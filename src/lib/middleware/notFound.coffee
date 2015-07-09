logger = require '../logger'

exports.index = (req, res, next) ->
  logger.error 'Not Found'
  res.json 404, 'Not Found'
