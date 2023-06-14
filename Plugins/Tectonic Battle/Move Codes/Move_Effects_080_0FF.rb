#===============================================================================
# Power is doubled if the target's HP is down to 1/2 or less. (Brine, Dead End)
#===============================================================================
class PokeBattle_Move_080 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.belowHalfHealth?
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the user has lost HP due to the target's move this round.
# (Avalanche, Revenge)
#===============================================================================
class PokeBattle_Move_081 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 2 if user.lastAttacker.include?(target.index)
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        baseDmg *= 2 if user.pbSpeed(true) < target.pbSpeed
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the target has already lost HP this round. (Assurance)
#===============================================================================
class PokeBattle_Move_082 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.tookDamage
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        fastAllyAttacker = false
        user.eachAlly do |b|
            next unless b.hasDamagingAttack?
            fastAllyAttacker = true if b.pbSpeed(true) > user.pbSpeed(true)
        end
        baseDmg *= 2 if fastAllyAttacker
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if a user's ally has already used this move this round. (Round)
# If an ally is about to use the same move, make it go next, ignoring priority.
#===============================================================================
class PokeBattle_Move_083 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 2 if user.pbOwnSide.effectActive?(:Round)
        return baseDmg
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:Round)
        user.eachAlly do |b|
            next if @battle.choices[b.index][0] != :UseMove || b.movedThisRound?
            next if @battle.choices[b.index][2].function != @function
            b.applyEffect(:MoveNext)
            break
        end
    end

    def getEffectScore(user, _target)
        score = 0
        user.eachAlly do |b|
            next unless b.pbHasMove?(@id)
            score += 50
        end
        return score
    end
end

#===============================================================================
# Power is doubled if the target has already moved this round. (Payback)
#===============================================================================
class PokeBattle_Move_084 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.movedThisRound?
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        baseDmg *= 2 if user.pbSpeed(true) < target.pbSpeed
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if a user's teammate fainted last round. (Retaliate)
#===============================================================================
class PokeBattle_Move_085 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        lrf = user.pbOwnSide.effects[:LastRoundFainted]
        baseDmg *= 2 if lrf >= 0 && lrf == @battle.turnCount - 1
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the user has no held item. (Acrobatics)
#===============================================================================
class PokeBattle_Move_086 < PokeBattle_Move
    def pbModifyDamage(damageMult, user, _target)
        damageMult *= 2 unless user.hasAnyItem?
        return damageMult
    end

    def pbBaseDamageAI(baseDmg, user, _target)
        baseDmg *= 2 if !user.hasAnyItem? || user.hasActiveItem?(:FLYINGGEM)
        return baseDmg
    end
end

#===============================================================================
# Type changes depending on the weather. (Weather Burst)
# Changes category based on your better attacking stat.
#===============================================================================
class PokeBattle_Move_087 < PokeBattle_Move
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
        when :Eclipse
            ret = :PSYCHIC if GameData::Type.exists?(:PSYCHIC)
        when :Moonglow
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
# Interrupts a foe switching out or using U-turn/Volt Switch/Parting Shot. Power
# is doubled in that case. (Pursuit)
# (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
#===============================================================================
class PokeBattle_Move_088 < PokeBattle_Move
    def pbAccuracyCheck(user, target)
        return true if @battle.switching
        return super
    end

    def pbBaseDamage(baseDmg, _user, _target)
        baseDmg *= 2 if @battle.switching
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        baseDmg *= 2 if @battle.aiPredictsSwitch?(user,target.index)
        return baseDmg
    end
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_089 < PokeBattle_Move
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_08A < PokeBattle_Move
end

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
# Power increases with the user's positive stat changes (ignores negative ones).
# (Power Trip, Stored Power, Trained Outburst)
#===============================================================================
class PokeBattle_Move_08E < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, _target)
        mult = 1
        GameData::Stat.each_battle { |s| mult += user.steps[s.id] if user.steps[s.id] > 0 }
        return 10 * mult
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
# Power and type depends on the user's IVs. (Hidden Power)
#===============================================================================
class PokeBattle_Move_090 < PokeBattle_Move
    def pbBaseType(user)
        hp = pbHiddenPower(user)
        return hp[0]
    end
end

def pbHiddenPower(pkmn)
    # NOTE: This allows Hidden Power to be Fairy-type (if you have that type in
    #       your game). I don't care that the official games don't work like that.
    iv = pkmn.iv
    idxType = 0
    power = 60
    types = []
    GameData::Type.each { |t| types.push(t.id) if !t.pseudo_type && !%i[NORMAL SHADOW].include?(t.id) }
    types.sort! { |a, b| GameData::Type.get(a).id_number <=> GameData::Type.get(b).id_number }
    idxType |= (iv[:HP] & 1)
    idxType |= (iv[:ATTACK] & 1) << 1
    idxType |= (iv[:DEFENSE] & 1) << 2
    idxType |= (iv[:SPEED] & 1) << 3
    idxType |= (iv[:SPECIAL_ATTACK] & 1) << 4
    idxType |= (iv[:SPECIAL_DEFENSE] & 1) << 5
    idxType = (types.length - 1) * idxType / 63
    type = types[idxType]
    return [type, power]
end

#===============================================================================
# Power doubles for each consecutive use. (FuryCutter)
#===============================================================================
class PokeBattle_Move_091 < PokeBattle_SnowballingMove
    def initialize(battle, move)
        @usageCountEffect = :FuryCutter
        super
    end
end

#===============================================================================
# Power is multiplied by the number of consecutive rounds in which this move was
# used by any Pokémon on the user's side. (Echoed Voice)
#===============================================================================
class PokeBattle_Move_092 < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        oldCount = user.pbOwnSide.effects[:EchoedVoiceCounter]
        super # Reset all other counters

        # If this is the first time the move is being used on this side this turn
        unless user.pbOwnSide.effectActive?(:EchoedVoiceUsed)
            user.pbOwnSide.effects[:EchoedVoiceCounter] = oldCount
            user.pbOwnSide.incrementEffect(:EchoedVoiceCounter)
        end
        user.pbOwnSide.applyEffect(:EchoedVoiceUsed)
    end

    def pbBaseDamage(baseDmg, user, _target)
        return baseDmg * user.pbOwnSide.effects[:EchoedVoiceCounter]
    end
end

#===============================================================================
# User rages until the start of a round in which they don't use this move. (Rage)
# (Handled in Battler's pbProcessMoveAgainstTarget): Ups rager's Attack by 1
# step each time it loses HP due to a move.
#===============================================================================
class PokeBattle_Move_093 < PokeBattle_Move
    def pbEffectGeneral(user)
        user.applyEffect(:Rage)
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless user.pbCanRaiseStatStep?(:ATTACK)

        score = 0

        user.eachPotentialAttacker do |b|
            if b.effectActive?(:TwoTurnAttack)
                if b.inTwoTurnAttack?("0CD")
                    next
                else
                    score += 50
                end
            else
                if hasBeenUsed?(user)
                    score += 15
                else
                    score += 30
                end
            end
        end
        score *= 2 if user.aboveHalfHealth?

        return score
    end
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_094 < PokeBattle_Move
end

#===============================================================================
# Power is chosen at random. Power is doubled if the target is using Dig. Hits
# some semi-invulnerable targets. (Magnitude)
#===============================================================================
class PokeBattle_Move_095 < PokeBattle_Move
    def pbOnStartUse(user, targets)
        chooseBasePower(user, targets)
    end

    def chooseBasePower(_user, _targets)
        baseDmg = [10, 30, 50, 70, 90, 110, 150]
        magnitudes = [
            4,
            5, 5,
            6, 6, 6, 6,
            7, 7, 7, 7, 7, 7,
            8, 8, 8, 8,
            9, 9,
            10,
        ]
        magni = magnitudes[@battle.pbRandom(magnitudes.length)]
        @magnitudeBP = baseDmg[magni - 4]
    end

    def pbBaseDamage(_baseDmg, _user, _target)
        return @magnitudeBP
    end

    def pbBaseDamageAI(_baseDmg, _user, _target)
        return 71
    end

    def shouldHighlight?(_user, _target)
        return false
    end
end

#===============================================================================
# Power and type depend on the user's held berry. Destroys the berry.
# (Natural Gift, Seed Surprise)
#===============================================================================
class PokeBattle_Move_096 < PokeBattle_Move
    def initialize(battle, move)
        super
        @typeArray = {
            :NORMAL   => [:CHILANBERRY],
            :FIRE     => %i[CHERIBERRY BLUKBERRY WATMELBERRY OCCABERRY],
            :WATER    => %i[CHESTOBERRY NANABBERRY DURINBERRY PASSHOBERRY],
            :ELECTRIC => %i[PECHABERRY WEPEARBERRY BELUEBERRY WACANBERRY],
            :GRASS    => %i[RAWSTBERRY PINAPBERRY RINDOBERRY LIECHIBERRY],
            :ICE      => %i[ASPEARBERRY POMEGBERRY YACHEBERRY GANLONBERRY],
            :FIGHTING => %i[LEPPABERRY KELPSYBERRY CHOPLEBERRY SALACBERRY],
            :POISON   => %i[ORANBERRY QUALOTBERRY KEBIABERRY PETAYABERRY],
            :GROUND   => %i[PERSIMBERRY HONDEWBERRY SHUCABERRY APICOTBERRY],
            :FLYING   => %i[LUMBERRY GREPABERRY COBABERRY LANSATBERRY],
            :PSYCHIC  => %i[SITRUSBERRY TAMATOBERRY PAYAPABERRY STARFBERRY],
            :BUG      => %i[FIGYBERRY CORNNBERRY TANGABERRY ENIGMABERRY],
            :ROCK     => %i[WIKIBERRY MAGOSTBERRY CHARTIBERRY MICLEBERRY],
            :GHOST    => %i[MAGOBERRY RABUTABERRY KASIBBERRY CUSTAPBERRY],
            :DRAGON   => %i[AGUAVBERRY NOMELBERRY HABANBERRY JABOCABERRY],
            :DARK     => %i[IAPAPABERRY SPELONBERRY COLBURBERRY ROWAPBERRY MARANGABERRY],
            :STEEL    => %i[RAZZBERRY PAMTREBERRY BABIRIBERRY],
            :FAIRY    => %i[ROSELIBERRY KEEBERRY],
        }
        @chosenItem = nil
    end

    def validItem(user,item)
        return false if user.unlosableItem?(item)
        return GameData::Item.get(item).is_berry?
    end

    def pbCanChooseMove?(user, commandPhase, show_message)
        unless user.itemActive?
            if show_message
                msg = _INTL("#{user.pbThis} can't use items!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        allItemsInvalid = true
        user.items.each do |item|
            next unless validItem(user, item)
            allItemsInvalid = false
            break
        end
        if allItemsInvalid
            if show_message
                msg = _INTL("#{user.pbThis} can't use any of its items!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        return true
    end

    def resolutionChoice(user)
        validItems = []
        validItemNames = []
        user.items.each do |item|
            next unless validItem(user,item)
            validItems.push(item)
            validItemNames.push(getItemName(item))
        end
        if validItems.length == 1
            @chosenItem = validItems[0]
        elsif validItems.length > 1
            if @battle.autoTesting
                @chosenItem = validItems.sample
            elsif !user.pbOwnedByPlayer? # Trainer AI
                @chosenItem = validItems[0]
            else
                chosenIndex = @battle.scene.pbShowCommands(_INTL("Which item should #{user.pbThis(true)} use?"),validItemNames,0)
                @chosenItem = validItems[chosenIndex]
            end
        end
    end

    def pbDisplayUseMessage(user, targets)
        super
        if @chosenItem
            typeName = GameData::Type.get(pbBaseType(user)).real_name
            @battle.pbDisplay(_INTL("The {1} turned the attack {2}-type!", getItemName(@chosenItem), typeName))
        end
    end

    # NOTE: The AI calls this method via pbCalcType, but it involves user.item
    #       which here is assumed to be not nil (because item.id is called). Since
    #       the AI won't want to use it if the user has no item anyway, perhaps
    #       this is good enough.
    def pbBaseType(user)
        item = @chosenItem
        ret = :NORMAL
        unless item.nil?
            @typeArray.each do |type, items|
                next unless items.include?(item)
                ret = type if GameData::Type.exists?(type)
                break
            end
        end
        return ret
    end

    def pbEndOfMoveUsageEffect(user, _targets, _numHits, _switchedBattlers)
        # NOTE: The item is consumed even if this move was Protected against or it
        #       missed. The item is not consumed if the target was switched out by
        #       an effect like a target's Red Card.
        # NOTE: There is no item consumption animation.
        user.consumeItem(@chosenItem, belch: false) if user.hasItem?(@chosenItem)
    end

    def resetMoveUsageState
        @chosenItem = nil
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
# Powers up the ally's attack this round by 1.5. (Helping Hand)
#===============================================================================
class PokeBattle_Move_09C < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.fainted?
            @battle.pbDisplay(_INTL("But it failed, since the receiver of the help is gone!")) if show_message
            return true
        end
        if target.effectActive?(:HelpingHand)
            @battle.pbDisplay(_INTL("But it failed, since #{arget.pbThis(true)} is already being helped!")) if show_message
            return true
        end
        return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
        return false
    end

    def pbFailsAgainstTargetAI?(_user, _target); return false; end

    def pbEffectAgainstTarget(user, target)
        target.applyEffect(:HelpingHand)
        @battle.pbDisplay(_INTL("{1} is ready to help {2}!", user.pbThis, target.pbThis(true)))
    end
end

#===============================================================================
# Starts eclipse weather. (Eclipse)
#===============================================================================
class PokeBattle_Move_09D < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Eclipse
    end
end

#===============================================================================
# Starts moonlight weather. (Moonglow)
#===============================================================================
class PokeBattle_Move_09E < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Moonglow
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

#===============================================================================
# This attack is always a critical hit. (Frost Breath, Storm Throw)
#===============================================================================
class PokeBattle_Move_0A0 < PokeBattle_Move
    def pbCriticalOverride(_user, _target); return 1; end
end

#===============================================================================
# For 5 rounds, foes' attacks cannot become critical hits. (Lucky Chant)
#===============================================================================
class PokeBattle_Move_0A1 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.pbOwnSide.effectActive?(:LuckyChant)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbTeam(true)} is already blessed!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:LuckyChant, 10)
    end

    def getEffectScore(_user, _target)
        return 40
    end
