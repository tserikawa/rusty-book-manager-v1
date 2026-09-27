use uuid::Uuid;

pub mod event;

/// データベースのカラムに対応するフィールド名を持つ構造体。
/// 読み取りに使用する。
#[derive(Debug)]
pub struct Book {
    pub id: Uuid,
    pub title: String,
    pub author: String,
    pub isbn: String,
    pub description: String,
}