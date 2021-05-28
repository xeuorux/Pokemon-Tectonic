class PokemonSystem
	attr_accessor :followers

  def initialize
    @textspeed   = 1     # Text speed (0=slow, 1=normal, 2=fast, 3=rapid)
    @battlescene = 0     # Battle effects (animations) (0=on, 1=off)
    @battlestyle = 1     # Battle style (0=switch, 1=set)
    @frame       = 0     # Default window frame (see also Settings::MENU_WINDOWSKINS)
    @textskin    = 0     # Speech frame
    @font        = 0     # Font (see also Settings::FONT_OPTIONS)
    @screensize  = (Settings::SCREEN_SCALE * 2).floor - 1   # 0=half size, 1=full size, 2=full-and-a-half size, 3=double size
    @language    = 0     # Language (see also Settings::LANGUAGES in script PokemonSystem)
    @runstyle    = 0     # Default movement speed (0=walk, 1=run)
    @bgmvolume   = 30   # Volume of background music and ME
    @sevolume    = 30   # Volume of sound effects
    @textinput   = 1     # Text input mode (0=cursor, 1=keyboard)
	@followers   = 0	# Follower Pokemon enabled (0=true, 1=false)
  end
end

class PokemonOption_Scene
  def pbStartScene(inloadscreen=false)
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("Options"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].text           = _INTL("Speech frame {1}.",1+$PokemonSystem.textskin)
    @sprites["textbox"].letterbyletter = false
    pbSetSystemFont(@sprites["textbox"].contents)
    # These are the different options in the game. To add an option, define a
    # setter and a getter for that option. To delete an option, comment it out
    # or delete it. The game's options may be placed in any order.
    @PokemonOptions = [
       SliderOption.new(_INTL("Music Volume"),0,100,5,
         proc { $PokemonSystem.bgmvolume },
         proc { |value|
           if $PokemonSystem.bgmvolume!=value
             $PokemonSystem.bgmvolume = value
             if $game_system.playing_bgm!=nil && !inloadscreen
               $game_system.playing_bgm.volume = value
               playingBGM = $game_system.getPlayingBGM
               $game_system.bgm_pause
               $game_system.bgm_resume(playingBGM)
             end
           end
         }
       ),
       SliderOption.new(_INTL("SE Volume"),0,100,5,
         proc { $PokemonSystem.sevolume },
         proc { |value|
           if $PokemonSystem.sevolume!=value
             $PokemonSystem.sevolume = value
             if $game_system.playing_bgs!=nil
               $game_system.playing_bgs.volume = value
               playingBGS = $game_system.getPlayingBGS
               $game_system.bgs_pause
               $game_system.bgs_resume(playingBGS)
             end
             pbPlayCursorSE
           end
         }
       ),
       EnumOption.new(_INTL("Text Speed"),[_INTL("Slow"),_INTL("Normal"),_INTL("Fast"),_INTL("Rapid")],
         proc { $PokemonSystem.textspeed },
         proc { |value|
           $PokemonSystem.textspeed = value
           MessageConfig.pbSetTextSpeed(MessageConfig.pbSettingToTextSpeed(value))
         }
       ),
       EnumOption.new(_INTL("Battle Effects"),[_INTL("On"),_INTL("Off")],
         proc { $PokemonSystem.battlescene },
         proc { |value| $PokemonSystem.battlescene = value }
       ),
       EnumOption.new(_INTL("Default Movement"),[_INTL("Walking"),_INTL("Running")],
         proc { $PokemonSystem.runstyle },
         proc { |value| $PokemonSystem.runstyle = value }
       ),
       NumberOption.new(_INTL("Speech Frame"),1,Settings::SPEECH_WINDOWSKINS.length,
         proc { $PokemonSystem.textskin },
         proc { |value|
           $PokemonSystem.textskin = value
           MessageConfig.pbSetSpeechFrame("Graphics/Windowskins/" + Settings::SPEECH_WINDOWSKINS[value])
         }
       ),
       NumberOption.new(_INTL("Menu Frame"),1,Settings::MENU_WINDOWSKINS.length,
         proc { $PokemonSystem.frame },
         proc { |value|
           $PokemonSystem.frame = value
           MessageConfig.pbSetSystemFrame("Graphics/Windowskins/" + Settings::MENU_WINDOWSKINS[value])
         }
       ),
       EnumOption.new(_INTL("Font Style"),[_INTL("Em"),_INTL("R/S"),_INTL("FRLG"),_INTL("DP")],
         proc { $PokemonSystem.font },
         proc { |value|
           $PokemonSystem.font = value
           MessageConfig.pbSetSystemFontName(Settings::FONT_OPTIONS[value])
         }
       ),
       EnumOption.new(_INTL("Text Entry"),[_INTL("Cursor"),_INTL("Keyboard")],
         proc { $PokemonSystem.textinput },
         proc { |value| $PokemonSystem.textinput = value }
       ),
       EnumOption.new(_INTL("Screen Size"),[_INTL("S"),_INTL("M"),_INTL("L"),_INTL("XL"),_INTL("Full")],
         proc { [$PokemonSystem.screensize, 4].min },
         proc { |value|
           if $PokemonSystem.screensize != value
             $PokemonSystem.screensize = value
             pbSetResizeFactor($PokemonSystem.screensize)
           end
         }
       )
    ]
	@PokemonOptions.push(EnumOption.new(_INTL("Pokemon Follow"),[_INTL("On"),_INTL("Off")],
         proc { $PokemonSystem.followers },
         proc { |value|
			$PokemonSystem.followers = value
            pbToggleFollowingPokemon($PokemonSystem.followers == 0 ? "on" : "off",false)
         }
       )) if $PokemonGlobal
    @PokemonOptions = pbAddOnOptions(@PokemonOptions)
    @sprites["option"] = Window_PokemonOption.new(@PokemonOptions,0,
       @sprites["title"].height,Graphics.width,
       Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
    @sprites["option"].viewport = @viewport
    @sprites["option"].visible  = true
    # Get the values of each option
    for i in 0...@PokemonOptions.length
      @sprites["option"].setValueNoRefresh(i,(@PokemonOptions[i].get || 0))
    end
    @sprites["option"].refresh
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
 end
 
 
# pbFadeOutIn(z) { block }
# Fades out the screen before a block is run and fades it back in after the
# block exits.  z indicates the z-coordinate of the viewport used for this effect
def pbFadeOutIn(z=99999,nofadeout=false)
  col=Color.new(0,0,0,0)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=z
  numFrames = (Graphics.frame_rate*0.25).floor
  alphaDiff = (255.0/numFrames).ceil
  for j in 0..numFrames
    col.set(0,0,0,j*alphaDiff)
    viewport.color=col
    Graphics.update
    Input.update
  end
  pbPushFade
  begin
    yield if block_given?
  ensure
    pbPopFade
    if !nofadeout
      for j in 0..numFrames
        col.set(0,0,0,(numFrames-j)*alphaDiff)
        viewport.color=col
        Graphics.update
        Input.update
      end
    end
    viewport.dispose
  end
end

def pbNicknameAndStore(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  $Trainer.pokedex.set_seen(pkmn.species)
  $Trainer.pokedex.set_owned(pkmn.species)
  
  #Let the player know info about the individual pokemon they caught
  pbMessage(_INTL("You check {1}, and discover that its ability is {2}!",pkmn.name,pkmn.ability.name))
  
  if (pkmn.hasItem?)
	pbMessage(_INTL("The {1} is holding an {2}!",pkmn.name,pkmn.item.name))
  end
  
  pbStorePokemon(pkmn)
end

module PokeBattle_BattleCommon
  #=============================================================================
  # Store caught Pokémon
  #=============================================================================
  def pbStorePokemon(pkmn)
    # Store the Pokémon
    currentBox = @peer.pbCurrentBox
    storedBox  = @peer.pbStorePokemon(pbPlayer,pkmn)
    if storedBox<0
      pbDisplayPaused(_INTL("{1} has been added to your party.",pkmn.name))
      @initialItems[0][pbPlayer.party.length-1] = pkmn.item_id if @initialItems
      return
    end
    # Messages saying the Pokémon was stored in a PC box
    creator    = @peer.pbGetStorageCreatorName
    curBoxName = @peer.pbBoxName(currentBox)
    boxName    = @peer.pbBoxName(storedBox)
    if storedBox!=currentBox
      if creator
        pbDisplayPaused(_INTL("Box \"{1}\" on {2}'s PC was full.",curBoxName,creator))
      else
        pbDisplayPaused(_INTL("Box \"{1}\" on someone's PC was full.",curBoxName))
      end
      pbDisplayPaused(_INTL("{1} was transferred to box \"{2}\".",pkmn.name,boxName))
    else
      if creator
        pbDisplayPaused(_INTL("{1} was transferred to {2}'s PC.",pkmn.name,creator))
      else
        pbDisplayPaused(_INTL("{1} was transferred to someone's PC.",pkmn.name))
      end
      pbDisplayPaused(_INTL("It was stored in box \"{1}\".",boxName))
    end
  end
  
  # Register all caught Pokémon in the Pokédex, and store them.
  def pbRecordAndStoreCaughtPokemon
    @caughtPokemon.each do |pkmn|
      pbPlayer.pokedex.register(pkmn)   # In case the form changed upon leaving battle
	  
	  #Let the player know info about the individual pokemon they caught
      pbDisplayPaused(_INTL("You check {1}, and discover that its ability is {2}!",pkmn.name,pkmn.ability.name))
      
      if (pkmn.hasItem?)
        pbDisplayPaused(_INTL("The {1} is holding an {2}!",pkmn.name,pkmn.item.name))
      end
	  
      # Record the Pokémon's species as owned in the Pokédex
      if !pbPlayer.owned?(pkmn.species)
        pbPlayer.pokedex.set_owned(pkmn.species)
        if $Trainer.has_pokedex
          pbDisplayPaused(_INTL("You register {1} as caught in the Pokédex.",pkmn.name))
          pbPlayer.pokedex.register_last_seen(pkmn)
          @scene.pbShowPokedex(pkmn.species)
        end
      end
      # Record a Shadow Pokémon's species as having been caught
      pbPlayer.pokedex.set_shadow_pokemon_owned(pkmn.species) if pkmn.shadowPokemon?
      # Store caught Pokémon
      pbStorePokemon(pkmn)
    end
    @caughtPokemon.clear
  end
end

class PokeBattle_Battle

  #=============================================================================
  # Switching Pokémon
  #=============================================================================
  # General switching method that checks if any Pokémon need to be sent out and,
  # if so, does. Called at the end of each round.
  def pbEORSwitch(favorDraws=false)
    return if @decision>0 && !favorDraws
    return if @decision==5 && favorDraws
    pbJudge
    return if @decision>0
    # Check through each fainted battler to see if that spot can be filled.
    switched = []
    loop do
      switched.clear
      @battlers.each do |b|
        next if !b || !b.fainted?
        idxBattler = b.index
        next if !pbCanChooseNonActive?(idxBattler)
        if !pbOwnedByPlayer?(idxBattler)   # Opponent/ally is switching in
          next if wildBattle? && opposes?(idxBattler)   # Wild Pokémon can't switch
          idxPartyNew = pbSwitchInBetween(idxBattler)
          opponent = pbGetOwnerFromBattlerIndex(idxBattler)
          # NOTE: The player is only offered the chance to switch their own
          #       Pokémon when an opponent replaces a fainted Pokémon in single
          #       battles. In double battles, etc. there is no such offer.
          if @internalBattle && @switchStyle && trainerBattle? && pbSideSize(0)==1 &&
             opposes?(idxBattler) && !@battlers[0].fainted? && !switched.include?(0) &&
             pbCanChooseNonActive?(0) && @battlers[0].effects[PBEffects::Outrage]==0
            idxPartyForName = idxPartyNew
            enemyParty = pbParty(idxBattler)
            if enemyParty[idxPartyNew].ability == :ILLUSION
              new_index = pbLastInTeam(idxBattler)
              idxPartyForName = new_index if new_index >= 0 && new_index != idxPartyNew
            end
            if pbDisplayConfirm(_INTL("{1} is about to send in {2}. Will you switch your Pokémon?",
               opponent.full_name, enemyParty[idxPartyForName].name))
              idxPlayerPartyNew = pbSwitchInBetween(0,false,true)
              if idxPlayerPartyNew>=0
                pbMessageOnRecall(@battlers[0])
                pbRecallAndReplace(0,idxPlayerPartyNew)
                switched.push(0)
              end
            end
          end
          pbRecallAndReplace(idxBattler,idxPartyNew)
          switched.push(idxBattler)
        elsif trainerBattle? || $game_switches[95]   # Player switches in in a trainer battle or boss battle
          idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
          pbRecallAndReplace(idxBattler,idxPlayerPartyNew)
          switched.push(idxBattler)
        else   # Player's Pokémon has fainted in a wild battle
          pbDisplay(_INTL("The wild Pokémon loses its respect for you and flees!"))
		  @decision = 1
		  return
        end
      end
      break if switched.length==0
      pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if switched.include?(b.index)
      end
    end
  end
end

class Game_Character
	def move_speed=(val)
		if $PokemonGlobal && $PokemonGlobal.surfing
		  val = 5
		end
		return if val==@move_speed
		@move_speed = val
		# @move_speed_real is the number of quarter-pixels to move each frame. There
		# are 128 quarter-pixels per tile. By default, it is calculated from
		# @move_speed and has these values (assuming 40 fps):
		# 1 => 3.2    # 40 frames per tile
		# 2 => 6.4    # 20 frames per tile
		# 3 => 12.8   # 10 frames per tile - walking speed
		# 4 => 25.6   # 5 frames per tile - running speed (2x walking speed)
		# 5 => 32     # 4 frames per tile - cycling speed (1.25x running speed)
		# 6 => 64     # 2 frames per tile
		self.move_speed_real = (val == 6) ? 64 : (val == 5) ? 32 : (2 ** (val + 1)) * 0.8
	  end
end

class Game_Map
	def playerPassable?(x, y, d, self_event = nil)
		bit = (1 << (d / 2 - 1)) & 0x0f
		for i in [2, 1, 0]
		  tile_id = data[x, y, i]
		  terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
		  passage = @passages[tile_id]
		  if terrain
			# Ignore bridge tiles if not on a bridge
			next if terrain.bridge && $PokemonGlobal.bridge == 0
			# Make water tiles passable if player is surfing or has the surfboard
			#echo("#{$PokemonBag.pbHasItem?(:SURFBOARD)}, #{errain.can_surf}, #{terrain.waterfall}\n")
			return true if terrain.can_surf && !terrain.waterfall && ($PokemonGlobal.surfing || $PokemonBag.pbHasItem?(:SURFBOARD))
			# Prevent cycling in really tall grass/on ice
			return false if $PokemonGlobal.bicycle && terrain.must_walk
			# Depend on passability of bridge tile if on bridge
			if terrain.bridge && $PokemonGlobal.bridge > 0
			  return (passage & bit == 0 && passage & 0x0f != 0x0f)
			end
		  end
		  # Regular passability checks
		  if !terrain || !terrain.ignore_passability
			return false if passage & bit != 0 || passage & 0x0f == 0x0f
			return true if @priorities[tile_id] == 0
		  end
		end
		return true
	  end
end


Events.onStepTakenFieldMovement += proc { |_sender,e|
  event = e[0]   # Get the event affected by field movement
  if $scene.is_a?(Scene_Map)
    if event == $game_player
	  currentTag = $game_player.pbTerrainTag
      if currentTag.can_surf && !$PokemonGlobal.surfing && $PokemonGlobal.bridge == 0
		pbStartSurfing()
      end
    end
  end
}

class HallOfFame_Scene
	# Speed in pokémon movement in hall entry. Don't use less than 2!
	ANIMATIONSPEED = 24
	# Entry wait time (in 1/20 seconds) between showing each Pokémon (and trainer)
	ENTRYWAITTIME = 42
	
	attr_accessor :league


  def pbUpdateAnimation
    if @battlerIndex<=@hallEntry.size
      if @xmovement[@battlerIndex]!=0 || @ymovement[@battlerIndex]!=0
        spriteIndex=(@battlerIndex<@hallEntry.size) ? @battlerIndex : -1
        moveSprite(spriteIndex)
      else
        @battlerIndex+=1
        if @battlerIndex<=@hallEntry.size
          # If it is a pokémon, write the pokémon text, wait the
          # ENTRYWAITTIME and goes to the next battler
          GameData::Species.play_cry_from_pokemon(@hallEntry[@battlerIndex - 1])
          writePokemonData(@hallEntry[@battlerIndex-1])
          (ENTRYWAITTIME*Graphics.frame_rate/20).times do
            Graphics.update
            Input.update
            pbUpdate
          end
          if @battlerIndex<@hallEntry.size   # Preparates the next battler
            setPokemonSpritesOpacity(@battlerIndex,OPACITY)
            @sprites["overlay"].bitmap.clear
          else   # Show the welcome message and preparates the trainer
            setPokemonSpritesOpacity(-1)
            writeWelcome
            (ENTRYWAITTIME*2*Graphics.frame_rate/20).times do
              Graphics.update
              Input.update
              pbUpdate
            end
            setPokemonSpritesOpacity(-1,OPACITY) if !SINGLEROW
            createTrainerBattler
          end
        end
      end
    elsif @battlerIndex>@hallEntry.size
      # Write the trainer data and fade
      writeTrainerData if @league
      (ENTRYWAITTIME*Graphics.frame_rate/20).times do
        Graphics.update
        Input.update
        pbUpdate
      end
      fadeSpeed=((Math.log(2**12)-Math.log(FINALFADESPEED))/Math.log(2)).floor
      pbBGMFade((2**fadeSpeed).to_f/20) if @useMusic
      slowFadeOut(@sprites,fadeSpeed) { pbUpdate }
      @alreadyFadedInEnd=true
      @battlerIndex+=1
    end
  end
end


def pbHallOfFameEntry(league=true)
  scene=HallOfFame_Scene.new
  scene.league = league
  screen=HallOfFameScreen.new(scene)
  screen.pbStartScreenEntry
end


module PokeBattle_BattleCommon
	  #=============================================================================
  # Calculate how many shakes a thrown Poké Ball will make (4 = capture)
  #=============================================================================
  def pbCaptureCalc(pkmn,battler,catch_rate,ball)
    return 4 if $DEBUG && Input.press?(Input::CTRL)
    # Get a catch rate if one wasn't provided
    catch_rate = pkmn.species_data.catch_rate if !catch_rate
    # Modify catch_rate depending on the Poké Ball's effect
    ultraBeast = [:NIHILEGO, :BUZZWOLE, :PHEROMOSA, :XURKITREE, :CELESTEELA,
                  :KARTANA, :GUZZLORD, :POIPOLE, :NAGANADEL, :STAKATAKA,
                  :BLACEPHALON].include?(pkmn.species)
    if !ultraBeast || ball == :BEASTBALL
      catch_rate = BallHandlers.modifyCatchRate(ball,catch_rate,self,battler,ultraBeast)
    else
      catch_rate /= 10
    end
    # First half of the shakes calculation
    a = battler.totalhp
    b = battler.hp
    x = ((3*a-2*b)*catch_rate.to_f)/(3*a)
    # Calculation modifiers
    if battler.status == :SLEEP
      x *= 2.5
    elsif battler.status != :NONE
      x *= 1.5
    end
    x = x.floor
    x = 1 if x<1
    # Definite capture, no need to perform randomness checks
    return 4 if x>=255 || BallHandlers.isUnconditional?(ball,self,battler)
    # Second half of the shakes calculation
    y = ( 65536 / ((255.0/x)**0.1875) ).floor
    # Critical capture check
    if Settings::ENABLE_CRITICAL_CAPTURES
      c = 0
      numOwned = $Trainer.pokedex.owned_count
      if numOwned>600;    c = x*5/12
      elsif numOwned>450; c = x*4/12
      elsif numOwned>300; c = x*3/12
      elsif numOwned>150; c = x*2/12
      elsif numOwned>30;  c = x/12
      end
      # Calculate the number of shakes
      if c>0 && pbRandom(256)<c
        @criticalCapture = true
        return 4 if pbRandom(65536)<y
        return 0
      end
    end
    # Calculate the number of shakes
    numShakes = 0
    for i in 0...4
      break if numShakes<i
      numShakes += 1 if pbRandom(65536)<y
    end
    return numShakes
  end
end

class PokemonPartyPanel < SpriteWrapper

  def initialize(pokemon,index,viewport=nil)
    super(viewport)
    @pokemon = pokemon
    @active = (index==0)   # true = rounded panel, false = rectangular panel
    @refreshing = true
    self.x = (index % 2) * Graphics.width / 2
    self.y = 16 * (index % 2) + 96 * (index / 2)
    @panelbgsprite = ChangelingSprite.new(0,0,viewport)
    @panelbgsprite.z = self.z
    if @active   # Rounded panel
      @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/panel_round")
      @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/panel_round_sel")
      @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/panel_round_faint")
      @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/panel_round_faint_sel")
      @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/panel_round_swap")
      @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/panel_round_swap_sel")
      @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/panel_round_swap_sel2")
    else   # Rectangular panel
      @panelbgsprite.addBitmap("able","Graphics/Pictures/Party/panel_rect")
      @panelbgsprite.addBitmap("ablesel","Graphics/Pictures/Party/panel_rect_sel")
      @panelbgsprite.addBitmap("fainted","Graphics/Pictures/Party/panel_rect_faint")
      @panelbgsprite.addBitmap("faintedsel","Graphics/Pictures/Party/panel_rect_faint_sel")
      @panelbgsprite.addBitmap("swap","Graphics/Pictures/Party/panel_rect_swap")
      @panelbgsprite.addBitmap("swapsel","Graphics/Pictures/Party/panel_rect_swap_sel")
      @panelbgsprite.addBitmap("swapsel2","Graphics/Pictures/Party/panel_rect_swap_sel2")
    end
    @hpbgsprite = ChangelingSprite.new(0,0,viewport)
    @hpbgsprite.z = self.z+1
    @hpbgsprite.addBitmap("able","Graphics/Pictures/Party/overlay_hp_back")
    @hpbgsprite.addBitmap("fainted","Graphics/Pictures/Party/overlay_hp_back_faint")
    @hpbgsprite.addBitmap("swap","Graphics/Pictures/Party/overlay_hp_back_swap")
    @ballsprite = ChangelingSprite.new(0,0,viewport)
    @ballsprite.z = self.z+1
    @ballsprite.addBitmap("desel","Graphics/Pictures/Party/icon_ball")
    @ballsprite.addBitmap("sel","Graphics/Pictures/Party/icon_ball_sel")
    @pkmnsprite = PokemonIconSprite.new(pokemon,viewport)
    @pkmnsprite.setOffset(PictureOrigin::Center)
    @pkmnsprite.active = @active
    @pkmnsprite.z      = self.z+2
    @helditemsprite = HeldItemIconSprite.new(0,0,@pokemon,viewport)
    @helditemsprite.z = self.z+3
    @overlaysprite = BitmapSprite.new(Graphics.width,Graphics.height,viewport)
    @overlaysprite.z = self.z+4
    @hpbar    = AnimatedBitmap.new("Graphics/Pictures/Party/overlay_hp")
    @statuses = AnimatedBitmap.new(_INTL("Graphics/Pictures/Rework/statuses"))
    @selected      = false
    @preselected   = false
    @switching     = false
    @text          = nil
    @refreshBitmap = true
    @refreshing    = false
    refresh
  end
  
    def refresh
    return if disposed?
    return if @refreshing
    @refreshing = true
    if @panelbgsprite && !@panelbgsprite.disposed?
      if self.selected
        if self.preselected;     @panelbgsprite.changeBitmap("swapsel2")
        elsif @switching;        @panelbgsprite.changeBitmap("swapsel")
        elsif @pokemon.fainted?; @panelbgsprite.changeBitmap("faintedsel")
        else;                    @panelbgsprite.changeBitmap("ablesel")
        end
      else
        if self.preselected;     @panelbgsprite.changeBitmap("swap")
        elsif @pokemon.fainted?; @panelbgsprite.changeBitmap("fainted")
        else;                    @panelbgsprite.changeBitmap("able")
        end
      end
      @panelbgsprite.x     = self.x
      @panelbgsprite.y     = self.y
      @panelbgsprite.color = self.color
    end
    if @hpbgsprite && !@hpbgsprite.disposed?
      @hpbgsprite.visible = (!@pokemon.egg? && !(@text && @text.length>0))
      if @hpbgsprite.visible
        if self.preselected || (self.selected && @switching); @hpbgsprite.changeBitmap("swap")
        elsif @pokemon.fainted?;                              @hpbgsprite.changeBitmap("fainted")
        else;                                                 @hpbgsprite.changeBitmap("able")
        end
        @hpbgsprite.x     = self.x+96
        @hpbgsprite.y     = self.y+50
        @hpbgsprite.color = self.color
      end
    end
    if @ballsprite && !@ballsprite.disposed?
      @ballsprite.changeBitmap((self.selected) ? "sel" : "desel")
      @ballsprite.x     = self.x+10
      @ballsprite.y     = self.y
      @ballsprite.color = self.color
    end
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.x        = self.x+60
      @pkmnsprite.y        = self.y+40
      @pkmnsprite.color    = self.color
      @pkmnsprite.selected = self.selected
    end
    if @helditemsprite && !@helditemsprite.disposed?
      if @helditemsprite.visible
        @helditemsprite.x     = self.x+62
        @helditemsprite.y     = self.y+48
        @helditemsprite.color = self.color
      end
    end
    if @overlaysprite && !@overlaysprite.disposed?
      @overlaysprite.x     = self.x
      @overlaysprite.y     = self.y
      @overlaysprite.color = self.color
    end
    if @refreshBitmap
      @refreshBitmap = false
      @overlaysprite.bitmap.clear if @overlaysprite.bitmap
      basecolor   = Color.new(248,248,248)
      shadowcolor = Color.new(40,40,40)
      pbSetSystemFont(@overlaysprite.bitmap)
      textpos = []
      # Draw Pokémon name
      textpos.push([@pokemon.name,96,10,0,basecolor,shadowcolor])
      if !@pokemon.egg?
        if !@text || @text.length==0
          # Draw HP numbers
          textpos.push([sprintf("% 3d /% 3d",@pokemon.hp,@pokemon.totalhp),224,54,1,basecolor,shadowcolor])
          # Draw HP bar
          if @pokemon.hp>0
            w = @pokemon.hp*96*1.0/@pokemon.totalhp
            w = 1 if w<1
            w = ((w/2).round)*2
            hpzone = 0
            hpzone = 1 if @pokemon.hp<=(@pokemon.totalhp/2).floor
            hpzone = 2 if @pokemon.hp<=(@pokemon.totalhp/4).floor
            hprect = Rect.new(0,hpzone*8,w,8)
            @overlaysprite.bitmap.blt(128,52,@hpbar.bitmap,hprect)
          end
          # Draw status
          status = 0
          if @pokemon.fainted?
            status = GameData::Status::DATA.keys.length / 2
          elsif @pokemon.status != :NONE
            status = GameData::Status.get(@pokemon.status).id_number
			status = 8 if @pokemon.status==:POISON && @pokemon.statusCount>0
          elsif @pokemon.pokerusStage == 1
            status = GameData::Status::DATA.keys.length / 2 + 1
          end
          status -= 1
          if status >= 0
            statusrect = Rect.new(0,16*status,44,16)
            @overlaysprite.bitmap.blt(78,68,@statuses.bitmap,statusrect)
          end
        end
        # Draw gender symbol
        if @pokemon.male?
          textpos.push([_INTL("♂"),224,10,0,Color.new(0,112,248),Color.new(120,184,232)])
        elsif @pokemon.female?
          textpos.push([_INTL("♀"),224,10,0,Color.new(232,32,16),Color.new(248,168,184)])
        end
        # Draw shiny icon
        if @pokemon.shiny?
          pbDrawImagePositions(@overlaysprite.bitmap,[[
             "Graphics/Pictures/shiny",80,48,0,0,16,16]])
        end
      end
      pbDrawTextPositions(@overlaysprite.bitmap,textpos)
      # Draw level text
      if !@pokemon.egg?
        pbDrawImagePositions(@overlaysprite.bitmap,[[
           "Graphics/Pictures/Party/overlay_lv",20,70,0,0,22,14]])
        pbSetSmallFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,[
           [@pokemon.level.to_s,42,57,0,basecolor,shadowcolor]
        ])
      end
      # Draw annotation text
      if @text && @text.length>0
        pbSetSystemFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,[
           [@text,96,52,0,basecolor,shadowcolor]
        ])
      end
    end
    @refreshing = false
  end
