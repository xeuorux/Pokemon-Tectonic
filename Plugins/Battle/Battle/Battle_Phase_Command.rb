class PokeBattle_Battle
	#=============================================================================
	# Check whether actions can be taken
	#=============================================================================
	def pbCanShowCommands?(idxBattler)
		battler = @battlers[idxBattler]
		return false if !battler || battler.fainted?
		return false if battler.usingMultiTurnAttack?
		return true
	end

	def canChooseAnyMove?(idxBattler)
		battler = @battlers[idxBattler]
		battler.eachMoveWithIndex do |_m,i|
			next if !pbCanChooseMove?(idxBattler,i,false)
			return true
		end
		return false
	end

	#=============================================================================
	# Use sub-menus to choose an action, and register it if is allowed
	#=============================================================================
	# Returns true if a choice was made, false if cancelled.
	def pbFightMenu(idxBattler)
		battler = @battlers[idxBattler]
		if !canChooseAnyMove?(idxBattler)
			if pbDisplayConfirmSerious(_INTL("#{battler.pbThis} cannot use any of its moves, and will Struggle if it fights. Go ahead?"))
				return pbAutoChooseMove(idxBattler)
			else
				return false
			end
		end
		if battler.effectActive?(:Encore)
			encoreMove = battler.moves[battler.pbEncoredMoveIndex]
			if pbDisplayConfirm(_INTL("#{battler.pbThis} must use #{encoreMove.name} if it fights. Go ahead?"))
				return pbAutoChooseMove(idxBattler)
			else
				return false
			end
		end
		# Battle Palace only
		return true if pbAutoFightMenu(idxBattler)
		# Regular move selection
		ret = false
		@scene.pbFightMenu(idxBattler,pbCanMegaEvolve?(idxBattler)) { |cmd|
		case cmd
		when -1   # Cancel
		when -2   # Toggle Mega Evolution
			pbToggleRegisteredMegaEvolution(idxBattler)
			next false
		when -3   # Shift
			pbUnregisterMegaEvolution(idxBattler)
			pbRegisterShift(idxBattler)
			ret = true
		else      # Chose a move to use
			next false if cmd<0 || !@battlers[idxBattler].moves[cmd] ||
								!@battlers[idxBattler].moves[cmd].id
			next false if !pbRegisterMove(idxBattler,cmd)
			next false if !singleBattle? &&
			!pbChooseTarget(@battlers[idxBattler],@battlers[idxBattler].moves[cmd])
			ret = true
		end
		next true
		}
		return ret
	end

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
		
		triggerAllChoicesDialogue()
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

	def triggerAllChoicesDialogue()
		idxBattler = -1
		loop do
			idxBattler += 1
			break if idxBattler >= @battlers.length
			battler = @battlers[idxBattler]
			next if battler.nil?
			triggerBattlerChoiceDialogue(battler,@choices[idxBattler])
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
			if battler.choicesTaken.nil?
				battler.choicesTaken = 1
			else
				battler.choicesTaken += 1
			end

			# Have the AI choose an action
			@battleAI.pbDefaultChooseEnemyCommand(idxBattler)

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
			if cmd>0 && @battlers[idxBattler].effectActive?(:SkyDrop)
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