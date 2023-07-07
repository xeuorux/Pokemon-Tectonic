def everybodyPanics(waitingFrames = 20)
    for id in -1..100 do
        event = get_event(id)
        next if event.nil?
        new_move_route = getNewMoveRoute()
        new_move_route.repeat = true
        new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[rand(3)]))
        new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::TurnRandom))
        new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait,[waitingFrames-rand(3)]))
        new_move_route.list.push(RPG::MoveCommand.new(0))
        event.force_move_route(new_move_route)
    end
end

def panicEnds
    for id in -1..100 do
        event = get_event(id)
        next if event.nil?
        event.reset_move_route
    end
end