class Game_Character
    attr_accessor :floats

    def move_toward_player
        myXPos = @x + (@width - 1) / 2.0
        playerXPos = ($game_player.x + ($game_player.width - 1) / 2.0)
        xDifference = myXPos - playerXPos
        myYPos = @y - (@height - 1) / 2.0
        playerYPos = ($game_player.y - ($game_player.height - 1) / 2.0)
        yDifference = myYPos - playerYPos
        abs_xDif = xDifference.abs
        abs_yDif = yDifference.abs
        return if abs_xDif < @width && abs_yDif < @height
        if abs_xDif == abs_yDif
            (rand(2) == 0) ? abs_xDif += 1 : abs_yDif += 1
        end
        if abs_xDif > abs_yDif
            (xDifference > 0) ? move_left : move_right
            if !moving? && yDifference != 0
                (yDifference > 0) ? move_up : move_down
            end
        else
            (yDifference > 0) ? move_up : move_down
            if !moving? && xDifference != 0
                (xDifference > 0) ? move_left : move_right
            end
        end
    end

    def move_away_from_player
        myXPos = @x + (@width - 1) / 2.0
        playerXPos = ($game_player.x + ($game_player.width - 1) / 2.0)
        xDifference = myXPos - playerXPos
        myYPos = @y - (@height - 1) / 2.0
        playerYPos = ($game_player.y - ($game_player.height - 1) / 2.0)
        yDifference = myYPos - playerYPos
        abs_xDif = xDifference.abs
        abs_yDif = yDifference.abs
        return if abs_xDif < @width && abs_yDif < @height
        abs_xDif = xDifference.abs
        abs_yDif = yDifference.abs
        if abs_xDif == abs_yDif
            (rand(2) == 0) ? abs_xDif += 1 : abs_yDif += 1
        end
        if abs_xDif > abs_yDif
            (xDifference > 0) ? move_right : move_left
            if !moving? && yDifference != 0
                (yDifference > 0) ? move_down : move_up
            end
        else
            (yDifference > 0) ? move_down : move_up
            if !moving? && xDifference != 0
                (xDifference > 0) ? move_right : move_left
            end
        end
    end

    def bush_depth
        return 0 if floats
        return @bush_depth || 0
    end

    def screen_y
        ret = screen_y_ground
        if jumping?
            if @jump_count > 0
                jump_fraction = ((@jump_count * jump_speed_real / Game_Map::REAL_RES_X) - 0.5).abs # 0.5 to 0 to 0.5
            elsif @jump_distance > 0
                jump_fraction = ((@jump_distance_left / @jump_distance) - 0.5).abs # 0.5 to 0 to 0.5
            else
                jump_fraction = 0.5
            end
            ret += @jump_peak * (4 * jump_fraction**2 - 1)
        end
        return ret
    end

    def passable?(x, y, d, strict = false)
        new_x = x + (if d == 6
                         1
                     else
                         d == 4 ? -1 : 0
                     end)
        new_y = y + (if d == 2
                         1
                     else
                         d == 8 ? -1 : 0
                     end)
        return false unless map.valid?(new_x, new_y)
        return true if @through
        if strict
            return false unless map.passableStrict?(x, y, d, self)
            return false unless map.passableStrict?(new_x, new_y, 10 - d, self)
        else
            return false unless map.passable?(x, y, d, self)
            return false unless map.passable?(new_x, new_y, 10 - d, self)
        end
        for event in map.events.values
            next if self == event
            next unless event.at_coordinate?(new_x, new_y)
            next if event.through
            next if event.character_name == "" # && self == $game_player
            return false
        end
        if $game_player.x == new_x && $game_player.y == new_y && !($game_player.through || @character_name == "")
            return false
        end
        return true
    end

    def silent_offset(offsetX, offsetY)
        @x += offsetX
        @y += offsetY
        @real_x += offsetX * Game_Map::REAL_RES_X
        @real_y += offsetY * Game_Map::REAL_RES_Y
        triggerLeaveTile
    end
end
