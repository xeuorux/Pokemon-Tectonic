PP_INCREASE_REPEAT_MOVES = false

class PokeBattle_Battler
    #=============================================================================
    # Change HP
    #=============================================================================
    def pbReduceHP(amt, anim = true, registerDamage = true, anyAnim = true)
        amt = amt.round
        amt = @hp if amt > @hp
        amt = 1 if amt < 1 && !fainted?
        oldHP = @hp
        self.hp -= amt
        PBDebug.log("[HP change] #{pbThis} lost #{amt} HP (#{oldHP}=>#{@hp})") if amt.positive?
        raise _INTL("HP less than 0") if @hp.negative?
        raise _INTL("HP greater than total HP") if @hp > @totalhp
        @battle.scene.pbHPChanged(self, oldHP, anim) if anyAnim && amt.positive? && !@battle.autoTesting
        @tookDamage = true if amt.positive? && registerDamage
        return amt
    end

    # Helper method for performing the two checks that are supposed to occur whenever the battler loses HP
    # From a special effect. E.g. sandstorm DOT, ability triggers
    # Returns whether or not the pokemon faints
    def pbHealthLossChecks(oldHP = -1)
        pbItemHPHealCheck
        if fainted?
            pbFaint
            return true
        elsif oldHP > -1
            pbAbilitiesOnDamageTaken(oldHP)
        end
        return false
    end

    # Helper method for performing the checks that are supposed to occur whenever the battler loses HP
    # From a special effect that occurs when entering the field (i.e. Stealth Rock)
    # Returns whether or not the pokemon was swapped out due to a damage taking ability
    def pbEntryHealthLossChecks(oldHP = -1)
        pbItemHPHealCheck
        if fainted?
            pbFaint
        elsif oldHP > -1
            return pbAbilitiesOnDamageTaken(oldHP)
        end
        return false
    end

    # Applies damage effects that are based on a fraction of the battler's total HP
    # Returns how much damage ended up dealt
    # Accounts for bosses taking reduced fractional damage
    def applyFractionalDamage(fraction, showDamageAnimation = true, basedOnCurrentHP = false, entryCheck = false)
        return 0 unless takesIndirectDamage?
        oldHP = @hp
        fraction /= BOSS_HP_BASED_EFFECT_RESISTANCE if boss?
        fraction *= 1.5 if @battle.pbCheckOpposingAbility(:AGGRAVATE, @index)
        if basedOnCurrentHP
            reduction = @hp * fraction
        else
            reduction = @totalhp * fraction
        end
        reduction *= 0.66 if hasTribeBonus?(:ANIMATED)
        reduction = reduction.ceil
        if showDamageAnimation
            @damageState.displayedDamage = reduction
            @battle.scene.pbDamageAnimation(self,0,true)
        end
        reduction = @hp if reduction > @hp
        pbReduceHP(reduction, false)
        if entryCheck
            swapped = pbEntryHealthLossChecks(oldHP)
            return swapped
        else
            pbHealthLossChecks(oldHP)
            return reduction
        end
    end

    def applyRecoilDamage(damage, showDamageAnimation = true, showMessage = true, recoilMessage = nil, cushionRecoil = false)
        return unless takesIndirectDamage?
        return if hasActiveAbility?(:ROCKHEAD)
        # return if @battle.pbAllFainted?(@idxOpposingSide)
        damage *= 0.66 if hasTribeBonus?(:ANIMATED)
        damage = damage.round
        damage = 1 if damage < 1
        if !cushionRecoil && hasActiveAbility?(:ALLYCUSHION)
            @battle.pbShowAbilitySplash(self, :ALLYCUSHION)
            @battle.pbDisplay(_INTL("{1} looks for an ally to help in avoiding the recoil!", pbThis))

            # Can be replaced
            if @battle.pbCanSwitch?(@index) && @battle.pbCanChooseNonActive?(@index)
                allyCushionAmount = (damage / 2.0).round
                allyCushionAmount = 1 if allyCushionAmount < 1
                applyEffect(:AllyCushionSwap)
                position.applyEffect(:AllyCushion, @pokemonIndex)
                position.applyEffect(:AllyCushionAmount, allyCushionAmount)
                @battle.pbHideAbilitySplash(self)
                return
            else
                @battle.pbDisplay(_INTL("But it couldn't swap into anybody!"))
                @battle.pbHideAbilitySplash(self)
            end
        end

        oldHP = @hp
        recoilMessage = _INTL("{1} is damaged by recoil!", pbThis) if recoilMessage.nil?
        @battle.pbDisplay(recoilMessage) if showMessage
        pbReduceHP(damage, showDamageAnimation)

        if !cushionRecoil
            pbHealthLossChecks(oldHP)
        elsif pbEntryHealthLossChecks(oldHP)
            @battle.pbOnActiveOne(self)
        end
    end

    def pbRecoverHP(amt, anim = true, anyAnim = true, showMessage = true, customMessage = nil)
        if @battle.autoTesting
            anim = false
            anyAnim = false
        end
        raise _INTL("Told to recover a negative amount") if amt.negative?
        amt *= 1.5 if hasActiveAbility?(:ROOTED)
        amt *= 2.0 if hasActiveAbilityAI?(:GLOWSHROOM) && @battle.pbWeather == :Moonglow
        amt *= 0.5 if effectActive?(:IcyInjection)
        amt = amt.round
        amt = @totalhp - @hp if amt > @totalhp - @hp
        amt = 1 if amt < 1 && @hp < @totalhp
        if effectActive?(:NerveBreak)
            @battle.pbDisplay(_INTL("{1}'s healing is reversed because of their broken nerves!", pbThis))
            amt *= -1
        end
        oldHP = @hp
        self.hp += amt
        self.hp = 0 if self.hp.negative?
        PBDebug.log("[HP change] #{pbThis} gained #{amt} HP (#{oldHP}=>#{@hp})") if amt.positive?
        raise _INTL("HP greater than total HP") if @hp > @totalhp
        anyAnim = false if @autoTesting
        @battle.scene.pbHPChanged(self, oldHP, anim) if anyAnim && amt.positive?
        if showMessage
            if amt.positive?
                message = customMessage.nil? ? _INTL("{1}'s HP was restored.", pbThis) : customMessage
                @battle.pbDisplay(message)
            elsif amt.negative?
                @battle.pbDisplay(_INTL("{1}'s lost HP.", pbThis))
            end
        end
        return amt
    end

    def pbRecoverHPFromDrain(drainAmount, target)
        if target.hasActiveAbility?(:LIQUIDOOZE)
            @battle.pbShowAbilitySplash(target, :LIQUIDOOZE)
            oldHP = @hp
            pbReduceHP(drainAmount)
            @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", pbThis))
            @battle.pbHideAbilitySplash(target)
            pbItemHPHealCheck
            pbAbilitiesOnDamageTaken(oldHP)
            pbFaint if fainted?
        elsif canHeal?
            drainAmount = (drainAmount * 1.3).floor if hasActiveItem?(:BIGROOT)
            pbRecoverHP(drainAmount, true, true, false)
        end
    end

    def pbRecoverHPFromMultiDrain(targets, ratio, ability: nil)
        totalDamageDealt = 0
        targets.each do |target|
            next if target.damageState.unaffected
            damage = target.damageState.totalHPLost
            if target.hasActiveAbility?(:LIQUIDOOZE)
                @battle.pbShowAbilitySplash(target, :LIQUIDOOZE)
                lossAmount = (damage * ratio).round
                pbReduceHP(lossAmount)
                @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", pbThis))
                @battle.pbHideAbilitySplash(target)
                pbItemHPHealCheck
            else
                totalDamageDealt += damage
            end
        end
        return if totalDamageDealt <= 0 || !canHeal?
        @battle.pbShowAbilitySplash(self, ability) if ability
        drainAmount = (totalDamageDealt * ratio).round
        drainAmount = 1 if drainAmount < 1
        drainAmount = (drainAmount * 1.3).floor if hasActiveItem?(:BIGROOT)
        pbRecoverHP(drainAmount, true, true, false)
        @battle.pbHideAbilitySplash(self) if ability
    end

    def applyFractionalHealing(fraction, ability: nil, anim: true, anyAnim: true, showMessage: true, customMessage: nil, item: nil)
        return 0 unless canHeal?
        if item
            @battle.pbCommonAnimation("UseItem", self) unless @battle.autoTesting
            unless customMessage
                if fraction <= 1.0 / 8.0
                    customMessage = _INTL("{1} restored a little HP using its {2}!", pbThis, getItemName(item))
                else
                    customMessage = _INTL("{1} restored its health using its {2}!", pbThis, getItemName(item))
                end
            end
        end
        battle.pbShowAbilitySplash(self, ability) if ability
        healAmount = @totalhp * fraction
        healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if boss?
        actuallyHealed = pbRecoverHP(healAmount, anim, anyAnim, showMessage, customMessage)
        battle.pbHideAbilitySplash(self) if ability
        return actuallyHealed
    end

    def pbFaint(showMessage = true)
        unless fainted?
            PBDebug.log("!!!***Can't faint with HP greater than 0")
            return
        end
        return if @fainted # Has already fainted properly
        if showMessage
            if boss?
                if isSpecies?(:PHIONE)
                    @battle.pbDisplayBrief(_INTL("{1} was defeated!", pbThis))
                else
                    @battle.pbDisplayBrief(_INTL("{1} was destroyed!", pbThis))
                end
            else
                @battle.pbDisplayBrief(_INTL("{1} fainted!", pbThis))
            end
        end
        PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") unless showMessage
        @battle.scene.pbFaintBattler(self) unless @battle.autoTesting

        @pokemon.addToFaintCount
        lastFoeAttacker.each do |foe|
            @battle.battlers[foe].pokemon.addToKOCount
        end

        # Trigger battler faint curses
        @battle.curses.each do |curse_policy|
            @battle.triggerBattlerFaintedCurseEffect(curse_policy, self, @battle)
        end

        @battle.triggerBattlerFaintedDialogue(self)

        if effectActive?(:GivingDragonRideTo, true)
            otherBattler = @battle.battlers[@effects[:GivingDragonRideTo]] # Do not switch to the helper method
            damageDealt = otherBattler.hp
            otherBattler.damageState.displayedDamage = damageDealt
            @battle.scene.pbDamageAnimation(otherBattler)
            otherBattler.pbReduceHP(damageDealt, false)
            @battle.pbDisplay(_INTL("{1} fell to the ground!", otherBattler.pbThis))
            otherBattler.pbFaint
        end

        # On-faint effect items
        if hasActiveItem?(:HOOHSASHES)
            faintedPartyMembers = []
            ownerParty.each do |partyPokemon|
                next if @battle.pbFindBattler(partyIndex, @index)
                next unless partyPokemon.fainted?
                faintedPartyMembers.push(partyPokemon)
            end
            pbDisplay(_INTL("{1}'s scattered its {2} when fainting.", pbThis, getItemName(:HOOHSASHES)))
            if faintedPartyMembers.length == 0
                pbDisplay(_INTL("But there was no one to revive!"))
            else
                reviver = faintedPartyMembers.sample
                reviver.heal_HP
                reviver.heal_status
                pbDisplay(_INTL("Its allied #{reviver.name} was revived to full health!"))
            end
        end

        pbInitEffects(false)

        # Reset status
        self.status      = :NONE
        self.statusCount = 0

        @bossStatus = :NONE
        @bossStatusCount = 0

        # Lose happiness
        if @pokemon && @battle.internalBattle
            badLoss = false
            @battle.eachOtherSideBattler(@index) do |b|
                badLoss = true if b.level >= level + 30
            end
            @pokemon.changeHappiness(badLoss ? "faintbad" : "faint")
        end

        # Reset form
        @battle.peer.pbOnLeavingBattle(@battle, @pokemon,
                                                                                                                                    @battle.usedInBattle[idxOwnSide][@index / 2])
        @pokemon.makeUnmega if mega?
        @pokemon.makeUnprimal if primal?

        # Do other things
        @battle.pbClearChoice(@index) # Reset choice
        pbOwnSide.effects[:LastRoundFainted] = @battle.turnCount

        # Check other battlers' abilities that trigger upon a battler fainting
        pbAbilitiesOnFainting

        # Check for end of primordial weather
        @battle.pbEndPrimordialWeather
    end

    #=============================================================================
    # Move PP
    #=============================================================================
    def pbSetPP(move, pp)
        move.pp = pp
        # Mimic
        move.realMove.pp = pp if move.realMove && move.id == move.realMove.id && !@effects[:Transform]
    end

    def pbReducePP(move)
        return true if usingMultiTurnAttack?
        return true if move.pp.negative? # Don't reduce PP for special calls of moves
        return true if move.total_pp <= 0 # Infinite PP, can always be used
        return false if move.pp.zero? # Ran out of PP, couldn't reduce
        reductionAmount = 1
        if PP_INCREASE_REPEAT_MOVES && (!boss? && @lastMoveUsed && @lastMoveUsed == move.id && !@lastMoveFailed)
            reductionAmount = 3
        end
        newPPAmount = [move.pp - reductionAmount, 0].max
        pbSetPP(move, newPPAmount)
        return true
    end

    def pbReducePPOther(move)
        pbSetPP(move, move.pp - 1) if move.pp.positive?
    end

    #=============================================================================
    # Change type
    #=============================================================================
    def pbChangeTypes(newType)
        if newType.is_a?(PokeBattle_Battler)
            typeCopyTarget = newType
            newTypes = typeCopyTarget.pbTypes
            newTypes.push(:NORMAL) if newTypes.length.zero?
            newType3 = typeCopyTarget.effects[:Type3]
            newType3 = nil if newTypes.include?(newType3)
            @type1 = newTypes[0]
            @type2 = (newTypes.length == 1) ? newTypes[0] : newTypes[1]
            if newType3
                applyEffect(:Type3, newType3)
            else
                disableEffect(:Type3)
            end
        elsif newType.is_a?(Array)
            @type1 = newType[0]
            @type2 = newType[1] if newType.length > 1
            applyEffect(:Type3, newType[2]) if newType.length > 2
        else
            newType = GameData::Type.get(newType).id
            @type1 = newType
            @type2 = newType
            disableEffect(:Type3)
        end
        disableEffect(:BurnUp)
        disableEffect(:ColdConversion)
        disableEffect(:Roost)
        refreshDataBox
    end

    #=============================================================================
    # Forms
    #=============================================================================
    def pbChangeForm(newForm, msg)
        return if fainted? || effectActive?(:Transform) || @form == newForm
        oldForm = @form
        oldDmg = @totalhp - @hp
        self.form = newForm
        pokemon.forced_form = newForm if boss?
        pbUpdate(true)
        @hp = @totalhp - oldDmg
        @hp = 1 if @hp < 1
        disableEffect(:WeightChange)
        @battle.scene.pbChangePokemon(self, @pokemon)
        refreshDataBox
        @battle.pbDisplay(msg) if msg && msg != ""
        PBDebug.log("[Form changed] #{pbThis} changed from form #{oldForm} to form #{newForm}")
        @battle.pbSetSeen(self)
    end

    def pbCheckFormOnStatusChange
        return if fainted? || effectActive?(:Transform)
    end

    def pbCheckFormOnMovesetChange
        return if fainted? || effectActive?(:Transform)
        # Keldeo - knowing Secret Sword
        if isSpecies?(:KELDEO)
            newForm = 0
            newForm = 1 if pbHasMove?(:SECRETSWORD)
            pbChangeForm(newForm, _INTL("{1} transformed!", pbThis))
        end
    end

    def pbCheckFormOnWeatherChange
        return if fainted? || effectActive?(:Transform)
        # Castform - Forecast
        if isSpecies?(:CASTFORM)
            if hasActiveAbility?(:FORECAST)
                newForm = 0
                case @battle.pbWeather
                when :Sun, :HarshSun   then newForm = 1
                when :Rain, :HeavyRain then newForm = 2
                when :Hail             then newForm = 3
                end
                if @form != newForm
                    @battle.pbShowAbilitySplash(self, true)
                    @battle.pbHideAbilitySplash(self)
                    pbChangeForm(newForm, _INTL("{1} transformed!", pbThis))
                end
            else
                pbChangeForm(0, _INTL("{1} transformed!", pbThis))
            end
        end
        # Cherrim - Flower Gift
        if isSpecies?(:CHERRIM)
            if hasActiveAbility?(:FLOWERGIFT)
                newForm = 0
                newForm = 1 if %i[Sun HarshSun].include?(@battle.pbWeather)
                if @form != newForm
                    @battle.pbShowAbilitySplash(self, true)
                    @battle.pbHideAbilitySplash(self)
                    pbChangeForm(newForm, _INTL("{1} transformed!", pbThis))
                end
            else
                pbChangeForm(0, _INTL("{1} transformed!", pbThis))
            end
        end
        # Eiscue - Ice Face
        if @species == :EISCUE && hasActiveAbility?(:ICEFACE) && @battle.pbWeather == :Hail && (@form == 1)
            @battle.pbShowAbilitySplash(self, true)
            @battle.pbHideAbilitySplash(self)
            pbChangeForm(0, _INTL("{1} transformed!", pbThis))
        end
    end

    def pbCheckFormOnTerrainChange
        return if fainted?
        if hasActiveAbility?(:MIMICRY)
            newTypes = pbTypes
            originalTypes = [@pokemon.type1]
            originalTypes.push(@pokemon.type2) if @pokemon.type2 != @pokemon.type1
            case @battle.field.terrain
            when :Electric then   newTypes = [:ELECTRIC]
            when :Grassy then     newTypes = [:GRASS]
            when :Fairy then      newTypes = [:FAIRY]
            when :Psychic then    newTypes = [:PSYCHIC]
            else; newTypes = originalTypes.dup
            end
            if pbTypes != newTypes
                pbChangeTypes(newTypes)
                @battle.pbShowAbilitySplash(self, true)
                @battle.pbHideAbilitySplash(self)
                if newTypes == originalTypes
                    @battle.pbDisplay(_INTL("{1} returned back to normal!", pbThis))
                else
                    typeName = GameData::Type.get(newTypes[0]).name
                    @battle.pbDisplay(_INTL("{1}'s type changed to {2}!", pbThis, typeName))
                end
            end
        end
    end

    # Checks the Pokémon's form and updates it if necessary. Used for when a
    # Pokémon enters battle (endOfRound=false) and at the end of each round
    # (endOfRound=true).
    def pbCheckForm(endOfRound = false)
        return if fainted? || effectActive?(:Transform)
        # Form changes upon entering battle and when the weather changes
        pbCheckFormOnWeatherChange unless endOfRound
        pbCheckFormOnTerrainChange unless endOfRound
        # Darmanitan - Zen Mode
        if isSpecies?(:DARMANITAN) && hasAbility?(:ZENMODE)
            if @hp <= @totalhp / 2
                if @form != 1
                    @battle.pbShowAbilitySplash(self, :ZENMODE, true)
                    @battle.pbHideAbilitySplash(self)
                    pbChangeForm(1, _INTL("{1} triggered!", getAbilityName(:ZENMODE)))
                end
            elsif @form != 0
                @battle.pbShowAbilitySplash(self, :ZENMODE, true)
                @battle.pbHideAbilitySplash(self)
                pbChangeForm(0, _INTL("{1} triggered!", getAbilityName(:ZENMODE)))
            end
        end
        # Minior - Shields Down
        if isSpecies?(:MINIOR) && hasAbility?(:SHIELDSDOWN)
            if @hp > @totalhp / 2 # Turn into Meteor form
                newForm = (@form >= 7) ? @form - 7 : @form
                if @form != newForm
                    @battle.pbShowAbilitySplash(self, :SHIELDSDOWN, true)
                    @battle.pbHideAbilitySplash(self)
                    pbChangeForm(newForm, _INTL("{1} deactivated!", getAbilityName(:SHIELDSDOWN)))
                elsif !endOfRound
                    @battle.pbDisplay(_INTL("{1} deactivated!", getAbilityName(:SHIELDSDOWN)))
                end
            elsif @form < 7 # Turn into Core form
                @battle.pbShowAbilitySplash(self, :SHIELDSDOWN, true)
                @battle.pbHideAbilitySplash(self)
                pbChangeForm(@form + 7, _INTL("{1} activated!", getAbilityName(:SHIELDSDOWN)))
            end
        end
        # Wishiwashi - Schooling
        if isSpecies?(:WISHIWASHI) && hasAbility?(:SCHOOLING)
            if @level >= 20 && @hp > @totalhp / 4
                if @form != 1
                    @battle.pbShowAbilitySplash(self, :SCHOOLING, true)
                    @battle.pbHideAbilitySplash(self)
                    pbChangeForm(1, _INTL("{1} formed a school!", pbThis))
                end
            elsif @form != 0
                @battle.pbShowAbilitySplash(self, :SCHOOLING, true)
                @battle.pbHideAbilitySplash(self)
                pbChangeForm(0, _INTL("{1} stopped schooling!", pbThis))
            end
        end
        # Zygarde - Power Construct
        if isSpecies?(:ZYGARDE) && hasAbility?(:POWERCONSTRUCT) && endOfRound && (@hp <= @totalhp / 2 && @form < 2) # Turn into Complete Forme
            newForm = @form + 2
            @battle.pbDisplay(_INTL("You sense the presence of many!"))
            @battle.pbShowAbilitySplash(self, :POWERCONSTRUCT, true)
            @battle.pbHideAbilitySplash(self)
            pbChangeForm(newForm, _INTL("{1} transformed into its Complete Forme!", pbThis))
        end
    end

    def pbTransform(target)
        oldAbil = @ability_id
        applyEffect(:Transform)
        applyEffect(:TransformSpecies, target.species)
        pbChangeTypes(target)
        self.ability = target.baseAbility
        @attack = target.attack
        @defense = target.defense
        @spatk = target.spatk
        @spdef = target.spdef
        @speed = target.speed
        GameData::Stat.each_battle { |s| @stages[s.id] = target.stages[s.id] }
        # Copy critical hit chance raising effects
        target.eachEffect do |effect, value, data|
            @effects[effect] = value if data.critical_rate_buff?
        end
        @moves.clear
        target.moves.each_with_index do |m, i|
            @moves[i] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(m.id))
        end
        disableEffect(:Disable)
        @effects[:WeightChange] = target.effects[:WeightChange]
        refreshDataBox
        @battle.pbDisplay(_INTL("{1} transformed into {2}!", pbThis, target.pbThis(true)))
        pbOnAbilityChanged(oldAbil)
    end

    def pbHyperMode; end

    def getSubLife
        subLife = @totalhp / 4
        subLife = 1 if subLife < 1
        return subLife.floor
    end

    def createSubstitute
        subLife = getSubLife
        pbReduceHP(subLife, false, false)
        pbItemHPHealCheck
        disableEffect(:Trapping)
        applyEffect(:Substitute, subLife)
    end
end
