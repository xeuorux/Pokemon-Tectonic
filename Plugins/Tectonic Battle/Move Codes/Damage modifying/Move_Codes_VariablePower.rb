#===============================================================================
# Power increases with the user's HP. (Eruption, Water Spout, Dragon Energy)
#===============================================================================
class PokeBattle_Move_08B < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, _target)
        # From 0 to 150 in increments of 5
        basePower = (30 * user.hp / user.totalhp).floor * 5
        basePower = 1 if basePower < 1
        return basePower
    end
end

#===============================================================================
# Power increases with the target's HP. (Crush Grip, Wring Out)
#===============================================================================
class PokeBattle_Move_08C < PokeBattle_Move
    def pbBaseDamage(_baseDmg, _user, target)
        # From 20 to 120 in increments of 5
        basePower = (20 * target.hp / target.totalhp).floor * 5
        basePower += 20
        return basePower
    end
end

#===============================================================================
# Power increases the quicker the target is than the user. (Gyro Ball)
#===============================================================================
class PokeBattle_Move_08D < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, target)
        return [[(25 * target.pbSpeed / user.pbSpeed).floor, 150].min, 1].max
    end
end

#===============================================================================
# Power increases with the user's positive stat changes (ignores negative ones). (Rising Power)
# This move is physical if user's Attack is higher than its Special Attack
# (after applying stat steps)
#===============================================================================
class PokeBattle_Move_08E < PokeBattle_Move
    def initialize(battle, move)
        super
        @calculated_category = 1
    end

    def calculateCategory(user, _targets)
        return selectBestCategory(user)
    end

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
class PokeBattle_Move_08F < PokeBattle_Move
    def pbBaseDamage(_baseDmg, _user, target)
        mult = 3
        GameData::Stat.each_battle { |s| mult += target.steps[s.id] if target.steps[s.id] > 0 }
        return [10 * mult, 200].min
    end
end

#===============================================================================
# Power increases the less PP this move has. (Trump Card)
#===============================================================================
class PokeBattle_Move_097 < PokeBattle_Move
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
class PokeBattle_Move_098 < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, _target)
        ret = 20
        n = 48 * user.hp / user.totalhp
        if n < 2
            ret = 200
        elsif n < 5
            ret = 150
        elsif n < 10
            ret = 100
        elsif n < 17
            ret = 80
        elsif n < 33
            ret = 40
        end
        return ret
    end
end

#===============================================================================
# Power increases the quicker the user is than the target. (Electro Ball)
#===============================================================================
class PokeBattle_Move_099 < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, target)
        ret = 40
        n = user.pbSpeed / target.pbSpeed
        if n >= 4
            ret = 150
        elsif n >= 3
            ret = 120
        elsif n >= 2
            ret = 80
        elsif n >= 1
            ret = 60
        end
        return ret
    end
end

#===============================================================================
# Power increases the heavier the target is. (Grass Knot, Low Kick)
#===============================================================================
class PokeBattle_Move_09A < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, target)
        ret = 15
        weight = [target.pbWeight,2000].min
        ret += ((3 * (weight**0.5)) / 5).floor * 5
        return ret
    end
end

#===============================================================================
# Power increases the heavier the user is than the target. (Heat Crash, Heavy Slam)
#===============================================================================
class PokeBattle_Move_09B < PokeBattle_Move
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
class PokeBattle_Move_132 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        user.ownerParty.each do |partyPokemon|
            next if partyPokemon.personalID == user.personalID
            next unless partyPokemon.fainted?
            baseDmg += 20
        end
        return baseDmg
    end
end