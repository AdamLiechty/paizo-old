libFolder = if process.env["NODE_ENV"] is "COVERAGE" then 'lib-cov' else 'lib'
module.exports = require "./#{libFolder}/express"
