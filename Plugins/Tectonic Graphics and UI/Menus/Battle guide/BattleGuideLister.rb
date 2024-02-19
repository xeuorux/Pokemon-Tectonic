class BattleGuideLister
    attr_reader :guideHash

    def initialize(hash, startingIndex = 0)
        @explanationWindow = Window_AdvancedTextPokemon.newWithSize("",
          Graphics.width / 2, 0, Graphics.width / 2, Graphics.height)
        @explanationWindow.z = 3
        @selection = @index = startingIndex
        @guideHash = hash
        @commands = []
        @ids = []
    end
    
    def dispose
        @explanationWindow.dispose
    end
    
    def setViewport(viewport)
        @explanationWindow.viewport = viewport
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
        @explanationWindow.text = text
    end

    def update
        @explanationWindow.update
    end
end