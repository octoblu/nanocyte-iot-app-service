_                      = require 'lodash'
mongojs                = require 'mongojs'
Datastore              = require 'meshblu-core-datastore'

ConfigurationGenerator = require 'nanocyte-configuration-generator'
ConfigurationSaver     = require 'nanocyte-configuration-saver-redis'
MeshbluConfig          = require 'meshblu-config'
MeshbluHttp            = require 'meshblu-http'

IotAppPublisher        = require 'nanocyte-iot-app-publisher'
redis                  = require 'ioredis'

class NanocyteIotAppService
  constructor: ({MONGODB_URI, REDIS_URI}, {@meshbluConfig, @channelConfig}) ->
    throw new Error 'MONGODB_URI is required' unless MONGODB_URI?
    throw new Error 'REDIS_URI is required' unless REDIS_URI?

    @meshbluConfig             ?= new MeshbluConfig().toJSON()
    @client                    = redis.createClient REDIS_URI, dropBufferSupport: true
    database                   = mongojs MONGODB_URI

    @datastore = new Datastore
      database: database
      collection: 'iot-apps'

  publish: ({appId, version, meshbluAuth}, callback)=>
    meshbluHttp = @_createMeshbluHttp meshbluAuth
    meshbluHttp.generateAndStoreTokenWithOptions appId, {tag: 'nanocyte-flow-deploy-service'}, (error, {token}={}) =>
      return callback error  if error?

      options         = appId: appId, appToken: token, version: version, meshbluConfig: new MeshbluConfig @meshbluConfig
      iotAppPublisher = @_createIotAppPublisher options
      iotAppPublisher.publish (error) =>
        return callback error  if error?
        meshbluHttp.register {}, callback

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

  _createIotAppPublisher: (options) =>
    {appId, appToken} = options

    meshbluJSON =
      _.extend {}, @meshbluConfig, {uuid:  appId, token: appToken}

    configurationSaver     = new ConfigurationSaver {@client, @datastore}
    configurationGenerator = new ConfigurationGenerator {meshbluJSON}, {@channelConfig}

    new IotAppPublisher options, {configurationSaver, configurationGenerator}


  _createMeshbluHttp: (options) =>
    meshbluJSON = _.assign {}, @meshbluConfig, options
    new MeshbluHttp meshbluJSON

module.exports = NanocyteIotAppService
