#===============================================================================
# Cures user of any status condition. (Refresh)
#===============================================================================
class PokeBattle_Move_018 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.pbHasAnyStatus?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no status condition!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbCureStatus
    end

    def getEffectScore(_user, _target)
        return 75
    end
end

#===============================================================================
# Cures all party Pokémon of permanent status problems. (Aromatherapy, Heal Bell)
#===============================================================================
class PokeBattle_Move_019 < PokeBattle_Move
    def worksWithNoTargets?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        @battle.pbParty(user.index).each do |pkmn|
            return false if validPokemon(pkmn)
        end
        @battle.pbDisplay(_INTL("But it failed, since there are no status conditions in the party!")) if show_message
        return true
    end

    def validPokemon(pkmn)
        return pkmn&.able? && pkmn.status != :NONE
    end

    def pbEffectGeneral(user)
        # Cure all Pokémon in the user's and partner trainer's party.
        # NOTE: This intentionally affects the partner trainer's inactive Pokémon
        #       too.
        @battle.pbParty(user.index).each_with_index do |pkmn, i|
            battler = @battle.pbFindBattler(i, user)
            if battler
                healStatus(battler)
            else
                healStatus(pkmn)
            end
        end
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        super
        if @id == :AROMATHERAPY
            @battle.pbDisplay(_INTL("A soothing aroma wafted through the area!"))
        elsif @id == :HEALBELL
            @battle.pbDisplay(_INTL("A bell chimed!"))
        end
    end

    def getEffectScore(user, target)
        return 0 if target && target.index != user.index
        score = 0
        score -= statusSpikesWeightOnSide(user.pbOwnSide) if user.alliesInReserve?
        statusesInParty = 0 
        @battle.pbParty(user.index).each do |pkmn|
            statusesInParty += 1 if validPokemon(pkmn)
        end
        if statusesInParty > 0
            statusScore = 70 + statusesInParty * 40
            statusScore = 200 if statusScore > 200
            score += statusScore
        end
        return score
    end
end

#===============================================================================
# Safeguards the user's side from being inflicted with status problems.
# (Safeguard)
#===============================================================================
class PokeBattle_Move_01A < PokeBattle_Move
    def initialize(battle, move)
        super
        @safeguardDuration = 10
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:Safeguard, @safeguardDuration)
    end

    def getEffectScore(user, _target)
        return getSafeguardEffectScore(user, @safeguardDuration)
    end
end

#===============================================================================
# User passes its first status problem to the target. (Psycho Shift)
#===============================================================================
class PokeBattle_Move_01B < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.pbHasAnyStatus?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't have any status conditions!"))
            end
            return true
        end
        return false
    end

    def statusBeingMoved(user)
        return user.getStatuses[0]
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return !target.pbCanInflictStatus?(statusBeingMoved(user), user, show_message, self)
    end

    def pbEffectAgainstTarget(user, target)
        target.pbInflictStatus(statusBeingMoved(user), 0, nil, user)
        user.pbCureStatus(true, statusBeingMoved(user))
    end

    def getEffectScore(user, target)
        status = statusBeingMoved(user)
        score = 0
        score += getStatusSettingEffectScore(status, user, target, ignoreCheck: true)
        score += getStatusSettingEffectScore(status, target, user, ignoreCheck: true)
        return score
    end
end