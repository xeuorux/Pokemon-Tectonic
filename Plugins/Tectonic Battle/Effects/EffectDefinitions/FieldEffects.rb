GameData::BattleEffect.register_effect(:Field, {
    :id => :AmuletCoin,
    :real_name => "Amulet Coin",
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :FairyLock,
    :real_name => "Fairy Lock",
    :type => :Integer,
    :ticks_down => true,
    :trapping => true,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :FusionBolt,
    :real_name => "Fusion Bolt",
    :resets_eor => true,
    :resets_on_move_start => true,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :FusionFlare,
    :real_name => "Fusion Flare",
    :resets_eor => true,
    :resets_on_move_start => true,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :Gravity,
    :real_name => "Gravity Turns",
    :type => :Integer,
    :ticks_down => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("Gravity intensified!"))
        battle.pbDisplay(_INTL("Everyone is twice as accurate!"))
        battle.eachBattler do |b|
            showMessage = false
            if b.inTwoTurnSkyAttack?
                b.disableEffect(:TwoTurnAttack)
                battle.pbClearChoice(b.index) unless b.movedThisRound?
                showMessage = true
            end
            if b.effectActive?(:MagnetRise) || b.effectActive?(:Telekinesis) || b.effectActive?(:SkyDrop)
                b.disableEffect(:MagnetRise)
                b.disableEffect(:Telekinesis)
                b.disableEffect(:SkyDrop)
                showMessage = true
            end
            battle.pbDisplay(_INTL("{1} couldn't stay airborne because of gravity!", b.pbThis)) if showMessage
        end
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("Gravity was forced back to normal!"))
    end,
    :expire_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("Gravity returned to normal."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :HappyHour,
    :real_name => "Happy Hour",
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :IonDeluge,
    :real_name => "Ion Deluge",
    :resets_eor => true,
    :disable_proc => proc do |battle, _battler|
                         battle.pbDisplay(_INTL("A deluge of ions showers the battlefield!"))
                     end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :PayDay,
    :real_name => "Money Dropped",
    :type => :Integer,
    :increment_proc => proc do |battle, _value, _increment|
        battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :Fortune,
    :real_name => "Fortune",
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :NeutralizingGas,
    :real_name => "Neutralizing Gas",
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("Gas nullified all abilities!"))
    end,
    :disable_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("The Neutralizing Gas dissipated."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :TrickRoom,
    :real_name => "Trick Room",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("A tricky area appeared! Speed functions in reverse!"))
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The tricky area was dispelled!"))
    end,
    :expire_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The tricky area fell away."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :PuzzleRoom,
    :real_name => "Puzzle Room",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("A puzzling area appeared! Attack and Sp. Atk are swapped!"))
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The puzzling area was dispelled!"))
    end,
    :expire_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The puzzling area fell away."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :OddRoom,
    :real_name => "Odd Room",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("An odd area appeared! Offensive and Defensive stats are swapped!"))
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The odd area was dispelled!"))
    end,
    :expire_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The odd area fell away."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :PolarizedRoom,
    :real_name => "Polarized Room",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("A polarized area appeared! Type effectiveness is exaggerated!"))
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The polarized area was dispelled!"))
    end,
    :expire_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The polarized area fell away."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :InsightRoom,
    :real_name => "Insight Room",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("An insightful area appeared! Everyone gets a 5th move!"))

        # AI learns of the battler's possible insight room move
        # It either has it from insight room or has it already
        battle.eachBattler do |b|
            b.aiSeesMove(b.getHighestLearnsetMoveID)
        end
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The insightful area was dispelled!"))
    end,
    :expire_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The insightful area fell away."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :EmotionRoom,
    :real_name => "Emotion Room",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("An emotional area appeared! Everyone switches ability every turn!"))
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The emotional area was dispelled!"))
    end,
    :expire_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The emotional area fell away."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :WillfulRoom,
    :real_name => "Willful Room",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("A willful area appeared! Everyone takes 30 less damage on hits!"))
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The willful area was dispelled!"))
    end,
    :expire_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The willful area fell away."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :GreyMist,
    :real_name => "Grey Mist Turns",
    :type => :Integer,
    :ticks_down => true,
    :apply_proc => proc do |battle, value|
        battle.pbDisplay(_INTL("A grey mist enveloped the field."))
        battle.pbDisplay(_INTL("Stat changes will be reset each turn, for #{value - 1} more turns!"))
    end,
    :disable_proc => proc do |battle|
        battle.pbDisplay(_INTL("The grey mist was expunged!"))
    end,
    :expire_proc => proc do |battle|
        battle.pbDisplay(_INTL("The grey mist dissipated."))
    end,
    :eor_proc => proc do |battle, value|
        battle.eachBattler do |b|
            next unless b.hasAlteredStatSteps?
            b.pbResetStatSteps
            battle.pbDisplay(_INTL("#{b.pbThis}'s stat changes were eliminated!"))
        end
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :Bliss,
    :real_name => "Bliss",
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :FloralGramarye,
    :real_name => "Floral Gramarye",
    :type => :Integer,
    :ticks_down => true,
    :eor_proc => proc do |battle, value|
        battle.eachBattler do |b|
            next unless b.canHeal?
            b.applyFractionalHealing(1.0/8.0, customMessage: _INTL("{1} was healed by the field of flowers!",b.pbThis))
        end
    end,
})