end

class PokemonSummary_Scene
	def drawPage(page)
    if @pokemon.egg?
      drawPageOneEgg
      return
    end
    @sprites["itemicon"].item = @pokemon.item_id
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    # Set background image
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_#{page}")
    imagepos=[]
    # Show the Poké Ball containing the Pokémon
    ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
    if !pbResolveBitmap(ballimage)
      ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%02d", pbGetBallType(@pokemon.poke_ball))
    end
    imagepos.push([ballimage,14,60])
    # Show status/fainted/Pokérus infected icon
    status = 0
    if @pokemon.fainted?
      status = GameData::Status::DATA.keys.length / 2
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).id_number
	  status = 8 if @pokemon.status==:POISON && @pokemon.statusCount>0
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status::DATA.keys.length / 2 + 1
    end
    status -= 1
    if status >= 0
      imagepos.push(["Graphics/Pictures/Rework/statuses",124,100,0,16*status,44,16])
    end
    # Show Pokérus cured icon
    if @pokemon.pokerusStage==2
      imagepos.push([sprintf("Graphics/Pictures/Summary/icon_pokerus"),176,100])
    end
    # Show shininess star
    if @pokemon.shiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,134])
    end
    # Draw all images
    pbDrawImagePositions(overlay,imagepos)
    # Write various bits of text
    pagename = [_INTL("INFO"),
                _INTL("TRAINER MEMO"),
                _INTL("SKILLS"),
                _INTL("MOVES"),
                _INTL("RIBBONS")][page-1]
    textpos = [
       [pagename,26,10,0,base,shadow],
       [@pokemon.name,46,56,0,base,shadow],
       [@pokemon.level.to_s,46,86,0,Color.new(64,64,64),Color.new(176,176,176)],
       [_INTL("Item"),66,312,0,base,shadow]
    ]
    # Write the held item's name
    if @pokemon.hasItem?
      textpos.push([@pokemon.item.name,16,346,0,Color.new(64,64,64),Color.new(176,176,176)])
    else
      textpos.push([_INTL("None"),16,346,0,Color.new(192,200,208),Color.new(208,216,224)])
    end
    # Write the gender symbol
    if @pokemon.male?
      textpos.push([_INTL("♂"),178,56,0,Color.new(24,112,216),Color.new(136,168,208)])
    elsif @pokemon.female?
      textpos.push([_INTL("♀"),178,56,0,Color.new(248,56,32),Color.new(224,152,144)])
    end
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    # Draw the Pokémon's markings
    drawMarkings(overlay,84,292)
    # Draw page-specific information
    case page
    when 1 then drawPageOne
    when 2 then drawPageTwo
    when 3 then drawPageThree
    when 4 then drawPageFour
    when 5 then drawPageFive
    end
  end