end

#===============================================================================
# For 5 rounds, lowers power of physical attacks against the user's side.
# (Reflect)
#===============================================================================
class PokeBattle_Move_0A2 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.pbOwnSide.effectActive?(:Reflect)
            @battle.pbDisplay(_INTL("But it failed, since a Reflect is already active!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:Reflect, user.getScreenDuration)
    end

    def getEffectScore(user, _target)
        score = 20 * user.getScreenDuration
        score += 30 if user.firstTurn?
        return score
    end
end

#===============================================================================
# For 5 rounds, lowers power of special attacks against the user's side. (Light Screen)
#===============================================================================
class PokeBattle_Move_0A3 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.pbOwnSide.effectActive?(:LightScreen)
            @battle.pbDisplay(_INTL("But it failed, since a Light Screen is already active!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:LightScreen, user.getScreenDuration)
    end

    def getEffectScore(user, _target)
        score = 20 * user.getScreenDuration
        score += 30 if user.firstTurn?
        return score
    end
end

#===============================================================================
# Effect depends on the environment. (Secret Power)
#===============================================================================
class PokeBattle_Move_0A4 < PokeBattle_Move
    def flinchingMove?; return [6, 10, 12].include?(@secretPower); end

    def pbOnStartUse(_user, _targets)
        # NOTE: This is Gen 7's list plus some of Gen 6 plus a bit of my own.
        @secretPower = 0 # Body Slam, numb
        case @battle.environment
        when :Grass, :TallGrass, :Forest, :ForestGrass
            @secretPower = 2    # (Same as Grassy Terrain)
        when :MovingWater, :StillWater, :Underwater
            @secretPower = 5    # Water Pulse, lower Attack by 1
        when :Puddle
            @secretPower = 6    # Mud Shot, lower Speed by 1
        when :Cave
            @secretPower = 7    # Rock Throw, flinch
        when :Rock, :Sand
            @secretPower = 8    # Dust Devil, burn
        when :Snow, :Ice
            @secretPower = 9    # Ice Shard, freeze
        when :Volcano
            @secretPower = 10   # Incinerate, burn
        when :Graveyard
            @secretPower = 11   # Shadow Sneak, flinch
        when :Sky
            @secretPower = 12   # Gust, lower Speed by 1
        when :Space
            @secretPower = 13   # Swift, flinch
        when :UltraSpace
            @secretPower = 14   # Psywave, lower Defense by 1
        end
    end

    # NOTE: This intentionally doesn't use def pbAdditionalEffect, because that
    #       method is called per hit and this move's additional effect only occurs
    #       once per use, after all the hits have happened (two hits are possible
    #       via Parental Bond).
    def pbEffectAfterAllHits(user, target)
        return if target.fainted?
        return if target.damageState.unaffected || target.damageState.substitute
        chance = pbAdditionalEffectChance(user, target, @calcType)
        return if @battle.pbRandom(100) >= chance
        return unless canApplyRandomAddedEffects?(user,target,true)
        case @secretPower
        when 2
            target.applySleep if target.canSleep?(user, false, self)
        when 8, 10
            target.applyBurn(user) if target.canBurn?(user, false, self)
        when 0, 1
            target.applyNumb(user) if target.canNumb?(user, false, self)
        when 9
            target.applyFrostbite if target.canFrostbite?(user, false, self)
        when 5
            target.tryLowerStat(:ATTACK, user, move: self)
        when 14
            target.tryLowerStat(:DEFENSE, user, move: self, increment: 2)
        when 3
            target.tryLowerStat(:SPECIAL_ATTACK, user, move: self, increment: 2)
        when 4, 6, 12
            target.tryLowerStryLowerStattat(:SPEED, user, move: self, increment: 2)
        when 7, 11, 13
            target.pbFlinch
        end
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        id = :BODYSLAM # Environment-specific anim
        case @secretPower
        when 1  then id = :THUNDERSHOCK if GameData::Move.exists?(:THUNDERSHOCK)
        when 2  then id = :VINEWHIP if GameData::Move.exists?(:VINEWHIP)
        when 3  then id = :FAIRYWIND if GameData::Move.exists?(:FAIRYWIND)
        when 4  then id = :MINDWAVES if GameData::Move.exists?(:MINDWAVES)
        when 5  then id = :WATERPULSE if GameData::Move.exists?(:WATERPULSE)
        when 6  then id = :MUDSHOT if GameData::Move.exists?(:MUDSHOT)
        when 7  then id = :ROCKTHROW if GameData::Move.exists?(:ROCKTHROW)
        when 8  then id = :MUDSLAP if GameData::Move.exists?(:MUDSLAP)
        when 9  then id = :ICESHARD if GameData::Move.exists?(:ICESHARD)
        when 10 then id = :INCINERATE if GameData::Move.exists?(:INCINERATE)
        when 11 then id = :SHADOWSNEAK if GameData::Move.exists?(:SHADOWSNEAK)
        when 12 then id = :GUST if GameData::Move.exists?(:GUST)
        when 13 then id = :SWIFT if GameData::Move.exists?(:SWIFT)
        when 14 then id = :PSYWAVE if GameData::Move.exists?(:PSYWAVE)
        end
        super
    end

    def getTargetAffectingEffectScore(_user, target)
        return 20
    end
end

#===============================================================================
# Always hits.
#===============================================================================
class PokeBattle_Move_0A5 < PokeBattle_Move
    def pbAccuracyCheck(_user, _target); return true; end
end

#===============================================================================
# User's attack next round against the target will definitely hit.
# (Lock-On, Mind Reader)
#===============================================================================
class PokeBattle_Move_0A6 < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        user.applyEffect(:LockOn, 2)
        user.pointAt(:LockOnPos, target)
        @battle.pbDisplay(_INTL("{1} took aim at {2}!", user.pbThis, target.pbThis(true)))
    end

    def getEffectScore(_user, _target)
        return 40
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_0A7 < PokeBattle_Move
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_0A8 < PokeBattle_Move
end

#===============================================================================
# This move ignores target's Defense, Special Defense and evasion stat changes.
# (Chip Away, Darkest Lariat, Sacred Sword)
#===============================================================================
class PokeBattle_Move_0A9 < PokeBattle_Move
    def pbCalcAccuracyMultipliers(user, target, multipliers)
        super
        modifiers[:evasion_step] = 0
    end

    def ignoresDefensiveStepBoosts?(_user, _target); return true; end

    def shouldHighlight?(_user, target)
        return target.hasRaisedDefenseSteps?
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. (Detect, Protect)
#===============================================================================
class PokeBattle_Move_0AA < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :Protect
    end
end

#===============================================================================
# User's side is protected against moves with priority greater than 0 this round.
# (Quick Guard)
#===============================================================================
class PokeBattle_Move_0AB < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect      = :QuickGuard
        @sidedEffect = true
    end
end

#===============================================================================
# User's side is protected against moves that target multiple battlers this round.
# (Wide Guard)
#===============================================================================
class PokeBattle_Move_0AC < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect      = :WideGuard
        @sidedEffect = true
    end
end

#===============================================================================
# Ends target's protections immediately. (Feint)
#===============================================================================
class PokeBattle_Move_0AD < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        removeProtections(target)
    end
end

#===============================================================================
# Uses the last move that the target used. (Mirror Move)
#===============================================================================
class PokeBattle_Move_0AE < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end
    def callsAnotherMove?; return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.lastRegularMoveUsed
            if show_message
                @battle.pbDisplay(_INTL("But #{target.pbThis(true)} has no move for #{user.pbThis(true)} to mirror!"))
            end
            return true
        end
        unless GameData::Move.get(target.lastRegularMoveUsed).flags[/e/] # Not copyable by Mirror Move
            @battle.pbDisplay(_INTL("But #{target.pbThis(true)}'s last used move can't be mirrored!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        user.pbUseMoveSimple(target.lastRegularMoveUsed, target.index)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        # No animation
    end

    def getEffectScore(_user, _target)
        return 80
    end
end

#===============================================================================
# Uses the last move that was used. (Copycat)
#===============================================================================
class PokeBattle_Move_0AF < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            # Struggle, Chatter, Belch
            "002",   # Struggle
            "014",   # Chatter
            "158",   # Belch                               # Not listed on Bulbapedia
            # Moves that affect the moveset
            "05C",   # Mimic
            "05D",   # Sketch
            "069",   # Transform
            # Counter moves
            "071",   # Counter
            "072",   # Mirror Coat
            "073",   # Metal Burst                         # Not listed on Bulbapedia
            # Helping Hand, Feint (always blacklisted together, don't know why)
            "09C",   # Helping Hand
            "0AD",   # Feint
            # Protection moves
            "0AA",   # Detect, Protect
            "0AB",   # Quick Guard                         # Not listed on Bulbapedia
            "0AC",   # Wide Guard                          # Not listed on Bulbapedia
            "0E8",   # Endure
            "149",   # Mat Block
            "14A",   # Crafty Shield                       # Not listed on Bulbapedia
            "14B",   # King's Shield
            "14C",   # Spiky Shield
            "168",   # Baneful Bunker
            # Moves that call other moves
            "0AE",   # Mirror Move
            "0AF",   # Copycat (this move)
            "0B0",   # Me First
            "0B3",   # Nature Power                        # Not listed on Bulbapedia
            "0B4",   # Sleep Talk
            "0B5",   # Assist
            "0B6",   # Metronome
            # Move-redirecting and stealing moves
            "0B1",   # Magic Coat                          # Not listed on Bulbapedia
            "0B2",   # Snatch
            "117",   # Follow Me, Rage Powder
            "16A",   # Spotlight
            # Set up effects that trigger upon KO
            "0E6",   # Grudge                              # Not listed on Bulbapedia
            "0E7",   # Destiny Bond
            # Held item-moving moves
            "0F1",   # Covet, Thief
            "0F2",   # Switcheroo, Trick
            "0F3",   # Bestow
            # Moves that start focussing at the start of the round
            "115",   # Focus Punch
            "171",   # Shell Trap
            "172",   # Beak Blast
            # Event moves that do nothing
            "133", # Hold Hands
            "134", # Celebrate
        ]
    end

    def pbChangeUsageCounters(user, specialUsage)
        super
        @copied_move = @battle.lastMoveUsed
    end

    def pbMoveFailed?(_user, _targets, show_message)
        unless @copied_move
            @battle.pbDisplay(_INTL("But it failed, since there was no move to copy!")) if show_message
            return true
        end
        if @moveBlacklist.include?(GameData::Move.get(@copied_move).function_code) || 
                @battle.getBattleMoveInstanceFromID(@copied_move).forceSwitchMove?
            @battle.pbDisplay(_INTL("But it failed, since the last used move can't be copied!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbUseMoveSimple(@copied_move)
    end

    def getEffectScore(_user, _target)
        return 80
    end
end

#===============================================================================
# Uses the move the target was about to use this round, with 1.5x power.
# (Me First)
#===============================================================================
class PokeBattle_Move_0B0 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "0F1", # Covet, Thief
            # Struggle, Chatter, Belch
            "002",   # Struggle
            "014",   # Chatter
            "158",   # Belch
            # Counter moves
            "071",   # Counter
            "072",   # Mirror Coat
            "073",   # Metal Burst
            # Moves that start focussing at the start of the round
            "115",   # Focus Punch
            "171",   # Shell Trap
            "172", # Beak Blast
        ]
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
        oppMove = @battle.choices[target.index][2]
        if !oppMove || oppMove.statusMove? || @moveBlacklist.include?(oppMove.function)
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTargetAI?(_user, _target); return false; end

    def pbEffectAgainstTarget(user, target)
        user.applyEffect(:MeFirst)
        user.pbUseMoveSimple(@battle.choices[target.index][2].id)
        user.disableEffect(:MeFirst)
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Me First.")
        return -1000
    end
end

#===============================================================================
# This round, reflects all moves with the "C" flag targeting the user back at
# their origin. (Magic Coat)
#===============================================================================
class PokeBattle_Move_0B1 < PokeBattle_Move
    def pbEffectGeneral(user)
        user.applyEffect(:MagicCoat)
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Magic Coat.")
        return -1000
    end
end

#===============================================================================
# This round, snatches all used moves with the "D" flag. (Snatch)
#===============================================================================
class PokeBattle_Move_0B2 < PokeBattle_Move
    def pbEffectGeneral(user)
        maxSnatch = 0
        @battle.eachBattler do |b|
            next if b.effects[:Snatch] <= maxSnatch
            maxSnatch = b.effects[:Snatch]
        end
        user.applyEffect(:Snatch, maxSnatch + 1)
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Snatch.")
        return -1000
    end
end

#===============================================================================
# Uses a different move depending on the environment. (Nature Power)
# NOTE: This code does not support the Gen 5 and older definition of the move
#       where it targets the user. It makes more sense for it to target another
#       Pokémon.
#===============================================================================
class PokeBattle_Move_0B3 < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def calculateNaturePower
        npMove = :RUIN
        case @battle.field.terrain
        when :Electric
            npMove = :THUNDERBOLT if GameData::Move.exists?(:THUNDERBOLT)
        when :Grassy
            npMove = :ENERGYBALL if GameData::Move.exists?(:ENERGYBALL)
        when :Fairy
            npMove = :MOONBLAST if GameData::Move.exists?(:MOONBLAST)
        when :Psychic
            npMove = :PSYCHIC if GameData::Move.exists?(:PSYCHIC)
        else
            case @battle.environment
            when :Grass, :TallGrass, :Forest, :ForestGrass
                npMove = :ENERGYBALL if GameData::Move.exists?(:ENERGYBALL)
            when :MovingWater, :StillWater, :Underwater
                npMove = :HYDROPUMP if GameData::Move.exists?(:HYDROPUMP)
            when :Puddle
                npMove = :MUDBOMB if GameData::Move.exists?(:MUDBOMB)
            when :Cave
                npMove = :POWERGEM if GameData::Move.exists?(:POWERGEM)
            when :Rock
                npMove = :EARTHPOWER if GameData::Move.exists?(:EARTHPOWER)
            when :Sand
                npMove = :EARTHPOWER if GameData::Move.exists?(:EARTHPOWER)
            when :Snow
                npMove = :FROSTBREATH if GameData::Move.exists?(:FROSTBREATH)
            when :Ice
                npMove = :ICEBEAM if GameData::Move.exists?(:ICEBEAM)
            when :Volcano
                npMove = :LAVAPLUME if GameData::Move.exists?(:LAVAPLUME)
            when :Graveyard
                npMove = :SHADOWBALL if GameData::Move.exists?(:SHADOWBALL)
            when :Sky
                npMove = :AIRSLASH if GameData::Move.exists?(:AIRSLASH)
            when :Space
                npMove = :DRACOMETEOR if GameData::Move.exists?(:DRACOMETEOR)
            when :UltraSpace
                npMove = :PSYSHOCK if GameData::Move.exists?(:PSYSHOCK)
            end
        end
        return npMove
    end

    def pbEffectAgainstTarget(user, target)
        moveToUse = calculateNaturePower
        @battle.pbDisplay(_INTL("{1} turned into {2}!", @name, GameData::Move.get(moveToUse).name))
        user.pbUseMoveSimple(moveToUse, target.index)
    end

    def getEffectScore(user, target)
        pseudoMove = calculateNaturePower
        return @battle.getBattleMoveInstanceFromID(pseudoMove).getEffectScore(user, target)
    end

    def getTargetAffectingEffectScore(user, target)
        pseudoMove = calculateNaturePower
        return @battle.getBattleMoveInstanceFromID(pseudoMove).getTargetAffectingEffectScore(user, target)
    end
end

#===============================================================================
# Uses a random move the user knows. Fails if user is not asleep. (Sleep Talk)
#===============================================================================
class PokeBattle_Move_0B4 < PokeBattle_Move
    def usableWhenAsleep?; return true; end
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "0D1",   # Uproar
            "0D4",   # Bide
            # Struggle, Chatter, Belch
            "002",   # Struggle                            # Not listed on Bulbapedia
            "014",   # Chatter                             # Not listed on Bulbapedia
            "158",   # Belch
            # Moves that affect the moveset (except Transform)
            "05C",   # Mimic
            "05D",   # Sketch
            # Moves that call other moves
            "0AE",   # Mirror Move
            "0AF",   # Copycat
            "0B0",   # Me First
            "0B3",   # Nature Power                        # Not listed on Bulbapedia
            "0B4",   # Sleep Talk
            "0B5",   # Assist
            "0B6",   # Metronome
            # Two-turn attacks
            "0C3",   # Razor Wind
            "0C4",   # Solar Beam, Solar Blade
            "0C5",   # Freeze Shock
            "0C6",   # Ice Burn
            "0C7",   # Sky Attack
            "0C8",   # Skull Bash
            "0C9",   # Fly
            "0CA",   # Dig
            "0CB",   # Dive
            "0CC",   # Bounce
            "0CD",   # Shadow Force
            "0CE",   # Sky Drop
            "12E",   # Shadow Half
            "14D",   # Phantom Force
            "14E",   # Geomancy
            # Moves that start focussing at the start of the round
            "115",   # Focus Punch
            "171",   # Shell Trap
            "172", # Beak Blast
        ]
    end

    def getSleepTalkMoves(user)
        sleepTalkMoves = []
        user.eachMoveWithIndex do |m, i|
            next if @moveBlacklist.include?(m.function)
            next unless @battle.pbCanChooseMove?(user.index, i, false, true)
            sleepTalkMoves.push(i)
        end
        return sleepTalkMoves
    end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.asleep?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} isn't asleep!")) if show_message
            return true
        end
        if getSleepTalkMoves(user).length == 0
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since none of #{user.pbThis(true)}'s moves can be used from Sleep Talk!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        choice = getSleepTalkMoves(user).sample
        user.pbUseMoveSimple(user.moves[choice].id, user.pbDirectOpposing.index)
    end
end

#===============================================================================
# Uses a random move known by any non-user Pokémon in the user's party. (Assist)
#===============================================================================
class PokeBattle_Move_0B5 < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            # Struggle, Chatter, Belch
            "002",   # Struggle
            "014",   # Chatter
            "158",   # Belch
            # Moves that affect the moveset
            "05C",   # Mimic
            "05D",   # Sketch
            "069",   # Transform
            # Counter moves
            "071",   # Counter
            "072",   # Mirror Coat
            "073",   # Metal Burst                         # Not listed on Bulbapedia
            # Helping Hand, Feint (always blacklisted together, don't know why)
            "09C",   # Helping Hand
            "0AD",   # Feint
            # Protection moves
            "0AA",   # Detect, Protect
            "0AB",   # Quick Guard                         # Not listed on Bulbapedia
            "0AC",   # Wide Guard                          # Not listed on Bulbapedia
            "0E8",   # Endure
            "149",   # Mat Block
            "14A",   # Crafty Shield                       # Not listed on Bulbapedia
            "14B",   # King's Shield
            "14C",   # Spiky Shield
            "168",   # Baneful Bunker
            # Moves that call other moves
            "0AE",   # Mirror Move
            "0AF",   # Copycat
            "0B0",   # Me First
            #       "0B3",   # Nature Power                                      # See below
            "0B4",   # Sleep Talk
            "0B5",   # Assist
            "0B6",   # Metronome
            # Move-redirecting and stealing moves
            "0B1",   # Magic Coat                          # Not listed on Bulbapedia
            "0B2",   # Snatch
            "117",   # Follow Me, Rage Powder
            "16A",   # Spotlight
            # Set up effects that trigger upon KO
            "0E6",   # Grudge                              # Not listed on Bulbapedia
            "0E7",   # Destiny Bond
            # Held item-moving moves
            "0F1",   # Covet, Thief
            "0F2",   # Switcheroo, Trick
            "0F3",   # Bestow
            # Moves that start focussing at the start of the round
            "115",   # Focus Punch
            "171",   # Shell Trap
            "172",   # Beak Blast
            # Event moves that do nothing
            "133", # Hold Hands
            "134", # Celebrate
            # Moves that call other moves
            "0B3", # Nature Power
        ]
    end

    def getAssistMoves(user)
        assistMoves = []
        @battle.pbParty(user.index).each_with_index do |pkmn, i|
            next if !pkmn || i == user.pokemonIndex
            next if pkmn.egg?
            pkmn.moves.each do |move|
                next if @moveBlacklist.include?(move.function_code)
                next if move.type == :SHADOW
                battleMoveInstance = @battle.getBattleMoveInstanceFromID(move.id)
                next if battleMoveInstance.forceSwitchMove?
                next if battleMoveInstance.is_a?(PokeBattle_TwoTurnMove)
                assistMoves.push(move.id)
            end
        end
        return assistMoves
    end

    def pbMoveFailed?(user, _targets, show_message)
        if getAssistMoves(user).length == 0
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since there are no moves #{user.pbThis(true)} can use!"))
            end
            return true
        end
        
        return false
    end

    def pbEffectGeneral(user)
        move = getAssistMoves(user).sample
        user.pbUseMoveSimple(move)
    end
end

#===============================================================================
# Uses a random move that exists. (Metronome)
#===============================================================================
class PokeBattle_Move_0B6 < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "011",   # Snore
            "11D",   # After You
            "11E",   # Quash
            "09C",   # Helping Hand
            # Move-redirecting and stealing moves
            "0B1",   # Magic Coat
            "0B2",   # Snatch
            "117",   # Follow Me, Rage Powder
            "16A",   # Spotlight
            # Held item-moving moves
            "0F1",   # Covet, Thief
            "0F2",   # Switcheroo, Trick
            "0F3",   # Bestow
            # Event moves that do nothing
            "133", # Hold Hands
            "134", # Celebrate
            # Z-moves
            "Z000",
        ]

        @metronomeMoves = []
        GameData::Move::DATA.keys.each do |move_id|
            move_data = GameData::Move.get(move_id)
            break if move_data.id_number >= 2000
            next if move_data.is_signature?
            next unless move_data.can_be_forced?
            next if move_data.type == :SHADOW
            next if @moveBlacklist.include?(move_data.function_code)
            next if move_data.empoweredMove?
            next if @battle.getBattleMoveInstanceFromID(move_id).is_a?(PokeBattle_ProtectMove)
            @metronomeMoves.push(move_data.id)
        end
    end

    def pbMoveFailed?(_user, _targets, show_message)
        if @metronomeMoves.empty?
            @battle.pbDisplay(_INTL("But it failed, since there are no moves to use!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        choice = @metronomeMoves.sample
        user.pbUseMoveSimple(choice)
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Metronome")
        return -1000
    end
end

#===============================================================================
# The target can no longer use the same move twice in a row. (Torment)
#===============================================================================
class PokeBattle_Move_0B7 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Torment)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already tormented!"))
            end
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Torment)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        score = 60
        score += 40 unless target.hasDamagingAttack?
        return score
    end
end

#===============================================================================
# Disables all target's moves that the user also knows. (Imprison)
#===============================================================================
class PokeBattle_Move_0B8 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:Imprison)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s is already imprisoning shared moves!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:Imprison)
    end

    def getTargetAffectingEffectScore(_user, _target)
        echoln("The AI will never use Imprison.")
        return -1000
    end
