use reqwest::header::{HeaderMap, HeaderValue, USER_AGENT};
use serde::{Deserialize, Serialize};

/// FleetYards API client — fetches ship data from api.fleetyards.net
pub struct FleetYardsClient {
    client: reqwest::Client,
    base_url: String,
}

impl FleetYardsClient {
    pub fn new() -> Self {
        let client = reqwest::Client::builder()
            .timeout(std::time::Duration::from_secs(60))
            .build()
            .expect("Failed to build reqwest client");

        Self {
            client,
            base_url: "https://api.fleetyards.net/v1".into(),
        }
    }

    /// Fetch all ships from FleetYards. Uses max per_page to minimize requests.
    pub async fn fetch_all_ships(&self) -> anyhow::Result<Vec<FleetYardsModel>> {
        let page_size = 240; // max per the API
        let url = format!("{}/models?per={}", self.base_url, page_size);

        let mut headers = HeaderMap::new();
        headers.insert(USER_AGENT, HeaderValue::from_static("SC:Synthesis/0.1"));
        headers.insert("Accept", HeaderValue::from_static("application/json"));

        let response = self.client.get(&url).headers(headers).send().await?;

        if !response.status().is_success() {
            anyhow::bail!(
                "FleetYards API returned {}: {}",
                response.status(),
                response.text().await.unwrap_or_default()
            );
        }

        let body: FleetYardsListResponse = response.json().await?;
        tracing::info!(
            "Fetched {} ships from FleetYards (total: {})",
            body.items.len(),
            body.meta.pagination.total_count
        );

        Ok(body.items)
    }
}

/// Top-level response from FleetYards API
#[derive(Debug, Deserialize)]
struct FleetYardsListResponse {
    items: Vec<FleetYardsModel>,
    meta: FleetYardsMeta,
}

#[derive(Debug, Deserialize)]
struct FleetYardsMeta {
    pagination: FleetYardsPagination,
}

#[derive(Debug, Deserialize)]
struct FleetYardsPagination {
    total_count: i64,
}

