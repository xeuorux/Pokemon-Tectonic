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
        numFrames = (Graphics.frame_rate*0.4).floor
        alphaDiff = (255.0/numFrames).ceil
        for j in 0..numFrames
            opacity = (numFrames - j) * alphaDiff
            databoxes.each do |dataBox|
                next if dataBox.disposed?
                dataBox.opacity = opacity
                dataBox.update
            end
            yield opacity if block_given?
            Graphics.update
        end
    end

    def returnDataboxes
        numFrames = (Graphics.frame_rate*0.4).floor
        alphaDiff = (255.0/numFrames).ceil
        for j in 0..numFrames
            opacity = j * alphaDiff
            databoxes.each do |dataBox|
                next if dataBox.disposed?
                dataBox.opacity = opacity
                dataBox.update
            end
            yield opacity if block_given?
            Graphics.update
        end
    end

    def databoxes
        boxes = []
        eachBattler do |b|
            databox = scene.sprites["dataBox_#{b.index}"]
            boxes.push(databox)
        end
        return boxes
    end

    def amuletActivates(curseName, explanation = nil)
        echoln("Amulet actives!")
        pbDisplaySlower(_INTL("\\i[TAROTAMULET]The Tarot Amulet glows with power!"))

        curseBG = scene.pbAddSprite("curseBG",0,0,"Graphics/Pictures/cursebg",@viewport)
        curseBG.visible = true
        curseBG.z = 100_000

        hideDataboxes { |opacity|
            curseBG.opacity = (255 - opacity) / 2
        }

        # Show the curse name in a big bold way
        pbSEPlay("Anim/PRSFX- Spectral Thief2", 300, 20)
        pbSEPlay("Anim/PRSFX- Telekinesis", 100, 120)

        msgwindow = pbCreateMessageWindow
        msgwindow.z = 100_001
        waitTime = tutorialMessageDuration
        fontSize = 48
        msgwindow.lineHeight(48)
        curseName = _INTL("\\ts[]<c3=4C0D0D,FFFFFF22><b><outln2><ac><fs={1}>\\w[]\\wu\\l[12]{2}</fs></ac></outln2></b></c3>\\wt[{3}]",fontSize,curseName,waitTime)
        curseName = "<fn=Didact Gothic>" + curseName + "</fn>"
        pbMessageDisplay(msgwindow,curseName)

        pbDisplaySlower(explanation) if explanation
        pbDisposeMessageWindow(msgwindow)
        Input.update

        returnDataboxes { |opacity|
            curseBG.opacity = (255 - opacity) / 2
        }
        curseBG.visible = false
    end
end
