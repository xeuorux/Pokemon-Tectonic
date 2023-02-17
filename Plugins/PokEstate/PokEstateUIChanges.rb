class PokemonSummaryScreen
    def pbStartSingleScreen(pokemon)
      @scene.pbStartSingleScene(pokemon)
      ret = @scene.pbScene
      @scene.pbEndScene
      return ret
    end
  end
  
  class PokemonSummary_Scene
    def pbStartSingleScene(pokemon)
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @party      = nil
      @partyindex = -1
      @pokemon    = pokemon
      @inbattle   = false
      @page = 1
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
      @sprites["itemicon"].type = @pokemon.itemTypeChosen
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
    
    def pbScene
      @pokemon.play_cry
      loop do
        Graphics.update
        Input.update
        pbUpdate
        dorefresh = false
        if Input.trigger?(Input::ACTION)
          pbSEStop
          @pokemon.play_cry
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        elsif Input.trigger?(Input::USE)
          if @page==4
            pbPlayDecisionSE
            pbMoveSelection
            dorefresh = true
          elsif @page==5
            pbPlayDecisionSE
            pbRibbonSelection
            dorefresh = true
          elsif !@inbattle
            pbPlayDecisionSE
            dorefresh = pbOptions
          end
        elsif Input.trigger?(Input::UP) && !@party.nil? && @partyindex>0
          oldindex = @partyindex
          pbGoToPrevious
          if @partyindex!=oldindex
            pbChangePokemon
            @ribbonOffset = 0
            dorefresh = true
          end
        elsif Input.trigger?(Input::DOWN) && !@party.nil? && @partyindex<@party.length-1
          oldindex = @partyindex
          pbGoToNext
          if @partyindex!=oldindex
            pbChangePokemon
            @ribbonOffset = 0
            dorefresh = true
          end
        elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
          oldpage = @page
          @page -= 1
          @page = 1 if @page<1
          @page = 5 if @page>5
          if @page!=oldpage   # Move to next page
            pbSEPlay("GUI summary change page")
            @ribbonOffset = 0
            dorefresh = true
          end
        elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
          oldpage = @page
          @page += 1
          @page = 1 if @page<1
          @page = 5 if @page>5
          if @page!=oldpage   # Move to next page
            pbSEPlay("GUI summary change page")
            @ribbonOffset = 0
            dorefresh = true
          end
        end
        if dorefresh
          drawPage(@page)
        end
      end
      return @partyindex
    end
  end
  
class Game_Temp
    attr_accessor :setup_sames
    
  #-----------------------------------------------------------------------------
  # * Object Initialization
  #-----------------------------------------------------------------------------
  def initialize
    @message_window_showing = false
    @common_event_id        = 0
    @in_battle              = false
    @battle_abort           = false
    @battleback_name        = ''
    @in_menu                = false
    @menu_beep              = false
    @menu_calling           = false
    @debug_calling          = false
    @player_transferring    = false
    @player_new_map_id      = 0
    @player_new_x           = 0
    @player_new_y           = 0
    @player_new_direction   = 0
    @transition_processing  = false
    @transition_name        = ""
    @to_title               = false
    @fadestate              = 0
    @background_bitmap      = nil
    @message_window_showing = false
    @transition_processing  = false
    @mart_prices            = {}
    @setup_sames			= false
  end
end