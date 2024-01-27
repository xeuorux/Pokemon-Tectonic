#===============================================================================
# No additional effect.
#===============================================================================
class PokeBattle_Move_Basic < PokeBattle_Move
end

#===============================================================================
# Does absolutely nothing. (Splash)
#===============================================================================
class PokeBattle_Move_DoNothing < PokeBattle_Move
    def unusableInGravity?; return true; end

    def pbEffectGeneral(_user)
        @battle.pbDisplay(_INTL("But nothing happened!"))
    end
end

#===============================================================================
# Struggle, if defined as a move in moves.txt. Typically it won't be.
#===============================================================================
class PokeBattle_Move_Struggle < PokeBattle_Struggle
end

#===============================================================================
# User faints, even if the move does nothing else. (Explosion, Self-Destruct)
#===============================================================================
class PokeBattle_Move_0E0 < PokeBattle_Move
    def worksWithNoTargets?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 1; end

    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.moldBreaker
            dampHolder = @battle.pbCheckGlobalAbility(:DAMP)
            unless dampHolder.nil?
                if show_message
                    @battle.pbShowAbilitySplash(dampHolder, :DAMP)
                    @battle.pbDisplay(_INTL("{1} cannot use {2}!", user.pbThis, @name))
                    @battle.pbHideAbilitySplash(dampHolder)
                end
                return true
            end
        end
        return false
    end

    def shouldShade?(_user, _target)
        return false
    end

    def pbMoveFailedAI?(_user, _targets); return false; end

    def pbSelfKO(user)
        return if user.fainted?

        if user.hasActiveAbility?(:SPINESPLODE)
            spikesCount = user.pbOpposingSide.incrementEffect(:Spikes, 2)
            
            if spikesCount > 0
                @battle.pbShowAbilitySplash(user, :SPINESPLODE)
                @battle.pbDisplay(_INTL("#{spikesCount} layers of Spikes were scattered all around #{user.pbOpposingTeam(true)}'s feet!"))
                @battle.pbHideAbilitySplash(user)
            end
        end

        if user.bunkeringDown?
            @battle.pbShowAbilitySplash(user, :BUNKERDOWN)
            @battle.pbDisplay(_INTL("{1}'s {2} barely saves it!", user.pbThis, @name))
            user.pbReduceHP(user.hp - 1, false)
            @battle.pbHideAbilitySplash(user)
        else
            reduction = user.totalhp
            unbreakable = user.hasActiveAbility?(:UNBREAKABLE)
            if unbreakable
                @battle.pbShowAbilitySplash(user, :UNBREAKABLE)
                @battle.pbDisplay(_INTL("{1} resists the recoil!", user.pbThis))
                reduction /= 2
            end
            user.pbReduceHP(reduction, false)
            @battle.pbHideAbilitySplash(user) if unbreakable
            if user.hasActiveAbility?(:PERENNIALPAYLOAD,true)
                @battle.pbShowAbilitySplash(user, :PERENNIALPAYLOAD)
                @battle.pbDisplay(_INTL("{1} will revive in 3 turns!", user.pbThis))
                if user.pbOwnSide.effectActive?(:PerennialPayload)
                    user.pbOwnSide.effects[:PerennialPayload][user.pokemonIndex] = 4
                else
                    user.pbOwnSide.effects[:PerennialPayload] = {
                        user.pokemonIndex => 4,
                    }
                end
                @battle.pbHideAbilitySplash(user)
            end
        end
        user.pbItemHPHealCheck
    end

    def getEffectScore(user, target)
        score = getSelfKOMoveScore(user, target)
        score += 30 if user.bunkeringDown?(true)
        score += 30 if user.hasActiveAbilityAI?(:PERENNIALPAYLOAD)
        if user.hasActiveAbility?(:SPINESPLODE)
            currentSpikeCount = user.pbOpposingSide.countEffect(:Spikes)
            spikesMax = GameData::BattleEffect.get(:Spikes).maximum
            count = [spikesMax, currentSpikeCount + 2].min - currentSpikeCount
            score += count * getHazardSettingEffectScore(user, target)
        end
        return score
    end
end

#===============================================================================
# Target's attacking stats are lowered by 5 steps. User faints. (Memento)
#===============================================================================
class PokeBattle_Move_0E2 < PokeBattle_TargetMultiStatDownMove
    def worksWithNoTargets?; return true; end

    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 5, :SPECIAL_ATTACK, 5]
    end

    def pbSelfKO(user)
        return if user.fainted?
        user.pbReduceHP(user.totalhp, false)
        user.pbItemHPHealCheck
    end
    
    def getEffectScore(user, target)
        score = getSelfKOMoveScore(user, target)
        return score
    end
