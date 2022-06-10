ATTACK_FORM_MOVESET = [:PSYCHOBOOST,:INFINITEFORCE]
DEFENSE_FORM_MOVESET = [:COSMICPOWER,:LIFEDEW]
SPEED_FORM_MOVESET = [:ZENHEADBUTT,:THUNDERBOLT]

PokeBattle_AI::BossBeginTurn.add(:DEOXYS,
	proc { |species,battler|
		battle = battler.battle
		turnCount = battle.turnCount

        turnCount = battler.battle.turnCount
		if turnCount != 0
            if battler.hp < battler.totalhp * 0.25
                if battler.form != 1
                    battler.form = 1
                    battle.pbDisplay(_INTL("The avatar of Deoxys turns to Attack Form!"))
                    battler.assignMoveset(ATTACK_FORM_MOVESET)
                end
            elsif battler.hp < battler.totalhp * 0.5
                if battler.form != 2
                    battler.form = 2
                    battle.pbDisplay(_INTL("The avatar of Deoxys turns to Defense Form!"))
                    battler.assignMoveset(DEFENSE_FORM_MOVESET)
                end
            elsif battler.hp < battler.totalhp * 0.75
                if battler.form != 3
                    battler.form = 3
                    battle.pbDisplay(_INTL("The avatar of Deoxys turns to Speed Form!"))
                    battler.assignMoveset(SPEED_FORM_MOVESET)
                end
            end
        end
	}
)