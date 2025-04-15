# scaf-genie
## Julia Web Application Template
Julia(Genie)のWebアプリケーション雛形。詳しくはプログラム参照。  

## Install
### clone
```
$ git clone https://github.com/kodaimura/scaf-genie
```
### scaf-genie/bin にPATHを通す
```
export PATH=$PATH:path/to/scaf-genie/bin
```
### 実行権限付与
```
$ chmod -R +x path/to/scaf-genie/bin
```

## Usage
### プロジェクト作成
```
$ scaf-genie <appname> [-db {SQLite| PostgreSQL | MySQL}]
```
* -db オプションを省略した場合は SQLite が選択される

### Dockerで起動
* Dockerコンテナ & アプリ起動
```
$ make up
```
http://localhost:8000
