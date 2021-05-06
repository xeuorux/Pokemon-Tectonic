=begin
module Input
  SAVE	   = S
end
=end

class Game_Temp
	attr_accessor :save_calling             # save calling flag
end

class Scene_Map
	def update
    loop do
      updateMaps
      pbMapInterpreter.update
      $game_player.update
      $game_system.update
      $game_screen.update
      break unless $game_temp.player_transferring
      transfer_player
      break if $game_temp.transition_processing
    end
    updateSpritesets
    if $game_temp.to_title
      $scene = pbCallTitle
      return
    end
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" + $game_temp.transition_name)
      end
    end
    return if $game_temp.message_window_showing
    if !pbMapInterpreterRunning?
      if Input.trigger?(Input::USE)
        $PokemonTemp.hiddenMoveEventCalling = true
      elsif Input.trigger?(Input::BACK)
        unless $game_system.menu_disabled || $game_player.moving?
          $game_temp.menu_calling = true
          $game_temp.menu_beep = true
        end
      elsif Input.trigger?(Input::SPECIAL)
        unless $game_player.moving?
          $PokemonTemp.keyItemCalling = true
        end
	  elsif Input.trigger?(Input::AUX1)
		unless $game_system.menu_disabled or $game_player.moving?
          $game_temp.save_calling = true
          $game_temp.menu_beep = true
        end
      elsif Input.press?(Input::F9)
        $game_temp.debug_calling = true if $DEBUG
      end
    end
    unless $game_player.moving?
      if $game_temp.menu_calling
        call_menu
      elsif $game_temp.debug_calling
        call_debug
	  elsif $game_temp.save_calling
		call_save
      elsif $PokemonTemp.keyItemCalling
        $PokemonTemp.keyItemCalling = false
        $game_player.straighten
        pbUseKeyItem
      elsif $PokemonTemp.hiddenMoveEventCalling
        $PokemonTemp.hiddenMoveEventCalling = false
        $game_player.straighten
        Events.onAction.trigger(self)
      end
    end
  end
  
  def call_save
    $game_temp.save_calling = false
    pbSEPlay("GUI save choice")
    if Game.save
      pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]",$Trainer.name))
    else
      pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
    end
  end
end