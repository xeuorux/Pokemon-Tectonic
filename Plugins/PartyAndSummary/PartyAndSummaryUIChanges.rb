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

class PokemonSummary_Scene
	def pbStartScene(party,partyindex,inbattle=false)
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@party      = party
		@partyindex = partyindex
		@pokemon    = @party[@partyindex]
		@inbattle   = inbattle
		@page = 1
		@forget = false
		@typebitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
		@markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Summary/markings")
		@sprites = {}
		@sprites["background"] = IconSprite.new(0,0,@viewport)
		@sprites["pokemon"] = PokemonSprite.new(@viewport)
		@sprites["pokemon"].setOffset(PictureOrigin::Center)
		@sprites["pokemon"].x = 104
		@sprites["pokemon"].y = 206
		@sprites["pokemon"].setPokemonBitmap(@pokemon)
		@sprites["pokeicon"] = PokemonIconSprite.new(@pokemon,@viewport)
		@sprites["pokeicon"].setOffset(PictureOrigin::Center)
		@sprites["pokeicon"].x       = 46
		@sprites["pokeicon"].y       = 92
		@sprites["pokeicon"].visible = false
		@sprites["itemicon"] = ItemIconSprite.new(30,320,@pokemon.item_id,@viewport)
		@sprites["itemicon"].blankzero = true
		@sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		pbSetSystemFont(@sprites["overlay"].bitmap)
		@sprites["movepresel"] = MoveSelectionSprite.new(@viewport)
		@sprites["movepresel"].visible     = false
		@sprites["movepresel"].preselected = true
		@sprites["movesel"] = MoveSelectionSprite.new(@viewport)
		@sprites["movesel"].visible = false
		@sprites["ribbonpresel"] = RibbonSelectionSprite.new(@viewport)
		@sprites["ribbonpresel"].visible     = false
		@sprites["ribbonpresel"].preselected = true
		@sprites["ribbonsel"] = RibbonSelectionSprite.new(@viewport)
		@sprites["ribbonsel"].visible = false
		@sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow",8,28,40,2,@viewport)
		@sprites["uparrow"].x = 350
		@sprites["uparrow"].y = 56
		@sprites["uparrow"].play
		@sprites["uparrow"].visible = false
		@sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow",8,28,40,2,@viewport)
		@sprites["downarrow"].x = 350
		@sprites["downarrow"].y = 260
		@sprites["downarrow"].play
		@sprites["downarrow"].visible = false
		@sprites["markingbg"] = IconSprite.new(260,88,@viewport)
		@sprites["markingbg"].setBitmap("Graphics/Pictures/Summary/overlay_marking")
		@sprites["markingbg"].visible = false
		@sprites["markingoverlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@sprites["markingoverlay"].visible = false
		pbSetSystemFont(@sprites["markingoverlay"].bitmap)
		@sprites["markingsel"] = IconSprite.new(0,0,@viewport)
		@sprites["markingsel"].setBitmap("Graphics/Pictures/Summary/cursor_marking")
		@sprites["markingsel"].src_rect.height = @sprites["markingsel"].bitmap.height/2
		@sprites["markingsel"].visible = false
		@sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
		@sprites["messagebox"].viewport       = @viewport
		@sprites["messagebox"].visible        = false
		@sprites["messagebox"].letterbyletter = true
		pbBottomLeftLines(@sprites["messagebox"],2)
		drawPage(@page)
		pbFadeInAndShow(@sprites) { pbUpdate }
	end


	def pbStartForgetScene(party,partyindex,move_to_learn)
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@party      = party
		@partyindex = partyindex
		@pokemon    = @party[@partyindex]
		@page = 4
		@forget = true
		@typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
		@statsCursorBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Summary/Rework/cursor_stats"))
		@sprites = {}
		@sprites["background"] = IconSprite.new(0,0,@viewport)
		@sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		pbSetSystemFont(@sprites["overlay"].bitmap)
		@sprites["pokemon"] = PokemonSprite.new(@viewport)
		@sprites["pokemon"].setOffset(PictureOrigin::Center)
		@sprites["pokemon"].x = 104
		@sprites["pokemon"].y = 206
		@sprites["pokemon"].setPokemonBitmap(@pokemon)
		@sprites["pokeicon"] = PokemonIconSprite.new(@pokemon,@viewport)
		@sprites["pokeicon"].setOffset(PictureOrigin::Center)
		@sprites["pokeicon"].x       = 46
		@sprites["pokeicon"].y       = 92
		@sprites["pokeicon"].visible = false
		@sprites["itemicon"] = ItemIconSprite.new(30,320,@pokemon.item_id,@viewport)
		@sprites["itemicon"].blankzero = true
		@sprites["movesel"] = MoveSelectionSprite.new(@viewport,!move_to_learn.nil?)
		@sprites["movesel"].visible = false
		@sprites["movesel"].visible = true
		@sprites["movesel"].index   = 0
		@sprites["statsCursor"] = SpriteWrapper.new(@viewport)
		@sprites["statsCursor"].bitmap = @statsCursorBitmap.bitmap
		@sprites["statsCursor"].x = 44
		@sprites["statsCursor"].y = 64
		new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
		drawSelectedMove(new_move,@pokemon.moves[0])
		pbFadeInAndShow(@sprites)
	end
	
	def drawPageFour
		overlay = @sprites["overlay"].bitmap
		moveBase   = Color.new(64,64,64)
		moveShadow = Color.new(176,176,176)
		ppBase   = [moveBase,                # More than 1/2 of total PP
					Color.new(248,192,0),    # 1/2 of total PP or less
					Color.new(248,136,32),   # 1/4 of total PP or less
					Color.new(248,72,72)]    # Zero PP
		ppShadow = [moveShadow,             # More than 1/2 of total PP
					Color.new(144,104,0),   # 1/2 of total PP or less
					Color.new(144,72,24),   # 1/4 of total PP or less
					Color.new(136,48,48)]   # Zero PP
		@sprites["pokeicon"].visible = false
		@sprites["itemicon"].visible = true
		textpos  = []
		imagepos = []
		# Write move names, types and PP amounts for each known move
		yPos = 92
		for i in 0...Pokemon::MAX_MOVES
		  move=@pokemon.moves[i]
		  if move
			type_number = GameData::Type.get(move.type).id_number
			imagepos.push(["Graphics/Pictures/types", 248, yPos + 8, 0, type_number * 28, 64, 28])
			textpos.push([move.name,316,yPos,0,moveBase,moveShadow])
			if move.total_pp>0
			  textpos.push([_INTL("PP"),342,yPos+32,0,moveBase,moveShadow])
			  ppfraction = 0
			  if move.pp==0;                  ppfraction = 3
			  elsif move.pp*4<=move.total_pp; ppfraction = 2
			  elsif move.pp*2<=move.total_pp; ppfraction = 1
			  end
			  textpos.push([sprintf("%d/%d",move.pp,move.total_pp),460,yPos+32,1,ppBase[ppfraction],ppShadow[ppfraction]])
			end
		  else
			textpos.push(["-",316,yPos,0,moveBase,moveShadow])
			textpos.push(["--",442,yPos+32,1,moveBase,moveShadow])
		  end
		  yPos += 64
		end
		# Draw all text and images
		pbDrawTextPositions(overlay,textpos)
		pbDrawImagePositions(overlay,imagepos)
	end
	
  def drawPageFourSelecting(move_to_learn)
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    moveBase   = Color.new(64,64,64)
    moveShadow = Color.new(176,176,176)
    ppBase   = [moveBase,                # More than 1/2 of total PP
                Color.new(248,192,0),    # 1/2 of total PP or less
                Color.new(248,136,32),   # 1/4 of total PP or less
                Color.new(248,72,72)]    # Zero PP
    ppShadow = [moveShadow,             # More than 1/2 of total PP
                Color.new(144,104,0),   # 1/2 of total PP or less
                Color.new(144,72,24),   # 1/4 of total PP or less
                Color.new(136,48,48)]   # Zero PP
    # Set background image
    if move_to_learn
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_learnmove")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_movedetail")
    end
    # Write various bits of text
    textpos = [
       [_INTL("MOVES"),26,10,0,base,shadow],
       [_INTL("CATEGORY"),20,116,0,base,shadow],
       [_INTL("POWER"),20,148,0,base,shadow],
       [_INTL("ACCURACY"),20,180,0,base,shadow]
    ]
    imagepos = []
    # Write move names, types and PP amounts for each known move
    yPos = 92
    yPos -= 76 if move_to_learn
    limit = (move_to_learn) ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
    for i in 0...limit
      move = @pokemon.moves[i]
      if i==Pokemon::MAX_MOVES
        move = move_to_learn
        yPos += 20
      end
      if move
        type_number = GameData::Type.get(move.type).id_number
        imagepos.push(["Graphics/Pictures/types", 248, yPos + 8, 0, type_number * 28, 64, 28])
        textpos.push([move.name,316,yPos,0,moveBase,moveShadow])
        if move.total_pp>0
          textpos.push([_INTL("PP"),342,yPos+32,0,moveBase,moveShadow])
          ppfraction = 0
          if move.pp==0;                  ppfraction = 3
          elsif move.pp*4<=move.total_pp; ppfraction = 2
          elsif move.pp*2<=move.total_pp; ppfraction = 1
          end
          textpos.push([sprintf("%d/%d",move.pp,move.total_pp),460,yPos+32,1,ppBase[ppfraction],ppShadow[ppfraction]])
        end
      else
        textpos.push(["-",316,yPos,0,moveBase,moveShadow])
        textpos.push(["--",442,yPos+32,1,moveBase,moveShadow])
      end
      yPos += 64
    end
    # Draw all text and images
    pbDrawTextPositions(overlay,textpos)
    pbDrawImagePositions(overlay,imagepos)
	if !@forget
		# Draw Pokémon's type icon(s)
		type1_number = GameData::Type.get(@pokemon.type1).id_number
		type2_number = GameData::Type.get(@pokemon.type2).id_number
		type1rect = Rect.new(0, type1_number * 28, 64, 28)
		type2rect = Rect.new(0, type2_number * 28, 64, 28)
		if @pokemon.type1==@pokemon.type2
		  overlay.blt(130,78,@typebitmap.bitmap,type1rect)
		else
		  overlay.blt(96,78,@typebitmap.bitmap,type1rect)
		  overlay.blt(166,78,@typebitmap.bitmap,type2rect)
		end
	end
  end

  def drawSelectedMove(move_to_learn, selected_move)
    # Draw all of page four, except selected move's details
    drawPageFourSelecting(move_to_learn)
    # Set various values
    overlay = @sprites["overlay"].bitmap
    base = Color.new(64, 64, 64)
    shadow = Color.new(176, 176, 176)
    @sprites["pokemon"].visible = false if @sprites["pokemon"]
    @sprites["pokeicon"].pokemon = @pokemon
    @sprites["pokeicon"].visible = true
	@sprites["pokeicon"].visible = false if @forget
    @sprites["itemicon"].visible = false if @sprites["itemicon"]
    textpos = []
    # Write power and accuracy values for selected move
    case selected_move.base_damage
    when 0 then textpos.push(["---", 216, 148, 1, base, shadow])   # Status move
    when 1 then textpos.push(["???", 216, 148, 1, base, shadow])   # Variable power move
    else        textpos.push([selected_move.base_damage.to_s, 216, 148, 1, base, shadow])
    end
    if selected_move.accuracy == 0
      textpos.push(["---", 216, 180, 1, base, shadow])
    else
      textpos.push(["#{selected_move.accuracy}%", 216 + overlay.text_size("%").width, 180, 1, base, shadow])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw selected move's damage category icon
    imagepos = [["Graphics/Pictures/category", 166, 124, 0, selected_move.category * 28, 64, 28]]
    pbDrawImagePositions(overlay, imagepos)
    # Draw selected move's description
    drawTextEx(overlay, 4, 222, 230, 5, selected_move.description, base, shadow)
  end
	  
	def pbEndScene
		pbFadeOutAndHide(@sprites) { pbUpdate }
		pbDisposeSpriteHash(@sprites)
		@typebitmap.dispose
		@statsCursorBitmap.dispose if @statsCursorBitmap
		@markingbitmap.dispose if @markingbitmap
		@viewport.dispose
	end

	def pbChooseMoveToForget(move_to_learn)
		new_move = (move_to_learn) ? Pokemon::Move.new(move_to_learn) : nil
		selmove = 0
		maxmove = (new_move) ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
		@sprites["pokemon"].visible = true if !@forget
		@sprites["itemicon"].visible = false
		loop do
		  Graphics.update
		  Input.update
		  pbUpdate
		  if Input.trigger?(Input::BACK)
			selmove = Pokemon::MAX_MOVES
			pbPlayCloseMenuSE if new_move
			break
		  elsif Input.trigger?(Input::USE)
			pbPlayDecisionSE
			break
		  elsif Input.trigger?(Input::UP)
			selmove -= 1
			selmove = maxmove if selmove<0
			if selmove<Pokemon::MAX_MOVES && selmove>=@pokemon.numMoves
			  selmove = @pokemon.numMoves-1
			end
			@sprites["movesel"].index = selmove
			selected_move = (selmove==Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
			drawSelectedMove(new_move,selected_move)
		  elsif Input.trigger?(Input::DOWN)
			selmove += 1
			selmove = 0 if selmove>maxmove
			if selmove<Pokemon::MAX_MOVES && selmove>=@pokemon.numMoves
			  selmove = (new_move) ? maxmove : 0
			end
			@sprites["movesel"].index = selmove
			selected_move = (selmove==Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
			drawSelectedMove(new_move,selected_move)
		  elsif Input.trigger?(Input::ACTION)
			pbFadeOutIn {
				pbTemporaryStatsScreen()
				@sprites["movesel"].visible = false
				@sprites["itemicon"].visible = false
				@sprites["statsCursor"].visible = false
				@sprites["pokemon"].visible = true
			}
			loop do
				Graphics.update
				Input.update
				if Input.trigger?(Input::BACK)
					pbPlayCancelSE()
					break
				end
			end
			@sprites["movesel"].visible = true
			@sprites["itemicon"].visible = true
			@sprites["statsCursor"].visible = true
			@sprites["pokemon"].visible = false
			drawSelectedMove(new_move,@pokemon.moves[0])
			pbFadeInAndShow(@sprites)
		  end
		end
		return (selmove==Pokemon::MAX_MOVES) ? -1 : selmove
	end

	def pbTemporaryStatsScreen()
		@sprites["itemicon"].item = @pokemon.item_id
		overlay = @sprites["overlay"].bitmap
		overlay.clear
		base   = Color.new(248,248,248)
		shadow = Color.new(104,104,104)
		# Set background image
		@sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_3z")
		imagepos = []
		# Show the Poké Ball containing the Pokémon
		ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
		if !pbResolveBitmap(ballimage)
			ballimage = sprintf("Graphics/Pictures/Summary/icon_ball_%02d", pbGetBallType(@pokemon.poke_ball))
		end
		imagepos.push([ballimage,14,60])
		# Draw all images
		pbDrawImagePositions(overlay,imagepos)
		# Write various bits of text
		pagename = _INTL("SKILLS")
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
		# Draw page-specific information
		base   = Color.new(248,248,248)
		shadow = Color.new(104,104,104)
		# Write various bits of text
		textpos = [
		   [_INTL("HP"),292,70,2,base,shadow],
		   [sprintf("%d/%d",@pokemon.hp,@pokemon.totalhp),462,70,1,Color.new(64,64,64),Color.new(176,176,176)],
		   [_INTL("Attack"),248,114,0,base,shadow],
		   [sprintf("%d",@pokemon.attack),456,114,1,Color.new(64,64,64),Color.new(176,176,176)],
		   [_INTL("Defense"),248,146,0,base,shadow],
		   [sprintf("%d",@pokemon.defense),456,146,1,Color.new(64,64,64),Color.new(176,176,176)],
		   [_INTL("Sp. Atk"),248,178,0,base,shadow],
		   [sprintf("%d",@pokemon.spatk),456,178,1,Color.new(64,64,64),Color.new(176,176,176)],
		   [_INTL("Sp. Def"),248,210,0,base,shadow],
		   [sprintf("%d",@pokemon.spdef),456,210,1,Color.new(64,64,64),Color.new(176,176,176)],
		   [_INTL("Speed"),248,242,0,base,shadow],
		   [sprintf("%d",@pokemon.speed),456,242,1,Color.new(64,64,64),Color.new(176,176,176)],
		   [_INTL("Ability"),224,278,0,base,shadow]
		]
		# Draw ability name and description
		ability = @pokemon.ability
		if ability
		  textpos.push([ability.name,362,278,0,Color.new(64,64,64),Color.new(176,176,176)])
		  drawTextEx(overlay,224,320,282,2,ability.description,Color.new(64,64,64),Color.new(176,176,176))
		end
		# Draw Pokémon's type icon(s)
		type1_number = GameData::Type.get(@pokemon.type1).id_number
		type2_number = GameData::Type.get(@pokemon.type2).id_number
		type1rect = Rect.new(0, type1_number * 28, 64, 28)
		type2rect = Rect.new(0, type2_number * 28, 64, 28)
		if @pokemon.type1==@pokemon.type2
		  overlay.blt(310,18,@typebitmap.bitmap,type1rect)
		else
		  overlay.blt(276,18,@typebitmap.bitmap,type1rect)
		  overlay.blt(346,18,@typebitmap.bitmap,type2rect)
		end
		# Draw all text
		pbDrawTextPositions(overlay,textpos)
	end
end


class PokemonPartyScreen
	def pbPokemonScreen
    @scene.pbStartScene(@party,
       (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),nil)
    loop do
      @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid = @scene.pbChoosePokemon(false,-1,1)
      break if (pkmnid.is_a?(Numeric) && pkmnid<0) || (pkmnid.is_a?(Array) && pkmnid[1]<0)
      if pkmnid.is_a?(Array) && pkmnid[0]==1   # Switch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid[1]
        pkmnid = @scene.pbChoosePokemon(true,-1,2)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
        next
      end
      pkmn = @party[pkmnid]
      commands   = []
      cmdSummary = -1
      cmdDebug   = -1
      cmdMoves   = [-1] * pkmn.numMoves
      cmdSwitch  = -1
      cmdMail    = -1
      cmdItem    = -1
	  cmdRename  = -1
      cmdPokedex = -1
      # Build the commands
      commands[cmdSummary = commands.length]      = _INTL("Summary")
      commands[cmdDebug = commands.length]        = _INTL("Debug") if $DEBUG
      if !pkmn.egg?
        # Check for hidden moves and add any that were found
        pkmn.moves.each_with_index do |m, i|
          if [:MILKDRINK, :SOFTBOILED].include?(m.id) ||
             HiddenMoveHandlers.hasHandler(m.id)
            commands[cmdMoves[i] = commands.length] = [m.name, 1]
          end
        end
      end
      commands[cmdSwitch = commands.length]       = _INTL("Switch") if @party.length>1
      if !pkmn.egg?
		if $Trainer.has_pokedex
          commands[cmdPokedex = commands.length]  = _INTL("Pokédex")
        end
		if !pkmn.shadowPokemon? && !pkmn.foreign?($Trainer)
          commands[cmdRename = commands.length]   = _INTL("Rename")
        end
        if pkmn.mail
          commands[cmdMail = commands.length]     = _INTL("Mail")
        else
          commands[cmdItem = commands.length]     = _INTL("Item")
        end
      end
      commands[commands.length]                   = _INTL("Cancel")
      command = @scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands)
      havecommand = false
      cmdMoves.each_with_index do |cmd, i|
        next if cmd < 0 || cmd != command
        havecommand = true
        if [:MILKDRINK, :SOFTBOILED].include?(pkmn.moves[i].id)
          amt = [(pkmn.totalhp/5).floor,1].max
          if pkmn.hp<=amt
            pbDisplay(_INTL("Not enough HP..."))
            break
          end
          @scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
          oldpkmnid = pkmnid
          loop do
            @scene.pbPreSelect(oldpkmnid)
            pkmnid = @scene.pbChoosePokemon(true,pkmnid)
            break if pkmnid<0
            newpkmn = @party[pkmnid]
            movename = pkmn.moves[i].name
            if pkmnid==oldpkmnid
              pbDisplay(_INTL("{1} can't use {2} on itself!",pkmn.name,movename))
            elsif newpkmn.egg?
              pbDisplay(_INTL("{1} can't be used on an Egg!",movename))
            elsif newpkmn.hp==0 || newpkmn.hp==newpkmn.totalhp
              pbDisplay(_INTL("{1} can't be used on that Pokémon.",movename))
            else
              pkmn.hp -= amt
              hpgain = pbItemRestoreHP(newpkmn,amt)
              @scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",newpkmn.name,hpgain))
              pbRefresh
            end
            break if pkmn.hp<=amt
          end
          @scene.pbSelect(oldpkmnid)
          pbRefresh
          break
        elsif pbCanUseHiddenMove?(pkmn,pkmn.moves[i].id)
          if pbConfirmUseHiddenMove(pkmn,pkmn.moves[i].id)
            @scene.pbEndScene
            if pkmn.moves[i].id == :FLY
              scene = PokemonRegionMap_Scene.new(-1,false)
              screen = PokemonRegionMapScreen.new(scene)
              ret = screen.pbStartFlyScreen
              if ret
                $PokemonTemp.flydata=ret
                return [pkmn,pkmn.moves[i].id]
              end
              @scene.pbStartScene(@party,
                 (@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
              break
            end
            return [pkmn,pkmn.moves[i].id]
          end
        end
      end
      next if havecommand
      if cmdSummary>=0 && command==cmdSummary
        @scene.pbSummary(pkmnid) {
          @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
        }
      elsif cmdDebug>=0 && command==cmdDebug
        pbPokemonDebug(pkmn,pkmnid)
      elsif cmdSwitch>=0 && command==cmdSwitch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid = pkmnid
        pkmnid = @scene.pbChoosePokemon(true)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
      elsif cmdMail>=0 && command==cmdMail
        command = @scene.pbShowCommands(_INTL("Do what with the mail?"),
           [_INTL("Read"),_INTL("Take"),_INTL("Cancel")])
        case command
        when 0   # Read
          pbFadeOutIn {
            pbDisplayMail(pkmn.mail,pkmn)
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
        when 1   # Take
          if pbTakeItemFromPokemon(pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        end
	  elsif cmdRename >= 0 && command==cmdRename
		currentName = pkmn.name
		speciesName=GameData::Species.get(pkmn.species).real_name
		pbTextEntry("#{currentName}'s nickname?",0,10,5)
		if pbGet(5)=="" || pbGet(5)==currentName
		  pkmn.name=currentName
		else
		  pkmn.name=pbGet(5)
		end
	  elsif cmdPokedex >=0 && command==cmdPokedex
		$Trainer.pokedex.register_last_seen(pkmn)
		pbFadeOutIn {
		  scene = PokemonPokedexInfo_Scene.new
		  screen = PokemonPokedexInfoScreen.new(scene)
		  screen.pbStartSceneSingle(pkmn.species)
		}
      elsif cmdItem>=0 && command==cmdItem
        itemcommands = []
        cmdUseItem   = -1
        cmdGiveItem  = -1
        cmdTakeItem  = -1
        cmdMoveItem  = -1
        # Build the commands
        itemcommands[cmdUseItem=itemcommands.length]  = _INTL("Use")
        itemcommands[cmdGiveItem=itemcommands.length] = _INTL("Give")
        itemcommands[cmdTakeItem=itemcommands.length] = _INTL("Take") if pkmn.hasItem?
        itemcommands[cmdMoveItem=itemcommands.length] = _INTL("Move") if pkmn.hasItem? && !GameData::Item.get(pkmn.item).is_mail?
        itemcommands[itemcommands.length]             = _INTL("Cancel")
        command = @scene.pbShowCommands(_INTL("Do what with an item?"),itemcommands)
        if cmdUseItem>=0 && command==cmdUseItem   # Use
          item = @scene.pbUseItem($PokemonBag,pkmn) {
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
          if item
            pbUseItemOnPokemon(item,pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdGiveItem>=0 && command==cmdGiveItem   # Give
          item = @scene.pbChooseItem($PokemonBag) {
            @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
          if item
            if pbGiveItemToPokemon(item,pkmn,self,pkmnid)
              pbRefreshSingle(pkmnid)
            end
          end
        elsif cmdTakeItem>=0 && command==cmdTakeItem   # Take
          if pbTakeItemFromPokemon(pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdMoveItem>=0 && command==cmdMoveItem   # Move
          item = pkmn.item
          itemname = item.name
          @scene.pbSetHelpText(_INTL("Move {1} to where?",itemname))
          oldpkmnid = pkmnid
          loop do
            @scene.pbPreSelect(oldpkmnid)
            pkmnid = @scene.pbChoosePokemon(true,pkmnid)
            break if pkmnid<0
            newpkmn = @party[pkmnid]
            break if pkmnid==oldpkmnid
            if newpkmn.egg?
              pbDisplay(_INTL("Eggs can't hold items."))
            elsif !newpkmn.hasItem?
              newpkmn.item = item
              pkmn.item = nil
              @scene.pbClearSwitching
              pbRefresh
              pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
              break
            elsif GameData::Item.get(newpkmn.item).is_mail?
              pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.",newpkmn.name))
            else
              newitem = newpkmn.item
              newitemname = newitem.name
              if newitem == :LEFTOVERS
                pbDisplay(_INTL("{1} is already holding some {2}.\1",newpkmn.name,newitemname))
              elsif newitemname.starts_with_vowel?
                pbDisplay(_INTL("{1} is already holding an {2}.\1",newpkmn.name,newitemname))
              else
                pbDisplay(_INTL("{1} is already holding a {2}.\1",newpkmn.name,newitemname))
              end
              if pbConfirm(_INTL("Would you like to switch the two items?"))
                newpkmn.item = item
                pkmn.item = newitem
                @scene.pbClearSwitching
                pbRefresh
                pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
                pbDisplay(_INTL("{1} was given the {2} to hold.",pkmn.name,newitemname))
                break
              end
            end
          end
        end
      end
    end
    @scene.pbEndScene
    return nil
  end
end

class PokeBattle_Scene
  #=============================================================================
  # Opens the party screen to choose a Pokémon to switch in (or just view its
  # summary screens)
  #=============================================================================
  def pbPartyScreen(idxBattler,canCancel=false)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Get player's party
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)
    # Start party screen
    scene = PokemonParty_Scene.new
    switchScreen = PokemonPartyScreen.new(scene,modParty)
    switchScreen.pbStartScene(_INTL("Choose a Pokémon."),@battle.pbNumPositions(0,0))
    # Loop while in party screen
    loop do
      # Select a Pokémon
      scene.pbSetHelpText(_INTL("Choose a Pokémon."))
      idxParty = switchScreen.pbChoosePokemon
      if idxParty<0
        next if !canCancel
        break
      end
      # Choose a command for the selected Pokémon
      cmdSwitch  = -1
      cmdSummary = -1
	  cmdPokedex = -1
      commands = []
      commands[cmdSwitch  = commands.length] = _INTL("Switch In") if modParty[idxParty].able?
      commands[cmdSummary = commands.length] = _INTL("Summary")
	  commands[cmdPokedex = commands.length] = _INTL("Pokédex") if !modParty[idxParty].egg? && $Trainer.has_pokedex
      commands[commands.length]              = _INTL("Cancel")
      command = scene.pbShowCommands(_INTL("Do what with {1}?",modParty[idxParty].name),commands)
      if cmdSwitch>=0 && command==cmdSwitch        # Switch In
        idxPartyRet = -1
        partyPos.each_with_index do |pos,i|
          next if pos!=idxParty+partyStart
          idxPartyRet = i
          break
        end
        break if yield idxPartyRet, switchScreen
      elsif cmdSummary>=0 && command==cmdSummary   # Summary
        scene.pbSummary(idxParty,true)
	  elsif cmdPokedex && command==cmdPokedex
        $Trainer.pokedex.register_last_seen(modParty[idxParty])
		pbFadeOutIn {
		  dexscene = PokemonPokedexInfo_Scene.new
		  dexscreen = PokemonPokedexInfoScreen.new(dexscene)
		  dexscreen.pbStartSceneSingle(modParty[idxParty].species)
		}
      end
    end
    # Close party screen
    switchScreen.pbEndScene
    # Fade back into battle screen
    pbFadeInAndShow(@sprites,visibleSprites)
  end
end