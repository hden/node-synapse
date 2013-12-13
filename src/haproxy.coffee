'use strict'

{exec} = require 'child_process'
stream = require 'stream'

_      = require 'underscore'
debug  = require 'debug'
Q      = require 'q'

print  = debug 'haproxy'

backendTemplate = (list, role) ->
  list = list
  .map ({name, address}) ->
    "  server #{name} #{address} weight 1 maxconn 512"
  .join('\n')

  """
  backend #{role}
    balance roundrobin
  #{list}
  """
