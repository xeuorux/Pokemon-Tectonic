#===============================================================================
# Entry hazard. Lays poison spikes on the opposing side (max. 1 layers).
# (Poison Spikes)
#===============================================================================
class PokeBattle_Move_104 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
        if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2
            @battle.pbDisplay(_INTL("But it failed, since the opposing side already has two layers of poison spikes!"))
            return true
        end
        return false
    end
  
    def pbEffectGeneral(user)
        user.pbOpposingSide.effects[PBEffects::ToxicSpikes] += 1
        if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] == 2
            @battle.pbDisplay(_INTL("The second layer of poison spikes were scattered all around {1}'s feet!",
			user.pbOpposingTeam(true)))
        else
            @battle.pbDisplay(_INTL("Poison spikes were scattered all around {1}'s feet!",
			user.pbOpposingTeam(true)))
        end
        if user.pbOpposingSide.effects[PBEffects::FlameSpikes] > 0
            user.pbOpposingSide.effects[PBEffects::FlameSpikes] = 0
            @battle.pbDisplay(_INTL("The flame spikes around {1}'s feet were brushed aside!",
                user.pbOpposingTeam(true)))
        end
        if user.pbOpposingSide.effects[PBEffects::FrostSpikes] > 0
            user.pbOpposingSide.effects[PBEffects::FrostSpikes] = 0
            @battle.pbDisplay(_INTL("The frost spikes around {1}'s feet were brushed aside!",
                user.pbOpposingTeam(true)))
        end
    end

    def getScore(score,user,target,skill=100)
        if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 1
            return 0
        end
        score -= 40
        score += 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        score += 10*@battle.pbAbleNonActiveCount(user.idxOwnSide)
        return score
    end
end

#===============================================================================
# Entry hazard. Lays burn spikes on the opposing side.
# (Flame Spikes)
#===============================================================================
class PokeBattle_Move_551 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
        if user.pbOpposingSide.effects[PBEffects::FlameSpikes] >= 2
            @battle.pbDisplay(_INTL("But it failed, since the opposing side already has two layers of flame spikes!"))
            return true
        end
        return false
    end
  
    def pbEffectGeneral(user)
        user.pbOpposingSide.effects[PBEffects::FlameSpikes] += 1
        if user.pbOpposingSide.effects[PBEffects::FlameSpikes] == 2
            @battle.pbDisplay(_INTL("The second layer of flame spikes were scattered all around {1}'s feet!",
            user.pbOpposingTeam(true)))
        else
            @battle.pbDisplay(_INTL("Flame spikes were scattered all around {1}'s feet!",
            user.pbOpposingTeam(true)))
        end
        if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] > 0
            user.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0
            @battle.pbDisplay(_INTL("The poison spikes around {1}'s feet were brushed aside!",
                user.pbOpposingTeam(true)))
        end
            if user.pbOpposingSide.effects[PBEffects::FrostSpikes] > 0
            user.pbOpposingSide.effects[PBEffects::FrostSpikes] = 0
            @battle.pbDisplay(_INTL("The frost spikes around {1}'s feet were brushed aside!",
                user.pbOpposingTeam(true)))
        end
    end
    
    def getScore(score,user,target,skill=100)
        if user.pbOpposingSide.effects[PBEffects::FlameSpikes] >= 1
            return 0
        end
        score -= 40
        score += 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
        score += 10*@battle.pbAbleNonActiveCount(user.idxOwnSide)
        return score
    end
end
  

#===============================================================================
# Entry hazard. Lays frostbite spikes on the opposing side.
# (Frost Spikes)
#===============================================================================
class PokeBattle_Move_569 < PokeBattle_Move
	def pbMoveFailed?(user,targets)
	  if user.pbOpposingSide.effects[PBEffects::FrostSpikes] >= 2
		@battle.pbDisplay(_INTL("But it failed, since the opposing side already has two layers of frost spikes!"))
		return true
	  end
	  return false
	end
  
	def pbEffectGeneral(user)
		user.pbOpposingSide.effects[PBEffects::FrostSpikes] += 1
		if user.pbOpposingSide.effects[PBEffects::FrostSpikes] == 2
            @battle.pbDisplay(_INTL("The second layer of frost spikes were scattered all around {1}'s feet!",
			user.pbOpposingTeam(true)))
        else
            @battle.pbDisplay(_INTL("Frost spikes were scattered all around {1}'s feet!",
			user.pbOpposingTeam(true)))
        end
		if user.pbOpposingSide.effects[PBEffects::FlameSpikes] > 0
			user.pbOpposingSide.effects[PBEffects::FlameSpikes] = 0
			@battle.pbDisplay(_INTL("The flame spikes around {1}'s feet were brushed aside!",
				user.pbOpposingTeam(true)))
		end
		if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] > 0
			user.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0
			@battle.pbDisplay(_INTL("The poison spikes around {1}'s feet were brushed aside!",
				user.pbOpposingTeam(true)))
		end
	end
	
	def getScore(score,user,target,skill=100)
		  if user.pbOpposingSide.effects[PBEffects::FrostSpikes] >= 1
			  return 0
		  end
		  score -= 40
		  score += 10*@battle.pbAbleNonActiveCount(user.idxOpposingSide)
		  score += 10*@battle.pbAbleNonActiveCount(user.idxOwnSide)
		  return score
	end
end