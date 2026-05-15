use axum::{Json, extract::{State, Path}, http::StatusCode};
use serde::Serialize;
use crate::api::AppState;
use crate::db;
use crate::scraping::fleetyards::FleetYardsClient;

#[derive(Debug, Serialize)]
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

/// List all ships in the database
pub async fn list_ships(
    State(state): State<AppState>,
) -> Json<Vec<Ship>> {
    let ships = db::queries::get_all_ships(&state.db)
        .await
        .unwrap_or_default();

    Json(ships.into_iter().map(|s| Ship {
        id: s.id,
        name: s.name,
        manufacturer: s.manufacturer,
        size: s.size,
        role: s.role,
        crew_min: s.crew_min,
        crew_max: s.crew_max,
        cargo_capacity: s.cargo_capacity,
        pledge_price: s.pledge_price,
        max_speed: s.max_speed,
        shield_hp: s.shield_hp,
        hull_hp: s.hull_hp,
        description: s.description,
    }).collect())
}

/// Get single ship details
pub async fn get_ship(
    State(state): State<AppState>,
    Path(id): Path<String>,
) -> Result<Json<Ship>, (StatusCode, Json<serde_json::Value>)> {
    let ship = db::queries::get_ship_by_id(&state.db, &id)
        .await
        .map_err(|_| (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({"error": "Database error"})),
        ))?;

    match ship {
        Some(s) => Ok(Json(Ship {
            id: s.id,
            name: s.name,
            manufacturer: s.manufacturer,
            size: s.size,
            role: s.role,
            crew_min: s.crew_min,
            crew_max: s.crew_max,
            cargo_capacity: s.cargo_capacity,
            pledge_price: s.pledge_price,
            max_speed: s.max_speed,
            shield_hp: s.shield_hp,
            hull_hp: s.hull_hp,
            description: s.description,
        })),
        None => Err((
            StatusCode::NOT_FOUND,
            Json(serde_json::json!({"error": format!("Ship '{}' not found", id)})),
        )),
    }
}

/// Sync ships from FleetYards API into the local database
pub async fn sync_ships(
    State(state): State<AppState>,
) -> Json<serde_json::Value> {
    tracing::info!("Syncing ships from FleetYards.net...");

    let client = FleetYardsClient::new();

    match client.fetch_all_ships().await {
        Ok(models) => {
            let count = models.len();
            let mut imported = 0i64;
            let mut skipped = 0i64;

            for model in &models {
                let ship = model.to_ship();
                match db::queries::upsert_ship(&state.db, &ship).await {
                    Ok(_) => imported += 1,
                    Err(e) => {
                        tracing::warn!("Failed to upsert ship '{}': {}", ship.name, e);
                        skipped += 1;
                    }
                }
            }

            tracing::info!("Synced {} ships: {} imported, {} skipped from {}", imported, imported, skipped, count);

            Json(serde_json::json!({
                "success": true,
                "total_from_api": count,
                "imported": imported,
                "skipped": skipped,
                "message": format!("Imported {} ships from FleetYards", imported)
            }))
        }
        Err(e) => {
            tracing::error!("Failed to sync ships from FleetYards: {}", e);
            Json(serde_json::json!({
                "success": false,
                "message": format!("Sync failed: {}", e)
            }))
        }
    }
}
