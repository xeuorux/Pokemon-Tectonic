BattleHandlers::ItemOnEnemyStatGain.add(:MIRRORHERB,
  proc { |item, battler, stat, increment, user, battle, benefactor|
    next if battler.effectActive?(:ParadoxHerbConsumed) && !battler.pointsAt?(:ParadoxHerbConsumed,benefactor)
    next unless battler.pbCanRaiseStatStep?(stat, battler)
    battler.pointAt(:MirrorHerbConsumed,benefactor)
    battler.effects[:MirrorHerbCopiedStats] = {} unless battler.effectActive?(:MirrorHerbCopiedStats)
    statsHash = battler.effects[:MirrorHerbCopiedStats]
    if statsHash.key?(stat)
      statsHash[stat] += increment
    else
      statsHash[stat] = increment
    end
  }
)

BattleHandlers::ItemOnEnemyStatGain.add(:PARADOXHERB,
  proc { |item, battler, stat, increment, user, battle, benefactor|
    battler.pointAt(:ParadoxHerbConsumed,benefactor)
  }
)