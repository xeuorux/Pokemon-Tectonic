MAIN_HASH = {
    "Basic Strategy"    => "How do I win battles?",
    "Moves"             => "What are moves and what are the differences between them?",
    "Type Matchups"     => "When and how are types better or worse against one another?",
    "Acquiring Pokémon"  => "How do I get more Pokémon?",
    "Stats"             => "What are stats, and how do they affect battles?",
    "Abilities"         => "How do abilities work?",
    "Held Items"        => "What are held items and how to use them?",
    "Status Conditions" => "What are the Conditions a Pokémon can be afflicted with?",
    "Trainers"          => "How do enemy Trainers work?",
    "Avatars"           => "What are avatars and what do they do?",
    "PokéDex"           => "What does the PokéDex do and how should I use it?",
    "Weathers"          => "What are weathers, and what does each do?",
}

BASICS_HASH = {
    "Winning Battles" => "You win a battle when all enemy Pokémon faint: reach 0 health points. You lose a battle if that happens to your Pokémon.",
    "Basic Strategy" => "1. Have as many Pokémon as you can. 2. Level up your Pokémon as much as you can. 3. Abuse type matchups. 4. Start battles with healthy Pokémon.",
    "Team Size" => "You can have a maximum of 6 Pokémon with you at any time. This is known as your \"team\". You can store extra Pokémon using the PC in any PokéCenter.",
    "Levels" => "Each Pokémon has a level from 1 to 70. A Pokémon's level determines its stats as well as what moves it could learn. Reaching high enough levels also unlocks Evolution.",
    "Type Matchups" => "Types are strong or weak against other types. Having a variety of different types on your team helps you take advantage of these relationships.",
    "Healing your Pokémon" => "Heal your Pokémon at PokéCenters between battles. You can often use the Aid Kit instead to save on traveling time.",
    "Who goes first?" => "In battle, the Pokémon with the higher speed stat gets to use their move first. Some moves modify this. Speed ties are decided randomly.",
}

MOVE_HASH = {
    "Attacking vs Status" => "Attacking moves deal damage. Status moves do not. Status moves are notated by a Yin/Yang symbol (White and Black intermixing).",
    "Physical vs Special" => "Attacking moves are split into Physical moves, and Special moves. Each of these categories uses different stats to determine how much damage is dealt to the target.",
    "Physical Moves" => "Physical moves are notated by the symbol of a smashing fist. Their damage is based on the Attack (Atk) stat of the attacker and the Defense (Def) stat of the target.",
    "Special Moves" => "Special moves are notated by the symbol of a splash. Their damage is based on the Special Attack (Sp. Atk) of the attacker and the Special Defense (Sp. Def) of the target.",
    "Targeting" => "Most moves target only a single Pokémon, but many can target multiple Pokémon at once. Some moves differ in how far they can target in the bigger battle styles (doubles, triples).",
    "Move Types" => "Every move has a type. Attacking moves deal different amounts of damage to different Pokémon based on those Pokémon's types. This is called \"type effectiveness\".",
    "Same-Type Bonus" => "Pokémon deal 50% more damage with moves the share a type with them. For example, a Raichu deals 50% more damage with an Electric move than a Normal move.",
    "Learning Moves" => "Pokémon learn new moves as they level up. They can also learn moves from the \"Move Tutors\" who sit in the left side of every PokéCenter.",
    "Base Power" => "Moves with higher Base Power deal more damage. Some moves deal variable Base Power depending on the situation. Status moves have no base power.",
    "Accuracy" => "Accuracy is a move's chance of hitting. Most moves have 100% accuracy. Some effects can raise accuracy to let you use low-accuracy moves consistently.",
    "Power Points" => "Power Points, or PP, is a number which limits how many times a move can be used. Healing at a PokéCenter or with the Aid Kit restores PP.",
}

