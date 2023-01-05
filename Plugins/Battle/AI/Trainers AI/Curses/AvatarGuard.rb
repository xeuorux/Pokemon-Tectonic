PokeBattle_Battle::BattleStartApplyCurse.add(:CURSE_AVATAR_GUARD,
    proc { |curse_policy, battle, curses_array|
        battle.amuletActivates("Avatar Guard")
        battle.pbDisplaySlower(_INTL("An Avatar has been inserted into Yezera's party!"))

        # Insert the avatar
        newPokemon = battle.generateAvatarPokemon(:LINOONE,65)
        partyIndex = battle.pbParty(1).length
        battle.pbParty(1)[partyIndex] = newPokemon

        curses_array.push(curse_policy)
        next curses_array
    }
)


def testYezera5
    setBattleRule("double")
    cursedBattle(:POKEMONTRAINER_Yezera,"Yezera",8)
end