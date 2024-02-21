#===============================================================================
#
#===============================================================================
class ItemStorage_Scene
    ITEMSVISIBLE        = 7
  
    def initialize(title)
      @title = title
    end
  
    def update
      pbUpdateSpriteHash(@sprites)
    end
  
    def pbStartScene(bag)
      @viewport   = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @bag = bag
      @sprites = {}
      @sprites["background"] = IconSprite.new(0,0,@viewport)
      bg_path = "Graphics/Pictures/pcItembg"
      bg_path += "_dark" if darkMode?
      @sprites["background"].setBitmap(bg_path)
      @sprites["icon"] = ItemIconSprite.new(50,334,nil,@viewport)
      # Item list
      @sprites["itemwindow"] = Window_PokemonItemStorage.new(@bag,98,14,334,32+ITEMSVISIBLE*32)
      @sprites["itemwindow"].viewport    = @viewport
      @sprites["itemwindow"].index       = 0
      @sprites["itemwindow"].baseColor   = MessageConfig.pbDefaultTextMainColor
      @sprites["itemwindow"].shadowColor = MessageConfig.pbDefaultTextShadowColor
      @sprites["itemwindow"].refresh
      # Title
      @sprites["pocketwindow"] = BitmapSprite.new(88,64,@viewport)
      @sprites["pocketwindow"].x = 14
      @sprites["pocketwindow"].y = 16
      pbSetNarrowFont(@sprites["pocketwindow"].bitmap)
      # Item description
      @sprites["itemtextwindow"] = Window_UnformattedTextPokemon.newWithSize("",84,270,Graphics.width-84,128,@viewport)
      @sprites["itemtextwindow"].baseColor   = MessageConfig::LIGHT_TEXT_MAIN_COLOR
      @sprites["itemtextwindow"].shadowColor = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
      @sprites["itemtextwindow"].windowskin  = nil
      @sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
      @sprites["helpwindow"].visible  = false
      @sprites["helpwindow"].viewport = @viewport
      # Letter-by-letter message window
      @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
      @sprites["msgwindow"].visible  = false
      @sprites["msgwindow"].viewport = @viewport
      pbBottomLeftLines(@sprites["helpwindow"],1)
      pbDeactivateWindows(@sprites)
      pbRefresh
      pbFadeInAndShow(@sprites)
    end
  
    def pbEndScene
      pbFadeOutAndHide(@sprites)
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
    end
  
    def pbChooseNumber(helptext,maximum)
      return UIHelper.pbChooseNumber(@sprites["helpwindow"],helptext,maximum) { update }
    end
  
    def pbDisplay(msg,brief=false)
      UIHelper.pbDisplay(@sprites["msgwindow"],msg,brief) { update }
    end
  
    def pbConfirm(msg)
      UIHelper.pbConfirm(@sprites["msgwindow"],msg) { update }
    end
  
    def pbShowCommands(helptext,commands)
      return UIHelper.pbShowCommands(@sprites["helpwindow"],helptext,commands) { update }
    end
  
    def pbRefresh
      bm = @sprites["pocketwindow"].bitmap
      # Draw title at upper left corner ("Toss Item/Withdraw Item")
      drawTextEx(bm,0,4,bm.width,2,@title,MessageConfig::LIGHT_TEXT_MAIN_COLOR,MessageConfig::LIGHT_TEXT_SHADOW_COLOR)
      itemwindow = @sprites["itemwindow"]
      # Draw item icon
      @sprites["icon"].item = itemwindow.item
      # Get item description
      if itemwindow.item
        @sprites["itemtextwindow"].text = GameData::Item.get(itemwindow.item).description
      else
        @sprites["itemtextwindow"].text = _INTL("Close storage.")
      end
      itemwindow.refresh
    end
  
    def pbChooseItem
      pbRefresh
      @sprites["helpwindow"].visible = false
      itemwindow = @sprites["itemwindow"]
      itemwindow.refresh
      pbActivateWindow(@sprites,"itemwindow") {
        loop do
          Graphics.update
          Input.update
          olditem = itemwindow.item
          self.update
          pbRefresh if itemwindow.item!=olditem
          if Input.trigger?(Input::BACK)
            return nil
          elsif Input.trigger?(Input::USE)
            if itemwindow.index<@bag.length
              pbRefresh
              return @bag[itemwindow.index][0]
            else
              return nil
            end
          end
        end
      }
    end
  end