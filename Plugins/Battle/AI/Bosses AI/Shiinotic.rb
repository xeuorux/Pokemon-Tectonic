# Strength Sap
PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:SHIINOTIC,"160"],
	 proc { |speciesAndMove,user,target,move|
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
	next target == maxHealer
  }
)