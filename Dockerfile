# マルチステージビルドを使用し、Rustのプログラムをビルドする
# マルチステージビルドは「ビルド専用のステージ」「実行専用のステージ」を分ける手法
# これをしないと最終的なコンテナの中に容量の大きいビルドツールも残ってしまう。

# <ステージ1:ビルド用ステージ>
# Rust 1.78がインストール済みのイメージを土台にする。ASで名前をつける。
FROM rust:1.78-slim-bookworm AS builder
# これ以降のコマンドを実行するディレクトリを指定する。
WORKDIR /app
# ホスト側のファイルをコンテナ内にコピーする。
COPY . .
# コピーしたソースコードをビルドする。
RUN cargo build --release
# ↑これが終わると実行ファイルがこのステージに存在している。

# <ステージ2:実行用ステージ>
# 不要なソフトウェアを同梱する必要はないので、軽量はbookworm-slimを使用する
# 前のイメージとは違うイメージを作る。
FROM debian:bookworm-slim
# 作業ディレクトリを設定
WORKDIR /app

# ARG : ビルド時だけの変数
ARG DATABASE_URL
# ENV : コンテナが実際に起動して動いている間にも有効な環境変数
ENV DATABASE_URL=${DATABASE_URL}

# ユーザーを作成しておく
# adduser book : bookという名前の一般ユーザーを作成
# chown -R book /app : /appディレクトリの所有者を再帰的(-R)にbookに変更
RUN adduser book && chown -R book /app
# USER book : これ以降のコマンドをbookユーザーの権限で実行するように切り替える。
USER book
# -----　ここまではセキュリティ上の配慮。デフォルトではroot権限になってしまう。

# --from=builder : builderというステージから。
# app(実行ファイル)だけを前のステージからコピーしている。
COPY --from=builder ./app/target/release/app ./target/release/app

# 8080番ポートを解放し、アプリケーションを起動する

# コンテナ内の環境変数PORTに8080を設定する。
ENV PORT 8080
# 8080を使うことを明示する。
# 実際にポートを外部に公開する設定ではない。
# 外部に公開するにはcompose.yamlでports:の指定が別途必要
EXPOSE $PORT
# コンテナ起動時に実行するコマンド
ENTRYPOINT ["./target/release/app"]

# ステージ「1つのDockerfile内に書ける、独立したFROMから始まるひとまとまりの手順」