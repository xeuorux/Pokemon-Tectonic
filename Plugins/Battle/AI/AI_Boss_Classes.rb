##################################################
# Summons
##################################################
class PokeBattle_AI_Combee < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @firstTurnOnly.push(:HELPINGHAND)

        case user.level
        when 1..24
            @fallback.push(:SMUSH)
        when 25..39
            @fallback.push(:STEAMROLLER)
        when 40..70
            @fallback.push(:BUGBUZZ)
        end

        if user.level >= 25
            @useMoveIFF.add(:CREEPOUT, proc { |_move, user, _target, _battle|
                next user.nthTurnThisRound?(1)
            })
        else
            @rejectedMoves.push(:CREEPOUT)
        end
    end
end

##################################################
# Legendary Beasts
##################################################
class PokeBattle_AI_Entei < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:INCINERATE, {
            :condition => proc { |_move, _user, target, _battle|
                next target.item && (target.item.is_berry? || target.item.is_gem?)
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} notices a flammable item amongst your Pokémon!")
            },
        })
    end
end

class PokeBattle_AI_Suicune < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:PURIFYINGWATER, {
            :condition => proc { |_move, user, _target, _battle|
                next user.pbHasAnyStatus?
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} inspects it's status conditions.")
            },
        })
    end
end

class PokeBattle_AI_Raikou < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:LIGHTNINGSHRIEK, {
            :condition => proc { |_move, user, _target, _battle|
                next user.stages[:SPEED] < 2
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} opens its mouth up wide!")
            },
        })
    end
end

##################################################
# Swords of Justice
##################################################
class PokeBattle_AI_Keldeo < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        rejectPoisonMovesIfBelched
    end
end

##################################################
# Weather Trio
##################################################
class PokeBattle_AI_Groudon < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @wholeRound += %i[ERUPTION PRECIPICEBLADES]

        @warnedIFFMove.add(:ERUPTION, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is clearly preparing a massive opening attack!")
            },
        })

        @warnedIFFMove.add(:PRECIPICEBLADES, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount > 0 && battle.turnCount % 4 == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is gathering energy for a big attack!")
            },
        })
    end
end

class PokeBattle_AI_Kyogre < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @wholeRound += %i[WATERSPOUT ORIGINPULSE]

        @warnedIFFMove.add(:WATERSPOUT, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is clearly preparing a massive opening attack!")
            },
        })

        @warnedIFFMove.add(:ORIGINPULSE, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount > 0 && battle.turnCount % 4 == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is gathering energy for a big attack!")
            },
        })
    end
end

class PokeBattle_AI_Rayquaza < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @beginBattle.push(proc { |user, _battle|
            user.battle.pbMegaEvolve(user.index)
        })

        @wholeRound += %i[DRAGONASCENT STRATOSPHERESCREAM]

        @warnedIFFMove.add(:DRAGONASCENT, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} looks to the Ozone Layer above!")
            },
        })

        @warnedIFFMove.add(:STRATOSPHERESCREAM, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount > 0 && battle.turnCount % 4 == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis}'s rage is at at its peak!")
            },
        })
    end
end

##################################################
# Chamber Avatars
##################################################
class PokeBattle_AI_Jirachi < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @useMoveIFF.add(:DOOMDESIRE, proc { |_move, user, _target, battle|
            next battle.turnCount % 3 == 0 && user.lastTurnThisRound?
        })

        @warnedIFFMove.add(:LIFEDEW, {
            :condition => proc { |_move, user, _target, battle|
                next battle.turnCount % 3 == 1 && user.belowHalfHealth?
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} takes a passive stance, inspecting its wounds.")
            },
        })
    end
end

class PokeBattle_AI_Xerneas < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @useMoveIFF.add(:GEOMANCY, proc { |_move, user, _target, battle|
            next battle.turnCount == 0 && user.lastTurnThisRound?
        })
    end
end

