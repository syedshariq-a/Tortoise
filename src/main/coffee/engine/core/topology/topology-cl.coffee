# (C) Uri Wilensky. https://github.com/NetLogo/Tortoise
goog.provide('engine.core.topology.topology')

goog.require('shim.lodash')
goog.require('shim.strictmath')
goog.require('util.abstractmethoderror')

class Topology

  _wrapInX: undefined # Boolean
  _wrapInY: undefined # Boolean

  height: undefined # Number
  width:  undefined # Number

  # (Number, Number, Number, Number, () => PatchSet, (Number, Number) => Patch) => Topology
  constructor: (@minPxcor, @maxPxcor, @minPycor, @maxPycor, @_getPatches, @_getPatchAt) ->
    @height = 1 + @maxPycor - @minPycor
    @width  = 1 + @maxPxcor - @minPxcor

  # (Number, Number) => Array[Patch]
  getNeighbors: (pxcor, pycor) ->
    _(@_getNeighbors(pxcor, pycor)).filter((patch) -> patch isnt false).value() #@# This function shouldn't exist; why give patches that are `false`?

  # (Number, Number) => Array[Patch]
  getNeighbors4: (pxcor, pycor) ->
    _(@_getNeighbors4(pxcor, pycor)).filter((patch) -> patch isnt false).value()

  # (Number, Number, Number, Number) => Number
  distanceXY: (x1, y1, x2, y2) ->
    a2 = StrictMath.pow(@_shortestX(x1, x2), 2)
    b2 = StrictMath.pow(@_shortestY(y1, y2), 2)
    StrictMath.sqrt(a2 + b2)

  # (Number, Number, Turtle|Patch) => Number
  distance: (x1, y1, agent) ->
    [x2, y2] = agent.getCoords()
    @distanceXY(x1, y1, x2, y2)

  # (Number, Number, Number, Number) => Number
  towards: (x1, y1, x2, y2) ->
    dx = @_shortestX(x1, x2)
    dy = @_shortestY(y1, y2)
    if dx is 0
      if dy >= 0 then 0 else 180
    else if dy is 0
      if dx >= 0 then 90 else 270
    else
      (270 + StrictMath.toDegrees(Math.PI + StrictMath.atan2(-dy, dx))) % 360

  # (Number, Number) => Number
  midpointx: (x1, x2) ->
    pos = (x1 + (x1 + @_shortestX(x1, x2))) / 2
    @_wrap(pos, @minPxcor - 0.5, @maxPxcor + 0.5)

  midpointy: (y1, y2) ->
    pos = (y1 + (y1 + @_shortestY(y1, y2))) / 2
    @_wrap(pos, @minPycor - 0.5, @maxPycor + 0.5)

  # (Number, Number, AbstractAgents[Agent], Number)
  inRadius: (x, y, agents, radius) ->
    agents.filter(
      (agent) =>
        [xcor, ycor] = agent.getCoords()
        @distanceXY(xcor, ycor, x, y) <= radius
    )

  # (Number, Number) => Array[Patch]
  _getNeighbors: (pxcor, pycor) ->
    if pxcor is @maxPxcor and pxcor is @minPxcor
      if pycor is @maxPycor and pycor is @minPycor
        []
      else
        [@_getPatchNorth(pxcor, pycor), @_getPatchSouth(pxcor, pycor)]
    else if pycor is @maxPycor and pycor is @minPycor
      [@_getPatchEast(pxcor, pycor), @_getPatchWest(pxcor, pycor)]
    else
      [@_getPatchNorth(pxcor, pycor),     @_getPatchEast(pxcor, pycor),
       @_getPatchSouth(pxcor, pycor),     @_getPatchWest(pxcor, pycor),
       @_getPatchNorthEast(pxcor, pycor), @_getPatchSouthEast(pxcor, pycor),
       @_getPatchSouthWest(pxcor, pycor), @_getPatchNorthWest(pxcor, pycor)]

  # (Number, Number) => Array[Patch]
  _getNeighbors4: (pxcor, pycor) ->
    if pxcor is @maxPxcor and pxcor is @minPxcor
      if pycor is @maxPycor and pycor is @minPycor
        []
      else
        [@_getPatchNorth(pxcor, pycor), @_getPatchSouth(pxcor, pycor)]
    else if pycor is @maxPycor and pycor is @minPycor
      [@_getPatchEast(pxcor, pycor), @_getPatchWest(pxcor, pycor)]
    else
      [@_getPatchNorth(pxcor, pycor), @_getPatchEast(pxcor, pycor),
       @_getPatchSouth(pxcor, pycor), @_getPatchWest(pxcor, pycor)]

  # (Number, Number, Number) => Number
  _wrap: (pos, min, max) ->
    if pos >= max
      min + ((pos - max) % (max - min))
    else if pos < min
      result = max - ((min - pos) % (max - min))
      if result < max
        result
      else
        min
    else
      pos

  # (Number, Number) => Number
  _shortestX: (x1, x2) -> abstractMethod('Topology._shortestX')
  _shortestY: (y1, y2) -> abstractMethod('Topology._shortestY')

  # (Number, Number) => Patch|Boolean
  _getPatchNorth:     (x, y) -> abstractMethod('Topology._getPatchNorth')
  _getPatchEast:      (x, y) -> abstractMethod('Topology._getPatchEast')
  _getPatchSouth:     (x, y) -> abstractMethod('Topology._getPatchSouth')
  _getPatchWest:      (x, y) -> abstractMethod('Topology._getPatchWest')
  _getPatchNorthEast: (x, y) -> abstractMethod('Topology._getPatchNorthEast')
  _getPatchSouthEast: (x, y) -> abstractMethod('Topology._getPatchSouthEast')
  _getPatchSouthWest: (x, y) -> abstractMethod('Topology._getPatchSouthWest')
  _getPatchNorthWest: (x, y) -> abstractMethod('Topology._getPatchNorthWest')
