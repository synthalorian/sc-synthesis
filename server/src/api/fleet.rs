use axum::{Json, extract::State, http::{StatusCode, HeaderMap}};
use serde::{Deserialize, Serialize};
use tracing;
use crate::api::AppState;
use crate::scraping::pledges::PledgeScraper;

/// Ship info returned by the fleet endpoint
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ShipInfo {
    pub id: String,
    pub name: String,
    pub manufacturer: String,
    pub size: String,
    pub role: String,
    pub pledge_price: f64,
    pub insured: bool,
    pub melt_value: f64,
}

/// Response wrapper for the fleet endpoint
#[derive(Debug, Serialize)]
pub struct FleetResponse {
    pub success: bool,
    pub ships: Vec<ShipInfo>,
    pub source: String,
    pub message: String,
    pub stats: Option<FleetStats>,
}

#[derive(Debug, Serialize)]
pub struct FleetStats {
    pub total_ships: usize,
    pub total_pledge_value: f64,
    pub total_melt_value: f64,
}

/// Mock ship data to return when no RSI session is available
fn mock_ships() -> Vec<ShipInfo> {
    vec![
        ShipInfo {
            id: "mock-andromeda".into(),
            name: "Andromeda".into(),
            manufacturer: "RSI".into(),
            size: "Large".into(),
            role: "Multi-role".into(),
            pledge_price: 240.00,
            insured: true,
            melt_value: 240.00,
        },
        ShipInfo {
            id: "mock-avenger-titan".into(),
            name: "Avenger Titan".into(),
            manufacturer: "Aegis Dynamics".into(),
            size: "Small".into(),
            role: "Light Fighter".into(),
            pledge_price: 55.00,
            insured: true,
            melt_value: 50.00,
        },
        ShipInfo {
            id: "mock-cutter".into(),
            name: "Cutter".into(),
            manufacturer: "Drake Interplanetary".into(),
            size: "Small".into(),
            role: "Starter / Exploration".into(),
            pledge_price: 45.00,
            insured: true,
            melt_value: 40.00,
        },
        ShipInfo {
            id: "mock-prospector".into(),
            name: "Prospector".into(),
            manufacturer: "MISC".into(),
            size: "Medium".into(),
            role: "Mining".into(),
            pledge_price: 155.00,
            insured: true,
            melt_value: 155.00,
        },
        ShipInfo {
            id: "mock-arrow".into(),
            name: "Arrow".into(),
            manufacturer: "Anvil Aerospace".into(),
            size: "Small".into(),
            role: "Light Fighter".into(),
            pledge_price: 75.00,
            insured: true,
            melt_value: 75.00,
        },
    ]
}

fn compute_stats(ships: &[ShipInfo]) -> FleetStats {
    FleetStats {
        total_ships: ships.len(),
        total_pledge_value: ships.iter().map(|s| s.pledge_price).sum(),
        total_melt_value: ships.iter().map(|s| s.melt_value).sum(),
    }
}

/// Convert a scraped pledge to a ShipInfo, enriching with known ship data from the local DB
async fn pledge_to_ship_info(
    pledge: &crate::scraping::pledges::ScrapedPledge,
    _db: &sqlx::SqlitePool,
) -> ShipInfo {
    // Try to look up ship details from the local database
    let (manufacturer, size, role) = if !pledge.ship_id.is_empty() {
        if let Ok(Some(ship)) = crate::db::queries::get_ship_by_id(_db, &pledge.ship_id).await {
            (ship.manufacturer, ship.size, ship.role)
        } else {
            // Derive manufacturer from ship name or id prefix
            let mfr = derive_manufacturer(&pledge.name);
            (mfr, "Unknown".into(), "Ship".into())
        }
    } else {
        ("RSI".into(), "Unknown".into(), "Ship".into())
    };

    ShipInfo {
        id: pledge.id.clone(),
        name: pledge.name.clone(),
        manufacturer,
        size,
        role,
        pledge_price: pledge.pledge_price,
        insured: pledge.insured,
        melt_value: pledge.melt_value,
    }
}

