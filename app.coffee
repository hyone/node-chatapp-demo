express    = require 'express'
http       = require 'http'
ChatServer = require './chatserver'


app = express()

app.configure ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', "#{__dirname}/views"
  app.set 'view engine', 'ejs'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use require('connect-assets')()
  app.use express.static("#{__dirname}/public")

app.configure 'development', ->
  app.use express.errorHandler()

app.get '/', (req, res) ->
  res.render 'index', title: 'チャット'

server = http.createServer app
server.listen app.get('port'), ->
  console.log "Express server listening on port " + app.get('port')

chatserver = new ChatServer(server)
chatserver.run()