TYPE_MATCHUPS_HASH = {
    "Type Matchups" => "Each Pokémon has type weakness and type resistances based on its own type. eg. Water deals double damage to Fire, and Fire deals half damage to Water.",
    "Type Combinations" => "When a Pokémon has two types, its type weaknesses and resistances multiply. A Pokémon can be double weak or double resistant, or immune even though one of their types is weak.",
    "Normal Effective" => "Normal Effective is the default effectiveness of all moves against a Pokémon.",
    "Super Effective" => "Super Effective moves deal double the damage compared to normal effective moves.",
    "Hyper Effective" => "Hyper Effective moves deal quadruple the damage compared to normal effective moves. This happens when a Pokémon is double weak to a type.",
    "Not Very Effective" => "Not Very Effective moves deal half the damage compared to normal effective moves.",
    "Barely Effective" => "Barely Effective moves deal one quarter the damage compared to normal effective moves. This happens when a Pokémon is double resistant to a type.",
    "Ineffective" => "Ineffective moves deal no damage at all. This can happen if one of a Pokémon's types has an immunity to the attacking move type, even if the other is neutral (or even weak!).",
    "Looking Up Matchups" => "The 5th and 6th pages of a PokéDex entry show that Pokémon's type matchups. Open the PokéDex in battle to check matchups if you're not sure.",
}

ACQUIRING_POKEMON_HASH = {
    "Why Get More?" => "Having choices of Pokémon is important when facing challenges. A team of six is a bare minimum--it's best to catch more and pull them from the PC as needed.",
    "Methods of Aquiring" => "The two main methods of acquiring Pokémon are catching them from the wild, and receiving them from other Trainers through gifts or trades.",
    "Catching Basics" => "Wild Pokémon will attack you if you walk through patches of grass, dark ground in caves, or other wild terrain. You can catch these Pokémon by throwing Poké Balls at them.",
    "Increase Catch Chance pt. 1" => "Catching a Pokémon isn't guaranteed. It's easier to catch Pokémon when their health has been lowered by your attacks, or when they have a status ailment.",
    "Increase Catch Chance pt. 2" => "Every time a Pokémon breaks out of a ball, it'll be slightly easier to catch for the rest of the battle. You can check what your current catch chance is in the Poké Ball menu.",
    "Finding Wild Pokémon" => "Use the DexNav to get information on which Pokémon are available where you are. You can also use it to find more Pokémon of a species that you've already caught one of.",
    "Trades" => "Throughout the world there will be people offering trades for Pokémon. Usually they want a different Pokémon, but sometimes they want money.",
}

STATS_HASH = {
    "What are Stats?" => "Stats, short for Statistics, are the numbers which determine how your Pokémon performs in battle.",
    "Checking Stats" => "Check your Pokémon's stats by looking at the second page of their summary screen, accessible through the Pokémon menu in the pause menu.",
    "Stat Factors" => "Your Pokémon's stats are calculated from a combination of their species' \"Base Stats\", their own \"Style Values\", and extra modifications during battle.",
    "Base Stats" => "Every species of Pokémon have base stats, which affect every Pokémon of that species. e.g. Every Raichu will be fast because the Raichu species has a high Speed base stat.",
    "Style Values" => "Style Values are numbers which you can customize to change your Pokémon's stats (except HP). Style Values show as blue numbers on the stat page of the summary.",
    "Leveling and Evolution" => "Your Pokémon's stats will increase every time they level up. When Pokémon evolve, their stats change (almost always they increase).",
    "Accuracy and Evasion" => "Accuracy and Evasion are two stats which are only active in battle, starting at 100% each. They are only modified by in-battle changing effects.",
    "Stat Stages" => "Effects can modify a Pokémon's stats during battle. These are called \"stat stages\". Stat stages multiply or divide the Pokémon's listed stat value.",
    "Bounds of Stat Stages" => "Stat stages start at 0, and can increase up to +6 (4x) and down to -6 (.25x). Stat stages are reset if you swap the Pokémon out or it faints.",
    "Checking Stat Stages" => "You can check the current stat stages of each Pokémon on the battlefield using the Info button. It lists the numerical stage as well as resultant multiplier.",
}

ABILITIES_HASH = {
    "What are abilities?" => "Abilities are special powers that Pokémon can have based on their species. Most Pokémon can have one of 2 possible abilities.",
    "Ability Effects" => "Abilities do a wide variety of different things. Understanding your team's abilities, and choosing the right ones, is important to winning.",
    "Checking Abilities" => "Check your Pokémon's summary to see what ability they have. Use the PokéDex to read about the abilities of enemy Pokémon during battle.",
    "Choosing Abilities" => "A Pokémon's ability is one of the two its species can have, randomly chosen when you get it. You can use Ability Capsules to swap to the other.",
    "Conditional Abilities" => "Many abilities only do things under certain circumstances. Buiding around Weather and Terrain-synergy abilities is a common strategy.",
    "Effect Of Evolution" => "A Pokémon's ability tends to stay the same when evolving, but can change. When this happens, the game will alert you.",
    "Defeating Abilities" => "An enemy Trainer's ability too much? Abilities like Neutralizing Gas, and moves like Gastro Acid, can suppress abilities in battle.",
    "Swapping Abilities" => "Moves like Skill Swap can be used to give a new ability to Pokémon during battle, enabling unique and creative team synergies.",
}

