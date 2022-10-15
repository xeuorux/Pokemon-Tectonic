PokeBattle_AI::BossSpeciesUseMoveCodeIfAndOnlyIf.add([:GENESECT,"150"],
	proc { |speciesAndMoveCode,user,target,move|
		ai = user.battle.battleAI
		baseDmg = ai.pbMoveBaseDamage(move,user,target,100)
		realDamage = ai.pbRoughDamage(move,user,target,100,baseDmg)
		score = 0
		if realDamage >= target.hp
			next true
		end
		next false
	}
)

PokeBattle_AI::BossDecidedOnMove.add(:GENESECT,
	proc { |species,move,user,target|
		if move.id == ":FELLSTINGER"
			user.battle.pbDisplay(_INTL("#{user.pbThis} aims its stinger at #{target.name}!"))
			user.extraMovesPerTurn = 0
		end
	}
)

PokeBattle_AI::BossBeginTurn.add(:GENESECT,
	proc { |species,battler|
		next if battler.turnCount != 0
		
		battler.battle.pbDisplay(_INTL("The avatar of Genesect is analyzing your team for weaknesses..."))
		weakToElectric 	= 0
		weakToFire 		= 0
		weakToIce 		= 0
		weakToWater 	= 0
		maxValue = 0

		$Trainer.party.each do |b|
			next if !b
			type1 = b.type1
			type2 = nil
			type2 = b.type2 if b.type2 != b.type1
			weakToElectric += 1 if Effectiveness.super_effective?(Effectiveness.calculate(:ELECTRIC,type1,type2,nil))
			maxValue = weakToElectric if weakToElectric > maxValue
			weakToFire += 1  if Effectiveness.super_effective?(Effectiveness.calculate(:FIRE,type1,type2,nil))
			maxValue = weakToFire if weakToFire > maxValue
			weakToIce += 1  if Effectiveness.super_effective?(Effectiveness.calculate(:ICE,type1,type2,nil))
			maxValue = weakToIce if weakToIce > maxValue
			weakToWater += 1  if Effectiveness.super_effective?(Effectiveness.calculate(:WATER,type1,type2,nil))
			maxValue = weakToWater if weakToWater > maxValue
		end
		
		chosenItem = nil
		if maxValue > 0
			results = {SHOCKDRIVE: weakToElectric, BURNDRIVE: weakToFire, CHILLDRIVE: weakToIce, DOUSEDRIVE: weakToWater}
			results = results.sort_by{|k, v| v}.to_h
			results.delete_if{|k, v| v < maxValue}
			chosenItem = results.keys.sample
		end
		
		if !chosenItem
			battler.battle.pbDisplay(_INTL("The avatar of Genesect can't find any!"))
		else
			battler.battle.pbDisplay(_INTL("The avatar of Genesect loads a {1}!",GameData::Item.get(chosenItem).real_name))
			battler.item = chosenItem
		end
	}
)