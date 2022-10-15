def pbBatteryLow?
    pstate = System.power_state
    # If it's not discharging, it doesn't matter if it's low
    return false if !pstate[:discharging]
    # Check for less than 10m, priority over the percentage
    # Some laptops (Chromebooks, Macbooks) have very long lifetimes
    return true if pstate[:seconds] && pstate[:seconds] <= 600
    # Check for <=15%
    return true if pstate[:percent] && pstate[:percent] <= 15
    return false
  end
  
  Events.onMapUpdate += proc { |_sender,_e|
    if !$PokemonTemp.batterywarning && pbBatteryLow?
      if !$game_temp.in_menu && !$game_temp.in_battle &&
         !$game_player.move_route_forcing && !$game_temp.message_window_showing &&
         !pbMapInterpreterRunning?
        if pbGetTimeNow.sec==0
          pbMessage(_INTL("The game has detected that the battery is low. You should save soon to avoid losing your progress."))
          $PokemonTemp.batterywarning = true
        end
      end
    end
    if $PokemonTemp.cueFrames
      $PokemonTemp.cueFrames -= 1
      if $PokemonTemp.cueFrames<=0
        $PokemonTemp.cueFrames = nil
        if $game_system.getPlayingBGM==nil
          pbBGMPlay($PokemonTemp.cueBGM)
        end
      end
    end
  }