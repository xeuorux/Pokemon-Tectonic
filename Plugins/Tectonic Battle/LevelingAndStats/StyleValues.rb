COMBINE_ATTACKING_STATS = true
STYLE_VALUE_TOTAL = 50
DEFAULT_STYLE_VALUE = 10
STYLE_VALUE_MAX = 20

def pbStyleValueScreen(pkmn)
    unless teamEditingAllowed?
        showNoTeamEditingMessage
        return
    end
    pbFadeOutIn do
        scene = StyleValueScene.new
        screen = StyleValueScreen.new(scene)
        screen.pbStartScreen(pkmn)
    end
end

class StyleValueScene
    attr_accessor :index
    attr_accessor :pool

    def pbDisplay(msg, brief = false)
        UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
    end

    def pbConfirm(msg)
        UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
    end

    def pbShowCommands(helptext,commands,initcmd=0)
        UIHelper.pbShowCommands(@sprites["msgwindow"], helptext, commands, initcmd) { pbUpdate }
    end

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    BASE_X = 48

    def pbStartScene(pokemon)
        @pokemon = pokemon
        @pool = 0
        # Create sprite hash
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_999
        @sprites = {}
        addBackgroundPlane(@sprites, "bg", "stylevaluesbg", @viewport)
        @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
        @sprites["pokeicon"].setOffset(PictureOrigin::Center)
        @sprites["pokeicon"].x = 36
        @sprites["pokeicon"].y = 36
        @sprites["pokeicon"].visible = false
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
        @sprites["msgwindow"].visible = false
        @sprites["msgwindow"].viewport = @viewport

        # Create the left and right arrow sprites which surround the selected index
        @index = 0
        @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
        @sprites["leftarrow"].x       = BASE_X + 2
        @sprites["leftarrow"].y       = 78
        @sprites["leftarrow"].play
        @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
        @sprites["rightarrow"].x       = BASE_X + 158
        @sprites["rightarrow"].y       = 78
        @sprites["rightarrow"].play

        # CALL COMPLEX SCENE DRAWING METHODS HERE #
        drawNameAndStats

        pbDeactivateWindows(@sprites)
        # Fade in all sprites
        pbFadeInAndShow(@sprites)
    end

    def drawNameAndStats
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        base = Color.new(248, 248, 248)
        shadow = Color.new(104, 104, 104)

        subtleBase = Color.new(200,200,200)
        subtleShadow = Color.new(140,140,140)

        styleValueLabelX = BASE_X + 38
        styleValueX = styleValueLabelX + 120
        styleValueY = 52

        # Place the pokemon's name
        textpos = []
        textpos.push([_INTL("Adjust {1}'s Style", @pokemon.name),Graphics.width / 2,0,2,Color.new(88,88,80),Color.new(168,184,184)])

        # Place the pokemon's Style Points (stored as EVs)
        numberBase = MessageConfig::DARK_TEXT_MAIN_COLOR
        numberShadow = MessageConfig::DARK_TEXT_SHADOW_COLOR
        textpos.concat([
                           [_INTL("Style Points"), styleValueLabelX, styleValueY, 0, base, shadow],
                           [_INTL("HP"), styleValueLabelX, styleValueY + 40, 0, base, shadow],
                           [format("%d", @pokemon.ev[:HP]), styleValueX, styleValueY + 40, 1, numberBase,
                            numberShadow,],
                           [_INTL("Attack"), styleValueLabelX, styleValueY + 40 + 32 * 1, 0, base, shadow],
                           [format("%d", @pokemon.ev[:ATTACK]), styleValueX, styleValueY + 40 + 32 * 1, 1, numberBase,
                            numberShadow,],
                           [_INTL("Defense"), styleValueLabelX, styleValueY + 40 + 32 * 2, 0, base, shadow],
                           [format("%d", @pokemon.ev[:DEFENSE]), styleValueX, styleValueY + 40 + 32 * 2, 1, numberBase,
                            numberShadow,],
                           [_INTL("Sp. Atk"), styleValueLabelX, styleValueY + 40 + 32 * 3, 0, base, shadow],
                           [format("%d", @pokemon.ev[:SPECIAL_ATTACK]), styleValueX, styleValueY + 40 + 32 * 3, 1, numberBase,
                            numberShadow,],
                           [_INTL("Sp. Def"), styleValueLabelX, styleValueY + 40 + 32 * 4, 0, base, shadow],
                           [format("%d", @pokemon.ev[:SPECIAL_DEFENSE]), styleValueX, styleValueY + 40 + 32 * 4, 1, numberBase,
                            numberShadow,],
                           [_INTL("Speed"), styleValueLabelX, styleValueY + 40 + 32 * 5, 0, base, shadow],
                           [format("%d", @pokemon.ev[:SPEED]), styleValueX, styleValueY + 40 + 32 * 5, 1, numberBase,
                           numberShadow,],
                       ])

        # Place the "reset all" button
        red = Color.new(250, 120, 120)
        resetAndConfirmY = 298
        textpos.push([_INTL("Free All"), styleValueLabelX - 52, resetAndConfirmY, 0, @index == 6 ? red : base,
                      shadow,])
        textpos.push([_INTL("Confirm"), styleValueLabelX - 52, resetAndConfirmY + 38, 0, @index == 7 ? red : base,
                      shadow,])

        # Place the pokemon's final resultant stats
        finalStatLabelX = styleValueLabelX + 200
        finalStatX	= finalStatLabelX + 132
        finalStatY = 52
        textpos.concat([
                           [_INTL("Final Stats"), finalStatLabelX, finalStatY, 0, base, shadow],
                           [_INTL("HP"), finalStatLabelX, finalStatY + 40 + 32 * 0, 0, base, shadow],
                           [format("%d", @pokemon.totalhp), finalStatX, finalStatY + 40 + 32 * 0, 1, numberBase,
                            numberShadow,],
                           [_INTL("Attack"), finalStatLabelX, finalStatY + 40 + 32 * 1, 0, base, shadow],
                           [format("%d", @pokemon.attack), finalStatX, finalStatY + 40 + 32 * 1, 1, numberBase,
                            numberShadow,],
                           [_INTL("Defense"), finalStatLabelX, finalStatY + 40 + 32 * 2, 0, base, shadow],
                           [format("%d", @pokemon.defense), finalStatX, finalStatY + 40 + 32 * 2, 1, numberBase,
                            numberShadow,],
                           [_INTL("Sp. Atk"), finalStatLabelX, finalStatY + 40 + 32 * 3, 0, base, shadow],
                           [format("%d", @pokemon.spatk), finalStatX, finalStatY + 40 + 32 * 3, 1, numberBase,
                            numberShadow,],
                           [_INTL("Sp. Def"), finalStatLabelX, finalStatY + 40 + 32 * 4, 0, base, shadow],
                           [format("%d", @pokemon.spdef), finalStatX, finalStatY + 40 + 32 * 4, 1, numberBase,
                            numberShadow,],
                           [_INTL("Speed"), finalStatLabelX, finalStatY + 40 + 32 * 5, 0, base, shadow],
                           [format("%d", @pokemon.speed), finalStatX, finalStatY + 40 + 32 * 5, 1, numberBase,
                            numberShadow,],
                       ])

        # Place the pokemon's final effective HP stats (EHP)
        ehpLabelX = finalStatLabelX + 160
        pehp = (@pokemon.totalhp * @pokemon.defense) / 100
        sehp = (@pokemon.totalhp * @pokemon.spdef) / 100
        textpos.concat([
                           [_INTL("EHP"), ehpLabelX, finalStatY, 0, subtleBase, subtleShadow],
                           [format("%d", pehp), ehpLabelX, finalStatY + 40 + 32 * 2, 0, subtleBase,
                            subtleShadow,],
                           [format("%d", sehp), ehpLabelX, finalStatY + 40 + 32 * 4, 0, subtleBase,
                            subtleShadow,],
                       ])

        # Place the style value pool
        poolXLeft = BASE_X + 140
        poolY = resetAndConfirmY
        textpos.concat([
                           [_INTL("Pool"), poolXLeft, poolY, 0, base, shadow],
                           [format("%d", @pool), poolXLeft, poolY + 40, 0, numberBase,
                            numberShadow,],
                       ])

        # Place the style name
        styleXLeft = finalStatLabelX
        styleNameY = resetAndConfirmY
        styleName = getStyleName(@pokemon.ev)
        textpos.concat([
                           [_INTL("Style"), styleXLeft, styleNameY, 0, base, shadow],
                           [styleName, styleXLeft, styleNameY + 40, 0, numberBase,
                            numberShadow,],
                       ])

        # Place the quick set helper
        helperX = styleXLeft + 216
        textpos.concat([
                            [_INTL("ACTION/Z for"), helperX, poolY + 4, 1, subtleBase, subtleShadow],
                            [_INTL("quick set"), helperX, poolY + 36, 1, subtleBase, subtleShadow],
                        ])

        # Draw all the previously placed texts
        pbDrawTextPositions(overlay, textpos)

        # Put the arrows around the currently selected style value line
        if @index < 6
            @sprites["leftarrow"].y = @sprites["rightarrow"].y = 100 + 32 * @index
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
            stats = %i[HP ATTACK DEFENSE SPECIAL_ATTACK SPECIAL_DEFENSE SPEED]
        else
            stats = %i[HP ATTACK DEFENSE SPECIAL_DEFENSE SPEED]
        end
        largeStats = []
        stats.each do |stat|
            largeStats.push(stat) if evs[stat] >= 13
        end
        largeStats = largeStats.sort_by { |a| evs[a] }
        largeStats.pop if largeStats.length > 3
        largeStats = largeStats.sort_by { |a| stats.find_index(a) }
        if largeStats.length == 1
            case largeStats[0]
            when :HP
                return _INTL("Stocky")
            when :ATTACK
                return _INTL("Aggressive")
            when :DEFENSE
                return _INTL("Defensive")
            when :SPECIAL_ATTACK
                return _INTL("Cunning")
            when :SPECIAL_DEFENSE
                return _INTL("Suspicious")
            when :SPEED
                return _INTL("Quick")
            end
        elsif largeStats.length == 2
            case largeStats
            when %i[HP ATTACK]
                return _INTL("Brutish")
            when %i[HP DEFENSE]
                return _INTL("Armored")
            when %i[HP SPECIAL_ATTACK]
                return _INTL("Attuned")
            when %i[HP SPECIAL_DEFENSE]
                return _INTL("Guarded")
            when %i[HP SPEED]
                return _INTL("Unyielding")
            when %i[ATTACK DEFENSE]
                return _INTL("Bulky")
            when %i[ATTACK SPECIAL_ATTACK]
                return _INTL("Variable")
            when %i[ATTACK SPECIAL_DEFENSE]
                return _INTL("Flowing")
            when %i[ATTACK SPEED]
                return _INTL("Hunting")
            when %i[DEFENSE SPECIAL_ATTACK]
                return _INTL("Vanguard")
            when %i[DEFENSE SPECIAL_DEFENSE]
                return _INTL("Prepared")
            when %i[DEFENSE SPEED]
                return _INTL("Steady")
            when %i[SPECIAL_ATTACK SPECIAL_DEFENSE]
                return _INTL("Calm")
            when %i[SPECIAL_ATTACK SPEED]
                return _INTL("Striking")
            when %i[SPECIAL_DEFENSE SPEED]
                return _INTL("Spirited")
            end
        elsif largeStats.length == 3
            case largeStats
            when %i[HP ATTACK DEFENSE]
                return _INTL("Blunt")
            when %i[HP ATTACK SPECIAL_ATTACK]
                return _INTL("Forceful")
            when %i[HP ATTACK SPECIAL_DEFENSE]
                return _INTL("Smooth")
            when %i[HP ATTACK SPEED]
                return _INTL("Blitzing")
            when %i[HP DEFENSE SPECIAL_ATTACK]
                return _INTL("Fortified")
            when %i[HP DEFENSE SPECIAL_DEFENSE]
                return _INTL("Precautionary")
            when %i[HP DEFENSE SPEED]
                return _INTL("Carefree")
            when %i[HP SPECIAL_DEFENSE SPEED]
                return _INTL("Crafty")
            when %i[HP SPECIAL_ATTACK SPECIAL_DEFENSE]
                return _INTL("Serene")
            when %i[HP SPECIAL_ATTACK SPEED]
                return _INTL("Energetic")
            when %i[ATTACK DEFENSE SPECIAL_ATTACK]
                return _INTL("Deliberate")
            when %i[ATTACK DEFENSE SPECIAL_DEFENSE]
                return _INTL("Patient")
            when %i[ATTACK DEFENSE SPEED]
                return _INTL("Flanking")
            when %i[ATTACK SPECIAL_ATTACK SPECIAL_DEFENSE]
                return _INTL("Strategic")
            when %i[ATTACK SPECIAL_ATTACK SPEED]
                return _INTL("Opportunistic")
            when %i[ATTACK SPECIAL_DEFENSE SPEED]
                return _INTL("Determined")
            when %i[DEFENSE SPECIAL_ATTACK SPECIAL_DEFENSE]
                return _INTL("Calculating")
            when %i[DEFENSE SPECIAL_ATTACK SPEED]
                return _INTL("Tactical")
            when %i[DEFENSE SPECIAL_DEFENSE SPEED]
                return _INTL("Protective")
            when %i[SPECIAL_ATTACK SPECIAL_DEFENSE SPEED]
                return _INTL("Elegant")
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
        stats = %i[HP ATTACK DEFENSE SPECIAL_ATTACK SPECIAL_DEFENSE SPEED]

        resetEVs = false
        if COMBINE_ATTACKING_STATS
            resetEVs = true if pkmn.ev[:ATTACK] != pkmn.ev[:SPECIAL_ATTACK]
        else
            !COMBINE_ATTACKING_STATS
            if pkmn.ev[:ATTACK] == pkmn.ev[:SPECIAL_ATTACK]
                total = 0
                stats.each do |stat|
                    total += pkmn.ev[stat]
                end
                resetEVs = true if total > STYLE_VALUE_TOTAL
            end
        end

        if resetEVs
            pbMessage(_INTL("Resetting Style Points due to non-conformity with rules."))
            GameData::Stat.each_main do |s|
                pkmn.ev[s.id] = DEFAULT_STYLE_VALUE
            end
        end

        @pool = STYLE_VALUE_TOTAL
        stats.each do |stat|
            next if stat == :SPECIAL_ATTACK && COMBINE_ATTACKING_STATS
            @pool -= pkmn.ev[stat]
        end
        raise _INTL("{1} has more EVs than its supposed to be able to!", pkmn.name) if @pool < 0
        @scene.pool = @pool
        updateStats(pkmn)
        loop do
            Graphics.update
            Input.update
            @scene.pbUpdate
            if Input.trigger?(Input::BACK)
                if @pool > 0
                    pbPlayBuzzerSE
                    @scene.pbDisplay("There are still Style Points points left to assign!")
                elsif @scene.pbConfirm(_INTL("Finish adjusting Style Points?"))
                    @scene.pbEndScene
                    pbPlayCloseMenuSE
                    return
                end
            elsif Input.trigger?(Input::USE)
                if @index == 6
                    pkmn.ev.each do |stat, _value|
                        pkmn.ev[stat] = 0
                    end
                    @pool = STYLE_VALUE_TOTAL
                    @scene.pool = @pool
                    pbPlayDecisionSE
                    updateStats(pkmn)
                elsif @index == 7
                    if @pool > 0
                        pbPlayBuzzerSE
                        @scene.pbDisplay("There are still Style Points points left to assign!")
                    elsif @scene.pbConfirm(_INTL("Finish adjusting Style Points?"))
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
                if pkmn.ev[stat] < STYLE_VALUE_MAX && @pool > 0
                    pkmn.ev[stat] = (pkmn.ev[stat] + 1)
                    @pool -= 1
                    pkmn.ev[:SPECIAL_ATTACK] = pkmn.ev[:ATTACK] if COMBINE_ATTACKING_STATS
                    @scene.pool = @pool
                    pbPlayDecisionSE
                    updateStats(pkmn)
                elsif pkmn.ev[stat] == STYLE_VALUE_MAX && Input.trigger?(Input::RIGHT)
                    pkmn.ev[stat] = 0
                    pkmn.ev[:SPECIAL_ATTACK] = pkmn.ev[:ATTACK] if COMBINE_ATTACKING_STATS
                    @pool += STYLE_VALUE_MAX
                    @scene.pool = @pool
                    pbPlayDecisionSE
                    updateStats(pkmn)
                elsif @pool == 0 && Input.trigger?(Input::RIGHT)
                    toAddToPool = pkmn.ev[stat]
                    pkmn.ev[stat] = 0
                    pkmn.ev[:SPECIAL_ATTACK] = pkmn.ev[:ATTACK] if COMBINE_ATTACKING_STATS
                    @pool += toAddToPool
                    @scene.pool = @pool
                    pbPlayDecisionSE
                    updateStats(pkmn)
                elsif Input.time?(Input::RIGHT) < 20_000
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
                    pkmn.ev[stat] = [@pool, STYLE_VALUE_MAX].min
                    pkmn.ev[:SPECIAL_ATTACK] = pkmn.ev[:ATTACK] if COMBINE_ATTACKING_STATS
                    @pool -= pkmn.ev[stat]
                    @scene.pool = @pool
                    pbPlayDecisionSE
                    updateStats(pkmn)
                elsif Input.time?(Input::LEFT) < 20_000
                    pbPlayBuzzerSE
                end
            elsif Input.trigger?(Input::ACTION)
                if COMBINE_ATTACKING_STATS
                    # HP, Attack, Defense, Sp. Atk, Sp. Def, Speed
                    choices = {
                        _INTL("Fast Attacker") => [10,20,0,20,0,20],
                        _INTL("Bulky Attacker") => [20,20,0,20,0,10],
                        _INTL("Physical Tank") => [10,20,20,20,0,0],
                        _INTL("Special Tank") => [10,20,0,20,20,0],
                        _INTL("Physical Wall") => [20,0,20,0,10,0],
                        _INTL("Special Wall") => [20,0,10,0,20,0],
                    }
                else
                    choices = {
                        _INTL("Physical Attacker") => [10,20,0,0,0,20],
                        _INTL("Special Attacker") => [10,0,0,20,0,20],
                        _INTL("Bulky Physical") => [20,20,0,0,0,10],
                        _INTL("Bulky Attacker") => [20,0,0,20,0,10],
                        _INTL("Physical Tank") => [10,20,20,0,0,0],
                        _INTL("Special Tank") => [10,0,0,20,20,0],
                        _INTL("Physical Wall") => [20,0,20,0,10,0],
                        _INTL("Special Wall") => [20,0,10,0,20,0],
                    }
                end
                windowChoices = [_INTL("Cancel")].concat(choices.keys)
                choice = @scene.pbShowCommands(nil, windowChoices)
                next if choice <= 0
                statsArray = choices.values[choice-1]

                statIDOrder = [:HP,:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
                statsArray.each_with_index do |value, index|
                    id = statIDOrder[index]
                    pkmn.ev[id] = value
                end
                @pool = 0
                @scene.pool = 0
                updateStats(pkmn)
            end
        end
    end
end

def choosePokemonToStyle(_pokemonVar = 1, _nameVar = 3)
    pbChooseStylePokemon(1, 3, proc { |p|
                                   p.ev[:ATTACK] != DEFAULT_STYLE_VALUE ||
                                   p.ev[:DEFENSE] != DEFAULT_STYLE_VALUE ||
                                   p.ev[:SPEED] != DEFAULT_STYLE_VALUE ||
                                   p.ev[:HP] != DEFAULT_STYLE_VALUE ||
                                   p.ev[:SPECIAL_ATTACK] != DEFAULT_STYLE_VALUE ||
                                   p.ev[:SPECIAL_DEFENSE] != DEFAULT_STYLE_VALUE
                               }
    )
end

def pbChooseStylePokemon(variableNumber, nameVarNumber, styleProc = nil)
    chosen = 0
    pbFadeOutIn do
        scene = PokemonParty_Scene.new
        screen = PokemonPartyScreen.new(scene, $Trainer.party)
        if styleProc
            chosen = screen.pbChooseAblePokemonStyle(styleProc)
        else
            screen.pbStartScene(_INTL("Choose a Pokémon."), false)
            chosen = screen.pbChoosePokemon
            screen.pbEndScene
        end
    end
    pbSet(variableNumber, chosen)
    if chosen >= 0
        pbSet(nameVarNumber, $Trainer.party[chosen].name)
    else
        pbSet(nameVarNumber, "")
    end
end

class PokemonPartyScreen
    def pbChooseAblePokemonStyle(styledProc)
        annot = []
        for pkmn in @party
            styled = styledProc.call(pkmn)
            annot.push(styled ? _INTL("RESTYLE") : _INTL("FIRST STYLE"))
        end
        ret = -1
        @scene.pbStartScene(@party,
           (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."), annot)
        loop do
            @scene.pbSetHelpText(
                (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
            pkmnid = @scene.pbChoosePokemon
            break if pkmnid < 0
            ret = pkmnid
            break
        end
        @scene.pbEndScene
        return ret
    end
end

def styleValuesTrainer
    unless teamEditingAllowed?
        showNoTeamEditingMessage
        return
    end

    choices = []
    choices[cmdAdjustStylePoints = choices.length] = _INTL("Adjust Style Points")
    choices[cmdExplainStylePoints = choices.length] = _INTL("What are Style Points?")
    choices.push(_INTL("Cancel"))
    choice = pbMessage(_INTL("I'm the Style Points adjuster. How can I help?"),choices,choices.length)

    if choice == cmdAdjustStylePoints
        while true
            choosePokemonToStyle
            break if $game_variables[1] < 0
            pbStyleValueScreen(pbGetPokemon(1))
        end
    elsif choice == cmdExplainStylePoints
        pbMessage(_INTL("Style Points are numbers which have an effect on your Pokemon's stats."))
        pbMessage(_INTL("Pokemon start with 10 Style Points in each of their stats."))
        pbMessage(_INTL("To add Style Points to a stat, you have to remove them from another."))
        pbMessage(_INTL("Investing into Attack and Sp. Atk is extra efficient: they go up at the same time!"))
        pbMessage(_INTL("Each stat's Style Points value can go as low as 0, and can go as high as 20."))
        pbMessage(_INTL("A Pokemon's Style Point total never changes, but Style Points give bigger stat bonuses at higher levels."))
        pbMessage(_INTL("If you need to move quickly, try using the Quick Set option!"))
    end        
end