end

#===============================================================================
# For 5 rounds, disables the last move the target used. (Disable)
#===============================================================================
class PokeBattle_Move_0B9 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Disable)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} already has a move disabled!"))
            end
            return true
        end
        unless target.lastRegularMoveUsed
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} hasn't used a move yet!"))
            end
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        canDisable = false
        target.eachMove do |m|
            next if m.id != target.lastRegularMoveUsed
            next if m.pp == 0 && m.total_pp > 0
            canDisable = true
            break
        end
        unless canDisable
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s last used move has no more PP!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Disable, 5)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        score = 70
        score += 30 if @battle.pbIsTrapped?(target.index)
        return score
    end
end

#===============================================================================
# For 4 rounds, disables the target's non-damaging moves. (Taunt)
#===============================================================================
class PokeBattle_Move_0BA < PokeBattle_Move
    def ignoresSubstitute?(_user); return statusMove?; end

    def initialize(battle, move)
        super
        @tauntTurns = 4
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if target.effectActive?(:Taunt)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already taunted!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        return if damagingMove?
        target.applyEffect(:Taunt, @tauntTurns)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        return if target.effectActive?(:Taunt)
        return true if pbMoveFailedAromaVeil?(user, target)
        target.applyEffect(:Taunt, @tauntTurns)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.substituted? && statusMove?
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        return 0 unless target.hasStatusMove?
        score = 20
        score += getSetupLikelihoodScore(target) { |move|
            next !move.statusMove?
        }
        score += getHazardLikelihoodScore(target) { |move|
            next !move.statusMove?
        }
        return score
    end
