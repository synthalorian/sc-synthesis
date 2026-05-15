use axum::{Json, extract::State, http::StatusCode};
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use crate::api::AppState;
use crate::scraping::auth::{RsiAuth, RsiLoginResult};

#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct LoginResponse {
    pub success: bool,
    pub requires_2fa: bool,
    pub session_id: Option<String>,
    pub message: String,
}

#[derive(Debug, Deserialize)]
pub struct Verify2faRequest {
    pub auth_code: String,
    pub session_token: String,
}

/// Proxy login to RSI using headless Chrome (handles Cloudflare Turnstile)
pub async fn login(
    State(state): State<AppState>,
    Json(req): Json<LoginRequest>,
) -> Result<Json<LoginResponse>, (StatusCode, Json<serde_json::Value>)> {
    let chrome_path = std::env::var("CHROME_PATH")
        .unwrap_or_else(|_| "/usr/bin/chromium".to_string());

    let auth = RsiAuth::new(&chrome_path, &state.config.rsi.base_url);

    tracing::info!("Attempting RSI login for user: {}", req.username);

    match auth.login(&req.username, &req.password).await {
        Ok(RsiLoginResult::Success(session)) => {
            // Store session in database
            let session_id = Uuid::new_v4().to_string();

            let _ = sqlx::query(
                "INSERT INTO sessions (id, username, rsi_token, expires_at) VALUES (?, ?, ?, ?)"
            )
            .bind(&session_id)
            .bind(&session.username)
            .bind(&session.cookies_json)
            .bind(&session.expires_at)
            .execute(&state.db)
            .await;

            tracing::info!("RSI login successful for {}", req.username);

            Ok(Json(LoginResponse {
                success: true,
                requires_2fa: false,
                session_id: Some(session_id),
                message: "Logged in successfully".to_string(),
            }))
        }
        Ok(RsiLoginResult::Requires2fa) => {
            tracing::info!("2FA required for {}", req.username);
            Ok(Json(LoginResponse {
                success: true,
                requires_2fa: true,
                session_id: None,
                message: "Two-factor authentication required. Please call /auth/verify with your 2FA code.".to_string(),
            }))
        }
        Ok(RsiLoginResult::Failed(msg)) => {
            tracing::warn!("RSI login failed for {}: {}", req.username, msg);
            Err((
                StatusCode::UNAUTHORIZED,
                Json(serde_json::json!({
                    "success": false,
                    "message": msg
                })),
            ))
        }
        Err(e) => {
            tracing::error!("RSI login error for {}: {:?}", req.username, e);
            Err((
                StatusCode::INTERNAL_SERVER_ERROR,
                Json(serde_json::json!({
                    "success": false,
                    "message": format!("Login error: {}", e)
                })),
            ))
        }
    }
}

/// Verify 2FA code
pub async fn verify_2fa(
    State(_state): State<AppState>,
    Json(_req): Json<Verify2faRequest>,
) -> Result<Json<LoginResponse>, (StatusCode, Json<serde_json::Value>)> {
    // TODO: Implement 2FA verification
    Ok(Json(LoginResponse {
        success: false,
        requires_2fa: false,
        session_id: None,
        message: "2FA verification pending implementation".into(),
    }))
}

/// Logout and destroy session
pub async fn logout(
    State(state): State<AppState>,
) -> Json<serde_json::Value> {
    // TODO: Invalidate session
    Json(serde_json::json!({ "success": true }))
}
