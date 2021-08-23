PokeBattle_AI::BossSpeciesRequireMove.add(:SHIINOTIC,
	proc { |species,move,user,target|
		next true if move.function == "160" && isMaxHeal(user,target)
	}
)

PokeBattle_AI::BossSpeciesRejectMove.add(:SHIINOTIC,
	proc { |species,move,user,target|
		next true if move.function == "160" && !isMaxHeal(user,target)
	}
)

def isMaxHeal(user,target)
	maxHeal = -99999
	maxHealer = nil
	@battle.battlers.each do |b|
		next if !user.opposes?(b)
		stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
		stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
		atk      = b.attack
		atkStage = b.stages[:ATTACK]+6
		healAmt = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
		if healAmt > maxHeal
			maxHeal = healAmt
			maxHealer = b
		end
	end
	return target == maxHealer
end