end


def pbPickBerry(berry, qty = 1)
  interp=pbMapInterpreter
  thisEvent=interp.get_character(0)
  berryData=interp.getVariable
  berry=GameData::Item.get(berry)
  itemname=(qty>1) ? berry.name_plural : berry.name
  if qty>1
    message=_INTL("There are {1} \\c[1]{2}\\c[0]!\nWant to pick them?",qty,itemname)
  else
    message=_INTL("There is 1 \\c[1]{1}\\c[0]!\nWant to pick it?",itemname)
  end
  if pbConfirmMessage(message)
    if !$PokemonBag.pbCanStore?(berry,qty)
      pbMessage(_INTL("Too bad...\nThe Bag is full..."))
      return
    end
    $PokemonBag.pbStoreItem(berry,qty)
    if qty>1
      pbMessage(_INTL("You picked the {1} \\c[1]{2}\\c[0].\\wtnp[20]",qty,itemname))
    else
      pbMessage(_INTL("You picked the \\c[1]{1}\\c[0].\\wtnp[20]",itemname))
    end
    pocket = berry.pocket
    pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0] in the <icon=bagPocket{3}>\\c[1]{4}\\c[0] Pocket.\1",
       $Trainer.name,itemname,pocket,PokemonBag.pocketNames()[pocket]))
    if Settings::NEW_BERRY_PLANTS
      pbMessage(_INTL("The berry plant withered away."))
      berryData=[0,nil,0,0,0,0,0,0]
    else
      pbMessage(_INTL("The berry plant withered away."))
      berryData=[0,nil,false,0,0,0]
    end
    interp.setVariable(berryData)
    pbSetSelfSwitch(thisEvent.id,"A",true)
  end
