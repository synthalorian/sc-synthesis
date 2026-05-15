use serde::{Deserialize, Serialize};

/// Server configuration
#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct Config {
    pub server: ServerConfig,
    pub database: DatabaseConfig,
    pub rsi: RsiConfig,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct ServerConfig {
    pub host: String,
    pub port: u16,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct DatabaseConfig {
    pub url: String,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct RsiConfig {
    /// RSI base URL
    pub base_url: String,
    /// Spectrum base URL
    pub spectrum_url: String,
    /// Request timeout in seconds
    pub timeout_secs: u64,
    /// User agent for scraping
    pub user_agent: String,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            server: ServerConfig {
                host: "0.0.0.0".into(),
                port: 3001,
            },
            database: DatabaseConfig {
                url: "sqlite:sc_synthesis.db?mode=rwc".into(),
            },
            rsi: RsiConfig {
                base_url: "https://robertsspaceindustries.com".into(),
                spectrum_url: "https://spectrum.chat".into(),
                timeout_secs: 30,
                user_agent: concat!(
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ",
                    "AppleWebKit/537.36 (KHTML, like Gecko) ",
                    "Chrome/125.0.0.0 Safari/537.36"
                ).into(),
            },
        }
    }
}

impl Config {
    pub fn load(path: &str) -> anyhow::Result<Self> {
        let content = std::fs::read_to_string(path)?;
        Ok(toml::from_str(&content)?)
    }
}
