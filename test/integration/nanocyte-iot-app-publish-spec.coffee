http          = require 'http'
request       = require 'request'
shmock        = require '@octoblu/shmock'
Server        = require '../../src/server'
enableDestroy = require 'server-destroy'

describe 'Publish', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d
    enableDestroy @meshblu

    serverOptions =
      port: undefined,
      disableLogging: true
      MONGODB_URI: 'mongodb://localhost'
      REDIS_URI: 'localhost'

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    @server = new Server serverOptions, {meshbluConfig}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.destroy done

  describe 'On POST /bluprint/:appId/:version', ->
    beforeEach (done) ->
      userAuth = new Buffer('some-uuid:some-token').toString 'base64'

      @authDevice = @meshblu
        .post '/authenticate'
        .set 'Authorization', "Basic #{userAuth}"
        .reply 204

      options =
        uri: '/bluprint/the-app-id/6.0.0'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true

      request.post options, (error, @response, @body) =>
        done error

    it 'should auth handler', ->
      @authDevice.done()

    it 'should return a 201', ->
      expect(@response.statusCode).to.equal 201