end

#===============================================================================
# For 5 rounds, disables the target's healing moves. (Heal Block)
#===============================================================================
class PokeBattle_Move_0BB < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:HealBlock)
            @battle.pbDisplay(_INTL("But it failed, since the target's healing is already blocked!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:HealBlock, 5)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        return 0 unless target.hasHealingMove?
        return 40
    end
end

#===============================================================================
# For 4 rounds, the target must use the same move each round. (Encore)
#===============================================================================
class PokeBattle_Move_0BC < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "0BC", # Encore
            # Struggle
            "002", # Struggle
            # Moves that affect the moveset
            "05C",   # Mimic
            "05D",   # Sketch
            "069",   # Transform
            # Moves that call other moves
            "0AE", # Mirror Move
            "0AF",   # Copycat
            "0B0",   # Me First
            "0B3",   # Nature Power
            "0B4",   # Sleep Talk
            "0B5",   # Assist
            "0B6", # Metronome
        ]
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Encore)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already locked into an encore!")) if show_message
            return true
        end
        unless target.lastRegularMoveUsed
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} hasn't used a move yet!")) if show_message
            return true
        end
        if @moveBlacklist.include?(GameData::Move.get(target.lastRegularMoveUsed).function_code)
            @battle.pbDisplay(_INTL("But it failed, since {1} can't be locked into {2}!",
                  target.pbThis(true), GameData::Move.get(target.lastRegularMoveUsed).real_name)) if show_message
            return true
        end
        if target.effectActive?(:ShellTrap)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is setting a Shell Trap!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        canEncore = false
        target.eachMove do |m|
            next if m.id != target.lastRegularMoveUsed
            next if m.pp == 0 && m.total_pp > 0
            canEncore = true
            break
        end
        unless canEncore
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} last used move has no more PP!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Encore, 4)
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        score = 60
        score += 40 if @battle.pbIsTrapped?(target.index)
        userSpeed = user.pbSpeed(true)
        targetSpeed = target.pbSpeed(true)
        if userSpeed > targetSpeed
            return 0 if target.lastRegularMoveUsed.nil?
            moveData = GameData::Move.get(target.lastRegularMoveUsed)
            if moveData.category == 2 && %i[User BothSides].include?(moveData.target)
                score += 100
            elsif moveData.category != 2 && moveData.target == :NearOther &&
                  Effectiveness.ineffective?(pbCalcTypeMod(moveData.type, target, user))
                score += 100
            end
        end
        return score
    end
end

#===============================================================================
# Hits twice.
#===============================================================================
class PokeBattle_Move_0BD < PokeBattle_Move
    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 2; end
end

#===============================================================================
# Hits twice. May poison the target on each hit. (Twineedle)
#===============================================================================
class PokeBattle_Move_0BE < PokeBattle_PoisonMove
    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 2; end
end

#===============================================================================
# Hits 3 times. Power is multiplied by the hit number. (Triple Kick)
# An accuracy check is performed for each hit.
#===============================================================================
class PokeBattle_Move_0BF < PokeBattle_Move
    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 3; end

    def successCheckPerHit?
        return @accCheckPerHit
    end

    def pbOnStartUse(user, _targets)
        @calcBaseDmg = 0
        @accCheckPerHit = !user.hasActiveAbility?(:SKILLLINK)
    end

    def pbBaseDamage(baseDmg, _user, target)
        @calcBaseDmg += baseDmg if !target.damageState.disguise || !target.damageState.iceface
        return @calcBaseDmg
    end

    def shouldHighlight?(_user, _target); return false; end

    def pbBaseDamageAI(baseDmg, _user, _target)
        return baseDmg * 2
    end
end

#===============================================================================
# Hits 2-5 times.
#===============================================================================
class PokeBattle_Move_0C0 < PokeBattle_Move
    def multiHitMove?; return true; end

    def pbNumHits(user, _targets, _checkingForAI = false)
        return 3 if @id == :WATERSHURIKEN && user.isSpecies?(:GRENINJA) && user.form == 2
        if user.hasActiveItem?(:LOADEDDICE)
            hitChances = [3, 3, 4, 4, 5, 5]
        else
            hitChances = [2, 2, 3, 3, 4, 5]
        end
        if user.hasActiveAbility?(:SKILLLINK)
            numHits = hitChances.last
        else
            numHits = hitChances.sample
        end
        return numHits
    end

    def pbNumHitsAI(user, _targets)
        return 3 if @id == :WATERSHURIKEN && user.isSpecies?(:GRENINJA) && user.form == 2
        return 5 if user.hasActiveAbilityAI?(:SKILLLINK)
        return 4 if user.hasActiveItem?(:LOADEDDICE)
        return 19.0 / 6.0 # Average
    end

    def pbBaseDamage(baseDmg, user, target)
        return 20 if @id == :WATERSHURIKEN && user.isSpecies?(:GRENINJA) && user.form == 2
        super
    end
end

#===============================================================================
# Hits X times, where X is the number of non-user unfainted status-free Pokémon
# in the user's party (not including partner trainers). Fails if X is 0.
# Base power of each hit depends on the base Attack stat for the species of that
# hit's participant. (Beat Up)
#===============================================================================
class PokeBattle_Move_0C1 < PokeBattle_Move
    def multiHitMove?; return true; end

    def calculateBeatUpList(user)
        @beatUpList = []
        @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, i|
            next if !pkmn.able? || pkmn.status != :NONE
            @beatUpList.push(i)
        end
    end

    def pbMoveFailed?(user, _targets, show_message)
        calculateBeatUpList(user)
        if @beatUpList.length == 0
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since has no party members on #{user.pbTeam(true)} who can join in!"))
            end
            return true
        end
        return false
    end

    def pbNumHits(user, _targets, _checkingForAI = false)
        calculateBeatUpList(user) if @beatUpList.empty?
        return @beatUpList.length
    end

    def baseDamageFromAttack(attack)
        return 5 + (attack / 10)
    end

    def pbBaseDamage(_baseDmg, user, _target)
        i = @beatUpList.shift # First element in array, and removes it from array
        attack = @battle.pbParty(user.index)[i].baseStats[:ATTACK]
        return baseDamageFromAttack(attack)
    end

    def pbBaseDamageAI(_baseDmg, user, _target)
        calculateBeatUpList(user) if @beatUpList.empty?
        totalAttack = 0
        @beatUpList.each do |i|
            totalAttack += @battle.pbParty(user.index)[i].baseStats[:ATTACK]
        end
        return baseDamageFromAttack(totalAttack / @beatUpList.length)
    end
end

