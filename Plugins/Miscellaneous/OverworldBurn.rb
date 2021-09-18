# Burn party Pokémon
Events.onStepTakenTransferPossible += proc { |_sender,e|
  handled = e[0]
  next if handled[0]
  if $PokemonGlobal.stepcount % 4 == 0
    flashed = false
	frontOfParty = $Trainer.first_able_pokemon
    $Trainer.able_party.each_with_index do |pokemon,index|
      if pokemon.status == :BURN
        if !flashed
		  pbFlash(Color.new(255, 119, 0, 128), 4)
          flashed = true
        end
        pokemon.hp -= 1
        if pokemon.hp == 0
          pokemon.changeHappiness("faint")
          pokemon.status = :NONE
          pbMessage(_INTL("{1} fainted...",pokemon.name))
		  if index == 0
			stowFollowerIfActive()
			refreshFollow()
		  end
        end
        if $Trainer.able_pokemon_count == 0
          handled[0] = true
          pbCheckAllFainted
        end
	  elsif pokemon.status == :POISON
        if !flashed
          pbFlash(Color.new(255, 0, 119, 128), 4)
          flashed = true
        end
        pokemon.hp -= 1
		if pokemon.hp == 0
          pokemon.changeHappiness("faint")
          pokemon.status = :NONE
          pbMessage(_INTL("{1} fainted...",pokemon.name))
		  if index == 0
			stowFollowerIfActive()
			refreshFollow()
		  end
        end
        if $Trainer.able_pokemon_count == 0
          handled[0] = true
          pbCheckAllFainted
        end
      end
    end
  end
}