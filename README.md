# README
pleiadesを使用したサンプルアプリ。
山手線ゲームで遊べる。
## install
    $ git clone git@github.com:harukikubota/yamanote-game.git

    $ cd yamanote-game

    $ bundle install

## setup
    $ rake db:create && rake db:migrate && rake db:seed

    # サーバ環境に合わせたファイル名にする
    $ vi .env.development
    LINE_CHANNEL_TOKEN='put your key.'
    LINE_CHANNEL_SECRET='put your key.'

## start
    $ rails server

## botとのトーク
### テキストメッセージ
#### ゲーム開始
ゲームが開始されます。

#### 駅名
山手線駅名を送信することでゲームが進行します。

botがNPCとして、まだ解答していない駅名を言います。

#### 終了
ゲームが終了します。
