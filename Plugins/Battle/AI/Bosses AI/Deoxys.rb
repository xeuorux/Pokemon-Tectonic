ATTACK_FORM_MOVESET = [:PSYCHOBOOST,:INFINITEFORCE]
DEFENSE_FORM_MOVESET = [:COSMICPOWER,:RECOVER]
SPEED_FORM_MOVESET = [:ZENHEADBUTT,:ELECTROBALL]

PokeBattle_AI::BossBeginTurn.add(:DEOXYS,
	proc { |species,battler|
		battle = battler.battle
		turnCount = battle.turnCount

        turnCount = battler.battle.turnCount
		if turnCount != 0
            if battler.hp < battler.totalhp * 0.25
                if battler.form != 1
                    formChangeMessage = _INTL("The avatar of Deoxys turns to Attack Form!")
                    battler.pbChangeFormBoss(1,formChangeMessage)
                    battler.assignMoveset(ATTACK_FORM_MOVESET)
                end
            elsif battler.hp < battler.totalhp * 0.5
                if battler.form != 2
                    formChangeMessage = _INTL("The avatar of Deoxys turns to Defense Form!")
                    battler.pbChangeFormBoss(2,formChangeMessage)
                    battler.assignMoveset(DEFENSE_FORM_MOVESET)
                end
            elsif battler.hp < battler.totalhp * 0.75
                if battler.form != 3
                    formChangeMessage = _INTL("The avatar of Deoxys turns to Speed Form!")
                    battler.pbChangeFormBoss(3,formChangeMessage)
                    battler.assignMoveset(SPEED_FORM_MOVESET)
                end
            end
        end
	}
)