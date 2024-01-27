#===============================================================================
# For 4 rounds, doubles the Speed of all battlers on the user's side. (Tailwind)
#===============================================================================
class PokeBattle_Move_05B < PokeBattle_Move
    def initialize(battle, move)
        super
        @tailwindDuration = 4
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:Tailwind, @tailwindDuration)
    end

    def getEffectScore(user, _target)
        return getTailwindEffectScore(user, @tailwindDuration, self)
    end
end