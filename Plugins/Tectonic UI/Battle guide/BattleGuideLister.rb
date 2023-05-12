class BattleGuideLister
    attr_reader :guideHash

    def initialize(hash, startingIndex = 0)
        @pkmnList = Window_UnformattedTextPokemon.newWithSize("",
          Graphics.width / 2, 64, Graphics.width / 2, Graphics.height - 64)
        @pkmnList.z = 3
        @selection = @index = startingIndex
        @guideHash = hash
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
        @commands = @guideHash.keys
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
        text = @guideHash[@commands[index]]
        @pkmnList.text = text
    end
end