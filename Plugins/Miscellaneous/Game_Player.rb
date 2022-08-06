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
end