GameData::BattleEffect.register_effect(:Battler,{
	:id => :AquaRing,
	:real_name => "Aqua Ring",
	:baton_passed => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",battler.pbThis))
	},
	:eor_proc => Proc.new { |battler,battle,value|
		next if !battler.canHeal?
		healAmount = battler.totalhp / 8.0
		healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
		healAmount *= 1.3 if battler.hasActiveItem?(:BIGROOT)
		healMessage = _INTL("The ring of water restored {1}'s HP!",battler.pbThis(true))
		battler.pbRecoverHP(healAmount,true,true,true,healMessage)
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Attract,
	:real_name => "Attract",
	:type => :Position,
	:others_lose_track => true,
	:is_mental => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BeakBlast,
	:real_name => "Beak Blast",
	:resets_battlers_eot => true,
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Bide,
	:real_name => "Bide Turns",
	:type => :Integer,
	:resets_on_cancel => true,
	:multi_turn_tracker => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BideDamage,
	:real_name => "Bide Damage",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BideTarget,
	:real_name => "Bide Target",
	:type => :Position,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BurnUp,
	:real_name => "Burnt Up",
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Charge,
	:real_name => "Charged",
	:type => :Integer,
	:ticks_down => true,
	:resets_battlers_eot => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} began charging power!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ChoiceBand,
	:real_name => "Choice Band",
	:type => :Move,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Confusion,
	:real_name => "Confusion Turns",
	:type => :Integer,
	:baton_passed => true,
	:is_mental => true,
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis))
	},
	:sub_effects => [:ConfusionChance],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Counter,
	:real_name => "Counter Damage",
	:type => :Integer,
	:resets_eor => true,
	:default => -1,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :CounterTarget,
	:real_name => "Counter Target",
	:type => :Position,
	:resets_eor => true,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Curse,
	:real_name => "Cursed",
	:baton_passed => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} is cursed!",battler.pbThis))
	},
	:eor_proc => Proc.new { |battle,battler,value|
		if battler.takesIndirectDamage?
			battle.pbDisplay(_INTL("{1} is afflicted by the curse!",battler.pbThis))
			battler.applyFractionalDamage(1.0/4.0,false)
		end
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Dancer,
	:real_name => "Dancer",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :DefenseCurl,
	:real_name => "Curled Up",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :DestinyBond,
	:real_name => "Destiny Bond",
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :DestinyBondPrevious,
	:real_name => "Destiny Bond Previous",
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :DestinyBondTarget,
	:real_name => "Destiny Bond Target",
	:type => :Position,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Disable,
	:real_name => "Disable Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis))
	},
	:is_mental => true,
	:sub_effects => [:DisableMove],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :DisableMove,
	:real_name => "Disabled Move",
	:type => :Move,
	:apply_proc => Proc.new { |battle, battler, value|
		moveName = GameData::Move.get(value).name
		battle.pbDisplay(_INTL("{1}'s {2} was disabled!",battler.pbThis,moveName))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Electrify,
	:real_name => "Electrify",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Embargo,
	:real_name => "Embargo Turns",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} can use items again!",battler.pbThis))
		battler.pbItemTerrainStatBoostCheck
	    battler.pbItemFieldEffectCheck
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Encore,
	:real_name => "Encore Turns",
	:eor_proc => Proc.new { |battle,battler,value|
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
	},
	:is_mental => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EncoreMove,
	:real_name => "Must Use",
	:type => :Move,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Endure,
	:real_name => "Endure",
	:resets_eor	=> true,
})

