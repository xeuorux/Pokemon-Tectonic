def legendaryFight(species, level, switch = 'A', form = 0)
    Pokemon.play_cry(species)
    level = [level,getLevelCap].min
    if pbWildBattleCore(species, level) == 4
        fadeSwitchOn(switch)
    else
        speciesName = GameData::Species.get(species).real_name
        pbMessage(_INTL("#{speciesName} stands strong, still ready to fight!"))
    end
end