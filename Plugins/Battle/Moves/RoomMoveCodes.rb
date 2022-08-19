def getRoomDuration(user)
   if user && user.hasActiveItem?(:REINFORCINGROD)
    return 8
   else
    return 5
   end
end

#===============================================================================
# For 5 rounds, Pokemon's Attack and Sp. Atk are swapped. (Puzzle Room)
#===============================================================================
class PokeBattle_Move_51A < PokeBattle_Move
	def pbEffectGeneral(user)
	  if @battle.field.effects[PBEffects::PuzzleRoom]>0
		@battle.field.effects[PBEffects::PuzzleRoom] = 0
		@battle.pbDisplay(_INTL("The area returned to normal!"))
	  else
		@battle.field.effects[PBEffects::PuzzleRoom] = getRoomDuration(user)
		@battle.pbDisplay(_INTL("It created a puzzling area in which Pokémon's Attack and Sp. Atk are swapped!"))
	  end
	end
  
	def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
	  return if @battle.field.effects[PBEffects::PuzzleRoom] > 0   # No animation
	  super
	end
end

#===============================================================================
# For 5 rounds, for each priority bracket, slow Pokémon move before fast ones.
# (Trick Room)
#===============================================================================
class PokeBattle_Move_11F < PokeBattle_Move
    def pbEffectGeneral(user)
      if @battle.field.effects[PBEffects::TrickRoom]>0
        @battle.field.effects[PBEffects::TrickRoom] = 0
        @battle.pbDisplay(_INTL("{1} reverted the dimensions!",user.pbThis))
      else
        @battle.field.effects[PBEffects::TrickRoom] = getRoomDuration(user)
        @battle.pbDisplay(_INTL("{1} twisted the dimensions!",user.pbThis))
      end
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      return if @battle.field.effects[PBEffects::TrickRoom]>0   # No animation
      super
    end
end


#===============================================================================
# For 5 rounds, swaps all battlers' base Defense with base Special Defense.
# (Wonder Room)
#===============================================================================
class PokeBattle_Move_124 < PokeBattle_Move
    def pbEffectGeneral(user)
      if @battle.field.effects[PBEffects::WonderRoom]>0
        @battle.field.effects[PBEffects::WonderRoom] = 0
        @battle.pbDisplay(_INTL("Wonder Room wore off, and the Defense and Sp. Def stats returned to normal!"))
      else
        @battle.field.effects[PBEffects::WonderRoom] = getRoomDuration(user)
        @battle.pbDisplay(_INTL("It created a bizarre area in which the Defense and Sp. Def stats are swapped!"))
      end
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      return if @battle.field.effects[PBEffects::WonderRoom]>0   # No animation
      super
    end
end
  
#===============================================================================
# For 5 rounds, all held items cannot be used in any way and have no effect.
# Held items can still change hands, but can't be thrown. (Magic Room)
#===============================================================================
class PokeBattle_Move_0F9 < PokeBattle_Move
    def pbEffectGeneral(user)
      if @battle.field.effects[PBEffects::MagicRoom]>0
        @battle.field.effects[PBEffects::MagicRoom] = 0
        @battle.pbDisplay(_INTL("The area returned to normal!"))
      else
        @battle.field.effects[PBEffects::MagicRoom] = getRoomDuration(user)
        @battle.pbDisplay(_INTL("It created a bizarre area in which Pokémon's held items lose their effects!"))
      end
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      return if @battle.field.effects[PBEffects::MagicRoom]>0   # No animation
      super
    end
end

#===============================================================================
# For 5 rounds, swaps all battlers' offensive and defensive stats (Sp. Def <-> Sp. Atk / Def <-> Atk).
# (Odd Room)
#===============================================================================
class PokeBattle_Move_582 < PokeBattle_Move
    def pbEffectGeneral(user)
      if @battle.field.effects[PBEffects::OddRoom]>0
        @battle.field.effects[PBEffects::OddRoom] = 0
        @battle.pbDisplay(_INTL("Odd Room wore off, and Offensive and Defensive stats returned to normal"))
      else
        @battle.field.effects[PBEffects::OddRoom] = getRoomDuration(user)
        @battle.pbDisplay(_INTL("It created an odd area in which Pokémon's Offensive and Defensive stats are swapped!"))
      end
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      return if @battle.field.effects[PBEffects::OddRoom]>0   # No animation
      super
    end
end