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
    # Get a move's base damage value
    #=============================================================================
    def pbMoveBaseDamageAI(move,user,target)
      baseDmg = move.baseDamage
      baseDmg = move.pbBaseDamageAI(baseDmg,user,target)
      return baseDmg
    end
  
    #=============================================================================
    # Damage calculation
    #=============================================================================
    def pbTotalDamageAI(move,user,target,numTargets=1)
        # Get the move's type
        type = pbRoughType(move,user)

        baseDmg = pbMoveBaseDamageAI(move,user,target)

        # Calculate the damage for one hit
        damage = move.calculateDamageForHit(user,target,type,baseDmg,numTargets,true)

        # Estimate how many hits the move will do
        numHits = move.numberOfHits(user,[target],true)

        # Calculate the total estimated damage of all hits
        totalDamage = damage * numHits
                
        return totalDamage.floor
    end
  
   #===========================================================================
    # Accuracy calculation
    #===========================================================================
    def pbRoughAccuracy(move,user,target)
        return 100 if target.effectActive?(:Telekinesis)
        baseAcc = move.accuracy
        return 100 if baseAcc == 0
        baseAcc = move.pbBaseAccuracy(user,target)
        return 100 if baseAcc == 0
        # Get the move's type
        type = pbRoughType(move,user)
        # Calculate all modifier effects
        modifiers = {}
        modifiers[:base_accuracy]  = baseAcc
        modifiers[:accuracy_stage] = user.stages[:ACCURACY]
        modifiers[:evasion_stage]  = target.stages[:EVASION]
        modifiers[:accuracy_multiplier] = 1.0
        modifiers[:evasion_multiplier]  = 1.0
        pbCalcAccuracyModifiers(user,target,modifiers,move,type)
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
  
    def pbCalcAccuracyModifiers(user,target,modifiers,move,type)
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
  