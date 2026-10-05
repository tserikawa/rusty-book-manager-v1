use crate::model::{id::UserId, role::Role};

pub mod event;

/// ユーザーを表す構造体
#[derive(Debug, PartialEq, Eq)]
pub struct User {
    pub id: UserId,
    pub name: String,
    pub email: String,
    pub role: Role,
}

/// 書籍の所有者を表す構造体
#[derive(Debug)]
pub struct BookOwner {
    pub id: UserId,
    pub name: String,
}

/// 借りたユーザーを表す構造体
#[derive(Debug)]
pub struct CheckoutUser {
    pub id: UserId,
    pub name: String,
}
