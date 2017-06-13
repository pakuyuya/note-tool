"use strict"

config = require('./local/config')
GitHubApi = require('github')

github = new GitHubApi({
    "protocol": "https"
    "host": "api.github.com"
#    "pathPrefix": "/api/v3"
    "headers": 
        "user-agent": "hubot"
    "Promise": require('bluebird')
    "followRedirects": false
    "timeout": 5000
})

github.authenticate({
  "type": "basic"
  "username": config.githubUser
  "password": config.githubPassword
})

_chisei = false
_debug = false

module.exports = (robot) ->
  robot.hear /(.+)/, (res) ->
    if !isCall(res.match[1]) 
      return
    dispatch(res, res.match[1])


# 呼ばれたか判定
isCall = (msg) ->
  msg.match(/^(くまー?|@?kuma)([\s、,]|$)/)


# コマンドをディスパッチ
dispatch = (res, msg) ->
  tokens = msg.split(/[\s、,]+/)

  if (_debug)
    console.log(tokens)
  
  if tokens.lenght < 2
    noOrder(res, tokens)
    return

  switch tokens[1]
    when "日本語でおｋ"
      getChisei(res, tokens)
    
    when "すごーい！"
      getYasei(res, tokens)
    when "森へお帰り"
      getYasei(res, tokens)
    when "しゃけ"
      getYasei(res, tokens)
    when "ｸﾏｰ"
      getYasei(res, tokens)
    
    when "pr"
      execPullRequest(res, tokens)
    when "ぷるりく"
      execPullRequest(res, tokens)
    when "プルリク"
      execPullRequest(res, tokens)
    
    when "debug"
      toggleDebug(res, tokens)
    
    else
      noUnderstand(res)

# ユーティリティ：話す
talk = (res, yaseiTalk, chiseiTalk) ->
  res.send((if _debug then "[debug]" else "") + "ʕ ·(ｴ)· ʔ " + (if _chisei then chiseiTalk else yaseiTalk))

# 失敗：
error = (res, reason) ->
  talk(res, "ｸﾏﾏｯ", "API投げたけど落ちたクマーッ！！理由はサーバーログ見ろクマ！")
  console.error(reason)

# コマンド：コマンドがない
noOrder = (res, tokens) ->
  talk(res, "ｸﾏ", "クマー")


# コマンド：コマンドがわからない
noUnderstand = (res) ->
  talk(res, "ｸﾏ?", "コマンドが分からないクマー　リファレンス見ろクマ")


# コマンド：知性を取り戻す
getChisei = (res, tokens) ->
  _chisei = true
  res.send("ʕ ·(ｴ)· ʔ 把握したクマ")


# コマンド：野生を取り戻す
getYasei = (res, tokens) ->
  _chisei = false
  res.send("ʕ ·(ｴ)· ʔ ｸﾏｰ")


# コマンド：デバッグ切り替え
toggleDebug = (res, tokens) ->
  _debug ^= true;
  if _debug
    talk(res, "ｸﾏｰ", "デバッグ切り替えクマ。サーバーログに変化クマ。")


# コマンド：プルリク処理
execPullRequest = (res, tokens) ->
  if (_debug)
    console.log('enter execPullRequest()')
  
  order = parsePullRequestTokens(tokens)
  
  switch (order.cmd)
    when "show"
      showPullRequest(res, order)
    when "merge"
      mergePullRequest(res, order)
    else
      noUnderstand(res)

## サブ：プルリクのトークン分解
parsePullRequestTokens = (tokens) ->
  order =
    "cmd" : ""
    "target" : "all"
    "firstNumeric" : ""
    "freeword" : []

  for token in tokens
    switch token

    　when "全部"
        order.target ="all"
    　when "ぜんぶ"
        order.target ="all"
    　when "all"
        order.target ="all"

      when "みたい"
        order.cmd = "show"
      when "見たい"
        order.cmd = "show"
      when "みせて"
        order.cmd = "show"
      when "見せて"
        order.cmd = "show"
      when "show"
        order.cmd = "show"

      when "たべて"
        order.cmd = "merge"
      when "食べて"
        order.cmd = "merge"
      when "マージ"
        order.cmd = "merge"
      when "マージして"
        order.cmd = "merge"
      when "merge"
        order.cmd = "merge"
      
      else
        if order.firstNumeric != "" && token.match(/^\d+/)
          order.firstNumeric = token
        order.freeword.push(token)

  return order

## サブコマンド：プルリクエストを見せる
showPullRequest = (res, order) ->
  if (_debug)
    console.log('enter showPullRequest()')

  promise = new Promise((resolve, reject) ->    
    switch order.target
      when "all"
        github.pullRequests.getAll({
          "owner" : config.githubOwner
          "repo" : config.githubRepository
        }, (err, response) -> 
          if !err
            if _debug
              console.log("get response")
              console.log(response)
            resolve(response.data)
          else
            reject(err)
        )
      else
        if order.firstNumeric == ""
          noUnderstand(res)
          return

        github.pullRequests.get({
          "owner" : config.githubOwner
          "repo" : config.githubRepository
          "number" : order.firstNumeric
        }, (err, response) -> 
          if !err
            if _debug
              console.log("get response")
              console.log(response)
            resolve([response])
          else
            reject(err)
        )
  ).then(
    (pullrequests)-> 
      if pullrequests.length
        res.send(pullrequests.map((req) -> req.html_url)
                             .join('\r\n'))
      else
        talk(res, "っ[空箱] ｶﾗｶﾗ", "プルリクないクマ")
    ,(reason)->
      error(res, err)
  )

# ## サブコマンド：プルリクエストをマージ
mergePullRequest = (res, order) ->
  if (_debug)
    console.log('enter mergePullRequest()')

  promise = new Promise((resolve, reject) ->    
    switch order.target
      when "all"
        github.pullRequests.getAll({
          "owner" : config.githubOwner
          "repo" : config.githubRepository
        }, (err, response) -> 
          if !err
            if _debug
              console.log("get response")
              console.log(response)
            resolve(response.data)
          else
            reject(err)
        )
      else
        if order.firstNumeric == ""
          noUnderstand(res)
          return

        github.pullRequests.get({
          "owner" : config.githubOwner
          "repo" : config.githubRepository
          "number" : order.firstNumeric
        }, (err, response) -> 
          if !err
            if _debug
              console.log("get response")
              console.log(response)
            resolve([response])
          else
            reject(err)
        )
  ).then(
    (pullrequests) -> 
      if !pullrequests.length
        talk(res, "っ[空箱] ｶﾗｶﾗ", "プルリクないクマ")
        return
      
      rejected = false

      mergePromises = pullrequests.map(
          (pullrequest) ->
            return new Promise( (resolve, reject) -> 
              github.pullRequests.merge({
                "owner" : config.githubOwner
                "repo" : config.githubRepository
                "number" : pullrequest.number
              }, (err, response) -> 
                if !err
                  resolve(pullrequest.html_url)
                else
                  if (!rejected)
                    rejected = true
                    reject(err)
              )
            )
      )

      return Promise.all(mergePromises)
    ,(reason)->
        error(res, err)
  ).then(
    (urls) -> 
      msg = [
          (_chisei) ? "全部食べたクマ。" : "ｸﾏｰ",
          "```",
          "numbers:"
        ].concat(urls)
        .concat(["```"])
        .join("\r\n");

    ,(reason)->
      error(res, err)
  )