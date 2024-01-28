#===============================================================================
# User is protected against moves with the "B" flag this round. (Detect, Protect)
#===============================================================================
class PokeBattle_Move_0AA < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :Protect
    end
end

#===============================================================================
# User's side is protected against moves with priority greater than 0 this round.
# (Quick Guard)
#===============================================================================
class PokeBattle_Move_0AB < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect      = :QuickGuard
        @sidedEffect = true
    end
end

#===============================================================================
# User's side is protected against moves that target multiple battlers this round.
# (Wide Guard)
#===============================================================================
class PokeBattle_Move_0AC < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect      = :WideGuard
        @sidedEffect = true
    end
end

#===============================================================================
# User's side is protected against moves that target multiple battlers this round.
# This round, user becomes the target of attacks that have single targets.
# (Omnishelter)
#===============================================================================
class PokeBattle_Move_5BF < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect      = :WideGuard
        @sidedEffect = true
    end

    def pbEffectGeneral(user)
        super
        maxFollowMe = 0
        user.eachAlly do |b|
            next if b.effects[:FollowMe] <= maxFollowMe
            maxFollowMe = b.effects[:FollowMe]
        end
        user.applyEffect(:FollowMe, maxFollowMe + 1)
    end

    def getEffectScore(user, _target)
        score = 0
        user.eachPredictedProtectHitter do |b|
            score += 50 if user.hasAlly?
            score += 50 if b.poisoned?
            score += 50 if b.leeched?
            score += 30 if b.burned?
            score += 30 if b.frostbitten?
        end
        score /= 2
        if user.hasAlly?
            score += 50
            score += 25 if user.aboveHalfHealth?
        end
        return score
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
# If user would be KO'd this round, it survives with 1 HP instead. (Endure)
#===============================================================================
class PokeBattle_Move_0E8 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :Endure
    end

    def pbProtectMessage(user)
        @battle.pbDisplay(_INTL("{1} braced itself!", user.pbThis))
    end

    def getEffectScore(user, target)
        return 0 if user.aboveHalfHealth?
        return super / 2
    end
end

#===============================================================================
# If user would be KO'd this round, it survives with 1 HP instead. (Fight Forever)
# Then, it's Attack is raised by 2
#===============================================================================
class PokeBattle_Move_094 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :FightForever
    end

    def pbProtectMessage(user)
        @battle.pbDisplay(_INTL("{1} braced itself!", user.pbThis))
    end

    def getEffectScore(user, target)
        return 0 if user.aboveHalfHealth?
        return super
    end
end

#===============================================================================
# User is protected against damaging moves this round. Decreases the Attack of
# the user of a stopped physical move by 1 step. (King's Shield)
#===============================================================================
class PokeBattle_Move_14B < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :KingsShield
    end

    def getEffectScore(user, target)
        score = super
        # Check only physical attackers
        user.eachPredictedProtectHitter(0) do |b|
            score += getMultiStatDownEffectScore([:ATTACK,1],user,b)
        end
        return score
    end
end

#===============================================================================
# User is protected against damaging moves this round. Decreases the Sp. Atk of
# the user of a stopped special move by 1 step. (Shield Shell)
#===============================================================================
class PokeBattle_Move_5BB < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :ShiningShell
    end

    def getEffectScore(user, target)
        score = super
        # Check only special attackers
        user.eachPredictedProtectHitter(1) do |b|
            score += getMultiStatDownEffectScore([:SPECIAL_ATTACK,1],user,b)
        end
        return score
    end
end

#===============================================================================
# User is protected against damaging moves this round. Decreases the Defense of
# the user of a stopped physical move by 2 steps. (Obstruct)
#===============================================================================
class PokeBattle_Move_180 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :Obstruct
    end
end

#===============================================================================
# User is protected against damaging moves this round. Decreases the Sp. Def of
# the user of a stopped special move by 2 steps. (Reverb Ward)
#===============================================================================
class PokeBattle_Move_5AE < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :ReverbWard
    end
end

