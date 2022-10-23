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
  # Entry hazard. Lays spikes on the opposing side (max. 3 layers). (Spikes)
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
  class PokeBattle_Move_104 < PokeBattle_TypeSpikeMove
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
  # NOTE: In Gen 6+, if the user levels up after this move is used, the amount of
  #       money picked up depends on the user's new level rather than its level
  #       when it used the move. I think this is silly, so I haven't coded this
  #       effect.
  #===============================================================================
  class PokeBattle_Move_109 < PokeBattle_Move
    def pbEffectGeneral(user)
      if user.pbOwnedByPlayer?
        @battle.field.effects[PBEffects::PayDay] += 5*user.level
      end
      @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
    end
  end
  
  #===============================================================================
  # Ends the opposing side's screen effects.(Brick Break, Psychic Fangs)
  #===============================================================================
  class PokeBattle_Move_10A < PokeBattle_Move
    def ignoresReflect?; return true; end
  
    def pbEffectWhenDealingDamage(user,target)
      side = target.pbOwnSide
      side.eachEffectWithData(true) do |effect,value,data|
        side.disableEffect(effect) if data.is_screen?
      end
    end
  
    def pbShowAnimation(id,user,targets,hitNum = 0,showAnimation=true)
      targets.each do |b|
        side = b.pbOwnSide
        side.eachEffectWithData(true) do |effect,value,data|
          # Wall-breaking anim
          if data.is_screen?
            hitNum = 1 
            break
          end
        end
      end
      super
    end

    def getScore(score,user,target,skill=100)
      side = target.pbOwnSide
      side.eachEffectWithData(true) do |effect,value,data|
        score += 10 if data.is_screen?
      end
      return score
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
      return if !user.takesIndirectDamage?
      @battle.pbDisplay(_INTL("{1} kept going and crashed!",user.pbThis))
      user.applyFractionalDamage(1.0/2.0)
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
      @subLife = user.totalhp/4
      @subLife = 1 if @subLife<1
      if user.hp <= @subLife
        @battle.pbDisplay(_INTL("But it does not have enough HP left to make a substitute!"))
        return true
      end
      return false
    end
  
    def pbOnStartUse(user,targets)
      user.pbReduceHP(@subLife,false,false)
      user.pbItemHPHealCheck
    end
  
    def pbEffectGeneral(user)
      user.effects[PBEffects::Trapping]     = 0
      user.effects[PBEffects::TrappingMove] = nil
      user.effects[PBEffects::Substitute]   = @subLife
      @battle.pbDisplay(_INTL("{1} put in a substitute!",user.pbThis))
    end

    def getScore(score,user,target,skill=100)
      score += 20 if user.firstTurn?
      user.eachOpposing(true) do |b|
        if b.effects[PBEffects::HyperBeam] > 0
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
      if user.pbHasType?(:GHOST) && target.effects[PBEffects::Curse]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      return if user.pbHasType?(:GHOST)
      # Non-Ghost effect
      if user.pbCanLowerStatStage?(:SPEED,user,self)
        user.pbLowerStatStage(:SPEED,1,user)
      end
      showAnim = true
      if user.pbCanRaiseStatStage?(:ATTACK,user,self)
        if user.pbRaiseStatStage(:ATTACK,1,user,showAnim)
          showAnim = false
        end
      end
      if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
        user.pbRaiseStatStage(:DEFENSE,1,user,showAnim)
      end
    end
  
    def pbEffectAgainstTarget(user,target)
      return if !user.pbHasType?(:GHOST)
      # Ghost effect
      @battle.pbDisplay(_INTL("{1} cut its own HP and laid a curse on {2}!",user.pbThis,target.pbThis(true)))
      target.effects[PBEffects::Curse] = true
      user.applyFractionalDamage(1.0/4.0,false)
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
      if !target.asleep? || target.effects[PBEffects::Nightmare]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::Nightmare] = true
      @battle.pbDisplay(_INTL("{1} began having a nightmare!",target.pbThis))
    end

    def getScore(score,user,target,skill=100)
      score -= 30
      score += 30 * target.statusCount
      return score
    end
  end
  
  #===============================================================================
  # Removes trapping moves, entry hazards and Leech Seed on user/user's side.
  # (Rapid Spin)
  #===============================================================================
  class PokeBattle_Move_110 < PokeBattle_Move
    def pbEffectAfterAllHits(user,target)
      return if user.fainted? || target.damageState.unaffected
      if user.effects[PBEffects::Trapping]>0
        trapMove = GameData::Move.get(user.effects[PBEffects::TrappingMove]).name
        trapUser = @battle.battlers[user.effects[PBEffects::TrappingUser]]
        @battle.pbDisplay(_INTL("{1} got free of {2}'s {3}!",user.pbThis,trapUser.pbThis(true),trapMove))
        user.effects[PBEffects::Trapping]     = 0
        user.effects[PBEffects::TrappingMove] = nil
        user.effects[PBEffects::TrappingUser] = -1
      end
      if user.effects[PBEffects::LeechSeed] >= 0
        user.effects[PBEffects::LeechSeed] = -1
        @battle.pbDisplay(_INTL("{1} shed Leech Seed!",user.pbThis))
      end
      user.pbOwnSide.eachEffectWithData(true) do |effect,value,data|
          next unless data.is_hazard?
          user.pbOwnSide.disableEffect(effect)
          hazardName = data.real_name
          @battle.pbDisplay(_INTL("{1} blew away {2}!",user.pbThis, hazardName)) if !data.has_expire_proc?
      end
    end

    def getScore(score,user,target,skill=100)
      if user.alliesInReserve?
        score += hazardWeightOnSide(user.pbOwnSide)
      end
      score += 20 if user.effects[PBEffects::LeechSeed] >= 0
      score += 20 if user.effects[PBEffects::Trapping] > 0
      return score
    end
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
  
    def pbFailsAgainstTarget?(user,target)
      if !@battle.futureSight &&
         @battle.positions[target.index].effects[PBEffects::FutureSightCounter]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      return if @battle.futureSight   # Attack is hitting
      effects = @battle.positions[target.index].effects
      count = 3
      count -= 1 if user.hasActiveAbility?([:BADOMEN])
      effects[PBEffects::FutureSightCounter]        = count
      effects[PBEffects::FutureSightMove]           = @id
      effects[PBEffects::FutureSightUserIndex]      = user.index
      effects[PBEffects::FutureSightUserPartyIndex] = user.pokemonIndex
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
      if user.effects[PBEffects::Stockpile] >= 3
        @battle.pbDisplay(_INTL("{1} can't stockpile any more!",user.pbThis))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.effects[PBEffects::Stockpile] += 1
      @battle.pbDisplay(_INTL("{1} stockpiled {2}!",user.pbThis,user.effects[PBEffects::Stockpile]))
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
      if user.effects[PBEffects::Stockpile]==0
        @battle.pbDisplay(_INTL("But it failed to spit up a thing!"))
        return true
      end
      return false
    end
  
    def pbBaseDamage(baseDmg,user,target)
      return 100*user.effects[PBEffects::Stockpile]
    end
  
    def pbEffectAfterAllHits(user,target)
      return if user.fainted? || user.effects[PBEffects::Stockpile]==0
      return if target.damageState.unaffected
      @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",user.pbThis))
      return if @battle.pbAllFainted?(target.idxOwnSide)
      showAnim = true
      if user.effects[PBEffects::StockpileDef]>0 &&
         user.pbCanLowerStatStage?(:DEFENSE,user,self)
        if user.pbLowerStatStage(:DEFENSE,user.effects[PBEffects::StockpileDef],user,showAnim)
          showAnim = false
        end
      end
      if user.effects[PBEffects::StockpileSpDef]>0 &&
         user.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
        user.pbLowerStatStage(:SPECIAL_DEFENSE,user.effects[PBEffects::StockpileSpDef],user,showAnim)
      end
      user.effects[PBEffects::Stockpile]      = 0
      user.effects[PBEffects::StockpileDef]   = 0
      user.effects[PBEffects::StockpileSpDef] = 0
    end

    def getScore(score,user,target,skill=100)
      score -= 20 * user.effects[PBEffects::Stockpile]
      return score
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
      if user.effects[PBEffects::Stockpile] == 0
        @battle.pbDisplay(_INTL("But it failed to swallow a thing!"))
        return true
      end
      return false
    end

    def healRatio(user)
      case [user.effects[PBEffects::Stockpile],1].max
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
      showAnim = true
      if user.effects[PBEffects::StockpileDef]>0 &&
         user.pbCanLowerStatStage?(:DEFENSE,user,self)
        if user.pbLowerStatStage(:DEFENSE,user.effects[PBEffects::StockpileDef],user,showAnim)
          showAnim = false
        end
      end
      if user.effects[PBEffects::StockpileSpDef] > 0 &&
         user.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
        user.pbLowerStatStage(:SPECIAL_DEFENSE,user.effects[PBEffects::StockpileSpDef],user,showAnim)
      end
      user.effects[PBEffects::Stockpile]      = 0
      user.effects[PBEffects::StockpileDef]   = 0
      user.effects[PBEffects::StockpileSpDef] = 0
    end

    def getScore(score,user,target,skill=100)
      score = super
      score -= 20 * user.effects[PBEffects::Stockpile]
      return score
    end
  end
  
  #===============================================================================
  # Fails if user was hit by a damaging move this round. (Focus Punch)
  #===============================================================================
  class PokeBattle_Move_115 < PokeBattle_Move
    def pbDisplayChargeMessage(user)
      user.effects[PBEffects::FocusPunch] = true
      @battle.pbCommonAnimation("FocusPunch",user)
      @battle.pbDisplay(_INTL("{1} is tightening its focus!",user.pbThis))
    end
  
    def pbDisplayUseMessage(user,targets)
      super if !user.effects[PBEffects::FocusPunch] || user.lastHPLost == 0
    end
  
    def pbMoveFailed?(user,targets)
      if user.effects[PBEffects::FocusPunch] && user.lastHPLost > 0
        @battle.pbDisplay(_INTL("{1} lost its focus and couldn't move!",user.pbThis))
        return true
      end
      return false
    end

    def getScore(score,user,target,skill=100)
      score += 30 if user.effectActive?(:Substitute)
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
      user.effects[PBEffects::FollowMe] = 1
      user.eachAlly do |b|
        next if b.effects[PBEffects::FollowMe] < user.effects[PBEffects::FollowMe]
        user.effects[PBEffects::FollowMe] = b.effects[PBEffects::FollowMe] + 1
      end
      user.effects[PBEffects::RagePowder] = true if @id == :RAGEPOWDER
      @battle.pbDisplay(_INTL("{1} became the center of attention!",user.pbThis))
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
      if @battle.field.effects[PBEffects::Gravity]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      @battle.field.effects[PBEffects::Gravity] = 5
      @battle.pbDisplay(_INTL("Gravity intensified!"))
      @battle.eachBattler do |b|
        showMessage = false
        if b.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly/Bounce/Sky Drop
          disableEffect(:TwoTurnAttack)
          @battle.pbClearChoice(b.index) if !b.movedThisRound?
          showMessage = true
        end
        if b.effects[PBEffects::MagnetRise]>0 ||
           b.effects[PBEffects::Telekinesis]>0 ||
           b.effects[PBEffects::SkyDrop]>=0
          b.effects[PBEffects::MagnetRise]  = 0
          b.effects[PBEffects::Telekinesis] = 0
          b.effects[PBEffects::SkyDrop]     = -1
          showMessage = true
        end
        @battle.pbDisplay(_INTL("{1} couldn't stay airborne because of gravity!",
           b.pbThis)) if showMessage
      end
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
      if user.effects[PBEffects::Ingrain] ||
         user.effects[PBEffects::SmackDown] ||
         user.effects[PBEffects::MagnetRise]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.effects[PBEffects::MagnetRise] = 5
      @battle.pbDisplay(_INTL("{1} levitated with electromagnetism!",user.pbThis))
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
      if target.effects[PBEffects::Ingrain] ||
         target.effects[PBEffects::SmackDown] ||
         target.effects[PBEffects::Telekinesis]>0
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
      target.effects[PBEffects::Telekinesis] = 3
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
                      target.effects[PBEffects::SkyDrop]>=0
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
        return false if target.effectActive?(:Substitute)
      else
        return false if target.damageState.unaffected || target.damageState.substitute
      end
      return false if target.inTwoTurnAttack?("0CE") || target.effects[PBEffects::SkyDrop] >= 0   # Sky Drop
      return false if !target.airborne? && !target.inTwoTurnAttack?("0C9","0CC")   # Fly/Bounce
      return true
    end
  
    def pbEffectAfterAllHits(user,target)
      return if !canSmackDown?(target)
      target.effects[PBEffects::SmackDown]   = true
      if target.inTwoTurnAttack?("0C9","0CC")   # Fly/Bounce. NOTE: Not Sky Drop.
        disableEffect(:TwoTurnAttack)
        @battle.pbClearChoice(target.index) if !target.movedThisRound?
      end
      target.effects[PBEffects::MagnetRise]  = 0
      target.effects[PBEffects::Telekinesis] = 0
      @battle.pbDisplay(_INTL("{1} fell straight down!",target.pbThis))
    end

    def getScore(score,user,target,skill=100)
      if canSmackDown?(target)
        if !target.effects[PBEffects::SmackDown]
          score += 20
        end
        if target.inTwoTurnAttack?("0C9","0CC")
          score += 20
        end
      end
      return score
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
      if target.effects[PBEffects::MoveNext]
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
      target.effects[PBEffects::MoveNext] = true
      target.effects[PBEffects::Quash]    = 0
      @battle.pbDisplay(_INTL("{1} took the kind offer!",target.pbThis))
    end

    def getScore(score,user,target,skill=100)
      return 0 if user.opposes?(target)
      userSpeed = pbRoughStat(user,:SPEED,skill)
		  targetSpeed = pbRoughStat(target,:SPEED,skill)
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
        next if b.effects[PBEffects::Quash]<=highestQuash
        highestQuash = b.effects[PBEffects::Quash]
      end
      if highestQuash>0 && target.effects[PBEffects::Quash]==highestQuash
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
        next if b.effects[PBEffects::Quash]<=highestQuash
        highestQuash = b.effects[PBEffects::Quash]
      end
      target.effects[PBEffects::Quash]    = highestQuash+1
      target.effects[PBEffects::MoveNext] = false
      @battle.pbDisplay(_INTL("{1}'s move was postponed!",target.pbThis))
    end

    def getScore(score,user,target,skill=100)
      return 0 if !user.opposes?(target)
      return 0 if !user.hasAlly?
      userSpeed = pbRoughStat(user,:SPEED,skill)
		  targetSpeed = pbRoughStat(target,:SPEED,skill)
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
      @roomEffect = PBEffects::TrickRoom
      @areaName = "tricky"
      @description = TRICK_ROOM_DESCRIPTION
    end
  end
  
  #===============================================================================
  # User switches places with its ally. (Ally Switch)
  #===============================================================================
  class PokeBattle_Move_120 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      numTargets = 0
      @idxAlly = -1
      idxUserOwner = @battle.pbGetOwnerIndexFromBattlerIndex(user.index)
      user.eachAlly do |b|
        next if @battle.pbGetOwnerIndexFromBattlerIndex(b.index)!=idxUserOwner
        next if !b.near?(user)
        numTargets += 1
        @idxAlly = b.index
      end
      if numTargets!=1
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      idxA = user.index
      idxB = @idxAlly
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
  # Target's Attack is used instead of user's Attack for this move's calculations.
  # (Foul Play)
  #===============================================================================
  class PokeBattle_Move_121 < PokeBattle_Move
    def pbGetAttackStats(user,target)
      if specialMove?
        return target.spatk, target.stages[:SPECIAL_ATTACK]+6
      end
      return target.attack, target.stages[:ATTACK]+6
    end
  end
  
  #===============================================================================
  # Target's Defense is used instead of its Special Defense for this move's
  # calculations. (Psyshock, Psystrike, Secret Sword)
  #===============================================================================
  class PokeBattle_Move_122 < PokeBattle_Move
    def pbGetDefenseStats(user,target)
      return target.defense, target.stages[:DEFENSE]+6
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
      @roomEffect = PBEffects::WonderRoom
      @areaName = "wondrous"
      @description = WONDER_ROOM_DESCRIPTION
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
# Paralyzes the target. (Shadow Bolt)
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
    user.effects[PBEffects::HyperBeam] = 2
    user.currentMove = @id
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
      side.eachEffectWithData(true) do |effect,value,data|
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
      return if pbTarget(user) != :UserSide
      @validTargets.each { |b| pbEffectAgainstTarget(user,b) }
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
  # Increases the user's and its ally's Defense and Special Defense by 1 stage
  # each, if they have Plus or Minus. (Magnetic Flux)
  #===============================================================================
  # NOTE: In Gen 5, this move should have a target of UserSide, while in Gen 6+ it
  #       should have a target of UserAndAllies. This is because, in Gen 5, this
  #       move shouldn't call def pbSuccessCheckAgainstTarget for each Pokémon
  #       currently in battle that will be affected by this move (i.e. allies
  #       aren't protected by their substitute/ability/etc., but they are in Gen
  #       6+). We achieve this by not targeting any battlers in Gen 5, since
  #       pbSuccessCheckAgainstTarget is only called for targeted battlers.
  class PokeBattle_Move_137 < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbMoveFailed?(user,targets)
      @validTargets = []
      @battle.eachSameSideBattler(user) do |b|
        next if !b.hasActiveAbility?([:MINUS,:PLUS])
        next if !b.pbCanRaiseStatStage?(:DEFENSE,user,self) &&
                !b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
        @validTargets.push(b)
      end
      if @validTargets.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbFailsAgainstTarget?(user,target)
      return false if @validTargets.any? { |b| b.index==target.index }
      return true if !target.hasActiveAbility?([:MINUS,:PLUS])
      @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!",target.pbThis))
      return true
    end
    
    def pbEffectAgainstTarget(user,target)
      showAnim = true
      if target.pbCanRaiseStatStage?(:DEFENSE,user,self)
        if target.pbRaiseStatStage(:DEFENSE,1,user,showAnim)
          showAnim = false
        end
      end
      if target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
        target.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user,showAnim)
      end
    end
  
    def pbEffectGeneral(user)
      return if pbTarget(user) != :UserSide
      @validTargets.each { |b| pbEffectAgainstTarget(user,b) }
    end
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
      if !user.isSpecies?(:HOOPA)
        @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis(true)))
        return true
      elsif user.form!=1
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
      @validTargets = []
      @battle.eachBattler do |b|
        next if !b.pbHasType?(:GRASS)
        next if b.semiInvulnerable?
        next if !b.pbCanRaiseStatStage?(:ATTACK,user,self) &&
                !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
        @validTargets.push(b.index)
      end
      if @validTargets.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbFailsAgainstTarget?(user,target)
      return false if @validTargets.include?(target.index)
      return true if !target.pbHasType?(:GRASS)
      return true if target.semiInvulnerable?
      @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!",target.pbThis))
      return true
    end
  
    def pbEffectAgainstTarget(user,target)
      showAnim = true
      if target.pbCanRaiseStatStage?(:ATTACK,user,self)
        if target.pbRaiseStatStage(:ATTACK,1,user,showAnim)
          showAnim = false
        end
      end
      if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
        target.pbRaiseStatStage(:SPECIAL_ATTACK,1,user,showAnim)
      end
    end

    def getScore(score,user,target,skill=100)
			if target.pbHasTypeAI?(:GRASS)
        if target.pbCanRaiseStatStage?(:ATTACK,user,self)
          score += 20
          score -= user.stages[:ATTACK] * 10
        end
        if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
          score += 20
          score -= user.stages[:SPECIAL_ATTACK] * 10
        end
			end
      return score
    end
  end
  
  #===============================================================================
  # Increases the Defense of all Grass-type self and allies by 1 stage each.
  # (Flower Shield)
  #===============================================================================
  class PokeBattle_Move_13F < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      @validTargets = []
      targets.each do |b|
        next if !b.pbHasType?(:GRASS)
        next if b.semiInvulnerable?
        next if !b.pbCanRaiseStatStage?(:DEFENSE,user,self)
        @validTargets.push(b.index)
      end
      if @validTargets.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbFailsAgainstTarget?(user,target)
      return false if @validTargets.include?(target.index)
      return true if !target.pbHasType?(:GRASS) || target.semiInvulnerable?
      return !target.pbCanRaiseStatStage?(:DEFENSE,user,self,true)
    end
  
    def pbEffectAgainstTarget(user,target)
      target.pbRaiseStatStage(:DEFENSE,1,user)
    end

    def getScore(score,user,target,skill=100)
			if target.pbHasTypeAI?(:GRASS) && target.pbCanRaiseStatStage?(:DEFENSE,user,self)
        score += 30
				score -= user.stages[:DEFENSE] * 10
			end
      return score
    end
  end
  
  #===============================================================================
  # Decreases the Attack, Special Attack and Speed of all nearby poisoned foes
  # by 1. (Venom Drench)
  #===============================================================================
  class PokeBattle_Move_140 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      @validTargets = []
      targets.each do |b|
        next if !b || b.fainted?
        next if !b.poisoned?
        next if !b.pbCanLowerStatStage?(:ATTACK,user,self) &&
                !b.pbCanLowerStatStage?(:SPECIAL_ATTACK,user,self) &&
                !b.pbCanLowerStatStage?(:SPEED,user,self)
        @validTargets.push(b.index)
      end
      if @validTargets.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      return if !@validTargets.include?(target.index)
      showAnim = true
      [:ATTACK,:SPECIAL_ATTACK,:SPEED].each do |s|
        next if !target.pbCanLowerStatStage?(s,user,self)
        if target.pbLowerStatStage(s,1,user,showAnim)
          showAnim = false
        end
      end
    end

    def getScore(score,user,target,skill=100)
			if target.poisoned?
        score += 30
        score += target.stages[:ATTACK] * 10
        score += target.stages[:SPECIAL_ATTACK] * 10
        score += target.stages[:SPEED] * 10
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
      target.effects[PBEffects::Type3] = :GHOST
      typeName = GameData::Type.get(:GHOST).name
      @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,typeName))
      @battle.scene.pbRefresh()
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
      target.effects[PBEffects::Type3] = :GRASS
      typeName = GameData::Type.get(:GRASS).name
      @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,typeName))
      @battle.scene.pbRefresh()
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
      if target.effects[PBEffects::Electrify]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if pbMoveFailedTargetAlreadyMoved?(target)
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::Electrify] = true
      @battle.pbDisplay(_INTL("{1}'s moves have been electrified!",target.pbThis))
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
      if @battle.field.effects[PBEffects::IonDeluge]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if pbMoveFailedLastInRound?(user)
      return false
    end
  
    def pbEffectGeneral(user)
      return if @battle.field.effects[PBEffects::IonDeluge]
      @battle.field.effects[PBEffects::IonDeluge] = true
      @battle.pbDisplay(_INTL("A deluge of ions showers the battlefield!"))
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
      if target.effects[PBEffects::Powder]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::Powder] = true
      @battle.pbDisplay(_INTL("{1} is covered in powder!",user.pbThis))
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
      if !user.firstTurn?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if pbMoveFailedLastInRound?(user)
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbOwnSide.effects[PBEffects::MatBlock] = true
      @battle.pbDisplay(_INTL("{1} intends to flip up a mat and block incoming attacks!",user.pbThis))
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
      if user.pbOwnSide.effects[PBEffects::CraftyShield]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if pbMoveFailedLastInRound?(user)
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbOwnSide.effects[PBEffects::CraftyShield] = true
      @battle.pbDisplay(_INTL("Crafty Shield protected {1}!",user.pbTeam(true)))
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
  # the user of a stopped contact move by 2 stages. (King's Shield)
  #===============================================================================
  class PokeBattle_Move_14B < PokeBattle_ProtectMove
    def initialize(battle,move)
      super
      @effect = PBEffects::KingsShield
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
  # a stopped contact move by 1/8 of its max HP. (Spiky Shield)
  #===============================================================================
  class PokeBattle_Move_14C < PokeBattle_ProtectMove
    def initialize(battle,move)
      super
      @effect = PBEffects::SpikyShield
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
      showAnim = true
      [:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED].each do |s|
        next if !user.pbCanRaiseStatStage?(s,user,self)
        if user.pbRaiseStatStage(s,2,user,showAnim)
          showAnim = false
        end
      end
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
        return if !user.pbCanRaiseStatStage?(:ATTACK,user,self)
        user.pbRaiseStatStage(:ATTACK,3,user)
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
        switcher = b if b.effects[PBEffects::MagicCoat] || b.effects[PBEffects::MagicBounce]
      end
      return if switcher.fainted? || numHits==0
      return if !@battle.pbCanChooseNonActive?(switcher.index)
      @battle.pbDisplay(_INTL("{1} went back to {2}!",switcher.pbThis,
         @battle.pbGetOwnerName(switcher.index)))
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
  # No Pokémon can switch out or flee until the end of the next round, as long as
  # the user remains active. (Fairy Lock)
  #===============================================================================
  class PokeBattle_Move_152 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if @battle.field.effects[PBEffects::FairyLock] > 0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      @battle.field.effects[PBEffects::FairyLock] = 2
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
      @battle.field.effects[PBEffects::HappyHour] = true if !user.opposes?
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
      if !target.pbCanPoison?(user,false,self) &&
         !target.pbCanLowerStatStage?(:SPEED,user,self)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.pbPoison(user) if target.pbCanPoison?(user,false,self)
      if target.pbCanLowerStatStage?(:SPEED,user,self)
        target.pbLowerStatStage(:SPEED,1,user)
      end
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
      if !target.effectActive?(:Substitute) && target.burned?
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
  # Increases the user's and its ally's Attack and Special Attack by 1 stage each,
  # if they have Plus or Minus. (Gear Up)
  #===============================================================================
  # NOTE: In Gen 5, this move should have a target of UserSide, while in Gen 6+ it
  #       should have a target of UserAndAllies. This is because, in Gen 5, this
  #       move shouldn't call def pbSuccessCheckAgainstTarget for each Pokémon
  #       currently in battle that will be affected by this move (i.e. allies
  #       aren't protected by their substitute/ability/etc., but they are in Gen
  #       6+). We achieve this by not targeting any battlers in Gen 5, since
  #       pbSuccessCheckAgainstTarget is only called for targeted battlers.
  class PokeBattle_Move_15C < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbMoveFailed?(user,targets)
      @validTargets = []
      @battle.eachSameSideBattler(user) do |b|
        next if !b.hasActiveAbility?([:MINUS,:PLUS])
        next if !b.pbCanRaiseStatStage?(:ATTACK,user,self) &&
                !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
        @validTargets.push(b)
      end
      if @validTargets.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbFailsAgainstTarget?(user,target)
      return false if @validTargets.any? { |b| b.index==target.index }
      return true if !target.hasActiveAbility?([:MINUS,:PLUS])
      @battle.pbDisplay(_INTL("{1}'s stats can't be raised further!",target.pbThis))
      return true
    end
  
    def pbEffectAgainstTarget(user,target)
      showAnim = true
      if target.pbCanRaiseStatStage?(:ATTACK,user,self)
        if target.pbRaiseStatStage(:ATTACK,1,user,showAnim)
          showAnim = false
        end
      end
      if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
        target.pbRaiseStatStage(:SPECIAL_ATTACK,1,user,showAnim)
      end
    end
  
    def pbEffectGeneral(user)
      return if pbTarget(user) != :UserSide
      @validTargets.each { |b| pbEffectAgainstTarget(user,b) }
    end

    def getScore(score,user,target,skill=100)
      score -= 40
			@battle.eachSameSideBattler(user) do |b|
        next if !b.hasActiveAbilityAI?([:MINUS,:PLUS])
        next if !b.pbCanRaiseStatStage?(:ATTACK,user,self) &&
                !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
        score += 40
      end
      return score
    end
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
  end
  
  #===============================================================================
  # Until the end of the next round, the user's moves will always be critical hits.
  # (Laser Focus)
  #===============================================================================
  class PokeBattle_Move_15E < PokeBattle_Move
    def pbEffectGeneral(user)
      user.effects[PBEffects::LaserFocus] = 2
      @battle.pbDisplay(_INTL("{1} concentrated intensely!",user.pbThis))
    end

    def getScore(score,user,target,skill=100)
      return 0 if user.effects[PBEffects::LaserFocus] > 0
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
      # Calculate target's effective attack value
      stageMul = PokeBattle_Battler::STAGE_MULTIPLIERS
      stageDiv = PokeBattle_Battler::STAGE_DIVISORS
      atk      = target.attack
      atkStage = target.stages[:ATTACK]+6
      healAmount = atk.to_f * stageMul[atkStage] / stageDiv[atkStage].to_f
      # Reduce target's Attack stat
      if target.pbCanLowerStatStage?(:ATTACK,user,self)
        target.pbLowerStatStage(:ATTACK,1,user)
      end
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
      if !user.effects[PBEffects::BurnUp]
        user.effects[PBEffects::BurnUp] = true
        @battle.pbDisplay(_INTL("{1} burned itself out!",user.pbThis))
        @battle.scene.pbRefresh()
      end
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
      @calcCategory = 1
    end
  
    def physicalMove?(thisType=nil); return (@calcCategory==0); end
    def specialMove?(thisType=nil);  return (@calcCategory==1); end
  
    def pbOnStartUse(user,targets)
      # Calculate user's effective attacking value
      stageMul = PokeBattle_Battler::STAGE_MULTIPLIERS
      stageDiv = PokeBattle_Battler::STAGE_DIVISORS
      atk        = user.attack
      atkStage   = user.stages[:ATTACK]+6
      realAtk    = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
      spAtk      = user.spatk
      spAtkStage = user.stages[:SPECIAL_ATTACK]+6
      realSpAtk  = (spAtk.to_f*stageMul[spAtkStage]/stageDiv[spAtkStage]).floor
      # Determine move's category
      @calcCategory = (realAtk>realSpAtk) ? 0 : 1
    end

    def getScore(score,user,target,skill=100)
      score += 20
      return score
    end
  end
  
  #===============================================================================
  # Negates the target's ability while it remains on the field, if it has already
  # performed its action this round. (Core Enforcer)
  #===============================================================================
  class PokeBattle_Move_165 < PokeBattle_Move
    def pbEffectAgainstTarget(user,target)
      return if target.damageState.substitute || target.effects[PBEffects::GastroAcid]
      return if target.unstoppableAbility?
      return if @battle.choices[target.index][0]!=:UseItem &&
                !((@battle.choices[target.index][0]==:UseMove ||
                @battle.choices[target.index][0]==:Shift) && target.movedThisRound?)
      target.effects[PBEffects::GastroAcid] = true
      target.effects[PBEffects::Truant]     = false
      @battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",target.pbThis))
      target.pbOnAbilityChanged(target.ability)
    end

    def getScore(score,user,target,skill=100)
      if !target.effectActive?(:Substitute) && !target.effects[PBEffects::GastroAcid]
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
  # makes contact with the user while this effect applies, that Pokémon is
  # poisoned. (Baneful Bunker)
  #===============================================================================
  class PokeBattle_Move_168 < PokeBattle_ProtectMove
    def initialize(battle,move)
      super
      @effect = PBEffects::BanefulBunker
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
      target.effects[PBEffects::Spotlight] = 1
      target.eachAlly do |b|
        next if b.effects[PBEffects::Spotlight]<target.effects[PBEffects::Spotlight]
        target.effects[PBEffects::Spotlight] = b.effects[PBEffects::Spotlight]+1
      end
      @battle.pbDisplay(_INTL("{1} became the center of attention!",target.pbThis))
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
      target.effects[PBEffects::Instruct] = true
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
      if target.effects[PBEffects::ThroatChop] == 0
        @battle.pbDisplay(_INTL("{1} is prevented from using sound-based moves!",target.pbThis))
      end
      target.effects[PBEffects::ThroatChop] = 3
    end

    def getScore(score,user,target,skill=100)
      if target.effects[PBEffects::ThroatChop] == 0 && target.hasSoundMove? && !target.effectActive?(:Substitute)
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
  end
  
  #===============================================================================
  # Damages target if target is a foe, or heals target by 1/2 of its max HP if
  # target is an ally. (Pollen Puff)
  #===============================================================================
  class PokeBattle_Move_16F < PokeBattle_Move
    def pbTarget(user)
      return GameData::Target.get(:NearFoe) if user.effects[PBEffects::HealBlock]>0
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
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} cannot use {2}!",user.pbThis,@name))
          else
            @battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
               user.pbThis,@name,bearer.pbThis(true),bearer.abilityName))
          end
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
      user.effects[PBEffects::ShellTrap] = true
      @battle.pbCommonAnimation("ShellTrap",user)
      @battle.pbDisplay(_INTL("{1} set a shell trap!",user.pbThis))
    end
  
    def pbDisplayUseMessage(user,targets)
      super if user.tookPhysicalHit
    end
  
    def pbMoveFailed?(user,targets)
      if !user.effects[PBEffects::ShellTrap]
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
  # If a Pokémon makes contact with the user before it uses this move, the
  # attacker is burned. (Beak Blast)
  #===============================================================================
  class PokeBattle_Move_172 < PokeBattle_Move
    def pbDisplayChargeMessage(user)
      user.effects[PBEffects::BeakBlast] = true
      @battle.pbCommonAnimation("BeakBlast",user)
      @battle.pbDisplay(_INTL("{1} started heating up its beak!",user.pbThis))
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
class PokeBattle_Move_176 < PokeBattle_ParalysisMove
  def pbMoveFailed?(user,targets)
    if @id == :AURAWHEEL && user.species != :MORPEKO && user.effects[PBEffects::TransformSpecies] != :MORPEKO
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
  
  def getScore(score,user,target,skill=100)
    score = getParalysisMoveScore(score,user,target,skill=100)
    score = 0 if @id == :AURAWHEEL && user.species != :MORPEKO && user.effects[PBEffects::TransformSpecies] != :MORPEKO
    return score
  end
