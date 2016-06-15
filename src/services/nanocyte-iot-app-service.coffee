mongojs                = require 'mongojs'
Datastore              = require 'meshblu-core-datastore'

ConfigurationGenerator = require 'nanocyte-configuration-generator'
ConfigurationSaver     = require 'nanocyte-configuration-saver-redis'
MeshbluConfig          = require 'meshblu-config'
MeshbluHttp            = require 'meshblu-http'

IotAppPublisher        = require 'nanocyte-iot-app-publisher'
redis                  = require 'ioredis'

class NanocyteIotAppService
  constructor: ({MONGODB_URI, REDIS_URI}) ->
    throw new Error 'MONGODB_URI is required' unless MONGODB_URI?
    throw new Error 'REDIS_URI is required' unless REDIS_URI?

    @meshbluConfig             = new MeshbluConfig
    @client                    = redis.createClient REDIS_URI, dropBufferSupport: true
    database                   = mongojs MONGODB_URI

    @datastore = new Datastore
      database: database
      collection: 'iot-apps'

  doHello: ({hasError}, callback) =>
    return callback @_createError(755, 'Not enough dancing!') if hasError?
    callback()

  _createError: (code, message) =>
    error = new Error message
    error.code = code if code?
    return error

  _createIotAppPublisher: (options) =>
    {appId, appToken} = options

    meshbluJSON =
      _.extend new MeshbluConfig().toJSON(), {uuid:  appId, token: appToken}

    configurationSaver     = new ConfigurationSaver {@client, @datastore}
    configurationGenerator = new ConfigurationGenerator {meshbluJSON}

    new IotAppPublisher options, {configurationSaver, configurationGenerator}


  _createMeshbluHttp: (options) =>
    meshbluJSON = _.assign {}, @meshbluConfig.toJSON(), options
    new MeshbluHttp meshbluJSON

module.exports = NanocyteIotAppService