#===============================================================================
# Two turn attack. Attacks first turn, skips second turn (if successful).
#===============================================================================
class PokeBattle_Move_0C2 < PokeBattle_Move
    def pbEffectGeneral(user)
        if user.hasActiveItem?(:ENERGYHERB)
            @battle.pbCommonAnimation("UseItem", user)
            @battle.pbDisplay(_INTL("{1} skipped exhaustion due to its Energy Herb!", user.pbThis))
            user.consumeItem(:ENERGYHERB)
        else
            user.applyEffect(:HyperBeam, 2)
        end
    end

    def getEffectScore(user, _target)
        return -40 unless user.hasActiveItem?(:ENERGYHERB)
        return 0
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Razor Wind)
#===============================================================================
class PokeBattle_Move_0C3 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} whipped up a whirlwind!", user.pbThis))
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. In sunshine, takes 1 turn instead. (Solar Beam, Solar Blade)
#===============================================================================
class PokeBattle_Move_0C4 < PokeBattle_TwoTurnMove
    def immuneToSunDebuff?; return true; end

    def pbIsChargingTurn?(user)
        ret = super
        if !user.effectActive?(:TwoTurnAttack) && @battle.sunny?
            @powerHerb = false
            @chargingTurn = true
            @damagingTurn = true
            return false
        end
        return ret
    end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} took in sunlight!", user.pbThis))
    end

    def getEffectScore(user, target)
        score = super
        score += 50 if @battle.sunny?
        return score
    end

    def shouldHighlight?(_user, _target)
        return @battle.sunny?
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Freeze Shock)
# May paralyze the target.
#===============================================================================
class PokeBattle_Move_0C5 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} became cloaked in a freezing light!", user.pbThis))
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyNumb(user) if target.canNumb?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getNumbEffectScore(user, target)
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Ice Burn)
# May burn the target.
#===============================================================================
class PokeBattle_Move_0C6 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} became cloaked in freezing air!", user.pbThis))
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyBurn(user) if target.canBurn?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getBurnEffectScore(user, target)
    end
end

#===============================================================================
# For 4 rounds, disables the target's off-type moves. (Bar)
#===============================================================================
class PokeBattle_Move_0C7 < PokeBattle_Move
    def ignoresSubstitute?(_user); return statusMove?; end

    def initialize(battle, move)
        super
        @barredTurns = 4
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if target.effectActive?(:Barred)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already barred!")) if show_message
            return true
        end
        return true if pbMoveFailedAromaVeil?(user, target, show_message)
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        return if damagingMove?
        target.applyEffect(:Barred, @tauntTurns)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        return if target.effectActive?(:Barred)
        return true if pbMoveFailedAromaVeil?(user, target)
        target.applyEffect(:Barred, @tauntTurns)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.substituted? && statusMove?
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        return 0 unless target.hasOffTypeMove?
        return 80
    end
end

#===============================================================================
# Two turn attack. Ups user's Defense by 4 steps first turn, attacks second turn.
# (Skull Bash)
#===============================================================================
class PokeBattle_Move_0C8 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} tucked in its head!", user.pbThis))
    end

    def pbChargingTurnEffect(user, _target)
        user.tryRaiseStat(:DEFENSE, user, increment: 4, move: self)
    end

    def getEffectScore(user, target)
        score = super
        score += getMultiStatUpEffectScore([:DEFENSE, 2], user, user)
        return score
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Fly)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_0C9 < PokeBattle_TwoTurnMove
    def unusableInGravity?; return true; end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} flew up high!", user.pbThis))
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Dig, Undermine)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_0CA < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} burrowed its way under the ground!", user.pbThis))
    end

    def pbIsChargingTurn?(user)
        ret = super
        if !user.effectActive?(:TwoTurnAttack) && user.hasActiveAbility?(:BURROWER)
            @powerHerb = false
            @chargingTurn = true
            @damagingTurn = true
            return false
        end
        return ret
    end

    def canBecomeReaper?(user)
        return @battle.sandy? && user.species == :GARCHOMP && user.hasActiveAbility?(:DUNEPREDATOR) && user.form == 0
    end

    def pbAttackingTurnMessage(user, targets)
        if canBecomeReaper?(user)
            @battle.pbDisplay(_INTL("The ground rumbles violently underneath {1}!", targets[0].pbThis))
            @battle.pbAnimation(:EARTHQUAKE, targets[0], targets, 0)
            user.pbChangeForm(1, _INTL("The Reaper appears!", user.pbThis))
        end
    end

    def getEffectScore(user, _target)
        return 50 if canBecomeReaper?(user)
        return 0
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Dive, Depth Charge)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_0CB < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} hid underwater!", user.pbThis))
        if user.canGulpMissile?
            user.form = 2
            user.form = 1 if user.hp > (user.totalhp / 2)
            @battle.scene.pbChangePokemon(user, user.pokemon)
        end
    end

    def getEffectScore(user, _target)
        return 40 if user.canGulpMissile?
        return 0
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Bounce)
# May numb the target.
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_0CC < PokeBattle_TwoTurnMove
    def unusableInGravity?; return true; end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} sprang up!", user.pbThis))
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyNumb(user) if target.canNumb?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getNumbEffectScore(user, target)
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Shadow Force)
# Is invulnerable during use. Ends target's protections upon hit.
#===============================================================================
class PokeBattle_Move_0CD < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} vanished instantly!", user.pbThis))
    end

    def pbAttackingTurnEffect(_user, target)
        removeProtections(target)
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Sky Drop)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
# Target is also semi-invulnerable during use, and can't take any action.
# Doesn't damage airborne Pokémon (but still makes them unable to move during).
#===============================================================================
class PokeBattle_Move_0CE < PokeBattle_TwoTurnMove
    def unusableInGravity?; return true; end

    def pbIsChargingTurn?(user)
        # NOTE: Sky Drop doesn't benefit from Power Herb, probably because it works
        #       differently (i.e. immobilises the target during use too).
        @powerHerb = false
        @chargingTurn = !user.effectActive?(:TwoTurnAttack)
        @damagingTurn = user.effectActive?(:TwoTurnAttack)
        return !@damagingTurn
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.opposes?(user)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} isn't an opponent!")) if show_message
            return true
        end
        if target.substituted? && !ignoresSubstitute?(user)
            @battle.pbDisplay(_INTL("#{target.pbThis} is protected by its Substitute!")) if show_message
            return true
        end
        if target.semiInvulnerable? || (target.effectActive?(:SkyDrop) && @chargingTurn)
            @battle.pbDisplay(_INTL("But it missed!")) if show_message
            return true
        end
        if !target.pointsAt?(:SkyDrop, user) && @damagingTurn
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already using Sky Drop on #{user.pbThis(true)}!"))
            end
            return true
        end
        return false
    end

    def pbCalcTypeMod(movetype, user, target)
        return Effectiveness::INEFFECTIVE if target.pbHasType?(:FLYING)
        return super
    end

    def pbChargingTurnMessage(user, targets)
        @battle.pbDisplay(_INTL("{1} took {2} into the sky!", user.pbThis, targets[0].pbThis(true)))
    end

    def pbAttackingTurnMessage(_user, targets)
        @battle.pbDisplay(_INTL("{1} was freed from the Sky Drop!", targets[0].pbThis))
    end

    def pbChargingTurnEffect(user, target)
        target.pointAt(:SkyDrop, user)
    end

    def pbAttackingTurnEffect(_user, target)
        target.disableEffect(:SkyDrop)
    end
end

#===============================================================================
# Trapping move. Traps for 3 or 6 rounds. Trapped Pokémon lose 1/16 of max HP
# at end of each round.
#===============================================================================
class PokeBattle_Move_0CF < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        return if target.fainted? || target.damageState.substitute
        return if target.effectActive?(:Trapping)
        # Set trapping effect duration and info
        trappingDuration = 3
        trappingDuration *= 2 if user.hasActiveItem?(:GRIPCLAW)
        target.applyEffect(:Trapping, trappingDuration)
        target.applyEffect(:TrappingMove, @id)
        target.pointAt(:TrappingUser, user)
        # Message
        msg = _INTL("{1} was trapped!", target.pbThis)
        case @id
        when :BIND, :VINEBIND, :BEARHUG
            msg = _INTL("{1} was squeezed by {2}!", target.pbThis, user.pbThis(true))
        when :CLAMP, :SLAMSHUT
            msg = _INTL("{1} clamped {2}!", user.pbThis, target.pbThis(true))
        when :FIRESPIN, :CRIMSONSTORM
            msg = _INTL("{1} was trapped in the fiery vortex!", target.pbThis)
        when :INFESTATION,:TERRORSWARM
            msg = _INTL("{1} has been afflicted with an infestation by {2}!", target.pbThis, user.pbThis(true))
        when :MAGMASTORM
            msg = _INTL("{1} became trapped by Magma Storm!", target.pbThis)
        when :SANDTOMB, :SANDVORTEX
            msg = _INTL("{1} became trapped by Sand Tomb!", target.pbThis)
        when :WHIRLPOOL, :MAELSTROM
            msg = _INTL("{1} became trapped in the vortex!", target.pbThis)
        when :WRAP, :KRAKENCLUTCHES
            msg = _INTL("{1} was wrapped by {2}!", target.pbThis, user.pbThis(true))
        end
        @battle.pbDisplay(msg)
    end

    def getEffectScore(_user, target)
        return 0 if target.effectActive?(:Trapping) || target.substituted?
        return 40
    end
end

#===============================================================================
# For 2 rounds, disables the target's non-damaging moves. (Docile Mask)
#===============================================================================
class PokeBattle_Move_0D0 < PokeBattle_Move_0BA
    def initialize(battle, move)
        super
        @tauntTurns = 2
    end
end

#===============================================================================
# User must use this move for 2 more rounds. No battlers can sleep. (Uproar)
# NOTE: Bulbapedia claims that an uproar will wake up Pokémon even if they have
#       Soundproof, and will not allow Pokémon to fall asleep even if they have
#       Soundproof. I think this is an oversight, so I've let Soundproof Pokémon
#       be unaffected by Uproar waking/non-sleeping effects.
#===============================================================================
class PokeBattle_Move_0D1 < PokeBattle_Move
    def pbEffectGeneral(user)
        return if user.effectActive?(:Uproar)
        user.applyEffect(:Uproar, 3)
        user.currentMove = @id
    end

    def getEffectScore(_user, _target)
        return -20
    end
end

#===============================================================================
# (No longer used)
#===============================================================================
class PokeBattle_Move_0D2 < PokeBattle_Move
end

#===============================================================================
# (No longer used)
#===============================================================================
class PokeBattle_Move_0D3 < PokeBattle_Move
end

#===============================================================================
# User bides its time this round and next round. The round after, deals 2x the
# total direct damage it took while biding to the last battler that damaged it.
# (Bide)
#===============================================================================
class PokeBattle_Move_0D4 < PokeBattle_FixedDamageMove
    def pbAddTarget(targets, user)
        return if user.effects[:Bide] != 1 # Not the attack turn
        target = user.getBattlerPointsTo(:BideTarget)
        unless user.pbAddTarget(targets, user, target, self, false)
            user.pbAddTargetRandomFoe(targets, user, self, false)
        end
    end

    def pbMoveFailed?(user, targets, show_message)
        return false if user.effects[:Bide] != 1 # Not the attack turn
        if user.effects[:BideDamage] == 0
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} hasn't absorbed any energy!"))
            end
            user.disableEffect(:Bide)
            return true
        end
        if targets.length == 0
            @battle.pbDisplay(_INTL("But there was no target...")) if show_message
            user.disableEffect(:Bide)
            return true
        end
        return false
    end

    def pbOnStartUse(user, _targets)
        @damagingTurn = (user.effects[:Bide] == 1) # If attack turn
    end

    def pbDisplayUseMessage(user, targets)
        if user.effects[:Bide] == 1 # Attack turn
            @battle.pbDisplayBrief(_INTL("{1} unleashed energy!", user.pbThis))
        elsif user.effectActive?(:Bide)
            @battle.pbDisplayBrief(_INTL("{1} is storing energy!", user.pbThis))
        else
            super # Start using Bide
        end
    end

    def damagingMove?(aiChecking = false)
        if aiChecking
            return super
        else
            return false unless @damagingTurn
            return super
        end
    end

    def pbFixedDamage(user, _target)
        return user.effects[:BideDamage] * 2
    end

    def pbEffectGeneral(user)
        unless user.effectActive?(:Bide)
            user.applyEffect(:Bide, 3)
            user.currentMove = @id
        end
        user.effects[:Bide] -= 1
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        hitNum = 1 unless @damagingTurn # Charging anim
        super
    end

    def pbBaseDamageAI(_baseDmg, _user, _target)
        return 60
    end

    def getEffectScore(user, _target)
        if user.belowHalfHealth?
            return 0
        else
            return 100
        end
    end
