ItemHandlers::UseOnPokemon.add(:ABILITYCAPSULE,proc { |item,pkmn,scene|
  abils = pkmn.getAbilityList
  abil1 = nil; abil2 = nil
  for i in abils
    abil1 = i[0] if i[1]==0
    abil2 = i[0] if i[1]==1
  end
  if abil1.nil? || abil2.nil? || pkmn.hasHiddenAbility? || pkmn.isSpecies?(:ZYGARDE)
    scene.pbDisplay(_INTL("It won't have any effect."))
    next false
  end
  newabilindex = (pkmn.ability_index + 1) % 2
  newabil = GameData::Ability.get((newabilindex==0) ? abil1 : abil2)
  newabilname = newabil.name
  if scene.pbConfirm(_INTL("Would you like to change {1}'s Ability to {2}?",
     pkmn.name,newabilname))
    pkmn.ability_index = newabilindex
	pkmn.ability = newabil
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s Ability changed to {2}!",pkmn.name,newabilname))
    next true
  end
  next false
})

class PokeBattle_Battler
	def hasActiveAbility?(check_ability, ignore_fainted = false)
		return false if !abilityActive?(ignore_fainted)
		return check_ability.include?(@ability_id) if check_ability.is_a?(Array)
		return check_ability == self.ability.id
	end
	alias hasWorkingAbility hasActiveAbility?
end

module PokeBattle_BattleCommon
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
    if battler.fainted?
      if itemName.starts_with_vowel?
        pbDisplay(_INTL("{1} threw an {2}!",pbPlayer.name,itemName))
      else
        pbDisplay(_INTL("{1} threw a {2}!",pbPlayer.name,itemName))
      end
      pbDisplay(_INTL("But there was no target..."))
      return
    end
    if itemName.starts_with_vowel?
      pbDisplayBrief(_INTL("{1} threw an {2}!",pbPlayer.name,itemName))
    else
      pbDisplayBrief(_INTL("{1} threw a {2}!",pbPlayer.name,itemName))
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
end

class Pokemon
	def can_relearn_move?
		return false if egg? || shadowPokemon?
		this_level = self.level
		getMoveList.each { |m| return true if m[0] <= this_level && !hasMove?(m[1]) }
		@first_moves.each { |m| return true if !hasMove?(m[1]) }
		return false
	end
end