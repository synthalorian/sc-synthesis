use serde::{Deserialize, Serialize};
use sqlx::FromRow;

/// Size classification for ships
#[derive(Debug, Clone, Serialize, Deserialize, sqlx::Type, PartialEq)]
#[sqlx(rename_all = "lowercase")]
pub enum ShipSize {
    Vehicle,
    Snub,
    Small,
    Medium,
    Large,
    Capital,
}

impl std::fmt::Display for ShipSize {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ShipSize::Vehicle => write!(f, "Vehicle"),
            ShipSize::Snub => write!(f, "Snub"),
            ShipSize::Small => write!(f, "Small"),
            ShipSize::Medium => write!(f, "Medium"),
            ShipSize::Large => write!(f, "Large"),
            ShipSize::Capital => write!(f, "Capital"),
        }
    }
}

/// A ship definition extracted from game data
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Ship {
    pub id: String,
    pub name: String,
    pub manufacturer: String,
    pub size: String,
    pub role: String,
    pub crew_min: i32,
    pub crew_max: i32,
    pub cargo_capacity: f64,
    pub pledge_price: f64,
    pub max_speed: f64,
    pub shield_hp: f64,
    pub hull_hp: f64,
    pub description: String,
}

impl Ship {
    /// Get a human-readable size label
    pub fn size_label(&self) -> &str {
        match self.size.to_lowercase().as_str() {
            "vehicle" => "Vehicle",
            "snub" => "Snub",
            "small" => "Small",
            "medium" => "Medium",
            "large" => "Large",
            "capital" => "Capital",
            _ => "Unknown",
        }
    }
}

/// A pledge/ship owned by a user
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Pledge {
    pub id: String,
    pub user_id: String,
    pub name: String,
    pub ship_id: String,
    pub pledge_price: f64,
    pub insured: bool,
    pub buyback_available: bool,
    pub melt_value: f64,
}

/// Component definition (power plant, cooler, shield, etc.)
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Component {
    pub id: String,
    pub name: String,
    pub category: String,
    pub size: i32,
    pub manufacturer: String,
    pub description: String,
}

/// Trade commodity prices
#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Commodity {
    pub id: String,
    pub name: String,
    pub category: String,
    pub base_price: f64,
}

/// Trading route between two locations
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TradeRoute {
    pub from: String,
    pub from_location: String,
    pub to: String,
    pub to_location: String,
    pub commodity: String,
    pub buy_price: f64,
    pub sell_price: f64,
    pub profit_per_scu: f64,
    pub distance_gm: f64,
    pub risk: String,
}
