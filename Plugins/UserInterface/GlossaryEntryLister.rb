MAIN_GLOSSARY_HASH = {
    "Basic Strategy" => "How do I win battles?",
    "Moves" => "What are moves and what are the differences between them?",
    "Type Matchups" => "When and how are types better or worse against one another?",
    "Aquiring Pokemon" => "How do I get more Pokemon?",
    "Stats" => "What are stats, and how do they effect battles?",
    "Abilities" => "How do abilities work?",
    "Held Items" => "What are held items and how to use them?",
    "Trainers" => "How do enemy trainers work?",
    "Avatars" => "What are avatars and what do they do?",
    "Pokedex" => "How does the PokeDex work and how should I use it?",
    "Advanced Team Building" => "How do I build extremely efficient teams?",
}

BASICS_GLOSSARY_HASH = {
    "Winning Battles" => "You win a battle when all enemy Pokemon faint: reach 0 health points. You lose a battle if that happens to your Pokemon.",
    "Basic Strategy" => "1. Have as many Pokemon as you can. 2. Level up your Pokemon as much as you can. 3. Abuse type matchups. 4. Start battles with healthy Pokemon.",
    "Team Size" => "You can have a maximum of 6 Pokemon with you at any time. This is known as your \"team\". You can store extra Pokemon using the PC in any PokeCenter.",
    "Levels" => "Each Pokemon has a level from 1 to 100. A Pokemon's level determines its stats as well as what moves it could learn. Reaching high enough levels also unlocks Evolution.",
    "Type Matchups" => "Types are strong or weak vs other types. Having a variety of different types on your team helps you make sure you can take advantage of this.",
    "Healing your Pokemon" => "Heal your Pokemon at PokeCenters between battles. You can often use the Aid Kit instead to save on traveling time.",
}

MOVE_GLOSSARY_HASH = {
    "Attacking vs Status" => "Attacking moves deal damage. Status moves do not. Status moves are notated by a Yin/Yang symbol (White and Black intermixing).",
    "Physical vs Special" => "Attacking moves are split into Physical moves, and Special moves. Each of these categories uses different stats to determine how much damage is dealt to the target.",
    "Physical Moves" => "Physical moves are notated by the symbol of a smashing fist. Their damage is based on the Attack (Atk) stat of the attacker and the Defense (Def) stat of the target.",
    "Special Moves" => "Special moves are notated by the symbol of a splash in water. Their is based on the Special Attack (Sp. Atk) of the attacker and the Special Defense (Sp. Def) of the target.",
    "Targeting" => "Most moves target only a single Pokemon, but many can target multiple Pokemon at once. Some moves differ in how far they can target in the bigger battle styles (doubles, triples).",
    "Move Types" => "Every move has a type. Attacking moves deal different amounts of damage to different Pokemon based on those Pokemon's types. This is called \"type effectiveness\".",
    "Learning Moves" => "Pokemon learn new moves as they level up. They can also learn moves from the \"Move Tutors\" who sit in the left side of every PokeCenter.",
}

TYPE_MATCHUPS_GLOSSARY_HASH = {
    "Type Matchups" => "Each Pokemon has type weakness and type resiliancies based on its own type. eg. Water deals double damage to Fire, and Fire deals half damage to Water.",
    "Type Combinations" => "When a Pokemon has two types, its type weaknesses and resiliances multiply. A Pokemon can be double weak or double resistant, or immune even though one of their types is weak.",
    "Normal Effective" => "Normal Effective is the default effectiveness of all moves against a Pokemon.",
    "Super Effective" => "Super Effective moves deal double the damage compared to normal effective moves.",
    "Hyper Effective" => "Hyper Effective moves deal quadruple the damage compared to normal effective moves. This happens when a Pokemon is double weak to a type.",
    "Not Very Effective" => "Not Very Effective moves deal half the damage compared to normal effective moves.",
    "Barely Effective" => "Barely Effective moves deal one quarter the damage compared to normal effective moves. This happens when a Pokemon is double resistant to a type.",
    "Ineffective" => "Ineffective moves deal no damage at all. This can happen if one of a Pokemon's types has an immunity to the attacking move type, even if the other is neutral (or even weak!).",
}

AQUIRING_POKEMON_HASH = {
    "Why Get More?" => "Having choices of Pokemon is important when facing challenges. A team of six is a bare minimum--it's best to catch more and pull them from the PC as needed.",
    "Methods of Aquiring" => "The two main methods of aquiring Pokemon are catching them from the wild, and receiving them from other trainers through gifts or trades.",
    "Catching Basics" => "Wild Pokemon will attack you if you walk through patches of grass, dark ground in caves, or other wild terrain. You can catch these Pokemon by throwing PokeBalls at them.",
    "Increase Catch Chance pt. 1" => "Catching a Pokemon isn't guarenteed. It's easier to catch Pokemon when their health has been lowered by your attacks, or when they have a status ailment.",
    "Increase Catch Chance pt. 2" => "Every time a Pokemon breaks out of a ball, it'll be slightly easier to catch for the rest of the battle. You can check what your current catch chance is in the PokeBall menu.",
    "Finding Wild Pokemon" => "Use the DexNav to get information on which Pokemon are available where you are. You can also use it to find more Pokemon of a species that you've already caught one of.",
    "Trades" => "Throughout the world there will be people offering trades for Pokemon. Usually they want a different Pokemon, but sometimes they want money.",
}

