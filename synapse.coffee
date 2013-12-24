'use strict'

_          = require 'underscore'
handlebars = require 'handlebars'
program    = require 'commander'

haproxy    = require "#{__dirname}/src/haproxy"
{debug}    = require "#{__dirname}/src/utils"
serf       = require "#{__dirname}/src/serf"

print      = debug 'main'

program
  .version('0.0.0')
  .option('-i --identity   <module>', 'define name, roles, etc.', require)
  .option('-c --controller <module>', 'controller', require)
  .option('-t --template   <.handlebars>', 'HAProxy config template in handlebars', require)
  .parse(process.argv)

# Default Settings
program.identity   ?= require "#{__dirname}/example/identity"
program.controller ?= require "#{__dirname}/example/controller"
program.template   ?= require "#{__dirname}/example/haproxy.config"

throw new Error 'invalid controller' unless _.isFunction program.controller
throw new Error 'invalid template' unless _.isFunction program.template

serf
  .start()
  .flatMap(program.controller)
  .flatMap(program.template)
  .debounceImmediate(5 * 1000) # 5 seconds
  .skipDuplicates(_.isEqual)
  .flatMap(haproxy.start())
  .assign(print)
