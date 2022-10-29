FIFTY_PERCENT_MOVESET = [:COREENFORCER,:DISCHARGE,:FLASHCANNON,:FLAMETHROWER]
ONE_HUNDRED_PERCENT_MOVESET = [:THOUSANDARROWS,:THOUSANDWAVES,:TORNADO]

PokeBattle_AI::BossBeginTurn.add(:ZYGARDE,
	proc { |species,battler|
		battle = battler.battle
		turnCount = battle.turnCount

    turnCount = battler.battle.turnCount
    if turnCount == 0
      battle.pbDisplayBossNarration(_INTL("{1} is at 10 percent cell strength!",battler.pbThis))
    elsif turnCount <= 9
        battle.pbDisplayBossNarration(_INTL("{1} gathers a cell!",battler.pbThis))
        percentStrength = (1 + turnCount) * 10 
        battle.pbDisplayBossNarration(_INTL("{1} is now at at {2} percent cell strength!",battler.pbThis,percentStrength.to_s))

        if percentStrength == 50
            formChangeMessage = _INTL("{1} transforms into its 50 percent form!",battler.pbThis)
            battler.pbChangeFormBoss(0,formChangeMessage)
            battler.ability = :AURABREAK
            battler.assignMoveset(FIFTY_PERCENT_MOVESET)
        elsif percentStrength == 100
            formChangeMessage = _INTL("{1} transforms into its 100 percent form!",battler.pbThis)
            battler.pbChangeFormBoss(2,formChangeMessage)
            battler.ability = :AURABREAK
            battle.pbDisplayBossNarration(_INTL("{1} completely regenerates!",battler.pbThis))
            battler.pbRecoverHP(battler.totalhp - battler.hp)
            battler.assignMoveset(ONE_HUNDRED_PERCENT_MOVESET)
        end
    end
	}
)

# First phase
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ZYGARDE,:INFERNOCHARGE],
  proc { |speciesAndMove,user,target,move|
	  next user.firstMoveThisTurn? && user.evenTurn?
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ZYGARDE,:TRAMPLE],
  proc { |speciesAndMove,user,target,move|
	  next user.firstMoveThisTurn? && user.oddTurn?
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ZYGARDE,:RECOVER],
  proc { |speciesAndMove,user,target,move|
    next user.lastMoveThisTurn?
 }
)

# Second phase
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ZYGARDE,:COREENFORCER],
  proc { |speciesAndMove,user,target,move|
	  next user.firstMoveThisTurn? && user.evenTurn?
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ZYGARDE,:FLAMETHROWER],
  proc { |speciesAndMove,user,target,move|
	  next user.firstMoveThisTurn? && user.oddTurn?
  }
)

# Third phase
PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ZYGARDE,:TORNADO],
  proc { |speciesAndMove,user,target,move|
	  next user.firstMoveThisTurn?
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ZYGARDE,:THOUSANDWAVES],
  proc { |speciesAndMove,user,target,move|
	  next user.lastMoveThisTurn? && user.oddTurn?
  }
)

PokeBattle_AI::BossSpeciesUseMoveIDIfAndOnlyIf.add([:ZYGARDE,:THOUSANDARROWS],
  proc { |speciesAndMove,user,target,move|
	  next user.lastMoveThisTurn? && user.evenTurn?
  }
)