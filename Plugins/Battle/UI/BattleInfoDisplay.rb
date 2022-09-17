HIGHEST_STAT_BASE = Color.new(139,52,34)
LOWEST_STAT_BASE = Color.new(60,55,112)

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
		weatherMessage = _INTL("{1} Weather ({2})",weatherName,weatherDuration)
	end
	
	textToDraw.push([weatherMessage,24,weatherAndTerrainY,0,base,shadow])

	terrainMessage = "No Terrain"
	if @battle.field.terrain != :None
		terrainName = GameData::BattleTerrain.get(@battle.field.terrain).real_name
		terrainDuration = @battle.field.terrainDuration
		terrainMessage = _INTL("{1} Terrain ({2})",terrainName, terrainDuration)
	end
	textToDraw.push([terrainMessage,256+24,weatherAndTerrainY,0,base,shadow])
	
	# Whole field effects
	wholeFieldX = 332
	textToDraw.push([_INTL("Field Effects"),wholeFieldX+60,0,2,base,shadow])
	
	fieldEffects = []
	for effect in 0..30
		effectValue = @battle.field.effects[effect]
		next if effectValue.nil?
		next if effectValue == false
		next if effectValue.is_a?(Integer) && effectValue <= 0
		effectName = labelBattleEffect(effect)
		next if effectName.blank?
		effectName += ": " + effectValue.to_s if effectValue.is_a?(Integer) || effectValue.is_a?(String) || effectValue.is_a?(Symbol)
		fieldEffects.push(effectName)
	end
	
	# One side effects
	# Index intentionally not reset
	for side in 0..1
		for effect in 0..30
			effectValue = @battle.sides[side].effects[effect]
			next if effectValue.nil?
			next if effectValue == false
			next if effectValue.is_a?(Integer) && effectValue <= 0
			effectName = labelSideEffect(effect)
			next if effectName.blank?
			effectName += ": " + effectValue.to_s if effectValue.is_a?(Integer) || effectValue.is_a?(String) || effectValue.is_a?(Symbol)
			effectName += side == 0 ? " [A]" : " [E]"
			fieldEffects.push(effectName)
		end
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
		value = (value * mult).floor
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
			mainColor = HIGHEST_STAT_BASE
			statValueAddendum = " H"
		elsif stat == lowestStat
			mainColor = LOWEST_STAT_BASE
			statValueAddendum = " L"
		else
			mainColor = base
		end

		# Display the stat's name
		textToDraw.push([name,statLabelX,y,0,mainColor,shadow])

		# Display the stat stage
		x = statStageX
		x -= 12 if stage != 0
		stageLabel = stage.to_s
		stageLabel = "+" + stageLabel if stage > 0
		textToDraw.push([stageLabel,x,y,0,mainColor,shadow])

		# Display the stat multiplier
		multLabel = statMult.round(2).to_s + "x"
		textToDraw.push([multLabel,statMultX,y,0,mainColor,shadow])

		# Display the final calculated stat
		textToDraw.push([statValue.to_s + statValueAddendum,statValueX,y,0,mainColor,shadow])

		index += 1
	end
	
	# Effects
	textToDraw.push(["Battler Effects",battlerEffectsX,statStagesSectionTopY,0,base,shadow])
	
	# Battler effects
	battlerEffects = []
	
	for effect in 0..150
		effectValue = battler.effects[effect]
		next if effectValue.nil?
		next if effectValue == false
		next if effectValue.is_a?(Integer) && effectValue <= 0
		next if effect == PBEffects::ProtectRate && effectValue <= 1
		next if effect == PBEffects::Unburden && !battler.hasActiveAbility?(:UNBURDEN)
		effectName = labelBattlerEffect(effect)
		next if effectName.blank?
		effectName += ": " + effectValue.to_s if effectValue.is_a?(Integer) || effectValue.is_a?(String) || effectValue.is_a?(Symbol)
		battlerEffects.push(effectName)
	end
	
	# Slot effects
	for effect in 0..30
		effectValue = @battle.positions[battler.index].effects[effect]
		next if effectValue.nil?
		next if effectValue == false
		next if effectValue.is_a?(Integer) && effectValue <= 0
		effectName = labelSlotEffect(effect)
		next if effectName.blank?
		effectName += ": " + effectValue.to_s if effectValue.is_a?(Integer) || effectValue.is_a?(String) || effectValue.is_a?(Symbol)
		battlerEffects.push(effectName)
	end
	
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
  
  def labelBattlerEffect(effectNumber)
	return [
		"Aqua Ring",
		"", # Attract
		"",
		"",
		"Bide",
		"",
		"",
		"Burn Up",
		"Charge",
		"", # Choice Band
		"Confusion",
		"",
		"",
		"Curse",
		"", # Dancer
		"",
		"Destiny Bond",
		"",
		"",
		"", # Disable
		"Disabled Move",
		"",
		"Embargo",
		"",
		"Encored Move",
		"",
		"",
		"Flash Fire",
		"",
		"Focus Energy",
		"",
		"",
		"Foresight",
		"Fury Cutter",
		"Gastro Acid",
		"",
		"",
		"Heal Block",
		"",
		"Move Recharge", # hyper beam, etc.
		"",
		"Imprison",
		"Ingrain",
		"",
		"",
		"",
		"Laser Focus",
		"Leech Seed",
		"Lock-On",
		"Locked On To",
		"",
		"",
		"Magnet Rise",
		"Trapped", # Mean look, etc.
		"",
		"Metronome Count",
		"Micle Berry",
		"Minimize",
		"Miracle Eye",
		"",
		"",
		"",
		"Mud Sport",
		"Nightmare",
		"Locked Into Move", # Outrage, etc.
		"",
		"Perish Song",
		"",
		"",
		"",
		"",
		"Black Powder",
		"Power Trick",
		"",
		"",
		"",
		"",
		"Protection Failure", # Protect Rate
		"",
		"",
		"Rage",
		"",
		"Rollout",
		"",
		"",
		"Sky Drop",
		"Slow Start",
		"Smacked Down",
		"",
		"",
		"", # Spotlight
		"Stockpile",
		"",
		"",
		"Substitute",
		"Taunt",
		"Telekenisis",
		"Throat Chopped",
		"Torment",
		"Toxic",
		"Transform",
		"",
		"", # Whirlpool, etc.
		"Trapped By Move",
		"Trapped By User",
		"Truant",
		"2-Turn Attack",
		"Added Type",
		"Unburden",
		"Uproar Restless",
		"Water Sport",
		"Weight Added",
		"Drowzy",
		"",
		"",
		"",
		"",
		"No Retreat",
		"",
		"Trapped by Jaws",
		"Trapping With Jaws",
		"Tar Shot",
		"Octolocked",
		"Octolocking",
		"Blundered",
		"",
		"",
		"",
		"",
		"Flinch Protection",
		"Enlightened",
		"Cold Conversion",
		"Creeped Out",
		"Lucky Star",
		"Charmed",
		"",
		"Inured",
		"No Retreat",
		"Nerve Broken",
		"Ice Ball",
		"Roll Out",
		"", # Gargantuan
		"", # Stunning Curl
		"", # Red-Hot Retreat
		"Primeval Moonlight",
		"Primeval Endure",
		"Primeval Laser Focus",
		"Primeval Destiny Bond",
		"Volley Stance",
		"Giving Dragon Ride",
		"Riding Dragon",
		"Shimmering Heat",
		"Flare Witch",
	][effectNumber] || ""
  end
  
  def labelSlotEffect(effectNumber)
	return [
		"Attack Incoming",
		"Delayed Attack",
		"",
		"",
		"", # Healing Wish
		"", # Lunar Dance
		"", # Wish
		"Wishing For",
		"", # Wish Maker
	][effectNumber] || ""
  end
  
	def labelBattleEffect(effectNumber)
		return [
			"Amulet Coin",
			"Fairy Lock",
			"", # Fusion Bolt
			"", # Fusion Flare
			"Gravity",
			"Happy Hour",
			"", # Ion Deluge
			"Magic Room",
			"Mud Sport",
			"Pay Day",
			"Trick Room",
			"Water Sport",
			"Wonder Room",
			"Fortune",
			"Neutralizing Gas",
			"Puzzle Room",
			"Odd Room",
		][effectNumber] || ""
	end

	def labelSideEffect(effectNumber)
		return [
			"Aurora Veil",
			"", # Crafty Shield
			"", # Echoed Voice Count
			"", # Encoed Voice Used
			"", # Last Round Fainted
			"Light Screen",
			"Lucky Chant",
			"", # Mat Block,
			"Mist",
			"", # Quick Guard
			"Rainbow",
			"Reflect",
			"", # Round
			"Safeguard",
			"Sea of Fire",
			"Spikes",
			"Stealth Rock",
			"Sticky Web",
			"Swamp",
			"Tailwind",
			"Poison Spikes", # Toxic Spikes,
			"", # Wide Guard
			"Flame Spikes",
			"EmpoweredEmbargo",
			"Frost Spikes",
		][effectNumber] || ""
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