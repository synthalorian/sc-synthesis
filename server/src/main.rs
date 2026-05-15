use std::net::SocketAddr;
use anyhow::Context;
use clap::Parser;
use sqlx::sqlite::SqlitePoolOptions;
use tower_http::cors::CorsLayer;
use tower_http::trace::TraceLayer;
use tracing_subscriber::EnvFilter;

mod api;
mod config;
mod data;
mod db;
mod scraping;

pub use config::Config;
pub use data::models;

/// SC:Synthesis — Star Citizen Companion App Backend
#[derive(Parser, Debug)]
#[command(name = "sc-synthesis-server")]
struct Args {
    /// Path to config file
    #[arg(short, long, default_value = "config.toml")]
    config: String,

    /// Database URL
    #[arg(short, long)]
    database_url: Option<String>,

    /// Server bind address
    #[arg(short, long, default_value = "0.0.0.0:3001")]
    bind: String,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::try_from_default_env()
            .unwrap_or_else(|_| "sc_synthesis_server=debug,tower_http=info".into()))
        .init();

    let args = Args::parse();

    // Load config
    let config = Config::load(&args.config).unwrap_or_default();

    // Database
    let database_url = args.database_url
        .unwrap_or_else(|| config.database.url.clone());

    let pool = SqlitePoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await
        .context("Failed to connect to SQLite database")?;

    // Run migrations
    db::migrate(&pool).await?;

    // Build router
    let app_state = api::AppState {
        db: pool,
        config: config.clone(),
    };

    let app = api::router(app_state)
        .layer(CorsLayer::permissive())
        .layer(TraceLayer::new_for_http());

    let addr: SocketAddr = args.bind.parse()
        .context("Invalid bind address")?;

    tracing::info!("🚀 SC:Synthesis server starting on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;

    Ok(())
}
