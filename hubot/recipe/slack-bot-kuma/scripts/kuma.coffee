"use strict"

config = require('./local/config')
GitHubApi = require('github')

github = new GitHubApi({
    "protocol": "https"
#    "host" : "github.my-GHE-enabled-company.com"
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
  msg.match(/^(くまー?|kuma)([\s　]|$)/)


# コマンドをディスパッチ
dispatch = (res, msg) ->
  tokens = msg.split(/\s+/)

  console.log(tokens)
  
  if tokens.lenght < 2
    noOrder(res, tokens)
    return

  switch tokens[1]
    when "日本語でおｋ"
      getChisei(res, tokens)
    
    when "ｸﾏｰ"
      getYasei(res, tokens)
    
    when "ぷるりく"
      execPullRequest(res, tokens)
    when "プルリク"
      execPullRequest(res, tokens)
    when "pullreq"
      execPullRequest(res, tokens)
    when "pullrequest"
      execPullRequest(res, tokens)
    
    else
      noUnderstand(res, tokens)

# ユーティリティ：話す
talk = (res, yaseiTalk, chiseiTalk) ->
  res.send((if _debug then "[debug]" else "") + "ʕ ·(ｴ)· ʔ " + (if _chisei then chiseiTalk else yaseiTalk))

# 失敗：
error = (res, reason) ->
  talk(res, "ｸﾏﾏｯ", "API投げたけど落ちたクマーッ！！理由はサーバーログ見ろクマ！")
  console.error(reason)

# コマンド：コマンドがない
noOrder = (res, tokens) ->
  talk(res, "ｸﾏ?", "クマー")


# コマンド：コマンドがわからない
noUnderstand = (res, tokens) ->
  talk(res, "ｸﾏ?", "コマンドが分からないクマー　リファレンス見ろクマ")


# コマンド：知性を取り戻す
getChisei = (res, tokens) ->
  _chisei = true
  res.send("ʕ ·(ｴ)· ʔ 把握したクマ")


# コマンド：野生を取り戻す
getYasei = (res, tokens) ->
  _chisei = false
  res.send("ʕ ·(ｴ)· ʔ ｸﾏｰ")

toggleDebug = (res, tokens) ->
  _debug ^= true;
  if _debug
    talk(res, "ｸﾏｰ", "デバッグ切り替えクマ")


# コマンド：プルリク処理
execPullRequest = (res, tokens) ->
  order = parsePullRequestTokens(tokens)
  
  switch (order.cmd)
    when "show"
      showPullRequest(res, order)
    else
      noUnderstand(res, tokens)

## サブ：プルリクのトークン分解
parsePullRequestTokens = (tokens) ->
  order =
    "cmd" : ""
    "target" : "all"
    "freeword" : []

  for token in tokens
    switch token

      when "みせて"
        order.cmd = "show"
      when "show"
        order.cmd = "show"
      
      else
        order.freeword.push(token)

  return order

## サブコマンド：プルリクエストを見せる
showPullRequest = (res, order) ->
  pullrequests = []
  canceled = false

  promise = new Promise((resolve, reject) ->    
    switch order.target
      when "all"
        pullrequests = github.pullRequests.getAll({
          "owner" : config.githubOwner
          "repo" : config.githubRepository
        }, (err, response) -> 
          if !err
            resolve(response)
          else
            reject(err)
        )
      else
        pullrequests = github.pullRequests.get({
          "owner" : config.githubOwner
          "repo" : config.githubRepository
          "number" : order.target
        }, (err, response) -> 
          if !err
            resolve(response)
          else
            reject(err)
        )
  ).then(
    (pullrequests)-> 
      if pullrequests.length
        res.send(pullrequests.map(req -> req.url)
                             .join('\r\n'))
      else
        talk(res, "っ[空箱]", "プルリクないクマ")
    ,(reason)->
      error(res, err)
  )
  
