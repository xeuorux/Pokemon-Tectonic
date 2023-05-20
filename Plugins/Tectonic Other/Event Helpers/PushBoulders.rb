class Game_Character
    attr_accessor :always_on_top

    def inverted_dir
        case @direction
        when 2 then return 8
        when 4 then return 6
        when 6 then return 4
        when 8 then return 2
        end
    end

    def pbPullTowardsPlayer
        if !$game_player.can_move_in_direction?($game_player.inverted_dir)
            $game_player.bump_into_object
            return
        end

        old_x  = @x
        old_y  = @y

        pbSEPlay("Anim/Earth3",30,rand(70,90))

        Input.update

        $game_player.move_backward

        case $game_player.inverted_dir
        when 2 then move_down
        when 4 then move_left
        when 6 then move_right
        when 8 then move_up
        end

        $PokemonMap.addMovedEvent(@id) if $PokemonMap

        if old_x != @x || old_y != @y
            $game_player.lock
            loop do
                Graphics.update
                Input.update
                pbUpdateSceneMap
                break unless moving?
            end
            $game_player.unlock
        end
    end
end