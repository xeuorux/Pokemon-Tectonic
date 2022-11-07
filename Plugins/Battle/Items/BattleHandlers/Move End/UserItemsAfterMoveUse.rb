BattleHandlers::UserItemAfterMoveUse.add(:LIFEORB,
    proc { |item,user,targets,move,numHits,battle|
      next if !user.takesIndirectDamage?
      next if !move.pbDamagingMove? || numHits==0
      hitBattler = false
      targets.each do |b|
        hitBattler = true if !b.damageState.unaffected && !b.damageState.substitute
        break if hitBattler
      end
      next if !hitBattler
      PBDebug.log("[Item triggered] #{user.pbThis}'s #{user.itemName} (recoil)")
      battle.pbDisplay(_INTL("{1} lost some of its HP!",user.pbThis))
      user.applyFractionalDamage(1.0/10.0)
    }
  )
  
  BattleHandlers::UserItemAfterMoveUse.add(:SHELLBELL,
    proc { |item,user,targets,move,numHits,battle|
      next if !user.canHeal?
      totalDamage = 0
      targets.each { |b| totalDamage += b.damageState.totalHPLost }
      next if totalDamage<=0
        healAmount = (totalDamage / 6.0)
        healAmount = 1 if healAmount < 1
      recoverMessage = _INTL("{1} restored a little HP using its {2}!", user.pbThis,user.itemName)
      user.pbRecoverHP(healAmount,true,true,true,recoverMessage)
    }
  )

  BattleHandlers::UserItemAfterMoveUse.add(:THROATSPRAY,
    proc { |item, user, targets, move, numHits, battle|
      next if battle.pbAllFainted?(user.idxOwnSide) ||
              battle.pbAllFainted?(user.idxOpposingSide)
      next if !move.soundMove? || numHits == 0
      user.tryRaiseStat(:SPECIAL_ATTACK,user,item: user.item)
    }
  )