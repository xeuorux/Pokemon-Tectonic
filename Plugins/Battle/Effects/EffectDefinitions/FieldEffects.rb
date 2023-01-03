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
        battle.eachBattler do |b|
            showMessage = false
            if b.inTwoTurnAttack?("0C9", "0CC", "0CE")   # Fly/Bounce/Sky Drop
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
        battle.pbDisplay(_INTL("Gravity returned to normal!"))
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
    :id => :MudSportField,
    :real_name => "Mud Sport Turns",
    :type => :Integer,
    :ticks_down => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("Electricity's power was weakened!"))
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The effects of Mud Sport have faded."))
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
    :id => :WaterSportField,
    :real_name => "Water Sport Turns",
    :type => :Integer,
    :ticks_down => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("Fire's power was weakened!"))
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The effects of Water Sport have faded."))
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
    :id => :MagicRoom,
    :real_name => "Magic Room Turns",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("A bizarre area appeared! Pokémon's held items lose their effects!"))
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The bizarre area went away."))
        battle.pbPriority(true).each { |b| b.pbItemTerrainStatBoostCheck }
        battle.pbPriority(true).each { |b| b.pbItemFieldEffectCheck }
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :TrickRoom,
    :real_name => "Trick Room Turns",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("A tricky area appeared! Speed functions in reverse!"))
    end,
    :disable_proc => proc do |battle, _battler|
        battle.pbDisplay(_INTL("The tricky room went away."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :WonderRoom,
    :real_name => "Wonder Room Turns",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("A wonderous area appeared! Defense and Sp. Def stats are swapped!"))
    end,
    :disable_proc => proc do |battle|
        battle.pbDisplay(_INTL("The wonderous area went away."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :PuzzleRoom,
    :real_name => "Puzzle Room Turns",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("A puzzling area appeared! Attack and Sp. Atk are swapped!"))
    end,
    :disable_proc => proc do |battle|
        battle.pbDisplay(_INTL("The puzzling area went away."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :OddRoom,
    :real_name => "Odd Room Turns",
    :type => :Integer,
    :ticks_down => true,
    :is_room => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("An odd area appeared! Offensive and Defensive stats are swapped!"))
    end,
    :disable_proc => proc do |battle|
        battle.pbDisplay(_INTL("The odd area went away."))
    end,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :TerrainSealant,
    :real_name => "Terrain Sealer",
    :type => :Position,
    :others_lose_track => true,
})

GameData::BattleEffect.register_effect(:Field, {
    :id => :GreyMist,
    :real_name => "Grey Mist Turns",
    :type => :Integer,
    :ticks_down => true,
    :apply_proc => proc do |battle, _value|
        battle.pbDisplay(_INTL("A grey mist enveloped the field."))
        battle.pbDisplay(_INTL("Stat changes will be reset each turn, for #{value - 1} more turns!", teamName))
    end,
    :disable_proc => proc do |battle|
        battle.pbDisplay(_INTL("The grey mist dissipated."))
    end,
    :eor_proc => proc do |battle, value|
        battle.battlers.each do |b|
            next unless b.hasAlteredStatStages?
            b.pbResetStatStages
            @battle.pbDisplay(_INTL("#{b.pbThis}'s stat changes were eliminated!"))
        end
    end,
})