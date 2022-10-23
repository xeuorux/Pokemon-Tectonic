BattleHandlers::StatusCheckAbilityNonIgnorable.add(:COMATOSE,
  proc { |ability,battler,status|
  validSpeciesList = [:PARSECT,:KOMALA,:MUSHARNA]
	validTransform = false
	validTransform = true if validSpeciesList.include?(battler.effects[:TransformSpecies])
	isTransformed = false
	isTransformed = battler.transformed? && validTransform
	validSpecies = validSpeciesList.include?(battler.species)
    next false if !(validSpecies || isTransformed)
    next true if status.nil? || status == :SLEEP
  }
)