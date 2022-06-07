MAIN_GLOSSARY_HASH = {
    "Basic Battle Mechanics" => "How do battles work?",
    "Moves" => "What are moves and what are the differences between them?",
    "Stats" => "What are stats, and how do they effect battles?",
    "Abilities" => "How do abilities work?",
    "Held Items" => "What are held items and how to use them?",
    "Trainers" => "How do enemy trainers work?",
    "Avatars" => "What are avatars and what do they do?",
}

BASICS_GLOSSARY_HASH
{
    "Taking Turns" = "",
}

MOVE_GLOSSARY_HASH = {
    "Attacking vs Status" => "Attacking moves deal damage. Status moves do not. Status moves are notated by a Yin/Yang symbol.",
    "Physical vs Special" => "Attacking moves are split into Physical moves, and Special moves. Each of these categories uses different stats to determine how much damage is dealt to the target.",
    "Physical Moves" => "Physical moves are notated by the symbol of a smashing fist. Theyir damage is based on the Attack (Atk) stat of the attacker and the Defense (Def) stat of the target.",
    "Special Moves" => "Special moves are notated by the symbol of a splash in water. Their is based on the Special Attack (Sp. Atk) of the attacker and the Special Defense (Sp. Def) of the target.",
    "Targeting" => "Most moves target only a single Pokemon, but many can target multiple Pokemon at once. Some moves differ in how far they can target in the bigger battle styles (doubles, triples).",
}

class GlossaryEntryList
    attr_reader :glossaryHash

    def initialize(hash)
        @pkmnList = Window_UnformattedTextPokemon.newWithSize("",
          Graphics.width / 2, 64, Graphics.width / 2, Graphics.height - 64)
        @pkmnList.z = 3
        @selection = 0
        @glossaryHash = hash
        @commands = []
        @ids = []
        @index = 0
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