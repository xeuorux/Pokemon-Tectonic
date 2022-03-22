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
	@backgroundBitmap  		= AnimatedBitmap.new("Graphics/Pictures/Battle/BattleButtonRework/battle_info")
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
    @backgroundBitmap.dispose
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
	# Draw background panel
    self.bitmap.blt(0,0,@backgroundBitmap.bitmap,Rect.new(0,0,@backgroundBitmap.width,@backgroundBitmap.height))
	
	if @individual
		drawIndividualBattlerInfo(@individual)
	else
		drawWholeBattleInfo()
	end
  end
  
  def drawWholeBattleInfo()
	base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
	textToDraw = []
	
	index = 0.2
	battlerIndex = 0
	@battle.eachSameSideBattler do |b|
		next if !b
		y = 50 * index
		textToDraw.push([b.name,24,y,0,base,shadow])
		cursorX = @selected == battlerIndex ? @statusCursorBitmap.width/2 : 0
		self.bitmap.blt(180,y,@statusCursorBitmap.bitmap,Rect.new(cursorX,0,@statusCursorBitmap.width/2,@statusCursorBitmap.height))
		index += 1
		battlerIndex += 1
	end
	index += 0.2
	@battle.eachOtherSideBattler do |b|
		next if !b
		y = 50 * index
		textToDraw.push([b.name,24,y,0,base,shadow])
		cursorX = @selected == battlerIndex ? @statusCursorBitmap.width/2 : 0
		self.bitmap.blt(180,y,@statusCursorBitmap.bitmap,Rect.new(cursorX,0,@statusCursorBitmap.width/2,@statusCursorBitmap.height))
		index += 1
		battlerIndex += 1
	end
	
	weatherName = GameData::BattleWeather.get(@battle.field.weather).real_name
	terrainName = GameData::BattleTerrain.get(@battle.field.terrain).real_name
	textToDraw.push([_INTL("Weather: {1}",weatherName),24,326,0,base,shadow])
	textToDraw.push([_INTL("Terrain: {1}",terrainName),224,326,0,base,shadow])
	
	# Whole field effects
	wholeFieldX = 326
	textToDraw.push([_INTL("Whole Field"),wholeFieldX+60,10,2,base,shadow])
	
	fieldEffects = []
	for effect in 0..30
		effectValue = @battle.field.effects[effect]
		next if effectValue.nil? || effectValue == false
		next if effectValue.is_a?(Integer) && effectValue <= 0
		effectName = labelBattleEffect(effect)
		next if effectName.blank?
		effectName += ": " + effectValue.to_s if effectValue.is_a?(Integer) || effectValue.is_a?(String)
		fieldEffects.push(effectName)
	end
	
	# One side effects
	# Index intentionally not reset
	for side in 0..1
		for effect in 0..30
			effectValue = @battle.sides[side].effects[effect]
			next if effectValue.nil? || effectValue == false
			next if effectValue.is_a?(Integer) && effectValue <= 0
			effectName = labelSideEffect(effect)
			next if effectName.blank?
			effectName += ": " + effectValue.to_s if effectValue.is_a?(Integer) || effectValue.is_a?(String)
			effectName += side == 0 ? " [A]" : " [E]"
			fieldEffects.push(effectName)
		end
	end
	
	# Render out the field effects
	scrolling = true if fieldEffects.length > 8
	index = 0
	repeats = scrolling ? 2 : 1
	for repeat in 0...repeats
		fieldEffects.each do |effectName|
			index += 1
			calcedY = 50 + 32 * index
			calcedY -= @fieldScrollingValue if scrolling
			next if calcedY < 34 || calcedY > 286
			textToDraw.push([effectName,wholeFieldX,calcedY,0,base,shadow])
		end
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
		battlerName += " [#{speciesData.real_form_name}]" if speciesDate.form != 0
	end
	textToDraw.push([battlerName,180,10,0,base,shadow])
	index = 0
	
	stageMulMainStat = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
	stageDivMainStat = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
	
	stageMulBattleStat = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDivBattleStat = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
	
	# Stat Stages
	textToDraw.push(["Stat Stages",24,42,0,base,shadow])
	
	statsToNames = {
	:ATTACK => "Atk",
	:DEFENSE => "Def",
	:SPECIAL_ATTACK => "Sp. Atk",
	:SPECIAL_DEFENSE => "Sp. Def",
	:SPEED => "Speed",
	:ACCURACY => "Acc",
	:EVASION => "Evade"
	}
	
	statsToNames.each do |stat,name|
		y = 90 + 32 * index
	
		statData = GameData::Stat.get(stat)
		textToDraw.push([name,24,y,0,base,shadow])
		
		stage = battler.stages[stat]
		stageZero = stage == 0
		stageLabel = stage.to_s
		if !stageZero && battler.boss?
			stageLabel = (stage/2.0).round(1).to_s
		end
		stageLabel = "+" + stageLabel if stage > 0
		
		if !stageZero
			#Percentages
			stageMul = statData.type == :battle ? stageMulBattleStat : stageMulMainStat
			stageDiv = statData.type == :battle ? stageDivBattleStat : stageDivMainStat
			adjustedStage = stage + 6
			mult = stageMul[adjustedStage].to_f/stageDiv[adjustedStage].to_f
			mult = (1.0+mult)/2.0 if battler.boss?
			stageLabel = "#{stageLabel} (#{mult.round(2)}x)"
		end
		
		x = 106
		x -= 12 if !stageZero
		mainColor = @battle.bossBattle? ? bossBase : base
		textToDraw.push([stageLabel,x,y,0,mainColor,shadow])
		
		index += 1
	end
	
	# Effects
	textToDraw.push(["Effects",240,42,0,base,shadow])
	
	# Battler effects
	battlerEffects = []
	
	for effect in 0..150
		effectValue = battler.effects[effect]
		next if effectValue.nil? || effectValue == false
		next if effectValue.is_a?(Integer) && effectValue <= 0
		next if effect == PBEffects::ProtectRate && effectValue <= 1
		next if effect == PBEffects::Unburden && !battler.hasActiveAbility?(:UNBURDEN)
		effectName = labelBattlerEffect(effect)
		next if effectName.blank?
		effectName += ": " + effectValue.to_s if effectValue.is_a?(Integer) || effectValue.is_a?(String)
		battlerEffects.push(effectName)
	end
	
	# Slot effects
	for effect in 0..30
		effectValue = @battle.positions[battler.index].effects[effect]
		next if effectValue.nil? || effectValue == false
		next if effectValue.is_a?(Integer) && effectValue <= 0
		effectName = labelSlotEffect(effect)
		next if effectName.blank?
		effectName += ": " + effectValue.to_s if effectValue.is_a?(Integer) || effectValue.is_a?(String)
		battlerEffects.push(effectName)
	end
	
	scrolling = true if battlerEffects.length > 8
	
	# Print all the battler effects to screen
	index = 0
	repeats = scrolling ? 2 : 1
	for repeat in 0...repeats
		battlerEffects.each do |effectName|
			index += 1
			calcedY = 90 + 32 * index
			calcedY -= @battlerScrollingValue if scrolling
			next if calcedY < 74 || calcedY > 326
			textToDraw.push([effectName,240,calcedY,0,base,shadow])
		end
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
		"",
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
		"Protected By Gargantuan",
		"Empowered Moonlight"
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
		"" # Wish Maker
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
			"Neutralizing Gas"
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
			"" # Wide Guard
		][effectNumber] || ""
	end
 
  def update(frameCounter=0)
    super()
    pbUpdateSpriteHash(@sprites)
	if @individual.nil?
		@battlerScrollingValue = 0
		@fieldScrollingValue += 2
	else
		@battlerScrollingValue += 2
		@fieldScrollingValue = 0
	end
  end
end