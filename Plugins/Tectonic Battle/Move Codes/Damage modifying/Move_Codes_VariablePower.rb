#===============================================================================
# Power increases with the user's HP. (Eruption, Water Spout, Dragon Energy)
#===============================================================================
class PokeBattle_Move_ScalesWithUserHP < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, _target)
        # From 65 to 130 in increments of 5, Overhealed caps at 195
        hpFraction = user.hp / user.totalhp.to_f
        hpFraction = 0.5 if hpFraction < 0.5
        hpFraction = 1.5 if hpFraction > 1.5
        basePower = (26 * hpFraction).floor * 5
        return basePower
    end
end

#===============================================================================
# Power increases with the target's HP. (Crush Grip, Wring Out)
#===============================================================================
class PokeBattle_Move_ScalesWithTargetHP < PokeBattle_Move
    def pbBaseDamage(_baseDmg, _user, target)
        # From 20 to 120 in increments of 5
        basePower = (20 * target.hp.to_f / target.totalhp.to_f).floor * 5
        basePower += 20
        return basePower
    end
end

#===============================================================================
# Power increases the quicker the target is than the user. (Gyro Ball)
#===============================================================================
class PokeBattle_Move_ScalesSlowerThanTarget < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, target)
        ratio = target.pbSpeed.to_f / user.pbSpeed.to_f
        basePower = 5 * (5 * ratio).floor
        basePower = 150 if basePower > 150
        basePower = 40 if basePower < 40
        return basePower
    end
end

#===============================================================================
# Power increases with the user's positive stat changes (ignores negative ones). (Rising Power)
# (after applying stat steps)
#===============================================================================
class PokeBattle_Move_ScalesUsersPositiveStatSteps < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        mult = 0
        GameData::Stat.each_battle { |s| mult += user.steps[s.id] if user.steps[s.id] > 0 }
        return baseDmg + 10 * mult
    end
end

#===============================================================================
# Power increases with the target's positive stat changes (ignores negative ones).
# (Punishment)
#===============================================================================
class PokeBattle_Move_ScalesTargetsPositiveStatSteps < PokeBattle_Move
    def pbBaseDamage(_baseDmg, _user, target)
        mult = 3
        GameData::Stat.each_battle { |s| mult += target.steps[s.id] if target.steps[s.id] > 0 }
        return [10 * mult, 200].min
    end
end

#===============================================================================
# Power increases the less PP this move has.
#===============================================================================
class PokeBattle_Move_ScalesWithLostPP < PokeBattle_Move
    def pbBaseDamage(_baseDmg, _user, _target)
        dmgs = [200, 160, 120, 80, 40]
        ppLeft = [@pp, dmgs.length - 1].min # PP is reduced before the move is used
        return dmgs[ppLeft]
    end

    def shouldHighlight?(_user, _target)
        return @pp == 1
    end
end

#===============================================================================
# Power increases the less HP the user has. (Flail, Reversal)
#===============================================================================
def flailBasePowerFormula(ratio)
    return [(20 / ((ratio * 5)**0.75)).floor * 5,200].min
end

class PokeBattle_Move_ScalesWithLostHP < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, _target)
        ratio = user.hp.to_f / user.totalhp.to_f
        return flailBasePowerFormula(ratio)
    end
end

#===============================================================================
# Power increases the quicker the user is than the target. (Electro Ball, Hunt Down)
#===============================================================================
class PokeBattle_Move_ScalesFasterThanTarget < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, target)
        ratio = user.pbSpeed.to_f / target.pbSpeed.to_f
        basePower = 10 + (7 * ratio).floor * 5
        basePower = 150 if basePower > 150
        basePower = 40 if basePower < 40
        return basePower
    end
end

#===============================================================================
# Power increases the heavier the target is. (Grass Knot, Low Kick)
#===============================================================================
class PokeBattle_Move_ScalesTargetsWeight < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, target)
        ret = 15
        weight = [target.pbWeight / 10,2000].min
        ret += ((4 * (weight**0.5)) / 5).floor * 5
        return ret
    end
end

#===============================================================================
# Power increases the heavier the user is than the target. (Heat Crash, Heavy Slam)
#===============================================================================
class PokeBattle_Move_ScalesHeavierThanTarget < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, target)
        ret = 40
        ratio = user.pbWeight.to_f / target.pbWeight.to_f
        ratio = 10 if ratio > 10
        ret += ((16 * (ratio**0.75)) / 5).floor * 5
        return ret
    end
end

#===============================================================================
# Deals 20 extra BP per fainted party member. (From Beyond)
#===============================================================================
class PokeBattle_Move_ScalesFaintedPartyMembers < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        user.ownerParty.each do |partyPokemon|
            next unless partyPokemon
            next if partyPokemon.personalID == user.personalID
            next unless partyPokemon.fainted?
            baseDmg += 20
        end
        return baseDmg
    end
end

#===============================================================================
# Power increases with the highest allies defense. (Hard Place)
#===============================================================================
class PokeBattle_Move_HardPlace < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, _target)
        highestDefense = 0
        user.eachAlly do |ally_battler|
            real_defense = ally_battler.pbDefense
            highestDefense = real_defense if real_defense > highestDefense
        end
        highestDefense = (highestDefense/5)*5 # Round to nearest 5
        highestDefense = 40 if highestDefense < 40
        highestDefense = 200 if highestDefense > 200
        return highestDefense
    end
end

#===============================================================================
# Power increases the taller the user is than the target. (Cocodrop)
#===============================================================================
class PokeBattle_Move_ScalesTallerThanTarget < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, target)
        ret = 40
        ratio = user.pbHeight.to_f / target.pbHeight.to_f
        ratio = 10 if ratio > 10
        ret += ((16 * (ratio**0.75)) / 5).floor * 5
        return ret
    end
end