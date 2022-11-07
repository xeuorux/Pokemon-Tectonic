BattleHandlers::UserAbilityOnHit.add(:POISONTOUCH,
  proc { |ability,user,target,move,battle|
    randomStatusProcAbility(:POISON,30,user,target,move,battle) if move.physicalMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:SHOCKSTYLE,
  proc { |ability,user,target,move,battle|
    randomStatusProcAbility(:PARALYSIS,50,user,target,move,battle) if move.type == :FIGHTING
  }
)

BattleHandlers::UserAbilityOnHit.add(:FROSTWINGS,
  proc { |ability,user,target,move,battle|
    randomStatusProcAbility(:FROSTBITE,20,user,target,move,battle) if move.type == :FLYING
  }
)

BattleHandlers::UserAbilityOnHit.add(:SHOCKWINGS,
  proc { |ability,user,target,move,battle|
    randomStatusProcAbility(:PARALYSIS,20,user,target,move,battle) if move.type == :FLYING
  }
)

BattleHandlers::UserAbilityOnHit.add(:FLAMEWINGS,
  proc { |ability,user,target,move,battle|
    randomStatusProcAbility(:BURN,20,user,target,move,battle) if move.type == :FLYING
  }
)
BattleHandlers::UserAbilityOnHit.add(:BURNSKILL,
  proc { |ability,user,target,move,battle|
    randomStatusProcAbility(:BURN,30,user,target,move,battle) if move.specialMove?
	}
)

BattleHandlers::UserAbilityOnHit.add(:CHILLOUT,
  proc { |ability,user,target,move,battle|
    randomStatusProcAbility(:FROSTBITE,30,user,target,move,battle) if move.specialMove?
	}
)

BattleHandlers::UserAbilityOnHit.add(:NUMBINGTOUCH,
  proc { |ability,user,target,move,battle|
    randomStatusProcAbility(:PARALYSIS,30,user,target,move,battle) if move.physicalMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:NERVENUMBER,
  proc { |ability,user,target,move,battle|
    randomStatusProcAbility(:PARALYSIS,30,user,target,move,battle) if move.specialMove?
  }
)

BattleHandlers::UserAbilityOnHit.add(:SOUNDBARRIER,
  proc { |ability,user,target,move,battle|
    next if !move.soundMove?
    user.tryRaiseStat(:DEFENSE,user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:DAWNBURST,
  proc { |ability,user,target,move,battle|
    next if user.turnCount > 1
    randomStatusProcAbility(:BURN,100,user,target,move,battle)
  }
)