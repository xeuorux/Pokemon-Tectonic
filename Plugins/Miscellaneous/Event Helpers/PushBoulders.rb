class Interpreter
    # Used in boulder events. Allows an event to be pushed.
    def pbPushThisEvent
        event = get_self
        old_x  = event.x
        old_y  = event.y
        # Apply strict version of passable, which treats tiles that are passable
        # only from certain directions as fully impassible
        unless event.can_move_in_direction?($game_player.direction, true)
            $game_player.bump_into_object
            return
        end
        case $game_player.direction
        when 2 then event.move_down
        when 4 then event.move_left
        when 6 then event.move_right
        when 8 then event.move_up
        end
        $PokemonMap.addMovedEvent(@event_id) if $PokemonMap
        if old_x != event.x || old_y != event.y
        $game_player.lock
        loop do
            Graphics.update
            Input.update
            pbUpdateSceneMap
            break if !event.moving?
        end
        $game_player.unlock
        end
    end
end