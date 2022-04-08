PokeBattle_AI::BossBeginTurn.add(:CRESSELIA,
	proc { |species,battler|
		battle = battler.battle
		turnCount = battle.turnCount
		if turnCount == 0
			battle.pbDisplay(_INTL("A Shadow creeps into the dream..."))
			darkrai = pbGenerateWildPokemon(:DARKRAI,70)
			darkrai.boss = true
			setAvatarProperties(darkrai)
			battle.setBattleMode("3v2")
			battlerIndexNew = 3
			battle.pbCreateBattler(battlerIndexNew,darkrai,1)
			darkraiBattler = battle.battlers[battlerIndexNew]
			battle.sideSizes[1] = 2
			battle.scene.sprites["dataBox_#{battler.index}"].dispose
			battle.scene.sprites["dataBox_#{battler.index}"] = PokemonDataBox.new(battler,2,battle.scene.viewport)
			battle.scene.sprites["dataBox_#{battlerIndexNew}"] = PokemonDataBox.new(darkraiBattler,2,battle.scene.viewport)
			battle.scene.pbCreatePokemonSprite(battlerIndexNew)
			battle.scene.pbChangePokemon(battlerIndexNew,darkrai)
			battle.scene.pbRefresh
			pkmnSprite = battle.scene.sprites["pokemon_#{battlerIndexNew}"]
			pkmnSprite.tone    = Tone.new(-80,-80,-80)
			pkmnSprite.visible = true
			battle.scene.sprites["targetWindow"] = TargetMenuDisplay.new(battle.scene.viewport,200,battle.sideSizes)


			battle.pbSendOut([[battlerIndexNew,darkrai]])
			battle.pbCalculatePriority
			battle.pbOnActiveOne(darkraiBattler)
			battle.pbCalculatePriority
		end
	}
)