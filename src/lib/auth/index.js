var passport = require("passport")
, GoogleStrategy = require("passport-google").Strategy
, config = require("config");

// Passport session setup
passport.serializeUser(function(user, done) {
  done(null, user);
});

passport.deserializeUser(function(obj, done) {
  done(null, obj);
});

function Auth(express, app) {
  // Use the GoogleStrategy within Passport.
  //   Strategies in passport require a `validate` function, which accept
  //   credentials (in this case, an OpenID identifier and profile), and invoke a
  //   callback with a user object.
  var rootUrl = config.express.rootUrl;

  passport.use(new GoogleStrategy({
      returnURL: rootUrl + config.auth.google.returnUrl,
      realm: rootUrl + "/"
    },
    function(identifier, profile, done) {
      // asynchronous verification, for effect...
      process.nextTick(function () {

        // To keep the example simple, the user's Google profile is returned to
        // represent the logged-in user.  In a typical application, you would want
        // to associate the Google account with a user record in your database,
        // and return that user instead.
        profile.identifier = identifier;
        return done(null, profile);
      });
    }
  ));

  function configureRoutes() {
    app.get(config.auth.loginUrl, function(req, res){
      res.render("login", { user: req.user });
    });

    // GET [/auth/google]
    //   Use passport.authenticate() as route middleware to authenticate the
    //   request.  The first step in Google authentication will involve redirecting
    //   the user to google.com.  After authenticating, Google will redirect the
    //   user back to this application at [/auth/google/return]
    app.get(config.auth.google.url),
      passport.authenticate("google", { failureRedirect: config.auth.loginUrl },
      function(req, res) {
        res.redirect("/");
      });

    // GET [/auth/google/return]
    //   Use passport.authenticate() as route middleware to authenticate the
    //   request.  If authentication fails, the user will be redirected back to the
    //   login page.  Otherwise, the primary route function function will be called,
    //   which, in this example, will redirect the user to the home page.
    app.get(config.auth.google.returnUrl,
      passport.authenticate("google", { failureRedirect: config.auth.loginUrl }),
      function(req, res) {
        res.redirect('/');
      });

    app.post(config.auth.logoutUrl, function(req, res){
      req.logout();
      res.redirect("/");
    });
  }

  // Simple route middleware to ensure user is authenticated.
  //   Use this route middleware on any resource that needs to be protected.  If
  //   the request is authenticated (typically via a persistent login session),
  //   the request will proceed.  Otherwise, the user will be redirected to the
  //   login page.
  function ensureAuthenticated(req, res, next) {
    if (req.isAuthenticated()) { return next(); }
    res.redirect(config.auth.loginUrl);
  }

  return {
    expressSession: express.session({ secret: config.express.session.secret }),
    passportInitialize: passport.initialize(),
    passportSession: passport.session(),
    ensureAuthenticated: ensureAuthenticated,
    configureRoutes: configureRoutes
  };
}

module.exports = Auth;
