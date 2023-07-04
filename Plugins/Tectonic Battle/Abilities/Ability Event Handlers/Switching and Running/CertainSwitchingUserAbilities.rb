BattleHandlers::CertainSwitchingUserAbility.add(:SLICKSURFACE,
    proc { |ability, switcher, battle, trappingProc|
        if trappingProc
            battle.pbShowAbilitySplash(switcher, ability)
            battle.pbDisplay(_INTL("#{switcher.pbThis} can switch out regardless!"))
            battle.pbHideAbilitySplash(switcher)
        end
        next true
    }
)