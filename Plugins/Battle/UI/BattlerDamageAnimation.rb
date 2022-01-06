#===============================================================================
# Shows a Pokémon flashing after taking damage
#===============================================================================
class BattlerDamageAnimation < PokeBattle_Animation
	def initialize(sprites,viewport,idxBattler,effectiveness,damageDealt = 0)
		@idxBattler    = idxBattler
		@effectiveness = effectiveness
		@damageDealt = damageDealt
		@damageDisplayBitmap = BitmapWrapper.new(Graphics.width,Graphics.height)
		@damageDisplaySprite = SpriteWrapper.new(@viewport)
		@damageDisplaySprite.bitmap = @damageDisplayBitmap
		pbSetSystemFont(@damageDisplayBitmap)
		@damageDisplayBitmap.font.size = 64
		@damageDisplaySprite.z = 999999
		
		super(sprites,viewport)
		
		@sprites["damage_display"] = @damageDisplaySprite
    end

	def createProcesses
		batSprite = @sprites["pokemon_#{@idxBattler}"]
		shaSprite = @sprites["shadow_#{@idxBattler}"]
		
		echoln("Are these the same? #{batSprite.viewport == @viewport}")
	
		# Damage hit numbers
		if @damageDealt != 0
			@damageDisplayBitmap.clear
			
			base = Color.new(72,72,72)
			case @effectiveness
			when 0 then base = Color.new(72,72,72)
			when 1 then base = Color.new(130,130,130)
			when 2 then base = Color.new(220,40,40)
			when 4 then base = Color.new(250,50,250)
			end
			
			shadow = Color.new(248,248,248)
			
			damageX = batSprite.x
			damageY = batSprite.y - 140
			pbDrawTextPositions(@damageDisplayBitmap,[[@damageDealt.to_s,damageX,damageY,2,base,shadow,true]])
		
			spritePicture = addSprite(@damageDisplaySprite)
			spritePicture.moveXY(5, 20, 0, -30)
			spritePicture.moveOpacity(10,15,0)
		end
		
		# Set up battler/shadow sprite
		battler = addSprite(batSprite,PictureOrigin::Bottom)
		shadow  = addSprite(shaSprite,PictureOrigin::Center)
		# Animation
		delay = 0
		case @effectiveness
		when 0 then battler.setSE(delay, "Battle damage normal")
		when 1 then battler.setSE(delay, "Battle damage weak")
		when 2 then battler.setSE(delay, "Battle damage super")
		when 4 then battler.setSE(delay, "Battle damage hyper") # HYPER EFFECTIVE DAMAGE !!
		end
		4.times do   # 4 flashes, each lasting 0.2 (4/20) seconds
		  battler.setVisible(delay,false)
		  shadow.setVisible(delay,false)
		  battler.setVisible(delay+2,true) if batSprite.visible
		  shadow.setVisible(delay+2,true) if shaSprite.visible
		  delay += 4
		end
		# Restore original battler/shadow sprites visibilities
		battler.setVisible(delay,batSprite.visible)
		shadow.setVisible(delay,shaSprite.visible)
	end
	
	def dispose
		super
		@damageDisplayBitmap.dispose if @damageDisplayBitmap
	end
end