class PokemonMart_Scene
    def update
      pbUpdateSpriteHash(@sprites)
      @subscene.pbUpdate if @subscene
    end
  
    def pbRefresh
      if @subscene
        @subscene.pbRefresh
      else
        itemwindow = @sprites["itemwindow"]
        @sprites["icon"].item = itemwindow.item
        @sprites["itemtextwindow"].text =
           (itemwindow.item) ? @adapter.getDescription(itemwindow.item) : _INTL("Quit shopping.")
        itemwindow.refresh
      end
      moneyWindowText = @adapter.getMoneyName(true) + ": "
      moneyWindowText += "\r\n" if @adapter.moneyOnNewLine?
      moneyWindowText += "<r>" + @adapter.getMoneyString
      @sprites["moneywindow"].text = moneyWindowText
    end
  
    def pbStartBuyOrSellScene(buying, stock, adapter)
      # Scroll right before showing screen
      pbScrollMap(6, 5, 5)
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @stock = stock
      @adapter = adapter
      @sprites = {}
      @sprites["background"] = IconSprite.new(0, 0, @viewport)
      bg_path = "Graphics/Pictures/martScreen"
      bg_path += "_dark" if darkMode?
      @sprites["background"].setBitmap(bg_path)
      @sprites["icon"] = ItemIconSprite.new(36, Graphics.height - 50, nil, @viewport)
      winAdapter = buying ? BuyAdapter.new(adapter) : SellAdapter.new(adapter)
      @sprites["itemwindow"] = Window_PokemonMart.new(stock, winAdapter,
         Graphics.width - 316 - 16, 12, 330 + 16, Graphics.height - 126)
      @sprites["itemwindow"].viewport = @viewport
      @sprites["itemwindow"].index = 0
      @sprites["itemwindow"].refresh
      @sprites["itemtextwindow"] = Window_UnformattedTextPokemon.newWithSize("",
         64, Graphics.height - 96 - 16, Graphics.width - 64, 128, @viewport)
      pbPrepareWindow(@sprites["itemtextwindow"])
      @sprites["itemtextwindow"].baseColor = Color.new(248, 248, 248)
      @sprites["itemtextwindow"].shadowColor = Color.new(0, 0, 0)
      @sprites["itemtextwindow"].windowskin = nil
      @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
      pbPrepareWindow(@sprites["helpwindow"])
      @sprites["helpwindow"].visible = false
      @sprites["helpwindow"].viewport = @viewport
      pbBottomLeftLines(@sprites["helpwindow"], 1)
      @sprites["moneywindow"] = Window_AdvancedTextPokemon.new("")
      pbPrepareWindow(@sprites["moneywindow"])
      skin_path = "Graphics/Windowskins/goldskin"
      skin_path += "_dark" if darkMode?
      @sprites["moneywindow"].setSkin(skin_path)
      @sprites["moneywindow"].visible = true
      @sprites["moneywindow"].viewport = @viewport
      @sprites["moneywindow"].x = 0
      @sprites["moneywindow"].y = 0
      @sprites["moneywindow"].width = 190
      @sprites["moneywindow"].height = @adapter.moneyOnNewLine? ? 96 : 64
      @sprites["moneywindow"].baseColor = MessageConfig.pbDefaultTextMainColor
      @sprites["moneywindow"].shadowColor = MessageConfig.pbDefaultTextShadowColor
      pbDeactivateWindows(@sprites)
      @buying = buying
      pbRefresh
      Graphics.frame_reset
    end
  
    def pbStartBuyScene(stock, adapter)
      pbStartBuyOrSellScene(true, stock, adapter)
    end
  
    def pbStartSellScene(bag, adapter)
      if $PokemonBag
        pbStartSellScene2(bag, adapter)
      else
        pbStartBuyOrSellScene(false, bag, adapter)
      end
    end
  
    def pbStartSellScene2(bag, adapter)
      @subscene = PokemonBag_Scene.new
      @adapter = adapter
      @viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport2.z = 99999
      numFrames = Graphics.frame_rate * 4 / 10
      alphaDiff = (255.0 / numFrames).ceil
      for j in 0..numFrames
        col = Color.new(0, 0, 0, j * alphaDiff)
        @viewport2.color = col
        Graphics.update
        Input.update
      end
      canSellProc = nil
      # canSellProc = Proc.new { |item|
      #   @adapter.canSell?(item)
      # }
      @subscene.pbStartScene(bag,true,canSellProc,false,6)
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @sprites = {}
      @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
      pbPrepareWindow(@sprites["helpwindow"])
      @sprites["helpwindow"].visible = false
      @sprites["helpwindow"].viewport = @viewport
      pbBottomLeftLines(@sprites["helpwindow"], 1)
      @sprites["moneywindow"] = Window_AdvancedTextPokemon.new("")
      pbPrepareWindow(@sprites["moneywindow"])
      skin_path = "Graphics/Windowskins/goldskin"
      skin_path += "_dark" if darkMode?
      @sprites["moneywindow"].setSkin(skin_path)
      @sprites["moneywindow"].visible = false
      @sprites["moneywindow"].viewport = @viewport
      @sprites["moneywindow"].x = 0
      @sprites["moneywindow"].y = 0
      @sprites["moneywindow"].width = 186
      @sprites["moneywindow"].height = 96
      @sprites["moneywindow"].baseColor = MessageConfig.pbDefaultTextMainColor
      @sprites["moneywindow"].shadowColor = MessageConfig.pbDefaultTextShadowColor
      pbDeactivateWindows(@sprites)
      @buying = false
      pbRefresh
    end
  
    def pbEndBuyScene
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
      # Scroll left after showing screen
      pbScrollMap(4, 5, 5)
    end
  
    def pbEndSellScene
      @subscene.pbEndScene if @subscene
      pbDisposeSpriteHash(@sprites)
      if @viewport2
        numFrames = Graphics.frame_rate * 4 / 10
        alphaDiff = (255.0 / numFrames).ceil
        for j in 0..numFrames
          col = Color.new(0, 0, 0, (numFrames - j) * alphaDiff)
          @viewport2.color = col
          Graphics.update
          Input.update
        end
        @viewport2.dispose
      end
      @viewport.dispose
      pbScrollMap(4, 5, 5) if !@subscene
    end
  
    def pbPrepareWindow(window)
      window.visible = true
      window.letterbyletter = false
    end
  
    def pbShowMoney
      pbRefresh
      @sprites["moneywindow"].visible = true
    end
  
    def pbHideMoney
      pbRefresh
      @sprites["moneywindow"].visible = false
    end
  
    def pbDisplay(msg, brief = false)
      cw = @sprites["helpwindow"]
      cw.letterbyletter = true
      cw.text = msg
      pbBottomLeftLines(cw, 2)
      cw.visible = true
      i = 0
      pbPlayDecisionSE
      loop do
        Graphics.update
        Input.update
        self.update
        if !cw.busy?
          return if brief
          pbRefresh if i == 0
        end
        if Input.trigger?(Input::USE) && cw.busy?
          cw.resume
        end
        return if i >= Graphics.frame_rate * 3 / 2
        i += 1 if !cw.busy?
      end
    end
  
    def pbDisplayPaused(msg)
      cw = @sprites["helpwindow"]
      cw.letterbyletter = true
      cw.text = msg
      pbBottomLeftLines(cw, 2)
      cw.visible = true
      yielded = false
      pbPlayDecisionSE
      loop do
        Graphics.update
        Input.update
        wasbusy = cw.busy?
        self.update
        if !cw.busy? && !yielded
          yield if block_given?   # For playing SE as soon as the message is all shown
          yielded = true
        end
        pbRefresh if !cw.busy? && wasbusy
        if Input.trigger?(Input::USE) && cw.resume && !cw.busy?
          @sprites["helpwindow"].visible = false
          return
        end
      end
    end
  
    def pbConfirm(msg)
      dw = @sprites["helpwindow"]
      dw.letterbyletter = true
      dw.text = msg
      dw.visible = true
      pbBottomLeftLines(dw, 2)
      commands = [_INTL("Yes"), _INTL("No")]
      cw = Window_CommandPokemon.new(commands)
      cw.viewport = @viewport
      pbBottomRight(cw)
      cw.y -= dw.height
      cw.index = 0
      pbPlayDecisionSE
      loop do
        cw.visible = !dw.busy?
        Graphics.update
        Input.update
        cw.update
        self.update
        if Input.trigger?(Input::BACK) && dw.resume && !dw.busy?
          cw.dispose
          @sprites["helpwindow"].visible = false
          return false
        end
        if Input.trigger?(Input::USE) && dw.resume && !dw.busy?
          cw.dispose
          @sprites["helpwindow"].visible = false
          return (cw.index == 0)
        end
      end
    end
  
    def pbChooseNumber(helptext,item,maximum)
      curnumber = 1
      ret = 0
      helpwindow = @sprites["helpwindow"]
      itemprice = @adapter.getPrice(item, !@buying)
      itemprice /= 2 if !@buying
      pbDisplay(helptext, true)
      using(numwindow = Window_AdvancedTextPokemon.new("")) {   # Showing number of items
        qty = @adapter.getQuantity(item)
        using(inbagwindow = Window_AdvancedTextPokemon.new("")) {   # Showing quantity in bag
          pbPrepareWindow(numwindow)
          pbPrepareWindow(inbagwindow)
          numwindow.viewport = @viewport
          numwindow.width = 224
          numwindow.height = 64
          numwindow.baseColor = Color.new(88, 88, 80)
          numwindow.shadowColor = Color.new(168, 184, 184)
          inbagwindow.visible = @buying
          inbagwindow.viewport = @viewport
          inbagwindow.width = 190
          inbagwindow.height = 64
          inbagwindow.baseColor = Color.new(88, 88, 80)
          inbagwindow.shadowColor = Color.new(168, 184, 184)
          inbagwindow.text = _INTL("In Bag:<r>{1}  ", qty)
          pbBottomRight(numwindow)
          numwindow.y -= helpwindow.height
          pbBottomLeft(inbagwindow)
          inbagwindow.y -= helpwindow.height
          loop do
            numwindow.text = _INTL("x{1}<r>{2}", curnumber, @adapter.getMoneyDisplay(curnumber * itemprice))

            Graphics.update
            Input.update
            numwindow.update
            inbagwindow.update
            self.update
            if Input.repeat?(Input::LEFT)
              pbPlayCursorSE
              curnumber -= 10
              curnumber = 1 if curnumber < 1
            elsif Input.repeat?(Input::RIGHT)
              pbPlayCursorSE
              curnumber += 10
              curnumber = maximum if curnumber > maximum
            elsif Input.repeat?(Input::UP)
              pbPlayCursorSE
              curnumber += 1
              curnumber = 1 if curnumber > maximum
            elsif Input.repeat?(Input::DOWN)
              pbPlayCursorSE
              curnumber -= 1
              curnumber = maximum if curnumber < 1
            elsif Input.trigger?(Input::USE)
              pbPlayDecisionSE
              ret = curnumber
              break
            elsif Input.trigger?(Input::BACK)
              pbPlayCancelSE
              ret = 0
              break
            end
          end
        }
      }
      helpwindow.visible = false
      return ret
    end
  
    def pbChooseBuyItem
      itemwindow = @sprites["itemwindow"]
      @sprites["helpwindow"].visible = false
      pbActivateWindow(@sprites, "itemwindow") {
        pbRefresh
        loop do
          Graphics.update
          Input.update
          olditem = itemwindow.item
          self.update
          if itemwindow.item != olditem
            @sprites["icon"].item = itemwindow.item
            @sprites["itemtextwindow"].text =
               (itemwindow.item) ? @adapter.getDescription(itemwindow.item) : _INTL("Quit shopping.")
          end
          if Input.trigger?(Input::BACK)
            pbPlayCloseMenuSE
            return nil
          elsif Input.trigger?(Input::USE)
            if itemwindow.index < @stock.length
              pbRefresh
              return @stock[itemwindow.index]
            else
              return nil
            end
          end
        end
      }
    end
  
    def pbChooseSellItem
      if @subscene
        return @subscene.pbChooseItem
      else
        return pbChooseBuyItem
      end
    end
  end