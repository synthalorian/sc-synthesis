use std::time::Duration;
use chromiumoxide::browser::{Browser, BrowserConfig, HeadlessMode};
use chromiumoxide::Page;
use futures::StreamExt;
use serde::{Deserialize, Serialize};
use tokio::time::sleep;

/// RSI authentication client using headless Chrome for Turnstile bypass
pub struct RsiAuth {
    chrome_path: String,
    base_url: String,
}

/// A valid RSI session with cookies
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RsiSession {
    pub username: String,
    pub rsi_token: String,
    pub cookies_json: String,
    pub expires_at: String,
}

/// Result variants for RSI login
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum RsiLoginResult {
    Success(RsiSession),
    Requires2fa,
    Failed(String),
}

impl RsiSession {
    pub fn is_success(&self) -> bool {
        !self.rsi_token.is_empty()
    }
}

impl RsiLoginResult {
    pub fn is_success(&self) -> bool {
        matches!(self, RsiLoginResult::Success(_))
    }

    pub fn session(&self) -> Option<&RsiSession> {
        match self {
            RsiLoginResult::Success(s) => Some(s),
            _ => None,
        }
    }
}

impl RsiAuth {
    pub fn new(chrome_path: &str, base_url: &str) -> Self {
        Self {
            chrome_path: chrome_path.to_string(),
            base_url: base_url.to_string(),
        }
    }

    /// Login to RSI using headless Chrome to handle Cloudflare Turnstile
    pub async fn login(&self, username: &str, password: &str) -> anyhow::Result<RsiLoginResult> {
        tracing::info!("Launching headless Chrome for RSI login...");

        let config = BrowserConfig::builder()
            .headless_mode(HeadlessMode::New)
            .no_sandbox()
            .chrome_executable(&self.chrome_path)
            .window_size(1920, 1080);

        let cfg = config.build()
            .map_err(|e| anyhow::anyhow!("Failed to build browser config: {}", e))?;

        let (mut browser, mut handler) = Browser::launch(cfg)
            .await
            .map_err(|e| anyhow::anyhow!("Failed to launch browser: {}", e))?;

        // Process browser events in background
        let handler_handle = tokio::spawn(async move {
            while let Some(event) = handler.next().await {
                if let Err(e) = event {
                    tracing::debug!("Browser event error: {:?}", e);
                }
            }
        });

        let result = self.perform_login(&browser, username, password).await;

        // Close browser
        if let Err(e) = browser.close().await {
            tracing::warn!("Error closing browser: {}", e);
        }
        handler_handle.abort();

        result
    }

