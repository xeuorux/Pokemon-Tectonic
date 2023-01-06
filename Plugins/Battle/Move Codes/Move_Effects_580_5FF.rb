#===============================================================================
# Transfers the user's status to the target (Vicious Cleaning)
#===============================================================================
class PokeBattle_Move_580 < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        user.getStatuses.each do |status|
            next if status == :NONE
            if target.pbCanInflictStatus?(status, user, false, self)
                case status
                when :SLEEP
                    target.applySleep
                when :POISON
                    target.applyPoison(user, nil, user.statusCount != 0)
                when :BURN
                    target.applyBurn(user)
                when :NUMB
                    target.applyNumb(user)
                when :FROSTBITE
                    target.applyFrostbite(user)
                when :DIZZY
                    target.applyDizzy(user)
                end
            else
                statusData = GameData::Status.get(status)
                @battle.pbDisplay(_INTL("{1} tries to transfer its {2} to {3}, but...", user.pbThis, statusData.real_name,
target.pbThis(true)))
                target.pbCanInflictStatus?(status, user, true, self)
            end
            user.pbCureStatus(status)
        end
    end

    def shouldHighlight?(user, _target)
        return user.pbHasAnyStatus?
    end
end

#===============================================================================
# Puts the target to sleep if they are slower, then minimizes the user's speed. (Sedating Dust)
#===============================================================================
class PokeBattle_Move_581 < PokeBattle_SleepMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.pbSpeed > user.pbSpeed
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is slower than #{target.pbThis(true)}!"))
            end
            return true
        end
        return !target.canSleep?(user, show_message, self)
    end

    def pbEffectAgainstTarget(user, target)
        target.applySleep
        user.pbMinimizeStatStage(:SPEED, user, self)
    end

    def getEffectScore(user, target)
        score = super
        score -= 30
        score -= user.stages[:SPEED] * 5
        return score
    end
end

#===============================================================================
# For 5 rounds, swaps all battlers' offensive and defensive stats (Sp. Def <-> Sp. Atk and Def <-> Atk).
# (Odd Room)
#===============================================================================
class PokeBattle_Move_582 < PokeBattle_Move
    def initialize(battle, move)
        super
        @roomEffect = :OddRoom
    end
end

#===============================================================================
# Restores health by 33% and raises Speed by one stage. (Mulch Meal)
#===============================================================================
class PokeBattle_Move_583 < PokeBattle_HealingMove
    def healRatio(_user)
        return 1.0 / 3.0
    end

    def pbMoveFailed?(user, _targets, show_message)
        if user.hp == user.totalhp && !user.pbCanRaiseStatStage?(:SPEED, user, self, true)
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
    end

    def pbEffectGeneral(user)
        super
        user.tryRaiseStat(:SPEED, user, move: self)
    end

    def getEffectScore(user, target)
        score = super
        score += 20
        score -= user.stages[:SPEED] * 20
        return score
    end
end

#===============================================================================
# Raises the target's worst three stats by one stage each. (Guiding Aroma)
#===============================================================================
class PokeBattle_Move_584 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if statUp(user, target).length == 0
            @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", target.pbThis)) if show_message
            return true
        end
        return false
    end

    def statUp(user, target)
        statsTargetCanRaise = target.finalStats.select do |stat, _finalValue|
            next target.pbCanRaiseStatStage?(stat, user, self)
        end
        statsRanked = statsTargetCanRaise.sort_by { |_s, v| v }.to_h.keys
        statUp = []
        statsRanked.each_with_index do |stat, index|
            break if index > 2
            statUp.push(stat)
            statUp.push(1)
        end
        return statUp
    end

    def pbEffectAgainstTarget(user, target)
        target.pbRaiseMultipleStatStages(statUp(user, target), user, move: self)
    end

    def getEffectScore(user, target)
        return 0 if statUp(user, target).length == 0
        return getMultiStatUpEffectScore(statUp(user, target), user, target)
    end
end

#===============================================================================
# Raises the user's Sp. Atk, and the user's attacks become spread. (Flare Witch)
#===============================================================================
class PokeBattle_Move_585 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:FlareWitch) && !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self, true)
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.tryRaiseStat(:SPECIAL_ATTACK, user, move: self)
        user.applyEffect(:FlareWitch)
    end
end

#===============================================================================
# Effectiveness against Fighting-type is 2x. (Honorless Sting)
#===============================================================================
class PokeBattle_Move_586 < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :FIGHTING
        return super
    end
end

