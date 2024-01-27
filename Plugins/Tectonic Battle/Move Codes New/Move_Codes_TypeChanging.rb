#===============================================================================
# Changes user's type to that of a random user's move, except a type the user
# already has (even partially), OR changes to the user's first move's type.
# (Conversion)
#===============================================================================
class PokeBattle_Move_05E < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.canChangeType?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't have its type changed!"))
            return true
        end
        userTypes = user.pbTypes(true)
        @newTypes = []
        user.eachMoveWithIndex do |m, i|
            break if i > 0
            next if GameData::Type.get(m.type).pseudo_type
            next if userTypes.include?(m.type)
            @newTypes.push(m.type) unless @newTypes.include?(m.type)
        end
        if @newTypes.length == 0
            @battle.pbDisplay(_INTL("But it failed, since there are no valid types for it to choose!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        newType = @newTypes[@battle.pbRandom(@newTypes.length)]
        user.pbChangeTypes(newType)
        typeName = GameData::Type.get(newType).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", user.pbThis, typeName))
    end
end

#===============================================================================
# Changes user's type to a random one that resists/is immune to the last move
# used by the target. (Conversion 2)
#===============================================================================
class PokeBattle_Move_05F < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.canChangeType?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't have its types changed!"))
            end
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        if !target.lastMoveUsed || !target.lastMoveUsedType ||
           GameData::Type.get(target.lastMoveUsedType).pseudo_type
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        @newTypes = []
        GameData::Type.each do |t|
            next if t.pseudo_type || user.pbHasType?(t.id) ||
                    !Effectiveness.resistant_type?(target.lastMoveUsedType, t.id)
            @newTypes.push(t.id)
        end
        if @newTypes.length == 0
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        newType = @newTypes[@battle.pbRandom(@newTypes.length)]
        user.pbChangeTypes(newType)
        typeName = GameData::Type.get(newType).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", user.pbThis, typeName))
    end
end

#===============================================================================
# Changes user's type depending on the environment. (Camouflage)
#===============================================================================
class PokeBattle_Move_060 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.canChangeType?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't have its types changed!"))
            end
            return true
        end
        camouflageType = getCamouflageType
        unless GameData::Type.exists?(camouflageType)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since the type #{user.pbThis(true)} is supposed to become doesn't exist!"))
            end
            return true
        end
        if user.pbHasOtherType?(camouflageType)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already #{GameData::Type.get(camouflageType).name}-type!"))
            end
            return true
        end
        return false
    end

    def getCamouflageType
        newType = :NORMAL
        case @battle.environment
        when :Grass, :TallGrass
            newType = :GRASS
        when :MovingWater, :StillWater, :Puddle, :Underwater
            newType = :WATER
        when :Cave
            newType = :ROCK
        when :Rock, :Sand
            newType = :GROUND
        when :Forest, :ForestGrass
            newType = :BUG
        when :Snow, :Ice
            newType = :ICE
        when :Volcano
            newType = :FIRE
        when :Graveyard
            newType = :GHOST
        when :Sky
            newType = :FLYING
        when :Space
            newType = :DRAGON
        when :UltraSpace
            newType = :PSYCHIC
        end
        newType = :NORMAL unless GameData::Type.exists?(newType)
        return newType
    end

    def pbEffectGeneral(user)
        newType = getCamouflageType
        user.pbChangeTypes(newType)
        typeName = GameData::Type.get(newType).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", user.pbThis, typeName))
    end
end

#===============================================================================
# Target becomes Water type. (Soak)
#===============================================================================
class PokeBattle_Move_061 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        unless GameData::Type.exists?(:WATER)
            @battle.pbDisplay(_INTL("But it failed, since the Water-type doesn't exist!")) if show_message
            return true
        end
        unless target.canChangeType?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't change their type!")) if show_message
            return true
        end
        unless target.pbHasOtherType?(:WATER)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already only Water-type!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.pbChangeTypes(:WATER)
        typeName = GameData::Type.get(:WATER).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", target.pbThis, typeName))
    end

    def getEffectScore(_user, _target)
        return 80
    end
end

#===============================================================================
# User copes target's types. (Reflect Type)
#===============================================================================
class PokeBattle_Move_062 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.canChangeType?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't have its types changed!"))
            end
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        newTypes = target.pbTypes(true)
        if newTypes.length == 0 # Target has no type to copy
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} has no types!")) if show_message
            return true
        end
        if user.pbTypes == target.pbTypes && user.effects[:Type3] == target.effects[:Type3]
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} && #{target.pbThis(true)} share the exact same types!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        user.pbChangeTypes(target)
        @battle.pbDisplay(_INTL("{1}'s type changed to match {2}'s!",
           user.pbThis, target.pbThis(true)))
    end
end

#===============================================================================
# Target becomes Bug type. (Scale Scatter)
#===============================================================================
class PokeBattle_Move_06F < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        unless GameData::Type.exists?(:BUG)
            @battle.pbDisplay(_INTL("But it failed, since the Bug-type doesn't exist!")) if show_message
            return true
        end
        unless target.canChangeType?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't change their type!")) if show_message
            return true
        end
        unless target.pbHasOtherType?(:BUG)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already only Bug-type!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.pbChangeTypes(:BUG)
        typeName = GameData::Type.get(:BUG).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", target.pbThis, typeName))
    end

    def getEffectScore(_user, _target)
        return 80
    end
end