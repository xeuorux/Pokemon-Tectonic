class Interpreter
    # Used in boulder events. Allows an event to be pushed.
    def pbPushThisEvent(checkForHoles = false)
        event = get_self
        old_x  = event.x
        old_y  = event.y
        holeEvent = nil
        # check for pluggable holes in that direction
        if checkForHoles
            new_x = old_x + xOffsetFromDir($game_player.direction)
            new_y = old_y + yOffsetFromDir($game_player.direction)

            $game_map.events.values.each do |otherEvent|
                next if event == otherEvent
                next unless otherEvent.at_coordinate?(new_x, new_y)
                next unless otherEvent.name[/boulderhole/]
                next if pbGetSelfSwitch(otherEvent.id,'A')
                
                holeEvent = otherEvent
                holeEvent.through = true
                event.always_on_top = true
                break
            end
        end
        # Apply strict version of passable, which treats tiles that are passable
        # only from certain directions as fully impassible
        unless !holeEvent || event.can_move_in_direction?($game_player.direction, true)
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

        if holeEvent
            pbSEPlay("Anim/Earth3",70,100)
            pbWait(10)
            pbSetSelfSwitch(event.id,'A')
            pbSetSelfSwitch(holeEvent.id,'A')
        end
    end
end

class Game_Character
    attr_accessor :always_on_top
end