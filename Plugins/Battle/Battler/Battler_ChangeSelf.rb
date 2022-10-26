PP_INCREASE_REPEAT_MOVES = false

class PokeBattle_Battler
	#=============================================================================
	# Change HP
	#=============================================================================
	def pbReduceHP(amt, anim = true, registerDamage = true, anyAnim = true)
		amt = amt.round
		amt = @hp if amt > @hp
		amt = 1 if amt < 1 && !fainted?
		oldHP = @hp
		self.hp -= amt
		PBDebug.log("[HP change] #{pbThis} lost #{amt} HP (#{oldHP}=>#{@hp})") if amt.positive?
		raise _INTL('HP less than 0') if @hp.negative?
		raise _INTL('HP greater than total HP') if @hp > @totalhp
		@battle.scene.pbHPChanged(self, oldHP, anim) if anyAnim && amt.positive?
		@tookDamage = true if amt.positive? && registerDamage
		return amt
	end

	# Helper method for performing the two checks that are supposed to occur whenever the battler loses HP
	# From a special effect. E.g. sandstorm DOT, ability triggers
	# Returns whether or not the pokemon faints
	def pbHealthLossChecks(oldHP = -1)
		pbItemHPHealCheck
		if fainted?
			pbFaint
			return true
		elsif oldHP > -1
			pbAbilitiesOnDamageTaken(oldHP)
		end
		return false
	end

	# Helper method for performing the checks that are supposed to occur whenever the battler loses HP
	# From a special effect that occurs when entering the field (i.e. Stealth Rock)
	# Returns whether or not the pokemon was swapped out due to a damage taking ability
	def pbEntryHealthLossChecks(oldHP = -1)
		pbItemHPHealCheck
		if fainted?
			pbFaint
		elsif oldHP > -1
			return pbAbilitiesOnDamageTaken(oldHP)
		end
		return false
	end

	# Applies damage effects that are based on a fraction of the battler's total HP
	# Returns how much damage ended up dealt
	# Accounts for bosses taking reduced fractional damage
	def applyFractionalDamage(fraction, showDamageAnimation = true, basedOnCurrentHP = false, entryCheck = false)
		oldHP = @hp
		fraction /= BOSS_HP_BASED_EFFECT_RESISTANCE if boss?
		fraction *= 2 if @battle.pbCheckOpposingAbility(:AGGRAVATE, @index)
		if basedOnCurrentHP
			reduction = (@hp * fraction).ceil
		else
			reduction = (@totalhp * fraction).ceil
		end
		if showDamageAnimation
			@damageState.displayedDamage = reduction
			@battle.scene.pbDamageAnimation(self) if !@battle.autoTesting
		end
		pbReduceHP(reduction, false)
		if entryCheck
			swapped = pbEntryHealthLossChecks(oldHP)
			return swapped
		else
			pbHealthLossChecks(oldHP)
			return reduction
		end
	end

	def pbRecoverHP(amt, anim = true, anyAnim = true, showMessage = true, customMessage = nil)
		raise _INTL('Told to recover a negative amount') if amt.negative?
		amt *= 1.5 if hasActiveAbility?(:ROOTED)
		amt = amt.round
		amt = @totalhp - @hp if amt > @totalhp - @hp
		amt = 1 if amt < 1 && @hp < @totalhp
		if effectActive?(:NerveBreak)
			@battle.pbDisplay(_INTL("{1}'s healing is reversed because of their broken nerves!", pbThis))
			amt *= -1
		end
		oldHP = @hp
		self.hp += amt
		self.hp = 0 if self.hp.negative?
		PBDebug.log("[HP change] #{pbThis} gained #{amt} HP (#{oldHP}=>#{@hp})") if amt.positive?
		raise _INTL('HP greater than total HP') if @hp > @totalhp
		@battle.scene.pbHPChanged(self, oldHP, anim) if anyAnim && amt.positive?
		if showMessage
			if amt.positive?
				message = customMessage.nil? ? _INTL("{1}'s HP was restored.", pbThis) : customMessage
				@battle.pbDisplay(message)
			elsif amt.negative?
				@battle.pbDisplay(_INTL("{1}'s lost HP.", pbThis))
			end
		end
		return amt
	end

	def pbRecoverHPFromDrain(drainAmount, target, _msg = nil)
		if target.hasActiveAbility?(:LIQUIDOOZE)
			@battle.pbShowAbilitySplash(target)
			oldHP = @hp
			pbReduceHP(drainAmount)
			@battle.pbDisplay(_INTL('{1} sucked up the liquid ooze!', pbThis))
			@battle.pbHideAbilitySplash(target)
			pbItemHPHealCheck
			pbAbilitiesOnDamageTaken(oldHP)
			pbFaint if fainted?
		elsif canHeal?
			drainAmount = (drainAmount * 1.3).floor if hasActiveItem?(:BIGROOT)
			pbRecoverHP(drainAmount, true, true, false)
		end
	end

	def pbRecoverHPFromMultiDrain(targets, ratio)
		totalDamageDealt = 0
		targets.each do |target|
			next if target.damageState.unaffected
			damage = target.damageState.totalHPLost
			if target.hasActiveAbility?(:LIQUIDOOZE)
				@battle.pbShowAbilitySplash(target)
				lossAmount = (damage * ratio).round
				pbReduceHP(lossAmount)
				@battle.pbDisplay(_INTL('{1} sucked up the liquid ooze!', pbThis))
				@battle.pbHideAbilitySplash(target)
				pbItemHPHealCheck
			else
				totalDamageDealt += damage
			end
		end
		return if totalDamageDealt <= 0 || !canHeal?
		@battle.pbShowAbilitySplash(self)
		drainAmount = (totalDamageDealt * ratio).round
		drainAmount = 1 if drainAmount < 1
		drainAmount = (drainAmount * 1.3).floor if hasActiveItem?(:BIGROOT)
		pbRecoverHP(drainAmount, true, true, false)
		@battle.pbHideAbilitySplash(self)
	end

	def pbFaint(showMessage = true)
		unless fainted?
			PBDebug.log("!!!***Can't faint with HP greater than 0")
			return
		end
		return if @fainted # Has already fainted properly
		if showMessage
			if boss?
				if isSpecies?(:PHIONE)
					@battle.pbDisplayBrief(_INTL('{1} was defeated!', pbThis))
				else
					@battle.pbDisplayBrief(_INTL('{1} was destroyed!', pbThis))
				end
			else
				@battle.pbDisplayBrief(_INTL('{1} fainted!', pbThis))
			end
		end
		PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") unless showMessage
		@battle.scene.pbFaintBattler(self)

		@pokemon.addToFaintCount
		lastFoeAttacker.each do |foe|
			@battle.battlers[foe].pokemon.addToKOCount
		end

		# Trigger battler faint curses
		@battle.curses.each do |curse_policy|
			@battle.triggerBattlerFaintedCurseEffect(curse_policy, self, @battle)
		end

		@battle.triggerBattlerFaintedDialogue(self)

		if effectActive?(:GivingDragonRideTo)
			otherBattler = @battle.battlers[@effects[:GivingDragonRideTo]]
			damageDealt = otherBattler.hp
			otherBattler.damageState.displayedDamage = damageDealt
			@battle.scene.pbDamageAnimation(otherBattler)
			otherBattler.pbReduceHP(damageDealt, false)
			@battle.pbDisplay(_INTL('{1} fell to the ground!', otherBattler.pbThis))
			otherBattler.pbFaint
		end

		pbInitEffects(false)
		
		# Reset status
		self.status      = :NONE
		self.statusCount = 0
		@bossStatus = :NONE
		# Lose happiness
		if @pokemon && @battle.internalBattle
			badLoss = false
			@battle.eachOtherSideBattler(@index) do |b|
				badLoss = true if b.level >= level + 30
			end
			@pokemon.changeHappiness(badLoss ? 'faintbad' : 'faint')
		end
		# Reset form
		@battle.peer.pbOnLeavingBattle(@battle, @pokemon,
																																	@battle.usedInBattle[idxOwnSide][@index / 2])
		@pokemon.makeUnmega if mega?
		@pokemon.makeUnprimal if primal?
		# Do other things
		@battle.pbClearChoice(@index) # Reset choice
		pbOwnSide.effects[:LastRoundFainted] = @battle.turnCount
		# Check other battlers' abilities that trigger upon a battler fainting
		pbAbilitiesOnFainting
		# Check for end of primordial weather
		@battle.pbEndPrimordialWeather
	end

	#=============================================================================
	# Move PP
	#=============================================================================
	def pbSetPP(move, pp)
		move.pp = pp
		# Mimic
		move.realMove.pp = pp if move.realMove && move.id == move.realMove.id && !@effects[:Transform]
	end

	def pbReducePP(move)
		return true if usingMultiTurnAttack?
		return true if move.pp.negative? # Don't reduce PP for special calls of moves
		return true if move.total_pp <= 0 # Infinite PP, can always be used
		return false if move.pp.zero? # Ran out of PP, couldn't reduce
		reductionAmount = 1
		if PP_INCREASE_REPEAT_MOVES
			reductionAmount = 3 if !boss? && @lastMoveUsed && @lastMoveUsed == move.id && !@lastMoveFailed
		end
		newPPAmount = [move.pp - reductionAmount, 0].max
		pbSetPP(move, newPPAmount)
		return true
	end

	def pbReducePPOther(move)
		pbSetPP(move, move.pp - 1) if move.pp.positive?
	end

	#=============================================================================
	# Change type
	#=============================================================================
	def pbChangeTypes(newType)
		if newType.is_a?(PokeBattle_Battler)
			typeCopyTarget = newType
			newTypes = typeCopyTarget.pbTypes
			newTypes.push(:NORMAL) if newTypes.length.zero?
			newType3 = typeCopyTarget.effects[:Type3]
			newType3 = nil if newTypes.include?(newType3)
			@type1 = newTypes[0]
			@type2 = (newTypes.length == 1) ? newTypes[0] : newTypes[1]
			if newType3
				applyEffect(:Type3,newType3)
			else
				disableEffect(:Type3)
			end
		else
			newType = GameData::Type.get(newType).id
			@type1 = newType
			@type2 = newType
			disableEffect(:Type3)
		end
		disableEffect(:BurnUp)
		disableEffect(:ColdConversion)
		disableEffect(:Roost)
		@battle.scene.pbRefresh
	end

	#=============================================================================
	# Forms
	#=============================================================================
	def pbChangeForm(newForm, msg)
		return if fainted? || effectActive?(:Transform) || @form == newForm
		oldForm = @form
		oldDmg = @totalhp - @hp
		self.form = newForm
		pbUpdate(true)
		@hp = @totalhp - oldDmg
		disableEffect(:WeightChange)
		@battle.scene.pbChangePokemon(self, @pokemon)
		@battle.scene.pbRefreshOne(@index)
		@battle.pbDisplay(msg) if msg && msg != ''
		PBDebug.log("[Form changed] #{pbThis} changed from form #{oldForm} to form #{newForm}")
		@battle.pbSetSeen(self)
	end

	def pbCheckFormOnStatusChange
		return if fainted? || effectActive?(:Transform)
	end

	def pbCheckFormOnMovesetChange
		return if fainted? || effectActive?(:Transform)
		# Keldeo - knowing Secret Sword
		if isSpecies?(:KELDEO)
			newForm = 0
			newForm = 1 if pbHasMove?(:SECRETSWORD)
			pbChangeForm(newForm, _INTL('{1} transformed!', pbThis))
		end
	end

	def pbCheckFormOnWeatherChange
		return if fainted? || effectActive?(:Transform)
		# Castform - Forecast
		if isSpecies?(:CASTFORM)
			if hasActiveAbility?(:FORECAST)
				newForm = 0
				case @battle.pbWeather
				when :Sun, :HarshSun   then newForm = 1
				when :Rain, :HeavyRain then newForm = 2
				when :Hail             then newForm = 3
				end
				if @form != newForm
					@battle.pbShowAbilitySplash(self, true)
					@battle.pbHideAbilitySplash(self)
					pbChangeForm(newForm, _INTL('{1} transformed!', pbThis))
				end
			else
				pbChangeForm(0, _INTL('{1} transformed!', pbThis))
			end
		end
		# Cherrim - Flower Gift
		if isSpecies?(:CHERRIM)
			if hasActiveAbility?(:FLOWERGIFT)
				newForm = 0
				newForm = 1 if %i[Sun HarshSun].include?(@battle.pbWeather)
				if @form != newForm
					@battle.pbShowAbilitySplash(self, true)
					@battle.pbHideAbilitySplash(self)
					pbChangeForm(newForm, _INTL('{1} transformed!', pbThis))
				end
			else
				pbChangeForm(0, _INTL('{1} transformed!', pbThis))
			end
		end
		# Eiscue - Ice Face
		if @species == :EISCUE && hasActiveAbility?(:ICEFACE) && @battle.pbWeather == :Hail && (@form == 1)
			@battle.pbShowAbilitySplash(self, true)
			@battle.pbHideAbilitySplash(self)
			pbChangeForm(0, _INTL('{1} transformed!', pbThis))
		end
	end

	def pbCheckFormOnTerrainChange
		return if fainted?
		if hasActiveAbility?(:MIMICRY)
			newTypes = pbTypes
			originalTypes = [@pokemon.type1, @pokemon.type2] | []
			case @battle.field.terrain
			when :Electric then   newTypes = [:ELECTRIC]
			when :Grassy then     newTypes = [:GRASS]
			when :Misty then      newTypes = [:FAIRY]
			when :Psychic then    newTypes = [:PSYCHIC]
			else; newTypes = originalTypes.dup
			end
			if pbTypes != newTypes
				pbChangeTypes(newTypes)
				@battle.pbShowAbilitySplash(self, true)
				@battle.pbHideAbilitySplash(self)
				if newTypes == originalTypes
					@battle.pbDisplay(_INTL('{1} returned back to normal!', pbThis))
				else
					typeName = GameData::Type.get(newTypes[0]).name
					@battle.pbDisplay(_INTL("{1}'s type changed to {3}!", pbThis, abilityName, typeName))
				end
			end
		end
	end

	# Checks the Pokémon's form and updates it if necessary. Used for when a
	# Pokémon enters battle (endOfRound=false) and at the end of each round
	# (endOfRound=true).
	def pbCheckForm(endOfRound = false)
		return if fainted? || effectActive?(:Transform)
		# Form changes upon entering battle and when the weather changes
		pbCheckFormOnWeatherChange unless endOfRound
		pbCheckFormOnTerrainChange unless endOfRound
		# Darmanitan - Zen Mode
		if isSpecies?(:DARMANITAN) && ability == :ZENMODE
			if @hp <= @totalhp / 2
				if @form != 1
					@battle.pbShowAbilitySplash(self, true)
					@battle.pbHideAbilitySplash(self)
					pbChangeForm(1, _INTL('{1} triggered!', abilityName))
				end
			elsif @form != 0
				@battle.pbShowAbilitySplash(self, true)
				@battle.pbHideAbilitySplash(self)
				pbChangeForm(0, _INTL('{1} triggered!', abilityName))
			end
		end
		# Minior - Shields Down
		if isSpecies?(:MINIOR) && ability == :SHIELDSDOWN
			if @hp > @totalhp / 2 # Turn into Meteor form
				newForm = (@form >= 7) ? @form - 7 : @form
				if @form != newForm
					@battle.pbShowAbilitySplash(self, true)
					@battle.pbHideAbilitySplash(self)
					pbChangeForm(newForm, _INTL('{1} deactivated!', abilityName))
				elsif !endOfRound
					@battle.pbDisplay(_INTL('{1} deactivated!', abilityName))
				end
			elsif @form < 7 # Turn into Core form
				@battle.pbShowAbilitySplash(self, true)
				@battle.pbHideAbilitySplash(self)
				pbChangeForm(@form + 7, _INTL('{1} activated!', abilityName))
			end
		end
		# Wishiwashi - Schooling
		if isSpecies?(:WISHIWASHI) && ability == :SCHOOLING
			if @level >= 20 && @hp > @totalhp / 4
				if @form != 1
					@battle.pbShowAbilitySplash(self, true)
					@battle.pbHideAbilitySplash(self)
					pbChangeForm(1, _INTL('{1} formed a school!', pbThis))
				end
			elsif @form != 0
				@battle.pbShowAbilitySplash(self, true)
				@battle.pbHideAbilitySplash(self)
				pbChangeForm(0, _INTL('{1} stopped schooling!', pbThis))
			end
		end
		# Zygarde - Power Construct
		if isSpecies?(:ZYGARDE) && ability == :POWERCONSTRUCT && endOfRound && (@hp <= @totalhp / 2 && @form < 2)   # Turn into Complete Forme
			newForm = @form + 2
			@battle.pbDisplay(_INTL('You sense the presence of many!'))
			@battle.pbShowAbilitySplash(self, true)
			@battle.pbHideAbilitySplash(self)
			pbChangeForm(newForm, _INTL('{1} transformed into its Complete Forme!', pbThis))
		end
	end

	def pbTransform(target)
		oldAbil = @ability_id
		applyEffect(:Transform)
		applyEffect(:TransformSpecies,target.species)
		pbChangeTypes(target)
		self.ability = target.ability
		@attack = target.attack
		@defense = target.defense
		@spatk = target.spatk
		@spdef = target.spdef
		@speed = target.speed
		GameData::Stat.each_battle { |s| @stages[s.id] = target.stages[s.id] }
		# Copy critical hit chance raising effects
		target.eachEffect do |effect, value, data|
			@effects[effect] = value if data.critical_rate_buff?
		end
		@moves.clear
		target.moves.each_with_index do |m, i|
			@moves[i] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(m.id))
			@moves[i].pp = 5
			@moves[i].total_pp = 5
		end
		disableEffect(:Disable)
		@effects[:WeightChange] = target.effects[:WeightChange]
		@battle.scene.pbRefreshOne(@index)
		@battle.pbDisplay(_INTL('{1} transformed into {2}!', pbThis, target.pbThis(true)))
		pbOnAbilityChanged(oldAbil)
	end

	def pbHyperMode; end
end
