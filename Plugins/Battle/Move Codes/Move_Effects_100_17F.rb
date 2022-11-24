#===============================================================================
# Starts rainy weather. (Rain Dance)
#===============================================================================
class PokeBattle_Move_100 < PokeBattle_WeatherMove
    def initialize(battle,move)
      super
      @weatherType = :Rain
    end
  end
  
  #===============================================================================
  # Starts sandstorm weather. (Sandstorm)
  #===============================================================================
  class PokeBattle_Move_101 < PokeBattle_WeatherMove
    def initialize(battle,move)
      super
      @weatherType = :Sandstorm
    end
  end
  
  #===============================================================================
  # Starts hail weather. (Hail)
  #===============================================================================
  class PokeBattle_Move_102 < PokeBattle_WeatherMove
    def initialize(battle,move)
      super
      @weatherType = :Hail
    end
  end
  
  #===============================================================================
  # Entry hazard. Lays spikes on the opposing side. (Spikes)
  #===============================================================================
  class PokeBattle_Move_103 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if user.pbOpposingSide.effectAtMax?(:Spikes)
        @battle.pbDisplay(_INTL("But it failed, since there is no room for more Spikes!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbOpposingSide.incrementEffect(:Spikes)
    end

    def getScore(score,user,target,skill=100)
        return getHazardSettingMoveScore(score,user,target,skill)
    end
  end
  
  #===============================================================================
  # Entry hazard. Lays poison spikes on the opposing side (max. 2 layers).
  # (Poison Spikes)
  #===============================================================================
  class PokeBattle_Move_104 < PokeBattle_StatusSpikeMove
    def initialize(battle,move)
      @spikeEffect = :PoisonSpikes
      super
    end
  end
  
  #===============================================================================
  # Entry hazard. Lays stealth rocks on the opposing side. (Stealth Rock)
  #===============================================================================
  class PokeBattle_Move_105 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if user.pbOpposingSide.effectActive?(:StealthRock)
        @battle.pbDisplay(_INTL("But it failed, since pointed stones already float around the opponent!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbOpposingSide.applyEffect(:StealthRock)
    end

    def getScore(score,user,target,skill=100)
      score = getHazardSettingMoveScore(score,user,target,skill)
      return score
    end
  end
  
  #===============================================================================
  # Combos with another Pledge move used by the ally. (Grass Pledge)
  # If the move is a combo, power is doubled and causes either a sea of fire or a
  # swamp on the opposing side.
  #===============================================================================
  class PokeBattle_Move_106 < PokeBattle_PledgeMove
    def initialize(battle,move)
      super
      # [Function code to combo with, effect, override type, override animation]
      @combos = [["107", :SeaOfFire, :FIRE, :FIREPLEDGE],
                 ["108", :Swamp,     nil,   nil]]
    end
  end
  
  #===============================================================================
  # Combos with another Pledge move used by the ally. (Fire Pledge)
  # If the move is a combo, power is doubled and causes either a rainbow on the
  # user's side or a sea of fire on the opposing side.
  #===============================================================================
  class PokeBattle_Move_107 < PokeBattle_PledgeMove
    def initialize(battle,move)
      super
      # [Function code to combo with, effect, override type, override animation]
      @combos = [["108", :Rainbow,   :WATER, :WATERPLEDGE],
                 ["106", :SeaOfFire, nil,    nil]]
    end
  end
  
  #===============================================================================
  # Combos with another Pledge move used by the ally. (Water Pledge)
  # If the move is a combo, power is doubled and causes either a swamp on the
  # opposing side or a rainbow on the user's side.
  #===============================================================================
  class PokeBattle_Move_108 < PokeBattle_PledgeMove
    def initialize(battle,move)
      super
      # [Function code to combo with, effect, override type, override animation]
      @combos = [["106", :Swamp,   :GRASS, :GRASSPLEDGE],
                 ["107", :Rainbow, nil,    nil]]
    end
  end
  
  #===============================================================================
  # Scatters coins that the player picks up after winning the battle. (Pay Day)
  #===============================================================================
  class PokeBattle_Move_109 < PokeBattle_Move
    def pbEffectGeneral(user)
      @battle.field.incrementEffect(:PayDay,5*user.level) if user.pbOwnedByPlayer?
    end
  end
  
  #===============================================================================
  # Ends the opposing side's screen effects. (Brick Break, Psychic Fangs)
  #===============================================================================
  class PokeBattle_Move_10A < PokeBattle_Move
    def ignoresReflect?; return true; end
  
    def pbEffectWhenDealingDamage(user,target)
      side = target.pbOwnSide
      side.eachEffect(true) do |effect,value,data|
        side.disableEffect(effect) if data.is_screen?
      end
    end

    def sideHasScreens?(side)
      side.eachEffect(true) do |effect,value,data|
        return true if data.is_screen?
      end
      return false
    end
  
    def pbShowAnimation(id,user,targets,hitNum = 0,showAnimation=true)
      targets.each do |b|
        next unless sideHasScreens?(b.pbOwnSide)
        hitNum = 1 # Wall-breaking anim
        break
      end
      super
    end

    def getScore(score,user,target,skill=100)
      side = target.pbOwnSide
      side.eachEffect(true) do |effect,value,data|
        score += 10 if data.is_screen?
      end
      return score
    end

    def shouldHighlight?(user,target)
      return sideHasScreens?(target.pbOwnSide)
    end
  end
  
  #===============================================================================
  # If attack misses, user takes crash damage of 1/2 of max HP.
  # (High Jump Kick, Jump Kick)
  #===============================================================================
  class PokeBattle_Move_10B < PokeBattle_Move
    def recoilMove?;        return true; end
    def unusableInGravity?; return true; end
  
    def pbCrashDamage(user)
      recoilDamage = user.totalhp / 2.0
      recoilMessage = _INTL("{1} kept going and crashed!",user.pbThis)
      user.applyRecoilDamage(recoilDamage,true,true,recoilMessage)
    end
  end
  
  #===============================================================================
  # User turns 1/4 of max HP into a substitute. (Substitute)
  #===============================================================================
  class PokeBattle_Move_10C < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if user.substituted?
        @battle.pbDisplay(_INTL("{1} already has a substitute!",user.pbThis))
        return true
      end
      
      if user.hp <= getSubLife(user)
        @battle.pbDisplay(_INTL("But it does not have enough HP left to make a substitute!"))
        return true
      end
      return false
    end

    def getSubLife(battler)
      subLife = battler.totalhp/4
      subLife = 1 if subLife < 1
      return subLife.floor
    end
  
    def pbEffectGeneral(user)
      subLife = getSubLife(user)
      user.pbReduceHP(subLife,false,false)
      user.pbItemHPHealCheck
      user.disableEffect(:Trapping)
		  user.applyEffect(:Substitute,subLife)
    end

    def getScore(score,user,target,skill=100)
      score += 20 if user.firstTurn?
      user.eachOpposing(true) do |b|
        if !b.canActThisTurn?
          score += 50
        elsif b.hasSoundMove?
          score -= 50
        end
      end
      return score
    end
  end
  
  #===============================================================================
  # User is Ghost: User loses 1/2 of max HP, and curses the target.
  # Cursed Pokémon lose 1/4 of their max HP at the end of each round.
  # User is not Ghost: Decreases the user's Speed by 1 stage, and increases the
  # user's Attack and Defense by 1 stage each. (Curse)
  #===============================================================================
  class PokeBattle_Move_10D < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbTarget(user)
      return GameData::Target.get(:NearFoe) if user.pbHasType?(:GHOST)
      return super
    end
  
    def pbMoveFailed?(user,targets)
      return false if user.pbHasType?(:GHOST)
      if !user.pbCanLowerStatStage?(:SPEED,user,self) &&
         !user.pbCanRaiseStatStage?(:ATTACK,user,self) &&
         !user.pbCanRaiseStatStage?(:DEFENSE,user,self)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbFailsAgainstTarget?(user,target)
      if user.pbHasType?(:GHOST) && target.effectActive?(:Curse)
        @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already cursed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      return if user.pbHasType?(:GHOST)
      # Non-Ghost effect
      user.tryLowerStat(:SPEED,user, increment: 1, move: self)
      user.pbRaiseMultipleStatStages([:ATTACK,1,:DEFENSE,1], user, move: self)
    end
  
    def pbEffectAgainstTarget(user,target)
      return if !user.pbHasType?(:GHOST)
      # Ghost effect
      @battle.pbDisplay(_INTL("{1} cut its own HP!",user.pbThis))
      user.applyFractionalDamage(1.0/4.0,false)
      target.applyEffect(:Curse)
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      hitNum = 1 if !user.pbHasType?(:GHOST)   # Non-Ghost anim
      super
    end

    def getScore(score,user,target,skill=100)
      if user.pbHasTypeAI?(:GHOST)
        return 0 if target.hp <= target.totalhp / 2

				if user.hp <= user.totalhp / 2
					if !user.alliesInReserve?
					  return 0
					else
            score -= 50
					end
				end
			else
        statUp = [:ATTACK,2,:DEFENSE,2]
        score = getMultiStatUpMoveScore(statUp,score,user,target,skill,statusMove?)
        score -= user.stages[:SPEED] * 10
			end
      return score
    end
  end
  
  #===============================================================================
  # Target's last move used loses 4 PP. (Spite)
  #===============================================================================
  class PokeBattle_Move_10E < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbFailsAgainstTarget?(user,target)
      failed = true
      if target.lastRegularMoveUsed
        target.eachMove do |m|
          next if m.id!=target.lastRegularMoveUsed || m.pp==0 || m.total_pp<=0
          failed = false; break
        end
      end
      if failed
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.eachMove do |m|
        next if m.id!=target.lastRegularMoveUsed
        reduction = [4,m.pp].min
        target.pbSetPP(m,m.pp-reduction)
        @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
           target.pbThis(true),m.name,reduction))
        break
      end
    end

    def getScore(score,user,target,skill=100)
      echoln("The AI should never use Spite.")
      return 0
    end
  end
  
  #===============================================================================
  # Target will lose 1/4 of max HP at end of each round, while asleep. (Nightmare)
  #===============================================================================
  class PokeBattle_Move_10F < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if !target.asleep? || target.effectActive?(:Nightmare)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.applyEffect(:Nightmare)
    end

    def getScore(score,user,target,skill=100)
      score -= 30
      score += 30 * target.statusCount
      return score
    end
  end
  
  #===============================================================================
  # Currently unused. # TODO
  #===============================================================================
  class PokeBattle_Move_110 < PokeBattle_Move
    
  end
  
  #===============================================================================
  # Attacks 2 rounds in the future. (Doom Desire, Future Sight)
  #===============================================================================
  class PokeBattle_Move_111 < PokeBattle_Move
    def cannotRedirect?; return true; end
  
    def pbDamagingMove?   # Stops damage being dealt in the setting-up turn
      return false if !@battle.futureSight
      return super
    end
  
    def pbAccuracyCheck(user,target)
      return true if !@battle.futureSight
      return super
    end
  
    def pbDisplayUseMessage(user,targets)
      super if !@battle.futureSight
    end

    def displayWeatherDebuffMessages(user,type)
      super if !@battle.futureSight
    end
  
    def pbFailsAgainstTarget?(user,target)
      if !@battle.futureSight && target.position.effectActive?(:FutureSightCounter)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      return if @battle.futureSight   # Attack is hitting
      position = 
      count = 3
      count -= 1 if user.hasActiveAbility?([:BADOMEN])
      target.position.applyEffect(:FutureSightCounter,count)
      target.position.applyEffect(:FutureSightMove,@id)
      target.position.pointAt(:FutureSightUserIndex,user)
      target.position.applyEffect(:FutureSightUserPartyIndex,user.pokemonIndex)
      if @id == :DOOMDESIRE
        @battle.pbDisplay(_INTL("{1} chose Doom Desire as its destiny!",user.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} foresaw an attack!",user.pbThis))
      end
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      hitNum = 1 if !@battle.futureSight   # Charging anim
      super
    end

    def getScore(score,user,target,skill=100)
      return 0 if !user.alliesInReserve?
      score += 20 if user.firstTurn?
      return score
    end
  end
  
  #===============================================================================
  # Increases the user's Defense and Special Defense by 1 stage each. Ups the
  # user's stockpile by 1 (max. 3). (Stockpile)
  #===============================================================================
  class PokeBattle_Move_112 < PokeBattle_MultiStatUpMove

    def initialize(battle,move)
      super
      @statUp = [:DEFENSE,1,:SPECIAL_DEFENSE,1]
    end
    
    def pbMoveFailed?(user,targets)
      if user.effectAtMax?(:Stockpile)
        @battle.pbDisplay(_INTL("{1} can't stockpile any more!",user.pbThis))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.incrementEffect(:Stockpile)
      super
    end

    def getScore(score,user,target,skill=100)
      score = super
      score += 20 if user.pbHasMoveFunction?("113")	# Spit Up
      score += 20 if user.pbHasMoveFunction?("114") # Swallow
      return score
    end
  end
  
  #===============================================================================
  # Power is 100 multiplied by the user's stockpile (X). Resets the stockpile to
  # 0. Decreases the user's Defense and Special Defense by X stages each. (Spit Up)
  #===============================================================================
  class PokeBattle_Move_113 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if !user.effectActive?(:Stockpile)
        @battle.pbDisplay(_INTL("But it failed to spit up a thing!"))
        return true
      end
      return false
    end
  
    def pbBaseDamage(baseDmg,user,target)
      return 100 * user.countEffect(:Stockpile)
    end
  
    def pbEffectAfterAllHits(user,target)
      return if user.fainted? || !user.effectActive?(:Stockpile)
      return if target.damageState.unaffected
      @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",user.pbThis))
      return if @battle.pbAllFainted?(target.idxOwnSide)
      user.disableEffect(:Stockpile)
    end

    def getScore(score,user,target,skill=100)
      score -= 20 * user.countEffect(:Stockpile)
      return score
    end

    def shouldHighlight?(user,target)
      return user.effectAtMax?(:Stockpile)
    end
  end
  
  #===============================================================================
  # Heals user depending on the user's stockpile (X). Resets the stockpile to 0.
  # Decreases the user's Defense and Special Defense by X stages each. (Swallow)
  #===============================================================================
  class PokeBattle_Move_114 < PokeBattle_HealingMove
    def healingMove?; return true; end
  
    def pbMoveFailed?(user,targets)
      return true if super
      if !user.effectActive?(:Stockpile)
        @battle.pbDisplay(_INTL("But it failed to swallow a thing!"))
        return true
      end
      return false
    end

    def healRatio(user)
      case [user.countEffect(:Stockpile),1].max
      when 1
        return 1.0/4.0
      when 2
        return 1.0/24.0
      when 3
        return 1.0
      end
      return 0.0
    end
  
    def pbEffectGeneral(user)
      super
      @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",user.pbThis))
      user.disableEffect(:Stockpile)
    end

    def getScore(score,user,target,skill=100)
      score = super
      score -= 20 * user.countEffect(:Stockpile)
      return score
    end

    def shouldHighlight?(user,target)
      return user.effectAtMax?(:Stockpile)
    end
  end
  
  #===============================================================================
  # Fails if user was hit by a damaging move this round. (Focus Punch)
  #===============================================================================
  class PokeBattle_Move_115 < PokeBattle_Move
    def pbDisplayChargeMessage(user)
      user.applyEffect(:FocusPunch)
    end
  
    def pbDisplayUseMessage(user,targets)
      super if !user.effectActive?(:FocusPunch) || user.lastHPLost == 0
    end
  
    def pbMoveFailed?(user,targets)
      if user.effectActive?(:FocusPunch) && user.lastHPLost > 0
        @battle.pbDisplay(_INTL("{1} lost its focus and couldn't move!",user.pbThis))
        return true
      end
      return false
    end

    def getScore(score,user,target,skill=100)
      score += 30 if user.substituted?
      score += 20 if user.hasAlly?
      user.eachPotentialAttacker do |b|
        score -= 20
      end
      score -= 50 if target.hp <= target.totalhp / 2	 # If target is weak, don't risk it
      return score
    end
  end
  
  #===============================================================================
  # Fails if the target didn't chose a damaging move to use this round, or has
  # already moved. (Sucker Punch)
  #===============================================================================
  class PokeBattle_Move_116 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if @battle.choices[target.index][0]!=:UseMove
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      oppMove = @battle.choices[target.index][2]
      if !oppMove ||
         (oppMove.function!="0B0" &&   # Me First
         (target.movedThisRound? || oppMove.statusMove?))
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end

    def getScore(score,user,target,skill=100)
      return 0 if target.hasDamagingAttack?
      if user.hp < user.totalhp / 2
        score -= 20
      else
        score += 20
      end
      return score
    end
  end
  
  #===============================================================================
  # This round, user becomes the target of attacks that have single targets.
  # (Follow Me, Rage Powder)
  #===============================================================================
  class PokeBattle_Move_117 < PokeBattle_Move
    def pbEffectGeneral(user)
      maxFollowMe = 0
      user.eachAlly do |b|
        next if b.effects[:FollowMe] <= maxFollowMe
        maxFollowMe = b.effects[:FollowMe]
      end
      user.applyEffect(:FollowMe,maxFollowMe+1)
      user.applyEffect(:RagePowder) if @id == :RAGEPOWDER
    end

    def getScore(score,user,target,skill=100)
      return 0 if !user.hasAlly?
      # TODO: Add a calculation for if tankier than ally
      return score
    end
  end
  
  #===============================================================================
  # For 5 rounds, increases gravity on the field. Pokémon cannot become airborne.
  # (Gravity)
  #===============================================================================
  class PokeBattle_Move_118 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if @battle.field.effectActive?(:Gravity)
        @battle.pbDisplay(_INTL("But it failed, since gravity is already intense!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      @battle.field.applyEffect(:Gravity,5)
    end

    def getScore(score,user,target,skill=100)
      @battle.eachBattler do |b|
        if user.opposes?(b)
          score += 20 if b.airborne?(true)
        else
          score -= 20 if b.airborne?(true)
        end
      end
      # TODO: Add a section that cares about accuracy
      return score
    end
  end
  
  #===============================================================================
  # For 5 rounds, user becomes airborne. (Magnet Rise)
  #===============================================================================
  class PokeBattle_Move_119 < PokeBattle_Move
    def unusableInGravity?; return true; end
  
    def pbMoveFailed?(user,targets)
      if user.effectActive?(:Ingrain) || user.effectActive?(:SmackDown) || user.effectActive?(:MagnetRise)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.applyEffect(:MagnetRise,5)
    end

    def getScore(score,user,target,skill=100)
      score -= 20
      score -= 20 if !user.firstTurn?
      user.eachOpposing(true) do |b|
        if b.pbHasAttackingType?(:GROUND)
          score += 50
          score += 25 if b.pbHasType?(:GROUND)
        end
      end
      return score
    end
  end
  
  #===============================================================================
  # For 3 rounds, target becomes airborne and can always be hit. (Telekinesis)
  #===============================================================================
  class PokeBattle_Move_11A < PokeBattle_Move
    def unusableInGravity?; return true; end
  
    def pbFailsAgainstTarget?(user,target)
      if target.effectActive?(:Ingrain)
         target.effectActive?(:SmackDown)
         target.effectActive?(:Telekinesis)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if target.isSpecies?(:DIGLETT) ||
         target.isSpecies?(:DUGTRIO) ||
         target.isSpecies?(:SANDYGAST) ||
         target.isSpecies?(:PALOSSAND) ||
         (target.isSpecies?(:GENGAR) && target.mega?)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.applyEffect(:Telekinesis,3)
      @battle.pbDisplay(_INTL("{1} was hurled into the air!",target.pbThis))
    end

    def getScore(score,user,target,skill=100)
      return 0 if !user.opposes?(target)
      score -= 40 # Move is very bad
      return score
    end
  end

  #===============================================================================
  # Hits airborne semi-invulnerable targets. (Sky Uppercut)
  #===============================================================================
  class PokeBattle_Move_11B < PokeBattle_Move
    def hitsFlyingTargets?; return true; end

    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if target.inTwoTurnAttack?("0C9","0CC","0CE") ||  # Fly/Bounce/Sky Drop
                      target.effectActive?(:SkyDrop)
      return baseDmg
    end
  end
  
  #===============================================================================
  # Grounds the target while it remains active. Hits some semi-invulnerable
  # targets. (Smack Down, Thousand Arrows)
  #===============================================================================
  class PokeBattle_Move_11C < PokeBattle_Move
    def hitsFlyingTargets?; return true; end
  
    def pbCalcTypeModSingle(moveType,defType,user,target)
      return Effectiveness::NORMAL_EFFECTIVE_ONE if moveType == :GROUND && defType == :FLYING
      return super
    end

    def canSmackDown?(target,checkingForAI=false)
      return false if target.fainted?
      if checkingForAI
        return false if target.substituted?
      else
        return false if target.damageState.unaffected || target.damageState.substitute
      end
      return false if target.inTwoTurnAttack?("0CE") || target.effectActive?(:SkyDrop)   # Sky Drop
      return false if !target.airborne? && !target.inTwoTurnAttack?("0C9","0CC")   # Fly/Bounce
      return true
    end
  
    def pbEffectAfterAllHits(user,target)
      return if !canSmackDown?(target)
      target.applyEffect(:SmackDown)
    end

    def getScore(score,user,target,skill=100)
      if canSmackDown?(target)
        if !target.effectActive?(:SmackDown)
          score += 20
        end
        if target.inTwoTurnAttack?("0C9","0CC")
          score += 20
        end
      end
      return score
    end

    def shouldHighlight?(user,target)
      return canSmackDown?(target)
    end
  end
  
  #===============================================================================
  # Target moves immediately after the user, ignoring priority/speed. (After You)
  #===============================================================================
  class PokeBattle_Move_11D < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbFailsAgainstTarget?(user,target)
      # Target has already moved this round
      return true if pbMoveFailedTargetAlreadyMoved?(target)
      # Target was going to move next anyway (somehow)
      if target.effectActive?(:MoveNext)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      # Target didn't choose to use a move this round
      oppMove = @battle.choices[target.index][2]
      if !oppMove
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.applyEffect(:MoveNext)
      @battle.pbDisplay(_INTL("{1} took the kind offer!",target.pbThis))
    end

    def getScore(score,user,target,skill=100)
      return 0 if user.opposes?(target)
      userSpeed = user.pbSpeed(true)
		  targetSpeed = target.pbSpeed(true)
      return 0 if targetSpeed > userSpeed

      # TODO: This can be improved
      return score
    end
  end
  
  #===============================================================================
  # Target moves last this round, ignoring priority/speed. (Quash)
  #===============================================================================
  class PokeBattle_Move_11E < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      return true if pbMoveFailedTargetAlreadyMoved?(target)
      # Target isn't going to use a move
      oppMove = @battle.choices[target.index][2]
      if !oppMove
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      # Target is already maximally Quashed and will move last anyway
      highestQuash = 0
      @battle.battlers.each do |b|
        next if b.effects[:Quash] <= highestQuash
        highestQuash = b.effects[:Quash]
      end
      if highestQuash > 0 && target.effects[:Quash] == highestQuash
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      # Target was already going to move last
      if highestQuash==0 && @battle.pbPriority.last.index==target.index
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      highestQuash = 0
      @battle.battlers.each do |b|
        next if b.effects[:Quash] <= highestQuash
        highestQuash = b.effects[:Quash]
      end
      target.applyEffect(:Quash,highestQuash+1)
      @battle.pbDisplay(_INTL("{1}'s move was postponed!",target.pbThis))
    end

    def getScore(score,user,target,skill=100)
      return 0 if !user.opposes?(target)
      return 0 if !user.hasAlly?
      userSpeed = user.pbSpeed(true)
		  targetSpeed = target.pbSpeed(true)
      return 0 if targetSpeed > userSpeed
      # TODO: This can be improved
    end
  end
  
  #===============================================================================
  # For 5 rounds, for each priority bracket, slow Pokémon move before fast ones.
  # (Trick Room)
  #===============================================================================
  class PokeBattle_Move_11F < PokeBattle_RoomMove
    def initialize(battle,move)
      super
      @roomEffect = :TrickRoom
    end
  end
  
  #===============================================================================
  # User switches places with its ally. (Ally Switch)
  #===============================================================================
  class PokeBattle_Move_120 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      eachValidSwitch(user) do |ally|
        return false
      end
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end

    def eachValidSwitch(battler)
      idxUserOwner = @battle.pbGetOwnerIndexFromBattlerIndex(battler.index)
      battler.eachAlly do |b|
        next if @battle.pbGetOwnerIndexFromBattlerIndex(b.index) != idxUserOwner
        next if !b.near?(battler)
        yield b
      end
    end
  
    def pbEffectGeneral(user)
      idxA = user.index
      idxB = -1
      eachValidSwitch(user) do |ally|
        idxB = ally.index
      end
      if @battle.pbSwapBattlers(idxA,idxB)
        @battle.pbDisplay(_INTL("{1} and {2} switched places!",
           @battle.battlers[idxB].pbThis,@battle.battlers[idxA].pbThis(true)))
      end
    end

    def getScore(score,user,target,skill=100)
      echoln("The AI will never use Ally Switch.")
      return 0
    end
  end
  
  #===============================================================================
  # Target's attacking stats are used instead of user's Attack for this move's calculations.
  # (Foul Play, Tricky Toxins)
  #===============================================================================
  class PokeBattle_Move_121 < PokeBattle_Move
    def pbAttackingStat(user,target)
      if specialMove?
        return target,:SPECIAL_ATTACK
      end
      return target,:ATTACK
    end
  end
  
  #===============================================================================
  # Target's Defense is used instead of its Special Defense for this move's
  # calculations. (Psyshock, Psystrike, Secret Sword)
  #===============================================================================
  class PokeBattle_Move_122 < PokeBattle_Move
    def pbDefendingStat(user,target)
      return target, :DEFENSE
    end
  end
  
  #===============================================================================
  # Only damages Pokémon that share a type with the user. (Synchronoise)
  #===============================================================================
  class PokeBattle_Move_123 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      userTypes = user.pbTypes(true)
      targetTypes = target.pbTypes(true)
      sharesType = false
      userTypes.each do |t|
        next if !targetTypes.include?(t)
        sharesType = true
        break
      end
      if !sharesType
        @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
        return true
      end
      return false
    end
  end
  
  #===============================================================================
  # For 5 rounds, swaps all battlers' base Defense with base Special Defense.
  # (Wonder Room)
  #===============================================================================
  class PokeBattle_Move_124 < PokeBattle_RoomMove
    def initialize(battle,move)
      super
      @roomEffect = :WonderRoom
    end
  end
  
  #===============================================================================
  # Fails unless user has already used all other moves it knows. (Last Resort)
  #===============================================================================
  class PokeBattle_Move_125 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      hasThisMove = false; hasOtherMoves = false; hasUnusedMoves = false
      user.eachMove do |m|
        hasThisMove    = true if m.id==@id
        hasOtherMoves  = true if m.id!=@id
        hasUnusedMoves = true if m.id!=@id && !user.movesUsed.include?(m.id)
      end
      if !hasThisMove || !hasOtherMoves || hasUnusedMoves
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  end
  
#===============================================================================
# NOTE: Shadow moves use function codes 126-132 inclusive.
#===============================================================================
module ShadowMoveAI
  def getScore(score,user,target,skill=100)
    echoln("The AI for Shadow moves is not created.")
    super
  end
end

#===============================================================================
# No additional effect. (Shadow Blast, Shadow Blitz, Shadow Break, Shadow Rave,
# Shadow Rush, Shadow Wave)
#===============================================================================
class PokeBattle_Move_126 < PokeBattle_Move_000
  include ShadowMoveAI
  
end

#===============================================================================
# Numbs the target. (Shadow Bolt)
#===============================================================================
class PokeBattle_Move_127 < PokeBattle_Move_007
  include ShadowMoveAI
  
end

#===============================================================================
# Burns the target. (Shadow Fire)
#===============================================================================
class PokeBattle_Move_128 < PokeBattle_Move_00A
  include ShadowMoveAI
  
end

#===============================================================================
# Freezes the target. (Shadow Chill)
#===============================================================================
class PokeBattle_Move_129 < PokeBattle_Move_00C
  include ShadowMoveAI
  
end

#===============================================================================
# Confuses the target. (Shadow Panic)
#===============================================================================
class PokeBattle_Move_12A < PokeBattle_Move_013
  include ShadowMoveAI
  
end

#===============================================================================
# Decreases the target's Defense by 2 stages. (Shadow Down)
#===============================================================================
class PokeBattle_Move_12B < PokeBattle_Move_04C
  include ShadowMoveAI

end

#===============================================================================
# Decreases the target's evasion by 2 stages. (Shadow Mist)
#===============================================================================
class PokeBattle_Move_12C < PokeBattle_TargetStatDownMove
  include ShadowMoveAI
  
  def initialize(battle,move)
    super
    @statDown = [:EVASION,2]
  end
end

#===============================================================================
# Power is doubled if the target is using Dive. (Shadow Storm)
#===============================================================================
class PokeBattle_Move_12D < PokeBattle_Move_075
  include ShadowMoveAI
end

#===============================================================================
# Two turn attack. On first turn, halves the HP of all active Pokémon.
# Skips second turn (if successful). (Shadow Half)
#===============================================================================
class PokeBattle_Move_12E < PokeBattle_Move
  include ShadowMoveAI
  
  def pbMoveFailed?(user,targets)
    failed = true
    @battle.eachBattler do |b|
      next if b.hp==1
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.hp==1
      b.pbReduceHP(i.hp/2,false)
    end
    @battle.pbDisplay(_INTL("Each Pokémon's HP was halved!"))
    @battle.eachBattler { |b| b.pbItemHPHealCheck }
    user.applyEffect(:HyperBeam,2)
  end
end

#===============================================================================
# Target can no longer switch out or flee, as long as the user remains active.
# (Shadow Hold)
#===============================================================================
class PokeBattle_Move_12F < PokeBattle_Move_0EF
  include ShadowMoveAI
  
end

#===============================================================================
# User takes recoil damage equal to 1/2 of its current HP. (Shadow End)
#===============================================================================
class PokeBattle_Move_130 < PokeBattle_RecoilMove
  include ShadowMoveAI

  def recoilFactor;  return 0.5; end

  def pbEffectAfterAllHits(user,target)
    return if user.fainted? || target.damageState.unaffected
    # NOTE: This move's recoil is not prevented by Rock Head/Magic Guard.
    amt = pbRecoilDamage(user,target)
    amt = 1 if amt<1
    user.pbReduceHP(amt,false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# Starts shadow weather. (Shadow Sky)
#===============================================================================
class PokeBattle_Move_131 < PokeBattle_WeatherMove
  include ShadowMoveAI

  def initialize(battle,move)
    super
    @weatherType = :ShadowSky
  end
end

#===============================================================================
# Ends the effects of Light Screen, Reflect and Safeguard on both sides.
# (Shadow Shed)
#===============================================================================
class PokeBattle_Move_132 < PokeBattle_Move
  include ShadowMoveAI

  def pbEffectGeneral(user)
    @battle.sides.each do |side|
      side.eachEffect(true) do |effect,value,data|
        side.disableEffect(effect) if data.is_screen?
      end
    end
    @battle.pbDisplay(_INTL("It broke all barriers!"))
  end
end

  #===============================================================================
  # Does absolutely nothing. (Hold Hands)
  #===============================================================================
  class PokeBattle_Move_133 < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbMoveFailed?(user,targets)
      hasAlly = false
      user.eachAlly do |_b|
        hasAlly = true
        break
      end
      if !hasAlly
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end

    def pbEffectGeneral(user)
      echoln("The AI will never use Hold Hands.")
      return 0
    end
  end
  
  #===============================================================================
  # Does absolutely nothing. Shows a special message. (Celebrate)
  #===============================================================================
  class PokeBattle_Move_134 < PokeBattle_Move
    def pbEffectGeneral(user)
      if @battle.wildBattle? && user.opposes?
        @battle.pbDisplay(_INTL("Congratulations from {1}!",user.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("Congratulations, {1}!",@battle.pbGetOwnerName(user.index)))
      end
    end

    def pbEffectGeneral(user)
      echoln("The AI will never use Celebrate.")
      return 0
    end
  end
  
  #===============================================================================
  # Freezes the target. Effectiveness against Water-type is 2x. (Freeze-Dry)
  #===============================================================================
  class PokeBattle_Move_135 < PokeBattle_FrostbiteMove
    def pbCalcTypeModSingle(moveType,defType,user,target)
      return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :WATER
      return super
    end
  end
  
  #===============================================================================
  # Increases the user's Defense by 2 stages. (Diamond Storm)
  #===============================================================================
  class PokeBattle_Move_136 < PokeBattle_Move_02F
    # NOTE: In Gen 6, this move increased the user's Defense by 1 stage for each
    #       target it hit. This effect changed in Gen 7 and is now identical to
    #       function code 02F.
  end
  
  #===============================================================================
  # TODO: Currently unused.
  #===============================================================================
  class PokeBattle_Move_137 < PokeBattle_Move
  end
  
  #===============================================================================
  # Increases target's Defense and Special Defense by 1 stage. (Aromatic Mist)
  #===============================================================================
  class PokeBattle_Move_138 < PokeBattle_TargetMultiStatUpMove
    def ignoresSubstitute?(user); return true; end

    def initialize(battle,move)
      super
      @statUp = [:DEFENSE,1,:SPECIAL_DEFENSE,1]
    end
  end
  
  #===============================================================================
  # Decreases the target's Attack by 1 stage. Always hits. (Play Nice)
  #===============================================================================
  class PokeBattle_Move_139 < PokeBattle_TargetStatDownMove
    def ignoresSubstitute?(user); return true; end
  
    def initialize(battle,move)
      super
      @statDown = [:ATTACK,1]
    end
  
    def pbAccuracyCheck(user,target); return true; end
  end
  
  #===============================================================================
  # Decreases the target's Attack and Special Attack by 1 stage each. Always hits.
  # (Noble Roar)
  #===============================================================================
  class PokeBattle_Move_13A < PokeBattle_TargetMultiStatDownMove
    def ignoresSubstitute?(user); return true; end
  
    def initialize(battle,move)
      super
      @statDown = [:ATTACK,1,:SPECIAL_ATTACK,1]
    end
  
    def pbAccuracyCheck(user,target); return true; end
  end
  
  #===============================================================================
  # Decreases the user's Defense by 1 stage. Always hits. Ends target's
  # protections immediately. (Hyperspace Fury)
  #===============================================================================
  class PokeBattle_Move_13B < PokeBattle_StatDownMove
    def ignoresSubstitute?(user); return true; end
  
    def initialize(battle,move)
      super
      @statDown = [:DEFENSE,1]
    end
  
    def pbMoveFailed?(user,targets)
      if !user.countsAs?(:HOOPA)
        @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis(true)))
        return true
      elsif user.form != 1
        @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!",user.pbThis(true)))
        return true
      end
      return false
    end
  
    def pbAccuracyCheck(user,target); return true; end
  
    def pbEffectAgainstTarget(user,target)
      removeProtections(target)
    end   
  end
  
  #===============================================================================
  # Decreases the target's Special Attack by 1 stage. Always hits. (Confide)
  #===============================================================================
  class PokeBattle_Move_13C < PokeBattle_TargetStatDownMove
    def ignoresSubstitute?(user); return true; end
  
    def initialize(battle,move)
      super
      @statDown = [:SPECIAL_ATTACK,1]
    end
  
    def pbAccuracyCheck(user,target); return true; end
  end
  
  #===============================================================================
  # Decreases the target's Special Attack by 2 stages. (Eerie Impulse)
  #===============================================================================
  class PokeBattle_Move_13D < PokeBattle_TargetStatDownMove
    def initialize(battle,move)
      super
      @statDown = [:SPECIAL_ATTACK,2]
    end
  end
  
  #===============================================================================
  # Increases the Attack and Special Attack of all Grass-type Pokémon in battle by
  # 1 stage each. (Rototiller)
  #===============================================================================
  class PokeBattle_Move_13E < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      @battle.eachBattler do |b|
        return false if isValidTarget?(user,b)
      end
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end

    def isValidTarget?(user,target)
      return false if !target.pbHasType?(:GRASS)
      return false if target.semiInvulnerable?
      return false if !target.pbCanRaiseStatStage?(:ATTACK,user,self) && !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      return true
    end
  
    def pbFailsAgainstTarget?(user,target)
      return !isValidTarget?(user,target)
    end
  
    def pbEffectAgainstTarget(user,target)
      target.pbRaiseMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1],user,move: self)
    end

    def getScore(score,user,target,skill=100)
			if isValidTarget?(user,target)
        score += 30
				score -= user.stages[:DEFENSE] * 5
        score -= user.stages[:SPECIAL_DEFENSE] * 5
			end
      return score
    end
  end
  
  #===============================================================================
  # Increases the Defense and Sp. Def of all Grass-type self and allies by 1 stage each.
  # (Flower Shield)
  #===============================================================================
  class PokeBattle_Move_13F < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      @battle.eachBattler do |b|
        return false if isValidTarget?(user,b)
      end
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end

    def isValidTarget?(user,target)
      return false if !target.pbHasType?(:GRASS)
      return false if target.semiInvulnerable?
      return false if !target.pbCanRaiseStatStage?(:DEFENSE,user,self) && !target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
      return true
    end
  
    def pbFailsAgainstTarget?(user,target)
      return !isValidTarget?(user,target)
    end
  
    def pbEffectAgainstTarget(user,target)
      target.pbRaiseMultipleStatStages([:DEFENSE,1,:SPECIAL_DEFENSE,1],user,move: self)
    end

    def getScore(score,user,target,skill=100)
			if isValidTarget?(user,target)
        score += 30
				score -= user.stages[:DEFENSE] * 5
        score -= user.stages[:SPECIAL_DEFENSE] * 5
			end
      return score
    end
  end
  
  #===============================================================================
  # Decreases the Attack, Special Attack and Speed of all nearby poisoned foes
  # by 1. (Venom Drench)
  #===============================================================================
  class PokeBattle_Move_140 < PokeBattle_Move
    def initialize(battle, move)
      super
      @statDown = [:ATTACK,1,:SPECIAL_ATTACK,1,:SPEED,1]
    end

    def pbMoveFailed?(user,targets)
      @battle.eachBattler do |b|
        return false if isValidTarget?(user,b)
      end
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end

    def isValidTarget?(user,target)
      return false if target.fainted?
      return false if !target.poisoned?
      return false if !target.pbCanLowerStatStage?(:ATTACK,user,self) &&
                !target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user,self) &&
                !target.pbCanLowerStatStage?(:SPEED,user,self)
      return true
    end
  
    def pbFailsAgainstTarget?(user,target)
      return !isValidTarget?(user,target)
    end
  
    def pbEffectAgainstTarget(user,target)
      target.pbLowerMultipleStatStages(@statDown, user, move: self)
    end

    def getScore(score,user,target,skill=100)
			if isValidTarget?(user,target)
        score += 30
        score += target.stages[:ATTACK] * 5
        score += target.stages[:SPECIAL_ATTACK] * 5
        score += target.stages[:SPEED] * 5
			end
      return score
    end
  end
  
  #===============================================================================
  # Reverses all stat changes of the target. (Topsy-Turvy)
  #===============================================================================
  class PokeBattle_Move_141 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      failed = true
      GameData::Stat.each_battle do |s|
        next if target.stages[s.id] == 0
        failed = false
        break
      end
      if failed
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      GameData::Stat.each_battle { |s| target.stages[s.id] *= -1 }
      @battle.pbDisplay(_INTL("{1}'s stats were reversed!",target.pbThis))
    end

    def getScore(score,user,target,skill=100)
      score -= 40
      netStages = 0
      GameData::Stat.each_battle do |s|
        netStages += target.stages[s.id]
      end
      if user.opposes?(target)
        score += netStages * 10
      else
        score -= netStages * 10
      end
      return score
    end
  end
  
  #===============================================================================
  # Gives target the Ghost type. (Trick-or-Treat)
  #===============================================================================
  class PokeBattle_Move_142 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if !GameData::Type.exists?(:GHOST) || target.pbHasType?(:GHOST) || !target.canChangeType?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.applyEffect(:Type3,:GHOST)
    end
  end
  
  #===============================================================================
  # Gives target the Grass type. (Forest's Curse)
  #===============================================================================
  class PokeBattle_Move_143 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if !GameData::Type.exists?(:GRASS) || target.pbHasType?(:GRASS) || !target.canChangeType?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.applyEffect(:Type3,:GRASS)
    end
  end
  
  #===============================================================================
  # Type effectiveness is multiplied by the Flying-type's effectiveness against
  # the target. (Flying Press)
  #===============================================================================
  class PokeBattle_Move_144 < PokeBattle_Move  
    def pbCalcTypeModSingle(moveType,defType,user,target)
      ret = super
      if GameData::Type.exists?(:FLYING)
        flyingEff = Effectiveness.calculate_one(:FLYING, defType)
        ret *= flyingEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
      end
      return ret
    end
  end
  
  #===============================================================================
  # Target's moves become Electric-type for the rest of the round. (Electrify)
  #===============================================================================
  class PokeBattle_Move_145 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if target.effectActive?(:Electrify)
        @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} was already electrified!"))
        return true
      end
      return true if pbMoveFailedTargetAlreadyMoved?(target)
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.applyEffect(:Electrify)
    end

    def getScore(score,user,target,skill=100)
      score -= 40 # Move sucks
      return score
    end
  end
  
  #===============================================================================
  # All Normal-type moves become Electric-type for the rest of the round.
  # (Ion Deluge, Plasma Fists)
  #===============================================================================
  class PokeBattle_Move_146 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      return false if damagingMove?
      if @battle.field.effectActive?(:IonDeluge)
        @battle.pbDisplay(_INTL("But it failed, since ions already shower the field!"))
        return true
      end
      return true if pbMoveFailedLastInRound?(user)
      return false
    end
  
    def pbEffectGeneral(user)
      @battle.field.applyEffect(:IonDeluge)
    end
  end
  
  #===============================================================================
  # Always hits. Ends target's protections immediately. (Hyperspace Hole)
  #===============================================================================
  class PokeBattle_Move_147 < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
    def pbAccuracyCheck(user,target); return true; end
  
    def pbEffectAgainstTarget(user,target)
      removeProtections(target)
    end
  end
  
  #===============================================================================
  # Powders the foe. This round, if it uses a Fire move, it loses 1/4 of its max
  # HP instead. (Powder)
  #===============================================================================
  class PokeBattle_Move_148 < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbFailsAgainstTarget?(user,target)
      if target.effectActive?(:Powder)
        @battle.pbDisplay(_INTL("But it failed, since the target is already covered in powder!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.applyEffect(:Powder)
    end

    def getScore(score,user,target,skill=100)
      if target.pbHasMoveType?(:FIRE)
        score += 50 
      else
        score -= 50 
      end
      return score
    end
  end
  
  #===============================================================================
  # This round, the user's side is unaffected by damaging moves. (Mat Block)
  #===============================================================================
  class PokeBattle_Move_149 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if !user.firstTurn? || user.pbOwnSide.effectActive?(:MatBlock)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if pbMoveFailedLastInRound?(user)
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbOwnSide.applyEffect(:MatBlock)
    end

    def getScore(score,user,target,skill=100)
      score += 20 if user.hasAlly?
      # Check only status having pokemon
      user.eachOpposing() do |b|
        next if !b.hasDamagingAttack?
        score += 20
      end
      return score
    end
  end
  
  #===============================================================================
  # User's side is protected against status moves this round. (Crafty Shield)
  #===============================================================================
  class PokeBattle_Move_14A < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if user.pbOwnSide.effectActive?(:CraftyShield)
        @battle.pbDisplay(_INTL("But it failed, since a crafty shield is already protecting #{user.pbTeam(true)}!"))
        return true
      end
      return true if pbMoveFailedLastInRound?(user)
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbOwnSide.applyEffect(:CraftyShield)
    end

    def getScore(score,user,target,skill=100)
      score -= 20
      score -= 20 if !user.hasAlly?
      # Check only status having pokemon
      user.eachOpposing do |b|
        next if !b.hasStatusMove?
        score += 20
      end
      return score
    end
  end
  
  #===============================================================================
  # User is protected against damaging moves this round. Decreases the Attack of
  # the user of a stopped physical move by 2 stages. (King's Shield)
  #===============================================================================
  class PokeBattle_Move_14B < PokeBattle_ProtectMove
    def initialize(battle,move)
      super
      @effect = :KingsShield
    end

    def getScore(score,user,target,skill=100)
      score = super
      # Check only physical attackers
      user.eachPotentialAttacker(0) do |b|
        score += 20
      end
      return score
    end
  end
  
  #===============================================================================
  # User is protected against moves that target it this round. Damages the user of
  # a stopped physical move by 1/8 of its max HP. (Spiky Shield)
  #===============================================================================
  class PokeBattle_Move_14C < PokeBattle_ProtectMove
    def initialize(battle,move)
      super
      @effect = :SpikyShield
    end

    def getScore(score,user,target,skill=100)
      score = super
      # Check only physical attackers
      user.eachPotentialAttacker(0) do |b|
        score += 20
      end
      return score
    end
  end
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Phantom Force)
  # Is invulnerable during use. Ends target's protections upon hit.
  #===============================================================================
  class PokeBattle_Move_14D < PokeBattle_Move_0CD
    # NOTE: This move is identical to function code 0CD (Shadow Force).
  end
  
  #===============================================================================
  # Two turn attack. Skips first turn, and increases the user's Special Attack,
  # Special Defense and Speed by 2 stages each in the second turn. (Geomancy)
  #===============================================================================
  class PokeBattle_Move_14E < PokeBattle_TwoTurnMove
    def initialize(battle, move)
      super
      @statUp = [:SPECIAL_ATTACK,2,:SPECIAL_DEFENSE,2,:SPEED,2]
    end

    def pbMoveFailed?(user,targets)
      return false if user.effectActive?(:TwoTurnAttack)   # Charging turn
      if !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self) &&
         !user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self) &&
         !user.pbCanRaiseStatStage?(:SPEED,user,self)
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis))
        return true
      end
      return false
    end
  
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} is absorbing power!",user.pbThis))
    end
  
    def pbEffectGeneral(user)
      return if !@damagingTurn
      user.pbRaiseMultipleStatStages(@statUp,user,move: self)
    end

    def getScore(score,user,target,skill=100)
      score += 30 if user.firstTurn? && user.hasSpecialAttack?
      score -= user.stages[:SPECIAL_ATTACK] * 10
      score -= user.stages[:SPECIAL_DEFENSE] * 10
      score -= user.stages[:SPEED] * 10
      super
    end
  end
  
  #===============================================================================
  # User gains 3/4 the HP it inflicts as damage. (Draining Kiss, Oblivion Wing)
  #===============================================================================
  class PokeBattle_Move_14F < PokeBattle_DrainMove
      def drainFactor(user,target); return 0.75; end
  end
  
  #===============================================================================
  # If this move KO's the target, increases the user's Attack by 3 stages.
  # (Fell Stinger)
  #===============================================================================
  class PokeBattle_Move_150 < PokeBattle_Move
    # Used to modify the AI elsewhere
    def hasKOEffect?(user,target)
        return false if !user.pbCanRaiseStatStage?(:ATTACK,user,self)
        return true
    end

    def pbEffectAfterAllHits(user,target)
        return if !target.damageState.fainted
        user.tryRaiseStat(:ATTACK,user,increment: 3, move: self)
    end
  end
  
  #===============================================================================
  # Decreases the target's Attack and Special Attack by 1 stage each. Then, user
  # switches out. Ignores trapping moves. (Parting Shot)
  #===============================================================================
  class PokeBattle_Move_151 < PokeBattle_TargetMultiStatDownMove
    def initialize(battle,move)
      super
      @statDown = [:ATTACK,1,:SPECIAL_ATTACK,1]
    end
  
    def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
      switcher = user
      targets.each do |b|
        next if switchedBattlers.include?(b.index)
        switcher = b if b.effectActive?(:MagicCoat) || b.effectActive?(:MagicBounce)
      end
      return if switcher.fainted? || numHits==0
      return if !@battle.pbCanChooseNonActive?(switcher.index)
      @battle.pbDisplay(_INTL("{1} went back to {2}!",switcher.pbThis,@battle.pbGetOwnerName(switcher.index)))
      @battle.pbPursuit(switcher.index)
      return if switcher.fainted?
      newPkmn = @battle.pbGetReplacementPokemonIndex(switcher.index)   # Owner chooses
      return if newPkmn<0
      @battle.pbRecallAndReplace(switcher.index,newPkmn)
      @battle.pbClearChoice(switcher.index)   # Replacement Pokémon does nothing this round
      @battle.moldBreaker = false if switcher.index==user.index
      switchedBattlers.push(switcher.index)
      switcher.pbEffectsOnSwitchIn(true)
    end

    def getScore(score,user,target,skill=100)
      score = getSwitchOutMoveScore(score,user,target,skill)
      return score
    end
  end
  
  #===============================================================================
  # No Pokémon can switch out or flee until the end of the next round. (Fairy Lock)
  #===============================================================================
  class PokeBattle_Move_152 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if @battle.field.effectActive?(:FairyLock)
        @battle.pbDisplay(_INTL("But it failed, since a Fairy Lock is already active!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      @battle.field.applyEffect(:FairyLock,2)
      @battle.pbDisplay(_INTL("No one will be able to run away during the next turn!"))
    end

    def getScore(score,user,target,skill=100)
      echoln("The AI will never use Fairy Lock.")
      return 0 # The move is both annoying and very weak
    end
  end
  
  #===============================================================================
  # Entry hazard. Lays stealth rocks on the opposing side. (Sticky Web)
  #===============================================================================
  class PokeBattle_Move_153 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if user.pbOpposingSide.effectActive?(:StickyWeb)
        @battle.pbDisplay(_INTL("But it failed, since a Sticky Web is already laid out!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbOpposingSide.applyEffect(:StickyWeb)
    end

    def getScore(score,user,target,skill=100)
      return getHazardSettingMoveScore(score,user,target,skill)
    end
  end
  
  #===============================================================================
  # For 5 rounds, creates an electric terrain which boosts Electric-type moves and
  # prevents Pokémon from falling asleep. Affects non-airborne Pokémon only.
  # (Electric Terrain)
  #===============================================================================
  class PokeBattle_Move_154 < PokeBattle_TerrainMove
    def initialize(battle,move)
      super
      @terrainType = :Electric
    end
  end
  
  #===============================================================================
  # For 5 rounds, creates a grassy terrain which boosts Grass-type moves and heals
  # Pokémon at the end of each round. Affects non-airborne Pokémon only.
  # (Grassy Terrain)
  #===============================================================================
  class PokeBattle_Move_155 < PokeBattle_TerrainMove
    def initialize(battle,move)
      super
      @terrainType = :Grassy
    end
  end
  
  #===============================================================================
  # For 5 rounds, creates a misty terrain which strengthens Fairy-type moves and
  # protects Pokémon from burn, frostbite, and numb. Affects non-airborne Pokémon only.
  # (Fairy Terrain)
  #===============================================================================
  class PokeBattle_Move_156 < PokeBattle_TerrainMove
    def initialize(battle,move)
      super
      @terrainType = :Misty
    end
  end
  
  #===============================================================================
  # Doubles the prize money the player gets after winning the battle. (Happy Hour)
  #===============================================================================
  class PokeBattle_Move_157 < PokeBattle_Move
    def pbEffectGeneral(user)
      @battle.field.applyEffect(:HappyHour) if !user.opposes?
      @battle.pbDisplay(_INTL("Everyone is caught up in the happy atmosphere!"))
    end

    def getScore(score,user,target,skill=100)
      echoln("The AI will never use Happy Hour.")
      return 0
    end
  end
  
  #===============================================================================
  # Fails unless user has consumed a berry at some point. (Belch)
  #===============================================================================
  class PokeBattle_Move_158 < PokeBattle_Move
    def pbCanChooseMove?(user,commandPhase,showMessages)
      if !user.belched?
        if showMessages
          msg = _INTL("{1} hasn't eaten any held berry, so it can't possibly belch!",user.pbThis)
          (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
        end
        return false
      end
      return true
    end
  
    def pbMoveFailed?(user,targets)
      if !user.belched?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  end
  
  #===============================================================================
  # Poisons the target and decreases its Speed by 1 stage. (Toxic Thread)
  #===============================================================================
  class PokeBattle_Move_159 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if !target.canPoison?(user,false,self) &&
         !target.pbCanLowerStatStage?(:SPEED,user,self)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.applyPoison(user) if target.canPoison?(user,false,self)
      target.tryLowerStat(:SPEED,user,move: self)
    end
  end
  
  #===============================================================================
  # Cures the target's burn. (Sparkling Aria)
  #===============================================================================
  class PokeBattle_Move_15A < PokeBattle_Move
    def pbAdditionalEffect(user,target)
      return if target.fainted? || target.damageState.substitute
      return if target.status != :BURN
      target.pbCureStatus(true,:BURN)
    end

    def getScore(score,user,target,skill=100)
      if !target.substituted? && target.burned?
        if target.opposes?(user)
          score -= 30
        else
          score += 30
        end
      end
      return score
    end
  end
  
  #===============================================================================
  # Cures the target's permanent status problems. Heals user by 1/2 of its max HP.
  # (Purify)
  #===============================================================================
  class PokeBattle_Move_15B < PokeBattle_HalfHealingMove
    def pbFailsAgainstTarget?(user,target)
      if !target.pbHasAnyStatus?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.pbCureStatus
      super
    end

    def getScore(score,user,target,skill=100)
      # The target for this is set as the user since its the user that heals
      score = getHealingMoveScore(score,user,user,skill,5)
      score += 30
      return score
    end
  end
  
  #===============================================================================
  # TODO: Currently unused.
  #===============================================================================
  class PokeBattle_Move_15C < PokeBattle_Move
  end
  
  #===============================================================================
  # User gains stat stages equal to each of the target's positive stat stages,
  # and target's positive stat stages become 0, before damage calculation.
  # (Spectral Thief)
  #===============================================================================
  class PokeBattle_Move_15D < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbCalcDamage(user,target,numTargets=1)
      if target.hasRaisedStatStages?
        pbShowAnimation(@id,user,target,1)   # Stat stage-draining animation
        @battle.pbDisplay(_INTL("{1} stole the target's boosted stats!",user.pbThis))
        showAnim = true
        GameData::Stat.each_battle do |s|
          next if target.stages[s.id] <= 0
          if user.pbCanRaiseStatStage?(s.id,user,self)
            if user.pbRaiseStatStage(s.id,target.stages[s.id],user,showAnim)
              showAnim = false
            end
          end
          target.stages[s.id] = 0
        end
      end
      super
    end

    def getScore(score,user,target,skill=100)
			GameData::Stat.each_battle do |s|
				next if target.stages[s.id] <= 0
				score += target.stages[s.id] * 15
			end
      return score
    end

    def shouldHighlight?(user,target)
      return target.hasRaisedStatStages?
    end
  end
  
  #===============================================================================
  # Until the end of the next round, the user's moves will always be critical hits.
  # (Laser Focus)
  #===============================================================================
  class PokeBattle_Move_15E < PokeBattle_Move
    def pbEffectGeneral(user)
      user.applyEffect(:LaserFocus,2)
      @battle.pbDisplay(_INTL("{1} concentrated intensely!",user.pbThis))
    end

    def getScore(score,user,target,skill=100)
      return 0 if user.effectActive?(:LaserFocus)
      score -= 20 # Move isn't very strong
      return score
    end
  end
  
  #===============================================================================
  # Decreases the user's Defense by 1 stage. (Clanging Scales)
  #===============================================================================
  class PokeBattle_Move_15F < PokeBattle_StatDownMove
    def initialize(battle,move)
      super
      @statDown = [:DEFENSE,1]
    end
  end
  
  #===============================================================================
  # Decreases the target's Attack by 1 stage. Heals user by an amount equal to the
  # target's Attack stat (after applying stat stages, before this move decreases
  # it). (Strength Sap)
  #===============================================================================
  class PokeBattle_Move_160 < PokeBattle_Move
    def healingMove?; return true; end
  
    def pbFailsAgainstTarget?(user,target)
      # NOTE: The official games appear to just check whether the target's Attack
      #       stat stage is -6 and fail if so, but I've added the "fail if target
      #       has Contrary and is at +6" check too for symmetry. This move still
      #       works even if the stat stage cannot be changed due to an ability or
      #       other effect.
      if !@battle.moldBreaker && target.hasActiveAbility?(:CONTRARY) &&
         target.statStageAtMax?(:ATTACK)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      elsif target.statStageAtMin?(:ATTACK)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      healAmount = target.pbAttack
      # Reduce target's Attack stat
      target.tryLowerStat(:ATTACK,user,move: self)
      # Heal user
      if target.hasActiveAbility?(:LIQUIDOOZE)
        @battle.pbShowAbilitySplash(target)
        user.pbReduceHP(healAmount)
        @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",user.pbThis))
        @battle.pbHideAbilitySplash(target)
        user.pbItemHPHealCheck
      elsif user.canHeal?
        healAmount = healAmount * 1.3 if user.hasActiveItem?(:BIGROOT)
        user.pbRecoverHP(healAmount)
      end
    end

    def getScore(score,user,target,skill=100)
      if target.pbCanLowerStatStage?(:ATTACK,user)
        score += target.stages[:ATTACK] * 20
        if target.hasPhysicalAttack?
          score += 20
        end
      end
      score = getHealingMoveScore(score,user,user,skill,2)
      return score
    end
  end
  
  #===============================================================================
  # User and target swap their Speed stats (not their stat stages). (Speed Swap)
  #===============================================================================
  class PokeBattle_Move_161 < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbEffectAgainstTarget(user,target)
      user.speed, target.speed = target.speed, user.speed
      @battle.pbDisplay(_INTL("{1} switched Speed with its target!",user.pbThis))
    end

    def getScore(score,user,target,skill=100)
      score = getWantsToBeSlowerScore(score,user,target,skill,magnitude=8)
      return score
    end
  end
  
  #===============================================================================
  # User loses their Fire type. Fails if user is not Fire-type. (Burn Up)
  #===============================================================================
  class PokeBattle_Move_162 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if !user.pbHasType?(:FIRE)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAfterAllHits(user,target)
      user.applyEffect(:BurnUp)
    end

    def getScore(score,user,target,skill=100)
      score -= 20
      return score
    end
  end
  
  #===============================================================================
  # Ignores all abilities that alter this move's success or damage.
  # (Moongeist Beam, Sunsteel Strike)
  #===============================================================================
  class PokeBattle_Move_163 < PokeBattle_Move
    def pbChangeUsageCounters(user,specialUsage)
      super
      @battle.moldBreaker = true if !specialUsage
    end

    def getScore(score,user,target,skill=100)
      score += 10
      return score
    end
  end
  
  #===============================================================================
  # Ignores all abilities that alter this move's success or damage. This move is
  # physical if user's Attack is higher than its Special Attack (after applying
  # stat stages), and special otherwise. (Photon Geyser)
  #===============================================================================
  class PokeBattle_Move_164 < PokeBattle_Move_163
    def initialize(battle,move)
      super
      @calculated_category = 1
    end
  
    def calculateCategory(user,targets)
      return selectBestCategory(user)
    end
  end
  
  #===============================================================================
  # Negates the target's ability while it remains on the field, if it has already
  # performed its action this round. (Core Enforcer)
  #===============================================================================
  class PokeBattle_Move_165 < PokeBattle_Move
    def pbEffectAgainstTarget(user,target)
      return if target.damageState.substitute || target.effectActive?(:GastroAcid)
      return if target.unstoppableAbility?
      return if @battle.choices[target.index][0]!=:UseItem &&
                !((@battle.choices[target.index][0]==:UseMove ||
                @battle.choices[target.index][0]==:Shift) && target.movedThisRound?)
      target.applyEffect(:GastroAcid)
    end

    def getScore(score,user,target,skill=100)
      if !target.substituted? && !target.effectActive?(:GastroAcid)
        score = getWantsToBeSlowerScore(score,user,target,skill,3)
      end
      return score
    end
  end
  
  #===============================================================================
  # Power is doubled if the user's last move failed. (Stomping Tantrum)
  #===============================================================================
  class PokeBattle_Move_166 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if user.lastRoundMoveFailed
      return baseDmg
    end
  end
  
  #===============================================================================
  # For 5 rounds, lowers power of attacks against the user's side. Fails if
  # weather is not hail. (Aurora Veil)
  #===============================================================================
  class PokeBattle_Move_167 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if @battle.pbWeather != :Hail
        @battle.pbDisplay(_INTL("But it failed, since it's not Hailing!"))
        return true
      end
      if user.pbOwnSide.effectActive?(:AuroraVeil)
        @battle.pbDisplay(_INTL("But it failed, since Aurora Veil is already active!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbOwnSide.applyEffect(:AuroraVeil,user.getScreenDuration())
    end

    def getScore(score,user,target,skill=100)
      score += 30
      score += 30 if user.firstTurn?
      return score
    end
  end
  
  #===============================================================================
  # User is protected against moves with the "B" flag this round. If a Pokémon
  # attacks the user with a physical move while this effect applies, that Pokémon is
  # poisoned. (Baneful Bunker)
  #===============================================================================
  class PokeBattle_Move_168 < PokeBattle_ProtectMove
    def initialize(battle,move)
      super
      @effect = :BanefulBunker
    end

    def getScore(score,user,target,skill=100)
      score = super
      # Check only physical attackers
      user.eachPotentialAttacker(0) do |b|
        score += getPoisonMoveScore(0,user,b,skill,user.ownersPolicies,statusMove?)
      end
      return score
    end
  end
  
  #===============================================================================
  # This move's type is the same as the user's first type. (Revelation Dance)
  #===============================================================================
  class PokeBattle_Move_169 < PokeBattle_Move
    def pbBaseType(user)
      userTypes = user.pbTypes(true)
      return userTypes[0]
    end
  end
  
  #===============================================================================
  # This round, target becomes the target of attacks that have single targets.
  # (Spotlight)
  #===============================================================================
  class PokeBattle_Move_16A < PokeBattle_Move
    def pbEffectAgainstTarget(user,target)
      maxSpotlight = 0
      target.eachAlly do |b|
        next if b.effects[:Spotlight] <= maxSpotlight
        maxSpotlight = b.effects[:Spotlight]
      end
      target.applyEffect(:Spotlight,maxSpotlight + 1)
    end

    def getScore(score,user,target,skill=100)
      return 0 if !target.hasAlly?
      return score
    end
  end
  
  #===============================================================================
  # The target uses its most recent move again. (Instruct)
  #===============================================================================
  class PokeBattle_Move_16B < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def initialize(battle,move)
      super
      @moveBlacklist = [
         "0D4",   # Bide
         "14B",   # King's Shield
         "16B",   # Instruct (this move)
         # Struggle
         "002",   # Struggle
         # Moves that affect the moveset
         "05C",   # Mimic
         "05D",   # Sketch
         "069",   # Transform
         # Moves that call other moves
         "0AE",   # Mirror Move
         "0AF",   # Copycat
         "0B0",   # Me First
         "0B3",   # Nature Power
         "0B4",   # Sleep Talk
         "0B5",   # Assist
         "0B6",   # Metronome
         # Moves that require a recharge turn
         "0C2",   # Hyper Beam
         # Two-turn attacks
         "0C3",   # Razor Wind
         "0C4",   # Solar Beam, Solar Blade
         "0C5",   # Freeze Shock
         "0C6",   # Ice Burn
         "0C7",   # Sky Attack
         "0C8",   # Skull Bash
         "0C9",   # Fly
         "0CA",   # Dig
         "0CB",   # Dive
         "0CC",   # Bounce
         "0CD",   # Shadow Force
         "0CE",   # Sky Drop
         "12E",   # Shadow Half
         "14D",   # Phantom Force
         "14E",   # Geomancy
         # Moves that start focussing at the start of the round
         "115",   # Focus Punch
         "171",   # Shell Trap
         "172"    # Beak Blast
      ]
    end
  
    def pbFailsAgainstTarget?(user,target)
      if !target.lastRegularMoveUsed || !target.pbHasMove?(target.lastRegularMoveUsed)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if target.usingMultiTurnAttack?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      targetMove = @battle.choices[target.index][2]
      if targetMove && (targetMove.function=="115" ||   # Focus Punch
                        targetMove.function=="171" ||   # Shell Trap
                        targetMove.function=="172")     # Beak Blast
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if @moveBlacklist.include?(GameData::Move.get(target.lastRegularMoveUsed).function_code)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      idxMove = -1
      target.eachMoveWithIndex do |m,i|
        idxMove = i if m.id==target.lastRegularMoveUsed
      end
      if target.moves[idxMove].pp==0 && target.moves[idxMove].total_pp>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.applyEffect(:Instruct)
    end

    def getScore(score,user,target,skill=100)
      return 0 # Much too chaotic of a move to allow the AI to use
    end
  end
  
  #===============================================================================
  # Target cannot use sound-based moves for 2 more rounds. (Throat Chop)
  #===============================================================================
  class PokeBattle_Move_16C < PokeBattle_Move
    def pbAdditionalEffect(user,target)
      return if target.fainted? || target.damageState.substitute
      target.applyEffect(:ThroatChop,3)
    end

    def getScore(score,user,target,skill=100)
      if !target.effectActive?(:ThroatChop) && target.hasSoundMove? && !target.substituted?
        score += 30
      end
      return score
    end
  end
  
  #===============================================================================
  # Heals user by 1/2 of its max HP, or 2/3 of its max HP in a sandstorm. (Shore Up)
  #===============================================================================
  class PokeBattle_Move_16D < PokeBattle_HealingMove
    def healRatio(user)
      if @battle.pbWeather == :Sandstorm
        return 2.0 / 3.0
      end
      return 1.0/2.0
    end
    
    def shouldHighlight?(user,target)
      return @battle.pbWeather == :Sandstorm
    end
  end
  
  #===============================================================================
  # Heals target by 1/2 of its max HP, or 2/3 of its max HP in Grassy Terrain.
  # (Floral Healing)
  #===============================================================================
  class PokeBattle_Move_16E < PokeBattle_Move
    def healingMove?; return true; end
  
    def pbFailsAgainstTarget?(user,target)
      if target.hp==target.totalhp
        @battle.pbDisplay(_INTL("{1}'s HP is full!",target.pbThis))
        return true
      elsif !target.canHeal?
        @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      if @battle.field.terrain == :Grassy
        healAmount = target.totalhp * 2.0/3.0
      else
        healAmount = target.totalhp / 2.0
      end
      healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if target.boss?
      target.pbRecoverHP(healAmount)
    end

    def getScore(score,user,target,skill=100)
      score += 30 if @battle.field.terrain == :Grassy
      score = getHealingMoveScore(score,user,target,skill)
      return score
    end

    def shouldHighlight?(user,target)
      return @battle.field.terrain == :Grassy
    end
  end
  
  #===============================================================================
  # Damages target if target is a foe, or heals target by 1/2 of its max HP if
  # target is an ally. (Pollen Puff)
  #===============================================================================
  class PokeBattle_Move_16F < PokeBattle_Move
    def pbTarget(user)
      return GameData::Target.get(:NearFoe) if user.effectActive?(:HealBlock)
      return super
    end
  
    def pbOnStartUse(user,targets)
      @healing = false
      @healing = !user.opposes?(targets[0]) if targets.length>0
    end
  
    def pbFailsAgainstTarget?(user,target)
      return false if !@healing
      if target.substituted? && !ignoresSubstitute?(user)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if !target.canHeal?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbDamagingMove?
      return false if @healing
      return super
    end
  
    def pbEffectAgainstTarget(user,target)
      return if !@healing
      healAmount = target.totalhp/2.0
      healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if target.boss?
      target.pbRecoverHP(healAmount)
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      hitNum = 1 if @healing   # Healing anim
      super
    end

    def getScore(score,user,target,skill=100)
      if !user.opposes?(target)
        score = getHealingMoveScore(score,user,target,skill)
      end
      return score
    end
  end
  
  #===============================================================================
  # Damages user by 1/2 of its max HP, even if this move misses. (Mind Blown)
  #===============================================================================
  class PokeBattle_Move_170 < PokeBattle_Move
    def worksWithNoTargets?; return true; end
  
    def pbMoveFailed?(user,targets)
      if !@battle.moldBreaker
        bearer = @battle.pbCheckGlobalAbility(:DAMP)
        if bearer!=nil
          @battle.pbShowAbilitySplash(bearer)
          @battle.pbDisplay(_INTL("{1} cannot use {2}!",user.pbThis,@name))
          @battle.pbHideAbilitySplash(bearer)
          return true
        end
      end
      return false
    end
  
    def pbSelfKO(user)
      return if !user.takesIndirectDamage?
      user.pbReduceHP((user.totalhp/2.0).round,false)
      user.pbItemHPHealCheck
    end

    def getScore(score,user,target,skill=100)
      if user.hp <= user.totalhp / 2
        return 0 if !user.alliesInReserve?
      end
      score -= 40
      return score
    end
  end
  
  #===============================================================================
  # Fails if user has not been hit by an opponent's physical move this round.
  # (Shell Trap)
  #===============================================================================
  class PokeBattle_Move_171 < PokeBattle_Move
    def pbDisplayChargeMessage(user)
      user.applyEffect(:ShellTrap)
    end
  
    def pbDisplayUseMessage(user,targets)
      super if user.tookPhysicalHit
    end
  
    def pbMoveFailed?(user,targets)
      if !user.effectActive?(:ShellTrap)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if !user.tookPhysicalHit
        @battle.pbDisplay(_INTL("{1}'s shell trap didn't work!",user.pbThis))
        return true
      end
      return false
    end

    def getScore(score,user,target,skill=100)
      score = 0 if !target.hasPhysicalAttack?
      return score
    end
  end
  
  #===============================================================================
  # If a Pokémon attacks the user with a physical move before it uses this move, the
  # attacker is burned. (Beak Blast)
  #===============================================================================
  class PokeBattle_Move_172 < PokeBattle_Move
    def pbDisplayChargeMessage(user)
      user.applyEffect(:BeakBlast)
    end

    def getScore(score,user,target,skill=100)
      score += 30 if target.hasPhysicalAttack?
      return score
    end
  end
  
  #===============================================================================
  # For 5 rounds, creates a psychic terrain which boosts Psychic-type moves and
  # prevents Pokémon from being hit by >0 priority moves. Affects non-airborne
  # Pokémon only. (Psychic Terrain)
  #===============================================================================
  class PokeBattle_Move_173 < PokeBattle_TerrainMove
    def initialize(battle,move)
      super
      @terrainType = :Psychic
    end
  end
  
  #===============================================================================
  # Fails if this isn't the user's first turn. (First Impression, Breach)
  #===============================================================================
  class PokeBattle_Move_174 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if !user.firstTurn?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  end
  
  #===============================================================================
  # Hits twice. Causes the target to flinch. (Double Iron Bash)
  #===============================================================================
  class PokeBattle_Move_175 < PokeBattle_FlinchMove
    def multiHitMove?;              return true; end
    def pbNumHits(user,targets,checkingForAI=false);    return 2;    end
  end

#===============================================================================
# Chance to paralyze the target. Fail if the user is not a Morpeko.
# If the user is a Morpeko-Hangry, this move will be Dark type. (Aura Wheel)
#===============================================================================
class PokeBattle_Move_176 < PokeBattle_NumbMove
  def pbMoveFailed?(user,targets)
    if @id == :AURAWHEEL && !user.countsAs?(:MORPEKO)
      @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis))
      return true
    end
    return false
  end

  def pbBaseType(user)
    ret = :NORMAL
    case user.form
    when 0
      ret = :ELECTRIC
    when 1
      ret = :DARK
    end
    return ret
  end
end

#===============================================================================
# User's Defense is used instead of user's Attack for this move's calculations.
# (Body Press)
#===============================================================================
class PokeBattle_Move_177 < PokeBattle_Move
  def pbAttackingStat(user,target)
    return user,:DEFENSE
  end
end

#===============================================================================
# If the user attacks before the target, or if the target switches in during the
# turn that Fishious Rend is used, its base power doubles. (Fishious Rend, Bolt Beak)
#===============================================================================
class PokeBattle_Move_178 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if @battle.choices[target.index][0]!=:None &&
       ((@battle.choices[target.index][0]!=:UseMove &&
       @battle.choices[target.index][0]==:Shift) || target.movedThisRound?)
    else
      baseDmg *= 2
    end
    return baseDmg
  end
  
  def getScore(score,user,target,skill=100)
    score = getWantsToBeSlowerScore(score,user,target,skill,-5)
    return score
  end
end

#===============================================================================
# Raises all user's stats by 1 stage in exchange for the user losing 1/3 of its
# maximum HP, rounded down. Fails if the user would faint. (Clangorous Soul)
#===============================================================================
class PokeBattle_Move_179 < PokeBattle_Move
  def initialize(battle,move)
		super
		@statUp = [:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:SPEED,1]
	end

  def pbMoveFailed?(user,targets)
    if user.hp <= (user.totalhp/3)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    super
  end
  
  def pbEffectGeneral(user)
    super
    user.applyFractionalDamage(1.0/3.0)
  end
  
  def getScore(score,user,target,skill=100)
    score -= 20
    score -= 50 if user.hp < user.totalhp/2
    super
  end
end

#===============================================================================
# Swaps barriers, veils and other effects between each side of the battlefield.
# (Court Change)
#===============================================================================
class PokeBattle_Move_17A < PokeBattle_Move
  
  def pbMoveFailed?(user,targets)
    playerSide = @battle.sides[0]
    trainerSide = @battle.sides[1]
    GameData::BattleEffect.each_side_effect do |effectData|
      next if !effectData.court_changed?
      id = effectData.id
      return false if playerSide.effectActive?(id) || trainerSide.effectActive?(id)
    end
    @battle.pbDisplay(_INTL("But it failed, since there were no effects to swap!"))
    return true
  end

  def pbEffectGeneral(user)
    effectsPlayer = @battle.sides[0].effects
    effectsTrainer = @battle.sides[1].effects
    GameData::BattleEffect.each_side_effect do |effectData|
      next if !effectData.court_changed?
      id = effectData.id
      effectsPlayer[id], effectsTrainer[id] = effectsTrainer[id], effectsPlayer[id]
    end
    @battle.pbDisplay(_INTL("{1} swapped the battle effects affecting each side of the field!",user.pbThis))
  end
  
  def getScore(score,user,target,skill=100)
    return 0 # TODO
  end
end

#===============================================================================
# The user sharply raises the target's Attack and Sp. Atk stats by decorating
# the target. (Decorate)
#===============================================================================
class PokeBattle_Move_17B < PokeBattle_TargetMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,2,:SPECIAL_ATTACK,2]
  end
end

#===============================================================================
# Hits in 2 volleys. The second volley targets the original target's ally if it
# has one (that can be targeted), or the original target if not. A battler
# cannot be targeted if it is is immune to or protected from this move somehow,
# or if this move will miss it. (Dragon Darts)
# NOTE: This move sometimes shows a different failure message compared to the
#       official games. This is because of the order in which failure checks are
#       done (all checks for each target in turn, versus all targets for each
#       check in turn). This is considered unimportant, and since correcting it
#       would involve extensive code rewrites, it is being ignored.
#===============================================================================
class PokeBattle_Move_17C < PokeBattle_Move_0BD
  def pbNumHits(user, targets,checkingForAI=false)
    if checkingForAI
      return 2
    else
      return 1
    end
  end

  # Hit again if only at the 0th hit
  def pbRepeatHit?(hitNum = 0)
    return hitNum < 1
  end

  def pbModifyTargets(targets, user)
    return if targets.length != 1
    choices = []
    targets[0].allAllies.each { |b| user.pbAddTarget(choices, user, b, self) }
    return if choices.length == 0
    idxChoice = (choices.length > 1) ? @battle.pbRandom(choices.length) : 0
    user.pbAddTarget(targets, user, choices[idxChoice], self, !pbTarget(user).can_choose_distant_target?)
  end

  def pbShowFailMessages?(targets)
    if targets.length > 1
      valid_targets = targets.select { |b| !b.fainted? && !b.damageState.unaffected }
      return valid_targets.length <= 1
    end
    return super
  end

  def pbDesignateTargetsForHit(targets, hitNum)
    valid_targets = []
    targets.each { |b|
      next if b.damageState.unaffected || b.damageState.fainted
      valid_targets.push(b) 
    }
    indexThisHit = hitNum % targets.length
    if indexThisHit == 2
      if valid_targets[2]
        return [valid_targets[2]]
      else
        indexThisHit = 1
      end
    end
    return [valid_targets[1]] if indexThisHit = 1 && valid_targets[1]
    return [valid_targets[0]]
  end
end

#===============================================================================
# Prevents both the user and the target from escaping. (Jaw Lock)
#===============================================================================
class PokeBattle_Move_17D < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    if !user.effectActive?(:JawLock) && !target.effectActive?(:JawLock)
      user.applyEffect(:JawLock)
      target.applyEffect(:JawLock)
      user.pointAt(:JawLockUser,target)
      target.pointAt(:JawLockUser,user)
      @battle.pbDisplay(_INTL("Neither Pokémon can escape!"))
    end
  end
end

#===============================================================================
# The user restores 1/4 of its maximum HP, rounded half up. If there is and
# adjacent ally, the user restores 1/4 of both its and its ally's maximum HP,
# rounded up. (Life Dew)
#===============================================================================
class PokeBattle_Move_17E < PokeBattle_Move
  def healingMove?; return true; end
  def worksWithNoTargets?; return true; end

  def healRatio(user)
    return 1.0/4.0
  end

  def pbMoveFailed?(user,targets)
    failed = true
    @battle.eachSameSideBattler(user) do |b|
      next if b.hp == b.totalhp
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user,target)
    if target.hp==target.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",target.pbThis))
      return true
    elsif !target.canHeal?
      @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    hpGain = (target.totalhp/4.0).round
    target.pbRecoverHP(hpGain)
  end
  
  def getScore(score,user,target,skill=100)
    score += 20 if user.hp < user.totalhp
    score += 20 if user.hp < user.totalhp/2
    score += 20 if target.hp < target.totalhp
    score += 20 if target.hp < target.totalhp/2
    score -= 80 if !user.canHeal?
    score -= 80 if !target.canHeal?
    return score
  end
end

#===============================================================================
# Increases each stat by 1 stage. Prevents user from fleeing. (No Retreat)
#===============================================================================
class PokeBattle_Move_17F < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
		super
		@statUp = [:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:SPEED,1]
	end

  def pbMoveFailed?(user,targets)
    if user.effectActive?(:NoRetreat)
      @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already committed to the battle!"))
      return true
    end
    super
  end

  def pbEffectGeneral(user)
    super
    user.applyEffect(:NoRetreat)
  end
end