class PokeBattle_Scene
	#=============================================================================
	# Window displays
	#=============================================================================
	def pbShowWindow(windowType)
		# NOTE: If you are not using fancy graphics for the command/fight menus, you
		#       will need to make "messageBox" also visible if the windowtype if
		#       COMMAND_BOX/FIGHT_BOX respectively.
		@sprites["messageBox"].visible    = (windowType==MESSAGE_BOX)
		@sprites["messageWindow"].visible = (windowType==MESSAGE_BOX)
		@sprites["commandWindow"].visible = (windowType==COMMAND_BOX)
		@sprites["fightWindow"].visible   = (windowType==FIGHT_BOX)
		@sprites["targetWindow"].visible  = (windowType==TARGET_BOX)
	end

	def pbDisplayConfirmMessageSerious(msg)
		return pbShowCommands(msg,[_INTL("No"),_INTL("Yes")],0)==1
	end

  def getDisplayBallCount(side)
    numBalls = PokeBattle_SceneConstants::NUM_BALLS
    if side == 0
      numBalls *= @battle.player.length
    else
      return 0 if @battle.wildBattle?
      numBalls *= @battle.opponent.length
    end
    echoln("The display ball count for side #{side} is #{numBalls}")
    return numBalls
  end

	def pbInitSprites
		@sprites = {}
		# The background image and each side's base graphic
		pbCreateBackdropSprites
		# Create message box graphic
		messageBox = pbAddSprite("messageBox",0,Graphics.height-96,
		   "Graphics/Pictures/Battle/overlay_message",@viewport)
		messageBox.z = 195
		# Create message window (displays the message)
		msgWindow = Window_AdvancedTextPokemon.newWithSize("",
		   16,Graphics.height-96+2,Graphics.width-32,96,@viewport)
		msgWindow.z              = 200
		msgWindow.opacity        = 0
		msgWindow.baseColor      = PokeBattle_SceneConstants::MESSAGE_BASE_COLOR
		msgWindow.shadowColor    = PokeBattle_SceneConstants::MESSAGE_SHADOW_COLOR
		msgWindow.letterbyletter = true
		@sprites["messageWindow"] = msgWindow
		# Create command window
		@sprites["commandWindow"] = CommandMenuDisplay.new(@viewport,200,@battle)
		# Create fight window
		@sprites["fightWindow"] = FightMenuDisplay.new(@viewport,200)
		# Create targeting window
		@sprites["targetWindow"] = TargetMenuDisplay.new(@viewport,200,@battle.sideSizes)
		pbShowWindow(MESSAGE_BOX)
		# The party lineup graphics (bar and balls) for both sides
		for side in 0...2
		  partyBar = pbAddSprite("partyBar_#{side}",0,0,
			 "Graphics/Pictures/Battle/overlay_lineup",@viewport)
		  partyBar.z       = 120
		  partyBar.mirror  = true if side==0   # Player's lineup bar only
		  partyBar.visible = false
		  for i in 0...getDisplayBallCount(side)
        ball = pbAddSprite("partyBall_#{side}_#{i}",0,0,nil,@viewport)
        ball.z       = 121
        ball.visible = false
		  end
		  # Ability splash bars
		  if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
			  @sprites["abilityBar_#{side}"] = AbilitySplashBar.new(side,@viewport)
		  end
		end
		# Player's and partner trainer's back sprite
		@battle.player.each_with_index do |p,i|
		  pbCreateTrainerBackSprite(i,p.trainer_type,@battle.player.length)
		end
		# Opposing trainer(s) sprites
		if @battle.trainerBattle?
		  @battle.opponent.each_with_index do |p,i|
			  pbCreateTrainerFrontSprite(i,p.trainer_type,@battle.opponent.length)
		  end
		end
		# Data boxes and Pokémon sprites
		@battle.battlers.each_with_index do |b,i|
		  next if !b
		  @sprites["dataBox_#{i}"] = PokemonDataBox.new(b,@battle.pbSideSize(i),@viewport)
		  pbCreatePokemonSprite(i)
      createAggroCursor(b,i)
		end
		# Wild battle, so set up the Pokémon sprite(s) accordingly
		if @battle.wildBattle?
		  @battle.pbParty(1).each_with_index do |pkmn,i|
			index = i*2+1
			pbChangePokemon(index,pkmn)
			pkmnSprite = @sprites["pokemon_#{index}"]
			pkmnSprite.tone    = Tone.new(-80,-80,-80)
			pkmnSprite.visible = true
		  end
		end
		
		weatherState = @battle.pbWeather
		areaUIpoint = Graphics.height/4
		indicator_Y = Graphics.height/3
		indicator_X = Graphics.width/30
  end

  def createAggroCursor(battler,index)
    cursor = AggroCursor.new(battler,@battle.pbSideSize(index),@viewport)
    @sprites["aggro_cursor_#{index}"] = cursor
    cursor.visible = false
  end

  def pbBeginCommandPhase
    @sprites["messageWindow"].text = ""
    setAggroCursorsOff()
  end

  def setAggroCursorsOff
    @battle.battlers.each_with_index do |b,i|
		  next if b.nil?
      if @sprites["aggro_cursor_#{i}"].nil?
        createAggroCursor(b,i)
      end
      @sprites["aggro_cursor_#{i}"].visible = false
		end
  end

  def setAggroCursorOnIndex(index,extraAggro = false)
    @sprites["aggro_cursor_#{index}"].visible = true
    @sprites["aggro_cursor_#{index}"].extraAggro = extraAggro
  end
	
	def pbChangePokemon(idxBattler,pkmn)
		idxBattler = idxBattler.index if idxBattler.respond_to?("index")
		pkmnSprite   = @sprites["pokemon_#{idxBattler}"]
		shadowSprite = @sprites["shadow_#{idxBattler}"]
		back = !@battle.opposes?(idxBattler)
		pkmnSprite.setPokemonBitmap(pkmn,back)
		shadowSprite.setPokemonBitmap(pkmn)
		# Set visibility of battler's shadow
		shadowSprite.visible = pkmn.species_data.shows_shadow? if shadowSprite && !back
		shadowSprite.visible = false if pkmn.boss
  end

  #=============================================================================
  # The player chooses a main command for a Pokémon
  # Return values: -1=Cancel, 0=Fight, 1=Bag, 2=Pokémon, 3=Run, 4=Call
  #=============================================================================
  def pbCommandMenu(idxBattler,firstAction)
    shadowTrainer = (GameData::Type.exists?(:SHADOW) && @battle.trainerBattle?)
    cmds = [
       _INTL("",@battle.battlers[idxBattler].name),
       _INTL("Fight"),
       _INTL("Dex"),
	   _INTL("Ball"),
       _INTL("Pokémon"),
	   _INTL("Info"),
       (shadowTrainer) ? _INTL("Call") : (firstAction) ? _INTL("Run") : _INTL("Cancel"),
    ]
    wildBattle = !@battle.trainerBattle? && !@battle.bossBattle?
    mode = 0
    if shadowTrainer
      mode = 2
    elsif firstAction
      if !wildBattle
        mode = 5
      else
        mode = 0
      end
    else
      mode = 1
    end
    ret = pbCommandMenuEx(idxBattler,cmds,mode,wildBattle)
    ret = -1 if ret==5 && !firstAction   # Convert "Run" to "Cancel"
    return ret
  end
  
  # Mode: 0 = regular battle with "Run" (first choosable action in the round only)
  #       1 = regular battle with "Cancel"
  #       2 = regular battle with "Call" (for Shadow Pokémon battles)
  #       3 = Safari Zone
  #       4 = Bug Catching Contest
  #       5 = regular battle with "Forfeit" and "Info"
  def pbCommandMenuEx(idxBattler,texts,mode=0,wildbattle = false)
    pbShowWindow(COMMAND_BOX)
    cw = @sprites["commandWindow"]
    cw.setTexts(texts)
    initIndex = @lastCmd[idxBattler]
    initIndex = 0 if @lastCmd[idxBattler] == 3
    cw.setIndexAndMode(initIndex,mode)
    pbSelectBattler(idxBattler)
    hasPokeballs = $PokemonBag.pockets()[3].any?{|itemrecord| itemrecord[1] > 0}
	  onlyOneOpponent = @battle.pbOpposingBattlerCount == 1
    ret = -1
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if cw.index > 0
      elsif Input.trigger?(Input::RIGHT)
        cw.index += 1 if cw.index < 5
      elsif Input.trigger?(Input::UP)
        cw.index -= 3 if cw.index >= 3
      elsif Input.trigger?(Input::DOWN)
        cw.index += 3 if cw.index < 3
      end
      pbPlayCursorSE if cw.index!=oldIndex
      # Actions
      if Input.trigger?(Input::C)                 # Confirm choice
        pbPlayDecisionSE
        ret = cw.index
        @lastCmd[idxBattler] = ret
        break
      elsif Input.trigger?(Input::B) && mode==1   # Cancel
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::F9) && $DEBUG    # Debug menu
        pbPlayDecisionSE
        ret = -2
        break
	  elsif Input.pressex?(:NUMBER_1)
		pbPlayDecisionSE
        ret = 0
        @lastCmd[idxBattler] = 0
        break
	  elsif Input.pressex?(:NUMBER_2)
		pbPlayDecisionSE
        ret = 1
        @lastCmd[idxBattler] = 1
        break
	  elsif Input.pressex?(:NUMBER_3)
		pbPlayDecisionSE
        ret = 2
        @lastCmd[idxBattler] = 2
        break
	  elsif Input.pressex?(:NUMBER_4)
		pbPlayDecisionSE
        ret = 3
        @lastCmd[idxBattler] = 3
        break
	  elsif Input.pressex?(:NUMBER_5)
		pbPlayDecisionSE
        ret = 4
        @lastCmd[idxBattler] = 4
        break
	  elsif Input.pressex?(:NUMBER_6)
		pbPlayDecisionSE
        ret = 5
        @lastCmd[idxBattler] = 5
        break
      end
    end
    return ret
  end
  
  #=============================================================================
  # The player chooses a move for a Pokémon to use
  #=============================================================================
  def pbFightMenu(idxBattler,megaEvoPossible=false)
    battler = @battle.battlers[idxBattler]
    cw = @sprites["fightWindow"]
    cw.battler = battler
    moveIndex = 0
    if battler.moves[@lastMove[idxBattler]] && battler.moves[@lastMove[idxBattler]].id
      moveIndex = @lastMove[idxBattler]
    end
    cw.shiftMode = (@battle.pbCanShift?(idxBattler)) ? 1 : 0
    cw.setIndexAndMode(moveIndex,(megaEvoPossible) ? 1 : 0)
    needFullRefresh = true
    needRefresh = false
    loop do
      # Refresh view if necessary
      if needFullRefresh
        pbShowWindow(FIGHT_BOX)
        pbSelectBattler(idxBattler)
        needFullRefresh = false
      end
      if needRefresh
        if megaEvoPossible
          newMode = (@battle.pbRegisteredMegaEvolution?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        needRefresh = false
      end
      oldIndex = cw.index
      # General update
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index&1)==1
      elsif Input.trigger?(Input::RIGHT)
        if battler.moves[cw.index+1] && battler.moves[cw.index+1].id
          cw.index += 1 if (cw.index&1)==0
        end
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index&2)==2
      elsif Input.trigger?(Input::DOWN)
        if battler.moves[cw.index+2] && battler.moves[cw.index+2].id
          cw.index += 2 if (cw.index&2)==0
        end
      end
      pbPlayCursorSE if cw.index!=oldIndex
      # Actions
      if Input.trigger?(Input::USE)      # Confirm choice
        pbPlayDecisionSE
        break if yield cw.index
        needFullRefresh = true
        needRefresh = true
      elsif Input.trigger?(Input::BACK)   # Cancel fight menu
        pbPlayCancelSE
        break if yield -1
        needRefresh = true
      elsif Input.trigger?(Input::ACTION)   # Toggle Extra Move Info
        pbPlayDecisionSE
		    cw.toggleExtraInfo()
        needRefresh = true
      elsif Input.trigger?(Input::SPECIAL)   # Shift
        if cw.shiftMode>0
          pbPlayDecisionSE
          break if yield -3
          needRefresh = true
        end
      end
    end
    @lastMove[idxBattler] = cw.index
  end
  
  def pbBattleInfoMenu
	# Create targeting window
	cw = BattleInfoDisplay.new(@viewport,300,@battle)
	totalBattlers = @battle.pbSideBattlerCount + @battle.pbOpposingBattlerCount
	doRefresh = false
    loop do
      pbUpdate(cw)
      cw.refresh
      Graphics.update
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::UP) && cw.individual.nil?
        cw.selected -= 1
        if (cw.selected < 0)
          cw.selected = totalBattlers - 1
        end
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN) && cw.individual.nil?
        cw.selected += 1
        if (cw.selected >= totalBattlers)
          cw.selected = 0
        end
        pbPlayCursorSE
      elsif Input.trigger?(Input::SPECIAL) && cw.individual.nil? && $DEBUG
        #truthifyAllEffects()
        
        @battle.battlers[0].effects[PBEffects::Illusion] = false
        @battle.battlers[0].effects[PBEffects::ProtectRate] = false
        pbPlayDecisionSE
      elsif Input.trigger?(Input::USE)
        battler = nil
        index = 0
        selectedBattler = nil
        @battle.eachSameSideBattler do |b|
          if index == cw.selected
            selectedBattler = b
            pbPlayDecisionSE
            break;
          end
          index += 1
        end
        if !selectedBattler
          @battle.eachOtherSideBattler do |b|
            if index == cw.selected
              selectedBattler = b
              pbPlayDecisionSE
              break;
            end
            index += 1
          end
        end
        if selectedBattler
          cw.individual = selectedBattler
          pbIndividualBattlerInfoMenu(cw)
        end
      end
    end
	  cw.dispose
  end

  def truthifyAllEffects
    for effect in 0..30 do
      @battle.positions[0].effects[effect] = true
    end
    for effect in 0..150 do
      @battle.battlers[0].effects[effect] = true
    end
  end
  
  def pbIndividualBattlerInfoMenu(display)
    display.refresh
    loop do
	  pbUpdate(display)
	  display.refresh
	  Graphics.update
      if Input.trigger?(Input::B)
        display.individual = nil
		break
	  end
    end
  end
  
  # Returns the initial position of the cursor when choosing a target for a move
  # in a non-single battle.
  def pbFirstTarget(idxBattler,target_data)
    case target_data.id
    when :NearAlly
      @battle.eachSameSideBattler(idxBattler) do |b|
        next if b.index==idxBattler || !@battle.nearBattlers?(b,idxBattler)
        next if b.fainted?
        return b.index
      end
      @battle.eachSameSideBattler(idxBattler) do |b|
        next if b.index==idxBattler || !@battle.nearBattlers?(b,idxBattler)
        return b.index
      end
    when :NearFoe, :NearOther
      indices = @battle.pbGetOpposingIndicesInOrder(idxBattler)
      indices.each { |i| return i if @battle.nearBattlers?(i,idxBattler) && !@battle.battlers[i].fainted? }
      indices.each { |i| return i if @battle.nearBattlers?(i,idxBattler) }
    when :Foe, :Other, :UserOrOther
      indices = @battle.pbGetOpposingIndicesInOrder(idxBattler)
      indices.each { |i| return i if !@battle.battlers[i].fainted? }
      indices.each { |i| return i }
    end
    return idxBattler   # Target the user initially
  end
  
   def pbChooseTarget(idxBattler,target_data,visibleSprites=nil,dexSelect=false)
    pbShowWindow(TARGET_BOX)
    cw = @sprites["targetWindow"]
	cw.dexSelect = dexSelect
    # Create an array of battler names (only valid targets are named)
    texts = pbCreateTargetTexts(idxBattler,target_data)
    # Determine mode based on target_data
    mode = (target_data.num_targets == 1) ? 0 : 1
    cw.setDetails(texts,mode)
    cw.index = pbFirstTarget(idxBattler,target_data)
    pbSelectBattler((mode==0) ? cw.index : texts,2)   # Select initial battler/data box
    pbFadeInAndShow(@sprites,visibleSprites) if visibleSprites
    ret = -1
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      # Update selected command
      if mode==0   # Choosing just one target, can change index
        if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
          inc = ((cw.index%2)==0) ? -2 : 2
          inc *= -1 if Input.trigger?(Input::RIGHT)
          indexLength = @battle.sideSizes[cw.index%2]*2
          newIndex = cw.index
          loop do
            newIndex += inc
            break if newIndex<0 || newIndex>=indexLength
            next if texts[newIndex].nil?
            cw.index = newIndex
            break
          end
        elsif (Input.trigger?(Input::UP) && (cw.index%2)==0) ||
              (Input.trigger?(Input::DOWN) && (cw.index%2)==1)
          tryIndex = @battle.pbGetOpposingIndicesInOrder(cw.index)
          tryIndex.each do |idxBattlerTry|
            next if texts[idxBattlerTry].nil?
            cw.index = idxBattlerTry
            break
          end
		elsif Input.trigger?(Input::ACTION) && dexSelect
			pbFadeOutIn {
				scene = PokemonPokedex_Scene.new
				screen = PokemonPokedexScreen.new(scene)
				screen.pbStartScreen
			}
        end
        if cw.index!=oldIndex
          pbPlayCursorSE
          pbSelectBattler(cw.index,2)   # Select the new battler/data box
        end
      end
      if Input.trigger?(Input::USE)   # Confirm
        ret = cw.index
        pbPlayDecisionSE
        break
      elsif Input.trigger?(Input::BACK)   # Cancel
        ret = -1
        pbPlayCancelSE
        break
      end
    end
    pbSelectBattler(-1)   # Deselect all battlers/data boxes
    return ret
  end

  #=============================================================================
  # Opens the Bag screen and chooses an item to use
  #=============================================================================
  def pbItemMenu(idxBattler,_firstAction)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Set Bag starting positions
    oldLastPocket = $PokemonBag.lastpocket
    oldChoices    = $PokemonBag.getAllChoices
    $PokemonBag.lastpocket = @bagLastPocket if @bagLastPocket!=nil
    $PokemonBag.setAllChoices(@bagChoices) if @bagChoices!=nil
    # Start Bag screen
    itemScene = PokemonBag_Scene.new
    itemScene.pbStartScene($PokemonBag,true,Proc.new { |item|
      useType = GameData::Item.get(item).battle_use
      next useType && useType>0
      },false)
    # Loop while in Bag screen
    wasTargeting = false
    loop do
      # Select an item
      itemSym = itemScene.pbChooseItem
      break if !itemSym
      # Choose a command for the selected item
      item = GameData::Item.get(itemSym)
      itemName = item.name
      useType = item.battle_use
      cmdUse = -1
	  cmdChance = -1
	  cmdCancel = -1
      commands = []
      commands[cmdUse = commands.length] = _INTL("Use") if useType && useType!=0
	  commands[cmdChance = commands.length] = _INTL("Chance") if item.pocket == 3
      commands[cmdCancel = commands.length] = _INTL("Cancel")
      command = itemScene.pbShowCommands(_INTL("{1} is selected.",itemName),commands)
	  if cmdChance > -1 && command == cmdChance # Show the chance of the selected Pokeball catching
		ballTarget = @battle.battlers[0].pbDirectOpposing(true)
		trueChance = @battle.captureChanceCalc(ballTarget.pokemon,ballTarget,nil,itemSym)
		chance = (trueChance*100/5).floor * 5
		chance = 100 if chance > 100
		case chance
		when 0
			pbMessage(_INTL("This ball has a very low chance to capture the wild Pokémon.",chance))
		when 100
			pbMessage(_INTL("This ball is guaranteed to capture the wild Pokémon!",chance))
		else
			pbMessage(_INTL("This ball has a close to {1}% chance of capturing the wild Pokémon.",chance))
		end
		next
	  end
	  next unless cmdUse > -1 && command==cmdUse
      # Use types:
      # 0 = not usable in battle
      # 1 = use on Pokémon (lots of items), consumed
      # 2 = use on Pokémon's move (Ethers), consumed
      # 3 = use on battler (X items, Persim Berry), consumed
      # 4 = use on opposing battler (Poké Balls), consumed
      # 5 = use no target (Poké Doll, Guard Spec., Launcher items), consumed
      # 6 = use on Pokémon (Blue Flute), not consumed
      # 7 = use on Pokémon's move, not consumed
      # 8 = use on battler (Red/Yellow Flutes), not consumed
      # 9 = use on opposing battler, not consumed
      # 10 = use no target (Poké Flute), not consumed
      case useType
      when 1, 2, 3, 6, 7, 8   # Use on Pokémon/Pokémon's move/battler
        # Auto-choose the Pokémon/battler whose action is being decided if they
        # are the only available Pokémon/battler to use the item on
        case useType
        when 1, 6   # Use on Pokémon
          if @battle.pbTeamLengthFromBattlerIndex(idxBattler)==1
            break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        when 3, 8   # Use on battler
          if @battle.pbPlayerBattlerCount==1
            break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        end
        # Fade out and hide Bag screen
        itemScene.pbFadeOutScene
        # Get player's party
        party    = @battle.pbParty(idxBattler)
        partyPos = @battle.pbPartyOrder(idxBattler)
        partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
        modParty = @battle.pbPlayerDisplayParty(idxBattler)
        # Start party screen
        pkmnScene = PokemonParty_Scene.new
        pkmnScreen = PokemonPartyScreen.new(pkmnScene,modParty)
        pkmnScreen.pbStartScene(_INTL("Use on which Pokémon?"),@battle.pbNumPositions(0,0))
        idxParty = -1
        # Loop while in party screen
        loop do
          # Select a Pokémon
          pkmnScene.pbSetHelpText(_INTL("Use on which Pokémon?"))
          idxParty = pkmnScreen.pbChoosePokemon
          break if idxParty<0
          idxPartyRet = -1
          partyPos.each_with_index do |pos,i|
            next if pos!=idxParty+partyStart
            idxPartyRet = i
            break
          end
          next if idxPartyRet<0
          pkmn = party[idxPartyRet]
          next if !pkmn || pkmn.egg?
          idxMove = -1
          if useType==2 || useType==7   # Use on Pokémon's move
            idxMove = pkmnScreen.pbChooseMove(pkmn,_INTL("Restore which move?"))
            next if idxMove<0
          end
          break if yield item.id, useType, idxPartyRet, idxMove, pkmnScene
        end
        pkmnScene.pbEndScene
        break if idxParty>=0
        # Cancelled choosing a Pokémon; show the Bag screen again
        itemScene.pbFadeInScene
      when 4, 9   # Use on opposing battler (Poké Balls)
        idxTarget = -1
        if @battle.pbOpposingBattlerCount(idxBattler)==1
          @battle.eachOtherSideBattler(idxBattler) { |b| idxTarget = b.index }
          break if yield item.id, useType, idxTarget, -1, itemScene
        else
          wasTargeting = true
          # Fade out and hide Bag screen
          itemScene.pbFadeOutScene
          # Fade in and show the battle screen, choosing a target
          tempVisibleSprites = visibleSprites.clone
          tempVisibleSprites["commandWindow"] = false
          tempVisibleSprites["targetWindow"]  = true
          idxTarget = pbChooseTarget(idxBattler,GameData::Target.get(:Foe),tempVisibleSprites)
          if idxTarget>=0
            break if yield item.id, useType, idxTarget, -1, self
          end
          # Target invalid/cancelled choosing a target; show the Bag screen again
          wasTargeting = false
          pbFadeOutAndHide(@sprites)
          itemScene.pbFadeInScene
        end
      when 5, 10   # Use with no target
        break if yield item.id, useType, idxBattler, -1, itemScene
      end
    end
    @bagLastPocket = $PokemonBag.lastpocket
    @bagChoices    = $PokemonBag.getAllChoices
    $PokemonBag.lastpocket = oldLastPocket
    $PokemonBag.setAllChoices(oldChoices)
    # Close Bag screen
    itemScene.pbEndScene
    # Fade back into battle screen (if not already showing it)
    pbFadeInAndShow(@sprites,visibleSprites) if !wasTargeting
  end
  
  def pbCreateBackdropSprites
    if GameData::MapMetadata.exists?($game_map.map_id) && GameData::MapMetadata.get($game_map.map_id).outdoor_map
      case @battle.time
      when 1 then time = "eve"
      when 2 then time = "night"
      end
    end
    # Put everything together into backdrop, bases and message bar filenames
    backdropFilename = @battle.backdrop
    baseFilename = @battle.backdrop
    baseFilename = sprintf("%s_%s",baseFilename,@battle.backdropBase) if @battle.backdropBase
    messageFilename = @battle.backdrop
    if time
      trialName = sprintf("%s_%s",backdropFilename,time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/"+trialName+"_bg"))
        backdropFilename = trialName
      end
      trialName = sprintf("%s_%s",baseFilename,time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/"+trialName+"_base0"))
        baseFilename = trialName
      end
      trialName = sprintf("%s_%s",messageFilename,time)
      if pbResolveBitmap(sprintf("Graphics/Battlebacks/"+trialName+"_message"))
        messageFilename = trialName
      end
    end
    if !pbResolveBitmap(sprintf("Graphics/Battlebacks/"+baseFilename+"_base0")) &&
       @battle.backdropBase
      baseFilename = @battle.backdropBase
      if time
        trialName = sprintf("%s_%s",baseFilename,time)
        if pbResolveBitmap(sprintf("Graphics/Battlebacks/"+trialName+"_base0"))
          baseFilename = trialName
        end
      end
    end
    # Finalise filenames
    battleBG   = "Graphics/Battlebacks/"+backdropFilename+"_bg"
    playerBase = "Graphics/Battlebacks/"+baseFilename+"_base0"
    enemyBase  = "Graphics/Battlebacks/"+baseFilename+"_base1"
    messageBG  = "Graphics/Battlebacks/"+messageFilename+"_message"
    # Apply graphics
    bg = pbAddSprite("battle_bg",0,0,battleBG,@viewport)
    bg.z = 0
    bg = pbAddSprite("battle_bg2",-Graphics.width,0,battleBG,@viewport)
    bg.z      = 0
    bg.mirror = true
    for side in 0...2
      baseX, baseY = PokeBattle_SceneConstants.pbBattlerPosition(side)
      base = pbAddSprite("base_#{side}",baseX,baseY,
         (side==0) ? playerBase : enemyBase,@viewport)
      base.z    = 1
      if base.bitmap
        base.ox = base.bitmap.width/2
        base.oy = (side==0) ? base.bitmap.height : base.bitmap.height/2
      end
      if @battle.bossBattle?
        if side != 0
          base.zoom_x *= 1.5
          base.zoom_y *= 1.5
        end
      end
    end
    cmdBarBG = pbAddSprite("cmdBar_bg",0,Graphics.height-96,messageBG,@viewport)
    cmdBarBG.z = 180
  end
end

module PokeBattle_SceneConstants
# Returns where the centre bottom of a battler's sprite should be, given its
  # index and the number of battlers on its side, assuming the battler has
  # metrics of 0 (those are added later).
  def self.pbBattlerPosition(index, sideSize = 1,boss = false)
    # Start at the centre of the base for the appropriate side
    if (index & 1) == 0
      ret = [PLAYER_BASE_X, PLAYER_BASE_Y]
    else
      ret = [FOE_BASE_X, FOE_BASE_Y]
    end
    # Shift depending on index (no shifting needed for sideSize of 1)
    xShift = 0
    yShift = 0
    case sideSize
    when 2
      xShift = [-48, 48, 32, -32][index]
      yShift = [  0,  0, 16, -16][index]
    when 3
      xShift = [-80, 80,  0,  0, 80, -80][index]
      yShift = [  0,  0,  8, -8, 16, -16][index]
    end
    if boss
      xShift *= 1.5
      yShift *= 1.5
      yShift += 20
    end
    ret[0] += xShift
    ret[1] += yShift

    return ret
  end
end
