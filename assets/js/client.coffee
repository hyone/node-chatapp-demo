class Application
  MESSAGE: 50

  outlet:
    loginBlock: '#loginBlock'
    loginForm: '#loginBlock form'
    nameTextbox: '#loginBlock form input[name=name]'
    messageBlock: '#messageBlock'
    messageForm: '#messageBlock form'
    messageTextBox: '#messageBlock form input[name=message]'
    validationError: '#validationError'
    messages: '#messages'
    messageTemplate: '#messageTemplate'
    onlineUserTotal: '#onlineUserTotal'
    onlineGuestTotal: '#onlineGuestTotal'
    onlineUsers: '#onlineUsers'

  constructor: (@config = {}) ->
    @config.socketUrl ?= "http://#{location.host}/"

    @user = null
    @socket = new Socket

    $(@outlet.loginForm).on 'submit', @loginAction
    $(@outlet.messageForm).on 'submit', @sendAction

  run: ->
    @socket.connect @config.socketUrl
    @socket.onInit @receiveInitAction
    @socket.onOnline @onlineAction
    @socket.onMessage @receiveMessageAction

    $(@outlet.nameText).focus()

  loginAction: (event) =>
    event.preventDefault()

    unless name = $(@outlet.nameTextbox).val()
      return $(@outlet.validationError).slideDown()

    @user = new User(name)
    @socket.notifyLogin(name)

    $(@outlet.loginBlock).slideUp()
    $(@outlet.messageBlock).slideDown()
    $(@outlet.messageTextBox).focus()

  sendAction: (event) =>
    event.preventDefault()
    $textbox = $(@outlet.messageTextBox)
    unless message = $textbox.val()
      return

    @socket.sendMessage @user.name, message
    $textbox.val('')

  onlineAction: (data) =>
    users = (user for user in data when user.isGuest isnt true)
    $(@outlet.onlineUserTotal).text(users.length)
    $(@outlet.onlineGuestTotal).text(data.length - users.length)

    names = (user.name for user in users)
    $(@outlet.onlineUsers).text(
      if names.length > 0 then "(#{names.join ', '})" else ""
    )

  receiveMessageAction: (data) =>
    @_renderMessage data

  receiveInitAction: (data) => 
    $(@outlet.messages).children().remove()
    @_renderMessage m for m in data.messages

  _renderMessage: (data) ->
    $template = $(@outlet.messageTemplate).clone()
    $template.removeAttr 'id'
    $template.find('[name]').text(data.name)
    $template.find('[message]').text(data.message)
    d = new Date(data.created)
    $template.find('[datetime] small').text(
      "#{d.getFullYear()}/#{d.getMonth()+1}/#{d.getDate()} #{d.getHours()}:#{d.getMinutes()}"
    )
    console.log data.type
    if data.type is 'info'
      $template.addClass 'message-info'
    $template.prependTo(@outlet.messages).slideDown()

    $messages = $(@outlet.messages)
    while $messages.children().length > @MESSAGE_MAX
      $messages.children(':last').remove()


class User
  constructor: (@name = '') ->

class Socket
  constructor: ->
    @con = null

  connect: (url) ->
    unless io?
      throw "socket.io.js have not loaded."
    @con = io.connect(url)

  onInit: (callback) ->
    @con.on 'init', callback

  onOnline: (callback) ->
    @con.on 'online', callback

  notifyLogin: (name) ->
    @con.emit 'login', name

  onLogin: (callback) ->
    @con.on 'login', callback

  sendMessage: (name, message) ->
    @con.json.emit 'message', { name: name, message: message }

  onMessage: (callback) ->
    @con.on 'message', callback

  onLogout: (callback) ->
    @con.on 'logout', callback


jQuery ->
  app = new Application
  app.run()