/// A ship model as returned by FleetYards
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FleetYardsModel {
    pub id: String,
    pub sc_identifier: Option<String>,
    pub name: String,
    pub slug: String,
    pub classification: Option<String>,
    pub classification_label: Option<String>,
    pub crew: Option<FleetYardsCrew>,
    pub description: Option<String>,
    pub focus: Option<String>,
    pub manufacturer: Option<FleetYardsManufacturer>,
    pub pledge_price: Option<f64>,
    pub pledge_price_label: Option<String>,
    pub price: Option<f64>,
    pub price_label: Option<String>,
    pub production_status: Option<String>,
    pub on_sale: Option<bool>,
    pub player_ownable: Option<bool>,
    pub in_game: Option<bool>,
    pub rsi_id: Option<String>,
    pub rsi_name: Option<String>,
    pub rsi_slug: Option<String>,
    pub metrics: Option<FleetYardsMetrics>,
    pub speeds: Option<FleetYardsSpeeds>,
    pub links: Option<FleetYardsLinks>,
    pub media: Option<FleetYardsMedia>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FleetYardsCrew {
    pub min: Option<i32>,
    pub max: Option<i32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FleetYardsManufacturer {
    pub name: Option<String>,
    pub long_name: Option<String>,
    pub slug: Option<String>,
    pub code: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FleetYardsMetrics {
    pub cargo: Option<f64>,
    pub beam: Option<f64>,
    pub length: Option<f64>,
    pub height: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FleetYardsSpeeds {
    pub max_speed: Option<f64>,
    pub max_scm_speed: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FleetYardsLinks {
    pub frontend: Option<String>,
    pub store_url: Option<String>,
    pub self_link: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FleetYardsMedia {
    pub angled_view: Option<FleetYardsImage>,
    pub angled_view_colored: Option<FleetYardsImage>,
    pub fleetchart_image: Option<String>,
    pub store_image: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FleetYardsImage {
    pub url: Option<String>,
    pub small_url: Option<String>,
    pub medium_url: Option<String>,
    pub large_url: Option<String>,
}

/// Convert a FleetYards model to our internal Ship model
impl FleetYardsModel {
    pub fn to_ship(&self) -> crate::data::models::Ship {
        let size = match self.classification.as_deref() {
            Some("capital") => "Capital",
            Some("large") => "Large",
            Some("medium") => "Medium",
            Some("small") | Some("snub") | Some("vehicle") => "Small",
            _ => "Unknown",
        };

        let crew_min = self.crew.as_ref().and_then(|c| c.min).unwrap_or(1);
        let crew_max = self.crew.as_ref().and_then(|c| c.max).unwrap_or(1);
        let cargo = self
            .metrics
            .as_ref()
            .and_then(|m| m.cargo)
            .unwrap_or(0.0);
        let max_speed = self
            .speeds
            .as_ref()
            .and_then(|s| s.max_speed)
            .unwrap_or(0.0);
        let pledge_price = self.pledge_price.unwrap_or(0.0);

        let manufacturer = self
            .manufacturer
            .as_ref()
            .map(|m| m.name.as_deref().unwrap_or("Unknown"))
            .unwrap_or("Unknown")
            .to_string();

        let description = self
            .description
            .clone()
            .unwrap_or_default()
            .chars()
            .take(1000)
            .collect();

        let slug = self.slug.clone();
        // Use the scIdentifier as our internal ship ID, falling back to slug
        let ship_id = self
            .sc_identifier
            .clone()
            .unwrap_or_else(|| slug.clone());

        crate::data::models::Ship {
            id: ship_id,
            name: self.name.clone(),
            manufacturer,
            size: size.to_string(),
            role: self
                .classification_label
                .clone()
                .unwrap_or_else(|| self.focus.clone().unwrap_or_default()),
            crew_min,
            crew_max,
            cargo_capacity: cargo,
            pledge_price,
            max_speed,
            shield_hp: 0.0, // FleetYards doesn't provide this directly
            hull_hp: 0.0,
            description,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ship_conversion() {
        let model = FleetYardsModel {
            id: "test-uuid".into(),
            sc_identifier: Some("orig_100i".into()),
            name: "100i".into(),
            slug: "orig-100i".into(),
            classification: Some("small".into()),
            classification_label: Some("Small".into()),
            crew: Some(FleetYardsCrew {
                min: Some(1),
                max: Some(1),
            }),
            description: Some("A nice ship".into()),
            focus: Some("Touring".into()),
            manufacturer: Some(FleetYardsManufacturer {
                name: Some("Origin Jumpworks".into()),
                long_name: Some("Origin Jumpworks".into()),
                slug: Some("origin-jumpworks".into()),
                code: Some("ORIG".into()),
            }),
            pledge_price: Some(45.0),
            pledge_price_label: Some("$45".into()),
            price: Some(500000.0),
            price_label: Some("500,000 aUEC".into()),
            production_status: Some("flight-ready".into()),
            on_sale: Some(true),
            player_ownable: Some(true),
            in_game: Some(true),
            rsi_id: Some("42".into()),
            rsi_name: Some("100i".into()),
            rsi_slug: Some("origin-100/100i".into()),
            metrics: Some(FleetYardsMetrics {
                cargo: Some(4.0),
                beam: Some(10.0),
                length: Some(18.0),
                height: Some(4.0),
            }),
            speeds: Some(FleetYardsSpeeds {
                max_speed: Some(1100.0),
                max_scm_speed: Some(200.0),
            }),
            links: Some(FleetYardsLinks {
                frontend: Some("https://fleetyards.net/ships/orig-100i".into()),
                store_url: Some("https://robertsspaceindustries.com/pledge/ships/origin-100/100i".into()),
                self_link: Some("https://api.fleetyards.net/v1/models/orig-100i".into()),
            }),
            media: Some(FleetYardsMedia {
                angled_view: Some(FleetYardsImage {
                    url: Some("https://example.com/img.png".into()),
                    small_url: None,
                    medium_url: None,
                    large_url: None,
                }),
                angled_view_colored: None,
                fleetchart_image: None,
                store_image: None,
            }),
        };

        let ship = model.to_ship();
        assert_eq!(ship.name, "100i");
        assert_eq!(ship.id, "orig_100i");
        assert_eq!(ship.manufacturer, "Origin Jumpworks");
        assert_eq!(ship.size, "Small");
        assert_eq!(ship.crew_min, 1);
        assert_eq!(ship.crew_max, 1);
        assert_eq!(ship.cargo_capacity, 4.0);
        assert_eq!(ship.pledge_price, 45.0);
        assert_eq!(ship.max_speed, 1100.0);
    }
}
