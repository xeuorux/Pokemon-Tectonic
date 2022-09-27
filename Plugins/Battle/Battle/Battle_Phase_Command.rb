class PokeBattle_Battle
	#=============================================================================
	# Command phase
	#=============================================================================
	def pbCommandPhase
		@scene.pbBeginCommandPhase
		# Reset choices if commands can be shown
		@battlers.each_with_index do |b,i|
		next if !b
		pbClearChoice(i) if pbCanShowCommands?(i)
		end
		# Reset choices to perform Mega Evolution if it wasn't done somehow
		for side in 0...2
			@megaEvolution[side].each_with_index do |megaEvo,i|
				@megaEvolution[side][i] = -1 if megaEvo>=0
			end
		end

		preSelectionAlerts()
		
		# SWAPPED THE ORDER HERE OF PLAYER VS AI
		
		# Choose actions for the round (AI first, then player)
		pbCommandPhaseLoop(false)   # AI chooses their actions
		
		return if @decision!=0   # Battle ended, stop choosing actions
		pbCommandPhaseLoop(true)   # Player chooses their actions
		
		# For each pokemon the player decided to use a move with, trigger the trainer dialogue method
		# for any trainers which can do so
		if @opponent
			idxBattler = -1
			loop do
			idxBattler += 1
			break if idxBattler>=@battlers.length
			next if !@battlers[idxBattler] || !pbOwnedByPlayer?(idxBattler)
			if @choices[idxBattler][0] == :UseMove
					battler = @battlers[idxBattler]
					move = @choices[idxBattler][2]
					target = @choices[idxBattler][3] == -1 ? nil : @battlers[@choices[idxBattler][3]]
					
					# Trigger dialogue for each opponent
					@opponent.each_with_index do |trainer_speaking,idxTrainer|
						@scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
							PokeBattle_AI.triggerPlayerChoseMoveDialogue(policy,battler,move,target,trainer_speaking,dialogue)
						}
					end	
				end
			end
		end
	end

	def preSelectionAlerts()
		# Soul Read alerts
		@battlers.each do |battler|
			next if battler.nil?
			next unless battler.hasActiveAbility?(:SOULREAD)
			battler.eachOpposing do |opponent|
				next if opponent.lastMoveUsedType.nil?
				next if opponent.pbTypes(true).include?(opponent.lastMoveUsedType)
				pbShowAbilitySplash(battler)
				pbDisplay(_INTL("{1} reads {2}'s guilty soul!",battler.pbThis,opponent.pbThis(true)))
				pbHideAbilitySplash(battler)
			end
		end
	end

	def pbExtraCommandPhase()
		@scene.pbBeginCommandPhase
		# Reset choices if commands can be shown
		@battlers.each_with_index do |b,i|
		next if !b
		pbClearChoice(i) if pbCanShowCommands?(i)
		end
		# Reset choices to perform Mega Evolution if it wasn't done somehow
		for side in 0...2
		@megaEvolution[side].each_with_index do |megaEvo,i|
			@megaEvolution[side][i] = -1 if megaEvo>=0
		end
		end
		# Choose actions for the round (AI first, then player)
		pbCommandPhaseLoop(false)   # AI chooses their actions
		return if @decision!=0   # Battle ended, stop choosing actions
		pbCommandPhaseLoop(true)   # Player chooses their actions
	end

	def pbCommandPhaseLoop(isPlayer)
		# NOTE: Doing some things (e.g. running, throwing a Poké Ball) takes up all
		#       your actions in a round.
		actioned = []
		idxBattler = -1
		loop do
		  break if @decision!=0   # Battle ended, stop choosing actions
		  idxBattler += 1
		  break if idxBattler >= @battlers.length
		  battler = @battlers[idxBattler]
		  next if battler.nil?
		  next if pbOwnedByPlayer?(idxBattler) != isPlayer
		  next if @commandPhasesThisRound > battler.extraMovesPerTurn
		  next if @choices[idxBattler][0] != :None    # Action is forced, can't choose one
		  next if !pbCanShowCommands?(idxBattler)   # Action is forced, can't choose one
		  # AI controls this battler
		  if @controlPlayer || !pbOwnedByPlayer?(idxBattler)
			next if @autoTesting
			# Debug testing thing
			@battleAI.beginAutoTester(battler) if $DEBUG && Input.press?(Input::CTRL) && Input.press?(Input::SPECIAL)
		  
			# Increment their choices taken
			if @battlers[idxBattler].choicesTaken.nil?
				@battlers[idxBattler].choicesTaken = 1
			else
				@battlers[idxBattler].choicesTaken += 1
			end

			# Have the AI choose an action
			@battleAI.pbDefaultChooseEnemyCommand(idxBattler)

			# If an AI trainer chose to use a move, trigger dialogue event for that trainer
			if @opponent && @choices[idxBattler][0] == :UseMove
				battler = @battlers[idxBattler]
				move = @choices[idxBattler][2]
				target = @choices[idxBattler][3] == -1 ? nil : @battlers[@choices[idxBattler][3]]
				idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
				trainer_speaking = @opponent[idxTrainer]
				@scene.showTrainerDialogue(idxTrainer) { |policy,dialogue|
					PokeBattle_AI.triggerTrainerChoseMoveDialogue(policy,battler,move,target,trainer_speaking,dialogue)
				}
			end
			# Go to the next battler
			next
		  end
		  
		  # Player chooses an action
		  actioned.push(idxBattler)
		  
		  if @autoTesting
			moveData = GameData::Move::DATA[@autoTestingIndex]
			@autoTestingIndex += 1
			next if moveData.nil?
			moveId = moveData.id
			
			moveObject = PokeBattle_Move.from_pokemon_move(self,Pokemon::Move.new(moveId))
			@battlers[idxBattler].moves[0] = moveObject
		  
			@choices[idxBattler][0] = :UseMove         # "Use move"
			@choices[idxBattler][1] = 0   # Index of move to be used
			@choices[idxBattler][2] = moveObject       # PokeBattle_Move object
			@choices[idxBattler][3] = -1
			
			# Heal all battlers
			@battlers.each do |b|
				b.hp = b.totalhp
				b.pbCureStatus(false)
				b.pbResetStatStages()
				b.pbInitPokemon(b.pokemon,b.index)
			end
			next
		  end
		  
		  commandsEnd = false   # Whether to cancel choosing all other actions this round
		  loop do
			cmd = pbCommandMenu(idxBattler,actioned.length==1)
			# If being Sky Dropped, can't do anything except use a move
			if cmd>0 && @battlers[idxBattler].effects[PBEffects::SkyDrop]>=0
			  pbDisplay(_INTL("Sky Drop won't let {1} go!",@battlers[idxBattler].pbThis(true)))
			  next
			end
			case cmd
			when 0    # Fight
			  break if pbFightMenu(idxBattler)
			when 1    # Dex
				pbGoAfterInfo(@battlers[idxBattler])
			when 2    # Ball
				if trainerBattle?
					pbDisplay(_INTL("You can't catch trainers' Pokemon!"))
					next
				end
				if bossBattle?
					pbDisplay(_INTL("You can't catch Avatars!"))
					next
				end
				if pbItemMenu(idxBattler,actioned.length==1)
					commandsEnd = true if pbItemUsesAllActions?(@choices[idxBattler][1])
					break
			    end
			when 3    # Pokémon
			  break if pbPartyMenu(idxBattler)
			when 4    # Run
				pbBattleInfoMenu
			when 5
			  # NOTE: "Run" is only an available option for the first battler the
			  #       player chooses an action for in a round. Attempting to run
			  #       from battle prevents you from choosing any other actions in
			  #       that round.
			  if pbRunMenu(idxBattler)
				commandsEnd = true
				break
			  end
			when -2   # Debug
			  pbDebugMenu
			  next
			when -1   # Go back to previous battler's action choice
			  next if actioned.length<=1
			  actioned.pop   # Forget this battler was done
			  idxBattler = actioned.last-1
			  pbCancelChoice(idxBattler+1)   # Clear the previous battler's choice
			  actioned.pop   # Forget the previous battler was done
			  break
			end
			pbCancelChoice(idxBattler)
		  end
		  break if commandsEnd
		end
	end
	
	def pbBattleInfoMenu
		@scene.pbBattleInfoMenu
	end
end