class Game_Player < Game_Character
    def update
        last_real_x = @real_x
        last_real_y = @real_y
        super
        update_stop if $game_temp.in_menu && @stopped_last_frame
        update_screen_position(last_real_x, last_real_y)
        # Update dependent events
        $PokemonTemp.dependentEvents.updateDependentEvents
        # Count down the time between allowed bump sounds
        @bump_se -= 1 if @bump_se && @bump_se>0
        # Finish up dismounting from surfing
        if $PokemonTemp.endSurf && !moving?
            pbCancelVehicles
            $PokemonTemp.surfJump = nil
            $PokemonTemp.endSurf  = false
        end
        update_event_triggering
    end

    def move_generic(dir, turn_enabled = true)
        turn_generic(dir, true) if turn_enabled
        if !$PokemonTemp.encounterTriggered
          if can_move_in_direction?(dir)
            perform_move_generic(dir)
          else 
            case check_event_trigger_touch(dir)
            when 0
                bump_into_object
            when 1
                # Do nothing!
            when 2
                perform_move_generic(dir)
                refresh
            end
          end
        end
        $PokemonTemp.encounterTriggered = false
    end

    def perform_move_generic(dir)
        x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
        y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
        return if pbLedge(x_offset, y_offset)
        return if pbEndSurf(x_offset, y_offset)
        turn_generic(dir, true)
        if !$PokemonTemp.encounterTriggered
            @x += x_offset
            @y += y_offset
            $PokemonTemp.dependentEvents.pbMoveDependentEvents
            increase_steps
        end
    end

    #-----------------------------------------------------------------------------
    # * Trigger event(s) at the same coordinates as self with the appropriate
    #   trigger(s) that can be triggered
    #-----------------------------------------------------------------------------
    def check_event_trigger_here(triggers)
        result = false
        # If event is running
        return result if $game_system.map_interpreter.running?
        # All event loops
        for event in $game_map.events.values
            # If event coordinates and triggers are consistent
            next if !event.at_coordinate?(@x, @y)
            next if !triggers.include?(event.trigger)
            next if event.name[/turnstile/]
            # If starting determinant is same position event (other than jumping)
            next if event.jumping? || !event.over_trigger?
            event.start
            result = true
        end
        return result
    end
    
    #-----------------------------------------------------------------------------
    # * Touch Event Starting Determinant
    # Returning 0 means block the player and play the bump noise
    # Returning 1 means block the player and do nothing
    # Returning 2 means allow the player to move into the event
    #-----------------------------------------------------------------------------
    def check_event_trigger_touch(dir)
        result = 0
        return result if $game_system.map_interpreter.running?
        # All event loops
        x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
        y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
        for event in $game_map.events.values
            next if ![1, 2].include?(event.trigger)   # Player touch, event touch
            # If event coordinates and triggers are consistent
            next if !event.at_coordinate?(@x + x_offset, @y + y_offset)
            if event.name[/trainer\((\d+)\)/i]
                distance = $~[1].to_i
                next if !pbEventCanReachPlayer?(event,self,distance)
            elsif event.name[/counter\((\d+)\)/i]
                distance = $~[1].to_i
                next if !pbEventFacesPlayer?(event,self,distance)
            elsif match = event.name.match(/turnstile\(([01]{4})\)/i)
                # If the player could move onto that tile if not for the event in the way
                # Allow the event to move out of the way
                if self.map.playerPassable?(@x + x_offset, @y + y_offset, dir)
                    collisionFlagString = match.captures[0]
                    collisionFlags = collisionFlagString.to_i(2)
                    if turnStileLogic(event,collisionFlags)
                        event.start
                        result = 2
                        next
                    end
                end
            end
            # If starting determinant is front event (other than jumping)
            next if event.jumping? || event.over_trigger?
            event.start
            result = 1
        end
        return result
    end
end