/// Rough manufacturer derivation from ship/pledge name
fn derive_manufacturer(name: &str) -> String {
    let lower = name.to_lowercase();
    if lower.contains("andromeda") || lower.contains("constellation") || lower.contains("aurora") {
        "RSI".into()
    } else if lower.contains("avenger") || lower.contains("gladius") || lower.contains("eclipse")
        || lower.contains("retaliator") || lower.contains("redeemer") || lower.contains("hammerhead")
        || lower.contains("idris")
    {
        "Aegis Dynamics".into()
    } else if lower.contains("cutter") || lower.contains("caterpillar") || lower.contains("cutlass")
        || lower.contains("buccaneer") || lower.contains("herald") || lower.contains("kraken")
    {
        "Drake Interplanetary".into()
    } else if lower.contains("prospector") || lower.contains("freelancer") || lower.contains("hull")
        || lower.contains("starfarer") || lower.contains("odyssey") || lower.contains("endeavor")
        || lower.contains("reclaimer") || lower.contains("razer")
    {
        "MISC".into()
    } else if lower.contains("arrow") || lower.contains("hornet") || lower.contains("valkyrie")
        || lower.contains("carrack") || lower.contains("terrapin") || lower.contains("crucible")
        || lower.contains("gladiator") || lower.contains("hurricane")
    {
        "Anvil Aerospace".into()
    } else if lower.contains("300") || lower.contains("350r") || lower.contains("m50")
        || lower.contains("85x") || lower.contains("origin") || lower.contains("890")
    {
        "Origin Jumpworks".into()
    } else if lower.contains("mercury") || lower.contains("hercules") || lower.contains("genesis")
        || lower.contains("starlifter") || lower.contains("crusader")
    {
        "Crusader Industries".into()
    } else if lower.contains("sabre") || lower.contains("gladius") || lower.contains("blade")
        || lower.contains("glaive") || lower.contains("scythe") || lower.contains("talon")
    {
        "Esperia".into()
    } else if lower.contains("mustang") || lower.contains("alpha") || lower.contains("beta")
        || lower.contains("gamma") || lower.contains("delta") || lower.contains("omega")
        || lower.contains("consolidated")
    {
        "Consolidated Outland".into()
    } else if lower.contains("nomad") || lower.contains("tumbo") || lower.contains("san'tok")
        || lower.contains("defender") || lower.contains("banu")
    {
        "Banu".into()
    } else if lower.contains("vulture") || lower.contains("mantis") || lower.contains("nautilus")
    {
        "Aegis Dynamics".into()
    } else {
        "Unknown Manufacturer".into()
    }
}