#===============================================================================
# Resets all stat stages at end of turn and at the end of the next four turns. (Grey Mist)
#===============================================================================
class PokeBattle_Move_587 < PokeBattle_Move
    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:GreyMist, 5)
    end

    def pbMoveFailed?(_user, _targets, show_message)
        if @battle.field.effectActive?(:GreyMist)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since the field is already shrouded in Grey Mist!"))
            end
            return true
        end
        return false
    end

    def getEffectScore(user, _target)
        score = 50
        @battle.eachBattler do |b|
            totalStages = 0
            GameData::Stat.each_battle { |s| totalStages += b.stages[s.id] }
            if b.opposes?(user)
                score += totalStages * 20
            else
                score -= totalStages * 20
            end
        end
        return score
    end
end

#===============================================================================
# If it faints the target, you gain lots of money after the battle. (Plunder)
#===============================================================================
class PokeBattle_Move_588 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return unless target.damageState.fainted
        @battle.field.incrementEffect(:PayDay, 10 * user.level) if user.pbOwnedByPlayer?
    end
end

#===============================================================================
# Attacks two to five times. Gains money for each hit. (Sacred Lots)
#===============================================================================
class PokeBattle_Move_589 < PokeBattle_Move_0C0
    def pbEffectOnNumHits(user, _target, numHits)
        coinsGenerated = 2 * user.level * numHits
        @battle.field.incrementEffect(:PayDay, coinsGenerated) if user.pbOwnedByPlayer?
        if numHits == 10
            @battle.pbDisplay(_INTL("How fortunate!"))
        elsif numHits == 0
            @battle.pbDisplay(_INTL("How unfortunate! Better luck next time."))
        end
    end
end

#===============================================================================
# Power is tripled if the target is poisoned. (Vipershock)
#===============================================================================
class PokeBattle_Move_58A < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 3 if target.poisoned?
        return baseDmg
    end
end

#===============================================================================
# Counts as a use of Rock Roll, Snowball, or Furycutter. (On A Roll)
#===============================================================================
class PokeBattle_Move_58B < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        oldEffectValues = {}
        user.eachEffect(true) do |effect, value, data|
            oldEffectValues[effect] = value if data.snowballing_move_counter?
        end
        super
        oldEffectValues.each do |effect, oldValue|
            data = GameData::BattleEffect.get(effect)
            user.effects[effect] = [oldValue + 1, data.maximum].min
        end
    end
end

#===============================================================================
# The user's Speed raises two stages, and it gains the Flying-type. (Mach Flight)
#===============================================================================
class PokeBattle_Move_58C < PokeBattle_Move_030
    def pbMoveFailed?(user, targets, show_message)
        return false if GameData::Type.exists?(:FLYING) && !user.pbHasType?(:FLYING) && user.canChangeType?
        super
    end

    def pbEffectGeneral(user)
        super
        user.applyEffect(:Type3, :FLYING)
    end
end

#===============================================================================
# Guaranteed to crit, but lowers the user's speed. (Incision)
#===============================================================================
class PokeBattle_Move_58D < PokeBattle_Move_03E
    def pbCriticalOverride(_user, _target); return 1; end
end

#===============================================================================
# Returns user to party for swap and lays a layer of spikes. (Caltrop Style)
#===============================================================================
class PokeBattle_Move_58E < PokeBattle_Move_0EE
    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if user.pbOpposingSide.effectAtMax?(:Spikes)
            @battle.pbDisplay(_INTL("But it failed, since there is no room for more Spikes!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        user.pbOpposingSide.incrementEffect(:Spikes)
    end

    def pbAdditionalEffect(user, _target)
        return unless damagingMove?
        return if user.pbOpposingSide.effectAtMax?(:Spikes)
        user.pbOpposingSide.incrementEffect(:Spikes)
    end

    def getEffectScore(user, target)
        score = super
        score += getHazardSettingEffectScore(user, target) unless user.pbOpposingSide.effectAtMax?(:Spikes)
        return score
    end
end

#===============================================================================
# Faints the opponant if they are below 1/4 HP, after dealing damage. (Cull)
#===============================================================================
class PokeBattle_Move_58F < PokeBattle_Move
    def canCull?(target)
        return target.hp < (target.totalhp / 4)
    end

    def pbEffectAgainstTarget(user, target)
        if canCull?(target)
            @battle.pbDisplay(_INTL("#{user.pbThis} culls #{target.pbThis(true)}!"))
            target.pbReduceHP(target.hp, false)
            target.pbItemHPHealCheck
        end
    end

    def shouldHighlight?(_user, target)
        return canCull?(target)
    end
end

#===============================================================================
# Decreases the target's Defense by 3 stages. (Eroding Foam)
#===============================================================================
class PokeBattle_Move_590 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 3]
    end
end

#===============================================================================
# Power increases the taller the user is than the target. (Cocodrop)
#===============================================================================
class PokeBattle_Move_591 < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, target)
        ret = 40
        n = (user.pbHeight / target.pbHeight).floor
        if n >= 5
            ret = 120
        elsif n >= 4
            ret = 100
        elsif n >= 3
            ret = 80
        elsif n >= 2
            ret = 60
        end
        return ret
    end
