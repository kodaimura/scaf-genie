# ScafGenie

[Genie.jl](https://genieframework.com/) によるWebアプリ開発のテンプレートです。  
ログイン / サインアップ機能、JWT認証など、すぐに使える土台を用意しています。

---

## 🚀 使い方
このテンプレートは、[webscaf](https://github.com/kodaimura/webscaf)  を使って簡単にセットアップできます。

セットアップ後、以下のコマンドで起動できます。  
   ```bash
   make up
   ```
ログイン・サインアップ機能付きの Genie アプリが立ち上がります。  
http://localhost:8000

---

## 必要要件

- Docker / Docker Compose
- make コマンド

---

## コマンド一覧（Makefile）

```bash
make up        # コンテナ起動
make build     # コンテナの再ビルド
make down      # コンテナ停止 & 破棄
make stop      # コンテナ停止のみ
make in        # appコンテナ内にbashで入る
make log       # ログ監視
make ps        # コンテナの状態確認
```

環境を切り替えたいときは `ENV` を指定
```bash
make up ENV=prod      # 本番環境で起動
```

---

## ディレクトリ構成

```
.
├── Dockerfile
├── docker-compose.yml
├── docker-compose.prod.yml
├── entrypoint.sh
├── Makefile
├── bootstrap.jl              # Genieアプリのブート処理
├── routes.jl                 # URLルーティング
│
├── app/
│   └── resources/
│       ├── accounts/         # 認証機能（ログイン・登録）
│       └── core/             # JWT認証やエラーハンドリング
│
├── config/
│   ├── env/                  # 環境ごの設定
│   └── initializers/         # 起動時の初期化処理
│
├── db/
│   ├── connection.yml
│   ├── migrations/
│   └── seeds/
│
├── public/                   # 静的ファイル (HTML, CSS, JS, 画像)
│   ├── index.html
│   ├── login.html
│   ├── signup.html
│   └── ...
│
├── bin/                      # CLI起動用スクリプト群
├── src/ScafGenie.jl          # ScafGenieのエントリーポイント
└── test/                     # テストコード
```
