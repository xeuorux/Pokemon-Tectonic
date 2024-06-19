#===============================================================================
#
#===============================================================================
class PokemonLoad_Scene
    def pbStartScene(commands, show_continue, trainer, frame_count, map_id)
        @commands = commands
        @sprites = {}
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_998
        addBackgroundOrColoredPlane(@sprites, "background", "loadbg", Color.new(248, 248, 248), @viewport)
        y = 16 * 2
        for i in 0...commands.length
            @sprites["panel#{i}"] = PokemonLoadPanel.new(i, commands[i],
               show_continue ? (i == 0) : false, trainer, frame_count, map_id, @viewport)
            @sprites["panel#{i}"].x = 24 * 2
            @sprites["panel#{i}"].y = y
            @sprites["panel#{i}"].pbRefresh
            y += (show_continue && i == 0) ? 112 * 2 : 24 * 2
        end
        @sprites["cmdwindow"] = Window_CommandPokemon.new([])
        @sprites["cmdwindow"].viewport = @viewport
        @sprites["cmdwindow"].visible  = false
    end

    def pbStartScene2
        pbFadeInAndShow(@sprites) { pbUpdate }
    end

    def pbStartDeleteScene
        @sprites = {}
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_998
        addBackgroundOrColoredPlane(@sprites, "background", "loadbg", Color.new(248, 248, 248), @viewport)
    end

    def pbUpdate
        oldi = begin
            @sprites["cmdwindow"].index
        rescue StandardError
            0
        end
        pbUpdateSpriteHash(@sprites)
        newi = begin
            @sprites["cmdwindow"].index
        rescue StandardError
            0
        end
        if oldi != newi
            @sprites["panel#{oldi}"].selected = false
            @sprites["panel#{oldi}"].pbRefresh
            @sprites["panel#{newi}"].selected = true
            @sprites["panel#{newi}"].pbRefresh
            while @sprites["panel#{newi}"].y > Graphics.height - 40 * 2
                for i in 0...@commands.length
                    @sprites["panel#{i}"].y -= 24 * 2
                end
                for i in 0...6
                    break unless @sprites["party#{i}"]
                    @sprites["party#{i}"].y -= 24 * 2
                end
                @sprites["player"].y -= 24 * 2 if @sprites["player"]
            end
            while @sprites["panel#{newi}"].y < 16 * 2
                for i in 0...@commands.length
                    @sprites["panel#{i}"].y += 24 * 2
                end
                for i in 0...6
                    break unless @sprites["party#{i}"]
                    @sprites["party#{i}"].y += 24 * 2
                end
                @sprites["player"].y += 24 * 2 if @sprites["player"]
            end
        end
    end

    def pbSetParty(trainer)
        return if !trainer || !trainer.party
        meta = GameData::Metadata.get_player(trainer.character_ID)
        if meta
            filename = pbGetPlayerCharset(meta, 1, trainer, true)
            @sprites["player"] = TrainerWalkingCharSprite.new(filename, @viewport)
            charwidth  = @sprites["player"].bitmap.width
            charheight = @sprites["player"].bitmap.height
            @sprites["player"].x        = 56 * 2 - charwidth / 8
            @sprites["player"].y        = 56 * 2 - charheight / 8
            @sprites["player"].src_rect = Rect.new(0, 0, charwidth / 4, charheight / 4)
        end
        for i in 0...trainer.party.length
            @sprites["party#{i}"] = PokemonIconSprite.new(trainer.party[i], @viewport)
            @sprites["party#{i}"].setOffset(PictureOrigin::Center)
            @sprites["party#{i}"].x = (167 + 33 * (i % 2)) * 2
            @sprites["party#{i}"].y = (56 + 25 * (i / 2)) * 2
            @sprites["party#{i}"].z = 99_999
        end
    end

    def pbChoose(commands)
        @sprites["cmdwindow"].commands = commands
        loop do
            Graphics.update
            Input.update
            pbUpdate
            return @sprites["cmdwindow"].index if Input.trigger?(Input::USE)
        end
    end

    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
    end

    def pbCloseScene
        pbDisposeSpriteHash(@sprites)
        @viewport.dispose
    end
end