end

#===============================================================================
# Damages target if target is a foe, or buff's the target's Speed and
# Sp. Def is it's an ally. (Lightning Spear)
#===============================================================================
class PokeBattle_Move_592 < PokeBattle_Move
    def pbOnStartUse(user, targets)
        @buffing = false
        @buffing = !user.opposes?(targets[0]) if targets.length > 0
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false unless @buffing
        if !target.pbCanRaiseStatStage?(:SPEED, user,
self) && !target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user, self)
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end

    def pbDamagingMove?
        return false if @buffing
        return super
    end

    def pbEffectAgainstTarget(user, target)
        return unless @buffing
        target.pbRaiseMultipleStatStages([:SPEED, 2], user, move: self)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        if @buffing
            @battle.pbAnimation(:CHARGE, user, targets, hitNum) if showAnimation
        else
            super
        end
    end
end

#===============================================================================
# Does Dragon-Darts style hit redirection, plus
# each target hit loses 1 stage of Speed. (Tar Volley)
#===============================================================================
class PokeBattle_Move_592 < PokeBattle_Move_17C
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.tryLowerStat(:SPEED, user, move: self)
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks with the user with a special attack while this effect applies, that Pokémon
# takes 1/8th chip damage. (Mirror Shield)
#===============================================================================
class PokeBattle_Move_593 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :MirrorShield
    end

    def getEffectScore(user, target)
        score = super
        # Check only special attackers
        user.eachPotentialAttacker(1) do |_b|
            score += 20
        end
        return score
    end
end

#===============================================================================
# Power doubles if has the Defense Curl effect, which it consumes. (Unfurl)
#===============================================================================
class PokeBattle_Move_594 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 2 if user.effectActive?(:DefenseCurl)
        return baseDmg
    end

    def pbEffectAfterAllHits(user, _target)
        user.disableEffect(:DefenseCurl)
    end
end

#===============================================================================
# User's Attack and Defense are raised by one stage each, and changes user's type to Rock. (Built Different)
#===============================================================================
class PokeBattle_Move_595 < PokeBattle_Move_024
    def pbMoveFailed?(user, targets, show_message)
        return false if GameData::Type.exists?(:ROCK) && !user.pbHasType?(:ROCK) && user.canChangeType?
        super
    end

    def pbEffectGeneral(user)
        super
        user.applyEffect(:Type3, :ROCK)
    end
end

