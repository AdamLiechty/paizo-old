passport = require 'passport'
GoogleStrategy = require('passport-google').Strategy
config = require 'config'

# Passport session setup
passport.serializeUser (user, done) ->
  done null, user

passport.deserializeUser (obj, done) ->
  done null, obj

Auth = (express, app) ->
  # Use the GoogleStrategy within Passport.
  # Strategies in passport require a `validate` function, which accept
  # credentials (in this case, an OpenID identifier and profile), and invoke a
  # callback with a user object.
  rootUrl = config.express.rootUrl

  passport.use new GoogleStrategy {
      returnURL: "#{rootUrl}#{config.auth.google.returnUrl}"
      realm: "#{rootUrl}/"
    }, (identifier, profile, done) ->
      # asynchronous verification, for effect...
      process.nextTick ->
        # To keep the example simple, the user's Google profile is returned to
        # represent the logged-in user.  In a typical application, you would want
        # to associate the Google account with a user record in your database,
        # and return that user instead.
        profile.identifier = identifier
        done null, profile

  configureRoutes = ->
    loginUrl = config.auth.loginUrl
    app.get loginUrl, (req, res) ->
      res.render 'login', { user: req.user }

    passportAuthenticateGoogle = passport.authenticate 'google',
      failureRedirect: loginUrl

    # GET [/auth/google]
    #   Use passport.authenticate() as route middleware to authenticate the
    #   request.  The first step in Google authentication will involve redirecting
    #   the user to google.com.  After authenticating, Google will redirect the
    #   user back to this application at [/auth/google/return]
    app.get config.auth.google.url, passportAuthenticateGoogle, (req, res) ->
      res.redirect '/'

    # GET [/auth/google/return]
    #   Use passport.authenticate() as route middleware to authenticate the
    #   request.  If authentication fails, the user will be redirected back to the
    #   login page.  Otherwise, the primary route function function will be called,
    #   which, in this example, will redirect the user to the home page.
    app.get config.auth.google.returnUrl, passportAuthenticateGoogle, (req, res) ->
      res.redirect '/'

    app.post config.auth.logoutUrl, (req, res) ->
      req.logout()
      res.redirect '/'

  # Simple route middleware to ensure user is authenticated.
  #   Use this route middleware on any resource that needs to be protected.  If
  #   the request is authenticated (typically via a persistent login session),
  #   the request will proceed.  Otherwise, the user will be redirected to the
  #   login page.
  ensureAuthenticated = (req, res, next) ->
    return next() if req.isAuthenticated()
    res.redirect config.auth.loginUrl

  val =
    expressSession: express.session
      secret: config.express.session.secret
    passportInitialize: passport.initialize()
    passportSession: passport.session()
    ensureAuthenticated: ensureAuthenticated
    configureRoutes: configureRoutes

module.exports = Auth;
