class PokeBattle_Battler
	def pbRecoverHPFromDrain(amt,target,msg=nil)
		if target.hasActiveAbility?(:LIQUIDOOZE)
		  @battle.pbShowAbilitySplash(target)
		  pbReduceHP(amt)
		  @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",pbThis))
		  @battle.pbHideAbilitySplash(target)
		  pbItemHPHealCheck
		else
		  if canHeal?
			amt = (amt*1.3).floor if hasActiveItem?(:BIGROOT)
			pbRecoverHP(amt)
		  end
		end
	end


	def pbFaint(showMessage=true)
		if !fainted?
		  PBDebug.log("!!!***Can't faint with HP greater than 0")
		  return
		end
		return if @fainted   # Has already fainted properly
		@battle.pbDisplayBrief(_INTL("{1} fainted!",pbThis)) if showMessage
		PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") if !showMessage
		@battle.scene.pbFaintBattler(self)
		
		@pokemon.addToFaintCount()
		lastFoeAttacker.each do |foe|
			@battle.battlers[foe].pokemon.addToKOCount()
		end
		
		# Show dialogue reacting to the fainting
		if @battle.opponent
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
	
  #=============================================================================
  # Change type
  #=============================================================================
  def pbChangeTypes(newType)
    if newType.is_a?(PokeBattle_Battler)
      newTypes = newType.pbTypes
      newTypes.push(:NORMAL) if newTypes.length == 0
      newType3 = newType.effects[PBEffects::Type3]
      newType3 = nil if newTypes.include?(newType3)
      @type1 = newTypes[0]
      @type2 = (newTypes.length == 1) ? newTypes[0] : newTypes[1]
      @effects[PBEffects::Type3] = newType3
    else
      newType = GameData::Type.get(newType).id
      @type1 = newType
      @type2 = newType
      @effects[PBEffects::Type3] = nil
    end
    @effects[PBEffects::BurnUp] 		= false
	@effects[PBEffects::ColdConversion] = false
    @effects[PBEffects::Roost]  		= false
	@battle.scene.pbRefresh()
  end
  
  def pbCheckFormOnWeatherChange
    return if fainted? || @effects[PBEffects::Transform]
    # Castform - Forecast
    if isSpecies?(:CASTFORM)
      if hasActiveAbility?(:FORECAST)
        newForm = 0
        case @battle.pbWeather
        when :Sun, :HarshSun   then newForm = 1
        when :Rain, :HeavyRain then newForm = 2
        when :Hail             then newForm = 3
        end
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
    # Cherrim - Flower Gift
    if isSpecies?(:CHERRIM)
      if hasActiveAbility?(:FLOWERGIFT)
        newForm = 0
        newForm = 1 if [:Sun, :HarshSun].include?(@battle.pbWeather)
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
	# Eiscue - Ice Face
    if @species == :EISCUE && hasActiveAbility?(:ICEFACE) && @battle.pbWeather == :Hail
      if @form==1
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
  end
  
  def pbCheckFormOnTerrainChange
    return if fainted?
    if hasActiveAbility?(:MIMICRY)
      newTypes = self.pbTypes
      originalTypes=[@pokemon.type1,@pokemon.type2] | []
      case @battle.field.terrain
      when :Electric;   newTypes = [:ELECTRIC]
      when :Grassy;     newTypes = [:GRASS]
      when :Misty;      newTypes = [:FAIRY]
      when :Psychic;    newTypes = [:PSYCHIC]
      else;                              newTypes = originalTypes.dup
      end
      if self.pbTypes!=newTypes
        pbChangeTypes(newTypes)
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        if newTypes!=originalTypes
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s type changed to {3}!",pbThis,
             self.abilityName,GameData::Type.get(newTypes[0]).name))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",pbThis,
             self.abilityName,GameData::Type.get(newTypes[0]).name))
          end
        else
          @battle.pbDisplay(_INTL("{1} returned back to normal!",pbThis))
        end
      end
    end
  end
  
    # Checks the Pokémon's form and updates it if necessary. Used for when a
  # Pokémon enters battle (endOfRound=false) and at the end of each round
  # (endOfRound=true).
  def pbCheckForm(endOfRound=false)
    return if fainted? || @effects[PBEffects::Transform]
    # Form changes upon entering battle and when the weather changes
    pbCheckFormOnWeatherChange if !endOfRound
	pbCheckFormOnTerrainChange if !endOfRound
    # Darmanitan - Zen Mode
    if isSpecies?(:DARMANITAN) && self.ability == :ZENMODE
      if @hp<=@totalhp/2
        if @form!=1
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(1,_INTL("{1} triggered!",abilityName))
        end
      elsif @form!=0
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(0,_INTL("{1} triggered!",abilityName))
      end
    end
    # Minior - Shields Down
    if isSpecies?(:MINIOR) && self.ability == :SHIELDSDOWN
      if @hp>@totalhp/2   # Turn into Meteor form
        newForm = (@form>=7) ? @form-7 : @form
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} deactivated!",abilityName))
        elsif !endOfRound
          @battle.pbDisplay(_INTL("{1} deactivated!",abilityName))
        end
      elsif @form<7   # Turn into Core form
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(@form+7,_INTL("{1} activated!",abilityName))
      end
    end
    # Wishiwashi - Schooling
    if isSpecies?(:WISHIWASHI) && self.ability == :SCHOOLING
      if @level>=20 && @hp>@totalhp/4
        if @form!=1
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(1,_INTL("{1} formed a school!",pbThis))
        end
      elsif @form!=0
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(0,_INTL("{1} stopped schooling!",pbThis))
      end
    end
    # Zygarde - Power Construct
    if isSpecies?(:ZYGARDE) && self.ability == :POWERCONSTRUCT && endOfRound
      if @hp<=@totalhp/2 && @form<2   # Turn into Complete Forme
        newForm = @form+2
        @battle.pbDisplay(_INTL("You sense the presence of many!"))
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(newForm,_INTL("{1} transformed into its Complete Forme!",pbThis))
      end
    end
  end
end
