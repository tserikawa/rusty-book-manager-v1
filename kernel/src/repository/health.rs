use async_trait::async_trait;

#[async_trait]
pub trait HealthCheckRepository: Send + Sync {
    /// データベースに接続を確立できるかを確認するための関数
    async fn check_db(&self) -> bool;
}
