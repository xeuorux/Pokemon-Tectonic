ItemHandlers::UseFromBag.add(:STINKBOMB,proc { |item|
    if getStinkBombables.empty?
        pbMessage(_INTL("There's no trainers nearby to use the Stink Bomb on."))
        next 0
    end
    next 2
})

STINK_BOMB_RANGE = 3

def getStinkBombables
    stinkBombables = []
    for event in $game_map.events.values
		next unless event.name.downcase.include?("stinkable")
		xDif = (event.x - $game_player.x).abs
		yDif = (event.y - $game_player.y).abs
		next unless xDif <= STINK_BOMB_RANGE && yDif <= STINK_BOMB_RANGE # Must be nearby
        next if pbGetSelfSwitch(event.id,'D') # Must not already be fled
		stinkBombables.push(event)
    end
    return stinkBombables
end

ItemHandlers::UseInField.add(:STINKBOMB,proc { |item|
    eventsToRemove = getStinkBombables
    next 0 if eventsToRemove.empty?
    next 0 unless pbConfirmMessageSerious(_INTL("#{eventsToRemove.count} trainers are in range. Deploy?"))
    pbUseItemMessage(:STINKBOMB)

    # Play sound effects and spawn particle effect
    pbSEPlay("Stink bomb",80,80)
    pbSEPlay("Anim/PRSFX- Poison Gas",80,80)
    if $scene.spriteset.particle_engine
        $scene.spriteset.particle_engine.add_effect($game_player,"stinkbomb")
        pbWait(72)
        $scene.spriteset.particle_engine.remove_effect($game_player)
    else
        pbWait(24)
    end

    if eventsToRemove.count > 1
        pbMessage(_INTL("#{eventsToRemove.count} trainers fled from the stench!"))
    else
        pbMessage(_INTL("A nearby trainer fled from the stench!"))
    end
    condensedLightCount = 0
    blackFadeOutIn {
        eventsToRemove.each do |eventToRemove|
            echoln("Causing event #{eventToRemove.name} (#{eventToRemove.event.id}) to flee")
            pbSetSelfSwitch(eventToRemove.id,'D',true,$game_map.map_id)
            setFollowerGone(eventToRemove.id)
            condensedLightCount += 1 if eventToRemove.name.downcase.include?("condensedlight")
        end
    }
    if condensedLightCount > 0
        if condensedLightCount == 1
            pbMessage(_INTL("Oh, a strange item was left behind!"))
        else
            pbMessage(_INTL("Oh, some strange items were left behind!"))
        end
        pbReceiveItem(:CONDENSEDLIGHT,condensedLightCount)
    end
    next 3
})