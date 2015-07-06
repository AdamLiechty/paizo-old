var bunyan = require("bunyan")

var logger = bunyan.createLogger({name: 'paizo', service: 'paizo', version: 'NO_VERSION'});

module.exports = logger;
