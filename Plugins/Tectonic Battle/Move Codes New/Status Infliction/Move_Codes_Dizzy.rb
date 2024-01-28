#===============================================================================
# Dizzies the target.
#===============================================================================
class PokeBattle_Move_Dizzy < PokeBattle_DizzyMove
end

#===============================================================================
# Dizzies the target. Accuracy perfect in rain. Hits flying semi-invuln targets. (Hurricane)
#===============================================================================
class PokeBattle_Move_570 < PokeBattle_DizzyMove
    def immuneToRainDebuff?; return true; end

    def hitsFlyingTargets?; return true; end

    def pbBaseAccuracy(user, target)
        return 0 if @battle.rainy?
        return super
    end

    def shouldHighlight?(_user, _target)
        return @battle.rainy?
    end
end