HELD_ITEMS_HASH = {
    "What are Held Items?" => "Held items are items which you can give your Pokémon to benefit them during battle. They can increase their damage, heal them, or other things.",
    "Equipping an item" => "You can give a Pokémon an item from your bag, or through the summary screen. Not all items do an effect when held, so read carefully.",
    "Berries" => "Berries are a common held item. During battles, Pokémon will eat the berry to get a benefit. Get berries by picking from Berry Trees.",
    "Sitrus and Oran Berry" => "Sitrus Berry and Oran Berry are common berries which heal your Pokémon when at low health. If in doubt about what item to give, give them one of these.",
    "Rematerializer" => "In Project Chasm, the rematerializer regenerates held items which are consumed in battle. You'll never run out of berries!",
    "Wild Held Items" => "Wild Pokémon can be found holding items. These items sometimes have held effects, but often don't.",
    "Getting More" => "You will find more held items on the ground when traveling, or as gifts from people, or as the reward for defeating Avatars, or as purchasable items in shops.",
}

STATUS_CONDITIONS_HASH = {
    "What are Status Conditions?" => "Status Conditions are ailments a Pokémon can have which hurt or restrict them. They remain after swapping out, and even between battles.",
    "Healing Status Conditions" => "Status Conditions are removed when you heal at the PokéCenter or when you use the Aid Kit.",
    "Status Immunity" => "Type immunities do not prevent status moves. However, some types give immunities to certain status conditions. Don't confuse these two!",
    "Burn" => "When burned, a Pokémon's Attack is reduced by 33%, and loses 1/8th HP every turn. Fire- and Ghost-types do the most burning. Fire is immune.",
    "Frostbite" => "When frostbitten, a Pokémon's Sp. Atk is reduced by 33%, and loses 1/8th HP every turn. Ice- and Flying-types do the most frostbiting. Ice is immune.",
    "Poison" => "When poisoned, a Pokémon loses 1/8th HP every turn--doubling every 3 turns until swapped. Poison- and Grass-types do the most poisoning. Poison/Steel are immune.",
    "Numb" => "When numbed, a Pokémon's Speed is halved, and it deals 25% less damage. Electric- and Fighting-types do the most numbing. Electric is immune.",
    "Dizzy" => "When dizzied, a Pokemon takes 25% more attack damage, and its ability doesn't function. Psychic- and Fairy-types do the most dizzying. Psychic is immune.",
    "Leeched" => "When leeched, it loses 1/8th HP every turn, and each opponent gains that health. Bug- and Dark-types do the most dizzying. Grass is immune.",
    "Sleep" => "A rarer status that causes a Pokémon to be unable to do anything for 3 turns. Psychic- and Grass-types put Pokémon to sleep the most often.",
}

TRAINERS_HASH = {
    "What are Enemy Trainers?" => "Enemy Trainers are the Pokémon Trainers you will battle throughout the game. Some block your path forwards (like Gym Leaders), others are optional.",
    "Detecting Trainers" => "Trainers are people who have a companion Pokémon next to them. If a person doesn't have that, they either aren't a Trainer, or are an inactive one.",
    "Avoiding Trainers" => "Trainers will challenge you if they see you within 4 tiles of them. Avoid them by going out of that distance, sneaking around them, or waiting until they move.",
    "Trainer Inactivity" => "When you defeat a Trainer, they will become inactive until the next time you heal at a PokéCenter. This is indicated by them returning their companion Pokémon to its Poké Ball.",
    "Perfecting Fights" => "If you defeat a Trainer without any of your Pokémon fainting, you've \"perfected\" the fight. They will leave forever and drop experience candy as a reward.",
    "Enemy Teams" => "Enemy Trainers have their own teams of Pokémon with their own moves and held items. Its important to pay attention to these possibilities to win battles.",
    "Differences" => "The typical trainer has 3 Pokémon, but Gym Leaders will have more. Trainers with more Pokémon also have more move variety and more items on their Pokémon.",
    "Cool Trainers" => "Cool Trainers are special Trainers, noted by their grey hair and black clothes. Their teams are always 6 Pokémon, with a wide variety of moves, all with items. They're hard!",
    "Trainer Behaviour" => "Individual Trainers will always react to the same in-battle circumstances the same way. You can learn how to beat or even perfect a Trainer through trial and error.",
}

