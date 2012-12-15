_      = require 'underscore'
models = require './models'

Message = models.Message


module.exports = class ChatServer
  constructor: (server) ->
    @io      = require('socket.io').listen(server)
    @clients = {}

  run: ->
    @io.sockets.on 'connection', @connectAction

  connectAction: (socket) =>
    console.log '新しい接続が開始されました: socket_id %s', socket.id

    @clients[socket.id] = new Client(socket.id)
    console.log 'クライアントの状態', @clients

    @broadcastOnlineStatus socket

    socket.on 'message',    (data) => @messageAction(socket, data)
    socket.on 'login',      (name) => @loginAction(socket, name)
    socket.on 'disconnect', => @disconnectAction(socket)

    @initAction socket

  initAction: (socket) =>
    Message.find({}).limit(100).exec (err, messages) ->
      console.log '初期データを送信しました'
      socket.json.emit 'init', messages: messages

  messageAction: (socket, data) =>
    console.log 'メッセージを受信しました', data

    instance = new Message()
    instance.name    = data.name
    instance.message = data.message
    instance.type    = data.type
    instance.created = data.created = new Date()
    instance.save (err) ->
      if err
        console.log "MongoDB Write Error", err
      else
        console.log "Success to write to database"

    socket.json.emit 'message', data
    socket.json.broadcast.emit 'message', data
    console.log 'メッセージを通知しました', data

  loginAction: (socket, name) =>
    console.log 'ログインがありました', name

    client = @clients[socket.id]
    client.name    = name
    client.isGuest = false
    console.log 'クライアントの状態', @clients

    @messageAction socket,
      name: 'お知らせ'
      message: client.name + " さんが入室しました。"
      type: 'info'

    @broadcastOnlineStatus socket

  disconnectAction: (socket) =>
    client = @clients[socket.id]
    console.log '接続が切れました', client

    delete @clients[socket.id] if client?
    console.log 'クライアントの状態', @clients

    unless client?.isGuest
      @messageAction socket,
        name: 'お知らせ'
        message: client.name + " さんが退室しました。"
        type: 'info'

    @broadcastOnlineStatus socket

  broadcastOnlineStatus: (socket) =>
    clients = _.values @clients

    socket.json.emit 'online', clients
    socket.json.broadcast.emit 'online', clients

    console.log 'オンライン状況を通知しました', clients


class Client
  constructor: (id = '') ->
    @id = id
    @name = "Guest"
    @isGuest = true