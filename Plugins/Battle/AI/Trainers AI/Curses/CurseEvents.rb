class PokeBattle_Battle
    BattleStartApplyCurse	= HandlerHash2.new
    BattleEndCurse	= HandlerHash2.new
    BattlerEnterCurseEffect	= HandlerHash2.new
    BattlerFaintedCurseEffect	= HandlerHash2.new
    EffectivenessChangeCurseEffect	= HandlerHash2.new
    MoveUsedCurseEffect	= HandlerHash2.new
    BeginningOfTurnCurseEffect	= HandlerHash2.new

    def triggerBattleStartApplyCurse(curse_policy, battle, curses_array)
        ret = BattleStartApplyCurse.trigger(curse_policy, battle, curses_array)
        return ret || curses_array
    end

    def triggerBattleEndCurse(curse_policy, battle)
        BattleEndCurse.trigger(curse_policy, battle)
    end

    def triggerBattlerEnterCurseEffect(curse_policy, battler, battle)
        ret = BattlerEnterCurseEffect.trigger(curse_policy, battler, battle)
        return ret || false
    end

    def triggerBattlerFaintedCurseEffect(curse_policy, battler, battle)
        ret = BattlerFaintedCurseEffect.trigger(curse_policy, battler, battle)
        return ret || false
    end

    def triggerEffectivenessChangeCurseEffect(curse_policy, moveType, user, target, effectiveness)
        ret = EffectivenessChangeCurseEffect.trigger(curse_policy, moveType, user, target, effectiveness)
        return ret || effectiveness
    end

    def triggerBeginningOfTurnCurseEffect(curse_policy, battle)
        BeginningOfTurnCurseEffect.trigger(curse_policy, battle)
    end

    def triggerMoveUsedCurseEffect(curse_policy, user, target, move)
        ret = MoveUsedCurseEffect.trigger(curse_policy, user, target, move)
        return ret || true
    end

    def hideDataboxes
        eachBattler do |b|
            databox = scene.sprites["dataBox_#{b.index}"]
            databox.visible = false
        end
    end

    def showDataboxes
        eachBattler do |b|
            databox = scene.sprites["dataBox_#{b.index}"]
            databox.visible = true
        end
    end

    def amuletActivates(curseName, explanation = nil)
        echoln("Amulet actives!")
        pbDisplaySlower(_INTL("\\i[TAROTAMULET]The Tarot Amulet glows with power!"))

        hideDataboxes

        # Show the curse name in a big bold way
        pbSEPlay("Anim/PRSFX- Spectral Thief2", 300, 20)
        pbSEPlay("Anim/PRSFX- Telekinesis", 100, 120)

        msgwindow = pbCreateMessageWindow
        waitTime = 40
        waitTime /= 2 if fastTransitions?
        fontSize = 48
        msgwindow.lineHeight(48)
        curseName = _INTL("\\ts[]<c3=4C0D0D,FFFFFF22><b><outln2><ac><fs={1}>\\w[]\\wu\\l[12]{2}</fs></ac></outln2></b></c3>\\wt[{3}]",fontSize,curseName,waitTime)
        curseName = "<fn=Didact Gothic>" + curseName + "</fn>"
        pbMessageDisplay(msgwindow,curseName)

        pbDisplaySlower(explanation) if explanation
        pbDisposeMessageWindow(msgwindow)
        Input.update

        showDataboxes
    end
end