end

#===============================================================================
# Heals user by 1/2 of its max HP.
#===============================================================================
class PokeBattle_Move_0D5 < PokeBattle_HalfHealingMove
end

#===============================================================================
# Heals user by 1/2 of its max HP. (Roost)
# User roosts, and its Flying type is ignored for attacks used against it.
#===============================================================================
class PokeBattle_Move_0D6 < PokeBattle_HalfHealingMove
    def pbEffectGeneral(user)
        super
        user.applyEffect(:Roost)
    end
end

#===============================================================================
# Battler in user's position is healed by 1/2 of its max HP, at the end of the
# next round. (Wish)
#===============================================================================
class PokeBattle_Move_0D7 < PokeBattle_Move
    def healingMove?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if user.position.effectActive?(:Wish)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since a Wish is already about to come true for #{user.pbThis(true)}!"))
            end
            return true
        end
        return false
    end

    def wishAmount(user)
        return (user.totalhp / 2.0).round
    end

    def pbEffectGeneral(user)
        user.position.applyEffect(:Wish, 2)
        user.position.applyEffect(:WishAmount, wishAmount(user))
        user.position.applyEffect(:WishMaker, user.pokemonIndex)
    end

    def getEffectScore(user, _target)
        return (user.totalhp / user.level) * 30
    end
end

#===============================================================================
# Heals user by an amount depending on the weather. (Morning Sun, Synthesis)
#===============================================================================
class PokeBattle_Move_0D8 < PokeBattle_HealingMove
    def healRatio(_user)
        if @battle.sunny?
            return 2.0 / 3.0
        else
            return 1.0 / 2.0
        end
    end

    def shouldHighlight?(_user, _target)
        return @battle.sunny?
    end
end

#===============================================================================
# Heals user to full HP. User falls asleep for 2 more rounds. (Rest)
#===============================================================================
class PokeBattle_Move_0D9 < PokeBattle_HealingMove
    def healRatio(_user); return 1.0; end

    def pbMoveFailed?(user, targets, show_message)
        if user.asleep?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already asleep!")) if show_message
            return true
        end
        return true unless user.canSleep?(user, show_message, self, true)
        return true if super
        return false
    end

    def pbEffectGeneral(user)
        user.applySleepSelf(_INTL("{1} slept and became healthy!", user.pbThis), 3)
        super
    end

    def getEffectScore(user, target)
        score = super
        score -= getSleepEffectScore(user, target)
        return score
    end
end

#===============================================================================
# Rings the user. Ringed Pokémon gain 1/16 of max HP at the end of each round.
# (Aqua Ring)
#===============================================================================
class PokeBattle_Move_0DA < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if user.effectActive?(:AquaRing)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already veiled with water!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        user.applyEffect(:AquaRing)
    end

    def pbEffectAfterAllHits(user, _target)
        return unless damagingMove?
        user.applyEffect(:AquaRing)
    end

    def getEffectScore(user, _target)
        return 0 if user.effectActive?(:AquaRing)
        score = 70
        score += 30 if user.firstTurn?
        return score
    end
end

#===============================================================================
# Ingrains the user. Ingrained Pokémon gain 1/16 of max HP at the end of each
# round, and cannot flee or switch out. (Ingrain)
#===============================================================================
class PokeBattle_Move_0DB < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:Ingrain)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s roots are already planted!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:Ingrain)
    end

    def getEffectScore(user, _target)
        score = 50
        score += 30 if @battle.pbIsTrapped?(user.index)
        score += 20 if user.firstTurn?
        score += 20 if user.aboveHalfHealth?
        return score
    end
end

#===============================================================================
# Seeds the target. Seeded Pokémon lose 1/8 of max HP at the end of each round,
# and the Pokémon in the user's position gains the same amount. (old!Leech Seed)
#===============================================================================
class PokeBattle_Move_0DC < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.effectActive?(:LeechSeed)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} was already seeded!")) if show_message
            return true
        end
        if target.pbHasType?(:GRASS)
            if show_message
                @battle.pbDisplay(_INTL("It doesn't affect {1} since it's a Grass-type...",
  target.pbThis(true)))
            end
            return true
        end
        return false
    end

    def pbMissMessage(_user, target)
        @battle.pbDisplay(_INTL("{1} evaded the attack!", target.pbThis))
        return true
    end

    def pbEffectAgainstTarget(user, target)
        target.pointAt(:LeechSeed, user)
    end

    def getEffectScore(user, _target)
        score = 100
        score += 20 if user.firstTurn?
        return score
    end
end

#===============================================================================
# User gains half the HP it inflicts as damage.
#===============================================================================
class PokeBattle_Move_0DD < PokeBattle_DrainMove
    def drainFactor(_user, _target); return 0.5; end
end

#===============================================================================
# User gains half the HP it inflicts as damage. Deals double damage if the target is asleep.
# (Dream Absorb)
#===============================================================================
class PokeBattle_Move_0DE < PokeBattle_DrainMove
    def drainFactor(_user, _target); return 0.5; end

    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.asleep?
        return baseDmg
    end
end

#===============================================================================
# Heals target by 1/2 of its max HP. (Heal Pulse)
#===============================================================================
class PokeBattle_Move_0DF < PokeBattle_Move
    def healingMove?; return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.hp == target.totalhp
            @battle.pbDisplay(_INTL("{1}'s HP is full!", target.pbThis)) if show_message
            return true
        elsif !target.canHeal?
            @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        if pulseMove? && user.hasActiveAbility?(:MEGALAUNCHER)
            ratio = 3.0 / 4.0
        else
            ratio = 1.0 / 2.0
        end
        target.applyFractionalHealing(ratio)
    end

    def getEffectScore(user, target)
        return getHealingEffectScore(user, target)
    end
end

#===============================================================================
# User faints, even if the move does nothing else. (Explosion, Self-Destruct)
#===============================================================================
class PokeBattle_Move_0E0 < PokeBattle_Move
    def worksWithNoTargets?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 1; end

    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.moldBreaker
            dampHolder = @battle.pbCheckGlobalAbility(:DAMP)
            unless dampHolder.nil?
                if show_message
                    @battle.pbShowAbilitySplash(dampHolder, :DAMP)
                    @battle.pbDisplay(_INTL("{1} cannot use {2}!", user.pbThis, @name))
                    @battle.pbHideAbilitySplash(dampHolder)
                end
                return true
            end
        end
        return false
    end

    def shouldShade?(_user, _target)
        return false
    end

    def pbMoveFailedAI?(_user, _targets); return false; end

    def pbSelfKO(user)
        return if user.fainted?

        if user.hasActiveAbility?(:SPINESPLODE)
            spikesCount = user.pbOpposingSide.incrementEffect(:Spikes, GameData::BattleEffect.get(:Spikes).maximum)
            
            if spikesCount > 0
                @battle.pbShowAbilitySplash(user, :SPINESPLODE)
                @battle.pbDisplay(_INTL("#{spikesCount} layers of Spikes were scattered all around #{user.pbOpposingTeam(true)}'s feet!"))
                @battle.pbHideAbilitySplash(user)
            end
        end

        if user.bunkeringDown?
            @battle.pbShowAbilitySplash(user, :BUNKERDOWN)
            @battle.pbDisplay(_INTL("{1}'s {2} barely saves it!", user.pbThis, @name))
            user.pbReduceHP(user.hp - 1, false)
            @battle.pbHideAbilitySplash(user)
        else
            reduction = user.totalhp
            unbreakable = user.hasActiveAbility?(:UNBREAKABLE)
            if unbreakable
                @battle.pbShowAbilitySplash(user, :UNBREAKABLE)
                @battle.pbDisplay(_INTL("{1} resists the recoil!", user.pbThis))
                reduction /= 2
            end
            user.pbReduceHP(reduction, false)
            @battle.pbHideAbilitySplash(user) if unbreakable
            if user.hasActiveAbility?(:SELFMENDING,true)
                @battle.pbShowAbilitySplash(user, :SELFMENDING)
                @battle.pbDisplay(_INTL("{1} will revive in 3 turns!", user.pbThis))
                if user.pbOwnSide.effectActive?(:SelfMending)
                    user.pbOwnSide.effects[:SelfMending][user.pokemonIndex] = 4
                else
                    user.pbOwnSide.effects[:SelfMending] = {
                        user.pokemonIndex => 4,
                    }
                end
                @battle.pbHideAbilitySplash(user)
            end
        end
        user.pbItemHPHealCheck
    end

    def getEffectScore(user, target)
        score = getSelfKOMoveScore(user, target)
        score += 20 if user.bunkeringDown?(true)
        return score
    end
end

#===============================================================================
# Inflicts fixed damage equal to user's current HP. (Final Gambit)
# User faints (if successful).
#===============================================================================
class PokeBattle_Move_0E1 < PokeBattle_FixedDamageMove
    def pbNumHits(_user, _targets, _checkingForAI = false); return 1; end

    def pbOnStartUse(user, _targets)
        @finalGambitDamage = user.hp
    end

    def pbFixedDamage(_user, _target)
        return @finalGambitDamage
    end

    def pbBaseDamageAI(_baseDmg, user, _target)
        return user.hp
    end

    def pbSelfKO(user)
        return if user.fainted?
        user.pbReduceHP(user.hp, false)
        user.pbItemHPHealCheck
    end

    def getEffectScore(user, target)
        score = getSelfKOMoveScore(user, target)
        return score
    end
end

#===============================================================================
# Target's attacking stats are lowered by 5 steps. User faints. (Memento)
#===============================================================================
class PokeBattle_Move_0E2 < PokeBattle_TargetMultiStatDownMove
    def worksWithNoTargets?; return true; end

    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 5, :SPECIAL_ATTACK, 5]
    end

    def pbSelfKO(user)
        return if user.fainted?
        user.pbReduceHP(user.totalhp, false)
        user.pbItemHPHealCheck
    end
    
    def getEffectScore(user, target)
        score = getSelfKOMoveScore(user, target)
        return score
    end
end

#===============================================================================
# User faints. The Pokémon that replaces the user is fully healed (HP and
# status). Fails if user won't be replaced. (Healing Wish)
#===============================================================================
class PokeBattle_Move_0E3 < PokeBattle_Move
    def healingMove?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.pbCanChooseNonActive?(user.index)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no party allies to replace it!"))
            end
            return true
        end
        return false
    end

    def pbSelfKO(user)
        return if user.fainted?
        user.pbReduceHP(user.hp, false)
        user.pbItemHPHealCheck
        user.position.applyEffect(:HealingWish)
    end

    def getEffectScore(user, target)
        score = 80
        score += getSelfKOMoveScore(user, target)
        return score
    end
end

#===============================================================================
# User faints. The Pokémon that replaces the user is fully healed (HP, PP and
# status). Fails if user won't be replaced. (Lunar Dance)
#===============================================================================
class PokeBattle_Move_0E4 < PokeBattle_Move
    def healingMove?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.pbCanChooseNonActive?(user.index)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no party allies to replace it!"))
            end
            return true
        end
        return false
    end

    def pbSelfKO(user)
        return if user.fainted?
        user.pbReduceHP(user.hp, false)
        user.pbItemHPHealCheck
        user.position.applyEffect(:LunarDance)
    end

    def getEffectScore(user, target)
        score = 90
        score += getSelfKOMoveScore(user, target)
        return score
    end
end

