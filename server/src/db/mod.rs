pub mod queries;

use sqlx::SqlitePool;
use tracing::info;

/// Run database migrations
pub async fn migrate(pool: &SqlitePool) -> anyhow::Result<()> {
    info!("Running database migrations...");

    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS ships (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            manufacturer TEXT NOT NULL,
            size TEXT NOT NULL DEFAULT 'unknown',
            role TEXT NOT NULL DEFAULT 'unknown',
            crew_min INTEGER NOT NULL DEFAULT 1,
            crew_max INTEGER NOT NULL DEFAULT 1,
            cargo_capacity REAL NOT NULL DEFAULT 0.0,
            pledge_price REAL NOT NULL DEFAULT 0.0,
            max_speed REAL NOT NULL DEFAULT 0.0,
            shield_hp REAL NOT NULL DEFAULT 0.0,
            hull_hp REAL NOT NULL DEFAULT 0.0,
            description TEXT NOT NULL DEFAULT ''
        )
        "#,
    )
    .execute(pool)
    .await?;

    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS components (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            size INTEGER NOT NULL DEFAULT 1,
            manufacturer TEXT NOT NULL DEFAULT 'Unknown',
            description TEXT NOT NULL DEFAULT ''
        )
        "#,
    )
    .execute(pool)
    .await?;

    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS pledges (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            ship_id TEXT NOT NULL,
            pledge_price REAL NOT NULL DEFAULT 0.0,
            insured INTEGER NOT NULL DEFAULT 1,
            buyback_available INTEGER NOT NULL DEFAULT 0,
            melt_value REAL NOT NULL DEFAULT 0.0,
            FOREIGN KEY (ship_id) REFERENCES ships(id)
        )
        "#,
    )
    .execute(pool)
    .await?;

    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS sessions (
            id TEXT PRIMARY KEY,
            username TEXT NOT NULL,
            rsi_token TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            expires_at TEXT NOT NULL
        )
        "#,
    )
    .execute(pool)
    .await?;

    sqlx::query(
        r#"
        CREATE TABLE IF NOT EXISTS commodities (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT NOT NULL DEFAULT 'general',
            base_price REAL NOT NULL DEFAULT 0.0
        )
        "#,
    )
    .execute(pool)
    .await?;

    info!("Database migrations complete");
    Ok(())
}
