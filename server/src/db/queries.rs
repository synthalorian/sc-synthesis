use sqlx::SqlitePool;
use crate::data::models::{Ship, Pledge};

/// Insert or update a ship record
pub async fn upsert_ship(pool: &SqlitePool, ship: &Ship) -> anyhow::Result<()> {
    sqlx::query(
        r#"
        INSERT INTO ships (id, name, manufacturer, size, role, crew_min, crew_max, 
                           cargo_capacity, pledge_price, max_speed, shield_hp, hull_hp, description)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(id) DO UPDATE SET
            name = excluded.name,
            manufacturer = excluded.manufacturer,
            size = excluded.size,
            cargo_capacity = excluded.cargo_capacity,
            max_speed = excluded.max_speed
        "#
    )
    .bind(&ship.id)
    .bind(&ship.name)
    .bind(&ship.manufacturer)
    .bind(&ship.size)
    .bind(&ship.role)
    .bind(ship.crew_min)
    .bind(ship.crew_max)
    .bind(ship.cargo_capacity)
    .bind(ship.pledge_price)
    .bind(ship.max_speed)
    .bind(ship.shield_hp)
    .bind(ship.hull_hp)
    .bind(&ship.description)
    .execute(pool)
    .await?;
    Ok(())
}

/// Get all ships
pub async fn get_all_ships(pool: &SqlitePool) -> anyhow::Result<Vec<Ship>> {
    let ships = sqlx::query_as::<_, Ship>("SELECT * FROM ships ORDER BY manufacturer, name")
        .fetch_all(pool)
        .await?;
    Ok(ships)
}

/// Get a single ship by ID
pub async fn get_ship_by_id(pool: &SqlitePool, id: &str) -> anyhow::Result<Option<Ship>> {
    let ship = sqlx::query_as::<_, Ship>("SELECT * FROM ships WHERE id = ?")
        .bind(id)
        .fetch_optional(pool)
        .await?;
    Ok(ship)
}

/// Save pledges for a user
pub async fn save_pledges(pool: &SqlitePool, user_id: &str, pledges: &[Pledge]) -> anyhow::Result<()> {
    // Delete old pledges for this user
    sqlx::query("DELETE FROM pledges WHERE user_id = ?")
        .bind(user_id)
        .execute(pool)
        .await?;

    // Insert new pledges
    for pledge in pledges {
        sqlx::query(
            r#"
            INSERT INTO pledges (id, user_id, name, ship_id, pledge_price, insured, 
                                 buyback_available, melt_value)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            "#
        )
        .bind(&pledge.id)
        .bind(&pledge.user_id)
        .bind(&pledge.name)
        .bind(&pledge.ship_id)
        .bind(pledge.pledge_price)
        .bind(pledge.insured)
        .bind(pledge.buyback_available)
        .bind(pledge.melt_value)
        .execute(pool)
        .await?;
    }
    Ok(())
}

/// Get pledges for a user
pub async fn get_user_pledges(pool: &SqlitePool, user_id: &str) -> anyhow::Result<Vec<Pledge>> {
    let pledges = sqlx::query_as::<_, Pledge>(
        "SELECT * FROM pledges WHERE user_id = ? ORDER BY name"
    )
    .bind(user_id)
    .fetch_all(pool)
    .await?;
    Ok(pledges)
}
