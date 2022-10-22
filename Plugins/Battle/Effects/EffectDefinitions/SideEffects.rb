##########################################
# Team combo effects
##########################################
GameData::BattleEffect.register_effect(:Side,{
	:id => :EchoedVoiceCounter,
	:real_name => "Echoed Voice Counter",
	:type => :Integer,
})

GameData::BattleEffect.register_effect(:Side,{
	:id => :EchoedVoiceUsed,
	:real_name => "Echoed Voice Used",
	:resets_eor => true,
})

GameData::BattleEffect.register_effect(:Side,{
	:id => :Round,
	:real_name => "Round Singers",
	:resets_eor => true,
})

##########################################
# Damage reducing effects
##########################################
GameData::BattleEffect.register_effect(:Side,{
	:id => :Reflect,
	:real_name => "Reflect Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle,side,teamName|
		battle.pbDisplay(_INTL("{1}'s Reflect wore off!",teamName))
	}
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :LightScreen,
	:real_name => "Light Screen Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle,side,teamName|
		battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",teamName))
	}
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :AuroraVeil,
	:real_name => "Aurora Veil Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle,side,teamName|
		battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",teamName))
	}
})

##########################################
# Misc. immunity effects
##########################################
GameData::BattleEffect.register_effect(:Side,{
	:id => :LuckyChant,
	:real_name => "Lucky Chant Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle,side,teamName|
		battle.pbDisplay(_INTL("{1}'s is no longer protected by Lucky Chant!",teamName))
	}
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :Mist,
	:real_name => "Mist Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle,side,teamName|
		battle.pbDisplay(_INTL("{1}'s is no longer protected by Mist!",teamName))
	}
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :Safeguard,
	:real_name => "Safeguard Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle,side,teamName|
		battle.pbDisplay(_INTL("{1}'s is no longer protected by Safeguard!",teamName))
	}
})

##########################################
# Temporary full side protecion effects
##########################################
GameData::BattleEffect.register_effect(:Side,{
	:id => :CraftyShield,
	:real_name => "Crafty Shield",
	:resets_eor => true,
	:protection_effect => true,
})

GameData::BattleEffect.register_effect(:Side,{
	:id => :MatBlock,
	:real_name => "Mat Block",
	:resets_eor => true,
	:protection_effect => true,
})

GameData::BattleEffect.register_effect(:Side,{
	:id => :QuickGuard,
	:real_name => "Quick Guard",
	:resets_eor => true,
	:protection_effect => true,
})

GameData::BattleEffect.register_effect(:Side,{
	:id => :WideGuard,
	:real_name => "Wide Guard",
	:resets_eor => true,
	:protection_effect => true,
})

GameData::BattleEffect.register_effect(:Side,{
	:id => :Bulwark,
	:real_name => "Bulwark",
	:resets_eor => true,
	:protection_effect => true,
})

##########################################
# Pledge combo effects
##########################################
GameData::BattleEffect.register_effect(:Side,{
	:id => :Rainbow,
	:real_name => "Rainbow Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle,side,teamName|
		teamName[0] = teamName[0].downcase
		battle.pbDisplay(_INTL("The Rainbow on {1}'s side dissapeared!",teamName))
	}
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :SeaOfFire,
	:real_name => "Sea of Fire Turns",
	:type => :Integer,
	:ticks_down => true,
	:remain_proc => Proc.new { |battle,side,teamName|
		battle.pbCommonAnimation("SeaOfFire") if side.index == 0
		battle.pbCommonAnimation("SeaOfFireOpp") if side.index == 1
		battle.eachBattler.each do |b|
			next if b.opposes?(side.index)
			next if !b.takesIndirectDamage? || b.pbHasType?(:FIRE)
			battle.pbDisplay(_INTL("{1} is hurt by the sea of fire!",b.pbThis))
			b.applyFractionalDamage(1.0/8.0)
		end
	},
	:expire_proc => Proc.new { |battle,side,teamName|
		teamName[0] = teamName[0].downcase
		battle.pbDisplay(_INTL("The Sea of Fire on {1}'s side dissapeared!",teamName))
	}
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :Swamp,
	:real_name => "Swamp Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle,side,teamName|
		teamName[0] = teamName[0].downcase
		battle.pbDisplay(_INTL("The Swamp on {1}'s side dissapeared!",teamName))
	}
})

##########################################
# Hazards
##########################################
GameData::BattleEffect.register_effect(:Side,{
	:id => :Spikes,
	:real_name => "Spikes Count",
	:type => :Integer,
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :PoisonSpikes,
	:real_name => "Poison Spikes Count",
	:type => :Integer,
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :FlameSpikes,
	:real_name => "Flame Spikes Count",
	:type => :Integer,
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :FrostSpikes,
	:real_name => "Frost Spikes Count",
	:type => :Integer,
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :StealthRock,
	:real_name => "Stealth Rock",
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :StickyWeb,
	:real_name => "Sticky Web",
})

##########################################
# Internal Tracking
##########################################
GameData::BattleEffect.register_effect(:Side,{
	:id => :LastRoundFainted,
	:real_name => "Last Round Fainted",
	:info_displayed => false,
})

##########################################
# Other
##########################################
GameData::BattleEffect.register_effect(:Side,{
	:id => :Tailwind,
	:real_name => "Tailwind Turns",
	:type => :Integer,
	:ticks_down => true,
	:expire_proc => Proc.new { |battle,side,teamName|
		battle.pbDisplay(_INTL("{1}'s Tailwind petered out!",teamName))
	}
})
GameData::BattleEffect.register_effect(:Side,{
	:id => :EmpoweredEmbargo,
	:real_name => "Empowered Embargo",
})