#===============================================================================
# Move has increased Priority in sunshine (Solar Glide)
#===============================================================================
class PokeBattle_Move_IncreasedPriorityInSunshine < PokeBattle_Move
    def priorityModification(_user, _targets)
        return 1 if @battle.sunny?
        return 0
    end

    def shouldHighlight?(_user, _target)
        return @battle.sunny?
    end
end

#===============================================================================
# Move has increased Priority in sandstorm (Sand Blasting)
#===============================================================================
class PokeBattle_Move_IncreasedPriorityInSandstorm < PokeBattle_Move
    def priorityModification(_user, _targets)
        return 1 if @battle.sandy?
        return 0
    end

    def shouldHighlight?(_user, _target)
        return @battle.sandy?
    end
end