DRAGON_EGGS = [:DRATINIEGG,:BAGONEGG,:GIBLEEGG,:DEINOEGG,:GOOMYEGG,:JANGMOOEGG,:DREEPYEGG]

def pbChooseDragonEgg(var = 0)
	ret = nil
	pbFadeOutIn {
	  scene = PokemonBag_Scene.new
	  screen = PokemonBagScreen.new(scene,$PokemonBag)
	  ret = screen.pbChooseItemScreen(Proc.new { |item| 
	  	DRAGON_EGGS.include?(item)
	  })
	}
	$game_variables[var] = ret || :NONE if var > 0
	return ret
  end

def hatchDragonEggs(egg)
	eggsToSpecies = {
		:DRATINIEGG => :DRATINI,
		:BAGONEGG => :BAGON,
		:GIBLEEGG => :GIBLE,
		:DEINOEGG => :DEINO,
		:GOOMYEGG => :GOOMY,
		:JANGMOOEGG => :JANGMOO,
		:DREEPYEGG => :DREEPY
	}
	
	species = eggsToSpecies[egg] || nil
	
	if species.nil?
		pbMessage(_INTL("Error! Could not determine how to hatch the given egg."))
		return
	end
	item_data = GameData::Item.get(egg)
	
	pbMessage(_INTL("\\PN hands over the #{item_data.name}."))
	
	pbMessage(_INTL("Now I must have time. Gingerly I shall attend to the egg."))
	
	blackFadeOutIn(30) {
		$PokemonBag.pbDeleteItem(egg)
	}
	
	pbMessage(_INTL("The hatching was a success. I am pleased to allow you this Dragon."))
	
	pbAddPokemon(species,5)
end

def dragonDenEnterPrompt()
	if pbConfirmMessage(_INTL("You notice a small hole in the rock. Dig into it?"))
		pbMessage(_INTL("You clambor into the den!"))
		return true
	end
	return false
end

def dragonDenExitMessage()
	pbMessage(_INTL("You clamber out of the den!"))
end