#===============================================================================
# All current battlers will perish after 3 more rounds. (Perish Song)
#===============================================================================
class PokeBattle_Move_0E5 < PokeBattle_Move
    def pbMoveFailed?(_user, targets, show_message)
        failed = true
        targets.each do |b|
            next if b.effectActive?(:PerishSong)
            failed = false
            break
        end
        if failed
            @battle.pbDisplay(_INTL("But it failed, since everyone has heard the song already!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, _show_message)
        return target.effectActive?(:PerishSong)
    end

    def pbEffectAgainstTarget(user, target)
        if target.boss?
            target.applyEffect(:PerishSong, 12)
        else
            target.applyEffect(:PerishSong, 3)
        end
    end

    def getEffectScore(user, _target)
        return 0 unless user.alliesInReserve?
        return 60
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_0E6 < PokeBattle_Move
end

#===============================================================================
# If user is KO'd before it next moves, the battler that caused it also faints.
# (Destiny Bond)
#===============================================================================
class PokeBattle_Move_0E7 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:DestinyBondPrevious)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} was already waiting to take down others with it!"))
            end
            return true
        end
        if @battle.bossBattle?
            @battle.pbDisplay(_INTL("But it failed in the presence of an Avatar!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:DestinyBond)
        @battle.pbDisplay(_INTL("{1} is hoping to take its attacker down with it!", user.pbThis))
    end

    def getEffectScore(user, _target)
        score = 40
        score += 40 if user.belowHalfHealth?
        score += 40 unless user.hasDamagingAttack?
        return score
    end
end

#===============================================================================
# If user would be KO'd this round, it survives with 1 HP instead. (Endure)
#===============================================================================
class PokeBattle_Move_0E8 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :Endure
    end

    def pbProtectMessage(user)
        @battle.pbDisplay(_INTL("{1} braced itself!", user.pbThis))
    end

    def getEffectScore(user, target)
        return 0 if user.aboveHalfHealth?
        return super / 2
    end
end

#===============================================================================
# If target would be KO'd by this attack, it survives with 1HP instead.
# (False Swipe, Hold Back)
#===============================================================================
class PokeBattle_Move_0E9 < PokeBattle_Move
    def nonLethal?(_user, _target); return true; end
end

#===============================================================================
# User flees from battle. Switches out, in trainer battles. (Teleport)
#===============================================================================
class PokeBattle_Move_0EA < PokeBattle_Move
    def switchOutMove?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if @battle.wildBattle? && !@battle.bossBattle?
            unless @battle.pbCanRun?(user.index)
                @battle.pbDisplay(_INTL("But it failed, since you can't run from this battle!")) if show_message
                return true
            end
        else
            unless @battle.pbCanChooseNonActive?(user.index)
                if show_message
                    @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no party members to replace it!"))
                end
                return true
            end
        end
        return false
    end

    def pbEffectGeneral(user)
        if @battle.wildBattle? && !@battle.bossBattle?
            @battle.pbDisplay(_INTL("{1} fled from battle!", user.pbThis))
            @battle.decision = 3 # Escaped
        else
            return if user.fainted?
            return unless @battle.pbCanChooseNonActive?(user.index)
            @battle.pbDisplay(_INTL("{1} teleported, and went back to {2}!", user.pbThis,
              @battle.pbGetOwnerName(user.index)))
            @battle.pbPursuit(user.index)
            return if user.fainted?
            newPkmn = @battle.pbGetReplacementPokemonIndex(user.index) # Owner chooses
            return if newPkmn < 0
            @battle.pbRecallAndReplace(user.index, newPkmn)
            @battle.pbClearChoice(user.index) # Replacement Pokémon does nothing this round
            @battle.moldBreaker = false
            user.pbEffectsOnSwitchIn(true)
        end
    end

    def getEffectScore(user, target)
        return getSwitchOutEffectScore(user, target)
    end
end

#===============================================================================
# In wild battles, makes target flee. Fails if target is a higher level than the
# user.
# In trainer battles, target switches out.
# For status moves. (Roar, Whirlwind)
#===============================================================================
class PokeBattle_Move_0EB < PokeBattle_Move
    def forceSwitchMove?; return true; end

    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
            if show_message
                @battle.pbShowAbilitySplash(target, ability)
                @battle.pbDisplay(_INTL("{1} anchors itself!", target.pbThis))
                @battle.pbHideAbilitySplash(target)
            end
            return true
        end
        if target.effectActive?(:Ingrain)
            @battle.pbDisplay(_INTL("{1} anchored itself with its roots!", target.pbThis)) if show_message
            return true
        end
        if @battle.wildBattle? && !@battle.canRun
            @battle.pbDisplay(_INTL("But it failed, since the battle can't be run from!")) if show_message
            return true
        end
        if @battle.wildBattle? && (target.level > user.level)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s level is greater than #{user.pbThis(true)}'s!")) if show_message
            return true
        end
        if @battle.wildBattle? && target.boss
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is an Avatar!")) if show_message
            return true
        end
        if @battle.trainerBattle? && !@battle.pbCanChooseNonActive?(target.index)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} cannot be replaced!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(_user)
        @battle.decision = 3 if @battle.wildBattle? && !@battle.bossBattle? # Escaped from battle
    end

    def pbSwitchOutTargetsEffect(user, targets, numHits, switchedBattlers)
        return if numHits == 0
        forceOutTargets(user, targets, switchedBattlers)
    end

    def getTargetAffectingEffectScore(user, target)
        return getForceOutEffectScore(user, target)
    end
end

#===============================================================================
# In wild battles, makes target flee. Fails if target is a higher level than the
# user.
# In trainer battles, target switches out, to be replaced at random.
# For damaging moves. (Circle Throw, Dragon Tail)
#===============================================================================
class PokeBattle_Move_0EC < PokeBattle_Move
    def forceSwitchMove?; return true; end

    def pbEffectAgainstTarget(user, target)
        if @battle.wildBattle? && target.level <= user.level && @battle.canRun &&
           (target.substituted? || ignoresSubstitute?(user)) && !target.boss
            @battle.decision = 3
        end
    end

    def pbSwitchOutTargetsEffect(user, targets, numHits, switchedBattlers)
        return if numHits == 0
        forceOutTargets(user, targets, switchedBattlers, true)
    end

    def getTargetAffectingEffectScore(user, target)
        return getForceOutEffectScore(user, target)
    end
end

#===============================================================================
# User switches out. Various effects affecting the user are passed to the
# replacement. (Baton Pass)
#===============================================================================
class PokeBattle_Move_0ED < PokeBattle_Move
    def switchOutMove?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.pbCanChooseNonActive?(user.index)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no party allies to replace it!"))
            end
            return true
        end
        return false
    end

    def pbEndOfMoveUsageEffect(user, _targets, numHits, switchedBattlers)
        return if user.fainted? || numHits == 0
        return unless @battle.pbCanChooseNonActive?(user.index)
        @battle.pbPursuit(user.index)
        return if user.fainted?
        newPkmn = @battle.pbGetReplacementPokemonIndex(user.index) # Owner chooses
        return if newPkmn < 0
        @battle.pbRecallAndReplace(user.index, newPkmn, false, true)
        @battle.pbClearChoice(user.index) # Replacement Pokémon does nothing this round
        @battle.moldBreaker = false
        switchedBattlers.push(user.index)
        user.pbEffectsOnSwitchIn(true)
    end

    def getEffectScore(user, target)
        total = 0
        GameData::Stat.each_battle { |s| total += user.steps[s.id] }
        return 0 if total <= 0 || user.firstTurn?
        score = 0
        score += total * 20
        score += 30 unless user.hasDamagingAttack?
        score += getSwitchOutEffectScore(user, target)
        return score
    end
end

#===============================================================================
# After inflicting damage, user switches out. Ignores trapping moves.
# (U-turn, Volt Switch)
#===============================================================================
class PokeBattle_Move_0EE < PokeBattle_Move
    def switchOutMove?; return true; end

    def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
        return if user.fainted? || numHits == 0
        targetSwitched = true
        targets.each do |b|
            targetSwitched = false unless switchedBattlers.include?(b.index)
        end
        return if targetSwitched
        return unless @battle.pbCanChooseNonActive?(user.index)
        @battle.pbDisplay(_INTL("{1} went back to {2}!", user.pbThis,
            @battle.pbGetOwnerName(user.index)))
        @battle.pbPursuit(user.index)
        return if user.fainted?
        newPkmn = @battle.pbGetReplacementPokemonIndex(user.index) # Owner chooses
        return if newPkmn < 0
        @battle.pbRecallAndReplace(user.index, newPkmn)
        @battle.pbClearChoice(user.index) # Replacement Pokémon does nothing this round
        @battle.moldBreaker = false
        switchedBattlers.push(user.index)
        user.pbEffectsOnSwitchIn(true)
    end

    def getEffectScore(user, target)
        return getSwitchOutEffectScore(user, target)
    end
end

#===============================================================================
# Target can no longer switch out or flee, as long as the user remains active.
# (Anchor Shot, Block, Mean Look, Spider Web, Spirit Shackle, Thousand Waves)
#===============================================================================
class PokeBattle_Move_0EF < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        return false if damagingMove?
        if target.effectActive?(:MeanLook)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} already can't escape!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        target.pointAt(:MeanLook, user) unless target.effectActive?(:MeanLook)
    end

    def pbAdditionalEffect(user, target)
        return if target.fainted? || target.damageState.substitute
        return if target.effectActive?(:MeanLook)
        target.pointAt(:MeanLook, user) unless target.effectActive?(:MeanLook)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 if target.effectActive?(:MeanLook)
        return 50
    end
end

#===============================================================================
# Target drops its item. It regains the item at the end of the battle. (Knock Off)
# If target has a losable item, damage is multiplied by 1.5.
#===============================================================================
class PokeBattle_Move_0F0 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        if target.hasAnyItem?
            # NOTE: Damage is still boosted even if target has Sticky Hold or a
            #       substitute.
            baseDmg = (baseDmg * 1.5).round
        end
        return baseDmg
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canknockOffItems?(user, target)
        knockOffItems(user, target)
    end

    def getTargetAffectingEffectScore(user, target)
        return 30 if canknockOffItems?(user, target, true)
        return 0
    end
end

#===============================================================================
# User steals the target's items. (Covet, Ransack, Thief)
#===============================================================================
class PokeBattle_Move_0F1 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        target.eachItem do |item|
            stealItem(user, target, item)
        end
    end

    def getEffectScore(user, target)
        score = 0
        target.eachItem do |item|
            score += 50 if canStealItem?(user, target, item)
        end
        return score
    end

    def shouldHighlight?(user, target)
        return target.hasAnyItem? && user.canAddItem?
    end
end

