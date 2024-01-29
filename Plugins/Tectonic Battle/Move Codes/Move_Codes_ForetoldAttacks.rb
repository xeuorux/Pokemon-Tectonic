#===============================================================================
# Attacks 2 rounds in the future. (Future Sight, etc.)
#===============================================================================
class PokeBattle_Move_AttackTwoTurnsLater < PokeBattle_ForetoldMove
end

# Empowered Future Sight
class PokeBattle_Move_EmpoweredFutureSight < PokeBattle_Move_AttackTwoTurnsLater
    include EmpoweredMove
end

#===============================================================================
# Choose between Ice, Fire, and Electric. This move attacks 1 turn in
# the future with an attack of that type. (Artillerize)
#===============================================================================
class PokeBattle_Move_AttackOneTurnLaterChooseIceFireElectricType < PokeBattle_ForetoldMove
    def initialize(battle, move)
        super
        @turnCount = 2
    end

    def resolutionChoice(user)
        return if damagingMove?
        validTypes = %i[FIRE ELECTRIC ICE]
        validTypeNames = []
        validTypes.each do |typeID|
            validTypeNames.push(GameData::Type.get(typeID).name)
        end
        if validTypes.length == 1
            @chosenType = validTypes[0]
        elsif validTypes.length > 1
            if @battle.autoTesting
                @chosenType = validTypes.sample
            elsif !user.pbOwnedByPlayer? # Trainer AI
                @chosenType = validTypes[0]
            else
                chosenIndex = @battle.scene.pbShowCommands(_INTL("Which type should #{user.pbThis(true)} launch?"),validTypeNames,0)
                @chosenType = validTypes[chosenIndex]
            end
        end
    end

    def pbEffectAgainstTarget(user, target)
        super
        unless @battle.futureSight
            target.position.applyEffect(:FutureSightType, @chosenType)
        end
    end

    def pbDisplayUseMessage(user, targets)
        super
        if @battle.futureSight
            @battle.pbDisplay(_INTL("It's an explosion of pure #{GameData::Type.get(@calcType).name}!"))
        end
    end
end