class PokeBattle_Battler
	def pbFaint(showMessage=true)
		if !fainted?
		  PBDebug.log("!!!***Can't faint with HP greater than 0")
		  return
		end
		return if @fainted   # Has already fainted properly
		@battle.pbDisplayBrief(_INTL("{1} fainted!",pbThis)) if showMessage
		PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") if !showMessage
		@battle.scene.pbFaintBattler(self)
		
		# Show dialogue reacting to the fainting
		if pbOwnedByPlayer?
			# Trigger dialogue for each opponent
			@battle.opponent.each_with_index do |trainer,idxTrainer|
				@battle.scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
					PokeBattle_AI.triggerPlayerPokemonFaintedDialogue(policy,self,dialogue)
				}
			end
		else
			# Trigger dialogue for the opponent which owns this
			idxTrainer = @battle.pbGetOwnerIndexFromBattlerIndex(@index)
			@battle.scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
				PokeBattle_AI.triggerTrainerPokemonFaintedDialogue(policy,self,dialogue)
			}
		end
		
		pbInitEffects(false)
		# Reset status
		self.status      = :NONE
		self.statusCount = 0
		# Lose happiness
		if @pokemon && @battle.internalBattle
		  badLoss = false
		  @battle.eachOtherSideBattler(@index) do |b|
			badLoss = true if b.level>=self.level+30
		  end
		  @pokemon.changeHappiness((badLoss) ? "faintbad" : "faint")
		end
		# Reset form
		@battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
		@pokemon.makeUnmega if mega?
		@pokemon.makeUnprimal if primal?
		# Do other things
		@battle.pbClearChoice(@index)   # Reset choice
		pbOwnSide.effects[PBEffects::LastRoundFainted] = @battle.turnCount
		# Check other battlers' abilities that trigger upon a battler fainting
		pbAbilitiesOnFainting
		# Check for end of primordial weather
		@battle.pbEndPrimordialWeather
	end
end
