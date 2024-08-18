#===============================================================================
# Pokédex main screen
#===============================================================================
class PokemonPokedex_Scene
    MODENUMERICAL = 0
    MODEATOZ      = 1
    MODETALLEST   = 2
    MODESMALLEST  = 3
    MODEHEAVIEST  = 4
    MODELIGHTEST  = 5

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    def pbStartScene
        generateSpeciesUseData if $DEBUG
        generateSignaturesData if $DEBUG

        @sliderbitmap       	= AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_slider")
        @typebitmap         	= AnimatedBitmap.new(addLanguageSuffix("Graphics/Pictures/Pokedex/icon_types"))
        @shapebitmap        	= AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_shapes")
        @hwbitmap           	= AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_hw")
        @selbitmap          	= AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_searchsel")
        @searchsliderbitmap 	= AnimatedBitmap.new(addLanguageSuffix("Graphics/Pictures/Pokedex/icon_searchslider"))
        @search2Cursorbitmap	= AnimatedBitmap.new(addLanguageSuffix("Graphics/Pictures/Pokedex/cursor_search"))
        @sprites = {}
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_999
        list_path     = "Pokedex/bg_list"
        search_path   = "Pokedex/bg_search"
        search_2_path = "Pokedex/bg_search_2"
        if darkMode?
            list_path += "_dark"
            search_path += "_dark"
            search_2_path += "_dark"
        end
        addBackgroundPlane(@sprites, "background", list_path, @viewport)
        addBackgroundPlane(@sprites, "searchbg", search_path, @viewport)
        addBackgroundPlane(@sprites, "searchbg2", search_2_path, @viewport)
        @sprites["searchbg"].visible = false
        @sprites["searchbg2"].visible = false
        @sprites["pokedex"] = Window_Pokedex.new(206, 30, 276, 364, @viewport)
        @sprites["icon"] = PokemonSprite.new(@viewport)
        @sprites["icon"].setOffset(PictureOrigin::Center)
        @sprites["icon"].x = 112
        @sprites["icon"].y = 196
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        # @sprites["searchcursor"] = PokedexSearchSelectionSprite.new(@viewport)
        # @sprites["searchcursor"].visible = false
        @sprites["search2cursor"] = SpriteWrapper.new(@viewport)
        @sprites["search2cursor"].bitmap = @search2Cursorbitmap.bitmap
        @sprites["search2cursor"].visible = false
        
        @searchParams = [$PokemonGlobal.pokedexMode, -1, -1, -1, -1, -1, -1, -1, -1, -1]

        # Load stored search
        storedIndex = $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex]

        if $PokemonGlobal.stored_search
            @dexlist = $PokemonGlobal.stored_search
            @searchResults = true
            refreshDexListGraphics(0)
        else
            @searchResults = false
            pbRefreshDexList(storedIndex)
        end

        pbDeactivateWindows(@sprites)
        pbFadeInAndShow(@sprites)
    end

    def generateSpeciesUseData
        speciesUsed = {}
        GameData::Species.each do |species_data|
            next if species_data.form != 0
            speciesUsed[species_data.species] = []
        end

        GameData::Trainer.each do |trainerData|
            next if trainerData.getParentTrainer # Ignore sub-trainers
            next if trainerData.name_for_hashing
            trainerData.pokemon.each do |partyEntry|
                species = partyEntry[:species]
                speciesUsed[species]&.push(trainerData)
            end
        end

        @speciesUseData = {}
        speciesUsed.each do |species, arrayOfTrainerData|
            arrayOfTrainerData.uniq!
            arrayOfTrainerData.compact!
            regularTrainerUseCount = 0
            monumentTrainerUseCount = 0
            arrayOfTrainerData.each do |trainerData|
                if trainerData.monumentTrainer
                    monumentTrainerUseCount += 1
                else
                    regularTrainerUseCount += 1
                end
            end
            @speciesUseData[species] = [regularTrainerUseCount, monumentTrainerUseCount]
        end
    end

    def generateSignaturesData
        @signatureAbilities = getSignatureAbilities
        @signatureMoves	= getSignatureMoves
    end

    def pbEndScene
        pbFadeOutAndHide(@sprites)
        pbDisposeSpriteHash(@sprites)
        @sliderbitmap.dispose
        @typebitmap.dispose
        @shapebitmap.dispose
        @hwbitmap.dispose
        @selbitmap.dispose
        @searchsliderbitmap.dispose
        @viewport.dispose
        @search2Cursorbitmap.dispose
    end

    # Gets the region used for displaying Pokédex entries. Species will be listed
    # according to the given region's numbering and the returned region can have
    # any value defined in the town map data file. It is currently set to the
    # return value of pbGetCurrentRegion, and thus will change according to the
    # current map's MapPosition metadata setting.
    def pbGetPokedexRegion
        if Settings::USE_CURRENT_REGION_DEX
            region = pbGetCurrentRegion
            region = -1 if region >= $Trainer.pokedex.dexes_count - 1
            return region
        else
            return $PokemonGlobal.pokedexDex # National Dex -1, regional Dexes 0, 1, etc.
        end
    end

    # Determines which index of the array $PokemonGlobal.pokedexIndex to save the
    # "last viewed species" in. All regional dexes come first in order, then the
    # National Dex at the end.
    def pbGetSavePositionIndex
        index = pbGetPokedexRegion
        index = $Trainer.pokedex.dexes_count - 1 if index == -1 # National Dex (comes after regional Dex indices)
        return index
    end

    def pbCanAddForModeList?(mode, species)
        case mode
        when MODEATOZ
            return $Trainer.seen?(species)
        when MODEHEAVIEST, MODELIGHTEST, MODETALLEST, MODESMALLEST
            return $Trainer.owned?(species)
        end
        return true # For MODENUMERICAL
    end

    def pbGetDexList
        region = pbGetPokedexRegion
        regionalSpecies = pbAllRegionalSpecies(region)
        if !regionalSpecies || regionalSpecies.length == 0
            # If no Regional Dex defined for the given region, use the National Pokédex
            regionalSpecies = []
            GameData::Species.each { |s| regionalSpecies.push(s.id) if s.form == 0 }
        end
        shift = Settings::DEXES_WITH_OFFSETS.include?(region)
        ret = []
        regionalSpecies.each_with_index do |species, i|
            next if species.nil?
            
            speciesData = GameData::Species.get(species)
            next if speciesData.isTest? && !$DEBUG

            dexListEntry =
			{
				:species => species,
				:data => speciesData,
				:index => i + 1,
				:shift => shift,
			}

            ret.push(dexListEntry)
        end
        return ret
    end

    def searchStartingList
        return SEARCHES_STACK ? @dexlist : pbGetDexList
    end

    def autoDisqualifyFromSearch(species_sym)
        return !speciesInfoViewable?(species_sym)
    end

    def pbRefreshDexList(index = 0)
        dexlist = pbGetDexList
        # Sort species in ascending order by Regional Dex number
        dexlist.sort! do |a, b|
            valA = a[:data].id_number
            valB = b[:data].id_number
            valA -= 999_999 if $PokemonGlobal.speciesStarred?(a[:species])
            valB -= 999_999 if $PokemonGlobal.speciesStarred?(b[:species])
            next valA <=> valB
        end
        @dexlist = dexlist
        refreshDexListGraphics(index)
    end

    def refreshDexListGraphics(index)
        @sprites["pokedex"].commands = @dexlist
        @sprites["pokedex"].index = index
        @sprites["pokedex"].refresh
        path = @searchResults ? "Graphics/Pictures/Pokedex/bg_listsearch" : "Graphics/Pictures/Pokedex/bg_list"
        path += "_dark" if darkMode?
        @sprites["background"].setBitmap(path)
        pbRefresh
    end

    def pbRefresh
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor
        zBase = MessageConfig::LIGHT_TEXT_MAIN_COLOR
        zShadow = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
        iconspecies = @sprites["pokedex"].species
        iconspecies = nil if !speciesInfoViewable?(iconspecies)
        dexname = _INTL("MasterDex")
        textpos = [
            [dexname, Graphics.width / 8, -2, 2, zBase, zShadow],
        ]
        textpos.push([GameData::Species.get(iconspecies).name, 112, 46, 2, base, shadow]) if iconspecies

        if @searchResults
            textpos.push([_INTL("Search results"), 112, 302, 2, base, shadow])
            textpos.push([@dexlist.length.to_s, 112, 334, 2, base, shadow])
            textpos.push([_INTL("ACTION/Z to search further."), Graphics.width - 5, -2, 1, zBase, zShadow])
        else
            textpos.push([_INTL("ACTION/Z to search."), Graphics.width - 5, -2, 1, zBase, zShadow])
            textpos.push([_INTL("Seen:"), 42, 302, 0, base, shadow])
            textpos.push([$Trainer.pokedex.seen_count(pbGetPokedexRegion).to_s, 182, 302, 1, base, shadow])
            textpos.push([_INTL("Owned:"), 42, 334, 0, base, shadow])
            textpos.push([$Trainer.pokedex.owned_count(pbGetPokedexRegion).to_s, 182, 334, 1, base, shadow])
        end
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Set Pokémon sprite
        setIconBitmap(iconspecies)
        # Draw slider arrows
        itemlist = @sprites["pokedex"]
        showslider = false
        if itemlist.top_row > 0
            overlay.blt(468, 48, @sliderbitmap.bitmap, Rect.new(0, 0, 40, 30))
            showslider = true
        end
        if itemlist.top_item + itemlist.page_item_max < itemlist.itemCount
            overlay.blt(468, 346, @sliderbitmap.bitmap, Rect.new(0, 30, 40, 30))
            showslider = true
        end
        # Draw slider box
        if showslider
            sliderheight = 268
            boxheight = (sliderheight * itemlist.page_row_max / itemlist.row_max).floor
            boxheight += [(sliderheight - boxheight) / 2, sliderheight / 6].min
            boxheight = [boxheight.floor, 40].max
            y = 78
            y += ((sliderheight - boxheight) * itemlist.top_row / (itemlist.row_max - itemlist.page_row_max)).floor
            overlay.blt(468, y, @sliderbitmap.bitmap, Rect.new(40, 0, 40, 8))
            i = 0
            while i * 16 < boxheight - 8 - 16
                height = [boxheight - 8 - 16 - i * 16, 16].min
                overlay.blt(468, y + 8 + i * 16, @sliderbitmap.bitmap, Rect.new(40, 8, 40, height))
                i += 1
            end
            overlay.blt(468, y + boxheight - 16, @sliderbitmap.bitmap, Rect.new(40, 24, 40, 16))
        end
    end

    def pbRefreshDexSearch(params, _index)
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        base   = Color.new(248, 248, 248)
        shadow = Color.new(72, 72, 72)
        # Write various bits of text
        textpos = [
            [_INTL("Search Mode"), Graphics.width / 2, -2, 2, base, shadow],
            [_INTL("Order"), 136, 52, 2, base, shadow],
            [_INTL("Name"), 58, 110, 2, base, shadow],
            [_INTL("Type"), 58, 162, 2, base, shadow],
            [_INTL("Height"), 58, 214, 2, base, shadow],
            [_INTL("Weight"), 58, 266, 2, base, shadow],
            [_INTL("Color"), 326, 110, 2, base, shadow],
            [_INTL("Shape"), 454, 162, 2, base, shadow],
            [_INTL("Reset"), 80, 338, 2, base, shadow, 1],
            [_INTL("Start"), Graphics.width / 2, 338, 2, base, shadow, 1],
            [_INTL("Cancel"), Graphics.width - 80, 338, 2, base, shadow, 1],
        ]
        # Write order, name and color parameters
        textpos.push([@orderCommands[params[0]], 344, 58, 2, base, shadow, 1])
        textpos.push([(params[1] < 0) ? "----" : @nameCommands[params[1]], 176, 116, 2, base, shadow, 1])
        textpos.push([(params[8] < 0) ? "----" : @colorCommands[params[8]].name, 444, 116, 2, base, shadow, 1])
        # Draw type icons
        if params[2] >= 0
            type_number = @typeCommands[params[2]].id_number
            typerect = Rect.new(0, type_number * 32, 96, 32)
            overlay.blt(128, 168, @typebitmap.bitmap, typerect)
        else
            textpos.push(["----", 176, 168, 2, base, shadow, 1])
        end
        if params[3] >= 0
            type_number = @typeCommands[params[3]].id_number
            typerect = Rect.new(0, type_number * 32, 96, 32)
            overlay.blt(256, 168, @typebitmap.bitmap, typerect)
        else
            textpos.push(["----", 304, 168, 2, base, shadow, 1])
        end
        # Write height and weight limits
        ht1 = if params[4] < 0
                  0
              else
                  (params[4] >= @heightCommands.length) ? 999 : @heightCommands[params[4]]
              end
        ht2 = if params[5] < 0
                  999
              else
                  (params[5] >= @heightCommands.length) ? 0 : @heightCommands[params[5]]
              end
        wt1 = if params[6] < 0
                  0
              else
                  (params[6] >= @weightCommands.length) ? 9999 : @weightCommands[params[6]]
              end
        wt2 = if params[7] < 0
                  9999
              else
                  (params[7] >= @weightCommands.length) ? 0 : @weightCommands[params[7]]
              end
        hwoffset = false
        if System.user_language[3..4] == "US" # If the user is in the United States
            ht1 = (params[4] >= @heightCommands.length) ? 99 * 12 : (ht1 / 0.254).round
            ht2 = (params[5] < 0) ? 99 * 12 : (ht2 / 0.254).round
            wt1 = (params[6] >= @weightCommands.length) ? 99_990 : (wt1 / 0.254).round
            wt2 = (params[7] < 0) ? 99_990 : (wt2 / 0.254).round
            textpos.push([format("%d'%02d''", ht1 / 12, ht1 % 12), 166, 220, 2, base, shadow, 1])
            textpos.push([format("%d'%02d''", ht2 / 12, ht2 % 12), 294, 220, 2, base, shadow, 1])
            textpos.push([format("%.1f", wt1 / 10.0), 166, 272, 2, base, shadow, 1])
            textpos.push([format("%.1f", wt2 / 10.0), 294, 272, 2, base, shadow, 1])
            hwoffset = true
        else
            textpos.push([format("%.1f", ht1 / 10.0), 166, 220, 2, base, shadow, 1])
            textpos.push([format("%.1f", ht2 / 10.0), 294, 220, 2, base, shadow, 1])
            textpos.push([format("%.1f", wt1 / 10.0), 166, 272, 2, base, shadow, 1])
            textpos.push([format("%.1f", wt2 / 10.0), 294, 272, 2, base, shadow, 1])
        end
        overlay.blt(344, 214, @hwbitmap.bitmap, Rect.new(0, hwoffset ? 44 : 0, 32, 44))
        overlay.blt(344, 266, @hwbitmap.bitmap, Rect.new(32, hwoffset ? 44 : 0, 32, 44))
        # Draw shape icon
        if params[9] >= 0
            shape_number = @shapeCommands[params[9]].id_number
            shaperect = Rect.new(0, (shape_number - 1) * 60, 60, 60)
            overlay.blt(424, 218, @shapebitmap.bitmap, shaperect)
        end
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
    end

    def pbRefreshDexSearchParam(mode, cmds, sel, _index)
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        base   = Color.new(248, 248, 248)
        shadow = Color.new(72, 72, 72)
        # Write various bits of text
        textpos = [
            [_INTL("Search Mode"), Graphics.width / 2, -2, 2, base, shadow],
            [_INTL("OK"), 80, 338, 2, base, shadow, 1],
            [_INTL("Cancel"), Graphics.width - 80, 338, 2, base, shadow, 1],
        ]
        title = [_INTL("Order"), _INTL("Name"), _INTL("Type"), _INTL("Height"),
                 _INTL("Weight"), _INTL("Color"), _INTL("Shape"),][mode]
        textpos.push([title, 102, (mode == 6) ? 58 : 52, 0, base, shadow])
        case mode
        when 0   # Order
            xstart = 46
            ystart = 128
            xgap = 236
            ygap = 64
            halfwidth = 92
            cols = 2
            selbuttony = 0
            selbuttonheight = 44
        when 1   # Name
            xstart = 78
            ystart = 114
            xgap = 52
            ygap = 52
            halfwidth = 22
            cols = 7
            selbuttony = 156
            selbuttonheight = 44
        when 2   # Type
            xstart = 8
            ystart = 104
            xgap = 124
            ygap = 44
            halfwidth = 62
            cols = 4
            selbuttony = 44
            selbuttonheight = 44
        when 3, 4 # Height, weight
            xstart = 44
            ystart = 110
            xgap = 304 / (cmds.length + 1)
            ygap = 112
            halfwidth = 60
            cols = cmds.length + 1
        when 5   # Color
            xstart = 62
            ystart = 114
            xgap = 132
            ygap = 52
            halfwidth = 62
            cols = 3
            selbuttony = 44
            selbuttonheight = 44
        when 6   # Shape
            xstart = 82
            ystart = 116
            xgap = 70
            ygap = 70
            halfwidth = 0
            cols = 5
            selbuttony = 88
            selbuttonheight = 68
        end
        # Draw selected option(s) text in top bar
        case mode
        when 2   # Type icons
            for i in 0...2
                if !sel[i] || sel[i] < 0
                    textpos.push(["----", 298 + 128 * i, 58, 2, base, shadow, 1])
                else
                    type_number = @typeCommands[sel[i]].id_number
                    typerect = Rect.new(0, type_number * 32, 96, 32)
                    overlay.blt(250 + 128 * i, 58, @typebitmap.bitmap, typerect)
                end
            end
        when 3   # Height range
            ht1 = if sel[0] < 0
                      0
                  else
                      (sel[0] >= @heightCommands.length) ? 999 : @heightCommands[sel[0]]
                  end
            ht2 = if sel[1] < 0
                      999
                  else
                      (sel[1] >= @heightCommands.length) ? 0 : @heightCommands[sel[1]]
                  end
            hwoffset = false
            if System.user_language[3..4] == "US" # If the user is in the United States
                ht1 = (sel[0] >= @heightCommands.length) ? 99 * 12 : (ht1 / 0.254).round
                ht2 = (sel[1] < 0) ? 99 * 12 : (ht2 / 0.254).round
                txt1 = format("%d'%02d''", ht1 / 12, ht1 % 12)
                txt2 = format("%d'%02d''", ht2 / 12, ht2 % 12)
                hwoffset = true
            else
                txt1 = format("%.1f", ht1 / 10.0)
                txt2 = format("%.1f", ht2 / 10.0)
            end
            textpos.push([txt1, 286, 58, 2, base, shadow, 1])
            textpos.push([txt2, 414, 58, 2, base, shadow, 1])
            overlay.blt(462, 52, @hwbitmap.bitmap, Rect.new(0, hwoffset ? 44 : 0, 32, 44))
        when 4 # Weight range
            wt1 = if sel[0] < 0
                      0
                  else
                      (sel[0] >= @weightCommands.length) ? 9999 : @weightCommands[sel[0]]
                  end
            wt2 = if sel[1] < 0
                      9999
                  else
                      (sel[1] >= @weightCommands.length) ? 0 : @weightCommands[sel[1]]
                  end
            hwoffset = false
            if System.user_language[3..4] == "US" # If the user is in the United States
                wt1 = (sel[0] >= @weightCommands.length) ? 99_990 : (wt1 / 0.254).round
                wt2 = (sel[1] < 0) ? 99_990 : (wt2 / 0.254).round
                txt1 = format("%.1f", wt1 / 10.0)
                txt2 = format("%.1f", wt2 / 10.0)
                hwoffset = true
            else
                txt1 = format("%.1f", wt1 / 10.0)
                txt2 = format("%.1f", wt2 / 10.0)
            end
            textpos.push([txt1, 286, 58, 2, base, shadow, 1])
            textpos.push([txt2, 414, 58, 2, base, shadow, 1])
            overlay.blt(462, 52, @hwbitmap.bitmap, Rect.new(32, hwoffset ? 44 : 0, 32, 44))
        when 5   # Color
            if sel[0] < 0
                textpos.push(["----", 362, 58, 2, base, shadow, 1])
            else
                textpos.push([cmds[sel[0]].name, 362, 58, 2, base, shadow, 1])
            end
        when 6   # Shape icon
            if sel[0] >= 0
                shaperect = Rect.new(0, (@shapeCommands[sel[0]].id_number - 1) * 60, 60, 60)
                overlay.blt(332, 50, @shapebitmap.bitmap, shaperect)
            end
        else
            if sel[0] < 0
                text = ["----", "-", "----", "", "", "----", ""][mode]
                textpos.push([text, 362, 58, 2, base, shadow, 1])
            else
                textpos.push([cmds[sel[0]], 362, 58, 2, base, shadow, 1])
            end
        end
        # Draw selected option(s) button graphic
        if [3, 4].include?(mode) # Height, weight
            xpos1 = xstart + (sel[0] + 1) * xgap
            xpos1 = xstart if sel[0] < -1
            xpos2 = xstart + (sel[1] + 1) * xgap
            xpos2 = xstart + cols * xgap if sel[1] < 0
            xpos2 = xstart if sel[1] >= cols - 1
            ypos1 = ystart + 172
            ypos2 = ystart + 28
            overlay.blt(16, 120, @searchsliderbitmap.bitmap, Rect.new(0, 192, 32, 44)) if sel[1] < cols - 1
            overlay.blt(464, 120, @searchsliderbitmap.bitmap, Rect.new(32, 192, 32, 44)) if sel[1] >= 0
            overlay.blt(16, 264, @searchsliderbitmap.bitmap, Rect.new(0, 192, 32, 44)) if sel[0] >= 0
            overlay.blt(464, 264, @searchsliderbitmap.bitmap, Rect.new(32, 192, 32, 44)) if sel[0] < cols - 1
            hwrect = Rect.new(0, 0, 120, 96)
            overlay.blt(xpos2, ystart, @searchsliderbitmap.bitmap, hwrect)
            hwrect.y = 96
            overlay.blt(xpos1, ystart + ygap, @searchsliderbitmap.bitmap, hwrect)
            textpos.push([txt1, xpos1 + halfwidth, ypos1, 2, base, nil, 1])
            textpos.push([txt2, xpos2 + halfwidth, ypos2, 2, base, nil, 1])
        else
            for i in 0...sel.length
                if sel[i] >= 0
                    selrect = Rect.new(0, selbuttony, @selbitmap.bitmap.width, selbuttonheight)
                    overlay.blt(xstart + (sel[i] % cols) * xgap, ystart + (sel[i] / cols).floor * ygap, @selbitmap.bitmap,
  selrect)
                else
                    selrect = Rect.new(0, selbuttony, @selbitmap.bitmap.width, selbuttonheight)
                    overlay.blt(xstart + (cols - 1) * xgap, ystart + (cmds.length / cols).floor * ygap, @selbitmap.bitmap,
  selrect)
                end
            end
        end
        # Draw options
        case mode
        when 0, 1 # Order, name
            for i in 0...cmds.length
                x = xstart + halfwidth + (i % cols) * xgap
                y = ystart + 6 + (i / cols).floor * ygap
                textpos.push([cmds[i], x, y, 2, base, shadow, 1])
            end
            if mode != 0
                textpos.push([(mode == 1) ? "-" : "----",
                              xstart + halfwidth + (cols - 1) * xgap, ystart + 6 + (cmds.length / cols).floor * ygap, 2, base, shadow, 1,])
            end
        when 2   # Type
            typerect = Rect.new(0, 0, 96, 32)
            for i in 0...cmds.length
                typerect.y = @typeCommands[i].id_number * 32
                overlay.blt(xstart + 14 + (i % cols) * xgap, ystart + 6 + (i / cols).floor * ygap, @typebitmap.bitmap,
    typerect)
            end
            textpos.push(["----",
                          xstart + halfwidth + (cols - 1) * xgap, ystart + 6 + (cmds.length / cols).floor * ygap, 2, base, shadow, 1,])
        when 5   # Color
            for i in 0...cmds.length
                x = xstart + halfwidth + (i % cols) * xgap
                y = ystart + 6 + (i / cols).floor * ygap
                textpos.push([cmds[i].name, x, y, 2, base, shadow, 1])
            end
            textpos.push(["----",
                          xstart + halfwidth + (cols - 1) * xgap, ystart + 6 + (cmds.length / cols).floor * ygap, 2, base, shadow, 1,])
        when 6   # Shape
            shaperect = Rect.new(0, 0, 60, 60)
            for i in 0...cmds.length
                shaperect.y = (@shapeCommands[i].id_number - 1) * 60
                overlay.blt(xstart + 4 + (i % cols) * xgap, ystart + 4 + (i / cols).floor * ygap, @shapebitmap.bitmap,
      shaperect)
            end
        end
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
    end

    def setIconBitmap(species)
        gender, form = $Trainer.pokedex.last_form_seen(species)
        @sprites["icon"].setSpeciesBitmap(species, gender, form)
    end

    def pbCloseSearch
        oldsprites = pbFadeOutAndHide(@sprites)
        oldspecies = @sprites["pokedex"].species
        @searchResults = false
        $PokemonGlobal.stored_search = nil
        $PokemonGlobal.pokedexMode = MODENUMERICAL
        @searchParams = [$PokemonGlobal.pokedexMode, -1, -1, -1, -1, -1, -1, -1, -1, -1]
        pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
        for i in 0...@dexlist.length
            next if @dexlist[i][:species] != oldspecies
            @sprites["pokedex"].index = i
            pbRefresh
            break
        end
        $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index
        pbFadeInAndShow(@sprites, oldsprites)
    end

    def updateSearch2Cursor(index)
        if index >= 6
            index -= 6
            shiftRightABit = true
        end
        @sprites["search2cursor"].x = index.even? ? 72 : 296
        @sprites["search2cursor"].x += 4 if shiftRightABit
        @sprites["search2cursor"].y = 62 + index / 2 * 96
    end

    def pbDexEntry(index)
        oldsprites = pbFadeOutAndHide(@sprites)
        region = -1
        unless Settings::USE_CURRENT_REGION_DEX
            dexnames = Settings.pokedex_names
            region = dexnames[pbGetSavePositionIndex][1] if dexnames[pbGetSavePositionIndex].is_a?(Array)
        end

        while true
            scene = PokemonPokedexInfo_Scene.new
            screen = PokemonPokedexInfoScreen.new(scene)
            ret = screen.pbStartScreen(@dexlist, index, region, true)

            # If given a species symbol, we move directly to that species
            if ret.is_a?(Symbol)
                # Find the species slot on the existing dexlist, if there
                currentListIndex = -1
                @dexlist.each_with_index do |dexListEntry, index|
                    next if dexListEntry[:species] != ret
                    currentListIndex = index
                    break
                end

                if @searchResults && currentListIndex < 0
                    # Species isn't in the current search, so scrap that search and go to it through its index on a reset dexlist
                    @dexlist = pbGetDexList
                    @searchResults = false
                    path = "Graphics/Pictures/Pokedex/bg_list"
                    path += "_dark" if darkMode?
                    @sprites["background"].setBitmap(path)
                    @sprites["pokedex"].commands = @dexlist

                    @dexlist.each_with_index do |dexListEntry, index|
                        next if dexListEntry[:species] != ret
                        currentListIndex = index
                        break
                    end

                    ret = currentListIndex
                end

                index = currentListIndex
                @sprites["pokedex"].index = index
                next
            # Otherwise, we were given the last looked index of the current dexlist
            # Go back to the main pokedex menu, at that index
            else
                @sprites["pokedex"].index = ret
                break
            end
        end

        @sprites["pokedex"].refresh
        pbRefresh
        pbFadeInAndShow(@sprites, oldsprites)
    end

	SEARCH_METHODS_INDEX = [
		:searchBySpeciesName,
		:searchByType,
		:searchByAbility,
		:searchByMoveLearned,
		:searchByEvolutionMethod,
		:searchByAvailableLevel,
		:searchByTribe,
		:searchByTypeMatchup,
		:searchByStatComparison,
		:sortByStat,
		:searchByMisc,
		:sortByOther,
	]

    def pbDexSearch
        # Prepare to start the search screen
        oldsprites = pbFadeOutAndHide(@sprites)
        @sprites["searchbg"].visible = true
        @sprites["overlay"].visible = true
        @sprites["search2cursor"].visible = true
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        index = 0
        updateSearch2Cursor(index)
        oldindex = index

        # Write the button names onto the overlay
        base   = MessageConfig.pbDefaultTextMainColor
        shadow = MessageConfig.pbDefaultTextShadowColor
        title_base   = MessageConfig::LIGHT_TEXT_MAIN_COLOR
        title_shadow = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
        xLeft = 92
        xLeft2 = 316
        page1textpos = [
            [_INTL("Choose a Search"), Graphics.width / 2, -2, 2, title_base, title_shadow],
            [_INTL("Name"), xLeft, 68, 0, base, shadow],
            [_INTL("Types"), xLeft2, 68, 0, base, shadow],
            [_INTL("Abilities"), xLeft, 164, 0, base, shadow],
            [_INTL("Moves"), xLeft2, 164, 0, base, shadow],
            [_INTL("Evolution"), xLeft, 260, 0, base, shadow],
            [_INTL("Available"), xLeft2, 260, 0, base, shadow],
        ]
        xLeft += 4
        xLeft2 += 4
        page2textpos = [
            [_INTL("Choose a Search"), Graphics.width / 2, -2, 2, title_base, title_shadow],
            [_INTL("Tribe"), xLeft, 68, 0, base, shadow],
            [_INTL("Matchups"), xLeft2, 68, 0, base, shadow],
            [_INTL("Stats"), xLeft, 164, 0, base, shadow],
            [_INTL("Stat Sort"), xLeft2, 164, 0, base, shadow],
            [_INTL("Filters"), xLeft, 260, 0, base, shadow],
            [_INTL("Sorts"), xLeft2, 260, 0, base, shadow],
        ]
        pbDrawTextPositions(overlay, page1textpos)

        # Begin the search screen
        pbFadeInAndShow(@sprites)
        oldIndex = 0
        loop do
            if index != oldIndex
                pbPlayCursorSE

                if oldIndex < 6 && index >= 6
                    pbFadeOutAndHide(@sprites)
                    overlay.clear
                    pbDrawTextPositions(overlay, page2textpos)
                    @sprites["searchbg2"].visible = true
                    @sprites["overlay"].visible = true
                    @sprites["search2cursor"].visible = true
                elsif oldIndex >= 6 && index < 6
                    pbFadeOutAndHide(@sprites)
                    overlay.clear
                    pbDrawTextPositions(overlay, page1textpos)
                    @sprites["searchbg"].visible     = true
                    @sprites["overlay"].visible      = true
                    @sprites["search2cursor"].visible = true
                end

                updateSearch2Cursor(index)
                oldIndex = index
            end

            Graphics.update
            Input.update
            pbUpdate

            if Input.trigger?(Input::UP)
                index -= 2 unless [0, 1, 6, 7].include?(index)
            elsif Input.trigger?(Input::DOWN)
                index += 2 unless [4, 5, 10, 11].include?(index)
            elsif Input.trigger?(Input::LEFT)
                if index.odd?
                    index -= 1
                elsif [6, 8, 10].include?(index)
                    index -= 5
                end
            elsif Input.trigger?(Input::RIGHT)
                if index.even?
                    index += 1
                elsif [1, 3, 5].include?(index)
                    index += 5
                end
            elsif Input.trigger?(Input::BACK)
                pbPlayCloseMenuSE
                break
            elsif Input.trigger?(Input::USE)
				searchChanged = acceptSearchResults2 do
					send SEARCH_METHODS_INDEX[index]
				end
                if searchChanged
                    break
                else
                    pbPlayCloseMenuSE
                end
            end
        end
        pbFadeOutAndHide(@sprites)
        path = @searchResults ? "Graphics/Pictures/Pokedex/bg_listsearch" : "Graphics/Pictures/Pokedex/bg_list"
        path += "_dark" if darkMode?
        @sprites["background"].setBitmap(path)
        pbRefresh
        pbFadeInAndShow(@sprites, oldsprites)
        Input.update
    end

    def acceptSearchResults(&searchingBlock)
        pbPlayDecisionSE
        @sprites["pokedex"].active = false
        begin
            dexlist = searchingBlock.call
            if !dexlist
            # Do nothing
            elsif dexlist.length == 0
                if @searchResults
                    pbMessage(_INTL("Attempted to do a combined search, but no matching Pokémon were found."))
                else
                    pbMessage(_INTL("No matching Pokémon were found."))
                end
            else
                @dexlist = dexlist
                @sprites["pokedex"].commands = @dexlist
                @sprites["pokedex"].index    = 0
                @sprites["pokedex"].refresh
                @searchResults = true
                path = "Graphics/Pictures/Pokedex/bg_listsearch"
                path += "_dark" if darkMode?
                @sprites["background"].setBitmap(path)
            end
        rescue StandardError
            pbMessage(_INTL("An unknown error has occured."))
        end
        @sprites["pokedex"].active = true
        pbRefresh
    end

    def acceptSearchResults2(&searchingBlock)
        pbPlayDecisionSE
        begin
            dexlist = searchingBlock.call
            if !dexlist
            # Do nothing
            elsif dexlist.length == 0
                if @searchResults
                    pbMessage(_INTL("Attempted to do a combined search, but no matching Pokémon were found."))
                else
                    pbMessage(_INTL("No matching Pokémon were found."))
                end
            else
                @dexlist = dexlist
                @sprites["pokedex"].commands = @dexlist
                @sprites["pokedex"].index    = 0
                @sprites["pokedex"].refresh
                @searchResults = true
                return true
            end
        rescue StandardError
            pbMessage(_INTL("An unknown error has occured."))
        end
        return false
    end

    def pbPokedex
        pbActivateWindow(@sprites, "pokedex") do
            loop do
                Graphics.update
                Input.update
                oldindex = @sprites["pokedex"].index
                pbUpdate
                # zOverlay = @sprites["overlay"].bitmap
                # zTextpos = [[_INTL("Press Z or SHIFT to search.") ,Graphics.width/4*3,Graphics.height,0,Color.new(104,104,104),Color.new(248,248,248)]]
                # pbDrawTextPositions(zOverlay,zTextpos)
                if oldindex != @sprites["pokedex"].index
                    unless @searchResults
                        $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] =
                            @sprites["pokedex"].index
                    end
                    pbRefresh
                end
                if Input.trigger?(Input::ACTION)
                    pbPlayDecisionSE
                    @sprites["pokedex"].active = false
                    pbDexSearch
                    @sprites["pokedex"].active = true
                elsif Input.trigger?(Input::BACK)
                    if @searchResults
                        if Input.press?(Input::CTRL)
                            $PokemonGlobal.stored_search = @dexlist
                            pbPlayCloseMenuSE
                            break
                        else
                            pbPlayCancelSE
                            pbCloseSearch
                        end
                    # storeCommand = -1
                    # cancelCommand = -1
                    # cancelAndCloseCommand = -1
                    # commands = []
                    # # commands[cancelCommand = commands.length] = _INTL("Cancel Search")
                    # # commands[cancelAndCloseCommand = commands.length] = _INTL("Cancel Search and Exit")
                    # # commands[storeCommand = commands.length] = _INTL("Store Search and Exit")
                    # # result = pbMessage(_INTL("You have an active search. What would you like to do?"),commands,0)
                    # # if result == storeCommand
                    # # 	$PokemonGlobal.stored_search = @dexlist
                    # # 	pbPlayCloseMenuSE
                    # # 	break
                    # # elsif result == cancelCommand
                    # # 	pbPlayCancelSE
                    # # 	pbCloseSearch
                    # # elsif result == cancelAndCloseCommand
                    # # 	pbCloseSearch
                    # # 	pbPlayCloseMenuSE
                    # # 	break
                    # # end
                    else
                        pbPlayCloseMenuSE
                        break
                    end
                elsif Input.trigger?(Input::USE)
                    if speciesInfoViewable?(@sprites["pokedex"].species)
                        pbPlayDecisionSE
                        pbDexEntry(@sprites["pokedex"].index)
                    end
                elsif Input.trigger?(Input::SPECIAL)
                    if $PokemonGlobal.toggleStarred(@sprites["pokedex"].species)
                        pbPlayDecisionSE
                    else
                        pbPlayCancelSE
                    end
                    @sprites["pokedex"].refresh
                elsif Input.pressex?(0x52) # R, for Random
                    @sprites["pokedex"].index = rand(@dexlist.length)
                    @sprites["pokedex"].refresh
                    pbRefresh
                elsif Input.pressex?(0x47) && $DEBUG # G, for Get
                    if debugControl
                        @dexlist.each do |dexlist_entry|
                            entrySpecies = dexlist_entry[:species]
                            pbAddPokemonSilent(entrySpecies, getLevelCap)
                        end
                        pbMessage(_INTL("Added every species on the current list!"))
                    else
                        pbAddPokemonSilent(@sprites["pokedex"].species, getLevelCap)
                        pbMessage(_INTL("Added #{@sprites['pokedex'].species}"))
                    end
                elsif Input.pressex?(0x57) && $DEBUG # W, for Wild Pokemon
                    pbWildBattle(@sprites["pokedex"].species, getLevelCap)
                elsif Input.pressex?(0x42) && $DEBUG # B, for Boss
                    begin
                        species = @sprites["pokedex"].species
                        if GameData::Species.get(species).isLegendary?
                            pbBigAvatarBattle([species.to_sym, getLevelCap])
                        else
                            pbSmallAvatarBattle([species.to_sym, getLevelCap])
                        end
                    rescue StandardError
                        pbMessage(_INTL("Unable to start Avatar battle."))
                    end
                elsif Input.pressex?(0x4F) && $DEBUG # O, for Own
                    @dexlist.each do |dexlist_entry|
                        entrySpecies = dexlist_entry[:species]
                        $Trainer.pokedex.set_owned(entrySpecies, false)
                    end
                    pbMessage(_INTL("Marked as owned every species on current list."))
                elsif Input.pressex?(0x50) && $DEBUG # P, for Print
                    echoln("Printing the entirety of the current dex list.")
                    if Input.press?(Input::CTRL)
                        @dexlist.each do |dexEntry|
                            echoln(dexEntry[:species])
                        end
                    else
                        @dexlist.each do |dexEntry|
                            echoln(GameData::Species.get(dexEntry[:species]).real_name)
                        end
                    end
                    pbMessage(_INTL("Printed the current list to the console."))
                elsif Input.pressex?(0x49) && $DEBUG # I, for Investigation
                    printDexListInvestigation
                elsif Input.pressex?(0x54) && $DEBUG # T, for Tutor
                    modifyTutorLearnability
                elsif Input.pressex?(0x46) && $DEBUG # F, for Filter
                    acceptSearchResults do
                        debugFilterToRegularLine
                    end
				else
					for key_index in 1..6 do
						if Input.pressex?("NUMBER_#{key_index}".to_sym)
							searchIndex = key_index - 1
							searchIndex += 6 if Input.press?(Input::CTRL)
							acceptSearchResults do
								send SEARCH_METHODS_INDEX[searchIndex]
							end
						end
					end
                end
            end
        end
    end

    #### DEBUG FUNCTIONALITY ###

    def debugFilterToRegularLine
        dexlist = searchStartingList
        dexlist = dexlist.find_all do |dex_item|
            next !dex_item[:data].isLegendary? && dex_item[:data].get_evolutions.length == 0
        end
        return dexlist
    end

    def modifyTutorLearnability
        while true
            moveNameInput = pbEnterText("Move name...", 0, 20)
            if moveNameInput && moveNameInput != ""
                actualMoveID = nil
                GameData::Move.each do |moveData|
                    if moveData.real_name.downcase == moveNameInput.downcase
                        actualMoveID = moveData.id
                        break
                    end
                end
                if actualMoveID.nil?
                    pbMessage(_INTL("Invalid input: {1}", moveNameInput))
                    next
                end

                tutorActionSelection = pbMessage("Do what with #{actualMoveID}?",
[_INTL("Teach"), _INTL("Remove"), _INTL("Replace"), _INTL("Cancel")], 4)
                return if tutorActionSelection == 3

                if tutorActionSelection == 2
                    while true
                        replacementMoveNameInput = pbEnterText("Move name...", 0, 16)
                        if replacementMoveNameInput && replacementMoveNameInput != ""
                            replacementActualMoveID = nil
                            GameData::Move.each do |moveData|
                                if moveData.real_name.downcase == replacementMoveNameInput.downcase
                                    replacementActualMoveID = moveData.id
                                    break
                                end
                            end
                            if replacementActualMoveID.nil?
                                pbMessage(_INTL("Invalid input: {1}", replacementMoveNameInput))
                                next
                            end
                        end
                        break
                    end
                end

                lineBehaviourSelection = pbMessage("Tutor or line moves?",
[_INTL("Line"), _INTL("Tutor"), _INTL("Cancel")], 3)
                return if lineBehaviourSelection == 2

                speciesToEdit = []
                @dexlist.each do |dexlist_entry|
                    species = dexlist_entry[0]
                    speciesData = GameData::Species.get(species)

                    # Grab the prevos and evos
                    if lineBehaviourSelection == 1
                        speciesToEdit.push(species)
                        getPrevosInLineAsList(speciesData).each do |prevoSpecies|
                            speciesToEdit.push(prevoSpecies)
                        end
                        getEvosInLineAsList(speciesData).each do |evoSpecies|
                            speciesToEdit.push(evoSpecies)
                        end
                    else
                        speciesToEdit.push(speciesData.get_line_start.id)
                    end
                end

                speciesToEdit.uniq!
                speciesToEdit.compact!

                speciesEdited = 0

                if tutorActionSelection == 0
                    echoln("Adding #{actualMoveID} to tutorable movesets:")
                    speciesToEdit.each do |species|
                        speciesData = GameData::Species.get(species)
                        movesList = [speciesData.egg_moves, speciesData.tutor_moves][lineBehaviourSelection]
                        movesList = speciesData.tutor_moves if speciesData.is_solitary?
                        next if movesList.include?(actualMoveID)
                        movesList.push(actualMoveID)
                        echoln(species)
                        speciesEdited += 1
                    end
                elsif tutorActionSelection == 1
                    echoln("Deleting #{actualMoveID} from tutorable movesets:")
                    speciesToEdit.each do |species|
                        speciesData = GameData::Species.get(species)
                        movesList = [speciesData.egg_moves, speciesData.tutor_moves][lineBehaviourSelection]
                        movesList = speciesData.tutor_moves if speciesData.is_solitary?
                        next unless movesList.include?(actualMoveID)
                        movesList.delete(actualMoveID)
                        echoln(species)
                        speciesEdited += 1
                    end
                elsif tutorActionSelection == 2
                    echoln("Replacing #{actualMoveID} in tutorable movesets with #{replacementActualMoveID}:")
                    speciesToEdit.each do |species|
                        speciesData = GameData::Species.get(species)
                        movesList = [speciesData.egg_moves, speciesData.tutor_moves][lineBehaviourSelection]
                        movesList = speciesData.tutor_moves if speciesData.is_solitary?
                        next unless movesList.include?(actualMoveID)
                        next if movesList.include?(replacementActualMoveID)
                        movesList.delete(actualMoveID)
                        movesList.push(replacementActualMoveID)
                        echoln(species)
                        speciesEdited += 1
                    end
                end
                pbMessage(_INTL("#{speciesEdited} species tutorable movesets edited!"))

                GameData::Species.save
                Compiler.write_pokemon
            end
            break
        end
    end

    def printDexListInvestigation
        # Find information about the currently displayed list
        typesCount = {}
        GameData::Type.each do |typesData|
            next if typesData.id == :QMARKS
            typesCount[typesData.id] = 0
        end
        total = 0
        @dexlist.each do |dexEntry|
            speciesData = GameData::Species.get(dexEntry[0])
            disqualify = false
            speciesData.get_evolutions.each do |evolutionEntry|
                evoSpecies = evolutionEntry[0]
                @dexlist.each do |searchDexEntry|
                    disqualify = true if searchDexEntry[0] == evoSpecies
                    break if disqualify
                end
                break if disqualify
            end
            next if disqualify
            typesCount[speciesData.type1] += 1
            typesCount[speciesData.type2] += 1 if speciesData.type2 != speciesData.type1
            total += 1
        end

        typesCount = typesCount.sort_by { |_type, count| -count }

        # Find information about the whole game list

        wholeGameTypesCount = {}
        GameData::Type.each do |typesData|
            next if typesData.id == :QMARKS
            wholeGameTypesCount[typesData.id] = 0
        end
        pbGetDexList.each do |dexEntry|
            speciesData = GameData::Species.get(dexEntry[0])
            next if speciesData.isLegendary?
            next if speciesData.get_evolutions.length > 0
            wholeGameTypesCount[speciesData.type1] += 1
            wholeGameTypesCount[speciesData.type2] += 1 if speciesData.type2 != speciesData.type1
        end

        # Display investigation

        echoln("Investigation of the currently displayed dexlist:")
        echoln("Type,Count,PercentOfCurrentList,PercentageTypeCompletion")
        typesCount.each do |type, count|
            percentOfThisList = ((count.to_f / total.to_f) * 10_000).floor / 100.0
            percentOfTypeIsInThisMap = ((count.to_f / wholeGameTypesCount[type].to_f) * 10_000).floor / 100.0
            echoln("#{type},#{count},#{percentOfThisList},#{percentOfTypeIsInThisMap}")
        end
    end
end

#===============================================================================
#
#===============================================================================
class PokemonPokedexScreen
    def initialize(scene)
        @scene = scene
    end

    def pbStartScreen
        @scene.pbStartScene
        @scene.pbPokedex
        @scene.pbEndScene
    end
end
