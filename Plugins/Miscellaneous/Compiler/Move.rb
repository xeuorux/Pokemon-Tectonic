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

        # The highest evolution of a line
        def signature_of=(val)
          @signature_of = val
        end

        def is_signature?()
          return !@signature_of.nil?
        end

        # def total_pp
        #   case @total_pp
        #   when 0..10
        #     return @total_pp
        #   when 10..14
        #     return 10
        #   when 15..19
        #     return 12
        #   when 20..24
        #     return 15
        #   when 25..29
        #     return 20
        #   when 30..34
        #     return 25
        #   when 35..40
        #     return 30
        #   else
        #     return 30
        #   end
        # end
    end
end