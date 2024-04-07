#===============================================================================
# Boosts by 50% if there is sun. (Hydro Steam)
#===============================================================================
class PokeBattle_Move_BoostInSun < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 1.5 if battle.sunny?
        return baseDmg
    end
end

#===============================================================================
# Boosts by 50% if there is moonglow. (Psyblade)
#===============================================================================
class PokeBattle_Move_BoostInMoonglow < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 1.5 if battle.moonGlowing?
        return baseDmg
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks with the user with a physical attack while this effect applies, that Pokémon is
# burned. (Burning Balwark)
#===============================================================================
class PokeBattle_Move_ProtectUserBurnPhysAttacker < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :BurningBalwark
    end

    def getEffectScore(user, target)
        score = super
        # Check only physical attackers
        user.eachPredictedProtectHitter(0) do |b|
            score += getBurnEffectScore(user, b)
        end
        return score
    end
end

#===============================================================================
# Boosts by 33% if the move is super effective. (Collision Course and Electro Drift)
#===============================================================================
class PokeBattle_Move_BoostIfSuperEffective < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 1.5 if Effectiveness.super_effective?(typeModToCheck(user.battle, type, user, target, move, aiCheck))
        return baseDmg
    end
end