class PokeBattle_AI_Deoxys < PokeBattle_AI_Boss
    ATTACK_FORM_MOVESET = %i[PSYCHOBOOST INFINITEFORCE]
    DEFENSE_FORM_MOVESET = %i[COSMICPOWER RECOVER]
    SPEED_FORM_MOVESET = %i[ZENHEADBUTT ELECTROBALL]

    def initialize(user, battle)
        super
        @beginTurn.push(proc { |user, _battle, turnCount|
            if turnCount != 0
                if user.hp < user.totalhp * 0.25
                    if user.form != 1
                        formChangeMessage = _INTL("The avatar of Deoxys turns to Attack Form!")
                        user.pbChangeFormBoss(1, formChangeMessage)
                        user.assignMoveset(ATTACK_FORM_MOVESET)
                    end
                elsif user.hp < user.totalhp * 0.5
                    if user.form != 2
                        formChangeMessage = _INTL("The avatar of Deoxys turns to Defense Form!")
                        user.pbChangeFormBoss(2, formChangeMessage)
                        user.assignMoveset(DEFENSE_FORM_MOVESET)
                    end
                elsif user.hp < user.totalhp * 0.75
                    if user.form != 3
                        formChangeMessage = _INTL("The avatar of Deoxys turns to Speed Form!")
                        user.pbChangeFormBoss(3, formChangeMessage)
                        user.assignMoveset(SPEED_FORM_MOVESET)
                    end
                end
            end
        })
    end
end

class PokeBattle_AI_Zygarde < PokeBattle_AI_Boss
    FIFTY_PERCENT_MOVESET = %i[COREENFORCER DISCHARGE FLASHCANNON FLAMETHROWER]
    ONE_HUNDRED_PERCENT_MOVESET = %i[THOUSANDARROWS THOUSANDWAVES TORNADO]

    def initialize(user, battle)
        super
        @beginTurn.push(proc { |user, battle, turnCount|
            if turnCount == 0
                battle.pbDisplayBossNarration(_INTL("{1} is at 10 percent cell strength!", user.pbThis))
            elsif turnCount <= 9
                battle.pbDisplayBossNarration(_INTL("{1} gathers a cell!", user.pbThis))
                percentStrength = (1 + turnCount) * 10
                battle.pbDisplayBossNarration(_INTL("{1} is now at at {2} percent cell strength!", user.pbThis,
percentStrength.to_s))

                if percentStrength == 50
                    formChangeMessage = _INTL("{1} transforms into its 50 percent form!", user.pbThis)
                    user.pbChangeFormBoss(0, formChangeMessage)
                    user.ability = :AURABREAK
                    user.assignMoveset(FIFTY_PERCENT_MOVESET)
                elsif percentStrength == 100
                    formChangeMessage = _INTL("{1} transforms into its 100 percent form!", user.pbThis)
                    user.pbChangeFormBoss(2, formChangeMessage)
                    user.ability = :AURABREAK
                    battle.pbDisplayBossNarration(_INTL("{1} completely regenerates!", user.pbThis))
                    user.pbRecoverHP(user.totalhp - user.hp)
                    user.assignMoveset(ONE_HUNDRED_PERCENT_MOVESET)
                end
            end
        })
    end
end

##################################################
# Other Legends
##################################################
class PokeBattle_AI_Genesect < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:FELLSTINGER, {
            :condition => proc { |move, user, target, _battle|
                ai = user.battle.battleAI
                next ai.getDamagePercentageAI(move, user, target, 100) >= 100
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} aims its stinger at #{target.pbThis(false)}!")
            },
        })

        @wholeRound.push(:FELLSTINGER)

        @beginBattle.push(proc { |user, battle|
            battle.pbDisplayBossNarration(_INTL("The avatar of Genesect is analyzing your whole team for weaknesses..."))
            weakToElectric	= 0
            weakToFire	= 0
            weakToIce	= 0
            weakToWater	= 0
            maxValue = 0

            $Trainer.party.each do |b|
                next unless b
                type1 = b.type1
                type2 = b.type2
                weakToElectric += 1 if Effectiveness.super_effective?(Effectiveness.calculate(:ELECTRIC, type1,
type2))
                maxValue = weakToElectric if weakToElectric > maxValue
                weakToFire += 1 if Effectiveness.super_effective?(Effectiveness.calculate(:FIRE, type1, type2))
                maxValue = weakToFire if weakToFire > maxValue
                weakToIce += 1 if Effectiveness.super_effective?(Effectiveness.calculate(:ICE, type1, type2))
                maxValue = weakToIce if weakToIce > maxValue
                weakToWater += 1 if Effectiveness.super_effective?(Effectiveness.calculate(:WATER, type1, type2))
                maxValue = weakToWater if weakToWater > maxValue
            end

            chosenItem = nil
            if maxValue > 0
                results = { SHOCKDRIVE: weakToElectric, BURNDRIVE: weakToFire, CHILLDRIVE: weakToIce,
DOUSEDRIVE: weakToWater, }
                results = results.sort_by { |_k, v| v }.to_h
                results.delete_if { |_k, v| v < maxValue }
                chosenItem = results.keys.sample
            end

            if !chosenItem
                battle.pbDisplayBossNarration(_INTL("#{user.pbThis} can't find any!"))
            else
                battle.pbDisplayBossNarration(_INTL("#{user.pbThis} loads a {1}!",
GameData::Item.get(chosenItem).real_name))
                user.item = chosenItem
            end
        })
    end
