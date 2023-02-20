MAPS_MAXIMUM = 500

SaveData.register(:events_reset) do
	ensure_class :ResetTracker
	save_value { $reset_tracker }
	load_value { |value| $reset_tracker = value }
	new_game_value { ResetTracker.new }
end

class ResetTracker
	attr_accessor :reset_table
  attr_accessor :respawn_tutorial
  attr_reader   :respawns_tutorialized

  def initialize()
      @reset_table          = []
      refillRespawnTable
      @respawns_tutorialized  = false
      @respawn_tutorial 	    = 0
  end

  def refillRespawnTable
    for i in 0...MAPS_MAXIMUM
      @reset_table[i] = true
    end
  end

  def checkForResets(oldid)
    if oldid==0 || oldid==$game_map.map_id
      echoln("Skipping this map for respawns because of some unknown error.\n")
      return
    end
      
    if !@reset_table[$game_map.map_id]
      echoln("Skipping this map for respawns because its already been reset.\n")
      return
    end
      
    # Reset all reset events on this map
    @reset_table[$game_map.map_id] = false
    echoln("Resetting events on this map\n")
    anyTrainersRespawned = false
    for event in $game_map.events.values
      if event.name.downcase.include?("reset")
      if event.name.downcase.include?("trainer") && $game_self_switches[[$game_map.map_id,event.id,"A"]]
        anyTrainersRespawned = true
      end
      $game_self_switches[[$game_map.map_id,event.id,"A"]] = false
      end
    end
    
    # Set up the player to experience the tutorial soon, if first time
    if anyTrainersRespawned && !@respawns_tutorialized
      @respawn_tutorial = 3
    else
      @respawn_tutorial = 0
    end
  end

  def checkForTutorial()
    return if @respawns_tutorialized
    return if @respawn_tutorial <= 0
    if @respawn_tutorial == 1
      playRespawningTutorial
      @respawns_tutorialized = true
    end
    @respawn_tutorial -= 1
  end
end

def playRespawningTutorial
  if $DEBUG
    echoln("Skipping Trainer Respawning tutorial message.")
    return
  end
  currentBGM = $game_system.playing_bgm
  pbBGMFade(1.0)
  pbWait(Graphics.frame_rate)
  pbSEPlay("Voltorb Flip tile",150,100)
  pbMessage(_INTL("\\wmAfter a full party heal, defeated enemy trainers will be battle ready again!\\wtnp[80]\1"))
  pbMessage(_INTL("\\wmFor example, healing at a Pokemon Center triggers this.\\wtnp[80]\1"))
  pbMessage(_INTL("\\wmTrainers who fled won't come back, however.\\wtnp[80]\1"))
  pbBGMPlay(currentBGM)
end

def pbRespawnTrainers
  $reset_tracker.refillRespawnTable()
end

Events.onMapChange += proc { |_sender,e|
  $reset_tracker.checkForResets(e[0])
}

Events.onStepTaken += proc { |_sender,_e|
  $reset_tracker.checkForTutorial()
}
