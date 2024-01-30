#===============================================================================
# Scatters coins that the player picks up after winning the battle. (Pay Day)
#===============================================================================
class PokeBattle_Move_AddMoneyGainedFromBattle < PokeBattle_Move
    def pbEffectGeneral(user)
        @battle.field.incrementEffect(:PayDay, 5 * user.level) if user.pbOwnedByPlayer?
    end
end

#===============================================================================
# Scatters lots of coins that the player picks up after winning the battle. (Cha-ching)
#===============================================================================
class PokeBattle_Move_AddLotsOfMoneyGainedFromBattle < PokeBattle_Move
    def pbEffectGeneral(user)
        @battle.field.incrementEffect(:PayDay, 8 * user.level) if user.pbOwnedByPlayer?
    end
end

#===============================================================================
# If it faints the target, you gain lots of money after the battle. (Plunder)
#===============================================================================
class PokeBattle_Move_IfFaintsTargetAddTonsOfMoneyGainedFromBattle < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return unless target.damageState.fainted
        @battle.field.incrementEffect(:PayDay, 15 * user.level) if user.pbOwnedByPlayer?
    end
end