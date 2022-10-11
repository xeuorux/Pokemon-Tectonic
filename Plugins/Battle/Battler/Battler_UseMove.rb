class PokeBattle_Battler
	def pbEndTurn(_choice)
		@lastRoundMoved = @battle.turnCount   # Done something this round
		 # Gorilla Tactics
    if hasActiveAbility?(:GORILLATACTICS) && !@effects[PBEffects::GorillaTactics]
      if @lastMoveUsed && pbHasMove?(@lastMoveUsed)
			  @effects[PBEffects::GorillaTactics] = @lastMoveUsed
		  elsif @lastRegularMoveUsed && pbHasMove?(@lastRegularMoveUsed)
		  	@effects[PBEffects::GorillaTactics] = @lastRegularMoveUsed
		  end
    end
    # Choice Items
		if !@effects[PBEffects::ChoiceBand] && hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
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
  
  def pbConfusionDamage(msg,charm=false,superEff=false,basePower=50)
    @damageState.reset
    @damageState.initialHP = @hp
    confusionMove = charm ? PokeBattle_Charm.new(@battle,nil,basePower) : PokeBattle_Confusion.new(@battle,nil,basePower)
    confusionMove.calcType = confusionMove.pbCalcType(self)   # nil
    @damageState.typeMod = confusionMove.pbCalcTypeMod(confusionMove.calcType,self,self)   # 8
	  @damageState.typeMod *= 2.0 if superEff
    confusionMove.pbCheckDamageAbsorption(self,self)
    confusionMove.pbCalcDamage(self,self)
    confusionMove.pbReduceDamage(self,self)
    self.hp -= @damageState.hpLost
    confusionMove.pbAnimateHitAndHPLost(self,[self])
    @battle.pbDisplay(msg) if !msg.nil?   # "It hurt itself in its confusion!"
	  @battle.pbDisplay("It was super-effective!") if superEff
    confusionMove.pbRecordDamageLost(self,self)
    confusionMove.pbEndureKOMessage(self)
    pbFaint if fainted?
    pbItemHPHealCheck
  end

  # If there's an effect that causes damage before a move is used
  # This deals with the possible ramifications of that
  def cleanupPreMoveDamage(user,oldHP)
    user.pbFaint if user.fainted?
    @battle.pbGainExp   # In case user is KO'd by this
    user.pbItemHPHealCheck
    if user.pbAbilitiesOnDamageTaken(oldHP)
      user.pbEffectsOnSwitchIn(true)
    end
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
    if usingMultiTurnAttack? && !@currentMove.nil?
      choice[2] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(@currentMove))
      specialUsage = true
    elsif @effects[PBEffects::Encore] > 0 && choice[1] >= 0 && @battle.pbCanShowCommands?(@index)
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
    # Move blocking abilities make the move fail here
    @battle.pbPriority(true).each do |b|
      next if !b || !b.abilityActive?
      if BattleHandlers.triggerMoveBlockingAbility(b.ability,b,user,targets,move,@battle)
        @battle.pbDisplayBrief(_INTL("{1} tried to use {2}!",user.pbThis,move.name))
        @battle.pbShowAbilitySplash(b)
        @battle.pbDisplay(_INTL("But, {1} cannot use {2}!",user.pbThis,move.name))
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
    # "But it failed!" checks, when the move is not a special usage
    if !specialUsage && move.pbMoveFailedNoSpecial?(user,targets)
      PBDebug.log(sprintf("[Move failed] In function code %s's def pbMoveFailedNoSpecial?",move.function))
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
      if user.takesIndirectDamage?
        oldHP = user.hp
        user.pbReduceHP((user.totalhp/4.0).round,false)
        cleanupPreMoveDamage(use,oldHP)
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
	  # Redirect Dragon Darts and similar moves first hit if necessary
    if move.smartSpreadsTargets? && @battle.pbSideSize(targets[0].index) > 1
      targets = pbChangeTargets(move,user,targets,0)
    end
    #---------------------------------------------------------------------------
    magicCoater  = -1
    magicBouncer = -1
    magicShielder = -1
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
          echoln("[DEBUG] #{b.pbThis} enters the unaffected damage state")
          b.damageState.unaffected = true
        end
      end
      # Magic Coat/Magic Bounce/Magic Shield checks (for moves which don't target Pokémon)
      if targets.length==0 && move.canMagicCoat?
        @battle.pbPriority(true).each do |b|
          next if b.fainted? || !b.opposes?(user)
          next if b.semiInvulnerable?
          if b.effects[PBEffects::MagicCoat]
            magicCoater = b.index
            b.effects[PBEffects::MagicCoat] = false
            break
          elsif b.hasActiveAbility?(:MAGICBOUNCE) && !@battle.moldBreaker #&& !b.effects[PBEffects::MagicBounce]
            magicBouncer = b.index
            b.effects[PBEffects::MagicBounce] = true
            break
          elsif b.hasActiveAbility?(:MAGICSHIELD) && !@battle.moldBreaker
            magicShielder = b.index
            @battle.pbShowAbilitySplash(b)
            @battle.pbDisplay(_INTL("{1} shielded its side from the {2}!",b.pbThis,move.name))
            @battle.pbHideAbilitySplash(b)
            user.lastMoveFailed = true
            break
          end
        end
      end
      # Needle Fur
      if targets.length > 0 && move.damagingMove?
        targets.each do |b|
          next if b.damageState.unaffected
          if b.hasActiveAbility?(:NEEDLEFUR)
            @battle.pbShowAbilitySplash(b)
            if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
             @battle.scene.pbDamageAnimation(user)
             upgradedNeedleFur = b.hp < b.totalhp / 2
             reduction = user.totalhp/10
             reduction /= 4 if user.boss?
             reduction *= 2 if upgradedNeedleFur
             oldHP = user.hp
             user.pbReduceHP(reduction,false)
             if !upgradedNeedleFur
               @battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
             else
              @battle.pbDisplay(_INTL("{1}'s fur is standing sharp! {2} is hurt!",b.pbThis,user.pbThis))
             end
             cleanupPreMoveDamage(user,oldHP)
           end
            @battle.pbHideAbilitySplash(b)
          end
        end
      end
      # Get the number of hits
      numHits = move.pbNumHits(user,targets)
      # Record that Parental Bond applies, to weaken the second attack
      user.effects[PBEffects::ParentalBond] = 3 if move.canParentalBond?(user,targets) 
      # Process each hit in turn
      # Skip all hits if the move is being magic coated, magic bounced, or magic shielded
      realNumHits = 0
      moveIsMagicked = magicCoater >= 0 || magicBouncer >= 0 || magicShielder >= 0
      if !moveIsMagicked
        for i in 0...numHits
          success = pbProcessMoveHit(move,user,targets,i,skipAccuracyCheck,numHits > 1)
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
          break if user.asleep?
          # NOTE: If a multi-hit move becomes disabled partway through doing those
          #       hits (e.g. by Cursed Body), the rest of the hits continue as
          #       normal.
          break if !targets.any? { |t| !t.fainted? }   # All targets are fainted
        end
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
      if numHits > 1
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
      # Magic Coat and Magic Bounce's bouncing back (move has no targets)
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
      targets.each { |targetBattler|
        move.pbEffectAfterAllHits(user,targetBattler)
        move.pbEffectOnNumHits(user,targetBattler,realNumHits)
        if targetBattler.effects[PBEffects::EmpoweredDestinyBond]
          next if targetBattler.damageState.unaffected
          next if !user.takesIndirectDamage?
          next if user.hasActiveAbility?(:ROCKHEAD)
          amt = (targetBattler.damageState.totalHPLost/2.0).round
          amt = 1 if amt<1
          @battle.pbDisplay(_INTL("{1}'s destiny is bonded with {2}!",user.pbThis,targetBattler.pbThis(true)))
          user.pbReduceHP(amt,false)
          user.pbItemHPHealCheck
        end
      }
	  
      # Curses about move usage
      @battle.curses.each do |curse_policy|
        @battle.triggerMoveUsedCurseEffect(curse_policy,self,choice[3],move)
      end
      
      if !battle.wildBattle?
        # Triggers dialogue for each target hit
        targets.each do |t|
          next unless t.damageState.totalHPLost > 0
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
      # Don't force the move if the pokemon someone no longer has that move
      moveIndex = -1
      b.eachMoveWithIndex { |m,i|
        if m.id==b.lastMoveUsed
          moveIndex = i
        end
      }
      next if moveIndex < 0
      moveID = b.lastMoveUsed
      usageMessage = _INTL("{1} used the move instructed by {2}!",b.pbThis,user.pbThis(true))
      preTarget = b.lastRegularMoveTarget
      @battle.forceUseMove(b,moveID,preTarget,false,usageMessage,PBEffects::Instructed,false)
    end
    # Dancer
    if !@effects[PBEffects::Dancer] && !user.lastMoveFailed && realNumHits>0 &&
          !move.snatched && magicCoater < 0 && @battle.pbCheckGlobalAbility(:DANCER) && move.danceMove?
      dancers = []
      @battle.pbPriority(true).each do |b|
        dancers.push(b) if b.index!=user.index && b.hasActiveAbility?(:DANCER)
      end
      while dancers.length>0
        nextUser = dancers.pop
        preTarget = choice[3]
        preTarget = user.index if nextUser.opposes?(user) || !nextUser.opposes?(preTarget)
        @battle.forceUseMove(nextUser,move.id,preTarget,true,nil,PBEffects::Dancer,true)
      end
    end
    # Echo
    if !@effects[PBEffects::Echo] && !user.lastMoveFailed && realNumHits>0 &&
          !move.snatched && magicCoater < 0 && @battle.pbCheckGlobalAbility(:ECHO) && move.soundMove?
      echoers = []
      @battle.pbPriority(true).each do |b|
        echoers.push(b) if b.index != user.index && b.hasActiveAbility?(:ECHO)
      end
      while echoers.length>0
        nextUser = echoers.pop
        preTarget = choice[3]
        preTarget = user.index if nextUser.opposes?(user) || !nextUser.opposes?(preTarget)
        @battle.forceUseMove(nextUser,move.id,preTarget,true,nil,PBEffects::Echo,true)
      end
    end
  end
  
  #=============================================================================
  # Attack a single target
  #=============================================================================
  def pbProcessMoveHit(move,user,targets,hitNum,skipAccuracyCheck,multiHit=false)
    return false if user.fainted?
    # For two-turn attacks being used in a single turn
    move.pbInitialEffect(user,targets,hitNum)
    numTargets = 0   # Number of targets that are affected by this hit
    targets.each { |b| b.damageState.resetPerHit }
    # Count a hit for Parental Bond (if it applies)
    user.effects[PBEffects::ParentalBond] -= 1 if user.effects[PBEffects::ParentalBond]>0
    # Redirect Dragon Darts other hits
    if move.smartSpreadsTargets? && @battle.pbSideSize(targets[0].index) > 1 && hitNum > 0
      targets = pbChangeTargets(move,user,targets,1)
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
    move.pbShowAnimation(move.id,user,targets,hitNum) if hitNum == 0
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
      move.pbAnimateHitAndHPLost(user,targets,multiHit)
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
    else
      if !user.poisoned?
        # Secretion Secret
        targets.each do |target|
          next if target.damageState.unaffected
          if target.hasActiveAbility?(:SECRETIONSECRET) && user.opposes?(target)
            battle.pbShowAbilitySplash(target)
            if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
              user.pbPoison(target,nil)
            end
            battle.pbHideAbilitySplash(target)
          end
        end
      end
    end
    @battle.pbJudgeCheckpoint(user,move)
    # Main effect (recoil/drain, etc.)
    targets.each do |b|
      next if b.damageState.unaffected
      move.pbEffectAgainstTarget(user,b)
    end
    move.pbEffectGeneral(user)
	  @battle.eachBattler { |b| b.pbItemFieldEffectCheck} #use this until the field change method applies to all field changes
    targets.each { |b| b.pbFaint if b && b.fainted? }
    user.pbFaint if user.fainted?
    # Additional effect
    if !user.hasActiveAbility?(:SHEERFORCE)
      targets.each do |b|
        next if b.damageState.calcDamage==0
        chance = move.pbAdditionalEffectChance(user,b)
        next if chance <= 0
        if @battle.pbRandom(100) < chance
          if b.hasActiveAbility?(:RUGGEDSCALES)
            @battle.pbShowAbilitySplash(b)
            @battle.pbDisplay(_INTL("The added effect of {1}'s {2} is deflected, harming it!",pbThis(true),move.name))
            user.applyFractionalDamage(1.0/6.0,true)
            @battle.pbHideAbilitySplash(b)
          else
            move.pbAdditionalEffect(user,b)
          end
        end
      end
    end
    # Make the target flinch (because of an item/ability)
    targets.each do |b|
      next if b.fainted?
      next if b.damageState.calcDamage == 0 || b.damageState.substitute
      chance = move.pbFlinchChance(user,b)
      next if chance <= 0
      if @battle.pbRandom(100) < chance
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
      @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",name,b.pbThis(true)))
      b.pbHeldItemTriggered(b.item) if b.item
    end
    targets.each { |b| b.pbFaint if b && b.fainted? }
    user.pbFaint if user.fainted?
    return true
  end
  
  # Called when the usage of various multi-turn moves is disrupted due to
  # failing pbTryUseMove, being ineffective against all targets, or because
  # Pursuit was used specially to intercept a switching foe.
  # Cancels the use of multi-turn moves and counters thereof. Note that Hyper
  # Beam's effect is NOT cancelled.
  def pbCancelMoves(full_cancel = false)
    # # Outragers get confused anyway if they are disrupted during their final
    # # turn of using the move
    # if @effects[PBEffects::Outrage]==1 && pbCanConfuseSelf?(false) && !full_cancel
    #   pbConfuse(_INTL("{1} became confused due to fatigue!",pbThis))
    # end
    # Cancel usage of most multi-turn moves
    @effects[PBEffects::TwoTurnAttack] = nil
    @effects[PBEffects::Rollout]       = 0
    @effects[PBEffects::Outrage]       = 0
    @effects[PBEffects::Uproar]        = 0
    @effects[PBEffects::Bide]          = 0
    @currentMove = nil
    # Reset counters for moves which increase them when used in succession
    @effects[PBEffects::FuryCutter]    = 0
	  @effects[PBEffects::IceBall]   	   = 0
	  @effects[PBEffects::RollOut]       = 0
  end

  #=============================================================================
  # Simple "use move" method, used when a move calls another move and for Future
  # Sight's attack
  #=============================================================================
  def pbUseMoveSimple(moveID,target=-1,idxMove=-1,specialUsage=true)
    choice = []
    choice[0] = :UseMove   # "Use move"
    choice[1] = idxMove    # Index of move to be used in user's moveset
    if idxMove>=0
      choice[2] = @moves[idxMove]
    else
      choice[2] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(moveID))
      choice[2].pp = -1
    end
    choice[3] = target     # Target (-1 means no target yet)
    choice[4] = 0
    PBDebug.log("[Move usage] #{pbThis} started using the called/simple move #{choice[2].name}")
    pbUseMove(choice,specialUsage)
  end
end