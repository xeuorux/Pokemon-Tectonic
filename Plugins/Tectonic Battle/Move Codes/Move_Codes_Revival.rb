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

#===============================================================================
# Revives a fainted party member back to 50% HP, then switch them in and boost their stats. (Golden Rebirth)
#===============================================================================
class PokeBattle_Move_RevivePartyMemberTo50HPThenSwitch < PokeBattle_Move
    def switchOutMove?; return true; end
    
    def initialize(battle, move)
        super
        @partyIndex = 0
    end

    def legalChoice(pokemon)
        return false unless pokemon
        return false unless pokemon.fainted?
        return true
    end

    def pbMoveFailed?(user, _targets, show_message)
        return true if @battle.autoTesting
        return true if user.battle.pbIsTrapped?(user.index)
        @battle.pbParty(user.index).each do |pkmn|
            return false if legalChoice(pkmn)
        end
        @battle.pbDisplay(_INTL("But it failed, since there are no valid choices in your party!")) if show_message
        return true
    end

    def effectOnPartyMember(pokemon)
        pokemon.heal
        pokemon.hp = (pokemon.totalhp / 2.0).ceil
    end

    def pbEffectGeneral(user)
        selectedPokemon, @partyIndex = selectPartyMemberForSwitchEffect(user.index, proc { |pkmn| next legalChoice(pkmn) })
        effectOnPartyMember(selectedPokemon)
    end

    def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
        return if user.fainted? || numHits == 0
        user.battle.pbCommonAnimation("FireSpin", user)
        @battle.pbDisplay(_INTL("{1} created a golden pyre!", user.name))
        switchOutUserForSelectedPokemon(user,@partyIndex,switchedBattlers)
        @battle.pbDisplay(_INTL("{1} emerged from the pyre!", user.name))
         user.pbRaiseMultipleStatSteps(ALL_STATS_1, user)
    end

    def getEffectScore(user, target)
        return 200 + getSwitchOutEffectScore(user)
    end
end