#===============================================================================
# The target cannot escape and takes 50% more damage from all attacks. (Death Mark)
#===============================================================================
class PokeBattle_Move_596 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:DeathMark)
            @battle.pbDisplay(_INTL("But it failed, since the target is already marked for death!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.pointAt(:DeathMark, user) unless target.effectActive?(:DeathMark)
    end
end

#===============================================================================
# User's side takes 50% less attack damage this turn. (Bulwark)
#===============================================================================
class PokeBattle_Move_597 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect      = :Bulwark
        @sidedEffect = true
    end

    def pbProtectMessage(user)
        @battle.pbDisplay(_INTL("{1} spread its arms to guard {2}!", @name, user.pbTeam(true)))
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_598 < PokeBattle_Move
end

#===============================================================================
# User takes recoil damage equal to 1/5 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_599 < PokeBattle_RecoilMove
    def recoilFactor; return 0.2; end
end

#===============================================================================
# Burns the target and sets Sun
#===============================================================================
class PokeBattle_Move_59A < PokeBattle_InvokeMove
    def initialize(battle, move)
        super
        @weatherType = :Sun
        @durationSet = 4
        @statusToApply = :BURN
    end
end

#===============================================================================
# Numbs the target and sets Rain
#===============================================================================
class PokeBattle_Move_59B < PokeBattle_InvokeMove
    def initialize(battle, move)
        super
        @weatherType = :Rain
        @durationSet = 4
        @statusToApply = :NUMB
    end
end

#===============================================================================
# Frostbites the target and sets Hail
#===============================================================================
class PokeBattle_Move_59C < PokeBattle_InvokeMove
    def initialize(battle, move)
        super
        @weatherType = :Hail
        @durationSet = 4
        @statusToApply = :FROSTBITE
    end
end

#===============================================================================
# Dizzies the target and sets Sandstorm
#===============================================================================
class PokeBattle_Move_59D < PokeBattle_InvokeMove
    def initialize(battle, move)
        super
        @weatherType = :Sandstorm
        @durationSet = 4
        @statusToApply = :DIZZY
    end
end

#===============================================================================
# Revives a fainted party member back to 1 HP. (Defibrillate)
#===============================================================================
class PokeBattle_Move_59E < PokeBattle_PartyMemberEffectMove
    def legalChoice(pokemon)
        return false unless super
        return false unless pokemon.fainted?
        return true
    end

    def effectOnPartyMember(pokemon)
        pokemon.hp = 1
        pokemon.heal_status
        @battle.pbDisplay(_INTL("{1} recovered to 1 HP!", pokemon.name))
    end
end

#===============================================================================
# Decreases the target's Attack and Special Attack by 1 stage each. (Singing Stone)
#===============================================================================
class PokeBattle_Move_59F < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 1, :SPECIAL_ATTACK, 1]
    end
end

#===============================================================================
# Type effectiveness is multiplied by the Ice-type's effectiveness against
# the target. (Feverish Gas)
#===============================================================================
class PokeBattle_Move_5A0 < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        ret = super
        if GameData::Type.exists?(:ICE)
            iceEffectiveness = Effectiveness.calculate_one(:ICE, defType)
            ret *= iceEffectiveness.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
        end
        return ret
    end
end

#===============================================================================
# Entry hazard. Lays Feather Ward on the opposing side. (Feather Ward)
#===============================================================================
class PokeBattle_Move_5A1 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.pbOpposingSide.effectActive?(:FeatherWard)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since sharp feathers already float around the opponent!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOpposingSide.applyEffect(:FeatherWard)
    end

    def getEffectScore(user, target)
        return getHazardSettingEffectScore(user, target)
    end
end

#===============================================================================
# Decreases the user's Sp. Def.
# Increases the user's Sp. Atk by 1 stage, and Speed by 2 stages.
# (Shed Coat)
#===============================================================================
class PokeBattle_Move_5A2 < PokeBattle_StatUpDownMove
    def initialize(battle, move)
        super
        @statUp   = [:SPEED, 2, :SPECIAL_ATTACK, 1]
        @statDown = [:SPECIAL_DEFENSE, 1]
    end
end

#===============================================================================
# Decreases the user's Speed by 2 stages. (Razor Plunge)
#===============================================================================
class PokeBattle_Move_5A3 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 2]
    end
end

#===============================================================================
# The next ground type move to hit the target deals double damage. (Volatile Toxin)
#===============================================================================
class PokeBattle_Move_5A4 < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:VolatileToxin)
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks the user while this effect applies, that Pokémon become leeched.
# (Root Haven)
#===============================================================================
class PokeBattle_Move_5A5 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :RootShelter
    end
end

#===============================================================================
# User must use this move for 2 more rounds. Raises Speed if KOs. (Tyrant's Fit)
#===============================================================================
class PokeBattle_Move_5A6 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        user.applyEffect(:Outrage, 3) if !target.damageState.unaffected && !user.effectActive?(:Outrage)
        user.tickDownAndProc(:Outrage)
        return unless target.damageState.fainted
        user.tryRaiseStat(:SPEED, user, increment: 1, move: self)
    end

    # Used to modify the AI elsewhere
    def hasKOEffect?(user, _target)
        return false unless user.pbCanRaiseStatStage?(:SPEED, user, self)
        return true
    end
end

#===============================================================================
# Two turn attack. Skips first turn, and transforms the user into their second form
# on the 2nd turn. Only ampharos can use it. (Transcendant Energy)
#===============================================================================
class PokeBattle_Move_5A7 < PokeBattle_TwoTurnMove
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:AMPHAROS)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        elsif user.form != 0
            @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} is radiating energy!", user.pbThis))
    end

    def pbEffectGeneral(user)
        return unless @damagingTurn
        user.pbChangeForm(1, _INTL("{1} transcended its limits and transformed!", user.pbThis))
    end

    def getEffectScore(user, target)
        score = super
        score += 100
        score += 50 if user.firstTurn?
        return score
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        if @chargingTurn && !@damagingTurn
            @battle.pbCommonAnimation("StatUp", user)
        else
            @battle.pbCommonAnimation("MegaEvolution", user)
            super
        end
    end
