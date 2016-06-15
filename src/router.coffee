NanocyteIotAppController = require './controllers/nanocyte-iot-app-controller'

class Router
  constructor: ({@nanocyteIotAppService}) ->
  route: (app) =>
    nanocyteIotAppController = new NanocyteIotAppController {@nanocyteIotAppService}

    app.post '/bluprint/:appId/:version',      nanocyteIotAppController.publish
    app.post '/bluprint/:appId/:version/sync', nanocyteIotAppController.sync

module.exports = Router
