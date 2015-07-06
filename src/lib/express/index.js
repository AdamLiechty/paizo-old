var express = require("express")
, app = express()
, path = require("path")
, http = require("http")
, config = require("config")
, heartbeat = require("../routes/heartbeat")
, index = require("../routes/index")
, notFound = require("../middleware/notFound");

var port = config.express.port;
app.set("port", port);
var isHttps = config.express.isHttps;
var rootScheme = isHttps ? "https" : "http";
var rootPortPart = (isHttps && port == 443) || (!isHttps && port == 80) ? "" : (":" + port);
var rootUrl = rootScheme + "://" + config.express.host + rootPortPart;
config.express.rootUrl = rootUrl;

var auth = require("../auth")(express, app);

////////////////
// Express stack

app.set("views", path.join(__dirname, "../../views"));
app.set("view engine", "jade");

// Logger
app.use(express.logger({ immediate: true, format: "dev" }));

app.use(express.cookieParser());

// Authentication
app.use(auth.expressSession);
app.use(auth.passportInitialize);
app.use(auth.passportSession);

// Routes
app.get("/heartbeat", heartbeat.index);
auth.configureRoutes();
app.get("/", auth.ensureAuthenticated, index.index);

app.use(express.static(path.join(__dirname, "/../../public")));

// 404 as catch-all
app.use(notFound.index);

//
////////////////

var server = require("./server")(app);
module.exports = app;
