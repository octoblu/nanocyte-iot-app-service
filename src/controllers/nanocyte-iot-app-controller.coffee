debug                  = require('debug')('nanocyte-flow-deploy-service:iot-app-controller')

class IotAppController
  constructor: (dependencies={}) ->

  publish: (req, res) =>
    res.send(201)

  sync: (req, res) =>


module.exports = IotAppController
