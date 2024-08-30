class PokemonGlobalMetadata
  attr_accessor :autosaveSteps
end

Events.onStepTaken += proc {
  $PokemonGlobal.autosaveSteps = 0 if !$PokemonGlobal.autosaveSteps
  $PokemonGlobal.autosaveSteps += 1 unless debugControl || isPlayerSliding?
  if $PokemonGlobal.autosaveSteps >= 40
    autoSave
    $PokemonGlobal.autosaveSteps = 0
  end
}

def autoSave
	return if $PokemonSystem.autosave == 1
	return if !savingAllowed?()
	setProperSavePath
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
		@sprites["saveicon"].setBitmap(addLanguageSuffix(("Graphics/Pictures/shiny")))
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