class Window_CommandPokemon < Window_DrawableCommand
    attr_reader :commands
  
    def initialize(commands,width=nil)
      @starting=true
      @commands=[]
      dims=[]
      super(0,0,32,32)
      getAutoDims(commands,dims,width)
      self.width=dims[0]
      self.height=dims[1]
      commands.map! { |command|
        globalMessageReplacements(command)
      }
      @commands=commands
      self.active=true
      colors=getDefaultTextColors(self.windowskin)
      self.baseColor=colors[0]
      self.shadowColor=colors[1]
      refresh
      @starting=false
    end
end