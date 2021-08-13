class PokeBattle_Battler
  def pbInitEffects(batonPass)
    if batonPass
      # These effects are passed on if Baton Pass is used, but they need to be
      # reapplied
      @effects[PBEffects::LaserFocus] = (@effects[PBEffects::LaserFocus]>0) ? 2 : 0
      @effects[PBEffects::LockOn]     = (@effects[PBEffects::LockOn]>0) ? 2 : 0
      if @effects[PBEffects::PowerTrick]
        @attack,@defense = @defense,@attack
      end
      # These effects are passed on if Baton Pass is used, but they need to be
      # cancelled in certain circumstances anyway
      @effects[PBEffects::Telekinesis] = 0 if isSpecies?(:GENGAR) && mega?
      @effects[PBEffects::GastroAcid]  = false if unstoppableAbility?
    else
      # These effects are not passed on if Baton Pass is used
      @stages[:ATTACK]          = 0
      @stages[:DEFENSE]         = 0
      @stages[:SPEED]           = 0
      @stages[:SPECIAL_ATTACK]  = 0
      @stages[:SPECIAL_DEFENSE] = 0
      @stages[:ACCURACY]        = 0
      @stages[:EVASION]         = 0
      @effects[PBEffects::AquaRing]          = false
      @effects[PBEffects::Confusion]         = 0
	  @effects[PBEffects::ConfusionChance]   = 0
      @effects[PBEffects::Curse]             = false
      @effects[PBEffects::Embargo]           = 0
      @effects[PBEffects::FocusEnergy]       = 0
      @effects[PBEffects::GastroAcid]        = false
      @effects[PBEffects::HealBlock]         = 0
      @effects[PBEffects::Ingrain]           = false
      @effects[PBEffects::LaserFocus]        = 0
      @effects[PBEffects::LeechSeed]         = -1
      @effects[PBEffects::LockOn]            = 0
      @effects[PBEffects::LockOnPos]         = -1
      @effects[PBEffects::MagnetRise]        = 0
      @effects[PBEffects::PerishSong]        = 0
      @effects[PBEffects::PerishSongUser]    = -1
      @effects[PBEffects::PowerTrick]        = false
      @effects[PBEffects::Substitute]        = 0
      @effects[PBEffects::Telekinesis]       = 0
	  @effects[PBEffects::JawLock]           = false
      @effects[PBEffects::JawLockUser]       = -1
	  @effects[PBEffects::NoRetreat]         = false
	  @effects[PBEffects::Charm]         = 0
	  @effects[PBEffects::CharmChance]   = 0
    end
    @fainted               = (@hp==0)
    @initialHP             = 0
    @lastAttacker          = []
    @lastFoeAttacker       = []
    @lastHPLost            = 0
    @lastHPLostFromFoe     = 0
    @tookDamage            = false
    @tookPhysicalHit       = false
    @lastMoveUsed          = nil
    @lastMoveUsedType      = nil
    @lastRegularMoveUsed   = nil
    @lastRegularMoveTarget = -1
    @lastRoundMoved        = -1
    @lastMoveFailed        = false
    @lastRoundMoveFailed   = false
    @movesUsed             = []
    @turnCount             = 0
    @effects[PBEffects::Attract]             = -1
    @battle.eachBattler do |b|   # Other battlers no longer attracted to self
      b.effects[PBEffects::Attract] = -1 if b.effects[PBEffects::Attract]==@index
    end
    @effects[PBEffects::BanefulBunker]       = false
    @effects[PBEffects::BeakBlast]           = false
    @effects[PBEffects::Bide]                = 0
    @effects[PBEffects::BideDamage]          = 0
    @effects[PBEffects::BideTarget]          = -1
    @effects[PBEffects::BurnUp]              = false
    @effects[PBEffects::Charge]              = 0
    @effects[PBEffects::ChoiceBand]          = nil
    @effects[PBEffects::Counter]             = -1
    @effects[PBEffects::CounterTarget]       = -1
    @effects[PBEffects::Dancer]              = false
    @effects[PBEffects::DefenseCurl]         = false
    @effects[PBEffects::DestinyBond]         = false
    @effects[PBEffects::DestinyBondPrevious] = false
    @effects[PBEffects::DestinyBondTarget]   = -1
    @effects[PBEffects::Disable]             = 0
    @effects[PBEffects::DisableMove]         = nil
    @effects[PBEffects::Electrify]           = false
    @effects[PBEffects::Encore]              = 0
    @effects[PBEffects::EncoreMove]          = nil
    @effects[PBEffects::Endure]              = false
    @effects[PBEffects::FirstPledge]         = 0
    @effects[PBEffects::FlashFire]           = false
    @effects[PBEffects::Flinch]              = false
    @effects[PBEffects::FocusPunch]          = false
    @effects[PBEffects::FollowMe]            = 0
    @effects[PBEffects::Foresight]           = false
    @effects[PBEffects::FuryCutter]          = 0
    @effects[PBEffects::GemConsumed]         = nil
    @effects[PBEffects::Grudge]              = false
    @effects[PBEffects::HelpingHand]         = false
    @effects[PBEffects::HyperBeam]           = 0
    @effects[PBEffects::Illusion]            = nil
    if hasActiveAbility?(:ILLUSION)
      idxLastParty = @battle.pbLastInTeam(@index)
      if idxLastParty >= 0 && idxLastParty != @pokemonIndex
        @effects[PBEffects::Illusion]        = @battle.pbParty(@index)[idxLastParty]
      end
    end
    @effects[PBEffects::Imprison]            = false
    @effects[PBEffects::Instruct]            = false
    @effects[PBEffects::Instructed]          = false
    @effects[PBEffects::KingsShield]         = false
    @battle.eachBattler do |b|   # Other battlers lose their lock-on against self
      next if b.effects[PBEffects::LockOn]==0
      next if b.effects[PBEffects::LockOnPos]!=@index
      b.effects[PBEffects::LockOn]    = 0
      b.effects[PBEffects::LockOnPos] = -1
    end
    @effects[PBEffects::MagicBounce]         = false
    @effects[PBEffects::MagicCoat]           = false
    @effects[PBEffects::MeanLook]            = -1
    @battle.eachBattler do |b|   # Other battlers no longer blocked by self
      b.effects[PBEffects::MeanLook] = -1 if b.effects[PBEffects::MeanLook]==@index
    end
    @effects[PBEffects::MeFirst]             = false
    @effects[PBEffects::Metronome]           = 0
    @effects[PBEffects::MicleBerry]          = false
    @effects[PBEffects::Minimize]            = false
    @effects[PBEffects::MiracleEye]          = false
    @effects[PBEffects::MirrorCoat]          = -1
    @effects[PBEffects::MirrorCoatTarget]    = -1
    @effects[PBEffects::MoveNext]            = false
    @effects[PBEffects::MudSport]            = false
    @effects[PBEffects::Nightmare]           = false
    @effects[PBEffects::Outrage]             = 0
    @effects[PBEffects::ParentalBond]        = 0
    @effects[PBEffects::PickupItem]          = nil
    @effects[PBEffects::PickupUse]           = 0
    @effects[PBEffects::Pinch]               = false
    @effects[PBEffects::Powder]              = false
    @effects[PBEffects::Prankster]           = false
    @effects[PBEffects::PriorityAbility]     = false
    @effects[PBEffects::PriorityItem]        = false
    @effects[PBEffects::Protect]             = false
    @effects[PBEffects::ProtectRate]         = 1
    @effects[PBEffects::Pursuit]             = false
    @effects[PBEffects::Quash]               = 0
    @effects[PBEffects::Rage]                = false
    @effects[PBEffects::RagePowder]          = false
    @effects[PBEffects::Rollout]             = 0
    @effects[PBEffects::Roost]               = false
    @effects[PBEffects::SkyDrop]             = -1
    @battle.eachBattler do |b|   # Other battlers no longer Sky Dropped by self
      b.effects[PBEffects::SkyDrop] = -1 if b.effects[PBEffects::SkyDrop]==@index
    end
    @effects[PBEffects::SlowStart]           = 0
    @effects[PBEffects::SmackDown]           = false
    @effects[PBEffects::Snatch]              = 0
    @effects[PBEffects::SpikyShield]         = false
    @effects[PBEffects::Spotlight]           = 0
    @effects[PBEffects::Stockpile]           = 0
    @effects[PBEffects::StockpileDef]        = 0
    @effects[PBEffects::StockpileSpDef]      = 0
    @effects[PBEffects::Taunt]               = 0
    @effects[PBEffects::ThroatChop]          = 0
    @effects[PBEffects::Torment]             = false
    @effects[PBEffects::Toxic]               = 0
    @effects[PBEffects::Transform]           = false
    @effects[PBEffects::TransformSpecies]    = 0
    @effects[PBEffects::Trapping]            = 0
    @effects[PBEffects::TrappingMove]        = nil
    @effects[PBEffects::TrappingUser]        = -1
    @battle.eachBattler do |b|   # Other battlers no longer trapped by self
      next if b.effects[PBEffects::TrappingUser]!=@index
      b.effects[PBEffects::Trapping]     = 0
      b.effects[PBEffects::TrappingUser] = -1
    end
	@effects[PBEffects::Octolock]     = false
    @effects[PBEffects::OctolockUser] = -1
    @battle.eachBattler do |b|   # Other battlers lose their lock-on against self - Octolock
      next if !b.effects[PBEffects::Octolock]
      next if b.effects[PBEffects::OctolockUser]!=@index
      b.effects[PBEffects::Octolock]     = false
      b.effects[PBEffects::OctolockUser] = -1
    end
    @battle.eachBattler do |b|   # Other battlers lose their lock-on against self - Jawlock
      next if !b.effects[PBEffects::JawLock]
      next if b.effects[PBEffects::JawLockUser]!=@index
      b.effects[PBEffects::JawLock]     = false
      b.effects[PBEffects::JawLockUser] = -1
    end
    @effects[PBEffects::Truant]              = false
    @effects[PBEffects::TwoTurnAttack]       = nil
    @effects[PBEffects::Type3]               = nil
    @effects[PBEffects::Unburden]            = false
    @effects[PBEffects::Uproar]              = 0
    @effects[PBEffects::WaterSport]          = false
    @effects[PBEffects::WeightChange]        = 0
    @effects[PBEffects::Yawn]                = 0
	
	@effects[PBEffects::GorillaTactics]      = -1
    @effects[PBEffects::BallFetch]           = 0
    @effects[PBEffects::LashOut]             = false
    @effects[PBEffects::BurningJealousy]     = false
	  @effects[PBEffects::Obstruct]            = false
	  @effects[PBEffects::TarShot]             = false
	  @effects[PBEffects::BlunderPolicy]       = false
    @effects[PBEffects::SwitchedAlly]        = -1
	
	@effects[PBEffects::FlinchedAlready]     = false
	@effects[PBEffects::Enlightened]		 = false
	@effects[PBEffects::ColdConversion]      = false
	@effects[PBEffects::CreepOut]		 	 = false
	@effects[PBEffects::LuckyStar]       	 = false
	@effects[PBEffects::Inured]       	 	 = false
  end

	def takesSandstormDamage?
		return false if !takesIndirectDamage?
		return false if pbHasType?(:GROUND) || pbHasType?(:ROCK) || pbHasType?(:STEEL)
		return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
		return false if hasActiveAbility?([:OVERCOAT,:SANDFORCE,:SANDRUSH,:SANDVEIL,:STOUT])
		return false if hasActiveItem?(:SAFETYGOGGLES)
		return true
	  end

	def takesHailDamage?
		return false if !takesIndirectDamage?
		return false if pbHasType?(:ICE) || pbHasType?(:STEEL) || pbHasType?(:GHOST)
		return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
		return false if hasActiveAbility?([:OVERCOAT,:ICEBODY,:SNOWCLOAK,:STOUT,:SNOWWARNING])
		return false if hasActiveItem?(:SAFETYGOGGLES)
		return true
	end
	
  # Returns the active types of this Pokémon. The array should not include the
  # same type more than once, and should not include any invalid type numbers
  # (e.g. -1).
  def pbTypes(withType3=false)
    ret = [@type1]
    ret.push(@type2) if @type2!=@type1
    # Burn Up erases the Fire-type.
    ret.delete(:FIRE) if @effects[PBEffects::BurnUp]
	# Cold Conversion erases the Ice-type.
    ret.delete(:ICE) if @effects[PBEffects::ColdConversion]
    # Roost erases the Flying-type. If there are no types left, adds the Normal-
    # type.
    if @effects[PBEffects::Roost]
      ret.delete(:FLYING)
      ret.push(:NORMAL) if ret.length == 0
    end
    # Add the third type specially.
    if withType3 && @effects[PBEffects::Type3]
      ret.push(@effects[PBEffects::Type3]) if !ret.include?(@effects[PBEffects::Type3])
    end
    return ret
  end
  
  # NOTE: Do not create any held item which affects whether a Pokémon's ability
  #       is active. The ability Klutz affects whether a Pokémon's item is
  #       active, and the code for the two combined would cause an infinite loop
  #       (regardless of whether any Pokémon actualy has either the ability or
  #       the item - the code existing is enough to cause the loop).
  def abilityActive?(ignore_fainted = false)
    return false if fainted? && !ignore_fainted
	return false if @battle.field.effects[PBEffects::NeutralizingGas]
    return false if @effects[PBEffects::GastroAcid]
    return true
  end
  
  # Applies to both losing self's ability (i.e. being replaced by another) and
  # having self's ability be negated.
  def unstoppableAbility?(abil = nil)
    abil = @ability_id if !abil
    abil = GameData::Ability.try_get(abil)
    return false if !abil
    ability_blacklist = [
      # Form-changing abilities
      :BATTLEBOND,
      :DISGUISE,
#      :FLOWERGIFT,                                        # This can be stopped
#      :FORECAST,                                          # This can be stopped
      :MULTITYPE,
      :POWERCONSTRUCT,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :ZENMODE,
      :ICEFACE,
      # Abilities intended to be inherent properties of a certain species
      :COMATOSE,
      :RKSSYSTEM,
      :GULPMISSILE,
      :ASONEICE,
      :ASONEGHOST
    ]
    return ability_blacklist.include?(abil.id)
  end
  
  # Applies to gaining the ability.
  def ungainableAbility?(abil = nil)
    abil = @ability_id if !abil
    abil = GameData::Ability.try_get(abil)
    return false if !abil
    ability_blacklist = [
      # Form-changing abilities
      :BATTLEBOND,
      :DISGUISE,
      :FLOWERGIFT,
      :FORECAST,
      :MULTITYPE,
      :POWERCONSTRUCT,
      :SCHOOLING,
      :SHIELDSDOWN,
      :STANCECHANGE,
      :ZENMODE,
      # Appearance-changing abilities
      :ILLUSION,
      :IMPOSTER,
      # Abilities intended to be inherent properties of a certain species
      :COMATOSE,
      :RKSSYSTEM,
	  :NEUTRALIZINGGAS,
	  :HUNGERSWITCH
    ]
    return ability_blacklist.include?(abil.id)
  end
  
  # permanent is whether the item is lost even after battle. Is false for Knock
  # Off.
  def pbRemoveItem(permanent = true)
	permanent = false # Items respawn after battle always!!
    @effects[PBEffects::ChoiceBand] = nil
    @effects[PBEffects::Unburden]   = true if self.item
    setInitialItem(nil) if permanent && self.item == self.initialItem
    self.item = nil
	@battle.scene.pbRefresh()
  end
  
  #=============================================================================
  # Generalised infliction of status problem
  #=============================================================================
  def pbInflictStatus(newStatus,newStatusCount=0,msg=nil,user=nil)
    # Inflict the new status
    self.status      = newStatus
    self.statusCount = newStatusCount
    @effects[PBEffects::Toxic] = 0
    # Show animation
    if newStatus == :POISON && newStatusCount > 0
      @battle.pbCommonAnimation("Toxic", self)
    else
      anim_name = GameData::Status.get(newStatus).animation
      @battle.pbCommonAnimation(anim_name, self) if anim_name
    end
    # Show message
	if msg != "false"
		if msg && !msg.empty?
		  @battle.pbDisplay(msg)
		else
		  case newStatus
		  when :SLEEP
			@battle.pbDisplay(_INTL("{1} fell asleep!", pbThis))
		  when :POISON
			if newStatusCount>0
			  @battle.pbDisplay(_INTL("{1} was toxified!", pbThis))
			else
			  @battle.pbDisplay(_INTL("{1} was poisoned! Its Sp. Atk is reduced!", pbThis))
			end
		  when :BURN
			@battle.pbDisplay(_INTL("{1} was burned! Its Attack is reduced!", pbThis))
		  when :PARALYSIS
			@battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!", pbThis))
		  when :FROZEN
			@battle.pbDisplay(_INTL("{1} was chilled! It's slower and takes more damage!", pbThis))
		  end
		end
	end
    #PBDebug.log("[Status change] #{pbThis}'s sleep count is #{newStatusCount}") if newStatus == :SLEEP
    # Form change check
    pbCheckFormOnStatusChange
    # Synchronize
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatusInflicted(self.ability,self,user,newStatus)
    end
    # Status cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
    # Petal Dance/Outrage/Thrash get cancelled immediately by falling asleep
    # NOTE: I don't know why this applies only to Outrage and only to falling
    #       asleep (i.e. it doesn't cancel Rollout/Uproar/other multi-turn
    #       moves, and it doesn't cancel any moves if self becomes frozen/
    #       disabled/anything else). This behaviour was tested in Gen 5.
    if @status == :SLEEP && @effects[PBEffects::Outrage] > 0
      @effects[PBEffects::Outrage] = 0
      @currentMove = nil
    end
  end
  
  def pbCureStatus(showMessages=true)
    oldStatus = status
    self.status = :NONE
    if showMessages
      case oldStatus
      when :SLEEP     then @battle.pbDisplay(_INTL("{1} woke up!", pbThis))
      when :POISON    then @battle.pbDisplay(_INTL("{1} was cured of its poisoning.", pbThis))
      when :BURN      then @battle.pbDisplay(_INTL("{1}'s burn was healed.", pbThis))
      when :PARALYSIS then @battle.pbDisplay(_INTL("{1} was cured of paralysis.", pbThis))
      when :FROZEN    then @battle.pbDisplay(_INTL("{1} thawed out!", pbThis))
      end
    end
	
	# Lingering Daze
	if oldStatus == :SLEEP
	  @battle.eachOtherSideBattler(@index) do |b|
        if b.hasActiveAbility?(:LINGERINGDAZE)
			@battle.pbShowAbilitySplash(b)
			pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,b)
			pbLowerStatStageByAbility(:SPECIAL_DEFENSE,1,b)
			@battle.pbHideAbilitySplash(b)
		end
      end
	end
	
    #PBDebug.log("[Status change] #{pbThis}'s status was cured") if !showMessages
  end
  
  def pbPoison(user=nil,msg=nil,toxic=false)
    if (boss && toxic)
      @battle.pbDisplay("The projection's power blunts the toxin.")
      toxic = false
    end
    pbInflictStatus(:POISON,(toxic) ? 1 : 0,msg,user)
  end
  
  def pbSleepDuration(duration = -1)
		duration = 4 if duration <= 0
		duration = 2 if hasActiveAbility?(:EARLYBIRD) || boss
		return duration
  end
  
  def pbConfuse(msg=nil)
    @effects[PBEffects::Confusion] = pbConfusionDuration
	@effects[PBEffects::ConfusionChance] = 0
    @battle.pbCommonAnimation("Confusion",self)
    msg = _INTL("{1} became confused!",pbThis) if !msg || msg==""
    @battle.pbDisplay(msg)
    PBDebug.log("[Lingering effect] #{pbThis}'s confusion count is #{@effects[PBEffects::Confusion]}")
    # Confusion cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
  end

  def pbConfusionDuration(duration=-1)
    duration = 4 if duration<=0
    return duration
  end

  def pbCureConfusion
    @effects[PBEffects::Confusion] = 0
	@effects[PBEffects::ConfusionChance] = 0
  end
  
  #=============================================================================
  # Charm
  #=============================================================================
  def pbCanCharm?(user=nil,showMessages=true,move=nil,selfInflicted=false)
    return false if fainted?
    if @effects[PBEffects::Charm]>0
      @battle.pbDisplay(_INTL("{1} is already charmed.",pbThis)) if showMessages
      return false
    end
    if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
       !selfInflicted
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    # Terrains immunity
    if affectedByTerrain? && @battle.field.terrain == :Misty
      @battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!",pbThis(true))) if showMessages
      return false
    end
    if selfInflicted || !@battle.moldBreaker
      if hasActiveAbility?(:OWNTEMPO)
        if showMessages
          @battle.pbShowAbilitySplash(self)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} doesn't become charmed!",pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents charmed!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanCharmSelf?(showMessages)
    return pbCanConfuse?(nil,showMessages,nil,true)
  end
  
  def pbCharm(msg=nil)
    @effects[PBEffects::Charm] = pbCharmDuration
	@effects[PBEffects::CharmChance] = 0
    @battle.pbAnimation(:LUCKYCHANT,self,nil)
    msg = _INTL("{1} became charmed!",pbThis) if !msg || msg==""
    @battle.pbDisplay(msg)
    PBDebug.log("[Lingering effect] #{pbThis}'s charm count is #{@effects[PBEffects::Confusion]}")
    # Charm cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
  end

  def pbCharmDuration(duration=-1)
    duration = 4 if duration<=0
    return duration
  end

  def pbCureCharm
    @effects[PBEffects::Charm] = 0
	@effects[PBEffects::CharmChance] = 0
  end
  
  def pbEndTurn(_choice)
    @lastRoundMoved = @battle.turnCount   # Done something this round
	 # Gorilla Tactics
    if @effects[PBEffects::GorillaTactics] == nil && @lastMoveUsed>=0 && hasActiveAbility?(:GORILLATACTICS)
      @effects[PBEffects::GorillaTactics]=@lastMoveUsed
    end
    if !@effects[PBEffects::ChoiceBand] &&
       hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
      if @lastMoveUsed && pbHasMove?(@lastMoveUsed)
        @effects[PBEffects::ChoiceBand] = @lastMoveUsed
      elsif @lastRegularMoveUsed && pbHasMove?(@lastRegularMoveUsed)
        @effects[PBEffects::ChoiceBand] = @lastRegularMoveUsed
      end
    end
    @effects[PBEffects::BeakBlast]   = false
    @effects[PBEffects::Charge]      = 0 if @effects[PBEffects::Charge]==1
    @effects[PBEffects::GemConsumed] = nil
    @effects[PBEffects::ShellTrap]   = false
    @battle.eachBattler { |b| b.pbContinualAbilityChecks }   # Trace, end primordial weathers
  end
  
  def pbConfusionDamage(msg,charm=false,superEff=false)
    @damageState.reset
    @damageState.initialHP = @hp
    confusionMove = charm ? PokeBattle_Charm.new(@battle,nil) : PokeBattle_Confusion.new(@battle,nil)
    confusionMove.calcType = confusionMove.pbCalcType(self)   # nil
    @damageState.typeMod = confusionMove.pbCalcTypeMod(confusionMove.calcType,self,self)   # 8
	@damageState.typeMod *= 2.0 if superEff
    confusionMove.pbCheckDamageAbsorption(self,self)
    confusionMove.pbCalcDamage(self,self)
    confusionMove.pbReduceDamage(self,self)
    self.hp -= @damageState.hpLost
    confusionMove.pbAnimateHitAndHPLost(self,[self])
    @battle.pbDisplay(msg)   # "It hurt itself in its confusion!"
	@battle.pbDisplay("It was super-effective!") if superEff
    confusionMove.pbRecordDamageLost(self,self)
    confusionMove.pbEndureKOMessage(self)
    pbFaint if fainted?
    pbItemHPHealCheck
  end 
  
  def pbCanInflictStatus?(newStatus,user,showMessages,move=nil,ignoreStatus=false)
    return false if fainted?
    selfInflicted = (user && user.index==@index)
    # Already have that status problem
    if self.status==newStatus && !ignoreStatus
      if showMessages
        msg = ""
        case self.status
        when :SLEEP     then msg = _INTL("{1} is already asleep!", pbThis)
        when :POISON    then msg = _INTL("{1} is already poisoned!", pbThis)
        when :BURN      then msg = _INTL("{1} already has a burn!", pbThis)
        when :PARALYSIS then msg = _INTL("{1} is already paralyzed!", pbThis)
        when :FROZEN    then msg = _INTL("{1} is already chilled!", pbThis)
        end
        @battle.pbDisplay(msg)
      end
      return false
    end
    # Trying to replace a status problem with another one
    if self.status != :NONE && !ignoreStatus && !selfInflicted
      @battle.pbDisplay(_INTL("{1} already has a status problem...",pbThis(false))) if showMessages
      return false
    end
    # Trying to inflict a status problem on a Pokémon behind a substitute
    if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
       !selfInflicted
      @battle.pbDisplay(_INTL("It doesn't affect {1} behind its substitute...",pbThis(true))) if showMessages
      return false
    end
    # Weather immunity
    if newStatus == :FROZEN && [:Sun, :HarshSun].include?(@battle.pbWeather)
      @battle.pbDisplay(_INTL("It doesn't affect {1} due to the sunny weather...",pbThis(true))) if showMessages
      return false
    end
    # Terrains immunity
    if affectedByTerrain?
      case @battle.field.terrain
      when :Electric
        if newStatus == :SLEEP
          @battle.pbDisplay(_INTL("{1} surrounds itself with electrified terrain!",
             pbThis(true))) if showMessages
          return false
        end
      when :Misty
        @battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!",pbThis(true))) if showMessages
        return false
      end
    end
    # Uproar immunity
    if newStatus == :SLEEP && !(hasActiveAbility?(:SOUNDPROOF) && !@battle.moldBreaker)
      @battle.eachBattler do |b|
        next if b.effects[PBEffects::Uproar]==0
        @battle.pbDisplay(_INTL("But the uproar kept {1} awake!",pbThis(true))) if showMessages
        return false
      end
    end
    # Type immunities
    hasImmuneType = false
    case newStatus
    when :SLEEP
      # No type is immune to sleep
    when :POISON
      if !(user && user.hasActiveAbility?(:CORROSION))
        hasImmuneType |= pbHasType?(:POISON)
        hasImmuneType |= pbHasType?(:STEEL)
      end
    when :BURN
      hasImmuneType |= pbHasType?(:FIRE)
    when :PARALYSIS
      hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
    when :FROZEN
      hasImmuneType |= pbHasType?(:ICE)
    end
    if hasImmuneType
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    # Ability immunity
    immuneByAbility = false; immAlly = nil
    if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(self.ability,self,newStatus)
      immuneByAbility = true
    elsif selfInflicted || !@battle.moldBreaker
      if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(self.ability,self,newStatus)
        immuneByAbility = true
      else
        eachAlly do |b|
          next if !b.abilityActive?
          next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability,self,newStatus)
          immuneByAbility = true
          immAlly = b
          break
        end
      end
    end
    if immuneByAbility
      if showMessages
        @battle.pbShowAbilitySplash(immAlly || self)
        msg = ""
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          case newStatus
          when :SLEEP     then msg = _INTL("{1} stays awake!", pbThis)
          when :POISON    then msg = _INTL("{1} cannot be poisoned!", pbThis)
          when :BURN      then msg = _INTL("{1} cannot be burned!", pbThis)
          when :PARALYSIS then msg = _INTL("{1} cannot be paralyzed!", pbThis)
          when :FROZEN    then msg = _INTL("{1} cannot be chilled!", pbThis)
          end
        elsif immAlly
          case newStatus
          when :SLEEP
            msg = _INTL("{1} stays awake because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :POISON
            msg = _INTL("{1} cannot be poisoned because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :BURN
            msg = _INTL("{1} cannot be burned because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :PARALYSIS
            msg = _INTL("{1} cannot be paralyzed because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :FROZEN
            msg = _INTL("{1} cannot be chilled because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          end
        else
          case newStatus
          when :SLEEP     then msg = _INTL("{1} stays awake because of its {2}!", pbThis, abilityName)
          when :POISON    then msg = _INTL("{1}'s {2} prevents poisoning!", pbThis, abilityName)
          when :BURN      then msg = _INTL("{1}'s {2} prevents burns!", pbThis, abilityName)
          when :PARALYSIS then msg = _INTL("{1}'s {2} prevents paralysis!", pbThis, abilityName)
          when :FROZEN    then msg = _INTL("{1}'s {2} prevents chilling!", pbThis, abilityName)
          end
        end
        @battle.pbDisplay(msg)
        @battle.pbHideAbilitySplash(immAlly || self)
      end
      return false
    end
    # Safeguard immunity
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted && move &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end
  
  def pbLowerStatStage(stat,increment,user,showAnim=true,ignoreContrary=false,ignoreMirrorArmor=false)
    # Mirror Armor
    if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index!=@index) && 
	  !@battle.moldBreaker && pbCanLowerStatStage?(stat)
      battle.pbShowAbilitySplash(self)
      @battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!",pbThis))
      if !user
        battle.pbHideAbilitySplash(self)
        return false
      end
      if !user.hasActiveAbility?(:MIRRORARMOR) && user.pbCanLowerStatStage?(stat,nil,nil,true)
        user.pbLowerStatStageByAbility(stat,increment,user,splashAnim=false,checkContact=false)
		# Trigger user's abilities upon stat loss
		if user.abilityActive?
		  BattleHandlers.triggerAbilityOnStatLoss(user.ability,user,stat,self)
		end
      end
      battle.pbHideAbilitySplash(self)
      return false
    end
	# Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbRaiseStatStage(stat,increment,user,showAnim,true)
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown",self) if showAnim
    arrStatTexts = [
       _INTL("{1}'s {2} fell!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} harshly fell!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} severely fell!",pbThis,GameData::Stat.get(stat).name)]
    @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
    end
	@effects[PBEffects::LashOut] = true
    return true
  end
  
  def pbLowerStatStageByCause(stat,increment,user,cause,showAnim=true,ignoreContrary=false,ignoreMirrorArmor=false)
	# Mirror Armor
    if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index!=@index) && 
	  !@battle.moldBreaker && pbCanLowerStatStage?(stat)
      battle.pbShowAbilitySplash(self)
      @battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!",pbThis))
      if !user
        battle.pbHideAbilitySplash(self)
        return false
      end
      if !user.hasActiveAbility?(:MIRRORARMOR) && user.pbCanLowerStatStage?(stat,nil,nil,true)
        user.pbLowerStatStageByAbility(stat,increment,user,splashAnim=false,checkContact=false)
		# Trigger user's abilities upon stat loss
		if user.abilityActive?
		  BattleHandlers.triggerAbilityOnStatLoss(user.ability,user,stat,self)
		end
      end
      battle.pbHideAbilitySplash(self)
      return false
    end
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbRaiseStatStageByCause(stat,increment,user,cause,showAnim,true)
    end
	# Royal Scales
    if hasActiveAbility?(:ROYALSCALES) && !@battle.moldBreaker
      return false
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown",self) if showAnim
    if user.index==@index
      arrStatTexts = [
         _INTL("{1}'s {2} lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} harshly lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} severely lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name)]
    else
      arrStatTexts = [
         _INTL("{1}'s {2} lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} harshly lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} severely lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name)]
    end
    @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
    end
	@effects[PBEffects::LashOut] = true
    return true
  end
  
  def pbLowerSpecialAttackStatStageDazzle(user)
    return false if fainted?
    # NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
    if @effects[PBEffects::Substitute]>0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
           pbThis,user.pbThis(true),user.abilityName))
      end
      return false
    end
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      return pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,user,false)
    end
    # NOTE: These checks exist to ensure appropriate messages are shown if
    #       Intimidate is blocked somehow (i.e. the messages should mention the
    #       Intimidate ability by name).
    if !hasActiveAbility?(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,user.pbThis(true),user.abilityName))
        return false
      end
      if abilityActive?
        if BattleHandlers.triggerStatLossImmunityAbility(self.ability,self,:ATTACK,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(self.ability,self,:ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
             pbThis,abilityName,user.pbThis(true),user.abilityName))
          return false
        end
      end
      eachAlly do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,:ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
             pbThis,user.pbThis(true),user.abilityName,b.pbThis(true),b.abilityName))
          return false
        end
      end
    end
    return false if !pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
    return pbLowerStatStageByCause(:SPECIAL_ATTACK,1,user,user.abilityName)
  end
  
  #=============================================================================
  # Calculated properties
  #=============================================================================
  def pbSpeed
    return 1 if fainted?
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    stage = @stages[:SPEED] + 6
    speed = @speed*stageMul[stage]/stageDiv[stage]
    speedMult = 1.0
    # Ability effects that alter calculated Speed
    if abilityActive?
      speedMult = BattleHandlers.triggerSpeedCalcAbility(self.ability,self,speedMult)
    end
    # Item effects that alter calculated Speed
    if itemActive?
      speedMult = BattleHandlers.triggerSpeedCalcItem(self.item,self,speedMult)
    end
    # Other effects
    speedMult *= 2 if pbOwnSide.effects[PBEffects::Tailwind]>0
    speedMult /= 2 if pbOwnSide.effects[PBEffects::Swamp]>0
    # Paralysis
    if (status == :PARALYSIS && !hasActiveAbility?(:QUICKFEET)) || status == :FROZEN
      speedMult /= (Settings::MECHANICS_GENERATION >= 7) ? 2 : 4
    end
    # Badge multiplier
    if @battle.internalBattle && pbOwnedByPlayer? &&
       @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPEED
      speedMult *= 1.1
    end
    # Calculation
    return [(speed*speedMult).round,1].max
  end
  
  #=============================================================================
  # Check whether the user (self) is able to take action at all.
  # If this returns true, and if PP isn't a problem, the move will be considered
  # to have been used (even if it then fails for whatever reason).
  #=============================================================================
  def pbTryUseMove(choice,move,specialUsage,skipAccuracyCheck)
    # Check whether it's possible for self to use the given move
    # NOTE: Encore has already changed the move being used, no need to have a
    #       check for it here.
    if !pbCanChooseMove?(move,false,true,specialUsage)
      @lastMoveFailed = true
      return false
    end
    # Check whether it's possible for self to do anything at all
    if @effects[PBEffects::SkyDrop]>=0   # Intentionally no message here
      PBDebug.log("[Move failed] #{pbThis} can't use #{move.name} because of being Sky Dropped")
      return false
    end
    if @effects[PBEffects::HyperBeam]>0   # Intentionally before Truant
      @battle.pbDisplay(_INTL("{1} must recharge!",pbThis))
      return false
    end
    if choice[1]==-2   # Battle Palace
      @battle.pbDisplay(_INTL("{1} appears incapable of using its power!",pbThis))
      return false
    end
    # Skip checking all applied effects that could make self fail doing something
    return true if skipAccuracyCheck
    # Check status problems and continue their effects/cure them
    case @status
    when :SLEEP
      self.statusCount -= 1
      if @statusCount<=0
        pbCureStatus
      else
        pbContinueStatus
        if !move.usableWhenAsleep?   # Snore/Sleep Talk
          @lastMoveFailed = true
          return false
        end
      end
	end
    # Obedience check
    return false if !pbObedienceCheck?(choice)
    # Truant
    if hasActiveAbility?(:TRUANT)
      @effects[PBEffects::Truant] = !@effects[PBEffects::Truant]
      if !@effects[PBEffects::Truant] && move.id != :SLACKOFF   # True means loafing, but was just inverted
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is loafing around!",pbThis))
        @lastMoveFailed = true
        @battle.pbHideAbilitySplash(self)
        return false
      end
    end
    # Flinching
    if @effects[PBEffects::Flinch]
      if @effects[PBEffects::FlinchedAlready]
        @battle.pbDisplay("#{pbThis} shrugged off their fear and didn't flinch!")
        @effects[PBEffects::Flinch] = false
      else
        @battle.pbDisplay(_INTL("{1} flinched and couldn't move!",pbThis))
        if abilityActive?
          BattleHandlers.triggerAbilityOnFlinch(@ability,self,@battle)
        end
        @lastMoveFailed = true
        @effects[PBEffects::FlinchedAlready] = true
        return false
      end
    end
    # Confusion
    if @effects[PBEffects::Confusion]>0
      @effects[PBEffects::Confusion] -= 1
      if @effects[PBEffects::Confusion]<=0
        pbCureConfusion
        @battle.pbDisplay(_INTL("{1} snapped out of its confusion.",pbThis))
      else
        @battle.pbCommonAnimation("Confusion",self)
        @battle.pbDisplay(_INTL("{1} is confused!",pbThis))
        threshold = 30 + 35 * @effects[PBEffects::ConfusionChance]
        if (@battle.pbRandom(100)<threshold && !hasActiveAbility?([:HEADACHE,:TANGLEDFEET])) || ($DEBUG && Input.press?(Input::CTRL))
          @effects[PBEffects::ConfusionChance] = 0
		  superEff = false
		  @battle.eachOtherSideBattler(@index) do |b| # Brain Scramble
			superEff = true if b.hasActiveAbility?(:BRAINSCRAMBLE)
		  end
          pbConfusionDamage(_INTL("It hurt itself in its confusion!"),false,superEff)
		  @effects[PBEffects::ConfusionChance] = -999
          @lastMoveFailed = true
          return false
        else
          @effects[PBEffects::ConfusionChance] += 1
        end
      end
    end
	# Charm
    if @effects[PBEffects::Charm]>0
      @effects[PBEffects::Charm] -= 1
      if @effects[PBEffects::Charm]<=0
        pbCureCharm
        @battle.pbDisplay(_INTL("{1} was released from the charm.",pbThis))
      else
        @battle.pbAnimation(:LUCKYCHANT,self,nil)
        @battle.pbDisplay(_INTL("{1} is charmed!",pbThis))
        threshold = 30 + 35 * @effects[PBEffects::CharmChance]
        if (@battle.pbRandom(100)<threshold && !hasActiveAbility?([:HEADACHE,:TANGLEDFEET])) || ($DEBUG && Input.press?(Input::CTRL))
          @effects[PBEffects::CharmChance] = 0
		  superEff = false
		  @battle.eachOtherSideBattler(@index) do |b| # Brain Scramble
			superEff = true if b.hasActiveAbility?(:BRAINSCRAMBLE)
		  end
          pbConfusionDamage(_INTL("It's energy went wild due to the charm!"),true,superEff)
		  @effects[PBEffects::CharmChance] = -999
          @lastMoveFailed = true
          return false
        else
          @effects[PBEffects::CharmChance] += 1
        end
      end
    end
    # Paralysis
    if @status == :PARALYSIS && @commandPhasesThisRound == 0
      if @battle.pbRandom(100)<25
        pbContinueStatus
        @lastMoveFailed = true
        return false
      end
    end
    # Infatuation
    if @effects[PBEffects::Attract]>=0
      @battle.pbCommonAnimation("Attract",self)
      @battle.pbDisplay(_INTL("{1} is in love with {2}!",pbThis,
         @battle.battlers[@effects[PBEffects::Attract]].pbThis(true)))
      if @battle.pbRandom(100)<50
        @battle.pbDisplay(_INTL("{1} is immobilized by love!",pbThis))
        @lastMoveFailed = true
        return false
      end
    end
    return true
  end
  
  #=============================================================================
  # Initial success check against the target. Done once before the first hit.
  # Includes move-specific failure conditions, protections and type immunities.
  #=============================================================================
  def pbSuccessCheckAgainstTarget(move,user,target)
	# Unseen Fist
    unseenfist = user.ability == :UNSEENFIST && move.contactMove?
    typeMod = move.pbCalcTypeMod(move.calcType,user,target)
    target.damageState.typeMod = typeMod
    # Two-turn attacks can't fail here in the charging turn
    return true if user.effects[PBEffects::TwoTurnAttack]
    # Move-specific failures
    return false if move.pbFailsAgainstTarget?(user,target)
    # Immunity to priority moves because of Psychic Terrain
    if @battle.field.terrain == :Psychic && target.affectedByTerrain? && target.opposes?(user) &&
       @battle.choices[user.index][4]>0   # Move priority saved from pbCalculatePriority
      @battle.pbDisplay(_INTL("{1} surrounds itself with psychic terrain!",target.pbThis))
      return false
    end
    # Crafty Shield
    if target.pbOwnSide.effects[PBEffects::CraftyShield] && user.index!=target.index && move.function != "17C"
       move.statusMove? && !move.pbTarget(user).targets_all && !unseenfist
      @battle.pbCommonAnimation("CraftyShield",target)
      @battle.pbDisplay(_INTL("Crafty Shield protected {1}!",target.pbThis(true)))
      target.damageState.protected = true
      @battle.successStates[user.index].protected = true
      return false
    end
    # Wide Guard
    if target.pbOwnSide.effects[PBEffects::WideGuard] && user.index!=target.index &&
       move.pbTarget(user).num_targets > 1 &&
       (Settings::MECHANICS_GENERATION >= 7 || move.damagingMove?) && !unseenfist
      @battle.pbCommonAnimation("WideGuard",target)
      @battle.pbDisplay(_INTL("Wide Guard protected {1}!",target.pbThis(true)))
      target.damageState.protected = true
      @battle.successStates[user.index].protected = true
      return false
    end
    if move.canProtectAgainst?
      # Quick Guard
      if target.pbOwnSide.effects[PBEffects::QuickGuard] && !unseenfist &&
         @battle.choices[user.index][4]>0   # Move priority saved from pbCalculatePriority
        @battle.pbCommonAnimation("QuickGuard",target)
        @battle.pbDisplay(_INTL("Quick Guard protected {1}!",target.pbThis(true)))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        return false
      end
      # Protect
      if target.effects[PBEffects::Protect] && !unseenfist
        @battle.pbCommonAnimation("Protect",target)
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        return false
      end
	  # Obstruct
	  if target.effects[PBEffects::Obstruct] && !unseenfist
        @battle.pbCommonAnimation("Obstruct",target)
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        if move.pbContactMove?(user) && user.affectedByContactEffect?
          if user.pbCanLowerStatStage?(:DEFENSE)
            user.pbLowerStatStage(:DEFENSE,2,nil)
          end
        end
        return false
      end
      # King's Shield
      if target.effects[PBEffects::KingsShield] && move.damagingMove? && !unseenfist
        @battle.pbCommonAnimation("KingsShield",target)
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        if move.pbContactMove?(user) && user.affectedByContactEffect?
          if user.pbCanLowerStatStage?(:ATTACK)
            user.pbLowerStatStage(:ATTACK,2,nil)
          end
        end
        return false
      end
      # Spiky Shield
      if target.effects[PBEffects::SpikyShield] && !unseenfist
        @battle.pbCommonAnimation("SpikyShield",target)
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        if move.pbContactMove?(user) && user.affectedByContactEffect?
          @battle.scene.pbDamageAnimation(user)
          user.pbReduceHP(user.totalhp/8,false)
          @battle.pbDisplay(_INTL("{1} was hurt!",user.pbThis))
          user.pbItemHPHealCheck
        end
        return false
      end
      # Baneful Bunker
      if target.effects[PBEffects::BanefulBunker] && !unseenfist
        @battle.pbCommonAnimation("BanefulBunker",target)
        @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        if move.pbContactMove?(user) && user.affectedByContactEffect?
          user.pbPoison(target) if user.pbCanPoison?(target,false)
        end
        return false
      end
      # Mat Block
      if target.pbOwnSide.effects[PBEffects::MatBlock] && move.damagingMove? && !unseenfist
        # NOTE: Confirmed no common animation for this effect.
        @battle.pbDisplay(_INTL("{1} was blocked by the kicked-up mat!",move.name))
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        return false
      end
    end
    # Magic Coat/Magic Bounce
    if move.canMagicCoat? && !target.semiInvulnerable? && target.opposes?(user)
      if target.effects[PBEffects::MagicCoat]
        target.damageState.magicCoat = true
        target.effects[PBEffects::MagicCoat] = false
        return false
      end
      if target.hasActiveAbility?(:MAGICBOUNCE) && !@battle.moldBreaker &&
         !target.effects[PBEffects::MagicBounce]
        target.damageState.magicBounce = true
        target.effects[PBEffects::MagicBounce] = true
        return false
      end
    end
    # Immunity because of ability (intentionally before type immunity check)
    if move.pbImmunityByAbility(user,target)
		if !user.boss? && !target.boss
			return false
		else
			name = (user.boss ? user : target).pbThis(true)
			@battle.pbDisplay(_INTL("Except, within {1}'s aura, immunities are pierced!",name))
			typeMod /= 2
		end
	end
    # Type immunity
    if move.pbDamagingMove? && Effectiveness.ineffective?(typeMod)
      PBDebug.log("[Target immune] #{target.pbThis}'s type immunity")
	  if !user.boss && !target.boss
		@battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
		return false
	  else
	    name = (user.boss ? user : target).pbThis(true)
	    @battle.pbDisplay(_INTL("Within {1}'s aura, immunities are pierced!",name))
      end
    end
    # Dark-type immunity to moves made faster by Prankster
    if Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::Prankster] &&
       target.pbHasType?(:DARK) && target.opposes?(user)
      PBDebug.log("[Target immune] #{target.pbThis} is Dark-type and immune to Prankster-boosted moves")
      @battle.pbDisplay(_INTL("It doesn't affect {1} due to its Dark typing...",target.pbThis(true)))
      return false
    end
    # Airborne-based immunity to Ground moves
    if move.damagingMove? && move.calcType == :GROUND &&
       target.airborne? && !move.hitsFlyingTargets?
      if target.hasActiveAbility?(:LEVITATE) && !@battle.moldBreaker
        @battle.pbShowAbilitySplash(target)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} avoided the attack with {2}!",target.pbThis,target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
        return false
      end
      if target.hasActiveItem?(:AIRBALLOON)
        @battle.pbDisplay(_INTL("{1}'s {2} makes Ground moves miss!",target.pbThis,target.itemName))
        return false
      end
      if target.effects[PBEffects::MagnetRise]>0
        @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Magnet Rise!",target.pbThis))
        return false
      end
      if target.effects[PBEffects::Telekinesis]>0
        @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Telekinesis!",target.pbThis))
        return false
      end
    end
    # Immunity to powder-based moves
    if move.powderMove?
      if target.pbHasType?(:GRASS) && Settings::MORE_TYPE_EFFECTS
        PBDebug.log("[Target immune] #{target.pbThis} is Grass-type and immune to powder-based moves")
        @battle.pbDisplay(_INTL("It doesn't affect {1} because of its Grass typing...",target.pbThis(true)))
        return false
      end
      if Settings::MECHANICS_GENERATION >= 6
        if target.hasActiveAbility?(:OVERCOAT) && !@battle.moldBreaker
          @battle.pbShowAbilitySplash(target)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
          else
            @battle.pbDisplay(_INTL("It doesn't affect {1} because of its {2}.",target.pbThis(true),target.abilityName))
          end
          @battle.pbHideAbilitySplash(target)
          return false
        end
        if target.hasActiveItem?(:SAFETYGOGGLES)
          PBDebug.log("[Item triggered] #{target.pbThis} has Safety Goggles and is immune to powder-based moves")
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
          return false
        end
      end
    end
    # Substitute
    if target.effects[PBEffects::Substitute]>0 && move.statusMove? &&
       !move.ignoresSubstitute?(user) && user.index!=target.index
      PBDebug.log("[Target immune] #{target.pbThis} is protected by its Substitute")
      @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis(true)))
      return false
    end
    return true
  end
  
  #=============================================================================
  # Decide whether the trainer is allowed to tell the Pokémon to use the given
  # move. Called when choosing a command for the round.
  # Also called when processing the Pokémon's action, because these effects also
  # prevent Pokémon action. Relevant because these effects can become active
  # earlier in the same round (after choosing the command but before using the
  # move) or an unusable move may be called by another move such as Metronome.
  #=============================================================================
  def pbCanChooseMove?(move,commandPhase,showMessages=true,specialUsage=false)
    # Disable
    if @effects[PBEffects::DisableMove]==move.id && !specialUsage
      if showMessages
        msg = _INTL("{1}'s {2} is disabled!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Heal Block
    if @effects[PBEffects::HealBlock]>0 && move.healingMove?
      if showMessages
        msg = _INTL("{1} can't use {2} because of Heal Block!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Gravity
    if @battle.field.effects[PBEffects::Gravity]>0 && move.unusableInGravity?
      if showMessages
        msg = _INTL("{1} can't use {2} because of gravity!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Throat Chop
    if @effects[PBEffects::ThroatChop]>0 && move.soundMove?
      if showMessages
        msg = _INTL("{1} can't use {2} because of Throat Chop!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Choice Band
    if @effects[PBEffects::ChoiceBand]
      if hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF]) &&
         pbHasMove?(@effects[PBEffects::ChoiceBand])
        if move.id!=@effects[PBEffects::ChoiceBand]
          if showMessages
            msg = _INTL("{1} allows the use of only {2}!",itemName,
               GameData::Move.get(@effects[PBEffects::ChoiceBand]).name)
            (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
          end
          return false
        end
      else
        @effects[PBEffects::ChoiceBand] = nil
      end
    end
	# Gorilla Tactics
    if @effects[PBEffects::GorillaTactics]>=0
      if hasActiveAbility?(:GORILLATACTICS)
        if move.id!=@effects[PBEffects::GorillaTactics]
          if showMessages
            msg = _INTL("{1} allows the use of only {2} !",abilityName,GameData::Move.get(@effects[PBEffects::GorillaTactics]).name)
            (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
          end
          return false
        end
      else
        @effects[PBEffects::GorillaTactics] = -1
      end
    end
    # Taunt
    if @effects[PBEffects::Taunt]>0 && move.statusMove?
      if showMessages
        msg = _INTL("{1} can't use {2} after the taunt!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Torment
    if @effects[PBEffects::Torment] && !@effects[PBEffects::Instructed] &&
       @lastMoveUsed && move.id==@lastMoveUsed && move.id!=@battle.struggle.id
      if showMessages
        msg = _INTL("{1} can't use the same move twice in a row due to the torment!",pbThis)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Imprison
    @battle.eachOtherSideBattler(@index) do |b|
      next if !b.effects[PBEffects::Imprison] || !b.pbHasMove?(move.id)
      if showMessages
        msg = _INTL("{1} can't use its sealed {2}!",pbThis,move.name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Assault Vest (prevents choosing status moves but doesn't prevent
    # executing them)
    if hasActiveItem?(:ASSAULTVEST) && move.statusMove? && commandPhase
      if showMessages
        msg = _INTL("The effects of the {1} prevent status moves from being used!",
           itemName)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    # Belch
    return false if !move.pbCanChooseMove?(self,commandPhase,showMessages)
    return true
  end
  
  #=============================================================================
  # Obedience check
  #=============================================================================
  # Return true if Pokémon continues attacking (although it may have chosen to
  # use a different move in disobedience), or false if attack stops.
  def pbObedienceCheck?(choice)
    return true
  end
  
  #=============================================================================
  # Master "use move" method
  #=============================================================================
  def pbUseMove(choice,specialUsage=false)
    # NOTE: This is intentionally determined before a multi-turn attack can
    #       set specialUsage to true.
    skipAccuracyCheck = (specialUsage && choice[2]!=@battle.struggle)
    # Start using the move
    pbBeginTurn(choice)
    # Force the use of certain moves if they're already being used
    if usingMultiTurnAttack?
      choice[2] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(@currentMove))
      specialUsage = true
    elsif @effects[PBEffects::Encore]>0 && choice[1]>=0 &&
       @battle.pbCanShowCommands?(@index)
      idxEncoredMove = pbEncoredMoveIndex
      if idxEncoredMove>=0 && @battle.pbCanChooseMove?(@index,idxEncoredMove,false)
        if choice[1]!=idxEncoredMove   # Change move if battler was Encored mid-round
          choice[1] = idxEncoredMove
          choice[2] = @moves[idxEncoredMove]
          choice[3] = -1   # No target chosen
        end
      end
    end
    # Labels the move being used as "move"
    move = choice[2]
    return if !move   # if move was not chosen somehow
    # Try to use the move (inc. disobedience)
    @lastMoveFailed = false
    if !pbTryUseMove(choice,move,specialUsage,skipAccuracyCheck)
      @lastMoveUsed     = nil
      @lastMoveUsedType = nil
      if !specialUsage
        @lastRegularMoveUsed   = nil
        @lastRegularMoveTarget = -1
      end
      @battle.pbGainExp   # In case self is KO'd due to confusion
      pbCancelMoves
      pbEndTurn(choice)
      return
    end
    move = choice[2]   # In case disobedience changed the move to be used
    return if !move   # if move was not chosen somehow
    # Subtract PP
    if !specialUsage
      if !pbReducePP(move)
        @battle.pbDisplay(_INTL("{1} used {2}!",pbThis,move.name))
        @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
        @lastMoveUsed          = nil
        @lastMoveUsedType      = nil
        @lastRegularMoveUsed   = nil
        @lastRegularMoveTarget = -1
        @lastMoveFailed        = true
        pbCancelMoves
        pbEndTurn(choice)
        return
      end
    end
    # Stance Change
    if isSpecies?(:AEGISLASH) && self.ability == :STANCECHANGE
      if move.damagingMove?
        pbChangeForm(1,_INTL("{1} changed to Blade Forme!",pbThis))
      elsif move.id == :KINGSSHIELD
        pbChangeForm(0,_INTL("{1} changed to Shield Forme!",pbThis))
      end
    end
    # Calculate the move's type during this usage
    move.calcType = move.pbCalcType(self)
    # Start effect of Mold Breaker
    @battle.moldBreaker = hasMoldBreaker?
    # Remember that user chose a two-turn move
    if move.pbIsChargingTurn?(self)
      # Beginning the use of a two-turn attack
      @effects[PBEffects::TwoTurnAttack] = move.id
      @currentMove = move.id
    else
      @effects[PBEffects::TwoTurnAttack] = nil   # Cancel use of two-turn attack
    end
    # Add to counters for moves which increase them when used in succession
    move.pbChangeUsageCounters(self,specialUsage)
    # Charge up Metronome item
    if hasActiveItem?(:METRONOME) && !move.callsAnotherMove?
      if @lastMoveUsed && @lastMoveUsed==move.id && !@lastMoveFailed
        @effects[PBEffects::Metronome] += 1
      else
        @effects[PBEffects::Metronome] = 0
      end
    end
    # Record move as having been used
    @lastMoveUsed     = move.id
    @lastMoveUsedType = move.calcType   # For Conversion 2
    if !specialUsage
      @lastRegularMoveUsed   = move.id   # For Disable, Encore, Instruct, Mimic, Mirror Move, Sketch, Spite
      @lastRegularMoveTarget = choice[3]   # For Instruct (remembering original target is fine)
      @movesUsed.push(move.id) if !@movesUsed.include?(move.id)   # For Last Resort
    end
    @battle.lastMoveUsed = move.id   # For Copycat
    @battle.lastMoveUser = @index   # For "self KO" battle clause to avoid draws
    @battle.successStates[@index].useState = 1   # Battle Arena - assume failure
    # Find the default user (self or Snatcher) and target(s)
    user = pbFindUser(choice,move)
    user = pbChangeUser(choice,move,user)
    targets = pbFindTargets(choice,move,user)
    targets = pbChangeTargets(move,user,targets)
    # Pressure
    if !specialUsage
      targets.each do |b|
        next unless b.opposes?(user) && b.hasActiveAbility?(:PRESSURE)
        PBDebug.log("[Ability triggered] #{b.pbThis}'s #{b.abilityName}")
        user.pbReducePP(move)
      end
      if move.pbTarget(user).affects_foe_side
        @battle.eachOtherSideBattler(user) do |b|
          next unless b.hasActiveAbility?(:PRESSURE)
          PBDebug.log("[Ability triggered] #{b.pbThis}'s #{b.abilityName}")
          user.pbReducePP(move)
        end
      end
    end
    # Dazzling/Queenly Majesty make the move fail here
    @battle.pbPriority(true).each do |b|
      next if !b || !b.abilityActive?
      if BattleHandlers.triggerMoveBlockingAbility(b.ability,b,user,targets,move,@battle)
        @battle.pbDisplayBrief(_INTL("{1} used {2}!",user.pbThis,move.name))
        @battle.pbShowAbilitySplash(b)
        @battle.pbDisplay(_INTL("{1} cannot use {2}!",user.pbThis,move.name))
        @battle.pbHideAbilitySplash(b)
        user.lastMoveFailed = true
        pbCancelMoves
        pbEndTurn(choice)
        return
      end
    end
    # "X used Y!" message
    # Can be different for Bide, Fling, Focus Punch and Future Sight
    # NOTE: This intentionally passes self rather than user. The user is always
    #       self except if Snatched, but this message should state the original
    #       user (self) even if the move is Snatched.
    move.pbDisplayUseMessage(self,targets)
    # Snatch's message (user is the new user, self is the original user)
    if move.snatched
      @lastMoveFailed = true   # Intentionally applies to self, not user
      @battle.pbDisplay(_INTL("{1} snatched {2}'s move!",user.pbThis,pbThis(true)))
    end
    # "But it failed!" checks
    if move.pbMoveFailed?(user,targets)
      PBDebug.log(sprintf("[Move failed] In function code %s's def pbMoveFailed?",move.function))
      user.lastMoveFailed = true
      pbCancelMoves
      pbEndTurn(choice)
      return
    end
    # Perform set-up actions and display messages
    # Messages include Magnitude's number and Pledge moves' "it's a combo!"
    move.pbOnStartUse(user,targets)
    # Powder
    if user.effects[PBEffects::Powder] && move.calcType == :FIRE
      @battle.pbCommonAnimation("Powder",user)
      @battle.pbDisplay(_INTL("When the flame touched the powder on the Pokémon, it exploded!"))
      user.lastMoveFailed = true
      if ![:Rain, :HeavyRain].include?(@battle.pbWeather) && user.takesIndirectDamage?
        oldHP = user.hp
        user.pbReduceHP((user.totalhp/4.0).round,false)
        user.pbFaint if user.fainted?
        @battle.pbGainExp   # In case user is KO'd by this
        user.pbItemHPHealCheck
        if user.pbAbilitiesOnDamageTaken(oldHP)
          user.pbEffectsOnSwitchIn(true)
        end
      end
      pbCancelMoves
      pbEndTurn(choice)
      return
    end
    # Primordial Sea, Desolate Land
    if move.damagingMove?
      case @battle.pbWeather
      when :HeavyRain
        if move.calcType == :FIRE
          @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
          user.lastMoveFailed = true
          pbCancelMoves
          pbEndTurn(choice)
          return
        end
      when :HarshSun
        if move.calcType == :WATER
          @battle.pbDisplay(_INTL("The Water-type attack evaporated in the harsh sunlight!"))
          user.lastMoveFailed = true
          pbCancelMoves
          pbEndTurn(choice)
          return
        end
      end
    end
    # Protean
    if (user.hasActiveAbility?(:PROTEAN) || user.hasActiveAbility?(:LIBERO)) && !move.callsAnotherMove? && !move.snatched
      if user.pbHasOtherType?(move.calcType) && !GameData::Type.get(move.calcType).pseudo_type
        @battle.pbShowAbilitySplash(user)
        user.pbChangeTypes(move.calcType)
        typeName = GameData::Type.get(move.calcType).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typeName))
        @battle.pbHideAbilitySplash(user)
        # NOTE: The GF games say that if Curse is used by a non-Ghost-type
        #       Pokémon which becomes Ghost-type because of Protean, it should
        #       target and curse itself. I think this is silly, so I'm making it
        #       choose a random opponent to curse instead.
        if move.function=="10D" && targets.length==0   # Curse
          choice[3] = -1
          targets = pbFindTargets(choice,move,user)
        end
      end
    end
	# Redirect Dragon Darts first hit if necessary
    if move.function=="17C" && @battle.pbSideSize(targets[0].index)>1
      targets=pbChangeTargets(move,user,targets,0)
    end
    #---------------------------------------------------------------------------
    magicCoater  = -1
    magicBouncer = -1
    if targets.length == 0 && move.pbTarget(user).num_targets > 0 && !move.worksWithNoTargets?
      # def pbFindTargets should have found a target(s), but it didn't because
      # they were all fainted
      # All target types except: None, User, UserSide, FoeSide, BothSides
      @battle.pbDisplay(_INTL("But there was no target..."))
      user.lastMoveFailed = true
    else   # We have targets, or move doesn't use targets
      # Reset whole damage state, perform various success checks (not accuracy)
      user.initialHP = user.hp
      targets.each do |b|
        b.damageState.reset
        b.damageState.initialHP = b.hp
        if !pbSuccessCheckAgainstTarget(move,user,b)
          b.damageState.unaffected = true
        end
      end
      # Magic Coat/Magic Bounce checks (for moves which don't target Pokémon)
      if targets.length==0 && move.canMagicCoat?
        @battle.pbPriority(true).each do |b|
          next if b.fainted? || !b.opposes?(user)
          next if b.semiInvulnerable?
          if b.effects[PBEffects::MagicCoat]
            magicCoater = b.index
            b.effects[PBEffects::MagicCoat] = false
            break
          elsif b.hasActiveAbility?(:MAGICBOUNCE) && !@battle.moldBreaker &&
             !b.effects[PBEffects::MagicBounce]
            magicBouncer = b.index
            b.effects[PBEffects::MagicBounce] = true
            break
          end
        end
      end
      # Get the number of hits
      numHits = move.pbNumHits(user,targets)
      # Process each hit in turn
      realNumHits = 0
      for i in 0...numHits
        break if magicCoater>=0 || magicBouncer>=0
        success = pbProcessMoveHit(move,user,targets,i,skipAccuracyCheck)
        if !success
          if i==0 && targets.length>0
            hasFailed = false
            targets.each do |t|
              next if t.damageState.protected
              hasFailed = t.damageState.unaffected
              break if !t.damageState.unaffected
            end
            user.lastMoveFailed = hasFailed
          end
          break
        end
        realNumHits += 1
        break if user.fainted?
        break if [:SLEEP, :FROZEN].include?(user.status)
        # NOTE: If a multi-hit move becomes disabled partway through doing those
        #       hits (e.g. by Cursed Body), the rest of the hits continue as
        #       normal.
        break if !targets.any? { |t| !t.fainted? }   # All targets are fainted
      end
      # Battle Arena only - attack is successful
      @battle.successStates[user.index].useState = 2
      if targets.length>0
        @battle.successStates[user.index].typeMod = 0
        targets.each do |b|
          next if b.damageState.unaffected
          @battle.successStates[user.index].typeMod += b.damageState.typeMod
        end
      end
      # Effectiveness message for multi-hit moves
      # NOTE: No move is both multi-hit and multi-target, and the messages below
      #       aren't quite right for such a hypothetical move.
      if numHits>1
        if move.damagingMove?
          targets.each do |b|
            next if b.damageState.unaffected || b.damageState.substitute
            move.pbEffectivenessMessage(user,b,targets.length)
          end
        end
        if realNumHits==1
          @battle.pbDisplay(_INTL("Hit 1 time!"))
        elsif realNumHits>1
          @battle.pbDisplay(_INTL("Hit {1} times!",realNumHits))
        end
      end
      # Magic Coat's bouncing back (move has targets)
      targets.each do |b|
        next if b.fainted?
        next if !b.damageState.magicCoat && !b.damageState.magicBounce
        @battle.pbShowAbilitySplash(b) if b.damageState.magicBounce
        @battle.pbDisplay(_INTL("{1} bounced the {2} back!",b.pbThis,move.name))
        @battle.pbHideAbilitySplash(b) if b.damageState.magicBounce
        newChoice = choice.clone
        newChoice[3] = user.index
        newTargets = pbFindTargets(newChoice,move,b)
        newTargets = pbChangeTargets(move,b,newTargets)
        success = pbProcessMoveHit(move,b,newTargets,0,false)
        b.lastMoveFailed = true if !success
        targets.each { |otherB| otherB.pbFaint if otherB && otherB.fainted? }
        user.pbFaint if user.fainted?
      end
      # Magic Coat's bouncing back (move has no targets)
      if magicCoater>=0 || magicBouncer>=0
        mc = @battle.battlers[(magicCoater>=0) ? magicCoater : magicBouncer]
        if !mc.fainted?
          user.lastMoveFailed = true
          @battle.pbShowAbilitySplash(mc) if magicBouncer>=0
          @battle.pbDisplay(_INTL("{1} bounced the {2} back!",mc.pbThis,move.name))
          @battle.pbHideAbilitySplash(mc) if magicBouncer>=0
          success = pbProcessMoveHit(move,mc,[],0,false)
          mc.lastMoveFailed = true if !success
          targets.each { |b| b.pbFaint if b && b.fainted? }
          user.pbFaint if user.fainted?
        end
      end
      # Move-specific effects after all hits
      targets.each { |b| move.pbEffectAfterAllHits(user,b) }
	  
	  if !battle.wildBattle?
		  # Triggers dialogue for each target hit
		  targets.each do |t|
			next if t.damageState.protected || t.damageState.unaffected
			if @battle.pbOwnedByPlayer?(t.index)
				# Trigger each opponent's dialogue
				@battle.opponent.each_with_index do |trainer_speaking,idxTrainer|
					@battle.scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
						trainer = @battle.opponent[idxTrainer]
						PokeBattle_AI.triggerPlayerPokemonTookMoveDamageDialogue(policy,self,t,trainer_speaking,dialogue)
					}
				end
			else
				# Trigger just this pokemon's trainer's dialogue
				idxTrainer = @battle.pbGetOwnerIndexFromBattlerIndex(index)
				trainer_speaking = @battle.opponent[idxTrainer]
				@battle.scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
					PokeBattle_AI.triggerTrainerPokemonTookMoveDamageDialogue(policy,self,t,trainer_speaking,dialogue)
				}
			end
		  end
	  end
      # Faint if 0 HP
      targets.each { |b| b.pbFaint if b && b.fainted? }
      user.pbFaint if user.fainted?
      # External/general effects after all hits. Eject Button, Shell Bell, etc.
      pbEffectsAfterMove(user,targets,move,realNumHits)
    end
    # End effect of Mold Breaker
    @battle.moldBreaker = false
    # Gain Exp
    @battle.pbGainExp
    # Battle Arena only - update skills
    @battle.eachBattler { |b| @battle.successStates[b.index].updateSkill }
    # Shadow Pokémon triggering Hyper Mode
    pbHyperMode if @battle.choices[@index][0]!=:None   # Not if self is replaced
	# Refresh the scene to account for changes to pokemon status
	@battle.scene.pbRefresh()
    # End of move usage
    pbEndTurn(choice)
    # Instruct
    @battle.eachBattler do |b|
      next if !b.effects[PBEffects::Instruct] || !b.lastMoveUsed
      b.effects[PBEffects::Instruct] = false
      idxMove = -1
      b.eachMoveWithIndex { |m,i| idxMove = i if m.id==b.lastMoveUsed }
      next if idxMove<0
      oldLastRoundMoved = b.lastRoundMoved
      @battle.pbDisplay(_INTL("{1} used the move instructed by {2}!",b.pbThis,user.pbThis(true)))
      PBDebug.logonerr{
        b.effects[PBEffects::Instructed] = true
        b.pbUseMoveSimple(b.lastMoveUsed,b.lastRegularMoveTarget,idxMove,false)
        b.effects[PBEffects::Instructed] = false
      }
      b.lastRoundMoved = oldLastRoundMoved
      @battle.pbJudge
      return if @battle.decision>0
    end
    # Dancer
    if !@effects[PBEffects::Dancer] && !user.lastMoveFailed && realNumHits>0 &&
       !move.snatched && magicCoater<0 && @battle.pbCheckGlobalAbility(:DANCER) &&
       move.danceMove?
      dancers = []
      @battle.pbPriority(true).each do |b|
        dancers.push(b) if b.index!=user.index && b.hasActiveAbility?(:DANCER)
      end
      while dancers.length>0
        nextUser = dancers.pop
        oldLastRoundMoved = nextUser.lastRoundMoved
        # NOTE: Petal Dance being used because of Dancer shouldn't lock the
        #       Dancer into using that move, and shouldn't contribute to its
        #       turn counter if it's already locked into Petal Dance.
        oldOutrage = nextUser.effects[PBEffects::Outrage]
        nextUser.effects[PBEffects::Outrage] += 1 if nextUser.effects[PBEffects::Outrage]>0
        oldCurrentMove = nextUser.currentMove
        preTarget = choice[3]
        preTarget = user.index if nextUser.opposes?(user) || !nextUser.opposes?(preTarget)
        @battle.pbShowAbilitySplash(nextUser,true)
        @battle.pbHideAbilitySplash(nextUser)
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} kept the dance going with {2}!",
             nextUser.pbThis,nextUser.abilityName))
        end
        PBDebug.logonerr{
          nextUser.effects[PBEffects::Dancer] = true
          nextUser.pbUseMoveSimple(move.id,preTarget)
          nextUser.effects[PBEffects::Dancer] = false
        }
        nextUser.lastRoundMoved = oldLastRoundMoved
        nextUser.effects[PBEffects::Outrage] = oldOutrage
        nextUser.currentMove = oldCurrentMove
        @battle.pbJudge
        return if @battle.decision>0
      end
    end
  end
  
  #=============================================================================
  # Effects after all hits (i.e. at end of move usage)
  #=============================================================================
  def pbEffectsAfterMove(user,targets,move,numHits)
    # Destiny Bond
    # NOTE: Although Destiny Bond is similar to Grudge, they don't apply at
    #       the same time (although Destiny Bond does check whether it's going
    #       to trigger at the same time as Grudge).
    if user.effects[PBEffects::DestinyBondTarget]>=0 && !user.fainted?
      dbName = @battle.battlers[user.effects[PBEffects::DestinyBondTarget]].pbThis
      @battle.pbDisplay(_INTL("{1} took its attacker down with it!",dbName))
      user.pbReduceHP(user.hp,false)
      user.pbItemHPHealCheck
      user.pbFaint
      @battle.pbJudgeCheckpoint(user)
    end
    # User's ability
    if user.abilityActive?
      BattleHandlers.triggerUserAbilityEndOfMove(user.ability,user,targets,move,@battle)
    end
    # Greninja - Battle Bond
    if !user.fainted? && !user.effects[PBEffects::Transform] &&
       user.isSpecies?(:GRENINJA) && user.ability == :BATTLEBOND
      if !@battle.pbAllFainted?(user.idxOpposingSide) &&
         !@battle.battleBond[user.index&1][user.pokemonIndex]
        numFainted = 0
        targets.each { |b| numFainted += 1 if b.damageState.fainted }
        if numFainted>0 && user.form==1
          @battle.battleBond[user.index&1][user.pokemonIndex] = true
          @battle.pbDisplay(_INTL("{1} became fully charged due to its bond with its Trainer!",user.pbThis))
          @battle.pbShowAbilitySplash(user,true)
          @battle.pbHideAbilitySplash(user)
          user.pbChangeForm(2,_INTL("{1} became Ash-Greninja!",user.pbThis))
        end
      end
    end
    # Consume user's Gem
    if user.effects[PBEffects::GemConsumed]
      # NOTE: The consume animation and message for Gems are shown immediately
      #       after the move's animation, but the item is only consumed now.
      user.pbConsumeItem
    end
    # Pokémon switching caused by Roar, Whirlwind, Circle Throw, Dragon Tail
    switchedBattlers = []
    move.pbSwitchOutTargetsEffect(user,targets,numHits,switchedBattlers)
    # Target's item, user's item, target's ability (all negated by Sheer Force)
    if move.addlEffect==0 || !user.hasActiveAbility?(:SHEERFORCE)
      pbEffectsAfterMove2(user,targets,move,numHits,switchedBattlers)
    end
    # Some move effects that need to happen here, i.e. U-turn/Volt Switch
    # switching, Baton Pass switching, Parting Shot switching, Relic Song's form
    # changing, Fling/Natural Gift consuming item.
    if !switchedBattlers.include?(user.index)
      move.pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
    end
    if numHits>0
      @battle.eachBattler { |b| b.pbItemEndOfMoveCheck }
    end
  end
  
  # Everything in this method is negated by Sheer Force.
  def pbEffectsAfterMove2(user,targets,move,numHits,switchedBattlers)
    hpNow = user.hp   # Intentionally determined now, before Shell Bell
    # Target's held item (Eject Button, Red Card)
    switchByItem = []
    @battle.pbPriority(true).each do |b|
      next if !targets.any? { |targetB| targetB.index==b.index }
      next if b.damageState.unaffected || b.damageState.calcDamage==0 ||
         switchedBattlers.include?(b.index)
      next if !b.itemActive?
      BattleHandlers.triggerTargetItemAfterMoveUse(b.item,b,user,move,switchByItem,@battle)
	  # Eject Pack
	  if b.effects[PBEffects::LashOut]
		BattleHandlers.triggerItemOnStatLoss(b.item,b,user,move,switchByItem,@battle)
	  end 
    end
    @battle.moldBreaker = false if switchByItem.include?(user.index)
    @battle.pbPriority(true).each do |b|
      b.pbEffectsOnSwitchIn(true) if switchByItem.include?(b.index)
    end
    switchByItem.each { |idxB| switchedBattlers.push(idxB) }
    # User's held item (Life Orb, Shell Bell)
    if !switchedBattlers.include?(user.index) && user.itemActive?
      BattleHandlers.triggerUserItemAfterMoveUse(user.item,user,targets,move,numHits,@battle)
    end
    # Target's ability (Berserk, Color Change, Emergency Exit, Pickpocket, Wimp Out)
    switchWimpOut = []
    @battle.pbPriority(true).each do |b|
      next if !targets.any? { |targetB| targetB.index==b.index }
      next if b.damageState.unaffected || switchedBattlers.include?(b.index)
      next if !b.abilityActive?
      BattleHandlers.triggerTargetAbilityAfterMoveUse(b.ability,b,user,move,switchedBattlers,@battle)
      if !switchedBattlers.include?(b.index) && move.damagingMove?
        if b.pbAbilitiesOnDamageTaken(b.damageState.initialHP)   # Emergency Exit, Wimp Out
          switchWimpOut.push(b.index)
        end
      end
    end
    @battle.moldBreaker = false if switchWimpOut.include?(user.index)
    @battle.pbPriority(true).each do |b|
      next if b.index==user.index
      b.pbEffectsOnSwitchIn(true) if switchWimpOut.include?(b.index)
    end
    switchWimpOut.each { |idxB| switchedBattlers.push(idxB) }
    # User's ability (Emergency Exit, Wimp Out)
    if !switchedBattlers.include?(user.index) && move.damagingMove?
      hpNow = user.hp if user.hp<hpNow   # In case HP was lost because of Life Orb
      if user.pbAbilitiesOnDamageTaken(user.initialHP,hpNow)
        @battle.moldBreaker = false
        user.pbEffectsOnSwitchIn(true)
        switchedBattlers.push(user.index)
      end
    end
  end
  
  #=============================================================================
  # Attack a single target
  #=============================================================================
  def pbProcessMoveHit(move,user,targets,hitNum,skipAccuracyCheck)
    return false if user.fainted?
    # For two-turn attacks being used in a single turn
    move.pbInitialEffect(user,targets,hitNum)
    numTargets = 0   # Number of targets that are affected by this hit
    targets.each { |b| b.damageState.resetPerHit }
    # Count a hit for Parental Bond (if it applies)
    user.effects[PBEffects::ParentalBond] -= 1 if user.effects[PBEffects::ParentalBond]>0
	# Redirect Dragon Darts other hits
	if move.function=="17C" && @battle.pbSideSize(targets[0].index)>1 && hitNum>0
	  targets=pbChangeTargets(move,user,targets,1)
	end
    # Accuracy check (accuracy/evasion calc)
    if hitNum==0 || move.successCheckPerHit?
      targets.each do |b|
        next if b.damageState.unaffected
        if pbSuccessCheckPerHit(move,user,b,skipAccuracyCheck)
          numTargets += 1
        else
          b.damageState.missed     = true
          b.damageState.unaffected = true
        end
      end
      # If failed against all targets
      if targets.length>0 && numTargets==0 && !move.worksWithNoTargets?
        targets.each do |b|
          next if !b.damageState.missed || b.damageState.magicCoat
          pbMissMessage(move,user,b)
        end
        move.pbCrashDamage(user)
		move.pbAllMissed(user,targets)
        user.pbItemHPHealCheck
        pbCancelMoves
        return false
      end
    end
    # If we get here, this hit will happen and do something
    #---------------------------------------------------------------------------
    # Calculate damage to deal
    if move.pbDamagingMove?
      targets.each do |b|
        next if b.damageState.unaffected
        # Check whether Substitute/Disguise will absorb the damage
        move.pbCheckDamageAbsorption(user,b)
        # Calculate the damage against b
        # pbCalcDamage shows the "eat berry" animation for SE-weakening
        # berries, although the message about it comes after the additional
        # effect below
        move.pbCalcDamage(user,b,targets.length)   # Stored in damageState.calcDamage
        # Lessen damage dealt because of False Swipe/Endure/etc.
        move.pbReduceDamage(user,b)   # Stored in damageState.hpLost
      end
    end
    # Show move animation (for this hit)
    move.pbShowAnimation(move.id,user,targets,hitNum)
    # Type-boosting Gem consume animation/message
    if user.effects[PBEffects::GemConsumed] && hitNum==0
      # NOTE: The consume animation and message for Gems are shown now, but the
      #       actual removal of the item happens in def pbEffectsAfterMove.
      @battle.pbCommonAnimation("UseItem",user)
      @battle.pbDisplay(_INTL("The {1} strengthened {2}'s power!",
         GameData::Item.get(user.effects[PBEffects::GemConsumed]).name,move.name))
    end
    # Messages about missed target(s) (relevant for multi-target moves only)
    targets.each do |b|
      next if !b.damageState.missed
      pbMissMessage(move,user,b)
    end
    # Deal the damage (to all allies first simultaneously, then all foes
    # simultaneously)
    if move.pbDamagingMove?
      # This just changes the HP amounts and does nothing else
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbInflictHPDamage(b)
      end
      # Animate the hit flashing and HP bar changes
      move.pbAnimateHitAndHPLost(user,targets)
    end
    # Self-Destruct/Explosion's damaging and fainting of user
    move.pbSelfKO(user) if hitNum==0
    user.pbFaint if user.fainted?
    if move.pbDamagingMove?
      targets.each do |b|
        next if b.damageState.unaffected
        # NOTE: This method is also used for the OKHO special message.
        move.pbHitEffectivenessMessages(user,b,targets.length)
        # Record data about the hit for various effects' purposes
        move.pbRecordDamageLost(user,b)
      end
      # Close Combat/Superpower's stat-lowering, Flame Burst's splash damage,
      # and Incinerate's berry destruction
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbEffectWhenDealingDamage(user,b)
      end
      # Ability/item effects such as Static/Rocky Helmet, and Grudge, etc.
      targets.each do |b|
        next if b.damageState.unaffected
        pbEffectsOnMakingHit(move,user,b)
      end
      # Disguise/Endure/Sturdy/Focus Sash/Focus Band messages
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbEndureKOMessage(b)
      end
      # HP-healing held items (checks all battlers rather than just targets
      # because Flame Burst's splash damage affects non-targets)
      @battle.pbPriority(true).each { |b| b.pbItemHPHealCheck }
      # Animate battlers fainting (checks all battlers rather than just targets
      # because Flame Burst's splash damage affects non-targets)
      @battle.pbPriority(true).each { |b| b.pbFaint if b && b.fainted? }
    end
    @battle.pbJudgeCheckpoint(user,move)
    # Main effect (recoil/drain, etc.)
    targets.each do |b|
      next if b.damageState.unaffected
      move.pbEffectAgainstTarget(user,b)
    end
    move.pbEffectGeneral(user)
    targets.each { |b| b.pbFaint if b && b.fainted? }
    user.pbFaint if user.fainted?
    # Additional effect
    if !user.hasActiveAbility?(:SHEERFORCE)
      targets.each do |b|
        next if b.damageState.calcDamage==0
        chance = move.pbAdditionalEffectChance(user,b)
        next if chance<=0
        if @battle.pbRandom(100)<chance
          move.pbAdditionalEffect(user,b)
        end
      end
    end
    # Make the target flinch (because of an item/ability)
    targets.each do |b|
      next if b.fainted?
      next if b.damageState.calcDamage==0 || b.damageState.substitute
      chance = move.pbFlinchChance(user,b)
      next if chance<=0
      if @battle.pbRandom(100)<chance
        PBDebug.log("[Item/ability triggered] #{user.pbThis}'s King's Rock/Razor Fang or Stench")
        b.pbFlinch(user)
      end
    end
    # Message for and consuming of type-weakening berries
    # NOTE: The "consume held item" animation for type-weakening berries occurs
    #       during pbCalcDamage above (before the move's animation), but the
    #       message about it only shows here.
    targets.each do |b|
      next if b.damageState.unaffected
      next if !b.damageState.berryWeakened
	  name = b.itemName
	  name = "berry" if name == ""
      @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",name,b.pbThis(true)))
      b.pbConsumeItem if b.item
    end
    targets.each { |b| b.pbFaint if b && b.fainted? }
    user.pbFaint if user.fainted?
    return true
  end
  
  #=============================================================================
  # Redirect attack to another target
  #=============================================================================
  def pbChangeTargets(move,user,targets,dragondarts=-1)
    target_data = move.pbTarget(user)
    return targets if @battle.switching   # For Pursuit interrupting a switch
    return targets if move.cannotRedirect?
    return targets if move.function != "17C" && (!target_data.can_target_one_foe? || targets.length!=1)
	# Stalwart / Propeller Tail
    allySwitched = false
    ally = -1
    user.eachOpposing do |b|
      next if b.lastMoveUsed && GameData::Move.get(b.lastMoveUsed).function_code != "120"
      next if !target_data.can_target_one_foe?
      next if !hasActiveAbility?(:STALWART) && !hasActiveAbility?(:PROPELLERTAIL) && move.function != "182"
      next if !@battle.choices[b.index][3] == targets
      next if b.effects[PBEffects::SwitchedAlly] == -1
      allySwitched = !allySwitched
      ally = b.effects[PBEffects::SwitchedAlly]
      b.effects[PBEffects::SwitchedAlly] = -1
    end
    if allySwitched && ally >= 0
      targets = []
      pbAddTarget(targets,user,@battle.battlers[ally],move,!PBTargets.canChooseDistantTarget?(move.target))
      return targets
    end
    return targets if user.hasActiveAbility?(:STALWART) || user.hasActiveAbility?(:PROPELLERTAIL)
	return targets if move.function == "182"
    priority = @battle.pbPriority(true)
    nearOnly = !target_data.can_choose_distant_target?
    # Spotlight (takes priority over Follow Me/Rage Powder/Lightning Rod/Storm Drain)
    newTarget = nil; strength = 100   # Lower strength takes priority
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::SkyDrop]>=0
      next if b.effects[PBEffects::Spotlight]==0 ||
              b.effects[PBEffects::Spotlight]>=strength
      next if !b.opposes?(user)
      next if nearOnly && !b.near?(user)
      newTarget = b
      strength = b.effects[PBEffects::Spotlight]
    end
    if newTarget
      PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Spotlight made it the target")
      targets = []
      pbAddTarget(targets,user,newTarget,move,nearOnly)
      return targets
    end
	# Dragon Darts redirection
    if dragondarts>=0
      newTargets=[]
      neednewtarget=false
      # Check if first use has to be redirected
      if dragondarts==0
        targets.each do |b|
          next if !b.effects[PBEffects::Protect] &&
          !(b.effects[PBEffects::QuickGuard] && @battle.choices[user.index][4]>0) &&
          !b.effects[PBEffects::SpikyShield] &&
          !b.effects[PBEffects::BanefulBunker] &&
          !b.effects[PBEffects::Obstruct] &&
          b.effects[PBEffects::TwoTurnAttack]<=0 &&
          !move.pbImmunityByAbility(user,b) &&
          !Effectiveness.ineffective_type?(move.type,b.type1,b.type2) &&
          move.pbAccuracyCheck(user,b)
          next neednewtarget=true
        end
      end
      # Redirect first use if necessary or get another target on each consecutive use
      if neednewtarget || dragondarts==1
        targets[0].eachAlly do |b|
		  next if b.index == user.index && dragondarts==1 # Don't attack yourself on the second hit.
          next if b.effects[PBEffects::Protect] ||
          (b.effects[PBEffects::QuickGuard] && @battle.choices[user.index][4]>0) ||
          b.effects[PBEffects::SpikyShield] ||
          b.effects[PBEffects::BanefulBunker] ||
          b.effects[PBEffects::Obstruct] ||
          b.effects[PBEffects::TwoTurnAttack]>0||
          move.pbImmunityByAbility(user,b) ||
          Effectiveness.ineffective_type?(move.type,b.type1,b.type2) ||
          !move.pbAccuracyCheck(user,b)
          newTargets.push(b)
		  b.damageState.unaffected = false
		  # In double battle, the pokémon might keep this state from a hit from the ally.
          break
        end
      end
      # Final target
      targets=newTargets if newTargets.length!=0
      # Reduce PP if the new target has Pressure
      if targets[0].hasActiveAbility?(:PRESSURE)
        user.pbReducePP(move) # Reduce PP
      end
    end
    # Follow Me/Rage Powder (takes priority over Lightning Rod/Storm Drain)
    newTarget = nil; strength = 100   # Lower strength takes priority
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::SkyDrop]>=0
      next if b.effects[PBEffects::RagePowder] && !user.affectedByPowder?
      next if b.effects[PBEffects::FollowMe]==0 ||
              b.effects[PBEffects::FollowMe]>=strength
      next if !b.opposes?(user)
      next if nearOnly && !b.near?(user)
      newTarget = b
      strength = b.effects[PBEffects::FollowMe]
    end
    if newTarget
      PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Follow Me/Rage Powder made it the target")
      targets = []
      pbAddTarget(targets,user,newTarget,move,nearOnly)
      return targets
    end
    # Lightning Rod
    targets = pbChangeTargetByAbility(:LIGHTNINGROD,:ELECTRIC,move,user,targets,priority,nearOnly)
    # Storm Drain
    targets = pbChangeTargetByAbility(:STORMDRAIN,:WATER,move,user,targets,priority,nearOnly)
	# Challenger
    targets = pbChangeTargetByAbility(:CHALLENGER,:FIGHTING,move,user,targets,priority,nearOnly)
    return targets
  end
  
  
end