end

def pbBattleAnimation(bgm=nil,battletype=0,foe=nil)
  $game_temp.in_battle = true
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  # Set up audio
  playingBGS = nil
  playingBGM = nil
  if $game_system && $game_system.is_a?(Game_System)
    playingBGS = $game_system.getPlayingBGS
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
  end
  pbMEFade(0.25)
  pbWait(Graphics.frame_rate/4)
  pbMEStop
  # Play battle music
  bgm = pbGetWildBattleBGM([]) if !bgm
  pbBGMPlay(bgm)
  # Take screenshot of game, for use in some animations
  $game_temp.background_bitmap.dispose if $game_temp.background_bitmap
  $game_temp.background_bitmap = Graphics.snap_to_bitmap
  # Check for custom battle intro animations
  handled = pbBattleAnimationOverride(viewport,battletype,foe)
  # Default battle intro animation
  if !handled
    # Determine which animation is played
    location = 0   # 0=outside, 1=inside, 2=cave, 3=water
    if $PokemonGlobal.surfing || $PokemonGlobal.diving
      location = 3
    elsif $PokemonTemp.encounterType &&
       GameData::EncounterType.get($PokemonTemp.encounterType).type == :fishing
      location = 3
    elsif $PokemonEncounters.has_cave_encounters?
      location = 2
    elsif !GameData::MapMetadata.exists?($game_map.map_id) ||
          !GameData::MapMetadata.get($game_map.map_id).outdoor_map
      location = 1
    end
    anim = ""
    if PBDayNight.isDay?
      case battletype
      when 0, 2   # Wild, double wild
        anim = ["SnakeSquares","DiagonalBubbleTL","DiagonalBubbleBR","RisingSplash"][location]
      when 1      # Trainer
        anim = ["TwoBallPass","ThreeBallDown","BallDown","WavyThreeBallUp"][location]
      when 3      # Double trainer
        anim = "FourBallBurst"
      end
    else
      case battletype
      when 0, 2   # Wild, double wild
        anim = ["SnakeSquares","DiagonalBubbleBR","DiagonalBubbleBR","RisingSplash"][location]
      when 1      # Trainer
        anim = ["SpinBallSplit","BallDown","BallDown","WavySpinBall"][location]
      when 3      # Double trainer
        anim = "FourBallBurst"
      end
    end
    # Initial screen flashing
    if location==2 || PBDayNight.isNight?
      viewport.color = Color.new(0,0,0)         # Fade to black a few times
    else
      viewport.color = Color.new(255,255,255)   # Fade to white a few times
    end
    halfFlashTime = Graphics.frame_rate*2/10   # 0.2 seconds, 8 frames
    alphaDiff = (255.0/halfFlashTime).ceil
    2.times do
      viewport.color.alpha = 0
      for i in 0...halfFlashTime*2
        if i<halfFlashTime; viewport.color.alpha += alphaDiff
        else;               viewport.color.alpha -= alphaDiff
        end
        Graphics.update
        pbUpdateSceneMap
      end
    end
    # Play main animation
    Graphics.freeze
    Graphics.transition(Graphics.frame_rate*1.0,sprintf("Graphics/Transitions/%s",anim))
    viewport.color = Color.new(0,0,0,255)   # Ensure screen is black
    # Slight pause after animation before starting up the battle scene
    (Graphics.frame_rate/10).times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  pbPushFade
  # Yield to the battle scene
  yield if block_given?
  # After the battle
  pbPopFade
  if $game_system && $game_system.is_a?(Game_System)
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
  end
  $PokemonGlobal.nextBattleBGM       = nil
  $PokemonGlobal.nextBattleME        = nil
  $PokemonGlobal.nextBattleCaptureME = nil
  $PokemonGlobal.nextBattleBack      = nil
  $PokemonEncounters.reset_step_count
  # Fade back to the overworld
  viewport.color = Color.new(0,0,0,255)
  numFrames = Graphics.frame_rate*4/10   # 0.4 seconds, 16 frames
  alphaDiff = (255.0/numFrames).ceil
  numFrames.times do
    viewport.color.alpha -= alphaDiff
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
  viewport.dispose
  $game_temp.in_battle = false
