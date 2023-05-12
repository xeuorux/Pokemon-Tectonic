BattleHandlers::StatusCheckAbilityNonIgnorable.add(:COMATOSE,
  proc { |ability, battler, status|
      validSpeciesList = %i[KOMALA]
      validTransform = false
      validTransform = true if validSpeciesList.include?(battler.effects[:TransformSpecies])
      isTransformed = battler.transformed? && validTransform
      validSpecies = validSpeciesList.include?(battler.species)
      next false unless validSpecies || isTransformed
      next true if status.nil? || status == :SLEEP
  }
)