end

#===============================================================================
# Target drops its item and is forced to hold a Black Sludge. (Trash Treasure)
# Also lower's the target's Sp. Def.
#===============================================================================
class PokeBattle_Move_5A8 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.item == :BLACKSLUDGE
            if show_message
                @battle.pbDisplay(_INTL("But {1} is already holding a Black Sludge!",
target.pbThis(true)))
            end
            return true
        end
        return !canRemoveItem?(user, target)
    end

    def pbFailsAgainstTargetAI?(user, target)
        return true if target.item == :BLACKSLUDGE
        return !canRemoveItem?(user, target, true)
    end

    def pbEffectAgainstTarget(user, target)
        if target.item
            itemName = target.itemName
            removalMessage = _INTL("{1} dropped its {2}!", target.pbThis, itemName)
            removeItem(user, target, false, removalMessage)
        end
        target.item = :BLACKSLUDGE
        @battle.pbDisplay(_INTL("{1} was forced to hold a {2}!", target.pbThis, target.itemName))
        target.tryLowerStat(:SPECIAL_DEFENSE, user, move: self)
    end
end

#===============================================================================
# Power increases by 20 for each consecutive use. User heals by 50% of damage dealt. (Hearth Rhythm)
#===============================================================================
class PokeBattle_Move_5A9 < PokeBattle_SnowballingMove
    def initialize(battle, move)
        @usageCountEffect = :HeartRhythm
        super
    end

    def damageAtCount(baseDmg, count)
        return baseDmg + 20 * count
    end

    def healingMove?; return true; end

    def drainFactor(_user, _target); return 0.5; end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.hpLost <= 0
        hpGain = (target.damageState.hpLost * drainFactor(user, target)).round
        user.pbRecoverHPFromDrain(hpGain, target)
    end
end

#===============================================================================
# Reduce's the target's highest attacking stat. (Scale Glint)
#===============================================================================
class PokeBattle_Move_5AF < PokeBattle_TargetMultiStatDownMove
    def pbAdditionalEffect(user, target)
        if target.pbAttack > target.pbSpAtk
            target.pbLowerMultipleStatStages(:ATTACK, user, move: self)
        else
            target.pbLowerMultipleStatStages(:SPECIAL_ATTACK, user, move: self)
        end
    end
end

#===============================================================================
# User's Defense and Sp. Def are raised. Then, it heals itself based on (Refurbish)
# current weight. Then, its current weigtht is cut in half.
#===============================================================================
class PokeBattle_Move_5AB < PokeBattle_HealingMove
    def pbMoveFailed?(user, _targets, show_message)
        if user.hp == user.totalhp && !user.pbCanRaiseStatStage?(:DEFENSE, user, self) &&
           !user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, user, self)
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end

    def healRatio(user)
        case user.pbWeight
        when 1024..999_999
            return 1.0
        when 512..1023
            return 0.75
        when 256..511
            return 0.5
        when 128..255
            return 0.25
        when 64..127
            return 0.125
        else
            return 0.0625
        end
    end

    def pbEffectGeneral(user)
        user.pbRaiseMultipleStatStages([:DEFENSE, 1, :SPECIAL_DEFENSE, 1], user, move: self)
        super
        user.incrementEffect(:Refurbished)
    end
end

#===============================================================================
# Leeches or numbs the target, depending on how its speed compares to the user.
# (Mystery Seed)
#===============================================================================
class PokeBattle_Move_5AC < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if !target.canLeech?(user, show_message, self) && !target.canNumb?(user, show_message, self)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can neither be leeched or numbed!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        leechOrNumb(user, target)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        leechOrNumb(user, target)
    end

    def leechOrNumb(user, target)
        target_speed = target.pbSpeed
        user_speed = user.pbSpeed

        if target.canNumb?(user, false, self) && target_speed >= user_speed
            target.applyNumb(user)
        elsif target.canLeech?(user, false, self) && user_speed >= target_speed
            target.applyLeeched(user)
        end
    end

    def getEffectScore(user, target)
        target_speed = target.pbSpeed
        user_speed = user.pbSpeed

        if target.canNumb?(user, false, self) && target_speed >= user_speed
            return getNumbEffectScore(user, target)
        elsif target.canLeech?(user, false, self) && user_speed >= target_speed
            return getLeechEffectScore(user, target)
        end
    end
end
