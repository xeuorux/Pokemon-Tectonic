
def pushbackPlayer
    pbSEPlay("GUI sel buzzer", 50, 150)
    pbSEPlay("Anim/PRSFX- Paralysis", 120, 120)

    new_move_route = getNewMoveRoute()
    new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::DirectionFixOn))
    new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::Backward))
    new_move_route.list.push(RPG::MoveCommand.new(PBMoveRoute::DirectionFixOff))
    new_move_route.list.push(RPG::MoveCommand.new(0)) # End of move route
    get_player.force_move_route(new_move_route)
end