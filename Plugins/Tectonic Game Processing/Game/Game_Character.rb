class Game_Character
    attr_reader   :id
    attr_reader   :original_x
    attr_reader   :original_y
    attr_reader   :original_direction
    attr_reader   :x
    attr_reader   :y
    attr_reader   :real_x
    attr_reader   :real_y
    attr_accessor :width
    attr_accessor :height
    attr_accessor :sprite_size
    attr_reader   :tile_id
    attr_accessor :character_name
    attr_accessor :character_hue
    attr_reader   :opacity
    attr_reader   :blend_type
    attr_accessor :direction
    attr_accessor :pattern
    attr_accessor :pattern_surf
    attr_accessor :lock_pattern
    attr_reader   :move_route_forcing
    attr_accessor :through
    attr_accessor :animation_id
    attr_accessor :transparent
    attr_reader   :move_speed
    attr_accessor :walk_anime
    attr_writer   :bob_height
    attr_accessor :floats
    attr_accessor :always_on_top
    attr_accessor :dependent_event

    def initialize(map = nil)
        @map                       = map
        @id                        = 0
        @original_x                = 0
        @original_y                = 0
        @x                         = 0
        @y                         = 0
        @real_x                    = 0
        @real_y                    = 0
        @width                     = 1
        @height                    = 1
        @sprite_size               = [Game_Map::TILE_WIDTH, Game_Map::TILE_HEIGHT]
        @tile_id                   = 0
        @character_name            = ""
        @character_hue             = 0
        @opacity                   = 255
        @blend_type                = 0
        @direction                 = 2
        @pattern                   = 0
        @pattern_surf              = 0
        @lock_pattern              = false
        @move_route_forcing        = false
        @through                   = false
        @animation_id              = 0
        @transparent               = false
        @original_direction        = 2
        @original_pattern          = 0
        @move_type                 = 0
        self.move_speed            = 3
        self.move_frequency        = 6
        @move_route                = nil
        @move_route_index          = 0
        @original_move_route       = nil
        @original_move_route_index = 0
        @walk_anime                = true    # Whether character should animate while moving
        @step_anime                = false   # Whether character should animate while still
        @direction_fix             = false
        @always_on_top             = false
        @anime_count               = 0
        @stop_count                = 0
        @jump_peak                 = 0   # Max height while jumping
        @jump_distance             = 0   # Total distance of jump
        @jump_distance_left        = 0   # Distance left to travel
        @jump_count                = 0   # Frames left in a stationary jump
        @bob_height                = 0
        @wait_count                = 0
        @moved_this_frame          = false
        @locked                    = false
        @prelock_direction         = 0
        @dependent_event           = false
    end

    def at_coordinate?(check_x, check_y)
        return check_x >= @x && check_x < @x + @width &&
               check_y > @y - @height && check_y <= @y
    end

    def in_line_with_coordinate?(check_x, check_y)
        return (check_x >= @x && check_x < @x + @width) ||
               (check_y > @y - @height && check_y <= @y)
    end

    def each_occupied_tile
        for i in @x...(@x + @width)
            for j in (@y - @height + 1)..@y
                yield i, j
            end
        end
    end

    # From 1 to 5
    def get_speed_from_speed_index(index)
        realSpeed = [3.2, 6.4, 12.8, 25.6, 44, 64][index - 1]
        return realSpeed
    end

    def move_speed=(val)
        return if val == @move_speed
        @move_speed = val
        # @move_speed_real is the number of quarter-pixels to move each frame. There
        # are 128 quarter-pixels per tile.
        realMoveSpeed = get_speed_from_speed_index(val)
        realMoveSpeed *= 1.5 if cellBoosterActive? && @dependent_event
        self.move_speed_real = realMoveSpeed
    end

    def move_speed_real
        self.move_speed = @move_speed unless @move_speed_real
        return @move_speed_real
    end

    def move_speed_real=(val)
        @move_speed_real = val * 40.0 / Graphics.frame_rate
    end

    def jump_speed_real
        self.jump_speed_real = (2**(3 + 1)) * 0.8 unless @jump_speed_real # 3 is walking speed
        return @jump_speed_real
    end

    def jump_speed_real=(val)
        @jump_speed_real = val * 40.0 / Graphics.frame_rate
    end

    def move_frequency=(val)
        return if val == @move_frequency
        @move_frequency = val
        # @move_frequency_real is the number of frames to wait between each action
        # in a move route (not forced). Specifically, this is the number of frames
        # to wait after the character stops moving because of the previous action.
        # By default, it is calculated from @move_frequency and has these values
        # (assuming 40 fps):
        # 1 => 190   # 4.75 seconds
        # 2 => 144   # 3.6 seconds
        # 3 => 102   # 2.55 seconds
        # 4 => 64    # 1.6 seconds
        # 5 => 30    # 0.75 seconds
        # 6 => 0     # 0 seconds, i.e. continuous movement
        self.move_frequency_real = (40 - val * 2) * (6 - val)
    end

    def move_frequency_real
        self.move_frequency = @move_frequency unless @move_frequency_real
        return @move_frequency_real
    end

    def move_frequency_real=(val)
        @move_frequency_real = val * Graphics.frame_rate / 40.0
    end

    def bob_height
        @bob_height ||= 0
        return @bob_height
    end

    def lock
        return if @locked
        @prelock_direction = 0 # Was @direction but disabled
        turn_toward_player
        @locked = true
    end

    def minilock
        @prelock_direction = 0 # Was @direction but disabled
        @locked = true
    end

    def lock?
        return @locked
    end

    def unlock
        return unless @locked
        @locked = false
        @direction = @prelock_direction if !@direction_fix && @prelock_direction != 0
    end

    #=============================================================================
    # Information from map data
    #=============================================================================
    def map
        return @map || $game_map
    end

    def terrain_tag
        return map.terrain_tag(@x, @y)
    end

    def bush_depth
        return 0 if floats
        return @bush_depth || 0
    end

    def calculate_bush_depth
        if @tile_id > 0 || @always_on_top || jumping?
            @bush_depth = 0
        else
            deep_bush = regular_bush = false
            xbehind = @x + (if @direction == 4
                                1
                            else
                                @direction == 6 ? -1 : 0
                            end)
            ybehind = @y + (if @direction == 8
                                1
                            else
                                @direction == 2 ? -1 : 0
                            end)
            this_map = map.valid?(@x, @y) ? [map, @x, @y] : $MapFactory.getNewMap(@x, @y)
            if this_map[0].deepBush?(this_map[1], this_map[2]) && map.deepBush?(xbehind, ybehind)
                @bush_depth = Game_Map::TILE_HEIGHT
            elsif !moving? && this_map[0].bush?(this_map[1], this_map[2])
                @bush_depth = 12
            else
                @bush_depth = 0
            end
        end
    end

    #=============================================================================
    # Passability
    #=============================================================================
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

    def can_move_from_coordinate?(start_x, start_y, dir, strict = false)
        case dir
        when 2, 8   # Down, up
            y_diff = (dir == 8) ? @height - 1 : 0
            for i in start_x...(start_x + @width)
                return false unless passable?(i, start_y - y_diff, dir, strict)
            end
            return true
        when 4, 6   # Left, right
            x_diff = (dir == 6) ? @width - 1 : 0
            for i in (start_y - @height + 1)..start_y
                return false unless passable?(start_x + x_diff, i, dir, strict)
            end
            return true
        when 1, 3   # Down diagonals
            # Treated as moving down first and then horizontally, because that
            # describes which tiles the character's feet touch
            for i in start_x...(start_x + @width)
                return false unless passable?(i, start_y, 2, strict)
            end
            x_diff = (dir == 3) ? @width - 1 : 0
            for i in (start_y - @height + 1)..start_y
                return false unless passable?(start_x + x_diff, i + 1, dir + 3, strict)
            end
            return true
        when 7, 9 # Up diagonals
            # Treated as moving horizontally first and then up, because that describes
            # which tiles the character's feet touch
            x_diff = (dir == 9) ? @width - 1 : 0
            for i in (start_y - @height + 1)..start_y
                return false unless passable?(start_x + x_diff, i, dir - 3, strict)
            end
            x_offset = (dir == 9) ? 1 : -1
            for i in start_x...(start_x + @width)
                return false unless passable?(i + x_offset, start_y - @height + 1, 8, strict)
            end
            return true
        end
        return false
    end

    def can_move_in_direction?(dir, strict = false)
        return can_move_from_coordinate?(@x, @y, dir, strict)
    end

    #=============================================================================
    # Screen position of the character
    #=============================================================================
    def screen_x
        ret = ((@real_x - map.display_x) / Game_Map::X_SUBPIXELS).round
        ret += @width * Game_Map::TILE_WIDTH / 2
        return ret
    end

    def screen_y_ground
        ret = ((@real_y - map.display_y) / Game_Map::Y_SUBPIXELS).round
        ret += Game_Map::TILE_HEIGHT
        return ret
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

    def screen_z(height = 0)
        return 999 if @always_on_top
        z = screen_y_ground
        if @tile_id > 0
            begin
                return z + map.priorities[@tile_id] * 32
            rescue StandardError
                raise "Event's graphic is an out-of-range tile (event #{@id}, map #{map.map_id})"
            end
        end
        # Add z if height exceeds 32
        return z + ((height > Game_Map::TILE_HEIGHT) ? Game_Map::TILE_HEIGHT - 1 : 0)
    end

    #=============================================================================
    # Movement
    #=============================================================================
    def moving?
        return @real_x != @x * Game_Map::REAL_RES_X ||
               @real_y != @y * Game_Map::REAL_RES_Y
    end

    def jumping?
        return (@jump_distance_left || 0) > 0 || @jump_count > 0
    end

    def straighten
        @pattern = 0 if @walk_anime || @step_anime
        @anime_count = 0
        @prelock_direction = 0
    end

    def force_move_route(move_route)
        if @original_move_route.nil?
            @original_move_route       = @move_route
            @original_move_route_index = @move_route_index
        end
        @move_route         = move_route
        @move_route_index   = 0
        @move_route_forcing = true
        @prelock_direction  = 0
        @wait_count         = 0
        move_type_custom
    end

    def moveto(x, y)
        @x = x % map.width
        @y = y % map.height
        @real_x = @x * Game_Map::REAL_RES_X
        @real_y = @y * Game_Map::REAL_RES_Y
        @prelock_direction = 0
        triggerLeaveTile
    end

    def triggerLeaveTile
        if @oldX && @oldY && @oldMap &&
           (@oldX != x || @oldY != y || @oldMap != map.map_id)
            Events.onLeaveTile.trigger(self, self, @oldMap, @oldX, @oldY)
        end
        @oldX = x
        @oldY = y
        @oldMap = map.map_id
    end

    def increase_steps
        @stop_count = 0
        triggerLeaveTile
    end

    #=============================================================================
    # Movement commands
    #=============================================================================
    def move_type_random
        case rand(6)
        when 0..3 then move_random
        when 4    then move_forward
        when 5    then @stop_count = 0
        end
    end

    def move_type_toward_player
        sx = @x + @width / 2.0 - ($game_player.x + $game_player.width / 2.0)
        sy = @y - @height / 2.0 - ($game_player.y - $game_player.height / 2.0)
        if sx.abs + sy.abs >= 20
            move_random
            return
        end
        case rand(6)
        when 0..3 then move_toward_player
        when 4    then move_random
        when 5    then move_forward
        end
    end

    def move_type_custom
        return if jumping? || moving?
        while @move_route_index < @move_route.list.size
            command = @move_route.list[@move_route_index]
            if command.code == 0
                if @move_route.repeat
                    @move_route_index = 0
                else
                    if @move_route_forcing
                        @move_route_forcing = false
                        @move_route       = @original_move_route
                        @move_route_index = @original_move_route_index
                        @original_move_route = nil
                    end
                    @stop_count = 0
                end
                return
            end
            if command.code <= 14
                case command.code
                when 1  then move_down
                when 2  then move_left
                when 3  then move_right
                when 4  then move_up
                when 5  then move_lower_left
                when 6  then move_lower_right
                when 7  then move_upper_left
                when 8  then move_upper_right
                when 9  then move_random
                when 10 then move_toward_player
                when 11 then move_away_from_player
                when 12 then move_forward
                when 13 then move_backward
                when 14 then jump(command.parameters[0], command.parameters[1])
                end
                @move_route_index += 1 if @move_route.skippable || moving? || jumping?
                return
            end
            if command.code == 15 # Wait
                @wait_count = (command.parameters[0] * Graphics.frame_rate / 20) - 1
                @move_route_index += 1
                return
            end
            if command.code >= 16 && command.code <= 26
                case command.code
                when 16 then turn_down
                when 17 then turn_left
                when 18 then turn_right
                when 19 then turn_up
                when 20 then turn_right_90
                when 21 then turn_left_90
                when 22 then turn_180
                when 23 then turn_right_or_left_90
                when 24 then turn_random
                when 25 then turn_toward_player
                when 26 then turn_away_from_player
                end
                @move_route_index += 1
                return
            end
            next unless command.code >= 27
            case command.code
            when 27
                $game_switches[command.parameters[0]] = true
                map.need_refresh = true
            when 28
                $game_switches[command.parameters[0]] = false
                map.need_refresh = true
            when 29 then self.move_speed = command.parameters[0]
            when 30 then self.move_frequency = command.parameters[0]
            when 31 then @walk_anime = true
            when 32 then @walk_anime = false
            when 33 then @step_anime = true
            when 34 then @step_anime = false
            when 35 then @direction_fix = true
            when 36 then @direction_fix = false
            when 37 then @through = true
            when 38 then @through = false
            when 39
                old_always_on_top = @always_on_top
                @always_on_top = true
                calculate_bush_depth if @always_on_top != old_always_on_top
            when 40
                old_always_on_top = @always_on_top
                @always_on_top = false
                calculate_bush_depth if @always_on_top != old_always_on_top
            when 41
                old_tile_id = @tile_id
                @tile_id = 0
                @character_name = command.parameters[0]
                @character_hue = command.parameters[1]
                if @original_direction != command.parameters[2]
                    @direction = command.parameters[2]
                    @original_direction = @direction
                    @prelock_direction = 0
                end
                if @original_pattern != command.parameters[3]
                    @pattern = command.parameters[3]
                    @original_pattern = @pattern
                end
                calculate_bush_depth if @tile_id != old_tile_id
            when 42 then @opacity = command.parameters[0]
            when 43 then @blend_type = command.parameters[0]
            when 44 then pbSEPlay(command.parameters[0])
            when 45 then eval(command.parameters[0])
            end
            @move_route_index += 1
        end
    end

    def move_generic(dir, turn_enabled = true)
        turn_generic(dir) if turn_enabled
        if can_move_in_direction?(dir)
            turn_generic(dir)
            @x += if dir == 4
                      -1
                  else
                      (dir == 6) ? 1 : 0
                  end
            @y += if dir == 8
                      -1
                  else
                      (dir == 2) ? 1 : 0
                  end
            increase_steps
        else
            check_event_trigger_touch(dir)
        end
    end

    def move_down(turn_enabled = true)
        move_generic(2, turn_enabled)
    end

    def move_left(turn_enabled = true)
        move_generic(4, turn_enabled)
    end

    def move_right(turn_enabled = true)
        move_generic(6, turn_enabled)
    end

    def move_up(turn_enabled = true)
        move_generic(8, turn_enabled)
    end

    def move_upper_left
        unless @direction_fix
            @direction = (if @direction == 6
                              4
                          else
                              @direction == 2 ? 8 : @direction
                          end)
        end
        if can_move_in_direction?(7)
            @x -= 1
            @y -= 1
            increase_steps
        end
    end

    def move_upper_right
        unless @direction_fix
            @direction = (if @direction == 4
                              6
                          else
                              @direction == 2 ? 8 : @direction
                          end)
        end
        if can_move_in_direction?(9)
            @x += 1
            @y -= 1
            increase_steps
        end
    end

    def move_lower_left
        unless @direction_fix
            @direction = (if @direction == 6
                              4
                          else
                              @direction == 8 ? 2 : @direction
                          end)
        end
        if can_move_in_direction?(1)
            @x -= 1
            @y += 1
            increase_steps
        end
    end

    def move_lower_right
        unless @direction_fix
            @direction = (if @direction == 4
                              6
                          else
                              @direction == 8 ? 2 : @direction
                          end)
        end
        if can_move_in_direction?(3)
            @x += 1
            @y += 1
            increase_steps
        end
    end

    def moveLeft90 # anticlockwise
        case direction
        when 2 then move_right   # down
        when 4 then move_down    # left
        when 6 then move_up      # right
        when 8 then move_left    # up
        end
    end

    def moveRight90 # clockwise
        case direction
        when 2 then move_left    # down
        when 4 then move_up      # left
        when 6 then move_down    # right
        when 8 then move_right   # up
        end
    end

    def move_random
        case rand(4)
        when 0 then move_down(false)
        when 1 then move_left(false)
        when 2 then move_right(false)
        when 3 then move_up(false)
        end
    end

    def move_random_range(xrange = -1, yrange = -1)
        dirs = [] # 0=down, 1=left, 2=right, 3=up
        if xrange < 0
            dirs.push(1)
            dirs.push(2)
        elsif xrange > 0
            dirs.push(1) if @x > @original_x - xrange
            dirs.push(2) if @x < @original_x + xrange
        end
        if yrange < 0
            dirs.push(0)
            dirs.push(3)
        elsif yrange > 0
            dirs.push(0) if @y < @original_y + yrange
            dirs.push(3) if @y > @original_y - yrange
        end
        return if dirs.length == 0
        case dirs[rand(dirs.length)]
        when 0 then move_down(false)
        when 1 then move_left(false)
        when 2 then move_right(false)
        when 3 then move_up(false)
        end
    end

    def move_random_UD(range = -1)
        move_random_range(0, range)
    end

    def move_random_LR(range = -1)
        move_random_range(range, 0)
    end

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

    def move_forward
        case @direction
        when 2 then move_down(false)
        when 4 then move_left(false)
        when 6 then move_right(false)
        when 8 then move_up(false)
        end
    end

    def move_backward
        last_direction_fix = @direction_fix
        @direction_fix = true
        case @direction
        when 2 then move_up(false)
        when 4 then move_right(false)
        when 6 then move_left(false)
        when 8 then move_down(false)
        end
        @direction_fix = last_direction_fix
    end

    def move_to_original
        moveto(@original_x, @original_y)
        @direction = @original_direction
    end

    def jump(x_plus, y_plus)
        if x_plus != 0 || y_plus != 0
            if x_plus.abs > y_plus.abs
                (x_plus < 0) ? turn_left : turn_right
            else
                (y_plus < 0) ? turn_up : turn_down
            end
            each_occupied_tile { |i, j| return unless passable?(i + x_plus, j + y_plus, 0) }
        end
        @x += x_plus
        @y += y_plus
        real_distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus)
        distance = [1, real_distance].max
        @jump_peak = distance * Game_Map::TILE_HEIGHT * 3 / 8 # 3/4 of tile for ledge jumping
        @jump_distance = [x_plus.abs * Game_Map::REAL_RES_X, y_plus.abs * Game_Map::REAL_RES_Y].max
        @jump_distance_left = 1 # Just needs to be non-zero
        if real_distance > 0 # Jumping to somewhere else
            @jump_count = 0
        else # Jumping on the spot
            @jump_speed_real = nil # Reset jump speed
            @jump_count = Game_Map::REAL_RES_X / jump_speed_real # Number of frames to jump one tile
        end
        @stop_count = 0
        $PokemonTemp.dependentEvents.pbMoveDependentEvents if is_a?(Game_Player)
        triggerLeaveTile
    end

    def jumpForward
        case direction
        when 2 then jump(0, 1)    # down
        when 4 then jump(-1, 0)   # left
        when 6 then jump(1, 0)    # right
        when 8 then jump(0, -1)   # up
        end
    end

    def jumpBackward
        case direction
        when 2 then jump(0, -1)   # down
        when 4 then jump(1, 0)    # left
        when 6 then jump(-1, 0)   # right
        when 8 then jump(0, 1)    # up
        end
    end

    def turn_generic(dir)
        return if @direction_fix
        oldDirection = @direction
        @direction = dir
        @stop_count = 0
        pbCheckEventTriggerAfterTurning if dir != oldDirection
    end

    def turn_down;  turn_generic(2); end
    def turn_left;  turn_generic(4); end
    def turn_right; turn_generic(6); end
    def turn_up;    turn_generic(8); end

    def turn_right_90
        case @direction
        when 2 then turn_left
        when 4 then turn_up
        when 6 then turn_down
        when 8 then turn_right
        end
    end

    def turn_left_90
        case @direction
        when 2 then turn_right
        when 4 then turn_down
        when 6 then turn_up
        when 8 then turn_left
        end
    end

    def turn_180
        case @direction
        when 2 then turn_up
        when 4 then turn_right
        when 6 then turn_left
        when 8 then turn_down
        end
    end

    def turn_right_or_left_90
        (rand(2) == 0) ? turn_right_90 : turn_left_90
    end

    def turn_random
        case rand(4)
        when 0 then turn_up
        when 1 then turn_right
        when 2 then turn_left
        when 3 then turn_down
        end
    end

    def turn_toward_player
        sx = @x + @width / 2.0 - ($game_player.x + $game_player.width / 2.0)
        sy = @y - @height / 2.0 - ($game_player.y - $game_player.height / 2.0)
        return if sx == 0 && sy == 0
        if sx.abs > sy.abs
            (sx > 0) ? turn_left : turn_right
        else
            (sy > 0) ? turn_up : turn_down
        end
    end

    def turn_away_from_player
        sx = @x + @width / 2.0 - ($game_player.x + $game_player.width / 2.0)
        sy = @y - @height / 2.0 - ($game_player.y - $game_player.height / 2.0)
        return if sx == 0 && sy == 0
        if sx.abs > sy.abs
            (sx > 0) ? turn_right : turn_left
        else
            (sy > 0) ? turn_down : turn_up
        end
    end

    def inverted_dir
        case @direction
        when 2 then return 8
        when 4 then return 6
        when 6 then return 4
        when 8 then return 2
        end
    end

    def set_move_route(move_route)
        @move_route         = move_route
        @move_route_index   = 0
        move_type_custom
    end

    def reset_move_route
        @move_route_forcing = false
        @move_route       = @original_move_route
        @move_route_index = @original_move_route_index
        @original_move_route = nil
    end

    #=============================================================================
    # Updating
    #=============================================================================
    def update
        @moved_last_frame = @moved_this_frame
        @stopped_last_frame = @stopped_this_frame
        unless $game_temp.in_menu
            # Update command
            update_command
            # Update movement
            (moving? || jumping?) ? update_move : update_stop
        end
        # Update animation
        update_pattern
    end

    def update_command
        if @wait_count > 0
            @wait_count -= 1
        elsif @move_route_forcing
            move_type_custom
        elsif !@starting && !lock? && !moving? && !jumping?
            update_command_new
        end
    end

    def update_command_new
        # @stop_count is the number of frames since the last movement finished.
        # @move_frequency has these values:
        # 1 => @stop_count > 190   # 4.75 seconds
        # 2 => @stop_count > 144   # 3.6 seconds
        # 3 => @stop_count > 102   # 2.55 seconds
        # 4 => @stop_count > 64    # 1.6 seconds
        # 5 => @stop_count > 30    # 0.75 seconds
        # 6 => @stop_count > 0     # 0 seconds
        if @stop_count >= move_frequency_real
            case @move_type
            when 1 then move_type_random
            when 2 then move_type_toward_player
            when 3 then move_type_custom
            end
        end
    end

    def update_move
        # Move the character (the 0.1 catches rounding errors)
        distance = jumping? ? jump_speed_real : move_speed_real
        dest_x = @x * Game_Map::REAL_RES_X
        dest_y = @y * Game_Map::REAL_RES_Y
        if @real_x < dest_x
            @real_x += distance
            @real_x = dest_x if @real_x > dest_x - 0.1
        else
            @real_x -= distance
            @real_x = dest_x if @real_x < dest_x + 0.1
        end
        if @real_y < dest_y
            @real_y += distance
            @real_y = dest_y if @real_y > dest_y - 0.1
        else
            @real_y -= distance
            @real_y = dest_y if @real_y < dest_y + 0.1
        end
        # Refresh how far is left to travel in a jump
        if jumping?
            @jump_count -= 1 if @jump_count > 0 # For stationary jumps only
            @jump_distance_left = [(dest_x - @real_x).abs, (dest_y - @real_y).abs].max
        end
        # End of a step, so perform events that happen at this time
        if !jumping? && !moving?
            Events.onStepTakenFieldMovement.trigger(self, self)
            calculate_bush_depth
            @stopped_this_frame = true
        elsif !@moved_last_frame || @stopped_last_frame # Started a new step
            calculate_bush_depth
            @stopped_this_frame = false
        end
        # Increment animation counter
        @anime_count += 1 if @walk_anime || @step_anime
        @moved_this_frame = true
    end

    def update_stop
        @anime_count += 1 if @step_anime
        @stop_count += 1 if !@starting && !lock?
        @moved_this_frame = false
        @stopped_this_frame = false
    end

    def update_pattern
        return if @lock_pattern
        #    return if @jump_count > 0   # Don't animate if jumping on the spot
        # Character has stopped moving, return to original pattern
        if @moved_last_frame && !@moved_this_frame && !@step_anime
            @pattern = @original_pattern
            @anime_count = 0
            return
        end
        # Character has started to move, change pattern immediately
        if !@moved_last_frame && @moved_this_frame && !@step_anime
            @pattern = (@pattern + 1) % 4 if @walk_anime
            @anime_count = 0
            return
        end
        # Calculate how many frames each pattern should display for, i.e. the time
        # it takes to move half a tile (or a whole tile if cycling). We assume the
        # game uses square tiles.
        real_speed = jumping? ? jump_speed_real : move_speed_real
        frames_per_pattern = Game_Map::REAL_RES_X / (real_speed * 2.0)
        frames_per_pattern *= 2 if move_speed >= 5 # Cycling speed or faster
        return if @anime_count < frames_per_pattern
        # Advance to the next animation frame
        @pattern = (@pattern + 1) % 4
        @anime_count -= frames_per_pattern
    end

    def silent_offset(offsetX, offsetY)
        @x += offsetX
        @y += offsetY
        @real_x += offsetX * Game_Map::REAL_RES_X
        @real_y += offsetY * Game_Map::REAL_RES_Y
        triggerLeaveTile
    end

    def pbPullTowardsPlayer
        unless $game_player.can_move_in_direction?($game_player.inverted_dir)
            $game_player.bump_into_object
            return
        end

        old_x  = @x
        old_y  = @y

        pbSEPlay("Anim/Earth3", 30, rand(70, 90))

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
