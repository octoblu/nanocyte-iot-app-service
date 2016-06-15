chai      = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'
containSubset = require 'chai-subset'

chai.use sinonChai
chai.use containSubset

global.expect = chai.expect
global.sinon  = sinon
