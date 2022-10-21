GameData::BattleEffect.register(:Battler,{
	:id => :AquaRing,
	:real_name => "AquaRing",
	:baton_passed => true,
	:eor_proc => proc { |battler,battle,value|
		next if !battler.canHeal?
		healAmount = battler.totalhp / 8.0
		healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
		healAmount *= 1.3 if battler.hasActiveItem?(:BIGROOT)
		healMessage = _INTL("The ring of water restored {1}'s HP!",battler.pbThis(true))
		battler.pbRecoverHP(healAmount,true,true,true,healMessage)
	}
})

GameData::BattleEffect.register(:Battler,{
	:id => :Attract,
	:real_name => "Attract",
	:type => :Position,
	:others_lose_track => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :BanefulBunker,
	:real_name => "BanefulBunker",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :BeakBlast,
	:real_name => "BeakBlast",
	:resets_battlers_eot => true,
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Bide,
	:real_name => "Bide",
	:type => :Integer,
	:resets_on_cancel => true,
	:multi_turn_tracker => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :BideDamage,
	:real_name => "BideDamage",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :BideTarget,
	:real_name => "BideTarget",
	:type => :Position,
})

GameData::BattleEffect.register(:Battler,{
	:id => :BurnUp,
	:real_name => "BurnUp",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Charge,
	:real_name => "Charge",
	:type => :Integer,
	:ticks_down => true,
	:resets_battlers_eot => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :ChoiceBand,
	:real_name => "ChoiceBand",
	:type => :Move,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Confusion,
	:real_name => "Confusion",
	:type => :Integer,
	:baton_passed => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Counter,
	:real_name => "Counter",
	:type => :Integer,
	:resets_eor => true,
	:default => -1,
})

GameData::BattleEffect.register(:Battler,{
	:id => :CounterTarget,
	:real_name => "CounterTarget",
	:type => :Position
	:resets_eor => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Curse,
	:real_name => "Curse",
	:baton_passed => true,
	:eor_proc => proc { |battle,battler,value|
		if battler.takesIndirectDamage?
			battle.pbDisplay(_INTL("{1} is afflicted by the curse!",battler.pbThis))
			battler.applyFractionalDamage(1.0/4.0,false)
		end
	}
})

GameData::BattleEffect.register(:Battler,{
	:id => :Dancer,
	:real_name => "Dancer",
})

GameData::BattleEffect.register(:Battler,{
	:id => :DefenseCurl,
	:real_name => "DefenseCurl",
})

GameData::BattleEffect.register(:Battler,{
	:id => :DestinyBond,
	:real_name => "DestinyBond",
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :DestinyBondPrevious,
	:real_name => "DestinyBondPrevious",
})

GameData::BattleEffect.register(:Battler,{
	:id => :DestinyBondTarget,
	:real_name => "DestinyBondTarget",
	:type => :Position,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Disable,
	:real_name => "Disable",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => proc { |battle, battler|
		battle.pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis))
		battler.disableEffect(:DisableMove)
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :DisableMove,
	:real_name => "DisableMove",
	:type => :Move
})

