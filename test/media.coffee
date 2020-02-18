synthTest = not process.env.HOSTNAME

assert = require 'assert'
onvif = require('../lib/onvif')
serverMockup = require('./serverMockup') if synthTest
util = require('util')

describe 'Media', () ->
  cam = null
  before (done) ->
    options = {
      hostname: process.env.HOSTNAME || 'localhost'
      username: process.env.USERNAME || 'admin'
      password: process.env.PASSWORD || '9999'
      port: if process.env.PORT then parseInt(process.env.PORT) else 10101
    }
    cam = new onvif.Cam options, done

  describe 'getProfiles', () ->
    it 'should create an array of profile objects with correspondent properties', (done) ->
      cam.getProfiles (err, data) ->
        assert.equal err, null
        assert.ok Object.keys(cam.profiles).length > 0
        assert.equal cam.profiles, data
        done()

  describe 'createAndDeleteProfile', () ->
    name = 'test'
    token = 'testToken'
    it 'should create a new profile with name and token', (done) ->
      cam.createProfile {name: name, token: token}, (err, res) ->
        assert.equal err, null
        assert.equal res.$.fixed, false
        assert.equal res.name, name
        assert.equal res.$.token, token
        done()
    it 'should delete already created profile by its token', (done) ->
      cam.deleteProfile token, (err, res) ->
        assert.equal err, null
        assert.equal res, ''
        done()

  describe 'getVideoSourceConfigurations', () ->
    it 'should return videosource configurations', (done) ->
      cam.getVideoSourceConfigurations (err, res) ->
        assert.equal err, null
        assert.ok Array.isArray(res)
        assert.ok res.every (conf) ->
          conf.name and conf.token and conf.sourceToken and conf.bounds
        done()

  describe 'getVideoEncoderConfiguration', () ->
    it 'should return an error when no token present as a parameter or in #videoEncoderConfigurations array and there is no `videoEncoderConfigurations` property', (done) ->
      cam.getVideoEncoderConfiguration (err) ->
        assert.notEqual err, null
        done()
  describe 'getVideoEncoderConfigurationOptions', () ->
    it 'should return an error when options is given but does not have `configurationToken` or `profileToken`', (done) ->
      cam.getVideoEncoderConfigurationOptions {}, (err, res) ->
        assert.notEqual err, null
        done()


  describe 'getVideoEncoderConfigurations', () ->
    it 'should return video encoder configurations', (done) ->
      cam.getVideoEncoderConfigurations (err, res) ->
        assert.equal err, null
        assert.ok ['name', '$', 'quality', 'resolution', 'multicast'].every (prop) ->
          res.every (vec) ->
            !!vec[prop]
        done()

  describe 'getVideoEncoderConfiguration', () ->
    it 'should return a configuration for the first token in #videoEncoderConfigurations array', (done) ->
      cam.getVideoEncoderConfiguration (err, res) ->
        assert.equal err, null
        assert.ok ['name', '$', 'quality', 'resolution', 'multicast'].every (prop) ->
          !!res[prop]
        done()
    it 'should return a configuration for the named token as a first argument', (done) ->
      cam.getVideoEncoderConfiguration cam.videoEncoderConfigurations[0].$.token, (err, res) ->
        assert.equal err, null
        assert.ok ['name', '$', 'quality', 'resolution', 'multicast'].every (prop) ->
          !!res[prop]
        done()

  describe 'getVideoEncoderConfigurationOptions', () ->
    configurationToken = "configurationToken"
    profileToken = "profileToken"
    it 'should return generic configuration options', (done) ->
      cam.getVideoEncoderConfigurationOptions (err, res) ->
        assert.equal err, null
        assert.ok res.qualityRange
        done()
    it 'should return a configuration options when `options` is given as a string', (done) ->
      cam.getVideoEncoderConfigurationOptions configurationToken, (err, res) ->
        assert.equal err, null
        assert.ok res.qualityRange
        done()
    it 'should return a configuration options when `options` is given as an object with `configurationToken`', (done) ->
      cam.getVideoEncoderConfigurationOptions {configurationToken: configurationToken}, (err, res) ->
        assert.equal err, null
        assert.ok res.qualityRange
        done()
    it 'should return a configuration options when `options` is given as an object with `profileToken`', (done) ->
      cam.getVideoEncoderConfigurationOptions {profileToken: profileToken}, (err, res) ->
        assert.equal err, null
        assert.ok res.qualityRange
        done()
    it 'should return a configuration options when `options` is given as an object with both `configurationToken` and `profileToken`', (done) ->
      cam.getVideoEncoderConfigurationOptions {configurationToken: configurationToken,profileToken: profileToken}, (err, res) ->
        assert.equal err, null
        assert.ok res.qualityRange
        done()
    
  describe 'setVideoEncoderConfiguration', () ->
    it 'should generate an error when no token in the options is present', (done) ->
      cam.setVideoEncoderConfiguration {}, (err) ->
        assert.notEqual err, null
        done()
    it 'should accept setting existing configuration and return the same configuration by the getVideoEncoderConfiguration method', (done) ->
      cam.setVideoEncoderConfiguration cam.videoEncoderConfigurations[0], (err, res, xml) ->
        assert.equal err, null
        assert.deepEqual cam.videoEncoderConfigurations[0], res
        done()
    it 'should accept setting some new video configuration based on the existing', (done) ->
      conf = {
        token: cam.videoEncoderConfigurations[0].$.token
        resolution: cam.videoEncoderConfigurations[0].resolution
      }
      cam.setVideoEncoderConfiguration conf, (err, res) ->
        assert.equal err, null
        done()
    if synthTest
      it 'should emits error with wrong response', (done) ->
        serverMockup.conf.bad = true
        cam.setVideoEncoderConfiguration cam.videoEncoderConfigurations[0], (err, res) ->
          assert.notEqual err, null
          delete serverMockup.conf.bad
          done()

  describe 'getAudioSources', () ->
    it 'should return audio sources', (done) ->
      cam.getAudioSources (err, res) ->
        assert.equal err, null
        done()

  describe 'getAudioEncoderConfiguration', () ->
    it 'should return an error when no token present as a parameter or in #videoEncoderConfigurations array and there is no `videoEncoderConfigurations` property', (done) ->
      cam.getAudioEncoderConfiguration (err) ->
        assert.notEqual err, null
        done()         
 
  describe 'getAudioEncoderConfigurations', () ->
    it 'should return audio encoder configurations', (done) ->
      cam.getAudioEncoderConfigurations (err, res) ->
        assert.equal err, null
        done()

  describe 'getAudioEncoderConfigurationOptions', () ->
    it 'should return a configuration options for the first token in #audioEncoderConfigurations array', (done) ->
      cam.getAudioEncoderConfigurationOptions (err, res) ->
        assert.equal err, null
        assert.ok res.bitrateList
        done()
    it 'should return a configuration options for the named token as a first argument', (done) ->
      cam.getAudioEncoderConfigurationOptions cam.audioEncoderConfigurations[0].$.token, (err, res) ->
        assert.equal err, null
        assert.ok res.bitrateList
        done()

  describe 'setAudioEncoderConfiguration', () ->
    it 'should generate an error when no token in the options is present', (done) ->
      cam.setAudioEncoderConfiguration {}, (err) ->
        assert.notEqual err, null
        done()
    it 'should accept setting existing configuration and return the same configuration by the getAudioEncoderConfiguration method', (done) ->
      cam.setAudioEncoderConfiguration cam.audioEncoderConfigurations[0], (err, res, xml) ->
        assert.equal err, null
        assert.deepEqual cam.audioEncoderConfigurations[0], res
        done()
    it 'should accept setting some new audio configuration based on the existing', (done) ->
      conf = {
        token: cam.audioEncoderConfigurations[0].$.token
        bitrate: cam.audioEncoderConfigurations[0].bitrate
      }
      cam.setAudioEncoderConfiguration conf, (err, res) ->
        assert.equal err, null
        done()
    if synthTest
      it 'should emits error with wrong response', (done) ->
        serverMockup.conf.bad = true
        cam.setAudioEncoderConfiguration cam.audioEncoderConfigurations[0], (err, res) ->
          assert.notEqual err, null
          delete serverMockup.conf.bad
          done()


  describe 'getAudioEncoderConfiguration', () ->
    it 'should return a configuration for the first token in #videoEncoderConfigurations array', (done) ->
      cam.getAudioEncoderConfiguration (err, res) ->
        assert.equal err, null
        assert.ok ['name', '$', 'multicast'].every (prop) ->
          !!res[prop]
        done()
    it 'should return a configuration for the named token as a first argument', (done) ->
      cam.getAudioEncoderConfiguration cam.videoEncoderConfigurations[0].$.token, (err, res) ->
        assert.equal err, null
        assert.ok ['name', '$', 'multicast'].every (prop) ->
          !!res[prop]
        done()
              