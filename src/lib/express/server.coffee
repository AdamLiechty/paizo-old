fs = require 'fs'
http = require 'http'
https = require 'https'
config = require 'config'

module.exports = (app) ->
  httpsOptions =
    key: fs.readFileSync 'secure/key.pem'
    cert: fs.readFileSync 'secure/cert.pem'

  isHttps = config.express.isHttps
  server = if isHttps then https.createServer(httpsOptions, app) else http.createServer app
  port = app.get 'port'
  console.log "http#{if isHttps then 's' else ''}://localhost:#{port}"
  server.listen port
