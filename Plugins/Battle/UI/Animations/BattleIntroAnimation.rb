#===============================================================================
# Shows the battle scene fading in while elements slide around into place
#===============================================================================
class BattleIntroAnimation < PokeBattle_Animation
    def initialize(sprites,viewport,battle)
      @battle = battle
      super(sprites,viewport)
    end
  
    def createProcesses
      appearTime = textFast? ? 12 : 20   # This is in 1/20 seconds
      # Background
      if @sprites["battle_bg2"]
        makeSlideSprite("battle_bg",0.5,appearTime)
        makeSlideSprite("battle_bg2",0.5,appearTime)
      end
      # Bases
      makeSlideSprite("base_0",1,appearTime,PictureOrigin::Bottom)
      makeSlideSprite("base_1",-1,appearTime,PictureOrigin::Center)
      # Player sprite, partner trainer sprite
      @battle.player.each_with_index do |_p,i|
        makeSlideSprite("player_#{i+1}",1,appearTime,PictureOrigin::Bottom)
      end
      # Opposing trainer sprite(s) or wild Pokémon sprite(s)
      if @battle.trainerBattle?
        @battle.opponent.each_with_index do |_p,i|
          makeSlideSprite("trainer_#{i+1}",-1,appearTime,PictureOrigin::Bottom)
        end
      else   # Wild battle
        @battle.pbParty(1).each_with_index do |_pkmn,i|
          idxBattler = 2*i+1
          makeSlideSprite("pokemon_#{idxBattler}",-1,appearTime,PictureOrigin::Bottom)
        end
      end
      # Shadows
      for i in 0...@battle.battlers.length
        makeSlideSprite("shadow_#{i}",((i%2)==0) ? 1 : -1,appearTime,PictureOrigin::Center)
      end
      # Fading blackness over whole screen
      blackScreen = addNewSprite(0,0,"Graphics/Battle animations/black_screen")
      blackScreen.setZ(0,999)
      blackScreen.moveOpacity(0,8,0)
      # Fading blackness over command bar
      blackBar = addNewSprite(@sprites["cmdBar_bg"].x,@sprites["cmdBar_bg"].y,
         "Graphics/Battle animations/black_bar")
      blackBar.setZ(0,998)
      blackBar.moveOpacity(appearTime*3/4,appearTime/4,0)
    end
  
    def makeSlideSprite(spriteName,deltaMult,appearTime,origin=nil)
      # If deltaMult is positive, the sprite starts off to the right and moves
      # left (for sprites on the player's side and the background).
      return if !@sprites[spriteName]
      s = addSprite(@sprites[spriteName],origin)
      s.setDelta(0,(Graphics.width*deltaMult).floor,0)
      s.moveDelta(0,appearTime,(-Graphics.width*deltaMult).floor,0)
    end
end