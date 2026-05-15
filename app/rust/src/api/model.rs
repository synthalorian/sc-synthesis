use serde::{Deserialize, Serialize};

/// A ship from the Star Citizen database
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Ship {
    pub id: String,
    pub name: String,
    pub slug: String,
    pub manufacturer: String,
    pub classification: String,
    pub focus: String,
    pub crew_min: i32,
    pub crew_max: i32,
    pub cargo: f64,
    pub pledge_price: f64,
    pub max_speed: f64,
    pub size: String,
    pub description: String,
}

impl Ship {
    pub fn pledge_price_label(&self) -> String {
        if self.pledge_price > 0.0 {
            format!("${}", self.pledge_price as i64)
        } else {
            String::new()
        }
    }

    pub fn cargo_label(&self) -> String {
        if self.cargo > 0.0 {
            format!("{} SCU", self.cargo as i64)
        } else {
            String::new()
        }
    }

    pub fn crew_label(&self) -> String {
        if self.crew_max > 1 {
            format!("{}-{} crew", self.crew_min, self.crew_max)
        } else {
            "1 pilot".to_string()
        }
    }
}

/// Raw JSON import format — matches the bundled assets/data/ships.json
#[derive(Debug, Deserialize)]
pub struct ShipImport {
    pub id: String,
    pub name: String,
    pub slug: String,
    pub manufacturer: String,
    pub classification: String,
    pub focus: String,
    pub crew_min: i32,
    pub crew_max: i32,
    pub cargo: f64,
    pub pledge_price: f64,
    pub max_speed: f64,
    pub size: String,
    pub description: String,
}
