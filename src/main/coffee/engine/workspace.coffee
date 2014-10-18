# (C) Uri Wilensky. https://github.com/NetLogo/Tortoise

Dump          = require('./dump')
Hasher        = require('./hasher')
Updater       = require('./updater')
BreedManager  = require('./core/breedmanager')
World         = require('./core/world')
SelfManager   = require('./core/structure/selfmanager')
LayoutManager = require('./prim/layoutmanager')
LinkPrims     = require('./prim/linkprims')
ListPrims     = require('./prim/listprims')
Prims         = require('./prim/prims')
SelfPrims     = require('./prim/selfprims')
RNG           = require('tortoise/util/rng')
Timer         = require('tortoise/util/timer')

class MiniWorkspace
  # (SelfManager, Updater, BreedManager, RNG) => MiniWorkspace
  constructor: (@selfManager, @updater, @breedManager, @rng) ->

module.exports =
  (breedObjs) -> () -> # World args; see constructor for `World` --JAB (4/17/14)

    worldArgs = arguments # If you want `Workspace` to take more parameters--parameters not related to `World`--just keep returning new functions

    rng = new RNG

    selfManager  = new SelfManager
    breedManager = new BreedManager(breedObjs)
    prims        = new Prims(Dump, Hasher, rng)
    selfPrims    = new SelfPrims(selfManager.self)
    timer        = new Timer
    updater      = new Updater

    world         = new World(new MiniWorkspace(selfManager, updater, breedManager, rng), worldArgs...)
    layoutManager = new LayoutManager(world, rng.nextDouble)
    linkPrims     = new LinkPrims(world)
    listPrims     = new ListPrims(Hasher, prims.equality.bind(prims), rng.nextInt)

    {
      selfManager
      breedManager
      layoutManager
      linkPrims
      listPrims
      prims
      rng
      selfPrims
      timer
      updater
      world
    }
