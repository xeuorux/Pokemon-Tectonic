class Game_Temp
	attr_accessor :save_calling             # save calling flag
end

class PokemonTemp
	attr_accessor :bicycleCalling 
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
	return if !savingAllowed?()
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