/// Get all ships in user's fleet
///
/// Accepts an optional `X-Session-Id` header to use a specific session.
/// Falls back to the most recent non-expired session if no header is provided.
/// Returns mock/example data if no RSI session is available.
pub async fn get_fleet(
    State(state): State<AppState>,
    headers: HeaderMap,
) -> Result<Json<FleetResponse>, (StatusCode, Json<serde_json::Value>)> {
    // Determine which session to use
    let session_id = headers
        .get("X-Session-Id")
        .and_then(|v| v.to_str().ok())
        .map(|s| s.to_string());

    // Try to find a valid session
    let session_row = if let Some(ref sid) = session_id {
        // Look up the specific session
        sqlx::query_as::<_, (String, String, String, String)>(
            "SELECT id, username, rsi_token, expires_at FROM sessions WHERE id = ?"
        )
        .bind(sid)
        .fetch_optional(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Session lookup error: {}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "success": false, "message": "Database error" })),
            )
        })?
    } else {
        // Get the most recent non-expired session
        sqlx::query_as::<_, (String, String, String, String)>(
            "SELECT id, username, rsi_token, expires_at FROM sessions ORDER BY created_at DESC LIMIT 1"
        )
        .fetch_optional(&state.db)
        .await
        .map_err(|e| {
            tracing::error!("Session lookup error: {}", e);
            (
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({ "success": false, "message": "Database error" })),
            )
        })?
    };

    match session_row {
        Some((sid, username, rsi_token, expires_at)) => {
            tracing::info!("Found session {} for user {} (expires: {})", sid, username, expires_at);

            // Check if session is expired
            if let Ok(expires) = chrono::DateTime::parse_from_rfc3339(&expires_at) {
                if chrono::Utc::now() > expires {
                    tracing::warn!("Session {} is expired (expired at {})", sid, expires_at);
                    // Session expired — return mock data with a note
                    let mock = mock_ships();
                    let stats = compute_stats(&mock);
                    return Ok(Json(FleetResponse {
                        success: true,
                        ships: mock,
                        source: "mock".into(),
                        message: format!("Session expired. Showing example fleet data."),
                        stats: Some(stats),
                    }));
                }
            }

            // Try to scrape pledges from RSI
            let scraper = PledgeScraper::new(
                &state.config.rsi.base_url,
                &state.config.rsi.user_agent,
            );

            match scraper.fetch_pledges_from_cookies(&rsi_token).await {
                Ok(pledges) if !pledges.is_empty() => {
                    tracing::info!("Fetched {} pledges from RSI for user {}", pledges.len(), username);

                    // Convert pledges to ShipInfo
                    let mut ships = Vec::new();
                    for pledge in &pledges {
                        let info = pledge_to_ship_info(pledge, &state.db).await;
                        ships.push(info);
                    }

                    let stats = compute_stats(&ships);

                    Ok(Json(FleetResponse {
                        success: true,
                        ships,
                        source: "rsi".into(),
                        message: format!("Loaded {} ships from RSI fleet", pledges.len()),
                        stats: Some(stats),
                    }))
                }
                Ok(_) => {
                    // Empty result — could mean no ships or API returned nothing
                    tracing::warn!("RSI returned no pledges for user {}", username);

                    // Check if we have cached pledges in the DB
                    match crate::db::queries::get_user_pledges(&state.db, &username).await {
                        Ok(cached_pledges) if !cached_pledges.is_empty() => {
                            let ships: Vec<ShipInfo> = cached_pledges.iter().map(|p| ShipInfo {
                                id: p.id.clone(),
                                name: p.name.clone(),
                                manufacturer: derive_manufacturer(&p.name),
                                size: "Unknown".into(),
                                role: "Ship".into(),
                                pledge_price: p.pledge_price,
                                insured: p.insured,
                                melt_value: p.melt_value,
                            }).collect();

                            let stats = compute_stats(&ships);
                            Ok(Json(FleetResponse {
                                success: true,
                                ships,
                                source: "cache".into(),
                                message: "No new pledges from RSI. Showing cached data.".into(),
                                stats: Some(stats),
                            }))
                        }
                        _ => {
                            // No cached data either — return mock fallback
                            let mock = mock_ships();
                            let stats = compute_stats(&mock);
                            Ok(Json(FleetResponse {
                                success: true,
                                ships: mock,
                                source: "mock".into(),
                                message: format!(
                                    "RSI returned no pledges for '{}'. This may be a network issue or the session needs refresh. Showing example fleet data.",
                                    username
                                ),
                                stats: Some(stats),
                            }))
                        }
                    }
                }
                Err(e) => {
                    tracing::error!("Failed to fetch pledges from RSI: {:?}", e);

                    // Fall back to cached pledges
                    match crate::db::queries::get_user_pledges(&state.db, &username).await {
                        Ok(cached_pledges) if !cached_pledges.is_empty() => {
                            let ships: Vec<ShipInfo> = cached_pledges.iter().map(|p| ShipInfo {
                                id: p.id.clone(),
                                name: p.name.clone(),
                                manufacturer: derive_manufacturer(&p.name),
                                size: "Unknown".into(),
                                role: "Ship".into(),
                                pledge_price: p.pledge_price,
                                insured: p.insured,
                                melt_value: p.melt_value,
                            }).collect();

                            let stats = compute_stats(&ships);
                            Ok(Json(FleetResponse {
                                success: true,
                                ships,
                                source: "cache".into(),
                                message: format!("Could not reach RSI. Showing cached fleet data."),
                                stats: Some(stats),
                            }))
                        }
                        _ => {
                            // Return mock data with error note
                            let mock = mock_ships();
                            let stats = compute_stats(&mock);
                            Ok(Json(FleetResponse {
                                success: true,
                                ships: mock,
                                source: "mock".into(),
                                message: format!("Could not fetch fleet from RSI: {}. Showing example fleet data.", e),
                                stats: Some(stats),
                            }))
                        }
                    }
                }
            }
        }
        None => {
            // No session found — return mock data
            tracing::info!("No RSI session available, returning mock fleet data");

            let mock = mock_ships();
            let stats = compute_stats(&mock);

            let msg = if session_id.is_some() {
                "No session found with the provided X-Session-Id. Please log in first.".into()
            } else {
                "No RSI session available. Showing example fleet data — log in via POST /api/v1/auth/login to see your real ships.".into()
            };

            Ok(Json(FleetResponse {
                success: true,
                ships: mock,
                source: "mock".into(),
                message: msg,
                stats: Some(stats),
            }))
        }
    }
}

/// Get fleet valuation
pub async fn get_fleet_value(
    State(state): State<AppState>,
    headers: HeaderMap,
) -> Result<Json<serde_json::Value>, (StatusCode, Json<serde_json::Value>)> {
    // Reuse get_fleet logic but return just the value summary
    let fleet_result = get_fleet(State(state), headers).await;

    match fleet_result {
        Ok(fleet) => {
            let total_pledge = fleet.ships.iter().map(|s| s.pledge_price).sum::<f64>();
            let total_melt = fleet.ships.iter().map(|s| s.melt_value).sum::<f64>();

            Ok(Json(serde_json::json!({
                "success": true,
                "total_pledge_value": total_pledge,
                "total_melt_value": total_melt,
                "ship_count": fleet.ships.len(),
                "currency": "USD",
                "source": fleet.source
            })))
        }
        Err((_, err_json)) => Ok(err_json),
    }
}
