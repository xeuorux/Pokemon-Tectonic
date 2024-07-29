
#===============================================================================
# Event movement
#===============================================================================
module PBMoveRoute
    Down               = 1
    Left               = 2
    Right              = 3
    Up                 = 4
    LowerLeft          = 5
    LowerRight         = 6
    UpperLeft          = 7
    UpperRight         = 8
    Random             = 9
    TowardPlayer       = 10
    AwayFromPlayer     = 11
    Forward            = 12
    Backward           = 13
    Jump               = 14 # xoffset, yoffset
    Wait               = 15 # frames
    TurnDown           = 16
    TurnLeft           = 17
    TurnRight          = 18
    TurnUp             = 19
    TurnRight90        = 20
    TurnLeft90         = 21
    Turn180            = 22
    TurnRightOrLeft90  = 23
    TurnRandom         = 24
    TurnTowardPlayer   = 25
    TurnAwayFromPlayer = 26
    SwitchOn           = 27 # 1 param
    SwitchOff          = 28 # 1 param
    ChangeSpeed        = 29 # 1 param
    ChangeFreq         = 30 # 1 param
    WalkAnimeOn        = 31
    WalkAnimeOff       = 32
    StepAnimeOn        = 33
    StepAnimeOff       = 34
    DirectionFixOn     = 35
    DirectionFixOff    = 36
    ThroughOn          = 37
    ThroughOff         = 38
    AlwaysOnTopOn      = 39
    AlwaysOnTopOff     = 40
    Graphic            = 41 # Name, hue, direction, pattern
    Opacity            = 42 # 1 param
    Blending           = 43 # 1 param
    PlaySE             = 44 # 1 param
    Script             = 45 # 1 param
    ScriptAsync        = 101 # 1 param
  end
  
  
  
  def pbMoveRoute(event, commands, waitComplete = true)
    route = RPG::MoveRoute.new
    route.repeat    = false
    route.skippable = true
    route.list.clear
    route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOn))
    i=0
    while i<commands.length
      case commands[i]
      when PBMoveRoute::Wait, PBMoveRoute::SwitchOn, PBMoveRoute::SwitchOff,
         PBMoveRoute::ChangeSpeed, PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
         PBMoveRoute::Blending, PBMoveRoute::PlaySE, PBMoveRoute::Script
        route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1]]))
        i += 1
      when PBMoveRoute::ScriptAsync
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script,[commands[i+1]]))
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[0]))
        i += 1
      when PBMoveRoute::Jump
        route.list.push(RPG::MoveCommand.new(commands[i],[commands[i+1],commands[i+2]]))
        i += 2
      when PBMoveRoute::Graphic
        route.list.push(RPG::MoveCommand.new(commands[i],
           [commands[i+1],commands[i+2],commands[i+3],commands[i+4]]))
        i += 4
      else
        route.list.push(RPG::MoveCommand.new(commands[i]))
      end
      i += 1
    end
    route.list.push(RPG::MoveCommand.new(PBMoveRoute::ThroughOff))
    route.list.push(RPG::MoveCommand.new(0))
    if event
      event.force_move_route(route)
    end
    pbMapInterpreter.command_210 if waitComplete
    return route
  end