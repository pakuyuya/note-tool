## 概要

チャットツールやSNSと連携できるBOTツール。


## 導入（yoman、generator-hubot経由）

要約

* hubotはNodeJSでパッケージが存在する。
* テンプレートジェネレータのyomanと対応テンプレートgenerator-hubotを用いて初期化する
* ついでにcoffeescriptが必要なので取り入れる

### Sclakの環境を導入

Nodejsをインストールする。

* Windows
  * https://nodejs.org/ja/

* Linux

  ```
  sudo npm install -y nodejs npm
  ```

hubot、coffeescript、yoman、generator-hubotをnpm経由でインストールする
  
```
sudo npm install -g hubot coffee-script yo generator-hubot
```

hubotを配置したいディレクトリを作成
  
```
mkdir my-hugot
```

生成
  
```
yo hubot
```

質問にてきとーに答える。`Bot adapter` の質問までEnter連打でよい

ただし、`Bot adapter`の質問がきたら、欲しいアダプターを回答する
テンプレートにいくつか準備がある。

* https://hubot.github.com/docs/adapters/

* たとえば、Slackがほしければ `slack` と回答する。


以上で、hubotの導入が完了。


### 動かす

環境変数に、必要なものをセットしておくこと。以下、SLACK例。
  
```
export HUBOT_SLACK_TOKEN=xxxxx
# SlackのApp & integrationでGenerateしたものを設定する。
```

動かす。以下、Slack例（※起動後、プロセスを殺すまでコンソールが帰ってきません。）

```
bin/hubot --adapter slack
```

デーモン化したければ、何かのコマンドを組み合わせてどうこうする。
NodeJS製であれば、`forever`とかが良いそう。
