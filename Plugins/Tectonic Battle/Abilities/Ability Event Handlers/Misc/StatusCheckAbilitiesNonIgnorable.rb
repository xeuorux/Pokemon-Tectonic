BattleHandlers::StatusCheckAbilityNonIgnorable.add(:COMATOSE,
  proc { |_ability, battler, status|
      next false unless battler.countsAs?(:KOMALA)
      next true if status.nil? || status == :SLEEP
  }
)
