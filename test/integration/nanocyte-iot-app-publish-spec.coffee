http          = require 'http'
request       = require 'request'
shmock        = require '@octoblu/shmock'
Server        = require '../../src/server'
enableDestroy = require 'server-destroy'
Redis         = require 'ioredis'

class VatChannelConfig
  fetch: (callback) => callback null, {}
  get: => {}
  update: (callback) => callback null

describe 'Publish', ->
  beforeEach (done) ->
    @client = new Redis()
    @meshblu = shmock 0xd00d
    enableDestroy @meshblu

    serverOptions =
      port: undefined,
      disableLogging: true
      MONGODB_URI: 'localhost/test'
      REDIS_URI: 'localhost'

    meshbluConfig =
      server: 'localhost'
      port: 0xd00d

    @server = new Server serverOptions, {meshbluConfig, channelConfig: new VatChannelConfig}

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.destroy done

  beforeEach ->
    @userAuth = new Buffer('some-uuid:some-token').toString 'base64'
    @flowAuth = new Buffer('the-app-id:alpha-bet').toString 'base64'
    @authDevice = @meshblu
      .post '/authenticate'
      .set 'Authorization', "Basic #{@userAuth}"
      .reply 204


  describe 'On POST /bluprint/:appId/:version', ->

    beforeEach 'generate token', ->
      @meshblu
        .post '/devices/the-app-id/tokens'
        .set 'Authorization', "Basic #{@userAuth}"
        .reply 201, {token: 'alpha-bet'}

    beforeEach 'search devices', ->
      @meshblu
        .post '/search/devices'
        .send {uuid: 'the-app-id'}
        .set 'Authorization', "Basic #{@flowAuth}"
        .reply 200, [{uuid: 'the-app-id', name: 'the-flow', flow: { nodes: [], links: [] } }]

    beforeEach 'update message schema', ->
      @meshblu
        .put '/v2/devices/the-app-id'
        .set 'Authorization', "Basic #{@flowAuth}"
        .reply 204

    afterEach (done) ->
      @client.del 'bluprint/the-app-id', done

    beforeEach (done) ->
      options =
        uri: '/bluprint/the-app-id/6.0.0'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true

      request.post options, (error, @response, @body) => done error

    it 'should authenticate with meshblu', ->
      @authDevice.done()

    it 'should publish the iot app', (done) ->
      @client.hkeys 'bluprint/the-app-id', (error, keys) =>
        expect(keys).to.contain '6.0.0/engine-output/config'
        done()

    it 'should return a 201', ->
      expect(@response.statusCode).to.equal 201
