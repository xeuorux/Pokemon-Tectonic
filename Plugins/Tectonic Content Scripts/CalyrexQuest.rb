CALYREX_QUEST_GLOBAL_VAR = 42

def happinessCheckerCorviknight
    showExclamation
    pbWait(60)
    showQuestion
    pbWait(60)

    pbMessage(_INTL("The Corviknight stares at you intently."))

    count = getMaxHappinessCount

    count.times do |i|
        showLove
        pbWait(40)
    end

    if count == 6
        pbWait(40)
        showExclamation
        pbWait(40)
        return true
    else
        pbWait(20)
        showSad
        pbWait(40)
        pbMessage(_INTL("You get the sense that you've failed some sort of test."))
        return false
    end
end

def getMaxHappinessCount
    count = 0
    $Trainer.pokemon_party.each do |partyMember|
        next unless partyMember.happiness = MAX_HAPPINESS
        count += 1
    end
    return count
end

def checkForCalyrexQuestFinale
    return unless $Trainer.owned?(:SPECTRIER)
    return unless $Trainer.owned?(:GLASTRIER)
    return unless pbHasItem?(:REINSOFUNITY)
    incrementGlobalVar(CALYREX_QUEST_GLOBAL_VAR)
end

def calyrexLegendFight
    level = [70,getLevelCap].min

    pkmn = pbGenerateWildPokemon(:CALYREX, level)
    pkmn.forget_all_moves
    pkmn.learn_move(:FUTURESIGHT)
    pkmn.learn_move(:SEERSTRIKE)
    pkmn.learn_move(:AROMATHERAPY)
    pkmn.learn_move(:ENERGYBALL)

    pkmn.Trait1 = _INTL("Green-thumbed")
    pkmn.Trait2 = _INTL("Savior")
    pkmn.Trait3 = _INTL("Scornful")
    pkmn.Like = _INTL("Grand Design")
    pkmn.Dislike = _INTL("Treason")
    pkmn.happiness = MAX_HAPPINESS

    result = pbWildBattleCore(pkmn)
    if result == 4 # Caught
        get_self.opacity = 0
        return true
    elsif result == 1
        setSpeaker(CALYREX)
        pbMessage(_INTL("<i>Drink the regal blood if you must.</i>"))
        pbMessage(_INTL("<i>Indulge in your <b>traitorous nature</b> if you insist.</i>"))
        pbMessage(_INTL("<i>Repulsive flea...</i>"))
        pbMessage(_INTL("<i><b>I will swat you from the sky.</b></i>"))
        return false
    else
        setSpeaker(CALYREX)
        pbMessage(_INTL("<i>Let this act as a lesson in humility, worm!</i>"))
        return false
    end
end

BallHandlers::OnPokemonCaught += proc { |ball, battle, pkmn|
    next unless pkmn.species == :CALYREX
    next unless $game_map.map_id == 444 # crown chamber

    setSpeaker(CALYREX)
    battle.pbDisplayWithFormatting(_INTL("<i>What!!?</i>"))
    battle.pbDisplayWithFormatting(_INTL("<i>How... how could you?</i>"))
    if ball == :RADIANTBALL
        battle.pbDisplayWithFormatting(_INTL("<i>To think!! My gift to the world, in the hands of the <b>undeserving</b>!</i>"))
    end
    battle.pbDisplayWithFormatting(_INTL("<i>Insolent fool! Treasonous wretch!!!  Usurping the King of All in your desperate attemp–</i>"))
    pbWait(40)
    removeSpeaker
    battle.pbDisplayWithFormatting(_INTL("Calyrex's protests fade away, leaving an echoing silence in its absence."))
}