GameData::BattleEffect.register(:Battler,{
	:id => :Electrify,
	:real_name => "Electrify",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Embargo,
	:real_name => "Embargo",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:expire_proc => proc { |battle, battler|
		battle.pbDisplay(_INTL("{1} can use items again!",battler.pbThis))
		battler.pbItemTerrainStatBoostCheck
	    battler.pbItemFieldEffectCheck
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :Encore,
	:real_name => "Encore",
	:eor_proc => proc { |battle,battler,value|
		next if battler.fainted?
		idxEncoreMove = b.pbEncoredMoveIndex
		if idxEncoreMove>=0
		  b.effects[PBEffects::Encore] -= 1
		  if b.effects[PBEffects::Encore]==0 || b.moves[idxEncoreMove].pp==0
			b.effects[PBEffects::Encore] = 0
			pbDisplay(_INTL("{1}'s encore ended!",b.pbThis))
		  end
		else
		  PBDebug.log("[End of effect] #{b.pbThis}'s encore ended (encored move no longer known)")
		  b.effects[PBEffects::Encore]     = 0
		  b.effects[PBEffects::EncoreMove] = nil
		end
	}
})

GameData::BattleEffect.register(:Battler,{
	:id => :EncoreMove,
	:real_name => "EncoreMove",
	:type => :Move,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Endure,
	:real_name => "Endure",
	:resets_eor	=> true,
})

# Stores a move code
GameData::BattleEffect.register(:Battler,{
	:id => :FirstPledge,
	:real_name => "FirstPledge",
	:type => :Integer,
	:default => 0,
})

GameData::BattleEffect.register(:Battler,{
	:id => :FlashFire,
	:real_name => "FlashFire",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Flinch,
	:real_name => "Flinch",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :FocusEnergy,
	:real_name => "FocusEnergy",
	:type => :Integer,
	:baton_passed => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :FocusPunch,
	:real_name => "FocusPunch",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :FollowMe,
	:real_name => "FollowMe",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Foresight,
	:real_name => "Foresight",
})

GameData::BattleEffect.register(:Battler,{
	:id => :FuryCutter,
	:real_name => "FuryCutter",
	:type => :Integer,
	:resets_on_cancel => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :GastroAcid,
	:real_name => "GastroAcid",
	:baton_passed => true,
	:pass_value_proc => proc { |battler,value|
		next false if battler.unstoppableAbility?
		next value
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :GemConsumed,
	:real_name => "GemConsumed",
	:type => :Item,
	:resets_battlers_eot => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Grudge,
	:real_name => "Grudge",
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :HealBlock,
	:real_name => "HealBlock",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:expire_proc => proc { |battle, battler|
		battle.pbDisplay(_INTL("{1} Heal Block wore off!",battler.pbThis))
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :HelpingHand,
	:real_name => "HelpingHand",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :HyperBeam,
	:real_name => "HyperBeam",
	:type => :Integer,
	:ticks_down => true,
	:multi_turn_tracker => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Illusion,
	:real_name => "Illusion",
	:type => :Pokemon,
	:initialize_proc => proc { |battle,battler|
		if battler.hasActiveAbility?(:ILLUSION)
			idxLastParty = battle.pbLastInTeam(battler.index)
			if idxLastParty >= 0 && idxLastParty != battler.pokemonIndex
				battler.effects[:Illusion]        = battle.pbParty(battler.index)[idxLastParty]
			end
		end
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :Imprison,
	:real_name => "Imprison",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Ingrain,
	:real_name => "Ingrain",
	:baton_passed => true,
	:eor_proc => proc { |battler,battle,value|
		next if !battler.canHeal?
		healAmount = battler.totalhp / 8.0
		healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
		healAmount *= 1.3 if battler.hasActiveItem?(:BIGROOT)
		healMessage = _INTL("{1} absorbed nutrients with its roots!",battler.pbThis)
		battler.pbRecoverHP(healAmount,true,true,true,healMessage)
	}
})

GameData::BattleEffect.register(:Battler,{
	:id => :Instruct,
	:real_name => "Instruct",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Instructed,
	:real_name => "Instructed",
})

GameData::BattleEffect.register(:Battler,{
	:id => :KingsShield,
	:real_name => "King's Shield",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :LaserFocus,
	:real_name => "Laser Focus",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:pass_value_proc => proc { |battler,value|
		next 2 if value > 0
		next 0
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :LeechSeed,
	:real_name => "Leech Seed",
	:type => :Position,
	:baton_passed => true,
	:eor_proc => proc { |battler,battle,value|
		next if !battler.takesIndirectDamage?
		recipient = battle.battlers[value]
		next if !recipient || recipient.fainted?
		pbCommonAnimation("LeechSeed",recipient,battler)
		oldHPRecipient = recipient.hp
		hpLost = battler.applyFractionalDamage(1.0/8.0,false)
		drainMessage = _INTL("{1}'s health is sapped by Leech Seed!",battler.pbThis)
		recipient.pbRecoverHPFromDrain(hpLost,battler,drainMessage)
	}
})

GameData::BattleEffect.register(:Battler,{
	:id => :LockOn,
	:real_name => "Lock On",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:others_lose_track = true,
	:pass_value_proc => proc { |battler,value|
		next 2 if value > 0
		next 0
	},
	:expire_proc => proc { |battle,battler|
		battler.disableEffect(:LockOnPos)
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :LockOnPos,
	:real_name => "LockOnPos",
	:type => :Position,
	:baton_passed => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :MagicBounce,
	:real_name => "MagicBounce",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :MagicCoat,
	:real_name => "MagicCoat",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :MagnetRise,
	:real_name => "MagnetRise",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:expire_proc => proc { |battle, battler|
		battle.pbDisplay(_INTL("{1} electromagnetism wore off!",battler.pbThis))
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :MeanLook,
	:real_name => "MeanLook",
	:type => :Position,
	:others_lose_track => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :MeFirst,
	:real_name => "MeFirst",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Metronome,
	:real_name => "Metronome",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :MicleBerry,
	:real_name => "MicleBerry",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Minimize,
	:real_name => "Minimize",
})

GameData::BattleEffect.register(:Battler,{
	:id => :MiracleEye,
	:real_name => "MiracleEye",
})

GameData::BattleEffect.register(:Battler,{
	:id => :MirrorCoat,
	:real_name => "MirrorCoat",
	:type => :Integer,
	:resets_eor => true,
	:default => -1,
})

GameData::BattleEffect.register(:Battler,{
	:id => :MirrorCoatTarget,
	:real_name => "MirrorCoatTarget",
	:type => :Position,
	:resets_eor => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :MoveNext,
	:real_name => "MoveNext",
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :MudSport,
	:real_name => "MudSport",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Nightmare,
	:real_name => "Nightmare",
	:eor_proc => proc { |battle,battler,value|
		if !battler.asleep?
			battler.effects[:Nightmare] = false
		elsif battler.takesIndirectDamage?
			battle.pbDisplay(_INTL("{1} is locked in a nightmare!",battler.pbThis))
			battler.applyFractionalDamage(1.0/4.0,false)
		end
	}
})

GameData::BattleEffect.register(:Battler,{
	:id => :Outrage,
	:real_name => "Outrage",
	:type => :Integer,
	:resets_on_cancel => true,
	:multi_turn_tracker => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :ParentalBond,
	:real_name => "ParentalBond",
	:type => :Integer,
})

# The logic here is complex enough that it is handled elsewhere
GameData::BattleEffect.register(:Battler,{
	:id => :PerishSong,
	:real_name => "PerishSong",
	:type => :Integer,
	:baton_passed => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :PerishSongUser,
	:real_name => "PerishSongUser",
	:type => :Position,
	:baton_passed => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :PickupItem,
	:real_name => "PickupItem",
	:type => :Item,
})

# I don't really understand this one
GameData::BattleEffect.register(:Battler,{
	:id => :PickupUse,
	:real_name => "PickupUse",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Pinch,
	:real_name => "Pinch",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Powder,
	:real_name => "Powder",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :PowerTrick,
	:real_name => "PowerTrick",
	:baton_passed => true,
	:apply_proc => proc { |battle,battler,value|
		battler.attack,battler.defense = battler.defense,battler.attack
	}
})

GameData::BattleEffect.register(:Battler,{
	:id => :Prankster,
	:real_name => "Prankster",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :PriorityAbility,
	:real_name => "PriorityAbility",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :PriorityItem,
	:real_name => "PriorityItem",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Protect,
	:real_name => "Protect",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :ProtectRate,
	:real_name => "ProtectRate",
	:type => :Integer,
	:default => 1,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Pursuit,
	:real_name => "Pursuit",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Quash,
	:real_name => "Quash",
	:type => :Integer,
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Rage,
	:real_name => "Rage",
})

GameData::BattleEffect.register(:Battler,{
	:id => :RagePowder,
	:real_name => "RagePowder",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Roost,
	:real_name => "Roost",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :ShellTrap,
	:real_name => "ShellTrap",
	:resets_battlers_eot => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :SkyDrop,
	:real_name => "SkyDrop",
	:type => :Position,
	:others_lose_track => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :SlowStart,
	:real_name => "SlowStart",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => proc { |battle, battler|
		battle.pbDisplay(_INTL("{1} finally got its act together!",battler.pbThis))
	}
})

GameData::BattleEffect.register(:Battler,{
	:id => :SmackDown,
	:real_name => "SmackDown",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Snatch,
	:real_name => "Snatch",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :SpikyShield,
	:real_name => "SpikyShield",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Spotlight,
	:real_name => "Spotlight",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Stockpile,
	:real_name => "Stockpile",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :StockpileDef,
	:real_name => "StockpileDef",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :StockpileSpDef,
	:real_name => "StockpileSpDef",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Substitute,
	:real_name => "Substitute",
	:type => :Integer,
	:baton_passed => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Taunt,
	:real_name => "Taunt",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => proc { |battle, battler|
		battle.pbDisplay(_INTL("{1} taunt wore off.",battler.pbThis))
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :Telekinesis,
	:real_name => "Telekinesis",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:pass_value_proc => proc { |battler,value|
		next 0 if if battler.isSpecies?(:GENGAR) && battler.mega?
		next value
	},
	:expire_proc => proc { |battle, battler|
		battle.pbDisplay(_INTL("{1} electromagnetism wore off!",battler.pbThis))
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :ThroatChop,
	:real_name => "ThroatChop",
	:type => :Integer,
	:ticks_down => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Torment,
	:real_name => "Torment",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Toxic,
	:real_name => "Toxic",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Transform,
	:real_name => "Transform",
})

GameData::BattleEffect.register(:Battler,{
	:id => :TransformSpecies,
	:real_name => "TransformSpecies",
	:type => :Species,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Trapping,
	:real_name => "Trapping",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => proc { |battle,battler|
		moveName = GameData::Move.get(battler.effects[:TrappingMove]).name
        battle.pbDisplay(_INTL("{1} was freed from {2}!",battler.pbThis,moveName))
	},
	:remain_proc => proc { |battle,battler,value|
		moveName = GameData::Move.get(battler.effects[:TrappingMove]).name
		case battler.effects[:TrappingMove]
        when :BIND,:VINEBIND            then pbCommonAnimation("Bind", battler
        when :CLAMP,:SLAMSHUT           then pbCommonAnimation("Clamp", battler
        when :FIRESPIN,:CRIMSONSTORM    then pbCommonAnimation("FireSpin", battler
        when :MAGMASTORM                then pbCommonAnimation("MagmaStorm", battler
        when :SANDTOMB,:SANDVORTEX      then pbCommonAnimation("SandTomb", battler
        when :INFESTATION               then pbCommonAnimation("Infestation", battler
	    when :SNAPTRAP 	                then pbCommonAnimation("SnapTrap",battler
        when :THUNDERCAGE               then pbCommonAnimation("ThunderCage",battler
        else                            pbCommonAnimation("Wrap", battler
        end
        if battler.takesIndirectDamage?
          fraction = (Settings::MECHANICS_GENERATION >= 6) ? 1.0/8.0 : 1.0/16.0
          fraction *= 2 if battle.battlers[battler.effects[:TrappingUser]].hasActiveItem?(:BINDINGBAND)
          battle.pbDisplay(_INTL("{1} is hurt by {2}!",battler.pbThis,moveName))
          battler.applyFractionalDamage(fraction)
        end
	}
	:disable_others => [:TrappingMove,:TrappingUser],
})

GameData::BattleEffect.register(:Battler,{
	:id => :TrappingMove,
	:real_name => "TrappingMove",
	:type => :Move,
	:disable_others => [:Trapping,:TrappingUser],
})

GameData::BattleEffect.register(:Battler,{
	:id => :TrappingUser,
	:real_name => "TrappingUser",
	:type => :Position,
	:others_lose_track => true,
	:disable_others => [:Trapping,:TrappingMove],
})

GameData::BattleEffect.register(:Battler,{
	:id => :Truant,
	:real_name => "Truant",
})

GameData::BattleEffect.register(:Battler,{
	:id => :TwoTurnAttack,
	:real_name => "TwoTurnAttack",
	:type => :Move,
	:resets_on_cancel => true,
	:multi_turn_tracker => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Type3,
	:real_name => "Type 3",
	:type => :Type,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Unburden,
	:real_name => "Unburden",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Uproar,
	:real_name => "Uproar",
	:type => :Integer,
	:resets_on_cancel => true,
	:ticks_down = true,
	:multi_turn_tracker => true,
	:remain_proc => proc { |battle, battler,value|
		battle.pbDisplay(_INTL("{1} is making an uproar!",battler.pbThis))
	}
	:expire_proc => proc { |battle, battler|
		battle.pbDisplay(_INTL("{1} calmed down.",battler.pbThis))
	}
})

GameData::BattleEffect.register(:Battler,{
	:id => :WaterSport,
	:real_name => "WaterSport",
})

GameData::BattleEffect.register(:Battler,{
	:id => :WeightChange,
	:real_name => "WeightChange",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Yawn,
	:real_name => "Yawn",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => proc { |battle, battler|
		if battler.pbCanSleepYawn?
			PBDebug.log("[Lingering effect] #{battler.pbThis} fell asleep because of Yawn")
			battler.pbSleep
		end
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :GorillaTactics,
	:real_name => "GorillaTactics",
	:type => :Move,
})

GameData::BattleEffect.register(:Battler,{
	:id => :BallFetch,
	:real_name => "BallFetch",
	:type => :Item,
})

GameData::BattleEffect.register(:Battler,{
	:id => :LashOut,
	:real_name => "LashOut",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :BurningJealousy,
	:real_name => "BurningJealousy",
})

GameData::BattleEffect.register(:Battler,{
	:id => :NoRetreat,
	:real_name => "NoRetreat",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Obstruct,
	:real_name => "Obstruct",
})

GameData::BattleEffect.register(:Battler,{
	:id => :JawLock,
	:real_name => "JawLock",
	:baton_passed => true,
	:apply_proc => proc { |battle,battler,value|
		if value == 0
			battler.disableEffect(:JawLockUser)
		end
	}
	:disable_others => [:JawLockUser],
})

GameData::BattleEffect.register(:Battler,{
	:id => :JawLockUser,
	:real_name => "JawLockUser",
	:type => :Position,
	:baton_passed => true,
	:others_lose_track => true,
	:disable_others => [:JawLock],
})

GameData::BattleEffect.register(:Battler,{
	:id => :TarShot,
	:real_name => "TarShot",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Octolock,
	:real_name => "Octolock",
	:eor_proc => proc { |battle,battler,value|
		octouser = battle.battlers[battler.effects[:OctolockUser]]
		if battler.pbCanLowerStatStage?(:DEFENSE,octouser,self)
			battler.pbLowerStatStage(:DEFENSE,1,octouser,true,false,true)
		end
		if battler.pbCanLowerStatStage?(:SPECIAL_DEFENSE,octouser,self)
			battler.pbLowerStatStage(:SPECIAL_DEFENSE,1,octouser,true,false,true)
		end
	}
	:apply_proc => proc { |battle,battler,value|
		if value == 0
			battler.disableEffect(:OctolockUser)
		end
	}
	:disable_others => [:OctolockUser],
})

GameData::BattleEffect.register(:Battler,{
	:id => :OctolockUser,
	:real_name => "OctolockUser",
	:type => :Position,
	:others_lose_track => true,
	:disable_others => [:Octolock],
})

GameData::BattleEffect.register(:Battler,{
	:id => :BlunderPolicy,
	:real_name => "BlunderPolicy",
})

GameData::BattleEffect.register(:Battler,{
	:id => :SwitchedAlly,
	:real_name => "SwitchedAlly",
	:type => :Position,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Sentry,
	:real_name => "Sentry",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Assist,
	:real_name => "Assist",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :ConfusionChance,
	:real_name => "ConfusionChance",
	:type => :Integer,
	:baton_passed => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :FlinchedAlready,
	:real_name => "FlinchedAlready",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Enlightened,
	:real_name => "Enlightened",
})

GameData::BattleEffect.register(:Battler,{
	:id => :ColdConversion,
	:real_name => "ColdConversion",
})

GameData::BattleEffect.register(:Battler,{
	:id => :CreepOut,
	:real_name => "CreepOut",
})

GameData::BattleEffect.register(:Battler,{
	:id => :LuckyStar,
	:real_name => "LuckyStar",
})

GameData::BattleEffect.register(:Battler,{
	:id => :Charm,
	:real_name => "Charm",
	:type => :Integer,
	:baton_passed => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :CharmChance,
	:real_name => "CharmChance",
	:type => :Integer,
	:baton_passed => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Inured,
	:real_name => "Inured",
})

GameData::BattleEffect.register(:Battler,{
	:id => :NoRetreat,
	:real_name => "NoRetreat",
	:baton_passed => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :NerveBreak,
	:real_name => "NerveBreak",
})

GameData::BattleEffect.register(:Battler,{
	:id => :IceBall,
	:real_name => "IceBall",
	:type => :Integer,
	:resets_on_cancel => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :RollOut,
	:real_name => "RollOut",
	:type => :Integer,
	:resets_on_cancel => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :StunningCurl,
	:real_name => "StunningCurl",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :RedHotRetreat,
	:real_name => "RedHotRetreat",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :ExtraTurns,
	:real_name => "ExtraTurns",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :EmpoweredMoonlight,
	:real_name => "EmpoweredMoonlight",
})

GameData::BattleEffect.register(:Battler,{
	:id => :EmpoweredEndure,
	:real_name => "EmpoweredEndure",
	:type => :Integer,
})

GameData::BattleEffect.register(:Battler,{
	:id => :EmpoweredLaserFocus,
	:real_name => "EmpoweredLaserFocus",
})

GameData::BattleEffect.register(:Battler,{
	:id => :EmpoweredDestinyBond,
	:real_name => "EmpoweredDestinyBond",
})

GameData::BattleEffect.register(:Battler,{
	:id => :VolleyStance,
	:real_name => "VolleyStance",
})

GameData::BattleEffect.register(:Battler,{
	:id => :GivingDragonRideTo,
	:real_name => "GivingDragonRideTo",
	:type => :Position,
	:others_lose_track => true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :OnDragonRide,
	:real_name => "OnDragonRide",
})

GameData::BattleEffect.register(:Battler,{
	:id => :ShimmeringHeat,
	:real_name => "ShimmeringHeat",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :FlareWitch,
	:real_name => "FlareWitch",
})

GameData::BattleEffect.register(:Battler,{
	:id => :EmpoweredDetect,
	:real_name => "EmpoweredDetect",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => proc { |battle, battler|
		battle.pbDisplay(_INTL("{1}'s Primeval Detect wore off!",battler.pbThis))
	},
})

GameData::BattleEffect.register(:Battler,{
	:id => :MirrorShield,
	:real_name => "MirrorShield",
	:resets_eor	=> true,
})

GameData::BattleEffect.register(:Battler,{
	:id => :Echo,
	:real_name => "Echo",
})