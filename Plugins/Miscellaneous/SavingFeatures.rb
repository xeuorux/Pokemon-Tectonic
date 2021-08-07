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
	if $game_switches[79]
      pbMessage(_INTL("\\se[]Saving is not allowed in this area.\\wtnp[10]"))
      return
    end
    pbSEPlay("GUI save choice")
    if Game.save
      pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]",$Trainer.name))
    else
      pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
    end
  end
end


class PokemonSaveScreen
	def pbSaveScreen
    ret = false
	if $game_switches[79]
      pbMessage(_INTL("\\se[]Saving is not allowed in this area.\\wtnp[10]"))
      return
    end
    @scene.pbStartScreen
    if pbConfirmMessage(_INTL('Would you like to save the game?'))
      if SaveData.exists? && $PokemonTemp.begunNewGame
        pbMessage(_INTL('WARNING!'))
        pbMessage(_INTL('There is a different game file that is already saved.'))
        pbMessage(_INTL("If you save now, the other file's adventure, including items and Pokémon, will be entirely lost."))
        if !pbConfirmMessageSerious(
            _INTL('Are you sure you want to save now and overwrite the other save file?'))
          pbSEPlay('GUI save choice')
          @scene.pbEndScreen
          return false
        end
      end
      $PokemonTemp.begunNewGame = false
      pbSEPlay('GUI save choice')
      if Game.save
        pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]\\wtnp[30]", $Trainer.name))
        ret = true
      else
        pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
        ret = false
      end
    else
      pbSEPlay('GUI save choice')
    end
    @scene.pbEndScreen
    return ret
  end
end


# Removes the "can't save" switch whenever you transfer maps.
# This switch needs to be set true by an autorun object in whatever maps its meant
# To be present on
Events.onMapChange += proc { |_sender,e|
  $game_switches[79] = false
}
