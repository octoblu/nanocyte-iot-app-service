cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
MeshbluAuth        = require 'express-meshblu-auth'
sendError          = require 'express-send-error'
MeshbluConfig      = require 'meshblu-config'
debug              = require('debug')('nanocyte-iot-app-service:server')
Router             = require './router'
NanocyteIotAppService = require './services/nanocyte-iot-app-service'

class Server
  constructor: ({@disableLogging, @port, @MONGODB_URI, @REDIS_URI}, {@meshbluConfig, @channelConfig})->
    @meshbluConfig ?= new MeshbluConfig().toJSON()
  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    meshbluAuth = new MeshbluAuth(@meshbluConfig)
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use sendError()
    app.use meshbluHealthcheck()
    app.use meshbluAuth.auth()
    app.use bodyParser.urlencoded limit: '1mb', extended : true
    app.use bodyParser.json limit : '1mb'

    app.options '*', cors()

    nanocyteIotAppService = new NanocyteIotAppService {@MONGODB_URI, @REDIS_URI}, {@meshbluConfig, @channelConfig}
    router = new Router {@meshbluConfig, nanocyteIotAppService}

    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
