#===============================================================================
# Ends all barriers and entry hazards for the target's side. (Defog)
# And all entry hazard's for the user's side.
#===============================================================================
class PokeBattle_Move_049 < PokeBattle_Move
    def hazardRemovalMove?; return true; end
    def aiAutoKnows?(pokemon); return false; end

    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @miscEffects = %i[Mist Safeguard]
    end

    def eachDefoggable(side, isOurSide)
        side.eachEffect(true) do |effect, _value, data|
            if !isOurSide && (data.is_screen? || @miscEffects.include?(effect))
                yield effect, data
            elsif data.is_hazard?
                yield effect, data
            end
        end
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        targetSide = target.pbOwnSide
        ourSide = user.pbOwnSide
        eachDefoggable(targetSide, false) do |_effect, _data|
            return false
        end
        eachDefoggable(ourSide, true) do |_effect, _data|
            return false
        end
    end

    def blowAwayEffect(user, side, effect, data)
        side.disableEffect(effect)
        if data.is_hazard?
            hazardName = data.name
            @battle.pbDisplay(_INTL("{1} blew away {2}!", user.pbThis, hazardName)) unless data.has_expire_proc?
        end
    end

    def pbEffectAgainstTarget(user, target)
        targetSide = target.pbOwnSide
        ourSide = user.pbOwnSide
        eachDefoggable(targetSide, false) do |effect, data|
            blowAwayEffect(user, targetSide, effect, data)
        end
        eachDefoggable(ourSide, true) do |effect, data|
            blowAwayEffect(user, ourSide, effect, data)
        end
    end

    def getEffectScore(user, target)
        score = 0
        # Dislike removing hazards that affect the enemy
        score -= 0.8 * hazardWeightOnSide(target.pbOwnSide) if target.alliesInReserve?
        # Like removing hazards that affect us
        score += hazardWeightOnSide(target.pbOpposingSide) if user.alliesInReserve?
        target.pbOwnSide.eachEffect(true) do |effect, value, data|
            next unless data.is_screen? || @miscEffects.include?(effect)
			case value
				when 2
					score += 30
				when 3
					score += 55
				when 4..999
					score += 140
            end	
        end
        return score
    end
end