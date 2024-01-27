#===============================================================================
# Type changes depending on the weather. (Weather Burst)
# Changes category based on your better attacking stat.
#===============================================================================
class PokeBattle_Move_087 < PokeBattle_Move
    def aiAutoKnows?(pokemon); return true; end

    def immuneToRainDebuff?; return true; end
    def immuneToSunDebuff?; return true; end
    
    def shouldHighlight?(_user, _target)
        return @battle.pbWeather != :None
    end

    def pbBaseType(_user)
        ret = :NORMAL
        case @battle.pbWeather
        when :Sun, :HarshSun
            ret = :FIRE if GameData::Type.exists?(:FIRE)
        when :Rain, :HeavyRain
            ret = :WATER if GameData::Type.exists?(:WATER)
        when :Sandstorm
            ret = :ROCK if GameData::Type.exists?(:ROCK)
        when :Hail
            ret = :ICE if GameData::Type.exists?(:ICE)
        when :Eclipse,:RingEclipse
            ret = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
        when :Moonglow,:BloodMoon
            ret = :FAIRY if GameData::Type.exists?(:FAIRY)
        end
        return ret
    end

    # def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    #     t = pbBaseType(user)
    #     hitNum = 1 if t == :FIRE # Type-specific anims
    #     hitNum = 2 if t == :WATER
    #     hitNum = 3 if t == :ROCK
    #     hitNum = 4 if t == :ICE
    #     super
    # end

    def calculateCategory(user, _targets)
        return selectBestCategory(user)
    end
end

#===============================================================================
# Type depends on the user's held item. (Judgment, Multi-Attack, Techno Blast)
#===============================================================================
class PokeBattle_Move_09F < PokeBattle_Move
    def initialize(battle, move)
        super
        if @id == :TECHNOBLAST
            @itemTypes = {
                :SHOCKDRIVE => :ELECTRIC,
                :BURNDRIVE  => :FIRE,
                :CHILLDRIVE => :ICE,
                :DOUSEDRIVE => :WATER,
            }
        elsif @id == :MULTIATTACK
            @itemTypes = {
                :FIGHTINGMEMORY => :FIGHTING,
                :FLYINGMEMORY   => :FLYING,
                :POISONMEMORY   => :POISON,
                :GROUNDMEMORY   => :GROUND,
                :ROCKMEMORY     => :ROCK,
                :BUGMEMORY      => :BUG,
                :GHOSTMEMORY    => :GHOST,
                :STEELMEMORY    => :STEEL,
                :FIREMEMORY     => :FIRE,
                :WATERMEMORY    => :WATER,
                :GRASSMEMORY    => :GRASS,
                :ELECTRICMEMORY => :ELECTRIC,
                :PSYCHICMEMORY  => :PSYCHIC,
                :ICEMEMORY      => :ICE,
                :DRAGONMEMORY   => :DRAGON,
                :DARKMEMORY     => :DARK,
                :FAIRYMEMORY    => :FAIRY,
            }
        end
    end

    def pbBaseType(user)
        ret = :NORMAL
        if user.itemActive?
            if @id == :TECHNOBLAST
                @itemTypes.each do |item, itemType|
                    next unless user.hasItem?(item)
                    ret = itemType if GameData::Type.exists?(itemType)
                    break
                end
            else
                return user.itemTypeChosen
            end
        end
        return ret
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        if @id == :TECHNOBLAST # Type-specific anim
            t = pbBaseType(user)
            hitNum = 0
            hitNum = 1 if t == :ELECTRIC
            hitNum = 2 if t == :FIRE
            hitNum = 3 if t == :ICE
            hitNum = 4 if t == :WATER
        end
        super
    end
end