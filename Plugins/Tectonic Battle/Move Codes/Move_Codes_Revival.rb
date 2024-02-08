#===============================================================================
# Revives a fainted Grass-type party member back to 100% HP. (Breathe Life)
#===============================================================================
class PokeBattle_Move_ReviveGrassTypePartyMemberToFullHP < PokeBattle_PartyMemberEffectMove
    def legalChoice(pokemon)
        return false unless super
        return false unless pokemon.fainted?
        return false unless pokemon.hasType?(:GRASS)
        return true
    end

    def effectOnPartyMember(pokemon)
        pokemon.heal
        @battle.pbDisplay(_INTL("{1} recovered all the way to full health!", pokemon.name))
    end

    def getEffectScore(_user, _target)
        return 250
    end
end

#===============================================================================
# Revives a fainted party member back to 1 HP. (Defibrillate)
#===============================================================================
class PokeBattle_Move_RevivePartyMemberTo1HP < PokeBattle_PartyMemberEffectMove
    def legalChoice(pokemon)
        return false unless super
        return false unless pokemon.fainted?
        return true
    end

    def effectOnPartyMember(pokemon)
        pokemon.heal
        pokemon.hp = 1
        @battle.pbDisplay(_INTL("{1} recovered to 1 HP!", pokemon.name))
    end

    def getEffectScore(_user, _target)
        return 200
    end
end