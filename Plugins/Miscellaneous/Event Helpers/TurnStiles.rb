def getClockwiseSwitch(switch)
    case switch.upcase
        when 'A'
            return 'B'
        when 'B'
            return 'D'
        when 'D'
            return 'C'
        when 'C'
            return 'A'
    end
end

def getCounterClockwiseSwitch(switch)
    case switch.upcase
    when 'B'
        return 'A'
    when 'D'
        return 'B'
    when 'C'
        return 'D'
    when 'A'
        return 'C'
    end
end

# The matrices go from top left to bottom right
def getCollisionFlagsForSwitch(switch)
    case switch.upcase
    when 'A'
        return 0b1100
    when 'B'
        return 0b0101
    when 'C'
        return 0b1010
    when 'D'
        return 0b0011
    end
end

def turnStileLogic(turnstileEvent,collisionFlags)
    player = $game_player
    return false if !turnstileEvent.at_coordinate?(player.x, player.y)
    dir = player.direction
    currentSwitch = pbGetFirstSwitch(turnstileEvent.id)

    playerWest = player.x == turnstileEvent.x
    playerSouth = player.y == turnstileEvent.y

    clockwise = true
    case dir
        when Down
            clockwise = false if playerWest && !playerSouth
        when Left
            clockwise = false if !playerWest && !playerSouth
        when Right
            clockwise = false if playerWest && playerSouth
        when Up
            clockwise = false if !playerWest && playerSouth
    end

    possibleResultSwitch = nil
    if clockwise
        possibleResultSwitch = getClockwiseSwitch(currentSwitch)
    else
        possibleResultSwitch = getCounterClockwiseSwitch(currentSwitch)
    end

    possibleResultFlags = getCollisionFlagsForSwitch(possibleResultSwitch)

    # The new orientation of the turnstile will not be an illegal one
    if collisionFlags & possibleResultFlags == 0b0000
        # THE MAP ID MUST BE PASSED HERE OR IT DOES NOT WORK
        # I UNDERSTAND WHY, BUT PLEASE DONT ASK ME TO EXPLAIN IT
        pbSetOnlySwitch(turnstileEvent.id,possibleResultSwitch,true,$game_map.map_id)
        pbSEPlay('Door enter')
        return true
    end
    return false
end