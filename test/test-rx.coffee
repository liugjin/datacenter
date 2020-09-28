###
* File: test-rx
* User: Pu
* Date: 2018/9/4
###

should = require 'should'

iced = require 'iced-coffee-script'
iced = iced.iced if iced.iced

describe 'test rx', ->
  before (done) ->
    done()

  after () ->

  it 'should be ok', (done) ->
    await setTimeout defer(), 1000
    console.log 'ok'
    done()
 
   