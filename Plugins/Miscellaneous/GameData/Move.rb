module GameData
    class Move
        attr_reader :animation_move
        attr_reader :signature_of

        def initialize(hash)
          @id                 = hash[:id]
          @id_number          = hash[:id_number]   || -1
          @real_name          = hash[:name]        || "Unnamed"
          @function_code      = hash[:function_code]
          @base_damage        = hash[:base_damage]
          @type               = hash[:type]
          @category           = hash[:category]
          @accuracy           = hash[:accuracy]
          @total_pp           = hash[:total_pp]
          @effect_chance      = hash[:effect_chance]
          @target             = hash[:target]
          @priority           = hash[:priority]
          @flags              = hash[:flags]
          @real_description   = hash[:description] || "???"
          @animation_move     = hash[:animation_move]
          @signature_of       = nil
        end

        def damaging?
          return physical? || special?
        end

        # The highest evolution of a line
        def signature_of=(val)
          @signature_of = val
        end

        def is_signature?()
          return !@signature_of.nil?
        end

        def empoweredMove?
          return @flags[/y/]
        end

        def can_be_forced?
          return false if [
            "0D4",   # Bide
            "14B",   # King's Shield
            "16B",   # Instruct (this move)
            # Struggle
            "002",   # Struggle
            # Moves that affect the moveset
            "05C",   # Mimic
            "05D",   # Sketch
            "069",   # Transform
            # Moves that call other moves
            "0AE",   # Mirror Move
            "0AF",   # Copycat
            "0B0",   # Me First
            "0B3",   # Nature Power
            "0B4",   # Sleep Talk
            "0B5",   # Assist
            "0B6",   # Metronome
            # Moves that require a recharge turn
            "0C2",   # Hyper Beam
            # Two-turn attacks
            "0C3",   # Razor Wind
            "0C4",   # Solar Beam, Solar Blade
            "0C5",   # Freeze Shock
            "0C6",   # Ice Burn
            "0C7",   # Sky Attack
            "0C8",   # Skull Bash
            "0C9",   # Fly
            "0CA",   # Dig
            "0CB",   # Dive
            "0CC",   # Bounce
            "0CD",   # Shadow Force
            "0CE",   # Sky Drop
            "12E",   # Shadow Half
            "14D",   # Phantom Force
            "14E",   # Geomancy
            # Moves that start focussing at the start of the round
            "115",   # Focus Punch
            "171",   # Shell Trap
            "172",    # Beak Blast
            "57A",   # Hive Mind
          ].include?(@function_code)
         return true
        end
    end
end