class PokeBattle_Battler
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
    # Choice Items
    if @effects[PBEffects::ChoiceBand]
      if hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF]) &&
         pbHasMove?(@effects[PBEffects::ChoiceBand])
        if move.id != @effects[PBEffects::ChoiceBand] && move.id != :STRUGGLE
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
    if @effects[PBEffects::GorillaTactics]
      if hasActiveAbility?(:GORILLATACTICS)
        if move.id != @effects[PBEffects::GorillaTactics]
          if showMessages
            msg = _INTL("{1} allows the use of only {2}!",abilityName,GameData::Move.get(@effects[PBEffects::GorillaTactics]).name)
            (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
          end
          return false
        end
      else
        @effects[PBEffects::GorillaTactics] = nil
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
    # Assault Vest and Strike Vest (prevents choosing status moves but doesn't prevent
    # executing them)
    if (hasActiveItem?(:ASSAULTVEST) || hasActiveItem?(:STRIKEVEST)) && move.statusMove? && commandPhase
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
  # Check whether the user (self) is able to take action at all.
  # If this returns true, and if PP isn't a problem, the move will be considered
  # to have been used (even if it then fails for whatever reason).
  #=============================================================================
  def pbTryUseMove(choice,move,specialUsage,skipAccuracyCheck)
	  return true if move.isEmpowered?
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
    if pbHasStatus?(:SLEEP)
      reduceStatusCount(:SLEEP)
      if getStatusCount(:SLEEP)<=0
        pbCureStatus(true,:SLEEP)
      else
        pbContinueStatus(:SLEEP)
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
        threshold = 50 + 50 * @effects[PBEffects::ConfusionChance]
        if (@battle.pbRandom(100)<threshold && !hasActiveAbility?([:HEADACHE,:TANGLEDFEET])) || ($DEBUG && Input.press?(Input::CTRL))
          @effects[PBEffects::ConfusionChance] = 0
          superEff = @battle.pbCheckOpposingAbility(:BRAINSCRAMBLE,@index)
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
        threshold = 50 + 50 * @effects[PBEffects::CharmChance]
        if (@battle.pbRandom(100)<threshold && !hasActiveAbility?([:HEADACHE,:TANGLEDFEET])) || ($DEBUG && Input.press?(Input::CTRL))
          @effects[PBEffects::CharmChance] = 0
          superEff = @battle.pbCheckOpposingAbility(:BRAINSCRAMBLE,@index)
          pbConfusionDamage(_INTL("It's energy went wild due to the charm!"),true,superEff)
		      @effects[PBEffects::CharmChance] = -999
          @lastMoveFailed = true
          return false
        else
          @effects[PBEffects::CharmChance] += 1
        end
      end
    end
=begin
    # Paralysis
    if pbHasStatus?(:PARALYSIS) && (!boss || @battle.commandPhasesThisRound == 0)
      if @battle.pbRandom(100)<25
        pbContinueStatus(:PARALYSIS)
        @lastMoveFailed = true
        return false
      end
    end
=end
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

  def doesProtectionEffectNegateThisMove?(effectDisplayName,move,user,target,protectionIgnoredByAbility,animationName=nil)
    if move.canProtectAgainst? && !protectionIgnoredByAbility
      @battle.pbCommonAnimation(animationName,target) if !animationName.nil?
      @battle.pbDisplay(_INTL("{1} protected {2}!",effectDisplayName,target.pbThis(true)))
      if user.boss?
        target.damageState.partiallyProtected = true
        yield if block_given?
        @battle.pbDisplay(_INTL("Actually, {1} partially pierces through!",user.pbThis(true)))
      else
        target.damageState.protected = true
        @battle.successStates[user.index].protected = true
        yield if block_given?
        return true
      end
    elsif move.pbTarget(user).targets_foe
      @battle.pbDisplay(_INTL("{1} was ignored, and failed to protect {2}!",effectDisplayName,target.pbThis(true)))
    end
    return false
  end

  #=============================================================================
  # Initial success check against the target. Done once before the first hit.
  # Includes move-specific failure conditions, protections and type immunities.
  #=============================================================================
  def pbSuccessCheckAgainstTarget(move,user,target)
	  # Unseen Fist
    protectionIgnoredByAbility = false
    protectionIgnoredByAbility = true if user.ability == :UNSEENFIST && move.contactMove?
    protectionIgnoredByAbility = true if user.ability == :AQUASNEAK && user.turnCount <= 1
    typeMod = move.pbCalcTypeMod(move.calcType,user,target)
    target.damageState.typeMod = typeMod
    # Two-turn attacks can't fail here in the charging turn
    return true if user.effects[PBEffects::TwoTurnAttack]
    # Move-specific failures
    return false if move.pbFailsAgainstTarget?(user,target)
    # Immunity to priority moves because of Psychic Terrain
    if @battle.field.terrain == :Psychic && target.affectedByTerrain? && target.opposes?(user) &&
       @battle.choices[user.index][4] > 0   # Move priority saved from pbCalculatePriority
      @battle.pbDisplay(_INTL("{1} surrounds itself with psychic terrain!",target.pbThis))
      return false
    end
    # Crafty Shield
    if target.pbOwnSide.effects[PBEffects::CraftyShield] && user.index != target.index && 
        move.statusMove? && !move.pbTarget(user).targets_all && !protectionIgnoredByAbility
      @battle.pbCommonAnimation("CraftyShield",target)
      @battle.pbDisplay(_INTL("Crafty Shield protected {1}!",target.pbThis(true)))
      target.damageState.protected = true
      @battle.successStates[user.index].protected = true
      return false
    end
    # Wide Guard
    if target.pbOwnSide.effects[PBEffects::WideGuard] && user.index!=target.index &&
       move.pbTarget(user).num_targets > 1 && !move.smartSpreadsTargets? &&
       (Settings::MECHANICS_GENERATION >= 7 || move.damagingMove?) && !protectionIgnoredByAbility
      @battle.pbCommonAnimation("WideGuard",target)
      @battle.pbDisplay(_INTL("Wide Guard protected {1}!",target.pbThis(true)))
      target.damageState.protected = true
      @battle.successStates[user.index].protected = true
      return false
    end	
    ######################################################
    #	Protect Style Moves
    ######################################################
    # Quick Guard
    if target.pbOwnSide.effects[PBEffects::QuickGuard] && @battle.choices[user.index][4]>0   # Move priority saved from pbCalculatePriority
      return false if doesProtectionEffectNegateThisMove?("Quick Guard",move,user,target,protectionIgnoredByAbility,"QuickGuard")
    end
    # Protect
    if target.effects[PBEffects::Protect]
      return false if doesProtectionEffectNegateThisMove?("Protect",move,user,target,protectionIgnoredByAbility,"Protect")
    end
    # Obstruct
    if target.effects[PBEffects::Obstruct]
      return false if doesProtectionEffectNegateThisMove?("Obstruct",move,user,target,protectionIgnoredByAbility,"Obstruct") {
        if move.physicalMove?
          if user.pbCanLowerStatStage?(:DEFENSE)
            user.pbLowerStatStage(:DEFENSE,2,nil)
          end
        end
      }
    end
    # King's Shield
    if target.effects[PBEffects::KingsShield] && move.damagingMove?
      return false if doesProtectionEffectNegateThisMove?("King's Shield",move,user,target,protectionIgnoredByAbility,"KingsShield") {
        if move.physicalMove?
          if user.pbCanLowerStatStage?(:ATTACK)
          user.pbLowerStatStage(:ATTACK,1,nil)
          end
        end
      }
    end
    # Spiky Shield
    if target.effects[PBEffects::SpikyShield]
      return false if doesProtectionEffectNegateThisMove?("Spiky Shield",move,user,target,protectionIgnoredByAbility,"SpikyShield") {
        if move.physicalMove?
          @battle.pbDisplay(_INTL("{1} was hurt!",user.pbThis))
          user.applyFractionalDamage(1.0/8.0)
        end
      }
    end
    # Mirror Shield
    if target.effects[PBEffects::MirrorShield]
      return false if doesProtectionEffectNegateThisMove?("Mirror Shield",move,user,target,protectionIgnoredByAbility,"MirrorShield") {
        if move.specialMove?
          @battle.pbDisplay(_INTL("{1} was hurt!",user.pbThis))
          user.applyFractionalDamage(1.0/8.0)
        end
      }
    end
    # Baneful Bunker
    if target.effects[PBEffects::BanefulBunker]
      return false if doesProtectionEffectNegateThisMove?("Baneful Bunker",move,user,target,protectionIgnoredByAbility,"BanefulBunker") {
        if move.physicalMove?
          user.pbPoison(target) if user.pbCanPoison?(target,false)
        end
      }
    end
    # Red-Hot Retreat
    if target.effects[PBEffects::RedHotRetreat]
      return false if doesProtectionEffectNegateThisMove?("Red Hot Retreat",move,user,target,protectionIgnoredByAbility,"RedHotRetreat") {
        if move.specialMove?
          user.pbBurn(target) if user.pbCanBurn?(target,false)
        end
      }
    end
    # Mat Block
    if target.pbOwnSide.effects[PBEffects::MatBlock] && move.damagingMove?
      return false if doesProtectionEffectNegateThisMove?("Mat Block",move,user,target,protectionIgnoredByAbility)
    end
    # Magic Coat/Magic Bounce/Magic Shield
    if move.canMagicCoat? && !target.semiInvulnerable? && target.opposes?(user)
      if target.effects[PBEffects::MagicCoat]
        target.damageState.magicCoat = true
        target.effects[PBEffects::MagicCoat] = false
        return false
      end
      if target.hasActiveAbility?(:MAGICBOUNCE) && !@battle.moldBreaker #&& !target.effects[PBEffects::MagicBounce]
        target.damageState.magicBounce = true
        target.effects[PBEffects::MagicBounce] = true
        return false
      end
      if target.hasActiveAbility?(:MAGICSHIELD) && !@battle.moldBreaker
        @battle.pbShowAbilitySplash(target)
        target.damageState.protected = true
        @battle.pbDisplay(_INTL("{1} shielded itself from the {2}!",target.pbThis,move.name))
        @battle.pbHideAbilitySplash(target)
       return false
     end
    end
    # Move fails due to type immunity ability
    # Skipped for bosses using damaging moves so that it can be calculated properly later
    if move.inherentImmunitiesPierced?(user,target)
      # Do nothing
    else
      return false if targetInherentlyImmune?(user,target,move,typeMod,true)
    end
    # Substitute
    if target.effects[PBEffects::Substitute] > 0 && move.statusMove? &&
       !move.ignoresSubstitute?(user) && user.index != target.index
      PBDebug.log("[Target immune] #{target.pbThis} is protected by its Substitute")
      @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis(true)))
      return false
    end
    return true
  end

  def targetInherentlyImmune?(user,target,move,typeMod,showMessages=true)
    if move.pbImmunityByAbility(user,target) 
      @battle.triggerImmunityDialogue(user,target,true) if showMessages
      return true
    end
    # Type immunity
    if move.damagingMove? && Effectiveness.ineffective?(typeMod)
      PBDebug.log("[Target immune] #{target.pbThis}'s type immunity")
      if showMessages
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
        @battle.triggerImmunityDialogue(user,target,false)
      end
      return true
    end
    if airborneImmunity?(user,target,move,showMessages)
      PBDebug.log("[Target immune] #{target.pbThis}'s immunity due to being airborne")
      return true
    end
    # Dark-type immunity to moves made faster by Prankster
    if user.effects[PBEffects::Prankster] && target.pbHasType?(:DARK) && target.opposes?(user)
      PBDebug.log("[Target immune] #{target.pbThis} is Dark-type and immune to Prankster-boosted moves")
      if showMessages
        @battle.pbDisplay(_INTL("It doesn't affect {1} since Dark-types are immune to pranks...",target.pbThis(true)))
        @battle.triggerImmunityDialogue(user,target,false)
      end
      return true
    end
    return false
  end

  def airborneImmunity?(user,target,move,showMessages=true)
    # Airborne-based immunity to Ground moves
    if move.damagingMove? && move.calcType == :GROUND && target.airborne? && !move.hitsFlyingTargets?
      if target.hasLevitate? && !@battle.moldBreaker
        if showMessages
          @battle.pbShowAbilitySplash(target)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
          else
            @battle.pbDisplay(_INTL("{1} avoided the attack with {2}!",target.pbThis,target.abilityName))
          end
          @battle.pbHideAbilitySplash(target)
          @battle.triggerImmunityDialogue(user,target,true)
        end
        return true
      end
      if target.hasActiveItem?(:AIRBALLOON)
        if showMessages
          @battle.pbDisplay(_INTL("{1}'s {2} makes Ground moves miss!",target.pbThis,target.itemName))
          @battle.triggerImmunityDialogue(user,target,false)
        end
        return true
      end
      if target.effects[PBEffects::MagnetRise]>0
        if showMessages
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Magnet Rise!",target.pbThis))
          @battle.triggerImmunityDialogue(user,target,false)
        end
        return true
      end
      if target.effects[PBEffects::Telekinesis]>0
        if showMessages
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Telekinesis!",target.pbThis))
          @battle.triggerImmunityDialogue(user,target,false)
        end
        return true
      end
    end
    return false
  end
end