end

module MessageConfig
	def self.pbSettingToTextSpeed(speed)
		case speed
		when 0 then return 2
		when 1 then return 1
		when 2 then return -2
		when 3 then return -6
		end
    return TextSpeed || 1
  end
end

module PBDebug
	def self.log(msg)
    if $DEBUG
      echo("#{msg}\n")
	  if $INTERNAL
		@@log.push("#{msg}\r\n")
		PBDebug.flush
	  end
    end
  end
end

#===============================================================================
# Makes a Pokémon's ability bar appear
#===============================================================================
class AbilitySplashAppearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,side)
    @side = side
    super(sprites,viewport)
  end

  def createProcesses
    return if !@sprites["abilityBar_#{@side}"]
    bar = addSprite(@sprites["abilityBar_#{@side}"])
    bar.setVisible(0,true)
    dir = (@side==0) ? 1 : -1
	duration = $PokemonSystem.textspeed >= 2 ? 4 : 8
    bar.moveDelta(0,duration,dir*Graphics.width/2,0)
  end
end



#===============================================================================
# Makes a Pokémon's ability bar disappear
#===============================================================================
class AbilitySplashDisappearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,side)
    @side = side
    super(sprites,viewport)
  end

  def createProcesses
    return if !@sprites["abilityBar_#{@side}"]
    bar = addSprite(@sprites["abilityBar_#{@side}"])
    dir = (@side==0) ? -1 : 1
	duration = $PokemonSystem.textspeed >= 2 ? 4 : 8
    bar.moveDelta(0,duration,dir*Graphics.width/2,0)
    bar.setVisible(duration,false)
  end
