class Game_Character
    def screen_y
        ret = screen_y_ground
        if jumping?
          if @jump_count > 0
            jump_fraction = ((@jump_count * jump_speed_real / Game_Map::REAL_RES_X) - 0.5).abs   # 0.5 to 0 to 0.5
          elsif @jump_distance > 0
            jump_fraction = ((@jump_distance_left / @jump_distance) - 0.5).abs   # 0.5 to 0 to 0.5
          else
            jump_fraction = 0.5
          end
          ret += @jump_peak * (4 * jump_fraction**2 - 1)
        end
        return ret
    end

    def passable?(x, y, d, strict = false)
      new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
      new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
      return false unless self.map.valid?(new_x, new_y)
      return true if @through
      if strict
        return false unless self.map.passableStrict?(x, y, d, self)
        return false unless self.map.passableStrict?(new_x, new_y, 10 - d, self)
      else
        return false unless self.map.passable?(x, y, d, self)
        return false unless self.map.passable?(new_x, new_y, 10 - d, self)
      end
      for event in self.map.events.values
        next if self == event
        next unless event.at_coordinate?(new_x, new_y)
        next if event.through
        next if event.character_name == "" #&& self == $game_player
        return false
      end
      if $game_player.x == new_x && $game_player.y == new_y
        return false unless ($game_player.through || @character_name == "")
      end
      return true
    end
end