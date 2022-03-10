class PokemonEvolutionScene
	def pbEvolutionSuccess
		# Play cry of evolved species
		frames = GameData::Species.cry_length(@newspecies, @pokemon.form)
		pbBGMStop
		Pokemon.play_cry(@newspecies, @pokemon.form)
		frames.times do
		  Graphics.update
		  pbUpdate
		end
		# Success jingle/message
		pbMEPlay("Evolution success")
		newspeciesname = GameData::Species.get(@newspecies).name
		pbMessageDisplay(@sprites["msgwindow"],
		   _INTL("\\se[]Congratulations! Your {1} evolved into {2}!\\wt[80]",
		   @pokemon.name,newspeciesname)) { pbUpdate }
		@sprites["msgwindow"].text = ""
		# Check for consumed item and check if Pokémon should be duplicated
		pbEvolutionMethodAfterEvolution
		
		showPokemonChanges (@pokemon) {
			@pokemon.species = @newspecies
			@pokemon.form    = 0 if @pokemon.isSpecies?(:MOTHIM)
			@pokemon.calc_stats
		}
		
		# See and own evolved species
		$Trainer.pokedex.register(@pokemon)
		$Trainer.pokedex.set_owned(@newspecies)
		# Learn moves upon evolution for evolved species
		movelist = @pokemon.getMoveList
		for i in movelist
		  next if i[0]!=0 && i[0]!=@pokemon.level   # 0 is "learn upon evolution"
		  pbLearnMove(@pokemon,i[1],true) { pbUpdate }
		end
	end
end

def showPokemonChanges(pokemon,&block)
	# Mark down pre-change stats
	oldTotalHP = pokemon.totalhp
	oldAttack = pokemon.attack
	oldDefense = pokemon.defense
	oldSpAtk = pokemon.spatk
	oldSpDef = pokemon.spdef
	oldSpeed = pokemon.speed
	# Mark down pre-change ability
	oldAbility = pokemon.ability
	# Modify Pokémon to make it evolved
	block.call
	# Show the stat changes
	hpDif = pokemon.totalhp-oldTotalHP
	attackDif = pokemon.attack-oldAttack
	defenseDif = pokemon.defense-oldDefense
	spAtkDif = pokemon.spatk-oldSpAtk
	spDefDif = pokemon.spdef-oldSpDef
	speedDif = pokemon.speed-oldSpeed
	if hpDif != 0 || attackDif != 0 || defenseDif != 0 ||
				spAtkDif != 0 || spDefDif != 0 || speedDif != 0
		pbTopRightWindow(
		   _INTL("Max. HP<r>#{hpDif >= 0 ? "+" : ""}{1}\r\nAttack<r>#{attackDif >= 0 ? "+" : ""}{2}\r\nDefense<r>#{defenseDif >= 0 ? "+" : ""}{3}\r\nSp. Atk<r>#{spAtkDif >= 0 ? "+" : ""}{4}\r\nSp. Def<r>#{spDefDif >= 0 ? "+" : ""}{5}\r\nSpeed<r>#{speedDif >= 0 ? "+" : ""}{6}",
		   hpDif,attackDif,defenseDif,
		   spAtkDif,spDefDif,speedDif))
		pbTopRightWindow(
		   _INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
		   pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
	end
	# Show new ability if any
	if pokemon.ability != oldAbility
		abilityName = GameData::Ability.get(pokemon.ability).real_name
		pbMessage(_INTL("{1}'s ability was changed to {2}.",pokemon.name,abilityName))
	end
end