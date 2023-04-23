module GameData
    class Move
        attr_reader :animation_move
        attr_reader :signature_of
        attr_reader :primeval
        attr_reader :zmove
        attr_reader :cut
        attr_reader :tectonic_new

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
          @primeval           = hash[:primeval] || false
          @zmove              = hash[:zmove] || false
          @cut                = hash[:cut] || false
          @tectonic_new       = hash[:tectonic_new] || false
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

        def getCategoryLabel
          category = nil
          @flags.split("").each do |flag|
            case flag
            when "i"
                category = _INTL("Bite")
            when "j"
                category = _INTL("Punch")
            when "k"
                category = _INTL("Sound")
            when "m"
                category = _INTL("Pulse")
            when "o"
                category = _INTL("Dance")
            when "p"
                category = _INTL("Blade")
            when "q"
                category = _INTL("Wind")
            end
          end
          return category
        end

        def can_be_forced?
          return false if [
            "0D4",   # Bide
            "14B",   # King's Shield
            # Struggle
            "002",   # Struggle
            "158",   # Belch
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
            "16B",   # Instruct
            "57A",   # Hive Mind
            # Moves that require a recharge turn
            "0C2",   # Hyper Beam
            # Moves that start focussing at the start of the round
            "115",   # Focus Punch
            "171",   # Shell Trap
            "172",   # Beak Blast
            # Counter moves
            "071",   # Counter
            "072",   # Mirror Coat
            "073",   # Metal Burst
          ].include?(@function_code)
          return true
        end

        def learnable?
          return false if @cut
          return false if @primeval
          return false if @zmove
          return true
        end
    end
end