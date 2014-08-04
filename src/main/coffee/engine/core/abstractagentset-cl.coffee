# (C) Uri Wilensky. https://github.com/NetLogo/Tortoise

# Never instantiate this class directly --JAB (5/7/14)
goog.provide('engine.core.abstractagentset')

goog.require('engine.core.nobody')
goog.require('shim.random')
goog.require('util.abstractmethoderror')
goog.require('util.exception')
goog.require('util.iterator')
goog.require('util.seq')
goog.require('util.shufflerator')

class AbstractAgentSet extends Seq

  @_selfManager: undefined # SelfManager

  # [T <: Agent] @ (Array[T]) => AbstractAgentSet[T]
  constructor: (agents) ->
    super(agents)
    @_selfManager =
      if agents[0]?
        agents[0].world.selfManager
      else
        {
          askAgent: () -> () -> undefined
          self: -> { id: undefined }
        }

  # (() => Boolean) => AbstractAgentSet[T]
  agentFilter: (f) ->
    @filter(@_selfManager.askAgent(f))

  # (() => Boolean) => Boolean
  agentAll: (f) ->
    @every(@_selfManager.askAgent(f))

  # (() => Any, Boolean) => Unit
  ask: (f, shouldShuffle) ->

    iter =
      if shouldShuffle
        @shufflerator()
      else
        @iterator()

    iter.forEach(@_selfManager.askAgent(f))

    if @_selfManager.self().id is -1
      throw new Exception.DeathInterrupt

    return

  # [Result] @ (() => Result) => Array[Result]
  projectionBy: (f) ->
    @shufflerator().map(@_selfManager.askAgent(f))

  # () => Iterator
  iterator: ->
    abstractMethod('AbstractAgentSet.iterator')

  # (() => Double) => Agent
  maxOneOf: (f) ->
    @_findBestOf(-Number.MAX_VALUE, ((result, currentBest) -> result > currentBest), f)

  # (() => Double) => Agent
  minOneOf: (f) ->
    @_findBestOf(Number.MAX_VALUE, ((result, currentBest) -> result < currentBest), f)

  # () => AbstractAgentSet[T]
  shuffled: ->
    @copyWithNewAgents(@shufflerator().toArray())

  # () => Shufflerator[T]
  shufflerator: ->
    new Shufflerator(@toArray())

  # () => Array[T]
  sort: ->
    if @isEmpty()
      @toArray()
    else
      @toArray().sort((x, y) -> x.compare(y).toInt)

  # () => Array[T]
  toArray: ->
    @_items = @iterator().toArray() # Prune out dead agents --JAB (7/21/14)
    @_items[..]

  # (Array[T]) => AbstractAgentSet[T]
  copyWithNewAgents: (agents) ->
    @_generateFrom(agents, this)

  # [U] @ (U, (U, U) => Boolean, () => U) => Agent
  _findBestOf: (worstPossible, findIsBetter, f) ->
    winningValue = worstPossible #@# God awful.  Use `reduce` or _something_!
    winners = []
    for agent in @toArray()
      result = @_selfManager.askAgent(f)(agent)
      if result is winningValue
        winners.push(agent)
      else if findIsBetter(result, winningValue)
        winningValue = result
        winners = []
        winners.push(agent)

    if winners.length is 0
      Nobody
    else
      winners[Random.nextInt(winners.length)]
