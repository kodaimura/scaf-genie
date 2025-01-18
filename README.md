# JLAT
## Julia Web Application Template
Julia(Genie)のWebアプリケーション雛形。詳しくはプログラム参照。  

## Install
### clone
```
$ git clone https://github.com/kodaimura/jlat
```
### jlat/bin にPATHを通す
```
export PATH=$PATH:path/to/jlat/bin
```
### 実行権限付与
```
$ chmod -R +x path/to/jlat/bin
```

## Usage
### プロジェクト作成
```
$ jlat <appname> [-db {SQLite| PostgreSQL | MySQL}]
```
* -db オプションを省略した場合は SQLite が選択される

### Dockerで起動
* Dockerコンテナ & アプリ起動
```
$ make dev
```
http://localhost:8000
