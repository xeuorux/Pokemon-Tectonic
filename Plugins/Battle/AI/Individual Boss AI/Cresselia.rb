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
			battle.pbCreateBattler(5,darkrai,1)
			battle.scene.pbCreatePokemonSprite(5)
			battle.scene.pbChangePokemon(5,darkrai)
			pkmnSprite = battle.scene.sprites["pokemon_#{index}"]
			pkmnSprite.tone    = Tone.new(-80,-80,-80)
			pkmnSprite.visible = true
			battle.pbSendOut([[5,darkrai]])
		end
	}
)