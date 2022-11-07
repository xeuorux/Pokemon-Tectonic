BattleHandlers::FieldEffectStatLossItem.add(:ROOMSERVICE,
	proc { |item,battler,battle|
		next false if !battle.field.effectActive?(:TrickRoom)
		next battler.tryLowerStat(:SPEED,battler,increment: 2, item: item)
	}
)