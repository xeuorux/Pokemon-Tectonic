class PokemonGlobalMetadata
    attr_writer :dragonFlamesCount

    def dragonFlamesCount
        @dragonFlamesCount = 0 if @dragonFlamesCount.nil?
        return @dragonFlamesCount
    end
end

class PokemonTemp
    def dragonFlames
        @dragonFlames = [] if @dragonFlames.nil?
        return @dragonFlames
    end
end

def takeDragonFlame(triggerEventID = -1)
    if $PokemonGlobal.dragonFlamesCount > 0
        pbMessage(_INTL("You are already holding a dragon flame!"))
        return
    end
    if triggerEventID > 0
        if get_event(triggerEventID).at_coordinate?($game_player.x, $game_player.y)
            pbMessage(_INTL("The shadow will envelop you if you remove the flame now!"))
            return
        end
    end
    invertMySwitch('A')
    createDragonFlameGraphic
    $PokemonGlobal.dragonFlamesCount += 1
    fadeInDarknessBlock(triggerEventID) if triggerEventID > 0
end

def giveDragonFlame(triggerEventID = -1)
    if $PokemonGlobal.dragonFlamesCount == 0
        pbMessage(_INTL("It looks like it could hold a magical flame."))
        return
    end
    invertMySwitch('A')
    removeDragonFlameGraphic
    $PokemonGlobal.dragonFlamesCount -= 1
    fadeOutDarknessBlock(triggerEventID, false) if triggerEventID > 0
end

def createDragonFlameGraphic(spriteset = nil)
    newGraphic = LightEffect_DragonFlame.new($game_player,Spriteset_Map.viewport,$game_map)
    spriteset = $scene.spriteset if spriteset.nil?
    spriteset.addUserSprite(newGraphic)
    $PokemonTemp.dragonFlames.push(newGraphic)
end

def removeDragonFlameGraphic
    removedFlame = $PokemonTemp.dragonFlames.pop
    removedFlame.dispose
end