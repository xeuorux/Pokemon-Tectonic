def grindRivalBattle(id = 0)
    pbTrainerBattle(:CHALLENGER_Vanya,"Vanya",nil,false,id)
end

def randomGrindRivalIntro
    pbMessage([
        _INTL("Think you can handle whatever strategy I'm hiding?"),
        _INTL("Ah, my dear friend \\PN, care for another battle?"),
        _INTL("Hey there, \\PN! How about a friendly Pokémon showdown?"),
        _INTL("The time has come for us to engage in yet another thrilling battle!"),
        _INTL("Greetings, esteemed champion! Fancy a clash of Pokémon prowess?"),
        _INTL("\\PN, my rival, I humbly request your presence on the battlefield."),
        _INTL("The stage is set, and my new team is eager to take you by surprise. Shall we battle?"),
        _INTL("\\PN, the champion of Maya, a challenger awaits you. Will you accept?"),
        _INTL("The thrill of surprise is imminent!"),
        _INTL("Hark! Brace yourself for a battle of wonder, where victory is uncertain!"),
        _INTL("Well, well, well! Fancy a sparring session, with a dash of unpredictability?"),
        _INTL("Hey, you! Up for a surprise Pokemon battle? Or are you too scared?"),
        _INTL("Champion, huh? You got the to face my surprises?"),
        _INTL("Get ready to unravel the enigma of my team. Will it be a treat or a trick?"),
        _INTL("Warning! Battling me may cause trembling, excessive sweating, and a memorable defeat."),
    ].sample)
end

def randomGrindRivalPerfectLine
    pbMessage([
        _INTL("No point in saying much. I've come to expect this sort of performance from you."),
        _INTL("Haha, you got me this time! But I'll be back with a vengeance!"),
        _INTL("You've mastered the art of surprise attacks! I bow down to your wacky brilliance."),
        _INTL("My perfectionism failed me. But if I can just perfect my perfectionism..."),
        _INTL("Utterly defeated... I'm at a loss for words. I'll need to find some new inspiration."),
        _INTL("\PN, you really knows how to bring out my weaknesses."),
        _INTL("Defeated, but at least I can pursue my dream of becoming a professional pillow fighter."),
        _INTL("My Pokémon must have been practicing their synchronized failing."),
        _INTL("I'll try to laugh about that loss. It's the best medicine, right?"),
        _INTL("Well, at least I'll be known for being a unique individual."),
        _INTL("I must confess, you're like a puzzle I just can't solve. Kudos for the mind games!"),
        _INTL("Ouch! That defeat hit harder than a Hyper Beam."),
        _INTL("Defeat stings like a Poison Jab to the heart. Time to reevaluate my strategy and lick my wounds."),
        _INTL("You've shown me the true meaning of humiliation. Frankly, it does stink."),
        _INTL(".....dang."),
        _INTL("Sometimes I regret deciding to never use held items."),
    ].sample)
end

def randomGrindRivalDefeatLine
    pbMessage([
        _INTL("The surprise play must have worked, since I took some of yours down with me!"),
        _INTL("Oh, well, my perfect plan went awry. Time to recalculate."),
        _INTL("Defeat? No worries, I'll just add it to my collection of almost-perfect victories!"),
        _INTL("Bravo! Your team concoction was like a spicy curry that set my taste buds on fire."),
        _INTL("\\PN, your battles are a roller coaster of emotions."),
        _INTL("Sometimes even the best fall short. I'll dust myself off and try again!"),
        _INTL("Looks like you're still a worthy rival!"),
        _INTL("Well, that was a close call! My heart was pounding with each move."),
        _INTL("I gave it my all, but luck wasn't on my side. At least I'm gonna blame that one on luck."),
        _INTL("A loss? How unexpected! It's not like I meticulously planned for this scenario."),
        _INTL("Well, at least I lost in style."),
        _INTL("Hats off to you, my friend. You battled like a true Pokemon virtuoso."),
        _INTL("Bravo! Your battle strategy was truly a work of art."),
        _INTL("Ah, my dear Pokémon, we were so close to achieving flawless victory. Alas..."),
        _INTL("Congratulations, \\PN! You've proven that even the best can be outshone... temporarily."),
        _INTL("Oh, look! A defeat. Just what I needed to keep my ego in check. Thanks for that, \\PN."),
    ].sample)
end

GRIND_RIVAL_RANDOM_TRAINER_CLASS = :POKEMONMASTER_Vanya

def grindRivalRandomBattle
    allGrindRivalRandoms = []
    GameData::Trainer.each do |trainerData|
        next unless trainerData.trainer_type == GRIND_RIVAL_RANDOM_TRAINER_CLASS
        allGrindRivalRandoms.push(trainerData.version)
    end
    pbTrainerBattle(GRIND_RIVAL_RANDOM_TRAINER_CLASS,"Vanya", nil, false, allGrindRivalRandoms.sample)
end