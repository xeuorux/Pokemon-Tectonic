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

PUZZLE_ROOM_DESCRIPTION = "puzzling area in which Pokémon's Attack and Sp. Atk are swapped"
TRICK_ROOM_DESCRIPTION = "tricky area in which Speed functions in reverse"
WONDER_ROOM_DESCRIPTION = "wondrous area in which the Defense and Sp. Def stats are swapped"
MAGIC_ROOM_DESCRIPTION = "bizarre area in which Pokémon's held items lose their effects"
ODD_ROOM_DESCRIPTION = "odd area in which Pokémon's Offensive and Defensive stats are swapped"