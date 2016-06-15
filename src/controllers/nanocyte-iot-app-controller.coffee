debug                  = require('debug')('nanocyte-flow-deploy-service:iot-app-controller')

class IotAppController
  constructor: ({@nanocyteIotAppService}) ->

  publish: (req, res) =>
    {meshbluAuth} = req
    {appId, version} = req.params

    @nanocyteIotAppService.publish {appId, version, meshbluAuth}, (error, bluprintDevice) =>
      return res.sendError(error) if error?
      res.status(201).send(bluprintDevice)

  sync: (req, res) =>


module.exports = IotAppController
