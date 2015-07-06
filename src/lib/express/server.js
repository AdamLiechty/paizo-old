var fs = require("fs")
, http = require("http")
, https = require("https")
, config = require("config");

function Server(app) {
  console.log(__dirname);
  var httpsOptions = {
    key: fs.readFileSync("secure/key.pem"),
    cert: fs.readFileSync("secure/cert.pem")
  };

  var server = config.express.isHttps
    ? https.createServer(httpsOptions, app)
    : http.createServer(app);

  return server.listen(app.get("port"));
}

module.exports = Server;
