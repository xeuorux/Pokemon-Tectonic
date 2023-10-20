
#===============================================================================
#
#===============================================================================
class PokemonEntry
    def initialize(scene)
      @scene=scene
    end
  
    def pbStartScreen(helptext,minlength,maxlength,initialText,mode=-1,pokemon=nil)
      @scene.pbStartScene(helptext,minlength,maxlength,initialText,mode,pokemon)
      ret=@scene.pbEntry
      @scene.pbEndScene
      return ret
    end
  end
  
  
  #===============================================================================
  #
  #===============================================================================
  def pbEnterText(helptext,minlength,maxlength,initialText="",mode=0,pokemon=nil,nofadeout=false)
    ret=""
    if ($PokemonSystem.textinput==1 rescue false)   # Keyboard
      pbFadeOutIn(99999,nofadeout) {
         sscene=PokemonEntryScene.new
         sscreen=PokemonEntry.new(sscene)
         ret=sscreen.pbStartScreen(helptext,minlength,maxlength,initialText,mode,pokemon)
      }
    else   # Cursor
      pbFadeOutIn(99999,nofadeout) {
         sscene=PokemonEntryScene2.new
         sscreen=PokemonEntry.new(sscene)
         ret=sscreen.pbStartScreen(helptext,minlength,maxlength,initialText,mode,pokemon)
      }
    end
    return ret
  end
  
  def pbEnterPlayerName(helptext,minlength,maxlength,initialText="",nofadeout=false)
    return pbEnterText(helptext,minlength,maxlength,initialText,1,nil,nofadeout)
  end
  
  def pbEnterPokemonName(helptext,minlength,maxlength,initialText="",pokemon=nil,nofadeout=false)
    return pbEnterText(helptext,minlength,maxlength,initialText,2,pokemon,nofadeout)
  end
  
  def pbEnterNPCName(helptext,minlength,maxlength,initialText="",id=0,nofadeout=false)
    return pbEnterText(helptext,minlength,maxlength,initialText,3,id,nofadeout)
  end
  
  def pbEnterBoxName(helptext,minlength,maxlength,initialText="",nofadeout=false)
    return pbEnterText(helptext,minlength,maxlength,initialText,4,nil,nofadeout)
  end
  