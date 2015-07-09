express = require 'express'
app = express()
path = require 'path'
http = require 'http'
config = require 'config'
heartbeat = require '../routes/heartbeat'
index = require '../routes/index'
notFound = require '../middleware/notFound'

port = config.express.port
app.set 'port', port
isHttps = config.express.isHttps
rootScheme = if isHttps then 'https' else 'http'
rootPortPart = if (isHttps and port is 443) or (not isHttps and port is 80) then '' else ":#{port}"
rootUrl = "#{rootScheme}://#{config.express.host}#{rootPortPart}"
config.express.rootUrl = rootUrl;

auth = require('../auth')(express, app)

###############
# Express stack

app.set 'views', path.join __dirname, '../../views'
app.set 'view engine', 'jade'

# Logger
app.use express.logger
  immediate: true
  format: 'dev'

app.use express.cookieParser()

# Authentication
app.use auth.expressSession
app.use auth.passportInitialize
app.use auth.passportSession

# Routes
app.get '/heartbeat', heartbeat.index
auth.configureRoutes()
app.get '/', auth.ensureAuthenticated, index.index

app.use express.static path.join __dirname, '/../../public'

# 404 as catch-all
app.use notFound.index

##################
# Start web server
server = require('./server')(app)
module.exports = app
