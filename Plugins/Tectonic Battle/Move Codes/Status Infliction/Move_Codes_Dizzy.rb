#===============================================================================
# Dizzies the target.
#===============================================================================
class PokeBattle_Move_Dizzy < PokeBattle_DizzyMove
end

#===============================================================================
# Dizzies the target. Accuracy perfect in rainstorm. Hits flying (Tempest)
# semi-invuln targets.
#===============================================================================
class PokeBattle_Move_DizzyTargetAlwaysHitsInRainstormHitsTargetInSky < PokeBattle_DizzyMove
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

#===============================================================================
# Multi-hit move that can dizzy.
#===============================================================================
class PokeBattle_Move_DizzyTargetHitTwoToFiveTimes < PokeBattle_DizzyMove
    include RandomHitable
end

# Empowered Power Gem
class PokeBattle_Move_EmpoweredPowerGem < PokeBattle_Move_Dizzy
    include EmpoweredMove
end