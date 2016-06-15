NanocyteIotAppController = require './controllers/nanocyte-iot-app-controller'

class Router
  constructor: ({@nanocyteIotAppService}) ->
  route: (app) =>
    nanocyteIotAppController = new NanocyteIotAppController {@nanocyteIotAppService}

    app.post '/bluprint/:appId/:version',      iotAppController.publish
    app.post '/bluprint/:appId/:version/link', iotAppController.link

module.exports = Router