end

#===============================================================================
# All current battlers will perish after 3 more rounds. (Perish Song)
#===============================================================================
class PokeBattle_Move_0E5 < PokeBattle_Move
    def pbMoveFailed?(_user, targets, show_message)
        failed = true
        targets.each do |b|
            next if b.effectActive?(:PerishSong)
            failed = false
            break
        end
        if failed
            @battle.pbDisplay(_INTL("But it failed, since everyone has heard the song already!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, _show_message)
        return target.effectActive?(:PerishSong)
    end

    def pbEffectAgainstTarget(user, target)
        if target.boss?
            target.applyEffect(:PerishSong, 12)
        else
            target.applyEffect(:PerishSong, 3)
        end
    end

    def getEffectScore(user, _target)
        return 0 unless user.alliesInReserve?
        return 60
    end
end

#===============================================================================
# If target would be KO'd by this attack, it survives with 1HP instead.
# (False Swipe, Hold Back)
#===============================================================================
class PokeBattle_Move_0E9 < PokeBattle_Move
    def nonLethal?(_user, _target); return true; end
end

#===============================================================================
# Swaps form if the user is Meloetta. (Relic Song)
#===============================================================================
class PokeBattle_Move_078 < PokeBattle_Move
    def pbEndOfMoveUsageEffect(user, _targets, numHits, _switchedBattlers)
        return if numHits == 0
        return if user.fainted? || user.transformed?
        return unless user.isSpecies?(:MELOETTA)
        return if user.hasActiveAbility?(:SHEERFORCE)
        newForm = (user.form + 1) % 2
        user.pbChangeForm(newForm, _INTL("{1} transformed!", user.pbThis))
    end
end

#===============================================================================
# Interrupts a foe switching out or using U-turn/Volt Switch/Parting Shot. Power
# is doubled in that case. (Pursuit)
# (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
#===============================================================================
class PokeBattle_Move_088 < PokeBattle_Move
    def pbAccuracyCheck(user, target)
        return true if @battle.switching
        return super
    end

    def pbBaseDamage(baseDmg, _user, _target)
        baseDmg *= 2 if @battle.switching
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        baseDmg *= 2 if @battle.aiPredictsSwitch?(user,target.index)
        return baseDmg
    end
end

#===============================================================================
# Transforms the user into one of its Mega Forms. (Gene Boost)
#===============================================================================
class PokeBattle_Move_089 < PokeBattle_Move
    def resolutionChoice(user)
        if @battle.autoTesting
            @chosenForm = rand(2) + 1
        elsif !user.pbOwnedByPlayer? # Trainer AI
            @chosenForm = 2 # Always chooses mega mind form
        else
            form1Name = GameData::Species.get_species_form(:MEWTWO,1).form_name
            form2Name = GameData::Species.get_species_form(:MEWTWO,2).form_name
            formNames = [form1Name,form2Name]
            chosenIndex = @battle.scene.pbShowCommands(_INTL("Which form should #{user.pbThis(true)} take?"),formNames,0)
            @chosenForm = chosenIndex + 1
        end
    end

    def pbCanChooseMove?(user, commandPhase, show_message)
        unless user.form == 0
            if show_message
                msg = _INTL("#{user.pbThis} has already transformed!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        return true
    end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.countsAs?(:MEWTWO)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis)) if show_message
            return true
        end
        unless user.form == 0
            @battle.pbDisplay(_INTL("But {1} has already transformed!", user.pbThis)) if show_message
            return true
        end
        return false
    end
    
    def pbEffectGeneral(user)
        user.pbChangeForm(@chosenForm, _INTL("{1} augmented its genes and transformed!", user.pbThis))
    end

    def resetMoveUsageState
        @chosenForm = nil
    end

    def getEffectScore(_user, _target)
        return 100
    end
end

#===============================================================================
# Target transforms into their pre-evolution. (Young Again)
#===============================================================================
class PokeBattle_Move_0BF < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.illusion?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is disguised by an Illusion!"))
            end
            return true
        end
        unless target.species_data
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have a defined species somehow!"))
            end
            return true
        end
        unless GameData::Species.get(target.technicalSpecies).has_previous_species?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} has no previous species to transform into!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.transformSpecies(GameData::Species.get(target.technicalSpecies).get_previous_species)
    end

    def getEffectScore(user, target)
        score = 95
        score += 45 if target.aboveHalfHealth?
        if user.battle.pbCanSwitch?(target.index)
            score -= 30
            score += getForceOutEffectScore(user, target)
        end
        return score
    end
end