#===============================================================================
# User is protected against moves that target it this round. Damages the user of
# a stopped physical move by 1/8 of its max HP. (Spiky Shield)
#===============================================================================
class PokeBattle_Move_14C < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :SpikyShield
    end

    def getEffectScore(user, target)
        score = super
        # Check only physical attackers
        user.eachPredictedProtectHitter(0) do |_b|
            score += 20
        end
        return score
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
        user.eachPredictedProtectHitter(1) do |_b|
            score += 20
        end
        return score
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks with the user with a special attack while this effect applies, that Pokémon is
# burned. (Red-Hot Retreat)
#===============================================================================
class PokeBattle_Move_567 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :RedHotRetreat
    end

    def getEffectScore(user, target)
        score = super
        # Check only special attackers
        user.eachPredictedProtectHitter(1) do |b|
            score += getBurnEffectScore(user, b)
        end
        return score
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks with the user with a physical attack while this effect applies, that Pokémon is
# frostbitten. (Icicle Armor)
#===============================================================================
class PokeBattle_Move_57E < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :IcicleArmor
    end

    def getEffectScore(user, target)
        score = super
        # Check only physical attackers
        user.eachPredictedProtectHitter(0) do |b|
            score += getFrostbiteEffectScore(user, b)
        end
        return score
    end
end

#===============================================================================
# User's side is protected against status moves this round. Disables the last used move
# of the opposing user for 3 turns. (Quarantine)
#===============================================================================
class PokeBattle_Move_156 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :Quarantine
        @sidedEffect = true
    end

    def pbProtectMessage(user)
        @battle.pbDisplay(_INTL("{1} put up a quarantine!", user.pbThis))
    end

    def getEffectScore(user, target)
        score = super
        user.eachPredictedTargeter(2) do |b|
            score += getDisableEffectScore(target, 3)
        end
        return score
    end
end

#===============================================================================
# User is protected against damaging moves this round. Counterattacks (Cranial Guard)
# with Granite Head.
#===============================================================================
class PokeBattle_Move_155 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :CranialGuard
    end

    def getEffectScore(user, target)
        score = super
        # Check only physical attackers
        user.eachPredictedProtectHitter do |b|
            score += 100
        end
        return score
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks the user while this effect applies, that Pokémon becomes numbed.
# (Stunning Curl)
#===============================================================================
class PokeBattle_Move_550 < PokeBattle_HalfProtectMove
    def initialize(battle, move)
        super
        @effect = :StunningCurl
    end

    def getOnHitEffectScore(user,target)
        return getNumbEffectScore(user, target)
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks the user while this effect applies, that Pokémon become leeched.
# (Root Haven)
#===============================================================================
class PokeBattle_Move_5A5 < PokeBattle_HalfProtectMove
    def initialize(battle, move)
        super
        @effect = :RootShelter
    end

    def getOnHitEffectScore(user,target)
        return getLeechEffectScore(user, target)
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks the user while this effect applies, that Pokémon becomes poisoned.
# (Venom Guard)
#===============================================================================
class PokeBattle_Move_57F < PokeBattle_HalfProtectMove
    def initialize(battle, move)
        super
        @effect = :VenomGuard
    end

    def getOnHitEffectScore(user,target)
        return getPoisonEffectScore(user, target)
    end
end

#===============================================================================
# Creates a bubble to shield the target. The next time they’re attacked, (Bubble Barrier)
# 50% of the move damage is instead dealt to the attacker
#===============================================================================
class PokeBattle_Move_196 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def hitsInvulnerable?; return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.fainted?
            @battle.pbDisplay(_INTL("But it failed, since the receiver of the barrier is gone!")) if show_message
            return true
        end
        if target.effectActive?(:BubbleBarrier)
            @battle.pbDisplay(_INTL("But it failed, since #{arget.pbThis(true)} is already protected by a bubble!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:BubbleBarrier)
    end

    def getEffectScore(_user, target)
        score = 50
        score += 50 if target.aboveHalfHealth?
        return score
    end
end