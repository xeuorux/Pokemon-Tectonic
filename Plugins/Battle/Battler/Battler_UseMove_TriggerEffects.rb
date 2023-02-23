class PokeBattle_Battler
    #=============================================================================
    # Effect per hit
    #=============================================================================
    def pbEffectsOnMakingHit(move, user, target)
        if target.damageState.calcDamage > 0 && !target.damageState.substitute
            # Target's ability
            if target.abilityActive?(true) && !user.hasActiveItem?(:PROXYFIST)
                oldHP = user.hp
                BattleHandlers.triggerTargetAbilityOnHit(target.ability, user, target, move, @battle)
                user.pbItemHPHealCheck if user.hp < oldHP
            end
            # User's ability
            if user.abilityActive?(true)
                BattleHandlers.triggerUserAbilityOnHit(user.ability, user, target, move, @battle)
                user.pbItemHPHealCheck
            end
            # Target's item
            if target.itemActive?(true) && !user.hasActiveItem?(:PROXYFIST)
                oldHP = user.hp
                BattleHandlers.triggerTargetItemOnHit(target.item, user, target, move, @battle)
                user.pbItemHPHealCheck if user.hp < oldHP
            end
        end
        if target.opposes?(user) && !user.hasActiveItem?(:PROXYFIST)
            # Rage
            if target.effectActive?(:Rage) && !target.fainted? && target.tryRaiseStat(:ATTACK, target)
                @battle.pbDisplay(_INTL("{1}'s rage is building!", target.pbThis))
            end
            # Beak Blast
            if target.effectActive?(:BeakBlast)
                PBDebug.log("[Lingering effect] #{target.pbThis}'s Beak Blast")
                user.applyBurn(target) if move.physicalMove? && user.canBurn?(target, false, self)
            end
            # Shell Trap (make the trapper move next if the trap was triggered)
            if target.effectActive?(:ShellTrap) && @battle.choices[target.index][0] == :UseMove && !target.movedThisRound? && (target.damageState.hpLost > 0 && !target.damageState.substitute && move.physicalMove?)
                target.tookPhysicalHit = true
                target.applyEffect(:MoveNext)
            end
            # Grudge
            if target.effectActive?(:Grudge) && target.fainted?
                move.pp = 0
                @battle.pbDisplay(_INTL("{1}'s {2} lost all of its PP due to the grudge!",
                                                                                                                user.pbThis, move.name))
            end
            # Destiny Bond (recording that it should apply)
            if target.effectActive?(:DestinyBond) && target.fainted? && !target.effectActive?(:DestinyBondTarget)
                applyEffect(:DestinyBondTarget, target.index)
            end
            # Stunning Curl
            if target.effectActive?(:StunningCurl) && !user.numbed?
                PBDebug.log("[Lingering effect] #{target.pbThis}'s Stunning Curl")
                if user.canNumb?(target, false)
                    @battle.pbDisplay(_INTL("{1}'s stance made {2}'s attack bounce off akwardly!", target.pbThis,
user.pbThis(true)))
                    user.applyNumb(target)
                end
            end
            # Root Shelter
            if target.effectActive?(:RootShelter) && !user.leeched?
                PBDebug.log("[Lingering effect] #{target.pbThis}'s Root Shelter")
                if user.canLeech?(target, false)
                    @battle.pbDisplay(_INTL("The roots guarding {1} dig into {2}!", target.pbThis(true),
user.pbThis(true)))
                    user.applyLeeched(target)
                end
            end
            # Venom Guard
            if target.effectActive?(:VenomGuard) && !user.poisoned?
                PBDebug.log("[Lingering effect] #{target.pbThis}'s Venom Guard")
                if user.canPoison?(target, false)
                    @battle.pbDisplay(_INTL("{1} was stuck by {2}'s venom!", user.pbThis, user.pbThis(true)))
                    user.applyPoison(target)
                end
            end
        end
    end

    #=============================================================================
    # Effects after all hits (i.e. at end of move usage)
    #=============================================================================
    def pbEffectsAfterMove(user, targets, move, numHits)
        # Destiny Bond
        # NOTE: Although Destiny Bond is similar to Grudge, they don't apply at
        #       the same time (although Destiny Bond does check whether it's going
        #       to trigger at the same time as Grudge).
        if user.effectActive?(:DestinyBondTarget) && !user.fainted?
            dbName = @battle.battlers[user.effects[:DestinyBondTarget]].pbThis
            @battle.pbDisplay(_INTL("{1} took its attacker down with it!", dbName))
            user.pbReduceHP(user.hp, false)
            user.pbFaint
            @battle.pbJudgeCheckpoint(user)
        end
        # User's ability
        switchedBattlers = []
        if user.abilityActive?
            BattleHandlers.triggerUserAbilityEndOfMove(user.ability, user, targets, move, @battle,
switchedBattlers)
        end
        # Greninja - Battle Bond
        if !user.fainted? && !effectActive?(:Transform) &&
           user.isSpecies?(:GRENINJA) && user.ability == :BATTLEBOND && (!@battle.pbAllFainted?(user.idxOpposingSide) &&
                        !@battle.battleBond[user.index & 1][user.pokemonIndex])
            numFainted = 0
            targets.each { |b| numFainted += 1 if b.damageState.fainted }
            if numFainted > 0 && user.form == 1
                @battle.battleBond[user.index & 1][user.pokemonIndex] = true
                @battle.pbDisplay(_INTL("{1} became fully charged due to its bond with its Trainer!", user.pbThis))
                @battle.pbShowAbilitySplash(user, true)
                @battle.pbHideAbilitySplash(user)
                user.pbChangeForm(2, _INTL("{1} became Ash-Greninja!", user.pbThis))
            end
        end
        # Consume user's Gem
        if user.effectActive?(:GemConsumed)
            # NOTE: The consume animation and message for Gems are shown immediately
            #       after the move's animation, but the item is only consumed now.
            user.pbConsumeItem
        end
        # Consume Volatile Toxin
        if move.pbDamagingMove?
            targets.each do |b|
                b.disableEffect(:VolatileToxin)
            end
        end
        # Pokémon switching caused by Roar, Whirlwind, Circle Throw, Dragon Tail
        move.pbSwitchOutTargetsEffect(user, targets, numHits, switchedBattlers)
        # Target's item, user's item, target's ability (all negated by Sheer Force)
        if user.hasActiveAbility?(:SHEERFORCE) && move.effectChance != 0
            # Skip other additional effects too if sheer force is being applied to the move
        else
            pbEffectsAfterMove2(user, targets, move, numHits, switchedBattlers)
        end
        # Ally Cushion
        if user.effectActive?(:AllyCushionSwap) && !switchedBattlers.include?(user.index)
            if @battle.triggeredSwitchOut(user.index, false)
                user.pbEffectsOnSwitchIn(true)
                switchedBattlers.push(user.index)
            else
                user.disableEffect(:AllyCushionSwap)
                user.position.disableEffect(:AllyCushion)
            end
        end
        # Some move effects that need to happen here, i.e. U-turn/Volt Switch
        # switching, Baton Pass switching, Parting Shot switching, Relic Song's form
        # changing, Fling/Natural Gift consuming item.
        unless switchedBattlers.include?(user.index)
            move.pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
        end
        @battle.eachBattler { |b| b.pbItemEndOfMoveCheck } if numHits > 0
    end

    # Everything in this method is negated by Sheer Force.
    def pbEffectsAfterMove2(user, targets, move, numHits, switchedBattlers)
        hpNow = user.hp # Intentionally determined now, before Shell Bell
        # Target's held item (Eject Button, Red Card)
        switchByItem = []
        @battle.pbPriority(true).each do |b|
            next unless targets.any? { |targetB| targetB.index == b.index }
            next if b.damageState.unaffected || b.damageState.calcDamage == 0 ||
                    switchedBattlers.include?(b.index)
            next unless b.itemActive?
            BattleHandlers.triggerTargetItemAfterMoveUse(b.item, b, user, move, switchByItem, @battle)
            # Eject Pack
            if b.effectActive?(:StatsDropped)
                BattleHandlers.triggerItemOnStatLoss(b.item, b, user, move, switchByItem,
@battle)
            end
        end
        @battle.moldBreaker = false if switchByItem.include?(user.index)
        @battle.pbPriority(true).each do |b|
            b.pbEffectsOnSwitchIn(true) if switchByItem.include?(b.index)
        end
        switchByItem.each { |idxB| switchedBattlers.push(idxB) }
        # User's held item (Life Orb, Shell Bell)
        if !switchedBattlers.include?(user.index) && user.itemActive?
            BattleHandlers.triggerUserItemAfterMoveUse(user.item, user, targets, move, numHits,
@battle)
        end
        # Target's ability (Berserk, Color Change, Emergency Exit, Pickpocket, Wimp Out)
        switchWimpOut = []
        @battle.pbPriority(true).each do |b|
            next unless targets.any? { |targetB| targetB.index == b.index }
            next if b.damageState.unaffected || switchedBattlers.include?(b.index)
            next unless b.abilityActive?
            BattleHandlers.triggerTargetAbilityAfterMoveUse(b.ability, b, user, move, switchedBattlers, @battle)
            next unless !switchedBattlers.include?(b.index) && move.damagingMove?
            if b.pbAbilitiesOnDamageTaken(b.damageState.initialHP)
                switchWimpOut.push(b.index)
            end # Emergency Exit, Wimp Out
        end
        @battle.moldBreaker = false if switchWimpOut.include?(user.index)
        @battle.pbPriority(true).each do |b|
            next if b.index == user.index
            b.pbEffectsOnSwitchIn(true) if switchWimpOut.include?(b.index)
        end
        switchWimpOut.each { |idxB| switchedBattlers.push(idxB) }
        # User's ability (Emergency Exit, Wimp Out)
        if !switchedBattlers.include?(user.index) && move.damagingMove?
            hpNow = user.hp if user.hp < hpNow   # In case HP was lost because of Life Orb
            if user.pbAbilitiesOnDamageTaken(user.initialHP, hpNow)
                @battle.moldBreaker = false
                user.pbEffectsOnSwitchIn(true)
                switchedBattlers.push(user.index)
            end
        end
    end
end