STATS_HASH = {
    "What are Stats?" => "Stats, short for Statistics, are the numbers which determine much of how your Pokemon performs in battle.",
    "Checking Stats" => "Check your Pokemon's stats by looking at the second page of their summary screen, accessible through the Pokemon menu in the pause menu.",
    "Stat Factors" => "Your Pokemon's stats are calculated from a combination of their species' \"Base Stats\", their own \"Style Values\", and extra modifications during battle.",
    "Base Stats" => "Every species of Pokemon have base stats, which affect every Pokemon of that species. e.g. Every Raichu will be fast because the Raichu species has a high Speed base stat.",
    "Style Values" => "Style Values are numbers which you can customize to change your Pokemon's stats (except HP). Style Values show as blue numbers on the stat page of the summary.",
    "Leveling and Evolution" => "Your Pokemon's stats will go up every time they level up. When Pokemon evolve, their stats change, almost always going up.",
    "Accuracy and Evasion" => "Accuracy and Evasion are two stats which are only active in battle, starting at 100% each. They are only modified by in-battle changing effects.",
    "Stat Stages" => "Effects can modify a Pokemon's stats during battle. These are called \"stat stages\". Stat stages multiply or divide the Pokemon's listed stat value.",
    "Bounds of Stat Stages" => "Stat stages start at 0, and can increase up to +6 (4x) and down to -6 (.25x). Stat stages are reset when a Pokemon faints or is swapped out.",
}

ABILITIES_HASH = {
    "What are abilities?" => "Abilities are special powers that Pokemon can have based on their species. Most Pokemon can have one of 2 possible abilities.",
    "Choosing Abilities" => "When you find or receive a Pokemon, it is random which ability it has of the two. You can use Ability Capsules to swap to the other.",
    "Ability Effects" => "Abilities do a very wide variety of things. Using the PokeDex to read about an ability is the main way to know it does.",
    "Conditional Abilities" => "Many abilities only perform their effects under certain contexts. Buiding around Weather and Terrain-synergy abilities is a common strategy.",
    "Effect Of Evolution" => "A Pokemon's ability tends to stay the same when evolving, but can change. When this happens, the game will alert you.",
    "Defeating Abilities" => "An enemy trainer's ability too much? Abilities like Neutralizing Gas, and moves like Gastro Acid, can supress abilities in battle.",
    "Swapping Abilities" => "Moves like Skill Swap can be used to give a new ability to Pokemon during battle, enabling unique and creative team synergies.",
}

HELD_ITEMS_HASH = {
    "What are Held Items?" => "Held items are items which you can give your Pokemon to benefit them during battle. They can increase their damage, heal them, or other things.",
    "Equipping an item" => "You can give a Pokemon an item from that item's entry in your bag, or through that Pokemon in the summary screen. Not all items do an effect when held, so read carefully.",
    "Berries" => "Berries are a common category of held item. On some condition, your Pokemon will eat the berry and get a benefit. Berries can be found by interacting with berry trees.",
    "Sitrus and Oran" => "Sitrus Berry and Oran Berry are common berries which heal your Pokemon when at low health. If in doubt about what item to give, give them one of these.",
    "Rematerializer" => "In Project Chasm, the rematerializer item gives you back items which are consumed during battles. You'll never run out of berries to use!",
    "Wild Held Items" => "Wild Pokemon can be found holding items. These items sometimes have held effects, but often are other items they just so happen to hold.",
    "Getting More" => "You will find more held items on the ground when traveling, or as gifts from people, or as the reward for defeating Avatars, or as purchasable items in shops.",
}

ENEMY_TRAINERS_HASH = {
    "What are Enemy Trainers?" => "Enemy trainers are the Pokemon trainers you will battle throughout the game. Some block your path forwards (like Gym Leaders), others are optional.",
    "Detecting Trainers" => "Trainers are people who have the first Pokemon of their team out with them. If a person doesn't have that, they either aren't a trainer, or are an inactive one.",
    "Trainer Inactivity" => "When you defeat a Trainer, they will become inactive until the next time you heal at a PokeCenter. This is indicated by them pulling their companion Pokemon back into its ball.",
    "Perfecting Fights" => "If you defeat a Trainer without any of your Pokemon fainting, you've \"perfected\" the fight. They will leave forever and drop experience candy as a reward.",
    "Enemy Teams" => "Enemy Trainers have their own teams of Pokemon with their own moves and held items. Its important to pay attention to these possibilities to win battles.",
    "Differences" => "The typical trainer has 3 Pokemon, but Gym Leaders will have more. Trainers with more Pokemon also have more move variety and more items on their Pokemon.",
    "Cool Trainers" => "Cool Trainers are special trainers, noted by their grey hair and black clothes. Their teams are always 6 Pokemon, with a wide variety of moves, all with items. They're hard!",
    "Trainer Behaviour" => "Individual trainers will always react to the same in-battle circumstances the same way. You can learn how to beat or even perfect a trainer through trial and error.",
}

AVATARS_HASH = {

}

class GlossaryEntryList
    attr_reader :glossaryHash

    def initialize(hash, startingIndex = 0)
        @pkmnList = Window_UnformattedTextPokemon.newWithSize("",
          Graphics.width / 2, 64, Graphics.width / 2, Graphics.height - 64)
        @pkmnList.z = 3
        @selection = @index = startingIndex
        @glossaryHash = hash
        @commands = []
        @ids = []
      end
    
    def dispose
        @pkmnList.dispose
    end
    
    def setViewport(viewport)
        @pkmnList.viewport = viewport
    end
    
    def startIndex
        return @index
    end
    
    def commands
        @commands = @glossaryHash.keys

        @index = @selection
        @index = @commands.length - 1 if @index >= @commands.length
        @index = 0 if @index < 0
        return @commands
    end
    
    def value(index)
        return nil if index < 0
        return @commands[index]
    end
    
    def refresh(index)
        return if index < 0
        text = @glossaryHash[@commands[index]]
        @pkmnList.text = text
    end
end