#===============================================================================
# User and target swap their first items. They remain swapped after wild battles.
# (Switcheroo, Trick)
#===============================================================================
class PokeBattle_Move_0F2 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if @battle.wildBattle? && user.opposes? && !user.boss
            @battle.pbDisplay(_INTL("But it failed, since this is a wild battle!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.hasAnyItem?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have an item!"))
            end
            return true
        end
        unless user.hasAnyItem?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't have an item!")) if show_message
            return true
        end
        if target.unlosableItem?(target.firstItem) ||
           target.unlosableItem?(user.firstItem) ||
           user.unlosableItem?(user.firstItem) ||
           user.unlosableItem?(target.firstItem)
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        if user.firstItem == :PEARLOFFATE || target.firstItem == :PEARLOFFATE
             @battle.pbDisplay(_INTL("But it failed, since the Pearl of Fate cannot be exchanged!")) if show_message
            return true
        end
        if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
            if show_message
                @battle.pbShowAbilitySplash(target, ability)
                @battle.pbDisplay(_INTL("But it failed to affect {1}!", target.pbThis(true)))
                @battle.pbHideAbilitySplash(target)
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        oldUserItem = user.firstItem
        oldUserItemName = getItemName(oldUserItem)
        oldTargetItem = target.firstItem
        oldTargetItemName = getItemName(target.firstItem)
        user.removeItem(oldUserItem)
        target.removeItem(oldTargetItem)
        if @battle.curseActive?(:CURSE_SUPER_ITEMS)
            @battle.pbDisplay(_INTL("{1}'s {2} turned to dust.", user.pbThis, oldUserItemName)) if oldUserItem
            @battle.pbDisplay(_INTL("{1}'s {2} turned to dust.", target.pbThis, oldTargetItemName)) if oldTargetItem
        else
            user.giveItem(oldTargetItem)
            target.giveItem(oldUserItem)
            @battle.pbDisplay(_INTL("{1} switched items with its opponent!", user.pbThis))
            @battle.pbDisplay(_INTL("{1} obtained {2}.", user.pbThis, oldTargetItemName)) if oldTargetItem
            @battle.pbDisplay(_INTL("{1} obtained {2}.", target.pbThis, oldUserItemName)) if oldUserItem
            user.pbHeldItemTriggerCheck
            target.pbHeldItemTriggerCheck
        end
    end

    def getEffectScore(user, target)
        if user.hasActiveItem?(%i[FLAMEORB POISONORB STICKYBARB IRONBALL])
            return 130
        elsif user.hasActiveItem?(CHOICE_LOCKING_ITEMS)
            return 100
        elsif !user.firstItem && target.firstItem
            if user.lastMoveUsed && GameData::Move.get(user.lastMoveUsed).function_code == "0F2" # Trick/Switcheroo
                return 0
            end
        end
        return 0
    end
end

#===============================================================================
# User gives one of its items to the target. (Bestow)
#===============================================================================
class PokeBattle_Move_0F3 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def validItem(user,item)
        return !(user.unlosableItem?(item) || GameData::Item.get(item).is_mega_stone?)
    end

    def pbCanChooseMove?(user, commandPhase, show_message)
        unless user.hasAnyItem?
            if show_message
                msg = _INTL("#{user.pbThis} doesn't have an item to give away!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        allItemsInvalid = true
        user.items.each do |item|
            next unless validItem(user, item)
            allItemsInvalid = false
            break
        end
        if allItemsInvalid
            if show_message
                msg = _INTL("#{user.pbThis} can't lose any of its items!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        return true
    end

    def resolutionChoice(user)
        validItems = []
        validItemNames = []
        user.items.each do |item|
            next unless validItem(user,item)
            validItems.push(item)
            validItemNames.push(getItemName(item))
        end
        if validItems.length == 1
            @chosenItem = validItems[0]
        elsif validItems.length > 1
            if @battle.autoTesting
                @chosenItem = validItems.sample
            elsif !user.pbOwnedByPlayer? # Trainer AI
                @chosenItem = validItems[0]
            else
                chosenIndex = @battle.scene.pbShowCommands(_INTL("Which item should #{user.pbThis(true)} give away?"),validItemNames,0)
                @chosenItem = validItems[chosenIndex]
            end
        end
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.canAddItem?(@chosenItem)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have room for a new item!")) if show_message
            return true
        end
        if target.unlosableItem?(@chosenItem)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't accept an #{getItemName(@chosenItem)}!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.giveItem(@chosenItem)
        user.removeItem(@chosenItem)
        itemName = getItemName(@chosenItem)
        @battle.pbDisplay(_INTL("{1} received {2} from {3}!", target.pbThis, itemName, user.pbThis(true)))
        target.pbHeldItemTriggerCheck
    end

    def resetMoveUsageState
        @chosenItem = nil
    end

    def getEffectScore(user, target)
        if user.hasActiveItem?(%i[FLAMEORB POISONORB FROSTORB STICKYBARB
                                  IRONBALL]) || user.hasActiveItem?(CHOICE_LOCKING_ITEMS)
            if user.opposes?(target)
                return 100
            else
                return 0
            end
        end
        return 50
    end
end

#===============================================================================
# User consumes target's berries and gains its effect. (Bug Bite, Pluck)
#===============================================================================
class PokeBattle_Move_0F4 < PokeBattle_Move
    def canPluckBerry?(_user, target)
        return false if target.fainted?
        return false if target.damageState.berryWeakened
        return true
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canPluckBerry?(user, target)
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item)
            next unless GameData::Item.get(item).is_berry?
            target.removeItem(item)
            @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!", user.pbThis, itemName))
            user.pbHeldItemTriggerCheck(item, false)
        end
    end

    def getEffectScore(user, target)
        return 0 unless canPluckBerry?(user, target)
        score = 0
        target.eachItem do |item|
            next unless canRemoveItem?(user, target, item, checkingForAI: true)
            next unless GameData::Item.get(item).is_berry?
            score += 50
        end
        return score
    end
end

#===============================================================================
# Target's berry/Gem is destroyed. (Incinerate)
#===============================================================================
class PokeBattle_Move_0F5 < PokeBattle_Move
    def canIncinerateTargetsItem?(target, checkingForAI = false)
        if checkingForAI
            return false if target.substituted?
        elsif target.damageState.substitute || target.damageState.berryWeakened
            return false
        end
        return true
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canIncinerateTargetsItem?(target)
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item)
            itemData = GameData::Item.get(item)
            next unless itemData.is_berry? || itemData.is_gem?
            target.removeItem(item)
            @battle.pbDisplay(_INTL("{1}'s {2} was destroyed!", target.pbThis, itemName))
        end
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless canIncinerateTargetsItem?(target)
        score = 0
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item, checkingForAI: true)
            itemData = GameData::Item.get(item)
            next unless itemData.is_berry? || itemData.is_gem?
            score += 30
        end
        return score
    end
end

#===============================================================================
# User recovers the last item it held and consumed. (Recycle)
#===============================================================================
class PokeBattle_Move_0F6 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.recyclableItem
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't have an item to recycle!"))
            end
            return true
        end
        if user.hasItem?(user.recyclableItem)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has the item it would recycle!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.recycleItem
    end

    def getEffectScore(_user, _target)
        return 100
    end
end

#===============================================================================
# User flings its item at the target. Power/effect depend on the item. (Fling)
#===============================================================================
class PokeBattle_Move_0F7 < PokeBattle_Move
    def initialize(battle, move)
        super
        @flingPowers = {}

        # Highest BP
        category1 = %i[IRONBALL PEARLOFFATE]

        # Middle BP
        category2 = []
        category2.concat(CHOICE_LOCKING_ITEMS)
        category2.concat(WEATHER_ROCK_ITEMS)
        category2.concat(RECOIL_ITEMS)

        @flingPowers[150] = category1
        @flingPowers[100] = category2
    end

    def validItem(user,item)
        return !(user.unlosableItem?(item) || GameData::Item.get(item).is_mega_stone?)
    end

    def pbCanChooseMove?(user, commandPhase, show_message)
        unless user.hasAnyItem?
            if show_message
                msg = _INTL("#{user.pbThis} doesn't have an item to fling!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        unless user.itemActive?
            if show_message
                msg = _INTL("#{user.pbThis} can't use items!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        allItemsInvalid = true
        user.items.each do |item|
            next unless validItem(user, item)
            allItemsInvalid = false
            break
        end
        if allItemsInvalid
            if show_message
                msg = _INTL("#{user.pbThis} can't lose any of its items!")
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        return true
    end

    def resolutionChoice(user)
        validItems = []
        validItemNames = []
        user.items.each do |item|
            next unless validItem(user,item)
            validItems.push(item)
            validItemNames.push(getItemName(item))
        end
        if validItems.length == 1
            @chosenItem = validItems[0]
        elsif validItems.length > 1
            if @battle.autoTesting
                @chosenItem = validItems.sample
            elsif !user.pbOwnedByPlayer? # Trainer AI
                @chosenItem = validItems[0]
            else
                chosenIndex = @battle.scene.pbShowCommands(_INTL("Which item should #{user.pbThis(true)} fling?"),validItemNames,0)
                @chosenItem = validItems[chosenIndex]
            end
        end
    end

    def pbDisplayUseMessage(user, targets)
        super
        @battle.pbDisplay(_INTL("{1} flung its {2}!", user.pbThis, getItemName(@chosenItem)))
    end

    def pbNumHits(_user, _targets, _checkingForAI = false); return 1; end

    def pbBaseDamage(_baseDmg, user, _target)
        @flingPowers.each do |power, items|
            return power if items.include?(@chosenItem)
        end
        return 75
    end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.substitute
        return unless canApplyRandomAddedEffects?(user, target, true)
        case @chosenItem
        when :POISONORB
            target.applyPoison(user) if target.canPoison?(user, false, self)
        when :FLAMEORB
            target.applyBurn(user) if target.canBurn?(user, false, self)
        when :FROSTORB
            target.applyFrostbite(user) if target.canFrostbite?(user, false, self)
        when :BIGROOT
            target.applyLeeched(user) if target.canLeech?(user, false, self)
        when :BINDINGBAND
            target.applyLeeched(user) if target.canLeech?(user, false, self)
        else
            target.pbHeldItemTriggerCheck(@chosenItem, true)
        end
    end

    def pbEndOfMoveUsageEffect(user, _targets, _numHits, _switchedBattlers)
        # NOTE: The item is consumed even if this move was Protected against or it
        #       missed. The item is not consumed if the target was switched out by
        #       an effect like a target's Red Card.
        # NOTE: There is no item consumption animation.
        user.consumeItem(@chosenItem, belch: false) if user.hasItem?(@chosenItem)
    end

    def resetMoveUsageState
        @chosenItem = nil
    end
end

#===============================================================================
# The target cannnot use its held item, its held item has no
# effect, and no items can be used on it. (Embargo)
#===============================================================================
class PokeBattle_Move_0F8 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.effectActive?(:Embargo)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already embargoed!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Embargo)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 unless target.hasAnyItem?
        return 50
    end
end

#===============================================================================
# Heals user by an amount depending on the weather. (Power Nap)
#===============================================================================
class PokeBattle_Move_0F9 < PokeBattle_HealingMove
    def healRatio(_user)
        if @battle.moonGlowing?
            return 2.0 / 3.0
        else
            return 1.0 / 2.0
        end
    end

    def shouldHighlight?(_user, _target)
        return @battle.moonGlowing?
    end
end

#===============================================================================
# User takes recoil damage equal to 1/4 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_0FA < PokeBattle_RecoilMove
    def recoilFactor;  return 0.25; end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_0FB < PokeBattle_RecoilMove
    def recoilFactor;  return (1.0 / 3.0); end
end

#===============================================================================
# User takes recoil damage equal to 1/2 of the damage this move dealt.
# (Head Smash, Light of Ruin)
#===============================================================================
class PokeBattle_Move_0FC < PokeBattle_RecoilMove
    def recoilFactor;  return 0.5; end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May paralyze the target. (Volt Tackle)
#===============================================================================
class PokeBattle_Move_0FD < PokeBattle_RecoilMove
    def recoilFactor;  return (1.0 / 3.0); end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyNumb(user) if target.canNumb?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getNumbEffectScore(user, target)
    end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May burn the target. (Flare Blitz)
#===============================================================================
class PokeBattle_Move_0FE < PokeBattle_RecoilMove
    def recoilFactor; return (1.0 / 3.0); end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.applyBurn(user) if target.canBurn?(user, false, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getBurnEffectScore(user, target)
    end
end

#===============================================================================
# Starts sunny weather. (Sunshine)
#===============================================================================
class PokeBattle_Move_0FF < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Sun
    end
end
