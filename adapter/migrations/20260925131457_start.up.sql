-- update_atを自動更新する関数
-- 参考: CREATE FUNCTION https://www.postgresql.org/docs/current/sql-createfunction.html
-- 参考: PL/pgSQL   https://www.postgresql.org/docs/current/plpgsql.html
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS '
  BEGIN
    new.updated_at := ''now'';
    return new;
  END;
' LANGUAGE 'plpgsql';

-- booksテーブルの作成
-- 参考: CREATE TABLE        https://www.postgresql.org/docs/current/sql-createtable.html
-- 参考: gen_random_uuid()   https://www.postgresql.org/docs/current/functions-uuid.html
-- 参考: TIMESTAMP WITH TIME ZONE https://www.postgresql.org/docs/current/datatype-datetime.html
CREATE TABLE IF NOT EXISTS books (
    book_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    isbn VARCHAR(255) NOT NULL,
    description VARCHAR(1024) NOT NULL,
    created_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
    );

-- booksテーブルへのトリガー
-- 参考: CREATE TRIGGER https://www.postgresql.org/docs/current/sql-createtrigger.html
CREATE TRIGGER books_updated_at_trigger
    BEFORE UPDATE ON books FOR EACH ROW
    EXECUTE PROCEDURE set_updated_at();