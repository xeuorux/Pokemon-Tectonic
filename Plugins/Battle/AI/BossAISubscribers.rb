#===============================================================================
# BossGetMoveCodeScore handlers
#===============================================================================

# Helping hand
PokeBattle_AI::BossGetMoveCodeScore.add("09C",
	proc { |moveCode,move,user,target,score|
		next 0 if user.battle.commandPhasesThisRound != 0
		next score + 50
	}
)

# Healing Pulse
PokeBattle_AI::BossGetMoveCodeScore.add("0DF",
	proc { |moveCode,move,user,target,score|
		next 0 if user.opposes?(target)
		score += 50 if target.hp<target.totalhp/2 && target.effects[PBEffects::Substitute]==0
		next score
	}
)

# Rest
PokeBattle_AI::BossGetMoveCodeScore.add("OD9",
	proc { |moveCode,move,user,target,score|
		next score += 50
	}
)

# Brine
PokeBattle_AI::BossGetMoveCodeScore.add("080",
	proc { |moveCode,move,user,target,score|
		score += 50 - (target.hp/target.totalhp)*100
		next score
	}
)

# Always crit moves
PokeBattle_AI::BossGetMoveCodeScore.add("0A0",
	proc { |moveCode,move,user,target,score|
		score *= 1.5 if move.physicalMove? && (user.stages[:ATTACK] < 6 || target.stages[:DEFENSE] > 6)
		score *= 2 if move.physicalMove? && (user.stages[:ATTACK] < 4 || target.stages[:DEFENSE] > 8)
		score *= 1.5 if move.specialMove? && (user.stages[:SPECIAL_ATTACK] < 6 || target.stages[:SPECIAL_DEFENSE] > 6)
		score *= 2 if move.specialMove? && (user.stages[:SPECIAL_ATTACK] < 4 || target.stages[:SPECIAL_DEFENSE] > 8)
		next score
	}
)

# Trapping + Damaging moves
PokeBattle_AI::BossGetMoveCodeScore.add("0CF",
	proc { |moveCode,move,user,target,score|
		score = 150 * user.hp.to_f/user.totalhp.to_f
		return score
	}
)


#===============================================================================
# BossGetMoveIDScore handlers
#===============================================================================

#===============================================================================
# BossRequireMoveCode handlers
#===============================================================================
# Flare Up
PokeBattle_AI::BossRequireMoveCode.add("07B",
	proc { |moveCode,move,user,target|
		next true if user.poisoned?
	}
)

# Flare Up
PokeBattle_AI::BossRequireMoveCode.add("50E",
	proc { |moveCode,move,user,target|
		next true if user.burned?
	}
)

#===============================================================================
# BossRequireMoveID handlers
#===============================================================================

#===============================================================================
# BossRejectMoveCode handlers
#===============================================================================

# Rest
PokeBattle_AI::BossRejectMoveCode.add("OD9",
	proc { |moveCode,move,user,target|
		next true if !user.pbCanSleep?(user,false,nil,true)
		next true if user.hp >= user.totalhp/4
	}
)

# Flail/reversal
PokeBattle_AI::BossRejectMoveCode.add("O98",
	proc { |moveCode,move,user,target|
		next true if (user.hp.to_f/user.totalhp.to_f > 0.5)
	}
)

# Flare Up
PokeBattle_AI::BossRejectMoveCode.add("07B",
	proc { |moveCode,move,user,target|
		next true if !user.poisoned?
	}
)

# Flare Up
PokeBattle_AI::BossRejectMoveCode.add("50E",
	proc { |moveCode,move,user,target|
		next true if !user.burned?
	}
)

# Trapping + Damaging moves
PokeBattle_AI::BossGetMoveCodeScore.add("0CF",
	proc { |moveCode,move,user,target,score|
		# Don't use if the're already affected
		next true if target.effects[PBEffects::Trapping] > 0 && target.effects[PBEffects::TrappingMove] == move.id
	}
)

#===============================================================================
# BossRejectMoveID handlers
#===============================================================================

# Future sight style moves
PokeBattle_AI::BossGetMoveCodeScore.add("111",
	proc { |moveCode,move,user,target|
		next true if move.pbFailsAgainstTarget?(user,target)
	}
)