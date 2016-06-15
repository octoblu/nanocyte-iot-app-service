class NanocyteIotAppController
  constructor: ({@nanocyteIotAppService}) ->

  hello: (request, response) =>
    {hasError} = request.query
    @nanocyteIotAppService.doHello {hasError}, (error) =>
      return response.status(error.code || 500).send(error: error.message) if error?
      response.sendStatus(200)

module.exports = NanocyteIotAppController
