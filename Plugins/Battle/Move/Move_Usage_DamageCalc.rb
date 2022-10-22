class PokeBattle_Move
    #=============================================================================
    # Final damage calculation
    #=============================================================================
    def calcBasicDamage(base_damage,attacker_level,user_attacking_stat,target_defending_stat)
        damage  = (((2.0 * attacker_level / 5 + 2).floor * base_damage * user_attacking_stat / target_defending_stat).floor / 50).floor + 2
    end

    def pbCalcDamage(user,target,numTargets=1)
        return if statusMove?
        if target.damageState.disguise
            target.damageState.calcDamage = 1
            return
        end
        stageMul = PokeBattle_Battler::STAGE_MULTIPLIERS
        stageDiv = PokeBattle_Battler::STAGE_DIVISORS
        # Get the move's type
        type = @calcType   # nil is treated as physical
        # Calculate whether this hit deals critical damage
        target.damageState.critical,target.damageState.forced_critical = pbIsCritical?(user,target)
        # Calcuate base power of move
        baseDmg = pbBaseDamage(@baseDamage,user,target)
        # Calculate user's attack stat
        atk, atkStage = pbGetAttackStats(user,target)
        if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
            atkStage = 6 if target.damageState.critical && atkStage<6
            calc = stageMul[atkStage].to_f/stageDiv[atkStage].to_f
            calc = (calc.to_f + 1.0)/2.0 if user.boss?
            atk = (atk.to_f*calc).floor
        end
        # Calculate target's defense stat
        defense, defStage = pbGetDefenseStats(user,target)
        if !user.hasActiveAbility?(:UNAWARE)
            if defStage > 6 && (target.damageState.critical || user.hasActiveAbility?(:INFILTRATOR))
                defStage = 6
            end
            calc = stageMul[defStage].to_f/stageDiv[defStage].to_f
            calc = (calc.to_f + 1.0)/2.0 if target.boss?
            defense = (defense.to_f*calc).floor
        end
        # Calculate all multiplier effects
        multipliers = {
            :base_damage_multiplier  => 1.0,
            :attack_multiplier       => 1.0,
            :defense_multiplier      => 1.0,
            :final_damage_multiplier => 1.0
        }
        pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        echoln("The calculated base damage multiplier: #{multipliers[:base_damage_multiplier]}")
        echoln("The calculated attack and defense multipliers: #{multipliers[:attack_multiplier]},#{multipliers[:defense_multiplier]}")
        echoln("The calculated final damage multiplier: #{multipliers[:final_damage_multiplier]}")
        # Main damage calculation
        baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
        atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
        defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
        damage  = calcBasicDamage(baseDmg,user.level,atk,defense)
        damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
        target.damageState.calcDamage = damage
    end
    
    def pbCalcAbilityDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        # Global abilities
        if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
            (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
            if @battle.pbCheckGlobalAbility(:AURABREAK)
                multipliers[:base_damage_multiplier] *= 2 / 3.0
            else
                multipliers[:base_damage_multiplier] *= 4 / 3.0
            end
        end
        if @battle.pbCheckGlobalAbility(:RUINOUS)
            multipliers[:base_damage_multiplier] *= 1.2
        end
        # Ability effects that alter damage
        if user.abilityActive?
            BattleHandlers.triggerDamageCalcUserAbility(user.ability,user,target,self,multipliers,baseDmg,type)
        end
        if !@battle.moldBreaker
            # NOTE: It's odd that the user's Mold Breaker prevents its partner's
            #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
            #       how it works.
            user.eachAlly do |b|
                next if !b.abilityActive?
                BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,user,target,self,multipliers,baseDmg,type)
            end
            if target.abilityActive?
                BattleHandlers.triggerDamageCalcTargetAbility(target.ability,user,target,self,multipliers,baseDmg,type) if !@battle.moldBreaker
                BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,user,target,self,multipliers,baseDmg,type)
            end
            target.eachAlly do |b|
                next if !b.abilityActive?
                BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,user,target,self,multipliers,baseDmg,type)
            end
        end
    end

    def pbCalcTerrainDamageMultipliers(user,target,type,multipliers,checkingForAI=false)
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
    end

    def pbCalcWeatherDamageMultipliers(user,target,type,multipliers,checkingForAI=false)
        case @battle.pbWeather
        when :Sun, :HarshSun
            if type == :FIRE
                multipliers[:final_damage_multiplier] *= @battle.pbWeather == :HarshSun ? 1.5 : 1.3
            elsif applySunDebuff?(user,checkingForAI)
                if @battle.pbCheckGlobalAbility(:BLINDINGLIGHT)
                    multipliers[:final_damage_multiplier] *= 0.7
                else
                    multipliers[:final_damage_multiplier] *= 0.85
                end
            end
        when :Rain, :HeavyRain
            if type == :WATER
                multipliers[:final_damage_multiplier] *= @battle.pbWeather == :HeavyRain ? 1.5 : 1.3
            elsif applyRainDebuff?(user,checkingForAI)
                if @battle.pbCheckGlobalAbility(:DREARYCLOUDS)
                    multipliers[:final_damage_multiplier] *= 0.7
                else
                    multipliers[:final_damage_multiplier] *= 0.85
                end
            end
        when :Swarm
            if type == :DRAGON || type == :BUG
                multipliers[:final_damage_multiplier] *= 1.3
            end
        when :Sandstorm
            if target.shouldTypeApply?(:ROCK,checkingForAI) && specialMove? && @function != "122"   # Psyshock/Psystrike
                multipliers[:defense_multiplier] *= 1.5
            end
        when :Hail
            if target.shouldTypeApply?(:ICE,checkingForAI) && physicalMove? && @function != "506"   # Soul Claw/Rip
                multipliers[:defense_multiplier] *= 1.5
            end
        end
    end

    def pbCalcStatusesDamageMultipliers(user,target,multipliers,checkingForAI=false)
        # Burn
        if user.burned? && physicalMove? && damageReducedByBurn? && !user.shouldAbilityApply?(:GUTS,checkingForAI) && !user.shouldAbilityApply?(:BURNHEAL,checkingForAI)
            damageReduction = user.boss? ? (1.0/5.0) : (1.0/3.0)
            damageReduction *= 2 if user.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
            multipliers[:final_damage_multiplier] *= (1.0 - damageReduction)
        end
        # Frostbite
        if user.frostbitten? && specialMove? && damageReducedByBurn? && !user.shouldAbilityApply?(:AUDACITY,checkingForAI) && !user.shouldAbilityApply?(:FROSTHEAL,checkingForAI)
            damageReduction = user.boss? ? (1.0/5.0) : (1.0/3.0)
            damageReduction *= 2 if user.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
            multipliers[:final_damage_multiplier] *= (1.0 - damageReduction)
        end
        # Numb
        if user.paralyzed?
            damageReduction = user.boss? ? (3.0/20.0) : (1.0/4.0)
            damageReduction *= 2 if user.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
            multipliers[:final_damage_multiplier] *= (1.0 - damageReduction)
        end
        # Fluster
        if target.flustered? && physicalMove? && @function != "122" && !target.shouldAbilityApply?([:FLUSTERFLOCK,:MARVELSCALE],checkingForAI)
            defenseDecrease = target.boss? ? (1.0/5.0) : (1.0/3.0)
            defenseDecrease *= 2 if target.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
            multipliers[:defense_multiplier] *= (1.0 - defenseDecrease)
        end
        # Mystified
        if target.mystified? && specialMove? && @function != "506" && !target.shouldAbilityApply?([:HEADACHE,:MARVELSKIN],checkingForAI)
            defenseDecrease = target.boss? ? (1.0/5.0) : (1.0/3.0)
            defenseDecrease *= 2 if target.pbOwnedByPlayer? && @battle.curseActive?(:CURSE_STATUS_DOUBLED)
            multipliers[:defense_multiplier] *= (1.0 - defenseDecrease)
        end
    end

    def pbCalcProtectionsDamageMultipliers(user,target,multipliers,checkingForAI=false)
        # Aurora Veil, Reflect, Light Screen
        if !ignoresReflect? && !target.damageState.critical && !user.shouldAbilityApply?(:INFILTRATOR,checkingForAI)
            if target.pbOwnSide.effectActive?(:AuroraVeil)
                if @battle.pbSideBattlerCount(target)>1
                    multipliers[:final_damage_multiplier] *= 2 / 3.0
                else
                    multipliers[:final_damage_multiplier] *= 0.5
                end
            elsif target.pbOwnSide.effectActive?(:Reflect) && physicalMove?
                if @battle.pbSideBattlerCount(target)>1
                    multipliers[:final_damage_multiplier] *= 2 / 3.0
                else
                    multipliers[:final_damage_multiplier] *= 0.5
                end
            elsif target.pbOwnSide.effectActive?(:LightScreen) && specialMove?
                if @battle.pbSideBattlerCount(target) > 1
                    multipliers[:final_damage_multiplier] *= 2 / 3.0
                else
                    multipliers[:final_damage_multiplier] *= 0.5
                end
            end
        end
        # Partial protection moves
        if target.effects[PBEffects::StunningCurl]
            multipliers[:final_damage_multiplier] *= 0.5
        end
        if target.effects[PBEffects::EmpoweredDetect] > 0
            multipliers[:final_damage_multiplier] *= 0.5
        end
        if target.pbOwnSide.effects[PBEffects::Bulwark]
            multipliers[:final_damage_multiplier] *= 0.5
        end
        # For when bosses are partway piercing protection
        if target.damageState.partiallyProtected
            multipliers[:final_damage_multiplier] *= 0.5
        end
    end

    def pbCalcTypeBasedDamageMultipliers(user,target,type,multipliers,checkingForAI=false)
        # STAB
        if !user.pbOwnedByPlayer? || !@battle.curses.include?(:DULLED)
            if type && user.pbHasType?(type)
                stab = 1.5
                if user.shouldAbilityApply?(:ADAPTED,checkingForAI)
                    stab *= 4.0/3.0
                elsif user.shouldAbilityApply?(:ULTRAADAPTED,checkingForAI)
                    stab *= 3.0/2.0
                end
                multipliers[:final_damage_multiplier] *= stab
            end
        end

        if !checkingForAI
            # Type effectiveness
            typeEffect = target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
            multipliers[:final_damage_multiplier] *= typeEffect
        end

        # Charge
        if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
            multipliers[:base_damage_multiplier] *= 2
        end
        
        # Mud Sport
        if type == :ELECTRIC
            @battle.eachBattler do |b|
                next if !b.effects[PBEffects::MudSport]
                multipliers[:base_damage_multiplier] /= 3.0
                break
            end
            if @battle.field.effects[PBEffects::MudSportField]>0
                multipliers[:base_damage_multiplier] /= 3.0
            end
        end

        # Water Sport
        if type == :FIRE
            @battle.eachBattler do |b|
                next if !b.effects[PBEffects::WaterSport]
                multipliers[:base_damage_multiplier] /= 3.0
                break
            end
            if @battle.field.effects[PBEffects::WaterSportField]>0
                multipliers[:base_damage_multiplier] /= 3.0
            end
        end
    end
      
    def pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        pbCalcAbilityDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
        pbCalcTerrainDamageMultipliers(user,target,type,multipliers)
        pbCalcWeatherDamageMultipliers(user,target,type,multipliers)
        pbCalcStatusesDamageMultipliers(user,target,multipliers)
        pbCalcProtectionsDamageMultipliers(user,target,multipliers)
        pbCalcTypeBasedDamageMultipliers(user,target,type,multipliers)
        # Item effects that alter damage
        if user.itemActive?
            BattleHandlers.triggerDamageCalcUserItem(user.item,
                user,target,self,multipliers,baseDmg,type)
        end
        if target.itemActive?
            BattleHandlers.triggerDamageCalcTargetItem(target.item,
                user,target,self,multipliers,baseDmg,type)
        end
        # Parental Bond's second attack
        if user.effects[PBEffects::ParentalBond]==1
            multipliers[:base_damage_multiplier] *= 0.25
        end
        # Me First
        if user.effects[PBEffects::MeFirst]
            multipliers[:base_damage_multiplier] *= 1.5
        end
        # Helping Hand
        if user.effects[PBEffects::HelpingHand] && !self.is_a?(PokeBattle_Confusion)
            multipliers[:base_damage_multiplier] *= 1.5
        end
        # Dragon Ride
        if user.effects[PBEffects::OnDragonRide] && physicalMove?
            multipliers[:final_damage_multiplier] *= 1.5
        end
        # Shimmering Heat
        if target.effects[PBEffects::ShimmeringHeat]
            echoln("Target is protected by Shimmering Heat")
            multipliers[:final_damage_multiplier] *= 0.67
        end
        # Echo
        if user.effects[PBEffects::Echo]
            multipliers[:final_damage_multiplier] *= 0.75
        end
        # Multi-targeting attacks
        if numTargets > 1
            multipliers[:final_damage_multiplier] *= 0.75
        end
        # Battler properites
        multipliers[:base_damage_multiplier] *= user.dmgMult
        multipliers[:base_damage_multiplier] *= [0,(1.0 - target.dmgResist.to_f)].max
        echoln("User's damage mult is #{user.dmgMult} and the target's damage resist is #{target.dmgResist}")
        # Critical hits
        if target.damageState.critical
            if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
                multipliers[:final_damage_multiplier] *= 1.5
            else
                multipliers[:final_damage_multiplier] *= 2
            end
        end
        # Random variance (What used to be for that)
        if !self.is_a?(PokeBattle_Confusion) && !self.is_a?(PokeBattle_Charm)
            multipliers[:final_damage_multiplier] *= 0.9
        end
        # Move-specific base damage modifiers
        multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
        # Move-specific final damage modifiers
        multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
    end
end