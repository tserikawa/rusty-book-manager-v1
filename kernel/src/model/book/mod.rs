use crate::model::id::BookId;

pub mod event;

/// データベースのカラムに対応するフィールド名を持つ構造体。
/// 読み取りに使用する。
#[derive(Debug)]
pub struct Book {
    pub id: BookId,
    pub title: String,
    pub author: String,
    pub isbn: String,
    pub description: String,
}
