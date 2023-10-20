#===============================================================================
#
#===============================================================================
class TrainerPC
    def shouldShow?
      return true
    end
  
    def name
        return _INTL("Item Storage PC")
    end
  
    def access
      pbMessage(_INTL("\\se[PC access]Accessed {1}'s PC.",$Trainer.name))
      pbTrainerPCMenu
    end
end

PokemonPCList.registerPC(TrainerPC.new)