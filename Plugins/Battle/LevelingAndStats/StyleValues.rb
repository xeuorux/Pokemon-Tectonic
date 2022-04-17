COMBINE_ATTACKING_STATS = true
STYLE_VALUE_TOTAL = 50

# Style value adjustments
class Pokemon
	# Max total EVs
	EV_LIMIT      = 50
	# Max EVs that a single stat can have
	EV_STAT_LIMIT = 20
end

def pbStyleValueScreen(pkmn)
	pbFadeOutIn {
		scene = StyleValueScene.new
		screen = StyleValueScreen.new(scene)
		screen.pbStartScreen(pkmn)
	}
end

class StyleValueScene
  attr_accessor :index
  attr_accessor :pool

  def pbDisplay(msg,brief=false)
    UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"],msg) { pbUpdate }
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(pokemon)
    @pokemon=pokemon
	@pool = 0
    # Create sprite hash
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    addBackgroundPlane(@sprites,"bg","mysteryGiftbg",@viewport)
    @sprites["pokeicon"]=PokemonIconSprite.new(@pokemon,@viewport)
    @sprites["pokeicon"].setOffset(PictureOrigin::Center)
    @sprites["pokeicon"].x=36
    @sprites["pokeicon"].y=36
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["msgwindow"]=Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible=false
    @sprites["msgwindow"].viewport=@viewport
	
	#Create the left and right arrow sprites which surround the selected index
	@index = 0
	@sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].x       = 36
    @sprites["leftarrow"].y       = 78
    @sprites["leftarrow"].play
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["rightarrow"].x       = 190
    @sprites["rightarrow"].y       = 78
    @sprites["rightarrow"].play
    
	# CALL COMPLEX SCENE DRAWING METHODS HERE #
	drawNameAndStats()
	
    pbDeactivateWindows(@sprites)
    # Fade in all sprites
    pbFadeInAndShow(@sprites)
  end
  
  def drawNameAndStats
	overlay=@sprites["overlay"].bitmap
    overlay.clear
	base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
	
	styleValueLabelX = 72
	styleValueX = styleValueLabelX + 120
	
	#Place the pokemon's name
	textpos = [[_INTL("{1}", @pokemon.name),styleValueLabelX,2,0,Color.new(88,88,80),Color.new(168,184,184)]]
	
	# Place the pokemon's style values (stored as EVs)
	textpos.concat([
	   [_INTL("Style Values"),styleValueLabelX,42,0,base,shadow],
       [_INTL("HP"),styleValueLabelX,82,0,base,shadow],
       [sprintf("%d",@pokemon.ev[:HP]),styleValueX,82,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Attack"),styleValueLabelX,114,0,base,shadow],
       [sprintf("%d",@pokemon.ev[:ATTACK]),styleValueX,114,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Defense"),styleValueLabelX,146,0,base,shadow],
       [sprintf("%d",@pokemon.ev[:DEFENSE]),styleValueX,146,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Atk"),styleValueLabelX,178,0,base,shadow],
       [sprintf("%d",@pokemon.ev[:SPECIAL_ATTACK]),styleValueX,178,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Def"),styleValueLabelX,210,0,base,shadow],
       [sprintf("%d",@pokemon.ev[:SPECIAL_DEFENSE]),styleValueX,210,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Speed"),styleValueLabelX,242,0,base,shadow],
       [sprintf("%d",@pokemon.ev[:SPEED]),styleValueX,242,1,Color.new(64,64,64),Color.new(176,176,176)],
    ])
	
	# Place the "reset all" button
	red = Color.new(250,120,120)
	textpos.push([_INTL("Reset"),styleValueLabelX,280,0,@index == 6 ? red : base,shadow])
	textpos.push([_INTL("Confirm"),styleValueLabelX,320,0,@index == 7 ? red : base,shadow])
	
	# Place the pokemon's final resultant stats
	finalStatLabelX = styleValueLabelX + 250
	finalStatX		= finalStatLabelX + 120
    textpos.concat([
	   [_INTL("Final Stats"),finalStatLabelX,42,0,base,shadow],
       [_INTL("HP"),finalStatLabelX,82,0,base,shadow],
       [sprintf("%d",@pokemon.totalhp),finalStatX,82,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Attack"),finalStatLabelX,114,0,base,shadow],
       [sprintf("%d",@pokemon.attack),finalStatX,114,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Defense"),finalStatLabelX,146,0,base,shadow],
       [sprintf("%d",@pokemon.defense),finalStatX,146,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Atk"),finalStatLabelX,178,0,base,shadow],
       [sprintf("%d",@pokemon.spatk),finalStatX,178,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Sp. Def"),finalStatLabelX,210,0,base,shadow],
       [sprintf("%d",@pokemon.spdef),finalStatX,210,1,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Speed"),finalStatLabelX,242,0,base,shadow],
       [sprintf("%d",@pokemon.speed),finalStatX,242,1,Color.new(64,64,64),Color.new(176,176,176)],
    ])
	
	# Place the style value pool
	poolXLeft = finalStatLabelX - 100
	textpos.concat([
		[_INTL("Pool"),poolXLeft,280,0,base,shadow],
		[sprintf("%d",@pool),poolXLeft,320,0,Color.new(64,64,64),Color.new(176,176,176)]
	])
	
	# Place the style name
	styleXLeft = finalStatLabelX
	styleName = "Balanced"
	styleName = getStyleName(@pokemon.ev)
	textpos.concat([
		[_INTL("Style"),styleXLeft,280,0,base,shadow],
		[styleName,styleXLeft,320,0,Color.new(64,64,64),Color.new(176,176,176)]
	])
	
	# Draw all the previously placed texts
	pbDrawTextPositions(overlay,textpos)
	
	# Put the arrows around the currently selected style value line
	if @index < 6
		@sprites["leftarrow"].y = @sprites["rightarrow"].y = 90+32*@index
	else
		@sprites["leftarrow"].y = @sprites["rightarrow"].y = -500
	end
  end

  # End the scene here
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    # DISPOSE OF BITMAPS HERE #
  end
  
  def getStyleName(evs)
	if !COMBINE_ATTACKING_STATS
		stats = [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
	else
		stats = [:HP,:ATTACK,:DEFENSE,:SPECIAL_DEFENSE,:SPEED]
	end
	largeStats = []
	stats.each do |stat|
		largeStats.push(stat) if evs[stat] >= 13
	end
	largeStats = largeStats.sort_by { |a| evs[a]}
	largeStats.pop() if largeStats.length > 3
	largeStats = largeStats.sort_by { |a| stats.find_index(a) }
	if largeStats.length == 1
		case largeStats[0]
		when :HP
			return "Stocky"
		when :ATTACK
			return "Aggressive"
		when :DEFENSE
			return "Defensive"
		when :SPECIAL_ATTACK
			return "Cunning"
		when :SPECIAL_DEFENSE
			return "Suspicious"
		when :SPEED
			return "Quick"
		end
	elsif largeStats.length == 2
		case largeStats
		when [:HP,:ATTACK]
			return "Brutish"
		when [:HP,:DEFENSE]
			return "Armored"
		when [:HP,:SPECIAL_ATTACK]
			return "Attuned"
		when [:HP,:SPECIAL_DEFENSE]
			return "Guarded"
		when [:HP,:SPEED]
			return "Unyielding"
		when [:ATTACK,:DEFENSE]
			return "Bulky"
		when [:ATTACK,:SPECIAL_ATTACK]
			return "Variable"
		when [:ATTACK,:SPECIAL_DEFENSE]
			return "Flowing"
		when [:ATTACK,:SPEED]
			return "Hunting"
		when [:DEFENSE,:SPECIAL_ATTACK]
			return "Vanguard"
		when [:DEFENSE,:SPECIAL_DEFENSE]
			return "Prepared"
		when [:DEFENSE,:SPEED]
			return "Steady"
		when [:SPECIAL_ATTACK,:SPECIAL_DEFENSE]
			return "Calm"
		when [:SPECIAL_ATTACK,:SPEED]
			return "Striking"
		when [:SPECIAL_DEFENSE,:SPEED]
			return "Spirited"
		end
	elsif largeStats.length == 3
		case largeStats
		when [:HP,:ATTACK,:DEFENSE]
			return "Blunt"
		when [:HP,:ATTACK,:SPECIAL_ATTACK]
			return "Forceful"
		when [:HP,:ATTACK,:SPECIAL_DEFENSE]
			return "Smooth"
		when [:HP,:ATTACK,:SPEED]
			return "Blitzing"
		when [:HP,:DEFENSE,:SPECIAL_ATTACK]
			return "Fortified"
		when [:HP,:DEFENSE,:SPECIAL_DEFENSE]
			return "Precautionary"
		when [:HP,:DEFENSE,:SPEED]
			return "Carefree"
		when [:HP,:SPECIAL_DEFENSE,:SPEED]
			return "Crafty"
		when [:HP,:SPECIAL_ATTACK,:SPECIAL_DEFENSE]
			return "Serene"
		when [:HP,:SPECIAL_ATTACK,:SPEED]
			return "Energetic"
		when [:ATTACK,:DEFENSE,:SPECIAL_ATTACK]
			return "Deliberate"
		when [:ATTACK,:DEFENSE,:SPECIAL_DEFENSE]
			return "Patient"
		when [:ATTACK,:DEFENSE,:SPEED]
			return "Flanking"
		when [:ATTACK,:SPECIAL_ATTACK,:SPECIAL_DEFENSE]
			return "Strategic"
		when [:ATTACK,:SPECIAL_ATTACK,:SPEED]
			return "Opportunistic"
		when [:ATTACK,:SPECIAL_DEFENSE,:SPEED]
			return "Determined"
		when [:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE]
			return "Calculating"
		when [:DEFENSE,:SPECIAL_ATTACK,:SPEED]
			return "Tactical"
		when [:DEFENSE,:SPECIAL_DEFENSE,:SPEED]
			return "Protective"
		when [:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
			return "Elegant"
		end
	elsif largeStats.length >= 4
		echoln("This shouldn't be possible.")
	end
	
	return "Balanced"
  end
end

class StyleValueScreen
  def initialize(scene)
    @scene = scene
  end
  
  def updateStats(pkmn)
	pkmn.calc_stats
	@scene.drawNameAndStats
  end

  def pbStartScreen(pkmn)
    @scene.pbStartScene(pkmn)
	@index = 0
	stats = [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]

	resetEVs = false
	if COMBINE_ATTACKING_STATS
		resetEVs = true if pkmn.ev[:ATTACK] != pkmn.ev[:SPECIAL_ATTACK]
	else !COMBINE_ATTACKING_STATS
		if pkmn.ev[:ATTACK] == pkmn.ev[:SPECIAL_ATTACK]
			total = 0
			stats.each do |stat|
				total += pkmn.ev[stat]
			end
			resetEVs = true if total > STYLE_VALUE_TOTAL
		end 
	end

	if resetEVs
		pbMessage(_INTL("Resetting style values due to non-conformity with rules."))
		GameData::Stat.each_main do |s|
			pkmn.ev[s.id]       = 8
		end
	end

	@pool = STYLE_VALUE_TOTAL
	stats.each do |stat|
		next if stat == :SPECIAL_ATTACK && COMBINE_ATTACKING_STATS
		@pool -= pkmn.ev[stat]
	end
	if @pool < 0
		raise _INTL("{1} has more EVs than its supposed to be able to!",pkmn.name)
	end
	@scene.pool = @pool
	updateStats(pkmn)
    loop do
	  Graphics.update
      Input.update
      @scene.pbUpdate
      if Input.trigger?(Input::BACK)
        if @pool > 0
		  pbPlayBuzzerSE
		  @scene.pbDisplay("There are still Style Values points left to assign!")
		elsif @scene.pbConfirm(_INTL("Finish adjusting style values?"))
		  @scene.pbEndScene
		  pbPlayCloseMenuSE
          return
        end
	  elsif Input.trigger?(Input::USE)
		if @index == 6
			pkmn.ev.each do |stat,value|
				pkmn.ev[stat] = 0
			end
			@pool = STYLE_VALUE_TOTAL
			@scene.pool = @pool
			pbPlayDecisionSE
			updateStats(pkmn)
		elsif @index == 7
			if @pool > 0
			  pbPlayBuzzerSE
			  @scene.pbDisplay("There are still Style Values points left to assign!")
			elsif @scene.pbConfirm(_INTL("Finish adjusting style values?"))
			  @scene.pbEndScene
			  pbPlayCloseMenuSE
			  return
			end
		end
	  elsif Input.trigger?(Input::UP)
		if @index > 0
			@index = (@index - 1)
		else
			@index = 7
		end
		pbPlayCursorSE
		@scene.index = @index
		@scene.drawNameAndStats
	  elsif Input.trigger?(Input::DOWN)
		if @index < 7
			@index = (@index + 1)
		else
			@index = 0
		end
		pbPlayCursorSE
		@scene.index = @index
		@scene.drawNameAndStats
      elsif Input.repeat?(Input::RIGHT) && @index < 6
		stat = stats[@index]
		stat = :ATTACK if COMBINE_ATTACKING_STATS && stat == :SPECIAL_ATTACK
		if pkmn.ev[stat] < 20 && @pool > 0
			pkmn.ev[stat] = (pkmn.ev[stat] + 1)
			@pool -= 1
			pkmn.ev[:SPECIAL_ATTACK] = pkmn.ev[:ATTACK] if COMBINE_ATTACKING_STATS
			@scene.pool = @pool
			pbPlayDecisionSE
			updateStats(pkmn)
		elsif pkmn.ev[stat] == 20 && Input.trigger?(Input::RIGHT)
			pkmn.ev[stat] = 0
			pkmn.ev[:SPECIAL_ATTACK] = pkmn.ev[:ATTACK] if COMBINE_ATTACKING_STATS
			@pool += 20
			@scene.pool = @pool
			pbPlayDecisionSE
			updateStats(pkmn)
		elsif Input.time?(Input::RIGHT) < 20000
			pbPlayBuzzerSE
		end
	  elsif Input.repeat?(Input::LEFT) && @index < 6
	    stat = stats[@index]
		stat = :ATTACK if COMBINE_ATTACKING_STATS && stat == :SPECIAL_ATTACK
		if pkmn.ev[stat] > 0
			pkmn.ev[stat] = (pkmn.ev[stat] - 1)
			pkmn.ev[:SPECIAL_ATTACK] = pkmn.ev[:ATTACK] if COMBINE_ATTACKING_STATS
			@pool += 1
			@scene.pool = @pool
			pbPlayDecisionSE
			updateStats(pkmn)
		elsif @pool > 0 && Input.trigger?(Input::LEFT)
			pkmn.ev[stat] = [@pool,20].min
			pkmn.ev[:SPECIAL_ATTACK] = pkmn.ev[:ATTACK] if COMBINE_ATTACKING_STATS
			@pool -= pkmn.ev[stat]
			@scene.pool = @pool
			pbPlayDecisionSE
			updateStats(pkmn)
		elsif Input.time?(Input::LEFT) < 20000
			pbPlayBuzzerSE
		end
	  end
    end
  end
end

def choosePokemonToStyle(pokemonVar = 1,nameVar = 3)
	pbChooseStylePokemon(1,3, proc { |p|
		p.ev[:ATTACK] != 8 ||
		p.ev[:DEFENSE] != 8 ||
		p.ev[:SPEED] != 8 ||
		p.ev[:HP] != 8 ||
		p.ev[:SPECIAL_ATTACK] != 8 ||
		p.ev[:SPECIAL_DEFENSE] != 8
		}
	)
end

def pbChooseStylePokemon(variableNumber,nameVarNumber,styleProc=nil)
  chosen = 0
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene,$Trainer.party)
    if styleProc
      chosen=screen.pbChooseAblePokemonStyle(styleProc)
    else
      screen.pbStartScene(_INTL("Choose a Pokémon."),false)
      chosen = screen.pbChoosePokemon
      screen.pbEndScene
    end
  }
  pbSet(variableNumber,chosen)
  if chosen>=0
    pbSet(nameVarNumber,$Trainer.party[chosen].name)
  else
    pbSet(nameVarNumber,"")
  end
end

class PokemonPartyScreen
	def pbChooseAblePokemonStyle(styledProc)
		annot = []
		for pkmn in @party
		  styled = styledProc.call(pkmn)
		  annot.push((styled) ? _INTL("STYLED") : _INTL("NOT STYLED"))
		end
		ret = -1
		@scene.pbStartScene(@party,
		   (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),annot)
		loop do
		  @scene.pbSetHelpText(
			 (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
		  pkmnid = @scene.pbChoosePokemon
		  break if pkmnid<0
		  ret = pkmnid
			break
		end
		@scene.pbEndScene
    return ret
  end
end

def styleValuesTrainer()
	if isTempSwitchOff?("A")
		pbMessage(_INTL("I'm the Style Values adjuster. I can adjust your Pokémon's Style values."))
		pbMessage(_INTL("1 point in a Style Value for a stat is equivalent to 1 point in the same base stat."))
		setTempSwitchOn("A")
	end
	if pbConfirmMessage(_INTL("Would you like to adjust the Style Values of any of your Pokémon?"))
		while true do
			choosePokemonToStyle()
			if $game_variables[1] < 0
				pbMessage(_INTL("If your Pokémon need to have their Style Values adjusted, come to me."))
				break
			else
				pbStyleValueScreen(pbGetPokemon(1))
			end
		end
	else
		pbMessage(_INTL("If your Pokémon need to have their Style Values adjusted, come to me."))
	end
end