AVATARS_HASH = {
    "What are Avatars?" => "Avatars are powerful enemy Pokémon with unique properties that you will fight and destroy during your adventure. They cannot be caught.",
    "Avatars are Healthy" => "Avatars have two health bars, which means they have a lot of health. Usually more than double the normal amount!",
    "Multi-Attack" => "Avatars can attack multiple times each turn. Usually they attack twice, but some can attack three or even more times.",
    "Two Statuses" => "Avatars are large, and have room for up to two status Conditions at a time. However, they are affected less than normal Pokémon.",
    "HP-Based Effects" => "Effects that damage based on a fraction of total HP are only one-fourth as powerful against avatars, compared to normal Pokémon.",
    "Stat-Modifying" => "Avatars are only half as affected by in-battle stat stage changes. For example, their attack is only given a 25% increase from a +1 boost.",
    "Primeval Moves" => "When about half damaged, most avatars will use their one Primeval Move! Primeval Moves are powered up versions of other moves, which also change the Avatars type.",
    "Attack Choice" => "Avatars usually only have a few moves to choose from. They usually alternate between their moves on successive attacks.",
    "Target Choice" => "Avatars usually attack your healthiest Pokémon. However, they avoid attacking Pokémon that they've noticed are invulnerable by moves like Protect.",
    "Experience Reward" => "When an Avatar is destroyed, every Pokémon on your team is given experience, even those that are fainted.",
    "Legendary Avatars" => "Legendary Avatars are unique. You fight them with 3 Pokémon, they have 3 HP bars, and they have more moves with more smarts about how to use them.",
}

POKEDEX_HASH = {
    "What is the PokéDex?" => "The PokéDex is an advanced encyclopedia about the 900+ Pokémon available in this game.",
    "Single PokéDex" => "Access the PokéDex entry of a single Pokémon when looking at a Pokémon in the summary or the PC, or by using the Dex button in battles.",
    "Full Pokdex" => "Access the full PokéDex from your pause menu, or by pressing D when using the Dex button in battles (while its waiting for you to select a battler).",
    "Searching" => "When in the PokéDex, you can press your Special keybind (default Shift or Z) to open the first search page. There's dozens of searches to experiment with!",
    "Combining Searches" => "You can begin a search while you're already looking at the results of a search. This will narrow down from what you were already looking at.",
    "Storing Searches" => "When you press the cancel button while looking at a search, it will ask you if you'd like to cancel the search, or store it for the next time you open the PokéDex.",
    "Quick Navigation" => "Press A to go up a page at a time, or S to go down a page. Use the number keys (1-9) to quickly go to one of the tab's of a Pokémon's PokéDex entry.",
    "Move Details" => "Press the Use key (defaults to C) on the level up learnset or tutor moves tabs to begin scrolling the lists, and viewing details about individual moves.",
    "Checking Evolutions" => "Press the Use key (defaults to C) on the evolutions tab to choose a Pokémon in the same evolutionary tree, and to warp to that Pokémon's PokéDex entry.",
}

WEATHERS_HASH = {
    "What are weathers?" => "Weathers are special states that effect the entire battlefield and help or hinder the Pokémon battling. Only one weather can be active at once.",
    "Weather Duration" => "Weathers last a certain number of turns. The length differs depending on what move or ability summoned the weather. The duration can be extended by certain items.",
    "Sun" => "Sun lowers attack damage by 15% and prevents attacks from critting. Fire and Grass-type moves/Pokémon are immune to this. Fire-type attacks are boosted by 30%.",
    "Rain" => "Rain lowers attack damage by 15% and makes added effects half as likely. Water and Electric-type moves/Pokémon are immune to this. Water-type attacks are boosted by 30%.",
    "Sandstorm" => "Sandstorm deals damage to all Pokémon at the end of each turn. Rock, Ground, and Steel-types are immune to this. Additionally, Rock-types get +50% Special Defense.",
    "Hail" => "Hail deals damage to all Pokémon at the end of each turn. Ice, Ghost, and Steel-types are immune to this. Additionally, Ice-types get +50% Defense.",
    "Weather Areas" => "Certain areas in the game experience intense weather. That weather will also be present in the battles of that area. Simple daily weather will not do this.",
    "Weather Synergies" => "Each weather has dozens of moves and abilities that benefit from that weather. Pokémon using these moves/abilities ignore the downsides of their favored weather!",
}