end

#===============================================================================
# User's Defense is used instead of user's Attack for this move's calculations.
# (Body Press)
#===============================================================================
class PokeBattle_Move_177 < PokeBattle_Move
  def pbGetAttackStats(user,target)
    return user.defense, user.stages[:DEFENSE]+6
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
  def pbMoveFailed?(user,targets,messages=true)
    if user.hp<=(user.totalhp/3) ||
      (!user.pbCanRaiseStatStage?(:ATTACK,user,self,messages) &&
      !user.pbCanRaiseStatStage?(:DEFENSE,user,self,messages) &&
      !user.pbCanRaiseStatStage?(:SPEED,user,self,messages) &&
      !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self,messages) &&
      !user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self,messages))
      @battle.pbDisplay(_INTL("But it failed!")) if messages
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    if user.pbCanRaiseStatStage?(:ATTACK,user,self)
      user.pbRaiseStatStage(:ATTACK,1,user)
    end
    if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
      user.pbRaiseStatStage(:DEFENSE,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPEED,user,self)
      user.pbRaiseStatStage(:SPEED,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
      user.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
    end
    user.applyFractionalDamage(1.0/3.0)
  end
  
  def getScore(score,user,target,skill=100)
    score += 50 if user.firstTurn?
    score -= 80 if user.hp < user.totalhp/2
    return score
  end
end

#===============================================================================
# Swaps barriers, veils and other effects between each side of the battlefield.
# (Court Change)
#===============================================================================
class PokeBattle_Move_17A < PokeBattle_Move
  
  def pbMoveFailed?(user,targets)
    effectsPlayer = @battle.sides[0].effects
    effectsTrainer = @battle.sides[1].effects
    GameData::BattleEffect.each_side_effect do |effectData|
      next if !effectData.court_changed?
      id = effectData.id
      return false if effectsPlayer.effectActive?(id) || effectsTrainer.effectActive?(id)
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
# In singles, this move hits the target twice. In doubles, this move hits each
# target once. If one of the two opponents protects or while semi-invulnerable
# or is a Fairy-type Pokémon, it hits the opponent that doesn't protect twice.
# In Doubles, not affected by WideGuard.
# (Dragon Darts)
#===============================================================================
class PokeBattle_Move_17C < PokeBattle_Move_0BD
  def smartSpreadsTargets?; return true; end

  def pbNumHits(user,targets,checkingForAI=false)
    return 1 if targets.length > 1
    return 2
  end

  def pbNumHitsAI(user,target,skill=100)
    return 2
  end
end

#===============================================================================
# Prevents both the user and the target from escaping. (Jaw Lock)
#===============================================================================
class PokeBattle_Move_17D < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    if target.effects[PBEffects::JawLockUser]<0 && !target.effects[PBEffects::JawLock] &&
      user.effects[PBEffects::JawLockUser]<0 && !user.effects[PBEffects::JawLock]
      user.effects[PBEffects::JawLock] = true
      target.effects[PBEffects::JawLock] = true
      user.effects[PBEffects::JawLockUser] = user.index
      target.effects[PBEffects::JawLockUser] = user.index
      @battle.pbDisplay(_INTL("Neither Pokémon can run away!"))
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
  def pbMoveFailed?(user,targets,messages=true)
    if user.effects[PBEffects::NoRetreat]
      @battle.pbDisplay(_INTL("But it failed!")) if messages
      return true
    end
    if !user.pbCanRaiseStatStage?(:ATTACK,user,self,true) &&
       !user.pbCanRaiseStatStage?(:DEFENSE,user,self,true) &&
       !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self,true) &&
       !user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self,true) &&
       !user.pbCanRaiseStatStage?(:SPEED,user,self,true)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    if user.pbCanRaiseStatStage?(:ATTACK,user,self)
      user.pbRaiseStatStage(:ATTACK,1,user)
    end
    if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
      user.pbRaiseStatStage(:DEFENSE,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPEED,user,self)
      user.pbRaiseStatStage(:SPEED,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
    end
    if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
      user.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
    end

      user.effects[PBEffects::NoRetreat] = true
    if !(user.effects[PBEffects::MeanLook]>=0 || user.effects[PBEffects::Trapping]>0 ||
       user.effects[PBEffects::JawLock] || user.effects[PBEffects::OctolockUser]>=0)
      @battle.pbDisplay(_INTL("{1} can no longer escape because it used No Retreat!",user.pbThis))
    end
  end
  
    def getScore(score,user,target,skill=100)
        score += 40 if user.firstTurn?
        score -= 40 if user.hp<user.totalhp/2
        score = 0 if user.effects[PBEffects::NoRetreat]
      return score
  end
end