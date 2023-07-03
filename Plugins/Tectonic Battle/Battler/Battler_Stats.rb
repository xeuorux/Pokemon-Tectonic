class PokeBattle_Battler
    def getPlainStat(stat)
        case stat
        when :ATTACK
            return attack
        when :DEFENSE
            return defense
        when :SPECIAL_ATTACK
            return spatk
        when :SPECIAL_DEFENSE
            return spdef
        when :SPEED
            return speed
        end
        return -1
    end

    def plainStats
        ret = {}
        ret[:ATTACK]          = attack
        ret[:DEFENSE]         = defense
        ret[:SPECIAL_ATTACK]  = spatk
        ret[:SPECIAL_DEFENSE] = spdef
        ret[:SPEED]           = speed
        if owner
            level = 0
            tribalStatBonuses = owner.tribalBonus.getTribeBonusStats(ownerLevelCap)
            ret[:ATTACK_TRIBAL] = tribalStatBonuses[:ATTACK]
            ret[:DEFENSE_TRIBAL] = tribalStatBonuses[:DEFENSE]
            ret[:SPECIAL_ATTACK_TRIBAL] = tribalStatBonuses[:SPECIAL_ATTACK]
            ret[:SPECIAL_DEFENSE_TRIBAL] = tribalStatBonuses[:SPECIAL_DEFENSE]
            ret[:SPEED_TRIBAL] = tribalStatBonuses[:SPEED]
        else
            ret[:ATTACK_TRIBAL] = 0
            ret[:DEFENSE_TRIBAL] = 0
            ret[:SPECIAL_ATTACK_TRIBAL] = 0
            ret[:SPECIAL_DEFENSE_TRIBAL] = 0
            ret[:SPEED_TRIBAL] = 0
        end
        return ret
    end

    def tribalBonusForStat(stat)
        return 0 unless owner
        return owner.tribalBonus.getTribeBonusStats(pokemon.level)[stat]
    end

    def puzzleRoom?
        return @battle.field.effectActive?(:PuzzleRoom)
    end

    def oddRoom?
        return @battle.field.effectActive?(:OddRoom)
    end

    def wonderRoom?
        return @battle.field.effectActive?(:WonderRoom)
    end

    def attack
        if puzzleRoom? && oddRoom?
            return base_special_defense
        elsif puzzleRoom? && !oddRoom?
            return base_special_attack
        elsif oddRoom? && !puzzleRoom?
            return base_defense
        else
            return base_attack
        end
    end

    def defense
        if wonderRoom? && oddRoom?
            return base_special_attack
        elsif wonderRoom? && !oddRoom?
            return base_special_defense
        elsif oddRoom? && !wonderRoom?
            return base_attack
        else
            return base_defense
        end
    end

    def spatk
        if puzzleRoom? && oddRoom?
            return base_defense
        elsif puzzleRoom? && !oddRoom?
            return base_attack
        elsif oddRoom? && !puzzleRoom?
            return base_special_defense
        else
            return base_special_attack
        end
    end

    def spdef
        if wonderRoom? && oddRoom?
            return base_attack
        elsif wonderRoom? && !oddRoom?
            return base_defense
        elsif oddRoom? && !wonderRoom?
            return base_special_attack
        else
            return base_special_defense
        end
    end

    OFFENSIVE_LOCK_STAT = 120

    DEFENSIVE_LOCK_STAT = 95

    def speed
        return base_speed
    end

    # Don't use for HP
    def recalcStat(stat, base)
        return calcStatGlobal(base, @level, @pokemon.ev[stat], hasActiveAbility?(:STYLISH))
    end

    def base_attack
        return @effects[:BaseAttack] if effectActive?(:BaseAttack)
        attack_bonus = tribalBonusForStat(:ATTACK)
        if hasActiveItem?(%i[POWERLOCK POWERKEY])
            return recalcStat(:ATTACK, OFFENSIVE_LOCK_STAT) + attack_bonus
        else
            return @attack + attack_bonus
        end
    end

    def base_defense
        return @effects[:BaseDefense] if effectActive?(:BaseDefense)
        defense_bonus = tribalBonusForStat(:DEFENSE)
        if hasActiveItem?(:GUARDLOCK)
            return recalcStat(:DEFENSE, DEFENSIVE_LOCK_STAT) + defense_bonus
        elsif hasActiveItem?(:POWERKEY)
            return recalcStat(:DEFENSE, OFFENSIVE_LOCK_STAT) + defense_bonus
        else
            return @defense + defense_bonus
        end
    end

    def base_special_attack
        return @effects[:BaseSpecialAttack] if effectActive?(:BaseSpecialAttack)
        spatk_bonus = tribalBonusForStat(:SPECIAL_ATTACK)
        if hasActiveItem?(%i[ENERGYLOCK ENERGYKEY])
            return recalcStat(:SPECIAL_ATTACK, OFFENSIVE_LOCK_STAT) + spatk_bonus
        else
            return @spatk + spatk_bonus
        end
    end

    def base_special_defense
        return @effects[:BaseSpecialDefense] if effectActive?(:BaseSpecialDefense)
        spdef_bonus = tribalBonusForStat(:SPECIAL_DEFENSE)
        if hasActiveItem?(:WILLLOCK)
            return recalcStat(:SPECIAL_DEFENSE, DEFENSIVE_LOCK_STAT) + spdef_bonus
        elsif hasActiveItem?(:ENERGYKEY)
            return recalcStat(:SPECIAL_DEFENSE, OFFENSIVE_LOCK_STAT) + spdef_bonus
        else
            return @spdef + spdef_bonus
        end
    end

    def base_speed
        return @effects[:BaseSpeed] if effectActive?(:BaseSpeed)
        speed_bonus = tribalBonusForStat(:SPEED)
        return @speed + speed_bonus
    end

    #=============================================================================
    # Query about stats after room modification, steps, abilities and item modifiers.
    #=============================================================================
    AI_CHEATS_FOR_STAT_ABILITIES = true

    def pbAttack(aiChecking = false, step = -1)
        return 1 if fainted?
        attack = statAfterStep(:ATTACK, step)
        attackMult = 1.0

        eachActiveAbility do |ability|
            next if ignoreAbilityInAI?(ability,aiChecking) && !AI_CHEATS_FOR_STAT_ABILITIES
            attackMult = BattleHandlers.triggerAttackCalcUserAbility(ability, self, @battle, attackMult)
        end
        eachAlly do |ally|
            ally.eachActiveAbility do |ability|
                next if ally.ignoreAbilityInAI?(ability,aiChecking) && !AI_CHEATS_FOR_STAT_ABILITIES
                attackMult = BattleHandlers.triggerAttackCalcAllyAbility(ability, self, @battle, attackMult)
            end
        end

        eachActiveItem do |item|
            attackMult = BattleHandlers.triggerAttackCalcUserItem(item, self, battle, attackMult)
        end

        # Dragon Ride
        attackMult *= 2.0 if effectActive?(:OnDragonRide)

        # Calculation
        return [(attack * attackMult).round, 1].max
    end

    def pbSpAtk(aiChecking = false, step = -1)
        return 1 if fainted?
        special_attack = statAfterStep(:SPECIAL_ATTACK, step)
        spAtkMult = 1.0

        eachActiveAbility do |ability|
            next if ignoreAbilityInAI?(ability,aiChecking) && !AI_CHEATS_FOR_STAT_ABILITIES
            spAtkMult = BattleHandlers.triggerSpecialAttackCalcUserAbility(ability, self, @battle, spAtkMult)
        end
        eachAlly do |ally|
            ally.eachActiveAbility do |ability|
                next if ally.ignoreAbilityInAI?(ability,aiChecking) && !AI_CHEATS_FOR_STAT_ABILITIES
                spAtkMult = BattleHandlers.triggerSpecialAttackCalcAllyAbility(ability, self, @battle, spAtkMult)
            end
        end

        eachActiveItem do |item|
            spAtkMult = BattleHandlers.triggerSpecialAttackCalcUserItem(item, self, battle, spAtkMult)
        end

        # Calculation
        return [(special_attack * spAtkMult).round, 1].max
    end

    def pbDefense(aiChecking = false, step = -1)
        return 1 if fainted?
        defense = statAfterStep(:DEFENSE, step)
        defenseMult = 1.0

        eachActiveAbility do |ability|
            next if ignoreAbilityInAI?(ability,aiChecking) && !AI_CHEATS_FOR_STAT_ABILITIES
            defenseMult = BattleHandlers.triggerDefenseCalcUserAbility(ability, self, @battle, defenseMult)
        end
        eachAlly do |ally|
            ally.eachActiveAbility do |ability|
                next if ally.ignoreAbilityInAI?(ability,aiChecking) && !AI_CHEATS_FOR_STAT_ABILITIES
                defenseMult = BattleHandlers.triggerDefenseCalcAllyAbility(ability, self, @battle, defenseMult)
            end
        end

        eachActiveItem do |item|
            defenseMult = BattleHandlers.triggerDefenseCalcUserItem(item, self, battle, defenseMult)
        end
        
        defenseMult *= 1.2 if hasTribeBonus?(:SCRAPPER)

        # Calculation
        return [(defense * defenseMult).round, 1].max
    end

    def pbSpDef(aiChecking = false, step = -1)
        return 1 if fainted?
        special_defense = statAfterStep(:SPECIAL_DEFENSE, step)
        spDefMult = 1.0

        eachActiveAbility do |ability|
            next if ignoreAbilityInAI?(ability,aiChecking) && !AI_CHEATS_FOR_STAT_ABILITIES
            spDefMult = BattleHandlers.triggerSpecialDefenseCalcUserAbility(ability, self, @battle, spDefMult)
        end
        eachAlly do |ally|
            ally.eachActiveAbility do |ability|
                spDefMult = BattleHandlers.triggerSpecialDefenseCalcAllyAbility(ability, self, @battle, spDefMult)
            end
        end

        eachActiveItem do |item|
            spDefMult = BattleHandlers.triggerSpecialDefenseCalcUserItem(item, self, battle, spDefMult)
        end
        
        spDefMult *= 1.2 if hasTribeBonus?(:RADIANT)

        # Calculation
        return [(special_defense * spDefMult).round, 1].max
    end

    def pbSpeed(aiChecking = false, step = -1)
        return 1 if fainted?
        speed = statAfterStep(:SPEED, step)
        speedMult = 1.0

        eachActiveAbility do |ability|
            next if ignoreAbilityInAI?(ability,aiChecking) && !AI_CHEATS_FOR_STAT_ABILITIES
            speedMult = BattleHandlers.triggerSpeedCalcAbility(ability, self, speedMult)
        end

        # Item effects that alter calculated Speed
        eachActiveItem do |item|
            speedMult = BattleHandlers.triggerSpeedCalcItem(item, self, speedMult)
        end
        
        # Other effects
        speedMult *= 2 if pbOwnSide.effectActive?(:Tailwind)
        speedMult /= 2 if pbOwnSide.effectActive?(:Swamp)
        speedMult *= 2 if effectActive?(:OnDragonRide)
        speedMult *= 2 if @battle.curseActive?(:CURSE_BOOSTED_ELECTRIC) &&
                          @battle.field.terrain == :Electric && pbHasType?(:ELECTRIC)
        # Numb
        if !shouldAbilityApply?(:QUICKFEET, aiChecking) && numbed?
            speedMult /= 2
            speedMult /= 2 if pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
        end
        # Calculation
        return [(speed * speedMult).round, 1].max
    end

    def getFinalStat(stat, aiChecking = false, step = -1)
        case stat
        when :ATTACK
            return pbAttack(aiChecking, step)
        when :DEFENSE
            return pbDefense(aiChecking, step)
        when :SPECIAL_ATTACK
            return pbSpAtk(aiChecking, step)
        when :SPECIAL_DEFENSE
            return pbSpDef(aiChecking, step)
        when :SPEED
            return pbSpeed(aiChecking, step)
        end
        return -1
    end
end
