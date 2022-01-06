#===============================================================================
# Shows a Pokémon flashing after taking damage
#===============================================================================
class BattlerDamageAnimation < PokeBattle_Animation
	def initialize(sprites,viewport,idxBattler,effectiveness,battler)
		@idxBattler    = idxBattler
		@effectiveness = effectiveness
		@battler = battler
		@damageDealt = battler.damageState.displayedDamage
		@damageDisplayBitmap = BitmapWrapper.new(Graphics.width,Graphics.height)
		@damageDisplaySprite = SpriteWrapper.new(@viewport)
		@damageDisplaySprite.bitmap = @damageDisplayBitmap
		pbSetSystemFont(@damageDisplayBitmap)
		@damageDisplaySprite.z = 999999
		
		super(sprites,viewport)
		
		@sprites["damage_display"] = @damageDisplaySprite
    end

	def createProcesses
		batSprite = @sprites["pokemon_#{@idxBattler}"]
		shaSprite = @sprites["shadow_#{@idxBattler}"]
		
		# Damage hit numbers
		if @damageDealt != 0
			@damageDisplayBitmap.clear
			
			framesForMovement = 20
			framesForOpacity = 15
			
			hpPercentDamaged = @damageDealt / @battler.totalhp.to_f
			numHPBars = @battler.boss? ? (isLegendary?(@battler.species) ? 3 : 2) : 1
			hpBarPercentage = (hpPercentDamaged * numHPBars).floor(1)
			
			if hpBarPercentage >= 1.0
				@damageDisplayBitmap.font.size = 96
				framesForMovement += 10
				framesForOpacity += 10
			elsif hpBarPercentage >= 0.5
				@damageDisplayBitmap.font.size = 64
				framesForMovement += 5
				framesForOpacity += 5
			else
				@damageDisplayBitmap.font.size = 32
			end
			
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
			spritePicture.moveXY(5, framesForMovement, 0, -30)
			spritePicture.moveOpacity(10,framesForOpacity,0)
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