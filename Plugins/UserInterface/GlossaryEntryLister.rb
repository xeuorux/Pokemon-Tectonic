MAIN_GLOSSARY_HASH = {
    "Moves" => "What are moves and how do they work?"
}

MOVE_GLOSSARY_HASH = {
    "Physical vs Special" => "asjdbasjod"
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