use reqwest::header::{HeaderMap, HeaderValue, USER_AGENT, COOKIE};
use serde::{Deserialize, Serialize};
use tracing;

/// Client for scraping user fleet/pledge data from RSI
pub struct PledgeScraper {
    client: reqwest::Client,
    base_url: String,
    user_agent: String,
}

/// A single pledge item from the RSI website
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ScrapedPledge {
    pub id: String,
    pub name: String,
    pub ship_id: String,
    pub pledge_price: f64,
    pub insured: bool,
    pub melt_value: f64,
}

/// Raw cookie struct for parsing stored cookies_json
#[derive(Debug, Clone, Serialize, Deserialize)]
struct RawCookie {
    name: String,
    value: String,
    #[serde(default)]
    domain: String,
    #[serde(default)]
    path: String,
}

impl PledgeScraper {
    pub fn new(base_url: &str, user_agent: &str) -> Self {
        let client = reqwest::Client::builder()
            .cookie_store(true)
            .build()
            .expect("Failed to build reqwest client");

        Self {
            client,
            base_url: base_url.to_string(),
            user_agent: user_agent.to_string(),
        }
    }

    /// Fetch all pledges for the authenticated user using an Rsi-Token cookie value.
    pub async fn fetch_pledges(&self, rsi_token: &str) -> anyhow::Result<Vec<ScrapedPledge>> {
        let account_url = format!("{}/api/account/ships", self.base_url);

        let mut headers = HeaderMap::new();
        headers.insert(USER_AGENT, HeaderValue::from_str(&self.user_agent)?);
        headers.insert("X-Requested-With", HeaderValue::from_static("XMLHttpRequest"));
        headers.insert("Referer", HeaderValue::from_str(&format!("{}/account/pledges", self.base_url))?);
        headers.insert("Accept", HeaderValue::from_static("application/json, text/plain, */*"));
        headers.insert(COOKIE, HeaderValue::from_str(&format!("Rsi-Token={}", rsi_token))?);

        let response = self.client
            .get(&account_url)
            .headers(headers)
            .timeout(std::time::Duration::from_secs(30))
            .send()
            .await
            .map_err(|e| anyhow::anyhow!("RSI API request failed: {}", e))?;

        let status = response.status();
        let text = response.text().await
            .map_err(|e| anyhow::anyhow!("Failed to read RSI response body: {}", e))?;

        tracing::debug!("RSI pledges response (status={}): {} bytes", status, text.len());

        if !status.is_success() {
            let preview: String = text.chars().take(500).collect();
            return Err(anyhow::anyhow!(
                "RSI API returned HTTP {}: {}",
                status,
                preview
            ));
        }

        // Try to parse as a JSON array
        if let Ok(pledges) = serde_json::from_str::<Vec<ScrapedPledge>>(&text) {
            tracing::info!("Successfully parsed {} pledges from RSI", pledges.len());
            return Ok(pledges);
        }

        // Try to parse as a JSON object with a "data" field (RSI sometimes wraps responses)
        if let Ok(wrapper) = serde_json::from_str::<serde_json::Value>(&text) {
            if let Some(data) = wrapper.get("data") {
                if let Some(arr) = data.as_array() {
                    let pledges: Vec<ScrapedPledge> = arr.iter()
                        .filter_map(|v| serde_json::from_value(v.clone()).ok())
                        .collect();
                    tracing::info!("Parsed {} pledges from RSI (data wrapper)", pledges.len());
                    return Ok(pledges);
                }
            }
            if let Some(ships) = wrapper.get("ships") {
                if let Some(arr) = ships.as_array() {
                    let pledges: Vec<ScrapedPledge> = arr.iter()
                        .filter_map(|v| serde_json::from_value(v.clone()).ok())
                        .collect();
                    tracing::info!("Parsed {} pledges from RSI (ships wrapper)", pledges.len());
                    return Ok(pledges);
                }
            }
        }

        let preview: String = text.chars().take(300).collect();
        tracing::warn!(
            "Could not parse RSI response as known format. Status={}, Preview: {}",
            status, preview
        );

        Ok(vec![])
    }

