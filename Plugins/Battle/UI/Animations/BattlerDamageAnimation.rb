#===============================================================================
# Shows a Pokémon flashing after taking damage
#===============================================================================
class BattlerDamageAnimation < PokeBattle_Animation
	def initialize(sprites,viewport,idxBattler,effectiveness,battler,fastHitAnimation=false)
		@idxBattler    = idxBattler
		@effectiveness = effectiveness
		@battler = battler
		@damageDealt = battler.damageState.displayedDamage.round
		battler.damageState.displayedDamage = 0
		@damageDisplayBitmap = BitmapWrapper.new(Graphics.width,Graphics.height)
		@damageDisplaySprite = SpriteWrapper.new(@viewport)
		@damageDisplaySprite.bitmap = @damageDisplayBitmap
		pbSetSystemFont(@damageDisplayBitmap)
		@damageDisplaySprite.z = 999999
		
		@fastHitAnimation = fastHitAnimation
		
		super(sprites,viewport)
		
		@sprites["damage_display"] = @damageDisplaySprite
    end

	DAMAGE_POPUP_SHADOW_COLOR = Color.new(248,248,248)

	def createProcesses
		batSprite = @sprites["pokemon_#{@idxBattler}"]
		shaSprite = @sprites["shadow_#{@idxBattler}"]
		
		# Damage hit numbers
		if @damageDealt != 0 && $PokemonSystem.damage_numbers == 0
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
			
			if @fastHitAnimation
				framesForMovement /= 4 
				framesForOpacity /= 4
			end
			
			effectivenessCategory = 3
			if @effectiveness <= 0
				effectivenessCategory = 0
			elsif @effectiveness < 0.5
				effectivenessCategory = 1
			elsif @effectiveness < 1
				effectivenessCategory = 2
			elsif @effectiveness < 2
				effectivenessCategory = 3
			elsif @effectiveness < 4
				effectivenessCategory = 4
			else
				effectivenessCategory = 5
			end
			color = EFFECTIVENESS_COLORS[effectivenessCategory]
			
			damageX = batSprite.x
			damageY = batSprite.y - 140
			damageDisplayLabel = @damageDealt.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/,"\\1#{","}")
			pbDrawTextPositions(@damageDisplayBitmap,[[damageDisplayLabel,damageX,damageY,2,color,DAMAGE_POPUP_SHADOW_COLOR,true]])
		
			if @fastHitAnimation
				movementFrameStart = 1
				opacityFrameStart = 2
			else
				movementFrameStart = 5
				opacityFrameStart = 10
			end
		
			spritePicture = addSprite(@damageDisplaySprite)
			spritePicture.moveXY(movementFrameStart, framesForMovement, 0, -30)
			spritePicture.moveOpacity(opacityFrameStart,framesForOpacity,0)
		end
		
		# Set up battler/shadow sprite
		battler = addSprite(batSprite,PictureOrigin::Bottom)
		shadow  = addSprite(shaSprite,PictureOrigin::Center)

		delay = 0
		if @effectiveness < 1
			battler.setSE(delay, "Battle damage weak")
		elsif @effectiveness < 2
			battler.setSE(delay, "Battle damage normal")
		elsif @effectiveness < 4
			battler.setSE(delay, "Battle damage super")
		else
			battler.setSE(delay, "Battle damage hyper")
		end

		if @fastHitAnimation
			flashesCount = 1
		else
			flashesCount = $PokemonSystem.battlescene == 1 ? flashesCount = 2 : 4
		end
		flashesCount.times do   # 4 flashes, each lasting 0.2 (4/20) seconds
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