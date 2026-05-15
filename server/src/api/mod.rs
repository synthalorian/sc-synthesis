pub mod auth;
pub mod fleet;
pub mod ships;

use axum::{Router, routing::{get, post}};
use sqlx::SqlitePool;

use crate::Config;

/// Shared application state
#[derive(Clone)]
pub struct AppState {
    pub db: SqlitePool,
    pub config: Config,
}

/// Build the API router
pub fn router(state: AppState) -> Router {
    Router::new()
        // Health check
        .route("/api/v1/status", get(status_handler))
        // Auth
        .route("/api/v1/auth/login", axum::routing::post(auth::login))
        .route("/api/v1/auth/verify", axum::routing::post(auth::verify_2fa))
        .route("/api/v1/auth/logout", axum::routing::delete(auth::logout))
        // Fleet
        .route("/api/v1/fleet", get(fleet::get_fleet))
        .route("/api/v1/fleet/value", get(fleet::get_fleet_value))
        // Ships
        .route("/api/v1/ships", get(ships::list_ships))
        .route("/api/v1/ships/sync", post(ships::sync_ships))
        .route("/api/v1/ships/:id", get(ships::get_ship))
        .with_state(state)
}

/// Health check handler
async fn status_handler() -> axum::Json<serde_json::Value> {
    axum::Json(serde_json::json!({
        "status": "ok",
        "version": env!("CARGO_PKG_VERSION"),
        "service": "sc-synthesis-server"
    }))
}
