class PokeBattle_Battle
  #=============================================================================
  # Store caught Pokémon
  #=============================================================================
  def pbStorePokemon(pkmn)
    # Store the Pokémon
    currentBox = @peer.pbCurrentBox
    storedBox  = @peer.pbStorePokemon(pbPlayer,pkmn)
    if storedBox < 0
      pbDisplayPaused(_INTL("{1} has been added to your party.",pkmn.name))
      @initialItems[0][pbPlayer.party.length-1] = pkmn.item_id if @initialItems
      return
    end
    # Messages saying the Pokémon was stored in a PC box
    curBoxName = @peer.pbBoxName(currentBox)
    boxName    = @peer.pbBoxName(storedBox)
    if storedBox != currentBox
      pbDisplayPaused(_INTL("Box \"{1}\" on the Pokémon Storage PC was full.",curBoxName))
      pbDisplayPaused(_INTL("{1} was transferred to box \"{2}\".",pkmn.name,boxName))
    else
      pbDisplayPaused(_INTL("{1} was transferred to the Pokémon Storage PC.",pkmn.name))
      pbDisplayPaused(_INTL("It was stored in box \"{1}\".",boxName))
    end
  end
  
  # Register all caught Pokémon in the Pokédex, and store them.
  def pbRecordAndStoreCaughtPokemon
    @caughtPokemon.each do |pkmn|
      pbPlayer.pokedex.register(pkmn)   # In case the form changed upon leaving battle
	  
	    #Let the player know info about the individual pokemon they caught
      pbDisplayPaused(_INTL("You check {1}, and discover that its ability is {2}!",pkmn.name,pkmn.ability.name))
      
      if (pkmn.hasItem?)
        pbDisplayPaused(_INTL("The {1} is holding an {2}!",pkmn.name,pkmn.item.name))
      end
	  
      # Record the Pokémon's species as owned in the Pokédex
      if !pbPlayer.owned?(pkmn.species)
        pbPlayer.pokedex.set_owned(pkmn.species)
        if $Trainer.has_pokedex
          pbDisplayPaused(_INTL("You register {1} as caught in the Pokédex.",pkmn.name))
          pbPlayer.pokedex.register_last_seen(pkmn)
          @scene.pbShowPokedex(pkmn.species)
        end
      end
      # Record a Shadow Pokémon's species as having been caught
      pbPlayer.pokedex.set_shadow_pokemon_owned(pkmn.species) if pkmn.shadowPokemon?
	  
	    # Increase the caught count for the global metadata
	    incrementDexNavCounts(true)

        # Nickname the Pokémon (unless it's a Shadow Pokémon)
      if !pkmn.shadowPokemon? && (!defined?($PokemonSystem.nicknaming_prompt) || $PokemonSystem.nicknaming_prompt == 0)
        if pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?", pkmn.name))
          nickname = @scene.pbNameEntry(_INTL("{1}'s nickname?", pkmn.speciesName), pkmn)
          pkmn.name = nickname
        end
      end

	    #Check Party Size
      if $Trainer.party_full?
        #Y/N option to store newly caught
        if pbDisplayConfirmSerious(_INTL("Would you like to add {1} to your party?", pkmn.name))
          pbDisplay(_INTL("Choose which Pokemon will be sent back to the PC."))
		      #if Y, select pokemon to store instead
          pbChoosePokemon(1,3)
		      chosen = $game_variables[1]
          #Didn't cancel
          if chosen != -1
            chosenPokemon = $Trainer.party[chosen]
            @peer.pbOnLeavingBattle(self,chosenPokemon,@usedInBattle[0][chosen],true)   # Reset form
        
            # Find the battler which matches with the chosen pokemon	
            chosenBattler = nil
            eachSameSideBattler() do |battler|
              next unless battler.pokemon == chosenPokemon
              chosenBattler = battler
              break
            end
            # Handle the chosen pokemon leaving battle, if it was in battle
            if !chosenBattler.nil? && chosenBattler.abilityActive?
              BattleHandlers.triggerAbilityOnSwitchOut(chosenBattler.ability,chosenBattler,true)
            end
            
            chosenPokemon.item = @initialItems[0][chosen]
            @initialItems[0][chosen] = pkmn.item
            
            if chosenPokemon.hasItem?
              itemName = GameData::Item.get(chosenPokemon.item).real_name
              if pbConfirmMessageSerious(_INTL("{1} is holding an {2}. Would you like to take it before transferring?", chosenPokemon.name, itemName))
                pbTakeItemFromPokemon(chosenPokemon)
              end
            end
            
            pbStorePokemon(chosenPokemon)
            $Trainer.party[chosen] = pkmn
          else
            # Store caught Pokémon if cancelled
            pbStorePokemon(pkmn)
          end
        else
          # Store caught Pokémon
          pbStorePokemon(pkmn)
        end
	    else
        # Store caught Pokémon
        pbStorePokemon(pkmn)
      end
    end
    @caughtPokemon.clear
  end

  #=============================================================================
  # Throw a Poké Ball
  #=============================================================================
  def pbThrowPokeBall(idxBattler,ball,catch_rate=nil,showPlayer=false)
    # Determine which Pokémon you're throwing the Poké Ball at
    battler = nil
    if opposes?(idxBattler)
      battler = @battlers[idxBattler]
    else
      battler = @battlers[idxBattler].pbDirectOpposing(true)
    end
    if battler.fainted?
      battler.eachAlly do |b|
        battler = b
        break
      end
    end
    # Messages
    itemName = GameData::Item.get(ball).name
    if ball == :BALLLAUNCHER
      pbDisplayBrief(_INTL("{1} used the {2}!",pbPlayer.name,itemName))
    elsif itemName.starts_with_vowel?
      pbDisplayBrief(_INTL("{1} threw an {2}!",pbPlayer.name,itemName))
    else
      pbDisplayBrief(_INTL("{1} threw a {2}!",pbPlayer.name,itemName))
    end
    if battler.fainted?
      pbDisplay(_INTL("But there was no target..."))
      return
    end
    # Animation of opposing trainer blocking Poké Balls (unless it's a Snag Ball
    # at a Shadow Pokémon)
    if trainerBattle? && !(GameData::Item.get(ball).is_snag_ball? && battler.shadowPokemon?)
      @scene.pbThrowAndDeflect(ball,1)
      pbDisplay(_INTL("The Trainer blocked your Poké Ball! Don't be a thief!"))
      return
    end
    # Calculate the number of shakes (4=capture)
    pkmn = battler.pokemon
    @criticalCapture = false
    numShakes = pbCaptureCalc(pkmn,battler,catch_rate,ball)
    #PBDebug.log("[Threw Poké Ball] #{itemName}, #{numShakes} shakes (4=capture)")
    # Animation of Ball throw, absorb, shake and capture/burst out
    @scene.pbThrow(ball,numShakes,@criticalCapture,battler.index,showPlayer)
    # Outcome message
    case numShakes
    when 0
      pbDisplay(_INTL("Oh no! The Pokémon broke free!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 1
      pbDisplay(_INTL("Aww! It appeared to be caught!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 2
      pbDisplay(_INTL("Aargh! Almost had it!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 3
      pbDisplay(_INTL("Gah! It was so close, too!"))
      BallHandlers.onFailCatch(ball,self,battler)
    when 4
      pbDisplayBrief(_INTL("Gotcha! {1} was caught!",pkmn.name))
      @scene.pbThrowSuccess   # Play capture success jingle
      pbRemoveFromParty(battler.index,battler.pokemonIndex)
      # Gain Exp
      if Settings::GAIN_EXP_FOR_CAPTURE
        battler.captured = true
        pbGainExp
        battler.captured = false
      end
      battler.pbReset
      if pbAllFainted?(battler.index)
        @decision = (trainerBattle?) ? 1 : 4   # Battle ended by win/capture
      end
      # Modify the Pokémon's properties because of the capture
      if GameData::Item.get(ball).is_snag_ball?
        pkmn.owner = Pokemon::Owner.new_from_trainer(pbPlayer)
      end
      BallHandlers.onCatch(ball,self,pkmn)
      pkmn.poke_ball = ball
      pkmn.makeUnmega if pkmn.mega?
      pkmn.makeUnprimal
      pkmn.update_shadow_moves if pkmn.shadowPokemon?
      pkmn.record_first_moves
      # Reset form
      pkmn.forced_form = nil if MultipleForms.hasFunction?(pkmn.species,"getForm")
      @peer.pbOnLeavingBattle(self,pkmn,true,true)
      # Make the Poké Ball and data box disappear
      @scene.pbHideCaptureBall(idxBattler)
      # Save the Pokémon for storage at the end of battle
      @caughtPokemon.push(pkmn)
    end
  end

  def pbCheckNeutralizingGas(battler=nil)
    # Battler = the battler to switch out. 
	  # Should be specified when called from pbAttackPhaseSwitch
	  # Should be nil when called from pbEndOfRoundPhase
    return if !@field.effects[PBEffects::NeutralizingGas]
    return if battler && (battler.ability != :NEUTRALIZINGGAS || 
		battler.effects[PBEffects::GastroAcid])
    hasabil=false
    eachBattler {|b|
      next if !b || b.fainted?
	  next if battler && b.index == battler.index 
	  # if specified, the battler will switch out, so don't consider it.
      # neutralizing gas can be blocked with gastro acid, ending the effect.
      if b.ability == :NEUTRALIZINGGAS && !b.effects[PBEffects::GastroAcid]
        hasabil=true; break
      end
    }
    if !hasabil
      @field.effects[PBEffects::NeutralizingGas] = false
      pbPriority(true).each { |b| 
	    next if battler && b.index == battler.index
	    b.pbEffectsOnSwitchIn
	  }
    end
  end 

  #=============================================================================
  # Calculate how many shakes a thrown Poké Ball will make (4 = capture)
  #=============================================================================
  CATCH_BASE_CHANCE = 65536

  def pbCaptureCalc(pkmn,battler,catch_rate,ball)
    return 4 if $DEBUG && Input.press?(Input::CTRL)
    return 4 if BallHandlers.isUnconditional?(ball,self,battler)
    y = captureThresholdCalc(pkmn,battler,catch_rate,ball)
    # Critical capture check
    if Settings::ENABLE_CRITICAL_CAPTURES
      c = 0
      numOwned = $Trainer.pokedex.owned_count
      if numOwned>600;    c = 20
      elsif numOwned>450; c = 16
      elsif numOwned>300; c = 12
      elsif numOwned>150; c = 8
      elsif numOwned>50;  c = 4
      end
      # Calculate the number of shakes
      if c>0 && pbRandom(100)<c
        if pbRandom(CATCH_BASE_CHANCE)<y
          @criticalCapture = true
          return 4
        end
      end
    end
    # Calculate the number of shakes
    numShakes = 0
    for i in 0...4
      break if numShakes<i
      numShakes += 1 if pbRandom(CATCH_BASE_CHANCE)<y
    end
    return numShakes
  end
  
  def captureThresholdCalc(pkmn,battler,catch_rate,ball)
	# Get a catch rate if one wasn't provided
    catch_rate = pkmn.species_data.catch_rate if !catch_rate
    ultraBeast = [:NIHILEGO, :BUZZWOLE, :PHEROMOSA, :XURKITREE, :CELESTEELA,
                  :KARTANA, :GUZZLORD, :POIPOLE, :NAGANADEL, :STAKATAKA,
                  :BLACEPHALON].include?(pkmn.species)
	  if !ultraBeast || ball == :BEASTBALL
      catch_rate = BallHandlers.modifyCatchRate(ball,catch_rate,self,battler,ultraBeast)
    else
		# All balls but the beast ball have a 1/10 chance to catch Ultra Beasts
      catch_rate /= 10
    end
    return captureThresholdCalcInternals(battler.status,battler.hp,battler.totalhp,catch_rate)
  end
  
  def captureChanceCalc(pkmn,battler,catch_rate,ball)
    return 1 if BallHandlers.isUnconditional?(ball,self,battler)
    y = captureThresholdCalc(pkmn,battler,catch_rate,ball)
    chancePerShake = y.to_f/CATCH_BASE_CHANCE.to_f
    overallChance = chancePerShake ** 4
    return overallChance
  end
  
  def self.captureThresholdCalcInternals(status,current_hp,total_hp,catch_rate)
    # First half of the shakes calculation
    x = (((5 * total_hp) - (4 * current_hp)) * catch_rate.to_f)/(5 * total_hp) * 1.2
	
    # Calculation modifiers
    if status == :SLEEP
      x *= 2.5
    elsif status != :NONE
      x *= 1.5
    end
    x = x.floor
    x = 1 if x<1
	
    # Second half of the shakes calculation
    y = ( CATCH_BASE_CHANCE / ((255.0/x) ** 0.1875) ).floor
    return y
  end
end

