PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_AVATAR_GUARD,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates(
            _INTL("Escorted by, Enthroned upon, Ensconced within this Empty Eminence"),
            _INTL("An Avatar has been inserted into Yezera's party!")
        )

        # Insert the avatar
        newPokemon = generateAvatarPokemon(:LINOONE,65)
        partyIndex = battle.pbParty(1).length
        battle.pbParty(1)[partyIndex] = newPokemon

        curses_array.push(curse_policy)
        next curses_array
    }
)