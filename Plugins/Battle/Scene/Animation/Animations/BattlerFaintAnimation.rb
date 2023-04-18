#===============================================================================
# Shows a Pokémon fainting
#===============================================================================
class BattlerFaintAnimation < PokeBattle_Animation
    def initialize(sprites,viewport,idxBattler,battle)
      @idxBattler = idxBattler
      @battle     = battle
      super(sprites,viewport)
    end
  
    def createProcesses
      batSprite = @sprites["pokemon_#{@idxBattler}"]
      shaSprite = @sprites["shadow_#{@idxBattler}"]
      # Set up battler/shadow sprite
      battler = addSprite(batSprite,PictureOrigin::Bottom)
      shadow  = addSprite(shaSprite,PictureOrigin::Center)
      # Get approx duration depending on sprite's position/size. Min 20 frames.
      battlerTop = batSprite.y-batSprite.height
      cropY = PokeBattle_SceneConstants.pbBattlerPosition(@idxBattler,
         @battle.pbSideSize(@idxBattler))[1]
      cropY += 8
      duration = (cropY-battlerTop)/8
      duration = 10 if duration<10   # Min 0.5 seconds
      # Animation
      # Play cry
      delay = 10
      cry = GameData::Species.cry_filename_from_pokemon(batSprite.pkmn)
      if cry
        battler.setSE(0, cry, nil, 75)   # 75 is pitch
        delay = GameData::Species.cry_length(batSprite.pkmn) * 20 / Graphics.frame_rate
      end
      # Sprite drops down
      shadow.setVisible(delay,false)
      battler.setSE(delay,"Pkmn faint")
      battler.moveOpacity(delay,duration,0)
      battler.moveDelta(delay,duration,0,cropY-battlerTop)
      battler.setCropBottom(delay,cropY)
      battler.setVisible(delay+duration,false)
      battler.setOpacity(delay+duration,255)
    end
end