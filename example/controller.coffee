'use strict'

_ = require 'underscore'

module.exports = (listOfCurrentMembers) ->
  _.chain(listOfCurrentMembers)
  .groupBy('role')
  .map (server, role) ->
    {server, role}
  .value()
