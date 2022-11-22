class PokeBattle_AI
    #=============================================================================
    #
    #=============================================================================
    def pbTargetsMultiple?(move,user)
      target_data = move.pbTarget(user)
      return false if target_data.num_targets <= 1
      num_targets = 0
      case target_data.id
      when :UserAndAllies
        @battle.eachSameSideBattler(user) { |_b| num_targets += 1 }
      when :AllNearFoes
        @battle.eachOtherSideBattler(user) { |b| num_targets += 1 if b.near?(user) }
      when :AllFoes
        @battle.eachOtherSideBattler(user) { |_b| num_targets += 1 }
      when :AllNearOthers
        @battle.eachBattler { |b| num_targets += 1 if b.near?(user) }
      when :AllBattlers
        @battle.eachBattler { |_b| num_targets += 1 }
      end
      return num_targets > 1
    end
  
 
    def pbCalcTypeModAI(moveType,user,target,move)
        return Effectiveness::NORMAL_EFFECTIVE if !moveType
        return Effectiveness::NORMAL_EFFECTIVE if moveType == :GROUND &&
           target.pbHasTypeAI?(:FLYING) && target.hasActiveItem?(:IRONBALL)
        # Determine types
        tTypes = target.pbTypesAI(true)
        # Get effectivenesses
        typeMods = [Effectiveness::NORMAL_EFFECTIVE_ONE] * 3   # 3 types max
        if moveType == :SHADOW
          if target.shadowPokemon?
            typeMods[0] = Effectiveness::NOT_VERY_EFFECTIVE_ONE
          else
            typeMods[0] = Effectiveness::SUPER_EFFECTIVE_ONE
          end
        else
          tTypes.each_with_index do |defType,i|
            typeMods[i] = move.pbCalcTypeModSingle(moveType,defType,user,target)
          end
        end
        # Multiply all effectivenesses together
        ret = 1
        typeMods.each { |m| ret *= m }
        return ret
      end
  
    # For switching. Determines the effectiveness of a potential switch-in against
    # an opposing battler.
    def pbCalcTypeModPokemon(battlerThis,_battlerOther)
        mod1 = Effectiveness.calculate(battlerThis.type1,_battlerOther.type1,_battlerOther.type2)
        mod2 = Effectiveness::NORMAL_EFFECTIVE
        if battlerThis.type1 != battlerThis.type2
            mod2 = Effectiveness.calculate(battlerThis.type2,_battlerOther.type1,_battlerOther.type2)
            mod2 = mod2.to_f / Effectiveness::NORMAL_EFFECTIVE
        end
        return mod1*mod2
    end

    def moveFailureAlert(move,user,target,failureMessage)
        echoln("#{user.pbThis(true)} thinks that move #{move.id} against target #{target.pbThis(true)} will fail due to #{failureMessage}")
    end
  
    #=============================================================================
    # Immunity to a move because of the target's ability, item or other effects
    #=============================================================================
    def pbCheckMoveImmunity(score,move,user,target,skill)
        type = pbRoughType(move,user,skill)
        typeMod = pbCalcTypeModAI(type,user,target,move)
        # Type effectiveness
        if (Effectiveness.ineffective?(typeMod) && !move.statusMove?)
            moveFailureAlert(move,user,target,"inneffective type mod")
            return true
        end
        # Immunity due to ability/item/other effects
        case type
        when :GROUND
            if target.airborne? && !move.hitsFlyingTargets?
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :FIRE
            if target.hasActiveAbility?([:FLASHFIRE,:FINESUGAR])
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :WATER
            if target.hasActiveAbility?([:DRYSKIN,:STORMDRAIN,:WATERABSORB])
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :GRASS
            if target.hasActiveAbility?(:SAPSIPPER)
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :ELECTRIC
            if target.hasActiveAbility?([:LIGHTNINGROD,:MOTORDRIVE,:VOLTABSORB])
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :ICE
            if target.hasActiveAbility?(:COLDRECEPTION)
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :DRAGON
            if target.hasActiveAbility?(:DRAGONSLAYER)
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :FLYING
            if target.hasActiveAbility?(:PECKINGORDER)
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :STEEL
            if target.hasActiveAbility?(:INDUSTRIALIZE)
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :FLYING
            if target.hasActiveAbility?(:AERODYNAMIC)
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :POISON
            if target.hasActiveAbility?(:POISONABSORB)
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :FIGHTING
            if target.hasActiveAbility?(:CHALLENGER)
                moveFailureAlert(move,user,target,"immunity ability")
                return true 
            end
        when :DARK
            if target.hasActiveAbility?(:HEARTOFJUSTICE)
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        when :FAIRY
            if target.hasActiveAbility?(:HEARTLESS)
                moveFailureAlert(move,user,target,"immunity ability")
                return true
            end
        end
        if Effectiveness.not_very_effective?(typeMod) && target.hasActiveAbility?(:WONDERGUARD)
            moveFailureAlert(move,user,target,"wonder guard immunity")
            return true
        end
        if move.damagingMove? && user.index!=target.index && !target.opposes?(user) && target.hasActiveAbility?(:TELEPATHY)
            moveFailureAlert(move,user,target,"telepathy ally immunity")
            return true
        end
        if move.canMagicCoat? && target.hasActiveAbility?([:MAGICBOUNCE,:MAGICSHIELD]) && target.opposes?(user)
            moveFailureAlert(move,user,target,"magic coat/bounce immunity")
            return true
        end
        # Account for magic bounc bouncing back side-effecting moves
        if move.canMagicCoat? && target == user
            user.eachOpposing do |b|
                if b.hasActiveAbility?([:MAGICBOUNCE,:MAGICSHIELD])
                moveFailureAlert(move,user,target,"magic bounce whole side immunity")
                return true
                end
            end
        end
        if move.soundMove? && target.hasActiveAbility?(:SOUNDPROOF)
            moveFailureAlert(move,user,target,"soundproof immunity")
            return true
        end
        if move.bombMove? && target.hasActiveAbility?(:BULLETPROOF)
            moveFailureAlert(move,user,target,"bulletproof immunity")
            return true
        end
        if move.powderMove?
            if target.pbHasTypeAI?(:GRASS)
                moveFailureAlert(move,user,target,"grass powder immunity")
                return true
            end
            if target.hasActiveAbility?(:OVERCOAT)
                moveFailureAlert(move,user,target,"overcoat powder immunity")
                return true
            end
            if target.hasActiveItem?(:SAFETYGOGGLES)
                moveFailureAlert(move,user,target,"safety-goggles powder immunity")
                return true
            end
        end
        if target.substituted? && move.statusMove? && !move.ignoresSubstitute?(user) && user.index != target.index
            moveFailureAlert(move,user,target,"substitute immunity to most status moves")
            return true
        end
        if user.hasActiveAbility?(:PRANKSTER) && target.pbHasTypeAI?(:DARK) && target.opposes?(user) && move.statusMove?
            moveFailureAlert(move,user,target,"dark immunity to prankster boosted moves")
            return true
        end
        if move.priority > 0 && @battle.field.terrain == :Psychic && target.affectedByTerrain?(true) && target.opposes?(user)
            moveFailureAlert(move,user,target,"psychic terrain prevention of priority")
            return true
        end
        return false
    end
  
    #=============================================================================
    # Get a move's base damage value
    #=============================================================================
    def pbMoveBaseDamageAI(move,user,target,skill)
      baseDmg = move.baseDamage
      baseDmg,isFixedDamage = move.pbBaseDamageAI(baseDmg,user,target,skill)
      return baseDmg
    end
  
    #=============================================================================
    # Damage calculation
    #=============================================================================
    def pbTotalDamageAI(move,user,target,skill,baseDmg)
        # Get the move's type
        type = pbRoughType(move,user,skill)

        # Give the move a chance to change itself to phys or spec
        move.calculated_category = move.calculateCategory(user, [target])

        # Get the relevant attacking and defending stat values (after stages)
        attack, defense = move.damageCalcStats(user,target,true)

        ##### Calculate all multiplier effects #####
        multipliers = move.initializeMultipliers

        # Ability effects that alter damage
        moldBreaker = user.hasMoldBreaker?

        # TODO: Seperate abilities and items that increase damage based on the move or target chosen
        # Away from stuff that the AI could not possibly predict
        # So that it can be used here and that other stuff would not be

        if !moldBreaker && target.abilityActive?
          # NOTE: These abilities aren't suitable for checking at the start of the
          #       round.
          abilityBlacklist = [:FILTER,:SOLIDROCK]
          canCheck = true
          abilityBlacklist.each do |m|
              next if move.id != m
              canCheck = false
              break
          end
          if canCheck
              BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
              user,target,move,multipliers,baseDmg,type)
          end
        end

        if !moldBreaker
          target.eachAlly do |b|
              next if !b.abilityActive?
              BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
                user,target,move,multipliers,baseDmg,type)
          end
        end

        # Item effects that alter damage
        # NOTE: Type-boosting gems aren't suitable for checking at the start of the
        #       round.
        if user.itemActive?
          # NOTE: These items aren't suitable for checking at the start of the
          #       round.
          itemBlacklist = [:EXPERTBELT,:LIFEORB]
          if !itemBlacklist.include?(user.item_id) && user.item && !user.item.is_gem? && !user.item.is_berry?
              BattleHandlers.triggerDamageCalcUserItem(user.item,
              user,target,move,multipliers,baseDmg,type)
          end
        end

        if target.itemActive?
          # NOTE: Type-weakening berries aren't suitable for checking at the start
          #       of the round.
          if target.item && !target.item.is_berry?
              BattleHandlers.triggerDamageCalcTargetItem(target.item,
              user,target,move,multipliers,baseDmg,type)
          end
        end

        # Global abilities
        if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
              (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
            if @battle.pbCheckGlobalAbility(:AURABREAK)
              multipliers[:base_damage_multiplier] *= 2 / 3.0
            else
              multipliers[:base_damage_multiplier] *= 4 / 3.0
            end
        end

        # Parental Bond
        if user.hasActiveAbility?(:PARENTALBOND)
          multipliers[:base_damage_multiplier] *= 1.25
        end

        # Multi-targeting attacks
        if pbTargetsMultiple?(move,user)
            multipliers[:final_damage_multiplier] *= 0.75
        end

        # Type effectiveness
        typemod = pbCalcTypeModAI(type,user,target,move) / Effectiveness::NORMAL_EFFECTIVE.to_f
        multipliers[:final_damage_multiplier] *= typemod.to_f 

        # Terrain
        move.pbCalcTerrainDamageMultipliers(user,target,type,multipliers,true)

        # Weather
        move.pbCalcWeatherDamageMultipliers(user,target,type,multipliers,true)

        # STAB, etc.
        # This skips type effectiveness checks when calling for the AI
        # Due to that otherwise relying on damage state
        move.pbCalcTypeBasedDamageMultipliers(user,target,type,multipliers,true)
        
        # Statuses
        move.pbCalcStatusesDamageMultipliers(user,target,multipliers,true)

        # Light Screen, etc.
        move.pbCalcProtectionsDamageMultipliers(user,target,multipliers,true)

        # Move-specific final damage modifiers
        baseDmg = move.pbModifyDamage(baseDmg,user,target)

        ##### Main damage calculation #####
        damage = move.calcDamageWithMultipliers(baseDmg,attack,defense,user.level,multipliers)

        criticalHitRate = move.pbIsCritical?(user,target,true)

        if criticalHitRate >= 0
          criticalHitRate = 5 if criticalHitRate > 5
          damage += damage * 0.1 * criticalHitRate
        end

        numHits = move.pbNumHitsAI(user,target,skill)
        totalDamage = damage * numHits
                
        return totalDamage.floor
    end
  
   #===========================================================================
    # Accuracy calculation
    #===========================================================================
    def pbRoughAccuracy(move,user,target,skill)
        return 100 if target.effectActive?(:Telekinesis)
        baseAcc = move.accuracy
        return 100 if baseAcc == 0
        baseAcc = move.pbBaseAccuracy(user,target)
        return 100 if baseAcc == 0
        # Get the move's type
        type = pbRoughType(move,user,skill)
        # Calculate all modifier effects
        modifiers = {}
        modifiers[:base_accuracy]  = baseAcc
        modifiers[:accuracy_stage] = user.stages[:ACCURACY]
        modifiers[:evasion_stage]  = target.stages[:EVASION]
        modifiers[:accuracy_multiplier] = 1.0
        modifiers[:evasion_multiplier]  = 1.0
        pbCalcAccuracyModifiers(user,target,modifiers,move,type,skill)
        # Calculation
        accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
        evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
        stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
        stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
        accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
        evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
        accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
        evasion  = (evasion  * modifiers[:evasion_multiplier]).round
        evasion = 1 if evasion<1
        # Value always hit moves if otherwise would be hard to hit here
        if modifiers[:base_accuracy] == 0
        return (accuracy / evasion < 1) ? 125 : 100
        end
        return modifiers[:base_accuracy] * accuracy / evasion
    end
  
    def pbCalcAccuracyModifiers(user,target,modifiers,move,type,skill)
      moldBreaker = false
      if target.hasMoldBreaker?
        moldBreaker = true
      end
      if user.abilityActive?
        BattleHandlers.triggerAccuracyCalcUserAbility(user.ability,
           modifiers,user,target,move,type)
      end
      user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerAccuracyCalcUserAllyAbility(b.ability,
           modifiers,user,target,move,type)
      end
      if target.abilityActive? && !moldBreaker
        BattleHandlers.triggerAccuracyCalcTargetAbility(target.ability,
           modifiers,user,target,move,type)
      end
      # Item effects that alter accuracy calculation
      if user.itemActive?
        BattleHandlers.triggerAccuracyCalcUserItem(user.item,
           modifiers,user,target,move,type)
      end
      if target.itemActive?
        BattleHandlers.triggerAccuracyCalcTargetItem(target.item,
           modifiers,user,target,move,type)
      end
      # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to specific values
      if @battle.field.effectActive?(:Gravity)
        modifiers[:accuracy_multiplier] *= 5/3.0
      end
      if user.effectActive?(:MicleBerry)
        modifiers[:accuracy_multiplier] *= 1.2
      end
      modifiers[:evasion_stage] = 0 if target.effectActive?(:MiracleEye) && modifiers[:evasion_stage] > 0
      modifiers[:evasion_stage] = 0 if target.effectActive?(:Foresight) && modifiers[:evasion_stage] > 0
      # "AI-specific calculations below"
      modifiers[:evasion_stage] = 0 if move.function == "0A9"   # Chip Away
      modifiers[:base_accuracy] = 0 if ["0A5", "139", "13A", "13B", "13C",   # "Always hit"
                                        "147"].include?(move.function)
      modifiers[:base_accuracy] = 0 if user.effectActive?(:LockOn) && user.pointsAt?(:LockOnPos,target)
    end
  end
  