# Stores a move code
GameData::BattleEffect.register_effect(:Battler,{
	:id => :FirstPledge,
	:real_name => "First Pledge",
	:type => :Integer,
	:default => 0,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FlashFire,
	:real_name => "Fired Up",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Flinch,
	:real_name => "Flinch",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FocusEnergy,
	:real_name => "Crit Chance Up",
	:type => :Integer,
	:baton_passed => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FocusPunch,
	:real_name => "Focus Punch",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FollowMe,
	:real_name => "Follow Me",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Foresight,
	:real_name => "Identified",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :GastroAcid,
	:real_name => "Ability Surpressed",
	:baton_passed => true,
	:pass_value_proc => Proc.new { |battler,value|
		next false if battler.unstoppableAbility?
		next value
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :GemConsumed,
	:real_name => "Gem Consumed",
	:type => :Item,
	:resets_battlers_eot => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Grudge,
	:real_name => "Grudge",
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :HealBlock,
	:real_name => "Healing Blocked",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} Heal Block wore off!",battler.pbThis))
	},
	:is_mental => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :HelpingHand,
	:real_name => "Helping Hand",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :HyperBeam,
	:real_name => "Recharging",
	:type => :Integer,
	:ticks_down => true,
	:multi_turn_tracker => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Illusion,
	:real_name => "Illusion",
	:type => :Pokemon,
	:initialize_proc => Proc.new { |battle,battler|
		if battler.hasActiveAbility?(:ILLUSION)
			idxLastParty = battle.pbLastInTeam(battler.index)
			if idxLastParty >= 0 && idxLastParty != battler.pokemonIndex
				toDisguiseAs = battle.pbParty(battler.index)[idxLastParty]
				battler.applyEffect(:Illusion,toDisguiseAs)
			end
		end
	},
	:expire_proc => Proc.new { |battle,battler|
		battle.pbDisplay(_INTL("{1}'s illusion wore off!",battler.pbThis))
	},
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Imprison,
	:real_name => "Moves Imprisoned",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Ingrain,
	:real_name => "Ingrained",
	:baton_passed => true,
	:trapping => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} firmly planted its roots! It can't be moved!",battler.pbThis))
	},
	:eor_proc => Proc.new { |battler,battle,value|
		next if !battler.canHeal?
		healAmount = battler.totalhp / 8.0
		healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
		healAmount *= 1.3 if battler.hasActiveItem?(:BIGROOT)
		healMessage = _INTL("{1} absorbed nutrients with its roots!",battler.pbThis)
		battler.pbRecoverHP(healAmount,true,true,true,healMessage)
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Instruct,
	:real_name => "Instruct",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Instructed,
	:real_name => "Instructed",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :LaserFocus,
	:real_name => "Laser Focus Turns",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:pass_value_proc => Proc.new { |battler,value|
		next 2 if value > 0
		next 0
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :LeechSeed,
	:real_name => "Seeded",
	:type => :Position,
	:baton_passed => true,
	:eor_proc => Proc.new { |battler,battle,value|
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

GameData::BattleEffect.register_effect(:Battler,{
	:id => :LockOn,
	:real_name => "Locked On",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:others_lose_track => true,
	:pass_value_proc => Proc.new { |battler,value|
		next 2 if value > 0
		next 0
	},
	:sub_effects => [:LockOnPos],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :LockOnPos,
	:real_name => "Locked On To",
	:type => :Position,
	:baton_passed => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MagicBounce,
	:real_name => "Magic Bounce",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MagicCoat,
	:real_name => "Magic Coat",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MagnetRise,
	:real_name => "Magnet Risen",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} electromagnetism wore off!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MeanLook,
	:real_name => "Cannot Escape",
	:type => :Position,
	:trapping => true,
	:others_lose_track => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} can no longer escape!", battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MeFirst,
	:real_name => "Me First",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Metronome,
	:real_name => "Metronome Count",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MicleBerry,
	:real_name => "Micle Berry",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Minimize,
	:real_name => "Minimized",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MiracleEye,
	:real_name => "Miracle Eye",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MirrorCoat,
	:real_name => "Mirror Coat Damage",
	:type => :Integer,
	:resets_eor => true,
	:default => -1,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MirrorCoatTarget,
	:real_name => "Mirror Coat Target",
	:type => :Position,
	:resets_eor => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MoveNext,
	:real_name => "Will Move Next",
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MudSport,
	:real_name => "Electric Resistant",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Nightmare,
	:real_name => "Nightmared",
	:eor_proc => Proc.new { |battle,battler,value|
		if !battler.asleep?
			battler.effects[:Nightmare] = false
		elsif battler.takesIndirectDamage?
			battle.pbDisplay(_INTL("{1} is locked in a nightmare!",battler.pbThis))
			battler.applyFractionalDamage(1.0/4.0,false)
		end
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Outrage,
	:real_name => "Rampaging Turns",
	:type => :Integer,
	:resets_on_cancel => true,
	:multi_turn_tracker => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ParentalBond,
	:real_name => "Parental Bond",
	:type => :Integer,
	:resets_on_move_start => true,
})

# The logic here is complex enough that it is handled elsewhere
GameData::BattleEffect.register_effect(:Battler,{
	:id => :PerishSong,
	:real_name => "Perish Song Turns",
	:type => :Integer,
	:baton_passed => true,
	:sub_effects => [:PerishSongUser],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :PerishSongUser,
	:real_name => "Perish Singer",
	:type => :Position,
	:baton_passed => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :PickupItem,
	:real_name => "Pickup Item",
	:type => :Item,
	:sub_effects => [:PickupUse],
})

# I don't really understand this one
GameData::BattleEffect.register_effect(:Battler,{
	:id => :PickupUse,
	:real_name => "Pickup Use",
	:type => :Integer,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Pinch,
	:real_name => "Pinch",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Powder,
	:real_name => "Powder",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :PowerTrick,
	:real_name => "Power Tricked",
	:baton_passed => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battler.attack,battler.defense = battler.defense,battler.attack
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Prankster,
	:real_name => "Prankster",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :PriorityAbility,
	:real_name => "Priority Ability",
	:resets_eor	=> true,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :PriorityItem,
	:real_name => "Priority Item",
	:resets_eor	=> true,
	:info_displayed => false,
})


GameData::BattleEffect.register_effect(:Battler,{
	:id => :Pursuit,
	:real_name => "Pursuit",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Quash,
	:real_name => "Quash",
	:type => :Integer,
	:resets_battlers_sot => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Rage,
	:real_name => "Rage",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :RagePowder,
	:real_name => "Rage Powder",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Roost,
	:real_name => "Roosting",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ShellTrap,
	:real_name => "Shell Trap",
	:resets_battlers_eot => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :SkyDrop,
	:real_name => "Sky Drop",
	:type => :Position,
	:others_lose_track => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :SlowStart,
	:real_name => "Slow Start Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} finally got its act together!",battler.pbThis))
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :SmackDown,
	:real_name => "Smacked Down",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Snatch,
	:real_name => "Snatch",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Spotlight,
	:real_name => "Spotlight",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Stockpile,
	:real_name => "Stockpile Charges",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :StockpileDef,
	:real_name => "Stockpile Def",
	:type => :Integer,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :StockpileSpDef,
	:real_name => "Stockpile Sp Def",
	:type => :Integer,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Substitute,
	:real_name => "Substitute Health",
	:type => :Integer,
	:baton_passed => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplaySlower(_INTL("{1} put up a substitute!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Taunt,
	:real_name => "Taunted Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} taunt wore off.",battler.pbThis))
	},
	:is_mental => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Telekinesis,
	:real_name => "Telekinesis Turns",
	:type => :Integer,
	:ticks_down => true,
	:baton_passed => true,
	:pass_value_proc => Proc.new { |battler,value|
		next 0 if battler.isSpecies?(:GENGAR) && battler.mega?
		next value
	},
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} electromagnetism wore off!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ThroatChop,
	:real_name => "Throat Injured Turns",
	:type => :Integer,
	:ticks_down => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Torment,
	:real_name => "Tormented",
	:is_mental => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} was subjected to torment!",battler.pbThis))
		battler.pbItemStatusCureCheck
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Toxic,
	:real_name => "Toxic Turns Passed",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Transform,
	:real_name => "Transformed",
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :TransformSpecies,
	:real_name => "Transformed Into",
	:type => :Species,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Trapping,
	:real_name => "Trapping Turns",
	:type => :Integer,
	:ticks_down => true,
	:trapping => true,
	:expire_proc => Proc.new { |battle,battler|
		moveName = GameData::Move.get(battler.effects[:TrappingMove]).name
        battle.pbDisplay(_INTL("{1} was freed from {2}!",battler.pbThis,moveName))
	},
	:remain_proc => Proc.new { |battle,battler,value|
		moveName = GameData::Move.get(battler.effects[:TrappingMove]).name
		case battler.effects[:TrappingMove]
        when :BIND,:VINEBIND            then pbCommonAnimation("Bind", battler)
        when :CLAMP,:SLAMSHUT           then pbCommonAnimation("Clamp", battler)
        when :FIRESPIN,:CRIMSONSTORM    then pbCommonAnimation("FireSpin", battler)
        when :MAGMASTORM                then pbCommonAnimation("MagmaStorm", battler)
        when :SANDTOMB,:SANDVORTEX      then pbCommonAnimation("SandTomb", battler)
        when :INFESTATION               then pbCommonAnimation("Infestation", battler)
	    when :SNAPTRAP 	                then pbCommonAnimation("SnapTrap",battler)
        when :THUNDERCAGE               then pbCommonAnimation("ThunderCage",battler)
        else                            pbCommonAnimation("Wrap", battler)
        end
        if battler.takesIndirectDamage?
          fraction = 1.0/8.0
          fraction *= 2 if battler.getBattler(:TrappingUser).hasActiveItem?(:BINDINGBAND)
          battle.pbDisplay(_INTL("{1} is hurt by {2}!",battler.pbThis,moveName))
          battler.applyFractionalDamage(fraction)
        end
	},
	:sub_effects => [:TrappingMove,:TrappingUser],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :TrappingMove,
	:real_name => "Trapping Move",
	:type => :Move,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :TrappingUser,
	:real_name => "Trapped By",
	:type => :Position,
	:others_lose_track => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Truant,
	:real_name => "Slacking Off",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :TwoTurnAttack,
	:real_name => "Two Turn Attack",
	:type => :Move,
	:resets_on_cancel => true,
	:multi_turn_tracker => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Type3,
	:real_name => "Type 3",
	:type => :Type,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ItemLost,
	:real_name => "Item Lost",
	:info_displayed => false,
	:apply_proc => Proc.new { |battle,battler,value|
		if battler.hasActiveAbility?(:UNBURDEN)
			battle.pbShowAbilitySplash(battler)
			battle.pbDisplay(_INTL("{1} is unburdened of its item. Its Speed is doubled!",battler.pbThis))
			battle.pbHideAbilitySplash(battler)
		end
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Uproar,
	:real_name => "Uproar Turns",
	:type => :Integer,
	:resets_on_cancel => true,
	:ticks_down => true,
	:multi_turn_tracker => true,
	:remain_proc => Proc.new { |battle, battler,value|
		battle.pbDisplay(_INTL("{1} is making an uproar!",battler.pbThis))
	},
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} calmed down.",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :WaterSport,
	:real_name => "Fire Resistant",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :WeightChange,
	:real_name => "Weight Changed",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Yawn,
	:real_name => "Drowsy",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle, battler|
		if battler.pbCanSleepYawn?
			PBDebug.log("[Lingering effect] #{battler.pbThis} fell asleep because of Yawn")
			battler.pbSleep
		end
	},
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} became drowsy!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :GorillaTactics,
	:real_name => "GorillaTactics",
	:type => :Move,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BallFetch,
	:real_name => "BallFetch",
	:type => :Item,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :StatsDropped,
	:real_name => "Stats Dropped",
	:resets_eor	=> true,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BurningJealousy,
	:real_name => "Burning Jealousy",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :JawLock,
	:real_name => "Jaw Lock",
	:baton_passed => true,
	:trapping => true,
	:expire_proc => Proc.new { |battle, battler|
		# Disable jaw lock on all other battlers who were locked with this
		battle.eachBattler do |b|
			if b.pointsAt?(:JawLockUser,battler)
				b.disableEffect(:JawLock)
				b.disableEffect(:JawLockUser)
			end
		end
	},
	:sub_effects => [:JawLockUser],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :JawLockUser,
	:real_name => "Jaw Locker",
	:info_displayed => false,
	:type => :Position,
	:baton_passed => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :TarShot,
	:real_name => "Covered In Tar",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Octolock,
	:real_name => "Octolocked",
	:trapping => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} is trapped by the tentacle hold!", battler.pbThis))
	},
	:eor_proc => Proc.new { |battle,battler,value|
		octouser = battle.battlers[battler.effects[:OctolockUser]]
		if battler.pbCanLowerStatStage?(:DEFENSE,octouser,self)
			battler.pbLowerStatStage(:DEFENSE,1,octouser,true,false,true)
		end
		if battler.pbCanLowerStatStage?(:SPECIAL_DEFENSE,octouser,self)
			battler.pbLowerStatStage(:SPECIAL_DEFENSE,1,octouser,true,false,true)
		end
	},
	:sub_effects => [:OctolockUser],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :OctolockUser,
	:real_name => "Octolocked By",
	:type => :Position,
	:others_lose_track => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BlunderPolicy,
	:real_name => "Blunder Policy",
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :SwitchedAlly,
	:real_name => "Switched Ally",
	:type => :Position,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Sentry,
	:real_name => "Sentry",
	:resets_eor	=> true,
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Assist,
	:real_name => "Assisting",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ConfusionChance,
	:real_name => "Confusion Chance",
	:type => :Integer,
	:baton_passed => true,
	:info_displayed => false,
	:active_value_proc => proc { |value|
		return value != 0
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FlinchedAlready,
	:real_name => "Flinch Immune",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Enlightened,
	:real_name => "Ignores Added Effects",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ColdConversion,
	:real_name => "Cold Converted",
	:info_displayed => false,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :CreepOut,
	:real_name => "Weak to Bug",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :LuckyStar,
	:real_name => "Added Crit Chance",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Charm,
	:real_name => "Charm Turns",
	:type => :Integer,
	:baton_passed => true,
	:is_mental => true,
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1} was released from the charm.",battler.pbThis))
	},
	:sub_effects => [:CharmChance],
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :CharmChance,
	:real_name => "Charm Chance",
	:type => :Integer,
	:baton_passed => true,
	:info_displayed => false,
	:active_value_proc => proc { |value|
		return value != 0
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Inured,
	:real_name => "No Weaknesses",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :NoRetreat,
	:real_name => "No Retreat!!",
	:baton_passed => true,
	:trapping => true,
	:apply_proc => Proc.new { |battle,battler,value|
		battle.pbDisplay(_INTL("{1} is committed to the battle! It can't escape!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :NerveBreak,
	:real_name => "Healing Reversed",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FuryCutter,
	:real_name => "Fury Cutter Count",
	:type => :Integer,
	:resets_on_cancel => true,
	:resets_on_move_start => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :IceBall,
	:real_name => "Ice Ball Count",
	:type => :Integer,
	:resets_on_cancel => true,
	:resets_on_move_start => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :RollOut,
	:real_name => "Roll Out Count",
	:type => :Integer,
	:resets_on_cancel => true,
	:resets_on_move_start => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :StunningCurl,
	:real_name => "Stunning Curl",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ExtraTurns,
	:real_name => "Extra Turns",
	:type => :Integer,
	:apply_proc => Proc.new { |battle, battler, value|
		if value == 1
			battle.pbDisplay(_INTL("{1} gained an extra attack!",battler.pbThis))
		else
			battle.pbDisplay(_INTL("{1} gained {2} extra attacks!",battler.pbThis, value))
		end
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredMoonlight,
	:real_name => "Stats Swapped Around",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredEndure,
	:real_name => "Enduring Turns",
	:type => :Integer,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} braced itself!",battler.pbThis))
		battle.pbDisplay(_INTL("It will endure the next #{value} hits which would faint it!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredLaserFocus,
	:real_name => "Laser Focus",
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} concentrated with extreme intensity!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredDestinyBond,
	:real_name => "Empowered Bond",
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("Attacks against {1} will incur half recoil!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :VolleyStance,
	:real_name => "Volley Stance",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :GivingDragonRideTo,
	:real_name => "Carrying",
	:type => :Position,
	:others_lose_track => true,
	:trapping => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :OnDragonRide,
	:real_name => "Riding Dragon",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ShimmeringHeat,
	:real_name => "Shimmering Heat",
	:resets_eor	=> true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :FlareWitch,
	:real_name => "Flare Witch",
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :EmpoweredDetect,
	:real_name => "Halving Damage Turns",
	:type => :Integer,
	:ticks_down => true,
	:apply_proc => Proc.new { |battle, battler, value|
		battle.pbDisplay(_INTL("{1} sees everything!",battler.pbThis))
		battle.pbDisplay(_INTL("It's protected from half of all attack damage for #{value} turns!",battler.pbThis))
	},
	:expire_proc => Proc.new { |battle, battler|
		battle.pbDisplay(_INTL("{1}'s Primeval Detect wore off!",battler.pbThis))
	},
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Echo,
	:real_name => "Echo",
})

#######################################################
# Protection effects
#######################################################

GameData::BattleEffect.register_effect(:Battler,{
	:id => :ProtectRate,
	:real_name => "Protect Rate",
	:type => :Integer,
	:default => 1,
	:info_displayed => false,
	:resets_on_move_start => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Protect,
	:real_name => "Protect",
	:resets_eor	=> true,
	:protection_effect => true,
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :KingsShield,
	:real_name => "King's Shield",
	:resets_eor	=> true,
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			user.pbLowerStatStage(:ATTACK, 1, nil) if move.physicalMove? && user.pbCanLowerStatStage?(:ATTACK)
		}
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :Obstruct,
	:real_name => "Obstruct",
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			user.pbLowerStatStage(:DEFENSE, 2, nil) if move.physical? && user.pbCanLowerStatStage?(:DEFENSE)
		}
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :BanefulBunker,
	:real_name => "Baneful Bunker",
	:resets_eor	=> true,
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			user.pbPoison(target) if move.physicalMove? && user.pbCanPoison?(target, false)
		}
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :RedHotRetreat,
	:real_name => "Red-Hot Retreat",
	:resets_eor	=> true,
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			user.pbBurn(target) if move.specialMove? && user.pbCanBurn?(target, false)
		}
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :SpikyShield,
	:real_name => "Spiky Shield",
	:resets_eor	=> true,
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			if move.physicalMove?
				battle.pbDisplay(_INTL('{1} was hurt!', user.pbThis))
				user.applyFractionalDamage(1.0 / 8.0)
			end
		}
	}
})

GameData::BattleEffect.register_effect(:Battler,{
	:id => :MirrorShield,
	:real_name => "Mirror Shield",
	:resets_eor	=> true,
	:protection_info => {
		:hit_proc => Proc.new { |user, target, move, battle|
			if move.specialMove?
				battle.pbDisplay(_INTL('{1} was hurt!', user.pbThis))
				uuserser.applyFractionalDamage(1.0 / 8.0)
			end
		}
	}
})