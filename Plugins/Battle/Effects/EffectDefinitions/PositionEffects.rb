GameData::BattleEffect.register_effect(:Position,{
	:id => :FutureSightCounter,
	:real_name => "FutureSightCounter",
    :connected_effects => [:FutureSightMove, :FutureSightUserPartyIndex, :FutureSightUserIndex]
})
GameData::BattleEffect.register_effect(:Position,{
	:id => :FutureSightMove,
	:real_name => "FutureSightMove",
    :connected_effects => [:FutureSightUserIndex, :FutureSightCounter, :FutureSightUserPartyIndex]
})
GameData::BattleEffect.register_effect(:Position,{
	:id => :FutureSightUserIndex,
	:real_name => "FutureSightUserIndex",
    :connected_effects => [:FutureSightMove, :FutureSightCounter, :FutureSightUserPartyIndex]
})
GameData::BattleEffect.register_effect(:Position,{
	:id => :FutureSightUserPartyIndex,
	:real_name => "FutureSightUserPartyIndex",
    :connected_effects => [:FutureSightMove, :FutureSightCounter, :FutureSightUserIndex]
})

HealingWish               = 4
LunarDance                = 5
Wish                      = 6
WishAmount                = 7
WishMaker                 = 8
Refuge                    = 9
RefugeMaker               = 10