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
end