    /// Fetch pledges using a full cookies JSON string (as stored in the sessions table).
    /// The cookies_json is the serialized cookies array from the browser.
    /// This method parses the JSON to extract the Rsi-Token and also sets full cookies.
    pub async fn fetch_pledges_from_cookies(&self, cookies_json: &str) -> anyhow::Result<Vec<ScrapedPledge>> {
        // First, try to extract the Rsi-Token from the cookies JSON
        if let Ok(cookies) = serde_json::from_str::<Vec<RawCookie>>(cookies_json) {
            let rsi_token = cookies.iter()
                .find(|c| c.name == "Rsi-Token" || c.name == "rsi_token")
                .map(|c| c.value.clone());

            if let Some(token) = rsi_token {
                tracing::info!("Using extracted Rsi-Token from cookies JSON");
                return self.fetch_pledges(&token).await;
            }

            // If no Rsi-Token found but we have cookies, try using the full cookie string
            if !cookies.is_empty() {
                tracing::warn!("No Rsi-Token cookie found, trying full cookie header");
                let cookie_str: String = cookies.iter()
                    .map(|c| format!("{}={}", c.name, c.value))
                    .collect::<Vec<_>>()
                    .join("; ");
                return self.fetch_pledges_with_cookies(&cookie_str).await;
            }
        } else {
            // If it's not JSON, assume it's a raw Rsi-Token value
            tracing::info!("cookies_json is not JSON array, using as raw token");
            return self.fetch_pledges(cookies_json).await;
        }

        Err(anyhow::anyhow!("No valid cookies or token found for RSI scraping"))
    }

    /// Fetch pledges using a raw cookie header string (e.g. "Rsi-Token=abc; session=xyz")
    pub async fn fetch_pledges_with_cookies(&self, cookie_header: &str) -> anyhow::Result<Vec<ScrapedPledge>> {
        let account_url = format!("{}/api/account/ships", self.base_url);

        let mut headers = HeaderMap::new();
        headers.insert(USER_AGENT, HeaderValue::from_str(&self.user_agent)?);
        headers.insert("X-Requested-With", HeaderValue::from_static("XMLHttpRequest"));
        headers.insert("Referer", HeaderValue::from_str(&format!("{}/account/pledges", self.base_url))?);
        headers.insert("Accept", HeaderValue::from_static("application/json, text/plain, */*"));
        headers.insert(COOKIE, HeaderValue::from_str(cookie_header)?);

        let response = self.client
            .get(&account_url)
            .headers(headers)
            .timeout(std::time::Duration::from_secs(30))
            .send()
            .await
            .map_err(|e| anyhow::anyhow!("RSI API request (cookies) failed: {}", e))?;

        let status = response.status();
        let text = response.text().await
            .map_err(|e| anyhow::anyhow!("Failed to read RSI response body: {}", e))?;

        tracing::debug!("RSI pledges response (cookies, status={}): {} bytes", status, text.len());

        if !status.is_success() {
            let preview: String = text.chars().take(500).collect();
            return Err(anyhow::anyhow!(
                "RSI API returned HTTP {}: {}",
                status, preview
            ));
        }

        // Try direct array parse
        if let Ok(pledges) = serde_json::from_str::<Vec<ScrapedPledge>>(&text) {
            tracing::info!("Successfully parsed {} pledges from RSI (cookies)", pledges.len());
            return Ok(pledges);
        }

        // Try wrapper formats
        if let Ok(wrapper) = serde_json::from_str::<serde_json::Value>(&text) {
            for key in &["data", "ships", "pledges", "results"] {
                if let Some(val) = wrapper.get(*key) {
                    if let Some(arr) = val.as_array() {
                        let pledges: Vec<ScrapedPledge> = arr.iter()
                            .filter_map(|v| serde_json::from_value(v.clone()).ok())
                            .collect();
                        tracing::info!("Parsed {} pledges from RSI (wrapper.{})", pledges.len(), key);
                        return Ok(pledges);
                    }
                }
            }
        }

        let preview: String = text.chars().take(300).collect();
        tracing::warn!(
            "Could not parse RSI response. Status={}, Preview: {}",
            status, preview
        );

        Ok(vec![])
    }
}
