use adapter::database::connect_database_with;
use adapter::redis::RedisClient;
use anyhow::{Context, Result};
use api::route::auth::routes;
use api::route::book::build_book_routers;
use api::route::health::build_health_check_routers;
use axum::Router;
use registry::AppRegistry;
use shared::{
    config::AppConfig,
    env::{which, Environment},
};
use std::net::{Ipv4Addr, SocketAddr};
use std::sync::Arc;
use tokio::net::TcpListener;
use tower_http::trace::{DefaultMakeSpan, DefaultOnRequest, DefaultOnResponse, TraceLayer};
use tower_http::LatencyUnit;
use tracing::Level;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};

#[tokio::main]
async fn main() -> Result<()> {
    init_logger()?;
    bootstrap().await
}

async fn bootstrap() -> Result<()> {
    // 設定情報を生成する。
    let app_config = AppConfig::new()?;
    // データベースへの接続のためのコネクションプールを取り出す。
    let pool = connect_database_with(&app_config.database);
    // redisへの接続を行うクライアントのインスタンス
    let kv = Arc::new(RedisClient::new(&app_config.redis)?);
    // AppRegistryを生成する。
    let registry = AppRegistry::new(pool, kv, app_config);
    // ルーティング
    let app = Router::new()
        .merge(build_health_check_routers())
        .merge(build_book_routers())
        .merge(routes())
        .layer(
            TraceLayer::new_for_http()
                .make_span_with(DefaultMakeSpan::new().level(Level::INFO))
                .on_request(DefaultOnRequest::new().level(Level::INFO))
                .on_response(
                    DefaultOnResponse::new()
                        .level(Level::INFO)
                        .latency_unit(LatencyUnit::Millis),
                ),
        )
        .with_state(registry);
    // サーバーの起動
    let addr = SocketAddr::new(Ipv4Addr::LOCALHOST.into(), 8080);
    let listener = TcpListener::bind(addr).await?;
    tracing::info!("Listening on {}", addr);
    axum::serve(listener, app)
        .await
        .context("Unexpected error happened in server")
        .inspect_err(|e| {
            tracing::error!(
                error.cause_chain = ?e,error.message = %e, "Unexpected error"
            )
        })
}

fn init_logger() -> Result<()> {
    let log_level = match which() {
        Environment::Development => "debug",
        Environment::Production => "debug",
    };

    // try_from_default_env()はデフォルトの環境変数(RUST_LOG)からログのフィルタリング設定を読み込む。
    let env_filter = EnvFilter::try_from_default_env().unwrap_or_else(|_| log_level.into());

    let subscriber = tracing_subscriber::fmt::layer()
        .with_file(true)
        .with_line_number(true)
        .with_target(false);

    tracing_subscriber::registry()
        .with(subscriber)
        .with(env_filter)
        .try_init()?;

    Ok(())
}


// 5.4.5　ログアウト機能の動作確認
// cargo make run
// ログイン
// curl -v "http://localhost:8080/auth/login" -H 'content-type: application/json' -d '{"email":"eleazar.fig@example.com","password":"password"}'
// > {"userId":"fa322ffe6a5942ed9e4b11f832253bb3","accessToken":"2f41167c778e45c9b16d8134eb1ce436"}
// ログアウト
// curl -v -X POST "http://localhost:8080/auth/logout" -H 'Authorization: Bearer a392bd7fd9814612ac1836a73ef387d0'