HIGHEST_STAT_BASE = Color.new(139,52,34)
LOWEST_STAT_BASE = Color.new(60,55,112)
TRIBAL_BOOSTED_BASE = Color.new(70, 130, 76)

DEBUGGING_EFFECT_DISPLAY = false

class BattleInfoDisplay < SpriteWrapper
	attr_accessor   :battle
	attr_accessor   :selected
	attr_accessor	:individual
	
  def initialize(viewport,z,battle)
	super(viewport)
    self.x = 0
    self.y = 0
	self.battle = battle
	
	@sprites      			= {}
    @spriteX      			= 0
    @spriteY      			= 0
	@selected	  			= 0
	@individual   			= nil
	@field					= false
	@battleInfoMain			= AnimatedBitmap.new("Graphics/Pictures/Battle/BattleButtonRework/battle_info_main")
	@battleInfoIndividual	= AnimatedBitmap.new("Graphics/Pictures/Battle/BattleButtonRework/battle_info_individual")
	@backgroundBitmap  		= @battleInfoMain
	@statusCursorBitmap  	= AnimatedBitmap.new("Graphics/Pictures/Battle/BattleButtonRework/cursor_status")
	
	@contents = BitmapWrapper.new(@backgroundBitmap.width,@backgroundBitmap.height)
    self.bitmap  = @contents
	pbSetNarrowFont(self.bitmap)
	
	@battlerScrollingValue = 0
	@fieldScrollingValue = 0
	
	self.z = z
    refresh
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    @battleInfoMain.dispose
	@battleInfoIndividual.dispose
    super
  end
  
  def visible=(value)
    super
    for i in @sprites
      i[1].visible = value if !i[1].disposed?
    end
  end
  
  def refresh
    self.bitmap.clear
	
	if @individual
		@backgroundBitmap  		= @battleInfoIndividual
		self.bitmap.blt(0,0,@backgroundBitmap.bitmap,Rect.new(0,0,@backgroundBitmap.width,@backgroundBitmap.height))
		drawIndividualBattlerInfo(@individual)
	else
		@backgroundBitmap  		= @battleInfoMain
		self.bitmap.blt(0,0,@backgroundBitmap.bitmap,Rect.new(0,0,@backgroundBitmap.width,@backgroundBitmap.height))
		drawWholeBattleInfo()
	end
  end
  
  def drawWholeBattleInfo()
	base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
	textToDraw = []
	
	# Draw the
	battlerNameX = 24
	battlerCursorX = 160
	yPos = 8
	battlerIndex = 0

	# Entries for allies
	@battle.eachSameSideBattler do |b|
		next if !b
		textToDraw.push([b.name,battlerNameX,yPos + 4,0,base,shadow])
		cursorX = @selected == battlerIndex ? @statusCursorBitmap.width/2 : 0
		self.bitmap.blt(battlerCursorX,yPos,@statusCursorBitmap.bitmap,Rect.new(cursorX,0,@statusCursorBitmap.width/2,@statusCursorBitmap.height))
		yPos += 52
		battlerIndex += 1
	end

	# Entries for enemies
	yPos = 180
	@battle.eachOtherSideBattler do |b|
		next if !b
		textToDraw.push([b.name,battlerNameX,yPos + 4,0,base,shadow])
		cursorX = @selected == battlerIndex ? @statusCursorBitmap.width/2 : 0
		self.bitmap.blt(battlerCursorX,yPos,@statusCursorBitmap.bitmap,Rect.new(cursorX,0,@statusCursorBitmap.width/2,@statusCursorBitmap.height))
		yPos += 52
		battlerIndex += 1
	end
	
	weatherAndTerrainY = 336
	weatherMessage = "No Weather"
	if @battle.field.weather != :None
		weatherName = GameData::BattleWeather.get(@battle.field.weather).real_name
		weatherDuration = @battle.field.weatherDuration
		weatherDuration = "Infinite" if weatherDuration < 0
		weatherMessage = _INTL("{1} ({2})",weatherName,weatherDuration)
	end
	
	textToDraw.push([weatherMessage,24,weatherAndTerrainY,0,base,shadow])

	terrainMessage = "No Terrain"
	if @battle.field.terrain != :None
		terrainName = GameData::BattleTerrain.get(@battle.field.terrain).real_name
		terrainDuration = @battle.field.terrainDuration
		terrainDuration = "Inf." if terrainDuration < 0
		terrainMessage = _INTL("{1} Terrain ({2})",terrainName, terrainDuration)
	end
	textToDraw.push([terrainMessage,256+24,weatherAndTerrainY,0,base,shadow])
	
	# Whole field effects
	wholeFieldX = 328
	textToDraw.push([_INTL("Field Effects"),wholeFieldX+60,0,2,base,shadow])
	
	# Compile array of descriptors of each field effect
	fieldEffects = []
	pushEffectDescriptorsToArray(@battle.field,fieldEffects)
	@battle.sides.each do |side|
		thisSideEffects = []
		pushEffectDescriptorsToArray(side,thisSideEffects)
		if side.index == 1
			thisSideEffects.map { |descriptor|
				"#{descriptor} [O]"
			}
		end
		fieldEffects.concat(thisSideEffects)
	end
	
	# Render out the field effects
	scrollingBoundYMin = 36
	scrollingBoundYMax = 300
	if fieldEffects.length != 0
		scrolling = true if fieldEffects.length > 8
		index = 0
		repeats = scrolling ? 2 : 1
		for repeat in 0...repeats
			fieldEffects.each do |effectName|
				index += 1
				calcedY = 60 + 32 * index
				if scrolling
					calcedY -= @fieldScrollingValue
					calcedY += 8
				end
				next if calcedY < scrollingBoundYMin || calcedY > scrollingBoundYMax
				distanceFromFade = [calcedY - scrollingBoundYMin,scrollingBoundYMax - calcedY].min
				textAlpha = scrolling ? ([distanceFromFade / 20.0,1.0].min * 255).floor : 255
				textBase = Color.new(base.red,base.blue,base.green,textAlpha)
				textShadow = Color.new(shadow.red,shadow.blue,shadow.green,textAlpha)
				textToDraw.push([effectName,wholeFieldX,calcedY,0,textBase,textShadow])
			end
		end
	else
		textToDraw.push(["None",wholeFieldX,44,0,base,shadow])
	end
	
	# Reset the scrolling once its scrolled through the entire list once
	@fieldScrollingValue = 0 if @fieldScrollingValue > fieldEffects.length * 32

	pbDrawTextPositions(self.bitmap,textToDraw)
  end
  
  def drawIndividualBattlerInfo(battler)
	base   = Color.new(88,88,80)
	bossBase = Color.new(50,115,50)
    shadow = Color.new(168,184,184)
	textToDraw = []
	
	battlerName = battler.name
	if battler.pokemon.nicknamed?
		speciesData = GameData::Species.get(battler.species)
		battlerName += " (#{speciesData.real_name})"
		battlerName += " [#{speciesData.real_form_name}]" if speciesData.form != 0
	end
	textToDraw.push([battlerName,256,0,2,base,shadow])
	
	stageMulMainStat = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
	stageDivMainStat = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
	
	stageMulBattleStat = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDivBattleStat = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
	
	# Stat Stages
	statStagesSectionTopY = 52
	statLabelX = 20
	statStageX = 116
	statMultX = 172
	statValueX = 232
	battlerEffectsX = 308
	textToDraw.push(["Stat",statLabelX,statStagesSectionTopY,0,base,shadow])
	textToDraw.push(["Stage",statStageX-16,statStagesSectionTopY,0,base,shadow])
	textToDraw.push(["Mult",statMultX,statStagesSectionTopY,0,base,shadow])
	textToDraw.push(["Value",statValueX,statStagesSectionTopY,0,base,shadow])
	
	statsToNames = {
		:ATTACK => "Atk",
		:DEFENSE => "Def",
		:SPECIAL_ATTACK => "Sp. Atk",
		:SPECIAL_DEFENSE => "Sp. Def",
		:SPEED => "Speed",
		:ACCURACY => "Acc",
		:EVASION => "Evade"
	}

	tribalBonus = TribalBonus.new
	pokemonTribalBonus = tribalBonus.getTribeBonuses(battler.pokemon)

	# Hash containing info about each stat
	# Each key is a symbol of a stat
	# Each value is an array of [statName, statStage, statMult, statFinalValue]
	calculatedStatInfo = {}
	
	# Display the info about each stat
	statValues = battler.plainStats
	highestStat = nil
	highestStatValue = -65536 # I chose these caps somewhat arbitrarily
	lowestStat = nil
	lowestStatValue = 65536
	statsToNames.each do |stat,name|
		statValuesArray = []
		
		statData = GameData::Stat.get(stat)
		statValuesArray.push(name)
		
		# Stat stage
		stage = battler.stages[stat]
		if stage != 0 && battler.boss?
			stage = (stage/2.0).round(1)
		end
		statValuesArray.push(stage)

		#Percentages
		stageMul = statData.type == :battle ? stageMulBattleStat : stageMulMainStat
		stageDiv = statData.type == :battle ? stageDivBattleStat : stageDivMainStat
		adjustedStage = stage + 6
		mult = stageMul[adjustedStage].to_f/stageDiv[adjustedStage].to_f
		mult = (1.0+mult)/2.0 if battler.boss?
		
		statValuesArray.push(mult)

		# Draw the final stat value label
		value = statValues[stat] || 100 # 100 is for accuracy and evasion
		valueBonus = pokemonTribalBonus[stat] || 0
		value = ((value + valueBonus) * mult).floor
		statValuesArray.push(value)

		# Track the highest and lowest main battle stat (not accuracy or evasion)
		if statData.type == :main_battle
			if value > highestStatValue
				highestStat = stat
				highestStatValue = value
			end

			if value < lowestStatValue
				lowestStat = stat
				lowestStatValue = value
			end
		end
		
		calculatedStatInfo[stat] = statValuesArray
	end

	index = 0
	calculatedStatInfo.each do |stat,calculatedInfo|
		name 		= calculatedInfo[0]
		stage 		= calculatedInfo[1]
		statMult 	= calculatedInfo[2]
		statValue 	= calculatedInfo[3]

		# Calculate text display info
		y = statStagesSectionTopY + 40 + 40 * index
		statValueAddendum = ""
		if stat == highestStat
			finalStatColor = HIGHEST_STAT_BASE
			statValueAddendum = " H"
		elsif stat == lowestStat
			finalStatColor = LOWEST_STAT_BASE
			statValueAddendum = " L"
		else
			finalStatColor = base
		end

		# Display the stat's name
		statNameColor = base
		if GameData::Stat.get(stat).type == :main_battle
			tribalBoostSymbol = (stat.to_s + "_TRIBAL").to_sym
			isTribalBoosted = statValues[tribalBoostSymbol] > 0
			statNameColor = TRIBAL_BOOSTED_BASE if isTribalBoosted
		end
		textToDraw.push([name,statLabelX,y,0,statNameColor,shadow])

		# Display the stat stage
		x = statStageX
		x -= 12 if stage != 0
		stageLabel = stage.to_s
		stageLabel = "+" + stageLabel if stage > 0
		textToDraw.push([stageLabel,x,y,0,base,shadow])

		# Display the stat multiplier
		multLabel = statMult.round(2).to_s + "x"
		textToDraw.push([multLabel,statMultX,y,0,base,shadow])

		# Display the final calculated stat
		textToDraw.push([statValue.to_s + statValueAddendum,statValueX,y,0,finalStatColor,shadow])

		index += 1
	end
	
	# Effects
	textToDraw.push(["Battler Effects",battlerEffectsX,statStagesSectionTopY,0,base,shadow])
	
	# Compile a descriptor for each effect on the battler or its position
	battlerEffects = []
	pushEffectDescriptorsToArray(battler,battlerEffects)
	pushEffectDescriptorsToArray(@battle.positions[battler.index],battlerEffects)
	
	scrolling = true if battlerEffects.length > 8
	
	# Print all the battler effects to screen
	scrollingBoundYMin = 84
	scrollingBoundYMax = 336
	index = 0
	repeats = scrolling ? 2 : 1
	if battlerEffects.length != 0
		for repeat in 0...repeats
			battlerEffects.each do |effectName|
				index += 1
				calcedY = statStagesSectionTopY + 4 + 32 * index
				calcedY -= @battlerScrollingValue if scrolling
				next if calcedY < scrollingBoundYMin || calcedY > scrollingBoundYMax
				distanceFromFade = [calcedY - scrollingBoundYMin,scrollingBoundYMax - calcedY].min
				textAlpha = scrolling ? ([distanceFromFade / 20.0,1.0].min * 255).floor : 255
				textBase = Color.new(base.red,base.blue,base.green,textAlpha)
				textShadow = Color.new(shadow.red,shadow.blue,shadow.green,textAlpha)
				textToDraw.push([effectName,battlerEffectsX,calcedY,0,textBase,textShadow])
			end
		end
	else
		textToDraw.push(["None",battlerEffectsX,statStagesSectionTopY + 36,0,base,shadow])
	end
	
	# Reset the scrolling once its scrolled through the entire list once
	@battlerScrollingValue = 0 if @battlerScrollingValue > battlerEffects.length * 32
	
	pbDrawTextPositions(self.bitmap,textToDraw)
  end

  def pushEffectDescriptorsToArray(effectHolder,descriptorsArray)
	effectHolder.eachEffect(!DEBUGGING_EFFECT_DISPLAY) do |effect, value, effectData|
		next if !effectData.info_displayed
		effectName = effectData.real_name
		if effectData.type != :Boolean
			effectName = "#{effectName}: #{effectData.value_to_string(value,@battle)}"
		end
		descriptorsArray.push(effectName)
	end
  end
 
  def update(frameCounter=0)
    super()
    pbUpdateSpriteHash(@sprites)
	if @individual.nil?
		@battlerScrollingValue = 0
		@fieldScrollingValue += 1
	else
		@battlerScrollingValue += 1
		@fieldScrollingValue = 0
	end
  end
end