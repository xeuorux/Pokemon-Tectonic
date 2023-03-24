BattleHandlers::CertainSwitchingUserAbility.add(:SLICKSURFACE,
    proc { |_ability, switcher, battle, trappingProc|
        if trappingProc
            battle.pbShowAbilitySplash(switcher)
            battle.pbDisplay(_INTL("#{switcher.pbThis} can switch out regardless!"))
            battle.pbHideAbilitySplash(switcher)
        end
        next true
    }
)

BattleHandlers::CertainSwitchingUserAbility.copy(:SLICKSURFACE, :JUGGERNAUT)