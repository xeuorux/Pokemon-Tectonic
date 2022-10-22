BattleHandlers::StatusCheckAbilityNonIgnorable.add(:COMATOSE,
  proc { |ability,battler,status|
  validSpeciesList = [:PARSECT,:KOMALA,:MUSHARNA]
	validTransform = false
	validTransform = true if validSpeciesList.include?(battler.effects[PBEffects::TransformSpecies])
	isTransformed = false
	isTransformed = battler.effects[PBEffects::Transform] && validTransform
	validSpecies = validSpeciesList.include?(battler.species)
    next false if !(validSpecies || isTransformed)
    next true if status.nil? || status == :SLEEP
  }
)