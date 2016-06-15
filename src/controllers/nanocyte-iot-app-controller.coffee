debug                  = require('debug')('nanocyte-flow-deploy-service:iot-app-controller')

class IotAppController
  constructor: ({@nanocyteIotAppService}) ->

  publish: (req, res) =>
    {meshbluAuth} = req
    {appId, version} = req.params

    @nanocyteIotAppService.publish {appId, version, meshbluAuth}, (error) =>
      return res.sendError(error) if error?
      res.send(201)

  sync: (req, res) =>


module.exports = IotAppController
