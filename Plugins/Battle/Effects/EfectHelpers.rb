def invulnerableProtectEffects()
    return [PBEffects::Protect,PBEffects::Obstruct,PBEffects::KingsShield,PBEffects::SpikyShield,
        PBEffects::BanefulBunker,PBEffects::RedHotRetreat,PBEffects::MatBlock,PBEffects::MirrorShield]
  end

def singleProtectEffects()
    return [PBEffects::BanefulBunker,PBEffects::RedHotRetreat,PBEffects::KingsShield,PBEffects::Protect,PBEffects::SpikyShield,PBEffects::MirrorShield]
end

def sideProtectEffects()
    return [PBEffects::CraftyShield,PBEffects::MatBlock,PBEffects::QuickGuard,PBEffects::WideGuard,PBEffects::Bulwark]
end
  
class PokeBattle_Move
    def removeProtections(target)
        singleProtectEffects().each do |single_protect_effect|
            target.effects[single_protect_effect] = false
        end
        sideProtectEffects().each do |side_protect_effect|
            target.pbOwnSide.effects[side_protect_effect] = false
        end
    end
end

PUZZLE_ROOM_DESCRIPTION = "puzzling area in which Pokémon's Attack and Sp. Atk are swapped".freeze
TRICK_ROOM_DESCRIPTION = "tricky area in which Speed functions in reverse".freeze
WONDER_ROOM_DESCRIPTION = "wondrous area in which the Defense and Sp. Def stats are swapped".freeze
MAGIC_ROOM_DESCRIPTION = "bizarre area in which Pokémon's held items lose their effects".freeze
ODD_ROOM_DESCRIPTION = "odd area in which Pokémon's Offensive and Defensive stats are swapped".freeze


def effectsEoR(effects,remain_proc,expire_proc)
    changedEffects = {}
    effects.each do |effect, value|
        effectData = GameData::BattleEffect.get(effect)
        next if effectData.nil?
        # Tick down active effects that tick down
        if effectData.ticks_down && effectData.active_value?(value)
            newValue = value - effectData.tick_amount
            newValue = 0 if newValue < 0 && !effectData.ticks_past_zero
            if effectData.active_value?(newValue)
                remain_proc.call(effectData)
            else
                effectData.eachConnectedEffect do |otherEffect, otherData|
                    changedEffects[otherEffect] = otherData.default
                end
                expire_proc.call(effectData)
            end
            changedEffects[effect] = newValue
        end
        if effectData.resets_eor && value != effectData.default
            changedEffects[effect] = effectData.default
        end
    end
    effects.update(changedEffects)
end