    async fn perform_login(
        &self,
        browser: &Browser,
        username: &str,
        password: &str,
    ) -> anyhow::Result<RsiLoginResult> {
        let login_url = format!("{}/login", self.base_url);
        tracing::info!("Navigating to {}", login_url);

        let page = browser.new_page(&login_url)
            .await
            .map_err(|e| anyhow::anyhow!("Failed to create page: {}", e))?;

        // Wait for page to fully load
        sleep(Duration::from_secs(3)).await;

        // Check if already logged in (redirected to account page)
        if let Ok(Some(url)) = page.url().await {
            tracing::info!("Current URL: {}", url);
            if !url.contains("/login") && !url.contains("signin") {
                tracing::info!("Already logged in, extracting cookies...");
                return self.extract_session(&page, username).await;
            }
        }

        // Enable stealth mode to avoid Cloudflare detection
        let _ = page.enable_stealth_mode().await;

        // Wait for login form to be ready
        tracing::info!("Looking for login form...");
        sleep(Duration::from_secs(2)).await;

        // Find and fill username field
        let username_filled = if let Ok(el) = page.find_element("input[name='username']").await {
            el.focus().await?;
            el.type_str(username).await.is_ok()
        } else if let Ok(el) = page.find_element("#login-username").await {
            el.focus().await?;
            el.type_str(username).await.is_ok()
        } else if let Ok(inputs) = page.find_elements("input[type='text'], input[autocomplete='username']").await {
            if let Some(input) = inputs.first() {
                input.focus().await?;
                input.type_str(username).await.is_ok()
            } else {
                false
            }
        } else {
            false
        };

        if username_filled {
            tracing::info!("Username entered");
        } else {
            tracing::warn!("Could not find username input");
        }

        sleep(Duration::from_millis(300)).await;

        // Find and fill password field
        let password_filled = if let Ok(el) = page.find_element("input[name='password']").await {
            el.focus().await?;
            el.type_str(password).await.is_ok()
        } else if let Ok(el) = page.find_element("#login-password").await {
            el.focus().await?;
            el.type_str(password).await.is_ok()
        } else if let Ok(inputs) = page.find_elements("input[type='password']").await {
            if let Some(input) = inputs.first() {
                input.focus().await?;
                input.type_str(password).await.is_ok()
            } else {
                false
            }
        } else {
            false
        };

        if password_filled {
            tracing::info!("Password entered");
        }

        sleep(Duration::from_millis(500)).await;

        // Click submit button
        let mut clicked = false;

        if let Ok(btn) = page.find_element("button[type='submit']").await {
            btn.click().await?;
            clicked = true;
        } else if let Ok(btn) = page.find_element("input[type='submit']").await {
            btn.click().await?;
            clicked = true;
        } else if let Ok(btns) = page.find_elements("button").await {
            // Try last button on page (usually submit)
            if let Some(btn) = btns.last() {
                btn.click().await?;
                clicked = true;
            }
        }

        if clicked {
            tracing::info!("Login button clicked");
        } else {
            tracing::warn!("No login button found, trying form submit via JS");
            let _ = page.evaluate(
                r#"document.querySelector('form')?.requestSubmit ? document.querySelector('form').requestSubmit() : document.querySelector('form').submit()"#
            ).await;
        }

        // Wait for login to process (navigation, Turnstile, etc.)
        tracing::info!("Waiting for login to complete...");
        sleep(Duration::from_secs(5)).await;

        // Check the final URL
        if let Ok(Some(url)) = page.url().await {
            tracing::info!("Post-login URL: {}", url);

            // Get a snippet of page content for debugging
            if let Ok(html) = page.content().await {
                let snippet: String = html.chars().take(300).collect();
                tracing::debug!("Page preview: {}", snippet);
            }

            // Success: redirected away from login
            if !url.contains("/login") && !url.contains("signin") && !url.contains("challenge") {
                tracing::info!("Login successful!");
                return self.extract_session(&page, username).await;
            }

            // 2FA check
            if url.contains("2fa") || url.contains("two-factor") || url.contains("otp") {
                tracing::info!("2FA required");
                return Ok(RsiLoginResult::Requires2fa);
            }

            // Turnstile/CAPTCHA
            if url.contains("turnstile") || url.contains("captcha") || url.contains("challenge") {
                tracing::warn!("Turnstile/CAPTCHA challenge detected at {}", url);
                return Ok(RsiLoginResult::Failed(
                    "Cloudflare Turnstile challenge detected. Try: (1) Log in manually in a regular browser first, then try the API, or (2) Use a non-headless mode.".to_string()
                ));
            }
        }

        // Post-login page content check
        if let Ok(html) = page.content().await {
            if html.contains("Incorrect") || html.contains("invalid") || html.contains("error") {
                tracing::warn!("Login form shows error message");
                return Ok(RsiLoginResult::Failed(
                    "Invalid username or password.".to_string()
                ));
            }
        }

        // Try waiting a bit more for async redirect
        tracing::info!("Waiting additional time for redirect...");
        sleep(Duration::from_secs(3)).await;

        if let Ok(Some(url)) = page.url().await {
            if !url.contains("/login") && !url.contains("signin") {
                tracing::info!("Login successful after additional wait!");
                return self.extract_session(&page, username).await;
            }
        }

        tracing::warn!("Login failed — still on login page");
        Ok(RsiLoginResult::Failed(
            "Login failed. Check credentials or try logging in manually.".to_string()
        ))
    }

    /// Extract cookies from the browser page after successful login
    async fn extract_session(&self, page: &Page, username: &str) -> anyhow::Result<RsiLoginResult> {
        sleep(Duration::from_secs(1)).await;

        let cookies = page.get_cookies()
            .await
            .map_err(|e| anyhow::anyhow!("Failed to get cookies: {}", e))?;

        tracing::info!("Extracted {} cookies", cookies.len());

        let mut rsi_token = String::new();
        let cookie_strings: Vec<String> = cookies.iter()
            .map(|c| format!("{}={}", c.name, c.value))
            .collect();

        // Look for RSI authentication token
        for cookie in &cookies {
            tracing::debug!("  Cookie: {} (domain: {})", cookie.name, cookie.domain);
            if cookie.name == "Rsi-Token" || cookie.name == "rsi_token" {
                rsi_token = cookie.value.clone();
            }
        }

        let cookies_json = serde_json::to_string(&cookies)
            .unwrap_or_else(|_| cookie_strings.join("; "));

        if rsi_token.is_empty() && !cookies.is_empty() {
            // Use the first session-identifying cookie
            tracing::warn!("No Rsi-Token found. Using available cookies for session.");
            // Still try with whatever cookies we got
        }

        if cookies.is_empty() {
            tracing::error!("No cookies were extracted! Login may have failed.");
            return Ok(RsiLoginResult::Failed(
                "No cookies received after login.".to_string()
            ));
        }

        let expires = chrono::Utc::now()
            .checked_add_signed(chrono::Duration::hours(24))
            .unwrap()
            .to_rfc3339();

        Ok(RsiLoginResult::Success(RsiSession {
            username: username.to_string(),
            rsi_token,
            cookies_json,
            expires_at: expires,
        }))
    }
}
