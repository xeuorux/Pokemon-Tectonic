BattleHandlers::FieldEffectStatLossItem.add(:ROOMSERVICE,
	proc { |item,battler,battle|
		next false if battle.field.effects[PBEffects::TrickRoom] <= 0
		next false if !battler.pbCanLowerStatStage?(:SPEED,battler)
		itemName = GameData::Item.get(item).name
		battle.pbCommonAnimation("UseItem",battler)
		next battler.pbLowerStatStageByCause(:SPEED,2,battler,itemName)
	}
)