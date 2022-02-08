BattleHandlers::SpeedCalcAbility.add(:QUICKTHINKING,
  proc { |ability,battler,mult|
    next mult*2 if battler.battle.field.terrain == :Psychic
  }
)

BattleHandlers::SpeedCalcAbility.add(:BROODING,
  proc { |ability,battler,mult|
	dragonCount = 0
	battler.battle.eachInTeamFromBattlerIndex(battler.index) do |pkmn,i|
		dragonCount += 1 if pkmn.pbHasType?(:DRAGON)
	end
	next mult * (1.0 + dragonCount * 0.05) 
  }
)