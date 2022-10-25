class PokeBattle_Battle
    def pbDisplay(msg,&block)
        @scene.pbDisplayMessage(msg,&block) if !@messagesBlocked
      end
    
      def pbDisplayBrief(msg)
        @scene.pbDisplayMessage(msg,true) if !@messagesBlocked
      end
    
      def pbDisplayPaused(msg,&block)
        @scene.pbDisplayPausedMessage(msg,&block) if !@messagesBlocked
      end
    
      def pbDisplayConfirm(msg)
        return @scene.pbDisplayConfirmMessage(msg) if !@messagesBlocked
      end
      
      def pbDisplayConfirmSerious(msg)
        return @scene.pbDisplayConfirmMessageSerious(msg) if !@messagesBlocked
      end
    
      def pbShowCommands(msg,commands,canCancel=true)
        @scene.pbShowCommands(msg,commands,canCancel)
      end
    
      def pbAnimation(move,user,targets,hitNum=0)
        if @messagesBlocked
          echoln("Skipping animation during AI calculations.")
          return
        end
        @scene.pbAnimation(move,user,targets,hitNum) if @showAnims
      end
    
      def pbCommonAnimation(name,user=nil,targets=nil)
        if @messagesBlocked
          echoln("Skipping animation during AI calculations.")
          return
        end
        return if @messagesBlocked
        @scene.pbCommonAnimation(name,user,targets) if @showAnims
      end
    
      def pbShowAbilitySplash(battler,delay=false,logTrigger=true)
        return if @messagesBlocked
        PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}") if logTrigger
        @scene.pbShowAbilitySplash(battler)
        if delay
          frames = Graphics.frame_rate # Default 1 second
          frames /= 2 if $PokemonSystem.battlescene > 0
          frames.times { @scene.pbUpdate }   
        end
      end
    
      def pbHideAbilitySplash(battler)
        return if @messagesBlocked
        @scene.pbHideAbilitySplash(battler)
      end
    
      def pbReplaceAbilitySplash(battler)
        return if @messagesBlocked
        @scene.pbReplaceAbilitySplash(battler)
      end
end