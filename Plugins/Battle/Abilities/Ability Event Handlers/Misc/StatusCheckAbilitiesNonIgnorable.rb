BattleHandlers::StatusCheckAbilityNonIgnorable.add(:COMATOSE,
  proc { |_ability, battler, status|
      validSpeciesList = %i[PARSECT KOMALA MUSHARNA]
      validTransform = false
      validTransform = true if validSpeciesList.include?(battler.effects[:TransformSpecies])
      isTransformed = false
      isTransformed = battler.transformed? && validTransform
      validSpecies = validSpeciesList.include?(battler.species)
      next false unless validSpecies || isTransformed
      next true if status.nil? || status == :SLEEP
  }
)
