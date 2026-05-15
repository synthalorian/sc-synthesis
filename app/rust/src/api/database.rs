use rusqlite::{Connection, params};
use std::sync::Mutex;

use crate::api::model::{Ship, ShipImport};

/// Thread-safe database handle
pub struct Database {
    conn: Mutex<Connection>,
}

impl Database {
    /// Open or create the database at the given path, run migrations
    pub fn open(path: &str) -> Result<Self, String> {
        let conn = Connection::open(path).map_err(|e| format!("Failed to open DB: {e}"))?;
        let db = Self { conn: Mutex::new(conn) };
        db.migrate()?;
        Ok(db)
    }

    /// Create tables if they don't exist
    fn migrate(&self) -> Result<(), String> {
        let conn = self.conn.lock().map_err(|e| format!("Lock error: {e}"))?;
        conn.execute_batch(
            "CREATE TABLE IF NOT EXISTS ships (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                slug TEXT NOT NULL DEFAULT '',
                manufacturer TEXT NOT NULL DEFAULT '',
                classification TEXT NOT NULL DEFAULT '',
                focus TEXT NOT NULL DEFAULT '',
                crew_min INTEGER NOT NULL DEFAULT 1,
                crew_max INTEGER NOT NULL DEFAULT 1,
                cargo REAL NOT NULL DEFAULT 0.0,
                pledge_price REAL NOT NULL DEFAULT 0.0,
                max_speed REAL NOT NULL DEFAULT 0.0,
                size TEXT NOT NULL DEFAULT 'Unknown',
                description TEXT NOT NULL DEFAULT ''
            );"
        ).map_err(|e| format!("Migration failed: {e}"))?;
        Ok(())
    }

    /// Check if the database has any ships
    pub fn has_ships(&self) -> Result<bool, String> {
        let conn = self.conn.lock().map_err(|e| format!("Lock error: {e}"))?;
        let count: i64 = conn
            .query_row("SELECT COUNT(*) FROM ships", [], |r| r.get(0))
            .map_err(|e| format!("Query failed: {e}"))?;
        Ok(count > 0)
    }

    /// Import ships from bundled JSON into SQLite
    pub fn import_ships(&self, json: &str) -> Result<i64, String> {
        let ships: Vec<ShipImport> = serde_json::from_str(json)
            .map_err(|e| format!("JSON parse error: {e}"))?;

        let conn = self.conn.lock().map_err(|e| format!("Lock error: {e}"))?;

        // Begin transaction
        conn.execute_batch("BEGIN TRANSACTION")
            .map_err(|e| format!("Transaction start failed: {e}"))?;

        let mut imported = 0i64;
        for ship in &ships {
            let result = conn.execute(
                "INSERT OR REPLACE INTO ships (id, name, slug, manufacturer, classification, focus,
                 crew_min, crew_max, cargo, pledge_price, max_speed, size, description)
                 VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?13)",
                params![
                    ship.id, ship.name, ship.slug, ship.manufacturer,
                    ship.classification, ship.focus, ship.crew_min, ship.crew_max,
                    ship.cargo, ship.pledge_price, ship.max_speed, ship.size, ship.description
                ],
            );

            match result {
                Ok(_) => imported += 1,
                Err(e) => log::warn!("Failed to import ship '{}': {e}", ship.name),
            }
        }

        conn.execute_batch("COMMIT")
            .map_err(|e| format!("Transaction commit failed: {e}"))?;

        Ok(imported)
    }

    /// Get all ships from the database
    pub fn get_all_ships(&self) -> Result<Vec<Ship>, String> {
        let conn = self.conn.lock().map_err(|e| format!("Lock error: {e}"))?;
        let mut stmt = conn
            .prepare("SELECT id, name, slug, manufacturer, classification, focus,
                      crew_min, crew_max, cargo, pledge_price, max_speed, size, description
                      FROM ships ORDER BY manufacturer, name")
            .map_err(|e| format!("Prepare failed: {e}"))?;

        let rows = stmt
            .query_map([], |row| {
                Ok(Ship {
                    id: row.get(0)?,
                    name: row.get(1)?,
                    slug: row.get(2)?,
                    manufacturer: row.get(3)?,
                    classification: row.get(4)?,
                    focus: row.get(5)?,
                    crew_min: row.get(6)?,
                    crew_max: row.get(7)?,
                    cargo: row.get(8)?,
                    pledge_price: row.get(9)?,
                    max_speed: row.get(10)?,
                    size: row.get(11)?,
                    description: row.get(12)?,
                })
            })
            .map_err(|e| format!("Query failed: {e}"))?;

        let mut ships = Vec::new();
        for row in rows {
            ships.push(row.map_err(|e| format!("Row error: {e}"))?);
        }
        Ok(ships)
    }

    /// Get a single ship by ID
    pub fn get_ship_by_id(&self, id: &str) -> Result<Option<Ship>, String> {
        let conn = self.conn.lock().map_err(|e| format!("Lock error: {e}"))?;
        let mut stmt = conn
            .prepare("SELECT id, name, slug, manufacturer, classification, focus,
                      crew_min, crew_max, cargo, pledge_price, max_speed, size, description
                      FROM ships WHERE id = ?1")
            .map_err(|e| format!("Prepare failed: {e}"))?;

        let mut rows = stmt
            .query_map(params![id], |row| {
                Ok(Ship {
                    id: row.get(0)?,
                    name: row.get(1)?,
                    slug: row.get(2)?,
                    manufacturer: row.get(3)?,
                    classification: row.get(4)?,
                    focus: row.get(5)?,
                    crew_min: row.get(6)?,
                    crew_max: row.get(7)?,
                    cargo: row.get(8)?,
                    pledge_price: row.get(9)?,
                    max_speed: row.get(10)?,
                    size: row.get(11)?,
                    description: row.get(12)?,
                })
            })
            .map_err(|e| format!("Query failed: {e}"))?;

        match rows.next() {
            Some(Ok(ship)) => Ok(Some(ship)),
            Some(Err(e)) => Err(format!("Row error: {e}")),
            None => Ok(None),
        }
    }

    /// Search ships by query and size filter
    pub fn search_ships(
        &self,
        query: &str,
        size_filter: &str,
        manufacturer_filter: &str,
    ) -> Result<Vec<Ship>, String> {
        let conn = self.conn.lock().map_err(|e| format!("Lock error: {e}"))?;

        let mut sql = String::from(
            "SELECT id, name, slug, manufacturer, classification, focus,
             crew_min, crew_max, cargo, pledge_price, max_speed, size, description
             FROM ships WHERE 1=1"
        );
        let mut param_values: Vec<String> = Vec::new();

        if !query.is_empty() {
            sql.push_str(" AND (LOWER(name) LIKE ? OR LOWER(manufacturer) LIKE ? OR LOWER(classification) LIKE ?)");
            let q = format!("%{}%", query.to_lowercase());
            param_values.push(q.clone());
            param_values.push(q.clone());
            param_values.push(q);
        }
        if !size_filter.is_empty() {
            sql.push_str(" AND LOWER(size) = ?");
            param_values.push(size_filter.to_lowercase());
        }
        if !manufacturer_filter.is_empty() {
            sql.push_str(" AND manufacturer = ?");
            param_values.push(manufacturer_filter.to_string());
        }

        sql.push_str(" ORDER BY manufacturer, name");

        let mut stmt = conn.prepare(&sql).map_err(|e| format!("Prepare failed: {e}"))?;

        let params_refs: Vec<&dyn rusqlite::types::ToSql> =
            param_values.iter().map(|v| v as &dyn rusqlite::types::ToSql).collect();

        let rows = stmt
            .query_map(params_refs.as_slice(), |row| {
                Ok(Ship {
                    id: row.get(0)?,
                    name: row.get(1)?,
                    slug: row.get(2)?,
                    manufacturer: row.get(3)?,
                    classification: row.get(4)?,
                    focus: row.get(5)?,
                    crew_min: row.get(6)?,
                    crew_max: row.get(7)?,
                    cargo: row.get(8)?,
                    pledge_price: row.get(9)?,
                    max_speed: row.get(10)?,
                    size: row.get(11)?,
                    description: row.get(12)?,
                })
            })
            .map_err(|e| format!("Query failed: {e}"))?;

        let mut ships = Vec::new();
        for row in rows {
            ships.push(row.map_err(|e| format!("Row error: {e}"))?);
        }
        Ok(ships)
    }

    /// Get distinct sizes
    pub fn get_available_sizes(&self) -> Result<Vec<String>, String> {
        let conn = self.conn.lock().map_err(|e| format!("Lock error: {e}"))?;
        let mut stmt = conn
            .prepare("SELECT DISTINCT size FROM ships ORDER BY size")
            .map_err(|e| format!("Prepare failed: {e}"))?;

        let rows = stmt
            .query_map([], |row| row.get::<_, String>(0))
            .map_err(|e| format!("Query failed: {e}"))?;

        let mut sizes = Vec::new();
        for row in rows {
            sizes.push(row.map_err(|e| format!("Row error: {e}"))?);
        }
        Ok(sizes)
    }

    /// Get distinct manufacturers
    pub fn get_available_manufacturers(&self) -> Result<Vec<String>, String> {
        let conn = self.conn.lock().map_err(|e| format!("Lock error: {e}"))?;
        let mut stmt = conn
            .prepare("SELECT DISTINCT manufacturer FROM ships ORDER BY manufacturer")
            .map_err(|e| format!("Prepare failed: {e}"))?;

        let rows = stmt
            .query_map([], |row| row.get::<_, String>(0))
            .map_err(|e| format!("Query failed: {e}"))?;

        let mut mfrs = Vec::new();
        for row in rows {
            mfrs.push(row.map_err(|e| format!("Row error: {e}"))?);
        }
        Ok(mfrs)
    }

    /// Total ship count
    pub fn ship_count(&self) -> Result<i64, String> {
        let conn = self.conn.lock().map_err(|e| format!("Lock error: {e}"))?;
        let count: i64 = conn
            .query_row("SELECT COUNT(*) FROM ships", [], |r| r.get(0))
            .map_err(|e| format!("Query failed: {e}"))?;
        Ok(count)
    }
}
