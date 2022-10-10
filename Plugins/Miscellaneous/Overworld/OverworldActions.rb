class Game_Temp
	attr_accessor :save_calling             # save calling flag
end

class PokemonTemp
	attr_accessor :bicycleCalling 
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
	  elsif Input.trigger?(Input::AUX2)
        #unless $game_player.moving?
          $PokemonTemp.bicycleCalling = true
        #end
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
	if $PokemonTemp.bicycleCalling
		call_bike
	end
  end
  
  def call_save
    $game_temp.save_calling = false
    pbSEPlay("GUI save choice")
    if properlySave()
      pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]",$Trainer.name))
    else
      pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
    end
  end
  
  def call_bike
	$PokemonTemp.bicycleCalling = false
	return unless $PokemonBag.pbHasItem?(:BICYCLE)
	pbUseKeyItemInField(:BICYCLE)
  end
end

class PokemonGlobalMetadata
  attr_accessor :autosaveSteps
end

Events.onStepTaken += proc {
  $PokemonGlobal.autosaveSteps = 0 if !$PokemonGlobal.autosaveSteps
  $PokemonGlobal.autosaveSteps += 1 unless Input.press?(Input::CTRL)
  if $PokemonGlobal.autosaveSteps>=40
    autoSave
    $PokemonGlobal.autosaveSteps = 0
  end
}

def properlySave
	if $storenamefilesave.nil?
		count = FileSave.count
		SaveData.changeFILEPATH(FileSave.name(count+1))
		$storenamefilesave = FileSave.name(count+1)
	end
	SaveData.changeFILEPATH($storenamefilesave.nil? ? FileSave.name : $storenamefilesave)
	return Game.save
end

def autoSave
	return if $PokemonSystem.autosave == 1
	SaveData.changeFILEPATH($storenamefilesave.nil? ? FileSave.name : $storenamefilesave)
	if !properlySave
		pbMessage(_INTL("\\se[]Auto-save failed.\\wtnp[30]"))
	else
    iconSize = 24
    x = Graphics.width - iconSize
		$game_screen.pictures[1].show("auto_save_icon", [0,0],x, iconSize, 100, 100, 255,0)
		$game_screen.pictures[1].move(60,[0,0],x,iconSize,100,100,0,0)
	end
end

class AutoSaveIcon
	def initialize
		viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
		viewport.z = 99999
		@sprites = {}
		@sprites["saveicon"] = IconSprite.new(0,0,viewport)
		@sprites["saveicon"].setBitmap(_INTL("Graphics/Pictures/shiny"))
		Graphics.update
	end
	
	def pbUpdate
		@framesRemaining -= 1
		echoln(@framesRemaining)
		pbUpdateSpriteHash(@sprites)
	end

	def dispose
		pbFadeOutAndHide(@sprites) {pbUpdate}
		pbDisposeSpriteHash(@sprites)
		@viewport.dispose
	end
end

def savingTutorial
	lines = [
		"It's important that you save your game frequently!",
		"You can quicksave by pressing the \"AUX1\" key.",
		"If you don't know what that is, press the \\c[2]F1\\c[0] key to check your control bindings.",
		"In fact, you should do that any time that you see a button that you don't understand.",
		"Also, if you don't want to worry about saving manually, you can also turn on \\c[2]autosave\\c[0] in your options menu.",
		"Hope all that was helpful, dearie!"
	]
	lines.each do |line|
		pbMessage(_INTL("#{line}"))
	end
end