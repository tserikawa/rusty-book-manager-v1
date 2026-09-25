use axum::{routing::get, Router};
use registry::AppRegistry;

use crate::handler::health::{health_check, health_check_db};

pub fn build_health_check_routers() -> Router<AppRegistry> {
    // Router<S> means a router that is missing a state of type S to be able to handle requests.

    // health, health/dbのように共通しているのでnestを使う。
    let routers = Router::new()
        .route("/", get(health_check))
        .route("/db", get(health_check_db));
    Router::new().nest("/health", routers)
}
