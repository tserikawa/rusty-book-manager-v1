/// 書き込みに使用する構造体。
/// idフィールドはデータベースに自動付与されるようにするので持たせていない。
pub struct CreateBook {
    pub title: String,
    pub author: String,
    pub isbn: String,
    pub description: String,
}