end

class Game_System
	def se_play(se)
		se = RPG::AudioFile.new(se) if se.is_a?(String)
		if se!=nil && se.name!="" && FileTest.audio_exist?("Audio/SE/"+se.name)
		  vol = se.volume
		  vol *= $PokemonSystem.sevolume/100.0
		  vol = vol.to_i
		  Audio.se_play("Audio/SE/"+se.name,vol,se.pitch || 100)
		end
	  end
end

class Sprite_Character
	def update
    return if @character.is_a?(Game_Event) && !@character.should_update?
    super
    if @tile_id != @character.tile_id ||
       @character_name != @character.character_name ||
       @character_hue != @character.character_hue ||
       @oldbushdepth != @character.bush_depth
      @tile_id        = @character.tile_id
      @character_name = @character.character_name
      @character_hue  = @character.character_hue
      @oldbushdepth   = @character.bush_depth
      if @tile_id >= 384
        @charbitmap.dispose if @charbitmap
        @charbitmap = pbGetTileBitmap(@character.map.tileset_name, @tile_id,
                                      @character_hue, @character.width, @character.height)
        @charbitmapAnimated = false
        @bushbitmap.dispose if @bushbitmap
        @bushbitmap = nil
        @spriteoffset = false
        @cw = Game_Map::TILE_WIDTH * @character.width
        @ch = Game_Map::TILE_HEIGHT * @character.height
        self.src_rect.set(0, 0, @cw, @ch)
        self.ox = @cw / 2
        self.oy = @ch
        @character.sprite_size = [@cw, @ch]
      else
        @charbitmap.dispose if @charbitmap
		@charbitmap = AnimatedBitmap.new('Graphics/Characters/' + @character_name, @character_hue)
		if @character.is_a?(Game_Event)
			match = @character.name.match(/.*overworld\(([A-Za-z_0-9]+)\).*/i)
			if match && @character_name == "00Overworld Placeholder"
				@charbitmap = AnimatedBitmap.new('Graphics/Characters/Followers/' + match[1], @character_hue)
			end
		end
        RPG::Cache.retain('Graphics/Characters/', @character_name, @character_hue) if @character == $game_player
        @charbitmapAnimated = true
        @bushbitmap.dispose if @bushbitmap
        @bushbitmap = nil
        @spriteoffset = @character_name[/offset/i]
        @cw = @charbitmap.width / 4
        @ch = @charbitmap.height / 4
        self.ox = @cw / 2
        @character.sprite_size = [@cw, @ch]
      end
    end
    @charbitmap.update if @charbitmapAnimated
    bushdepth = @character.bush_depth
    if bushdepth == 0
      self.bitmap = (@charbitmapAnimated) ? @charbitmap.bitmap : @charbitmap
    else
      @bushbitmap = BushBitmap.new(@charbitmap, (@tile_id >= 384), bushdepth) if !@bushbitmap
      self.bitmap = @bushbitmap.bitmap
    end
    self.visible = !@character.transparent
    if @tile_id == 0
      sx = @character.pattern * @cw
      sy = ((@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
      self.oy = (@spriteoffset rescue false) ? @ch - 16 : @ch
      self.oy -= @character.bob_height
    end
    if self.visible
      if $PokemonSystem.tilemap == 0 ||
         (@character.is_a?(Game_Event) && @character.name[/regulartone/i])
        self.tone.set(0, 0, 0, 0)
      else
        pbDayNightTint(self)
      end
    end
    self.x          = @character.screen_x
    self.y          = @character.screen_y
    self.z          = @character.screen_z(@ch)
#    self.zoom_x     = Game_Map::TILE_WIDTH / 32.0
#    self.zoom_y     = Game_Map::TILE_HEIGHT / 32.0
    self.opacity    = @character.opacity
    self.blend_type = @character.blend_type
#    self.bush_depth = @character.bush_depth
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
    @reflection.update if @reflection
    @surfbase.update if @surfbase
  end
end

Events.onMapChange += proc { |_sender,e|
  old_map_ID = e[0] # previous map ID, 0 if no map ID
  
  if old_map_ID == 0 || old_map_ID == $game_map.map_id
    echo("Skipping off screen events check on this map because of some unknown error.\n")
    next
  end

  $game_switches[98] = true
  $game_switches[99] = true
}

class StorageSystemPC
	def name
		return _INTL("Pokémon Storage PC")
	end
end

class TrainerPC
	def name
		return _INTL("Item Storage PC")
	end
end