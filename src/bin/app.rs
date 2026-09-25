use std::net::{Ipv4Addr, SocketAddr};

use adapter::database::connect_database_with;
use anyhow::{Error, Result};
use api::route::health::build_health_check_routers;
use axum::Router;
use registry::AppRegistry;
use shared::config::AppConfig;
use tokio::net::TcpListener;

#[tokio::main]
async fn main() -> Result<()> {
    bootstrap().await
}

async fn bootstrap() -> Result<()> {
    // 設定情報を生成する。
    let app_config = AppConfig::new()?;
    // データベースへの接続のためのコネクションプールを取り出す。
    let pool = connect_database_with(&app_config.database);
    // AppRegistryを生成する。
    let registry = AppRegistry::new(pool);
    // ルーティング
    let app = Router::new()
        .merge(build_health_check_routers())
        .with_state(registry);
    // サーバーの起動
    let addr = SocketAddr::new(Ipv4Addr::LOCALHOST.into(), 8080);
    let listner = TcpListener::bind(&addr).await?;

    println!("Listening on: {}", addr);
    axum::serve(listner, app).await.map_err(Error::from)
}
