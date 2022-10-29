module GameData
    class Ability
        attr_reader :signature_of

        # The highest evolution of a line
        def signature_of=(val)
          @signature_of = val
        end

        def is_signature?()
          return !@signature_of.nil?
        end

        def is_primeval?
          return @id.to_s[/PRIMEVAL/]
        end
    end
end