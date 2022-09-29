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
        if target.effects[PBEffects::Substitute] > 0 && move.statusMove? && !move.ignoresSubstitute?(user) && user.index != target.index
            moveFailureAlert(move,user,target,"substitute immunity to most status moves")
            return true
        end
        if user.hasActiveAbility?(:PRANKSTER) && target.pbHasTypeAI?(:DARK) && target.opposes?(user) && move.statusMove?
            moveFailureAlert(move,user,target,"dark immunity to prankster boosted status moves")
            return true
        end
        if move.priority > 0 && @battle.field.terrain == :Psychic && target.affectedByTerrain? && target.opposes?(user)
            moveFailureAlert(move,user,target,"psychic terrain prevention of priority")
            return true
        end
        return false
    end
  
    #=============================================================================
    # Get approximate properties for a battler
    #=============================================================================
    def pbRoughType(move,user,skill)
        return move.pbCalcType(user)
    end
  
    def pbRoughStatCalc(atkStat,atkStage)
        stageMul = PokeBattle_Battler::STAGE_MULTIPLIERS
        stageDiv = PokeBattle_Battler::STAGE_DIVISORS
        return (atkStat.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
      end
    
    def pbRoughStat(battler,stat,skill=100)
        castBattler = (battler.effects[PBEffects::Illusion] && battler.pbOwnedByPlayer?) ? battler.effects[PBEffects::Illusion] : battler
        return battler.pbSpeed if stat==:SPEED && !battler.effects[PBEffects::Illusion]
        
        stage = battler.stages[stat]+6
        value = 0
        case stat
        when :ATTACK          then value = castBattler.attack
        when :DEFENSE         then value = castBattler.defense
        when :SPECIAL_ATTACK  then value = castBattler.spatk
        when :SPECIAL_DEFENSE then value = castBattler.spdef
        when :SPEED           then value = castBattler.speed
        end
        return pbRoughStatCalc(value,stage)
    end
  
    #=============================================================================
    # Get a better move's base damage value
    #=============================================================================
    def pbMoveBaseDamage(move,user,target,skill)
      baseDmg = move.baseDamage
      baseDmg = 60 if baseDmg==1
      return baseDmg if skill<PBTrainerAI.mediumSkill
      # Covers all function codes which have their own def pbBaseDamage
      case move.function
      when "010"   # Stomp
        baseDmg *= 2 if skill>=PBTrainerAI.mediumSkill && target.effects[PBEffects::Minimize]
      # Sonic Boom, Dragon Rage, Super Fang, Night Shade, Endeavor
      when "06A", "06B", "06C", "06D", "06E"
        baseDmg = move.pbFixedDamage(user,target)
      when "06F"   # Psywave
        baseDmg = user.level
      when "070"   # OHKO
        baseDmg = 200
      when "071", "072", "073"   # Counter, Mirror Coat, Metal Burst
        baseDmg = 60
      when "075", "076", "0D0", "12D"   # Surf, Earthquake, Whirlpool, Shadow Storm
        baseDmg = move.pbModifyDamage(baseDmg,user,target)
      # Gust, Twister, Venoshock, Smelling Salts, Wake-Up Slap, Facade, Hex, Brine,
      # Retaliate, Weather Ball, Return, Frustration, Eruption, Crush Grip,
      # Stored Power, Punishment, Hidden Power, Fury Cutter, Echoed Voice,
      # Trump Card, Flail, Electro Ball, Low Kick, Fling, Spit Up
      when "077", "078", "07B", "07C", "07D", "07E", "07F", "080", "085", "087",
           "089", "08A", "08B", "08C", "08E", "08F", "090", "091", "092", "097",
           "098", "099", "09A", "0F7", "113"
        baseDmg = move.pbBaseDamage(baseDmg,user,target)
      when "086"   # Acrobatics
        baseDmg *= 2 if !user.item || user.hasActiveItem?(:FLYINGGEM)
      when "08D"   # Gyro Ball
        targetSpeed = pbRoughStat(target,:SPEED,skill)
        userSpeed = pbRoughStat(user,:SPEED,skill)
        baseDmg = [[(25*targetSpeed/userSpeed).floor,150].min,1].max
      when "094"   # Present
        baseDmg = 50
      when "095"   # Magnitude
        baseDmg = 71
        baseDmg *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
      when "096"   # Natural Gift
        baseDmg = move.pbNaturalGiftBaseDamage(user.item_id)
      when "09B"   # Heavy Slam
        baseDmg = move.pbBaseDamage(baseDmg,user,target)
        baseDmg *= 2 if Settings::MECHANICS_GENERATION >= 7 && skill>=PBTrainerAI.mediumSkill &&
                        target.effects[PBEffects::Minimize]
      when "0A0", "0BD", "0BE"   # Frost Breath, Double Kick, Twineedle
        baseDmg *= 2
      when "0BF"   # Triple Kick
        baseDmg *= 6   # Hits do x1, x2, x3 baseDmg in turn, for x6 in total
      when "0C0"   # Fury Attack
        if user.hasActiveAbility?(:SKILLLINK)
          baseDmg *= 5
        else
          baseDmg = (baseDmg*19/6).floor   # Average damage dealt
        end
      when "0C1"   # Beat Up
        mult = 0
        @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,_i|
          mult += 1 if pkmn && pkmn.able? && pkmn.status == :NONE
        end
        baseDmg *= mult
      when "0C4"   # Solar Beam
        baseDmg = move.pbBaseDamageMultiplier(baseDmg,user,target)
      when "0D3"   # Rollout
        baseDmg *= 2 if user.effects[PBEffects::DefenseCurl]
      when "0D4"   # Bide
        baseDmg = 40
      when "0E1"   # Final Gambit
        baseDmg = user.hp
      when "144"   # Flying Press
        if GameData::Type.exists?(:FLYING)
          if skill>=PBTrainerAI.highSkill
            targetTypes = target.pbTypes(true)
            mult = Effectiveness.calculate(:FLYING,
               targetTypes[0],targetTypes[1],targetTypes[2])
            baseDmg = (baseDmg.to_f*mult/Effectiveness::NORMAL_EFFECTIVE).round
          else
            mult = Effectiveness.calculate(:FLYING,
               target.type1,target.type2,target.effects[PBEffects::Type3])
            baseDmg = (baseDmg.to_f*mult/Effectiveness::NORMAL_EFFECTIVE).round
          end
        end
        baseDmg *= 2 if skill>=PBTrainerAI.mediumSkill && target.effects[PBEffects::Minimize]
      when "166"   # Stomping Tantrum
        baseDmg *= 2 if user.lastRoundMoveFailed
      when "175"   # Double Iron Bash
        baseDmg *= 2
        baseDmg *= 2 if skill>=PBTrainerAI.mediumSkill && target.effects[PBEffects::Minimize]
      end
      return baseDmg
    end
  
    #=============================================================================
    # Damage calculation
    #=============================================================================
    def pbRoughDamage(move,user,target,skill,baseDmg)
        # Fixed damage moves
        return baseDmg if move.is_a?(PokeBattle_FixedDamageMove)
        # Get the move's type
        type = pbRoughType(move,user,skill)
        ##### Calculate user's attack stat #####
        atkStat, atkStage = move.pbGetAttackStats(user,target)
        atk = pbRoughStatCalc(atkStat,atkStage)
        ##### Calculate target's defense stat #####
        defStat, defStage = move.pbGetDefenseStats(user,target)
        defense = pbRoughStatCalc(defStat,defStage)
        ##### Calculate all multiplier effects #####
        multipliers = {
        :base_damage_multiplier  => 1.0,
        :attack_multiplier       => 1.0,
        :defense_multiplier      => 1.0,
        :final_damage_multiplier => 1.0
        }
        # Ability effects that alter damage
        moldBreaker = false
        if target.hasMoldBreaker?
        moldBreaker = true
        end
        if user.abilityActive?
        # NOTE: These abilities aren't suitable for checking at the start of the
        #       round.
        abilityBlacklist = [:ANALYTIC,:SNIPER,:TINTEDLENS,:AERILATE,:PIXILATE,:REFRIGERATE]
        canCheck = true
        abilityBlacklist.each do |m|
            next if move.id != m
            canCheck = false
            break
        end
        if canCheck
            BattleHandlers.triggerDamageCalcUserAbility(user.ability,
            user,target,move,multipliers,baseDmg,type)
        end
        end
        if !moldBreaker
        user.eachAlly do |b|
            next if !b.abilityActive?
            BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
            user,target,move,multipliers,baseDmg,type)
        end
        end
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
        # Me First
        # TODO
        # Helping Hand - n/a
        # Charge
        if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
            multipliers[:base_damage_multiplier] *= 2
        end
        # Terrain moves
        case @battle.field.terrain
        when :Electric
            multipliers[:base_damage_multiplier] *= 1.3 if type == :ELECTRIC && user.affectedByTerrain?
        when :Grassy
            multipliers[:base_damage_multiplier] *= 1.3 if type == :GRASS && user.affectedByTerrain?
        when :Psychic
            multipliers[:base_damage_multiplier] *= 1.3 if type == :PSYCHIC && user.affectedByTerrain?
        when :Misty
            multipliers[:base_damage_multiplier] *= 1.3 if type == :FAIRY && target.affectedByTerrain?
        end
        # Multi-targeting attacks
        if pbTargetsMultiple?(move,user)
            multipliers[:final_damage_multiplier] *= 0.75
        end
        # Weather
        case @battle.pbWeather
        when :Sun, :HarshSun
            if type == :FIRE
            multipliers[:final_damage_multiplier] *= 1.5
            elsif type == :WATER
            multipliers[:final_damage_multiplier] /= 2
            end
        when :Rain, :HeavyRain
            if type == :FIRE
            multipliers[:final_damage_multiplier] /= 2
            elsif type == :WATER
            multipliers[:final_damage_multiplier] *= 1.5
            end
        when :Sandstorm
            if target.pbHasTypeAI?(:ROCK) && move.specialMove?(type)
            multipliers[:defense_multiplier] *= 1.5
            end
        when :Hail
            if target.pbHasTypeAI?(:ICE) && move.physicalMove?(type)
            multipliers[:defense_multiplier] *= 1.5
            end
        end
        # Critical hits - n/a
        # Random variance - n/a
        # STAB
        if type && user.pbHasTypeAI?(type)
            if user.hasActiveAbility?(:ADAPTABILITY)
                multipliers[:final_damage_multiplier] *= 2
            else
                multipliers[:final_damage_multiplier] *= 1.5
            end
        end
        # Type effectiveness
        typemod = pbCalcTypeModAI(type,user,target,move)
        multipliers[:final_damage_multiplier] *= typemod.to_f / Effectiveness::NORMAL_EFFECTIVE
        # Burn
        if user.burned? && move.physicalMove?(type) &&
            !user.hasActiveAbility?(:GUTS) && !user.hasActiveAbility?(:BURNHEAL) && !move.damageReducedByBurn?
        if !user.boss
            multipliers[:final_damage_multiplier] *= 2.0/3.0
        else
            multipliers[:final_damage_multiplier] *= 4.0/5.0
        end
        end
        # Poison
        if user.poisoned? && move.specialMove?(type) &&
            !user.hasActiveAbility?(:AUDACITY) && !user.hasActiveAbility?(:POISONHEAL) && !move.damageReducedByBurn?
        if !user.boss
            multipliers[:final_damage_multiplier] *= 2.0/3.0
        else
            multipliers[:final_damage_multiplier] *= 4.0/5.0
        end
        end
        # Frostbite
        if user.frostbitten? && move.specialMove?(type) && !move.damageReducedByBurn? && !user.hasActiveAbility?(:AUDACITY) && !user.hasActiveAbility?(:FROSTHEAL)
        damageReduction = user.boss? ? (1.0/5.0) : (1.0/3.0)
        damageReduction *= 2 if user.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
        multipliers[:final_damage_multiplier] *= (1.0 - damageReduction)
        end
        # Aurora Veil, Reflect, Light Screen
        if !move.ignoresReflect? && !user.hasActiveAbility?(:INFILTRATOR)
        if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
            if @battle.pbSideBattlerCount(target) > 1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
            else
            multipliers[:final_damage_multiplier] /= 2
            end
        elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && move.physicalMove?(type)
            if @battle.pbSideBattlerCount(target) > 1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
            else
            multipliers[:final_damage_multiplier] /= 2
            end
        elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && move.specialMove?(type)
            if @battle.pbSideBattlerCount(target) > 1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
            else
            multipliers[:final_damage_multiplier] /= 2
            end
        end
        end
        # Move-specific base damage modifiers
        # TODO
        # Move-specific final damage modifiers
        # TODO
        ##### Main damage calculation #####
        baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
        atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
        defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
        damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
        damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
        # "AI-specific calculations below"
        # Increased critical hit rates
        c = 0
        # Ability effects that alter critical hit rate
        if c>=0 && user.abilityActive?
        c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
        end
        if c>=0 && !moldBreaker && target.abilityActive?
        c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
        end
        # Item effects that alter critical hit rate
        if c>=0 && user.itemActive?
        c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
        end
        if c>=0 && target.itemActive?
        c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
        end
        # Other efffects
        c = -1 if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
        if c>=0
        c += 1 if move.highCriticalRate?
        c += user.effects[PBEffects::FocusEnergy]
        c += 1 if user.inHyperMode? && move.type == :SHADOW
        end
        if c>=0
        c = 4 if c>4
        damage += damage*0.1*c
        end
        
        return damage.floor
    end
  
   #===========================================================================
    # Accuracy calculation
    #===========================================================================
    def pbRoughAccuracy(move,user,target,skill)
        return 100 if target.effects[PBEffects::Telekinesis] > 0
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
      if skill>=PBTrainerAI.highSkill && target.hasMoldBreaker?
        moldBreaker = true
      end
      # Ability effects that alter accuracy calculation
      if skill>=PBTrainerAI.mediumSkill
        if user.abilityActive?
          BattleHandlers.triggerAccuracyCalcUserAbility(user.ability,
             modifiers,user,target,move,type)
        end
        user.eachAlly do |b|
          next if !b.abilityActive?
          BattleHandlers.triggerAccuracyCalcUserAllyAbility(b.ability,
             modifiers,user,target,move,type)
        end
      end
      if skill>=PBTrainerAI.bestSkill
        if target.abilityActive? && !moldBreaker
          BattleHandlers.triggerAccuracyCalcTargetAbility(target.ability,
             modifiers,user,target,move,type)
        end
      end
      # Item effects that alter accuracy calculation
      if skill>=PBTrainerAI.mediumSkill
        if user.itemActive?
          BattleHandlers.triggerAccuracyCalcUserItem(user.item,
             modifiers,user,target,move,type)
        end
      end
      if skill>=PBTrainerAI.bestSkill
        if target.itemActive?
          BattleHandlers.triggerAccuracyCalcTargetItem(target.item,
             modifiers,user,target,move,type)
        end
      end
      # Other effects, inc. ones that set accuracy_multiplier or evasion_stage to specific values
      if skill>=PBTrainerAI.mediumSkill
        if @battle.field.effects[PBEffects::Gravity] > 0
          modifiers[:accuracy_multiplier] *= 5/3.0
        end
        if user.effects[PBEffects::MicleBerry]
          modifiers[:accuracy_multiplier] *= 1.2
        end
        modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
        modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
      end
      # "AI-specific calculations below"
      if skill>=PBTrainerAI.mediumSkill
        modifiers[:evasion_stage] = 0 if move.function == "0A9"   # Chip Away
        modifiers[:base_accuracy] = 0 if ["0A5", "139", "13A", "13B", "13C",   # "Always hit"
                                          "147"].include?(move.function)
        modifiers[:base_accuracy] = 0 if user.effects[PBEffects::LockOn]>0 &&
                                         user.effects[PBEffects::LockOnPos]==target.index
      end
      if skill>=PBTrainerAI.highSkill
        if move.function=="006"   # Toxic
          modifiers[:base_accuracy] = 0 if Settings::MORE_TYPE_EFFECTS && move.statusMove? &&
                                           user.pbHasType?(:POISON)
        end
        if move.function=="070"   # OHKO moves
          modifiers[:base_accuracy] = move.accuracy + user.level - target.level
          modifiers[:accuracy_multiplier] = 0 if target.level > user.level
          if skill>=PBTrainerAI.bestSkill
            modifiers[:accuracy_multiplier] = 0 if target.hasActiveAbility?(:STURDY)
          end
        end
      end
    end
  end
  