-- update_atを自動更新する関数
-- 参考: CREATE FUNCTION https://www.postgresql.org/docs/current/sql-createfunction.html
-- 参考: PL/pgSQL   https://www.postgresql.org/docs/current/plpgsql.html
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS '
  BEGIN
    new.updated_at := ''now'';
    return new;
  END;
' LANGUAGE 'plpgsql';

-- CREATE OR REPLACE FUNCTION set_updated_at() ～のクエリのあとに、
-- roles テーブルと users テーブルを追加する
CREATE TABLE IF NOT EXISTS roles (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role_id UUID NOT NULL ,
    created_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    FOREIGN KEY (role_id) REFERENCES roles(role_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- users テーブルの updated_at を自動更新するためのトリガー
CREATE TRIGGER users_updated_at_trigger
    BEFORE UPDATE ON users FOR EACH ROW
    EXECUTE PROCEDURE set_updated_at();

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
    user_id UUID NOT NULL,
    created_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    -- 以下の記述を追加
    FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- booksテーブルへのトリガー
-- 参考: CREATE TRIGGER https://www.postgresql.org/docs/current/sql-createtrigger.html
CREATE TRIGGER books_updated_at_trigger
    BEFORE UPDATE ON books FOR EACH ROW
    EXECUTE PROCEDURE set_updated_at();

CREATE TABLE IF NOT EXISTS checkouts (
    checkout_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book_id UUID NOT NULL UNIQUE,
    user_id UUID NOT NULL,
    checked_out_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS returned_checkouts (
    checkout_id UUID PRIMARY KEY,
    book_id UUID NOT NULL,
    user_id UUID NOT NULL,
    checked_out_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    returned_at TIMESTAMP(3) WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
);