module.exports =
  application:
    name: 'node-template'
  auth:
    loginUrl: '/login'
    logoutUrl: '/logout'
    google:
      url: '/auth/google'
      returnUrl: '/auth/google/return'
  express:
    port: 3000
    isHttps: true