end

class PokeBattle_AI_Cresselia < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @beginTurn.push(proc { |user, battle, turnCount|
            if turnCount == 4
                battle.pbDisplayBossNarration(_INTL("A Shadow creeps into the dream..."))
                battle.addAvatarBattler(:DARKRAI, user.level)
            end
        })
    end
end

##################################################
# Route Avatars
##################################################

class PokeBattle_AI_Donster < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        rejectPoisonMovesIfBelched
    end
end

class PokeBattle_AI_Deceat < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        prioritizeFling
    end
end

class PokeBattle_AI_Gourgeist < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @lastTurnOnly.push(:TRICKORTREAT)
    end
end

class PokeBattle_AI_Electrode < PokeBattle_AI_Boss
    TURNS_TO_EXPLODE = 3

    def initialize(user, battle)
        super
        @warnedIFFMove.add(:EXPLOSION, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount >= TURNS_TO_EXPLODE
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is fully charged. Its about to explode!")
            },
        })

        @beginTurn.push(proc { |user, battle, _turnCount|
            turnsRemaining = TURNS_TO_EXPLODE - battle.turnCount
            if turnsRemaining > 0
                battle.pbDisplayBossNarration(_INTL("#{user.pbThis} is charging up."))
                battle.pbDisplayBossNarration(_INTL("#{turnsRemaining} turns remain!"))
            end
        })

        @dangerMoves.push(:EXPLOSION)
        @wholeRound.push(:EXPLOSION)
    end
end

class PokeBattle_AI_Incineroar < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @lastTurnOnly += %i[SWAGGER TAUNT]
    end
end

class PokeBattle_AI_Linoone < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:COVET, {
            :condition => proc { |_move, user, target, _battle|
                next user.item.nil? && !target.item.nil?
            },
            :warning => proc { |_move, user, targets, _battle|
                target = targets[0]
                _INTL("#{user.pbThis} eyes #{target.pbThis(true)}'s #{GameData::Item.get(target.item).real_name} with jealousy!")
            },
        })
    end
end

class PokeBattle_AI_Parasect < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:SPORE, {
            :condition => proc { |_move, user, _target, _battle|
                anyAsleep = false
                user.battle.battlers.each do |b|
                    next if !b || !user.opposes?(b)
                    anyAsleep = true if b.asleep?
                end
                next !anyAsleep
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis}'s shroom stalks perked up!")
            },
        })
    end
end

class PokeBattle_AI_Magnezone < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @useMoveIFF.add(:ZAPCANNON, proc { |_move, user, target, _battle|
            next user.battle.commandPhasesThisRound == 0 && user.pointsAt?(:LockOnPos, target)
        })

        @lastTurnOnly.push(:LOCKON)
    end
end

class PokeBattle_AI_Porygonz < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @firstTurnOnly += %i[CONVERSION CONVERSION2]
    end
end

class PokeBattle_AI_Greedent < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @nonFirstTurnOnly += [:STOCKPILE]
        @fallback.push(:STOCKPILE)

        @lastUsedMove = :SWALLOW
        @decidedOnMove[:SWALLOW] = proc { |_move, _user, _targets, _battle|
            @lastUsedMove = :SWALLOW
        }
        @decidedOnMove[:SPITUP] = proc { |_move, _user, _targets, _battle|
            @lastUsedMove = :SPITUP
        }

        @useMoveIFF.add(:SPITUP, proc { |_move, user, _target, _battle|
            next @lastUsedMove == :SWALLOW && user.firstTurnThisRound? &&
                user.countEffect(:Stockpile) >= 2 && user.primevalTimer < 3
        })

        @useMoveIFF.add(:SWALLOW, proc { |_move, user, _target, _battle|
            next @lastUsedMove == :SPITUP && user.firstTurnThisRound? &&
                user.countEffect(:Stockpile) >= 2 && user.primevalTimer < 3
        })
    end
end

class PokeBattle_AI_Wailord < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:SELFDESTRUCT, {
            :condition => proc { |_move, _user, _target, _battle|
                next true
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is flying erratically. It looks unstable!")
            },
        })

        @wholeRound.push(:SELFDESTRUCT)
        @dangerMoves.push(:SELFDESTRUCT)
    end
end

class PokeBattle_AI_Maractus < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        spaceOutProtecting
    end
end

class PokeBattle_AI_Mtangrowth < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        spaceOutProtecting
    end
end
