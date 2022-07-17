
#===============================================================================
# Implements the move Struggle.
# For cases where the real move named Struggle is not defined.
#===============================================================================
class PokeBattle_Struggle < PokeBattle_Move
  def initialize(battle,move)
    @battle     = battle
    @realMove   = nil                     # Not associated with a move
    @id         = (move) ? move.id : :STRUGGLE
    @name       = (move) ? move.name : _INTL("Struggle")
    @function   = "002"
    @baseDamage = 50
    @type       = nil
    @category   = 0
    @accuracy   = 0
    @pp         = -1
    @target     = 0
    @priority   = 0
    @flags      = ""
    @addlEffect = 0
    @calcType   = nil
    @powerBoost = false
    @snatched   = false
  end

  def physicalMove?(thisType=nil); return true;  end
  def specialMove?(thisType=nil);  return false; end

  def pbEffectAfterAllHits(user,target)
    return if target.damageState.unaffected
	  if user.boss?
		  user.pbReduceHP((user.totalhp/16.0).round,false)
    else
		  user.pbReduceHP((user.totalhp/4.0).round,false)
	  end
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
    user.pbItemHPHealCheck
  end
end
