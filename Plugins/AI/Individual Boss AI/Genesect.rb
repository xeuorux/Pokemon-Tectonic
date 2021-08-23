PokeBattle_AI::BossSpeciesRequireMove.add(:GENESECT,
	proc { |species,move,user,target|
		next true if move.function == "150" && shouldUseFellStinger(user,target)
	}
)

PokeBattle_AI::BossSpeciesRejectMove.add(:GENESECT,
	proc { |species,move,user,target|
		next true if move.function == "150" && !shouldUseFellStinger(user,target)
	}
)

def shouldUseFellStinger(user,target)
	ai = user.battle.battleAI
	baseDmg = ai.pbMoveBaseDamage(move,user,target,100)
	realDamage = ai.pbRoughDamage(move,user,target,100,baseDmg)
	score = 0
	if realDamage >= target.hp
		return true
	end
	return false
end