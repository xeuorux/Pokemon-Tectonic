#===============================================================================
# Pokémon storage visuals
#===============================================================================
class PokemonStorageScene
    attr_reader :quickswap

    def initialize
        @command = 1
    end

    def pbStartBox(screen, command, iconFadeProc = nil)
        @screen = screen
        @storage = screen.storage
        @bgviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @bgviewport.z = 99_999
        @boxviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @boxviewport.z = 99_999
        @boxsidesviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @boxsidesviewport.z = 99_999
        @arrowviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @arrowviewport.z = 99_999
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_999
        @selection = 0
        @quickswap = false
        @sprites = {}
        @choseFromParty = false
        @command = command
        addBackgroundPlane(@sprites, "background", "Storage/bg", @bgviewport)
        @iconFadeProc = iconFadeProc
        @sprites["box"] = PokemonBoxSprite.new(@storage, @storage.currentBox, @boxviewport, @iconFadeProc)
        @sprites["boxsides"] = IconSprite.new(0, 0, @boxsidesviewport)
        overlay_path = "Graphics/Pictures/Storage/overlay_main"
        overlay_path += "_dark" if darkMode?
        @sprites["boxsides"].setBitmap(overlay_path)
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @boxsidesviewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        @sprites["pokemon"] = AutoMosaicPokemonSprite.new(@boxsidesviewport)
        @sprites["pokemon"].setOffset(PictureOrigin::Center)
        @sprites["pokemon"].x = 90
        @sprites["pokemon"].y = 134
        @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party, @boxsidesviewport, iconFadeProc)
        if command != 2 # Drop down tab only on Deposit
            @sprites["boxparty"].x = 182
            @sprites["boxparty"].y = Graphics.height
        end
        marking_path = "Graphics/Pictures/Storage/markings"
        marking_path += "_dark" if darkMode?
        @markingbitmap = AnimatedBitmap.new(marking_path)
        @sprites["markingbg"] = IconSprite.new(292, 68, @boxsidesviewport)
        markingbg_path = "Graphics/Pictures/Storage/overlay_marking"
        markingbg_path += "_dark" if darkMode?
        @sprites["markingbg"].setBitmap(markingbg_path)
        @sprites["markingbg"].visible = false
        @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @boxsidesviewport)
        @sprites["markingoverlay"].visible = false
        pbSetSystemFont(@sprites["markingoverlay"].bitmap)
        @sprites["arrow"] = PokemonBoxArrow.new(@arrowviewport)
        @sprites["arrow"].z += 1
        if command != 2
            pbSetArrow(@sprites["arrow"], @selection)
            pbUpdateOverlay(@selection)
            pbSetMosaic(@selection)
        else
            pbPartySetArrow(@sprites["arrow"], @selection)
            pbUpdateOverlay(@selection, @storage.party)
            pbSetMosaic(@selection)
        end
        pbSEPlay("PC access")
        pbFadeInAndShow(@sprites)
    end

    def pbCloseBox
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
        @markingbitmap.dispose if @markingbitmap
        @boxviewport.dispose
        @boxsidesviewport.dispose
        @arrowviewport.dispose
    end

    def pbDisplay(message)
        msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
        msgwindow.z       = @viewport.z + 1
        msgwindow.visible        = true
        msgwindow.letterbyletter = false
        msgwindow.resizeHeightToFit(message, Graphics.width - 180)
        msgwindow.text = message
        pbBottomRight(msgwindow)
        loop do
            Graphics.update
            Input.update
            break if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
            msgwindow.update
            update
        end
        msgwindow.dispose
        Input.update
    end

    def pbShowCommands(message, commands, index = 0)
        ret = -1
        msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
        msgwindow.z = @viewport.z+1
        msgwindow.visible        = true
        msgwindow.letterbyletter = false
        msgwindow.text           = message
        msgwindow.resizeHeightToFit(message, Graphics.width - 180)
        pbBottomRight(msgwindow)
        cmdwindow = Window_CommandPokemon.new(commands)
        cmdwindow.z = @viewport.z+1
        cmdwindow.visible  = true
        cmdwindow.resizeToFit(cmdwindow.commands)
        cmdwindow.height = Graphics.height - msgwindow.height if cmdwindow.height > Graphics.height - msgwindow.height
        pbBottomRight(cmdwindow)
        cmdwindow.y -= msgwindow.height
        cmdwindow.index = index
        loop do
            Graphics.update
            Input.update
            msgwindow.update
            cmdwindow.update
            if Input.trigger?(Input::BACK)
                ret = -1
                break
            elsif Input.trigger?(Input::USE)
                ret = cmdwindow.index
                break
            end
            update
        end
        msgwindow.dispose
        cmdwindow.dispose
        Input.update
        return ret
    end

    def pbConfirm(str)
        return pbShowCommands(str, [_INTL("Yes"), _INTL("No")]) == 0
    end

    def pbSetArrow(arrow, selection)
        case selection
        when -1, -4, -5 # Box name, move left, move right
            arrow.x = 157 * 2
            arrow.y = -12 * 2
        when -2 # Party Pokémon
            arrow.x = 119 * 2
            arrow.y = 139 * 2
        when -3 # Close Box
            arrow.x = 207 * 2
            arrow.y = 139 * 2
        else
            arrow.x = (97 + 24 * (selection % PokemonBox::BOX_WIDTH)) * 2
            arrow.y = (8 + 24 * (selection / PokemonBox::BOX_WIDTH)) * 2
        end
    end

    def pbChangeSelection(key, selection)
        case key
        when Input::UP
            if selection == -1 # Box name
                selection = -2
            elsif selection == -2 # Party
                selection = PokemonBox::BOX_SIZE - 1 - PokemonBox::BOX_WIDTH * 2 / 3 # 25
            elsif selection == -3 # Close Box
                selection = PokemonBox::BOX_SIZE - PokemonBox::BOX_WIDTH / 3 # 28
            else
                selection -= PokemonBox::BOX_WIDTH
                selection = -1 if selection < 0
            end
        when Input::DOWN
            if selection == -1 # Box name
                selection = PokemonBox::BOX_WIDTH / 3 # 2
            elsif selection == -2   # Party
                selection = -1
            elsif selection == -3   # Close Box
                selection = -1
            else
                selection += PokemonBox::BOX_WIDTH
                if selection >= PokemonBox::BOX_SIZE
                    if selection < PokemonBox::BOX_SIZE + PokemonBox::BOX_WIDTH / 2
                        selection = -2   # Party
                    else
                        selection = -3   # Close Box
                    end
                end
            end
        when Input::LEFT
            if selection == -1 # Box name
                selection = -4 # Move to previous box
            elsif selection == -2
                selection = -3
            elsif selection == -3
                selection = -2
            elsif (selection % PokemonBox::BOX_WIDTH) == 0 # Wrap around
                selection += PokemonBox::BOX_WIDTH - 1
            else
                selection -= 1
            end
        when Input::RIGHT
            if selection == -1 # Box name
                selection = -5 # Move to next box
            elsif selection == -2
                selection = -3
            elsif selection == -3
                selection = -2
            elsif (selection % PokemonBox::BOX_WIDTH) == PokemonBox::BOX_WIDTH - 1 # Wrap around
                selection -= PokemonBox::BOX_WIDTH - 1
            else
                selection += 1
            end
        end
        return selection
    end

    def pbPartySetArrow(arrow, selection)
        return if selection < 0
        xvalues = []   # [200, 272, 200, 272, 200, 272, 236]
        yvalues = []   # [2, 18, 66, 82, 130, 146, 220]
        for i in 0...Settings::MAX_PARTY_SIZE
            xvalues.push(200 + 72 * (i % 2))
            yvalues.push(2 + 16 * (i % 2) + 64 * (i / 2))
        end
        xvalues.push(236)
        yvalues.push(220)
        arrow.angle = 0
        arrow.mirror = false
        arrow.ox = 0
        arrow.oy = 0
        arrow.x = xvalues[selection]
        arrow.y = yvalues[selection]
    end

    def pbPartyChangeSelection(key, selection)
        case key
        when Input::LEFT
            selection -= 1
            selection = Settings::MAX_PARTY_SIZE if selection < 0
        when Input::RIGHT
            selection += 1
            selection = 0 if selection > Settings::MAX_PARTY_SIZE
        when Input::UP
            if selection == Settings::MAX_PARTY_SIZE
                selection = Settings::MAX_PARTY_SIZE - 1
            else
                selection -= 2
                selection = Settings::MAX_PARTY_SIZE if selection < 0
            end
        when Input::DOWN
            if selection == Settings::MAX_PARTY_SIZE
                selection = 0
            else
                selection += 2
                selection = Settings::MAX_PARTY_SIZE if selection > Settings::MAX_PARTY_SIZE
            end
        end
        return selection
    end

    def pbSelectBoxInternal(_party)
        selection = @selection
        pbSetArrow(@sprites["arrow"], selection)
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
        loop do
            Graphics.update
            Input.update
            key = -1
            key = Input::DOWN if Input.repeat?(Input::DOWN)
            key = Input::RIGHT if Input.repeat?(Input::RIGHT)
            key = Input::LEFT if Input.repeat?(Input::LEFT)
            key = Input::UP if Input.repeat?(Input::UP)
            if key >= 0
                pbPlayCursorSE
                selection = pbChangeSelection(key, selection)
                pbSetArrow(@sprites["arrow"], selection)
                if selection == -4
                    nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
                    pbSwitchBoxToLeft(nextbox)
                    @storage.currentBox = nextbox
                elsif selection == -5
                    nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
                    pbSwitchBoxToRight(nextbox)
                    @storage.currentBox = nextbox
                end
                selection = -1 if [-4, -5].include?(selection)
                pbUpdateOverlay(selection)
                pbSetMosaic(selection)
            end
            update
            if Input.trigger?(Input::JUMPUP)
                pbPlayCursorSE
                nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
                pbSwitchBoxToLeft(nextbox)
                @storage.currentBox = nextbox
                pbUpdateOverlay(selection)
                pbSetMosaic(selection)
            elsif Input.trigger?(Input::JUMPDOWN)
                pbPlayCursorSE
                nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
                pbSwitchBoxToRight(nextbox)
                @storage.currentBox = nextbox
                pbUpdateOverlay(selection)
                pbSetMosaic(selection)
            elsif Input.trigger?(Input::SPECIAL) # Jump to box name
                if selection != -1
                    pbPlayCursorSE
                    selection = -1
                    pbSetArrow(@sprites["arrow"], selection)
                    pbUpdateOverlay(selection)
                    pbSetMosaic(selection)
                end
            elsif Input.trigger?(Input::ACTION) && @command == 0 # Organize only
                pbPlayDecisionSE
                pbSetQuickSwap(!@quickswap)
            elsif Input.trigger?(Input::BACK)
                @selection = selection
                return nil
            elsif Input.trigger?(Input::USE)
                @selection = selection
                if selection >= 0
                    return [@storage.currentBox, selection]
                elsif selection == -1   # Box name
                    return [-4, -1]
                elsif selection == -2   # Party Pokémon
                    return [-2, -1]
                elsif selection == -3   # Close Box
                    return [-3, -1]
                end
            end
        end
    end

    def pbSelectBox(party)
        return pbSelectBoxInternal(party) if @command == 1 # Withdraw
        ret = nil
        loop do
            ret = pbSelectBoxInternal(party) unless @choseFromParty
            if @choseFromParty || (ret && ret[0] == -2) # Party Pokémon
                unless @choseFromParty
                    pbShowPartyTab
                    @selection = 0
                end
                ret = pbSelectPartyInternal(party, false)
                if ret < 0
                    pbHidePartyTab
                    @selection = 0
                    @choseFromParty = false
                else
                    @choseFromParty = true
                    return [-1, ret]
                end
            else
                @choseFromParty = false
                return ret
            end
        end
    end

    def pbSelectPartyInternal(party, depositing)
        selection = @selection
        pbPartySetArrow(@sprites["arrow"], selection)
        pbUpdateOverlay(selection, party)
        pbSetMosaic(selection)
        lastsel = 1
        loop do
            Graphics.update
            Input.update
            key = -1
            key = Input::DOWN if Input.repeat?(Input::DOWN)
            key = Input::RIGHT if Input.repeat?(Input::RIGHT)
            key = Input::LEFT if Input.repeat?(Input::LEFT)
            key = Input::UP if Input.repeat?(Input::UP)
            if key >= 0
                pbPlayCursorSE
                newselection = pbPartyChangeSelection(key, selection)
                if newselection == -1
                    return -1 unless depositing
                elsif newselection == -2
                    selection = lastsel
                else
                    selection = newselection
                end
                pbPartySetArrow(@sprites["arrow"], selection)
                lastsel = selection if selection > 0
                pbUpdateOverlay(selection, party)
                pbSetMosaic(selection)
            end
            update
            if Input.trigger?(Input::ACTION) && @command == 0 # Organize only
                pbPlayDecisionSE
                pbSetQuickSwap(!@quickswap)
            elsif Input.trigger?(Input::BACK)
                @selection = selection
                return -1
            elsif Input.trigger?(Input::USE)
                if selection >= 0 && selection < Settings::MAX_PARTY_SIZE
                    @selection = selection
                    return selection
                elsif selection == Settings::MAX_PARTY_SIZE # Close Box
                    @selection = selection
                    return depositing ? -3 : -1
                end
            end
        end
    end

    def pbSelectParty(party)
        return pbSelectPartyInternal(party, true)
    end

    def pbChangeBackground(wp)
        @sprites["box"].refreshSprites = false
        alpha = 0
        Graphics.update
        update
        timeTaken = Graphics.frame_rate * 4 / 10
        alphaDiff = (255.0 / timeTaken).ceil
        timeTaken.times do
            alpha += alphaDiff
            Graphics.update
            Input.update
            @sprites["box"].color = Color.new(248, 248, 248, alpha)
            update
        end
        @sprites["box"].refreshBox = true
        @storage[@storage.currentBox].background = wp
        (Graphics.frame_rate / 10).times do
            Graphics.update
            Input.update
            update
        end
        timeTaken.times do
            alpha -= alphaDiff
            Graphics.update
            Input.update
            @sprites["box"].color = Color.new(248, 248, 248, alpha)
            update
        end
        @sprites["box"].refreshSprites = true
    end

    def pbSwitchBoxToRight(newbox)
        newbox = PokemonBoxSprite.new(@storage, newbox, @boxviewport, @iconFadeProc)
        newbox.x = 520
        Graphics.frame_reset
        distancePerFrame = 64 * 20 / Graphics.frame_rate
        loop do
            Graphics.update
            Input.update
            @sprites["box"].x -= distancePerFrame
            newbox.x -= distancePerFrame
            update
            break if newbox.x <= 184
        end
        diff = newbox.x - 184
        newbox.x = 184
        @sprites["box"].x -= diff
        @sprites["box"].dispose
        @sprites["box"] = newbox
    end

    def pbSwitchBoxToLeft(newbox)
        newbox = PokemonBoxSprite.new(@storage, newbox, @boxviewport, @iconFadeProc)
        newbox.x = -152
        Graphics.frame_reset
        distancePerFrame = 64 * 20 / Graphics.frame_rate
        loop do
            Graphics.update
            Input.update
            @sprites["box"].x += distancePerFrame
            newbox.x += distancePerFrame
            update
            break if newbox.x >= 184
        end
        diff = newbox.x - 184
        newbox.x = 184
        @sprites["box"].x -= diff
        @sprites["box"].dispose
        @sprites["box"] = newbox
    end

    def pbJumpToBox(newbox)
        if @storage.currentBox != newbox
            if newbox > @storage.currentBox
                pbSwitchBoxToRight(newbox)
            else
                pbSwitchBoxToLeft(newbox)
            end
            @storage.currentBox = newbox
        end
    end

    def pbSetMosaic(selection)
        if !@screen.pbHeldPokemon && (@boxForMosaic != @storage.currentBox || @selectionForMosaic != selection)
            @sprites["pokemon"].mosaic = Graphics.frame_rate / 4
            @boxForMosaic = @storage.currentBox
            @selectionForMosaic = selection
        end
    end

    def pbSetQuickSwap(value)
        @quickswap = value
        @sprites["arrow"].quickswap = value
    end

    def pbShowPartyTab
        pbSEPlay("GUI storage show party panel")
        distancePerFrame = 48 * 20 / Graphics.frame_rate
        loop do
            Graphics.update
            Input.update
            @sprites["boxparty"].y -= distancePerFrame
            update
            break if @sprites["boxparty"].y <= Graphics.height - 352
        end
        @sprites["boxparty"].y = Graphics.height - 352
    end

    def pbHidePartyTab
        pbSEPlay("GUI storage hide party panel")
        distancePerFrame = 48 * 20 / Graphics.frame_rate
        loop do
            Graphics.update
            Input.update
            @sprites["boxparty"].y += distancePerFrame
            update
            break if @sprites["boxparty"].y >= Graphics.height
        end
        @sprites["boxparty"].y = Graphics.height
    end

    def pbHold(selected)
        pbSEPlay("GUI storage pick up")
        if selected[0] == -1
            @sprites["boxparty"].grabPokemon(selected[1], @sprites["arrow"])
        else
            @sprites["box"].grabPokemon(selected[1], @sprites["arrow"])
        end
        while @sprites["arrow"].grabbing?
            Graphics.update
            Input.update
            update
        end
    end

    def pbSwap(selected, _heldpoke)
        pbSEPlay("GUI storage pick up")
        heldpokesprite = @sprites["arrow"].heldPokemon
        boxpokesprite = nil
        if selected[0] == -1
            boxpokesprite = @sprites["boxparty"].getPokemon(selected[1])
        else
            boxpokesprite = @sprites["box"].getPokemon(selected[1])
        end
        if selected[0] == -1
            @sprites["boxparty"].setPokemon(selected[1], heldpokesprite)
        else
            @sprites["box"].setPokemon(selected[1], heldpokesprite)
        end
        @sprites["arrow"].setSprite(boxpokesprite)
        @sprites["pokemon"].mosaic = 10
        @boxForMosaic = @storage.currentBox
        @selectionForMosaic = selected[1]
    end

    def pbPlace(selected, _heldpoke)
        pbSEPlay("GUI storage put down")
        heldpokesprite = @sprites["arrow"].heldPokemon
        @sprites["arrow"].place
        while @sprites["arrow"].placing?
            Graphics.update
            Input.update
            update
        end
        if selected[0] == -1
            @sprites["boxparty"].setPokemon(selected[1], heldpokesprite)
        else
            @sprites["box"].setPokemon(selected[1], heldpokesprite)
        end
        @boxForMosaic = @storage.currentBox
        @selectionForMosaic = selected[1]
    end

    def pbWithdraw(selected, heldpoke, partyindex)
        pbHold(selected) unless heldpoke
        pbShowPartyTab
        pbPartySetArrow(@sprites["arrow"], partyindex)
        pbPlace([-1, partyindex], heldpoke)
        pbHidePartyTab
    end

    def pbStore(selected, heldpoke, destbox, firstfree)
        if heldpoke
            if destbox == @storage.currentBox
                heldpokesprite = @sprites["arrow"].heldPokemon
                @sprites["box"].setPokemon(firstfree, heldpokesprite)
                @sprites["arrow"].setSprite(nil)
            else
                @sprites["arrow"].deleteSprite
            end
        else
            sprite = @sprites["boxparty"].getPokemon(selected[1])
            if destbox == @storage.currentBox
                @sprites["box"].setPokemon(firstfree, sprite)
                @sprites["boxparty"].setPokemon(selected[1], nil)
            else
                @sprites["boxparty"].deletePokemon(selected[1])
            end
        end
    end

    def pbRelease(selected, heldpoke)
        box = selected[0]
        index = selected[1]
        if heldpoke
            sprite = @sprites["arrow"].heldPokemon
        elsif box == -1
            sprite = @sprites["boxparty"].getPokemon(index)
        else
            sprite = @sprites["box"].getPokemon(index)
        end
        if sprite
            sprite.release
            while sprite.releasing?
                Graphics.update
                sprite.update
                update
            end
        end
    end

    def pbChooseBox(msg)
        commands = []
        for i in 0...@storage.maxBoxes
            box = @storage[i]
            commands.push(_INTL("{1} ({2}/{3})", box.name, box.nitems, box.length)) if box
        end
        return pbShowCommands(msg, commands, @storage.currentBox)
    end

    def pbChooseSearch(msg)
        searchMethods = [_INTL("Cancel"), _INTL("Name"), _INTL("Species"), _INTL("Type"), _INTL("Tribe")]
        return pbShowCommands(msg, searchMethods)
    end

    def pbChooseSort(msg)
        sortMethods = [_INTL("Cancel"), _INTL("Name"), _INTL("Species"), _INTL("Dex ID"), _INTL("Type"), _INTL("Level")]
        return pbShowCommands(msg, sortMethods)
    end

    def pbChooseFound(msg, found)
        return pbShowCommands(msg, found)
    end

    def inDonationBox?
        return @storage[@storage.currentBox].isDonationBox?
    end

    def pbBoxName(helptext, minchars, maxchars)
        oldsprites = pbFadeOutAndHide(@sprites)
        ret = pbEnterBoxName(helptext, minchars, maxchars)
        @storage[@storage.currentBox].name = ret if ret.length > 0
        @sprites["box"].refreshBox = true
        pbRefresh
        pbFadeInAndShow(@sprites, oldsprites)
    end

    def pbSearch(searchText, minchars, maxchars, searchMethod)
        ret = pbEnterText(searchText, minchars, maxchars)

        # Find search candidates
        found = []
        if ret.length > 0
            for i in 0...@storage.maxBoxes
                next if @storage.boxes[i].isDonationBox?
                box = @storage.boxes[i]
                for j in 0..PokemonBox::BOX_SIZE
                    curpkmn = box[j]
                    next unless curpkmn
                    fitsSearch = false

                    if searchMethod == 1 # Name
                        fitsSearch = curpkmn.name.downcase.include?(ret.downcase)
                    elsif searchMethod == 2 # Species
                        fitsSearch = curpkmn.speciesName.downcase.include?(ret.downcase)
                    elsif searchMethod == 3 # Type
                        search = GameData::Type.try_get(ret.upcase)
                        if search
                            fitsSearch = curpkmn.hasType?(search.id)
                        else
                            pbDisplay(_INTL("\"#{ret}\" is not a valid type."))
                            return false
                        end
                    elsif searchMethod == 4 # Tribe
                        search = GameData::Tribe.try_get(ret.upcase)
                        if search
                            curpkmn.tribes.each do |tribe|
                                next unless tribe == search.id
                                fitsSearch = true
                                break
                            end
                        else
                            pbDisplay(_INTL("\"#{ret}\" is not a valid tribe."))
                            return false
                        end
                    end

                    found.push([i, j]) if fitsSearch
                end
            end
        end
        @sprites["box"].refreshBox = true
        pbRefresh

        # Switch boxes
        possibleboxes = {}
        unless found.empty?
            for i in 0..found.length - 1
                opt = @storage.boxes[found[i][0]].name
                possibleboxes[opt] = found[i][0]
            end
        end

        if possibleboxes.length > 0
            if possibleboxes.length == 1
                if found[0][0] == @storage.currentBox
                    if found.length == 1
                        pbDisplay(_INTL("The current box contains the only match."))
                    else
                        pbDisplay(_INTL("The current box contains every match."))
                    end
                    return false
                else
                    pbJumpToBox(found[0][0])
                end
            else
                foundIndex = pbChooseFound(_INTL("Multiple matches. Jump to which box?"), possibleboxes.keys)
                pbJumpToBox(possibleboxes[possibleboxes.keys[foundIndex]])
            end
        else
            pbDisplay(_INTL("No matching Pokémon were found."))
            return false
        end
        return true
    end

    def pbChooseItem(bag)
        ret = nil
        pbFadeOutIn do
            scene = PokemonBag_Scene.new
            screen = PokemonBagScreen.new(scene, bag)
            ret = screen.pbChooseItemScreen(proc { |item| GameData::Item.get(item).can_hold? })
        end
        return ret
    end

    def pbSummary(selected, heldpoke)
        oldsprites = pbFadeOutAndHide(@sprites)
        scene = PokemonSummary_Scene.new
        screen = PokemonSummaryScreen.new(scene)
        if heldpoke
            screen.pbStartScreen([heldpoke], 0)
        elsif selected[0] == -1
            @selection = screen.pbStartScreen(@storage.party, selected[1])
            pbPartySetArrow(@sprites["arrow"], @selection)
            pbUpdateOverlay(@selection, @storage.party)
        else
            @selection = screen.pbStartScreen(@storage.boxes[selected[0]], selected[1])
            pbSetArrow(@sprites["arrow"], @selection)
            pbUpdateOverlay(@selection)
        end
        pbFadeInAndShow(@sprites, oldsprites)
    end

    def pbMarkingSetArrow(arrow, selection)
        if selection >= 0
            xvalues = [162, 191, 220, 162, 191, 220, 184, 184]
            yvalues = [24, 24, 24, 49, 49, 49, 77, 109]
            arrow.angle = 0
            arrow.mirror = false
            arrow.ox = 0
            arrow.oy = 0
            arrow.x = xvalues[selection] * 2
            arrow.y = yvalues[selection] * 2
        end
    end

    def pbMarkingChangeSelection(key, selection)
        case key
        when Input::LEFT
            if selection < 6
                selection -= 1
                selection += 3 if selection % 3 == 2
            end
        when Input::RIGHT
            if selection < 6
                selection += 1
                selection -= 3 if selection % 3 == 0
            end
        when Input::UP
            if selection == 7
                selection = 6
            elsif selection == 6
                selection = 4
            elsif selection < 3
                selection = 7
            else
                selection -= 3
            end
        when Input::DOWN
            if selection == 7
                selection = 1
            elsif selection == 6
                selection = 7
            elsif selection >= 3
                selection = 6
            else
                selection += 3
            end
        end
        return selection
    end

    def pbMark(selected, heldpoke)
        @sprites["markingbg"].visible = true
        @sprites["markingoverlay"].visible = true
        msg = _INTL("Mark your Pokémon.")
        msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
        msgwindow.viewport       = @viewport
        msgwindow.visible        = true
        msgwindow.letterbyletter = false
        msgwindow.text           = msg
        msgwindow.resizeHeightToFit(msg, Graphics.width - 180)
        pbBottomRight(msgwindow)
        base   = Color.new(248, 248, 248)
        shadow = Color.new(80, 80, 80)
        pokemon = heldpoke
        if heldpoke
            pokemon = heldpoke
        elsif selected[0] == -1
            pokemon = @storage.party[selected[1]]
        else
            pokemon = @storage.boxes[selected[0]][selected[1]]
        end
        markings = pokemon.markings
        index = 0
        redraw = true
        markrect = Rect.new(0, 0, 16, 16)
        loop do
            # Redraw the markings and text
            if redraw
                @sprites["markingoverlay"].bitmap.clear
                for i in 0...6
                    markrect.x = i * 16
                    markrect.y = (markings & (1 << i) != 0) ? 16 : 0
                    @sprites["markingoverlay"].bitmap.blt(336 + 58 * (i % 3), 106 + 50 * (i / 3), @markingbitmap.bitmap,
      markrect)
                end
                textpos = [
                    [_INTL("OK"), 402, 208, 2, base, shadow, 1],
                    [_INTL("Cancel"), 402, 272, 2, base, shadow, 1],
                ]
                pbDrawTextPositions(@sprites["markingoverlay"].bitmap, textpos)
                pbMarkingSetArrow(@sprites["arrow"], index)
                redraw = false
            end
            Graphics.update
            Input.update
            key = -1
            key = Input::DOWN if Input.repeat?(Input::DOWN)
            key = Input::RIGHT if Input.repeat?(Input::RIGHT)
            key = Input::LEFT if Input.repeat?(Input::LEFT)
            key = Input::UP if Input.repeat?(Input::UP)
            if key >= 0
                oldindex = index
                index = pbMarkingChangeSelection(key, index)
                pbPlayCursorSE if index != oldindex
                pbMarkingSetArrow(@sprites["arrow"], index)
            end
            update
            if Input.trigger?(Input::BACK)
                pbPlayCancelSE
                break
            elsif Input.trigger?(Input::USE)
                pbPlayDecisionSE
                if index == 6 # OK
                    pokemon.markings = markings
                    break
                elsif index == 7 # Cancel
                    break
                else
                    mask = (1 << index)
                    if (markings & mask) == 0
                        markings |= mask
                    else
                        markings &= ~mask
                    end
                    redraw = true
                end
            end
        end
        @sprites["markingbg"].visible      = false
        @sprites["markingoverlay"].visible = false
        msgwindow.dispose
    end

    def pbRefresh
        @sprites["box"].refresh
        @sprites["boxparty"].refresh
    end

    def pbHardRefresh
        oldPartyY = @sprites["boxparty"].y
        @sprites["box"].dispose
        @sprites["box"] = PokemonBoxSprite.new(@storage, @storage.currentBox, @boxviewport, @iconFadeProc)
        @sprites["boxparty"].dispose
        @sprites["boxparty"] = PokemonBoxPartySprite.new(@storage.party, @boxsidesviewport)
        @sprites["boxparty"].y = oldPartyY
    end

    def drawMarkings(bitmap, x, y, _width, _height, markings)
        markrect = Rect.new(0, 0, 16, 16)
        for i in 0...8
            markrect.x = i * 16
            markrect.y = (markings & (1 << i) != 0) ? 16 : 0
            bitmap.blt(x + i * 16, y, @markingbitmap.bitmap, markrect)
        end
    end

    def pbUpdateOverlay(selection, party = nil, forceUpdatePokemon = false)
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        buttonbase = Color.new(248, 248, 248)
        buttonshadow = Color.new(80, 80, 80)
        pbDrawTextPositions(overlay, [
                                [_INTL("Party: {1}", begin
                                    @storage.party.length
                                rescue StandardError
                                    0
                                end), 270, 326, 2, buttonbase, buttonshadow, 1,],
                                [_INTL("Exit"), 446, 326, 2, buttonbase, buttonshadow, 1],
                            ])
        pokemon = nil
        if @screen.pbHeldPokemon
            pokemon = @screen.pbHeldPokemon
        elsif selection >= 0
            pokemon = party ? party[selection] : @storage[@storage.currentBox, selection]
        end
        unless pokemon
            @sprites["pokemon"].visible = false
            return
        end
        @sprites["pokemon"].visible = true
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor
        nonbase   = Color.new(208, 208, 208)
        nonshadow = Color.new(224, 224, 224)
        pokename = pokemon.name
        textstrings = [
            [pokename, 10, 2, false, base, shadow],
        ]
        unless pokemon.egg?
            imagepos = []
            if pokemon.male?
                textstrings.push([_INTL("♂"), 148, 2, false, Color.new(24, 112, 216), Color.new(136, 168, 208)])
            elsif pokemon.female?
                textstrings.push([_INTL("♀"), 148, 2, false, Color.new(248, 56, 32), Color.new(224, 152, 144)])
            end
            lv_path = "Graphics/Pictures/Storage/overlay_lv"
            lv_path += "_dark" if darkMode?
            lv_path = addLanguageSuffix(lv_path)
            imagepos.push([lv_path, 6, 246])
            textstrings.push([pokemon.level.to_s, 28, 228, false, base, shadow])
            if pokemon.ability
                textstrings.push([pokemon.ability.name, 86, 300, 2, base, shadow])
            else
                textstrings.push([_INTL("No ability"), 86, 300, 2, nonbase, nonshadow])
            end
            if pokemon.firstItem
                textstrings.push([pokemon.firstItemData.name, 86, 336, 2, base, shadow])
            else
                textstrings.push([_INTL("No item"), 86, 336, 2, nonbase, nonshadow])
            end
            imagepos.push(["Graphics/Pictures/shiny", 156, 198]) if pokemon.shiny?
            typebitmap = AnimatedBitmap.new(addLanguageSuffix(("Graphics/Pictures/types")))
            type1_number = GameData::Type.get(pokemon.type1).id_number
            type2_number = GameData::Type.get(pokemon.type2).id_number
            type1rect = Rect.new(0, type1_number * 28, 64, 28)
            type2rect = Rect.new(0, type2_number * 28, 64, 28)
            if pokemon.type1 == pokemon.type2
                overlay.blt(52, 272, typebitmap.bitmap, type1rect)
            else
                overlay.blt(18, 272, typebitmap.bitmap, type1rect)
                overlay.blt(88, 272, typebitmap.bitmap, type2rect)
            end
            drawMarkings(overlay, 70, 240, 128, 20, pokemon.markings)
            pbDrawImagePositions(overlay, imagepos)
        end
        pbDrawTextPositions(overlay, textstrings)
        @sprites["pokemon"].setPokemonBitmap(pokemon) if forceUpdatePokemon || @sprites["pokemon"].pokemon != pokemon
    end

    def update
        pbUpdateSpriteHash(@sprites)
    end
end