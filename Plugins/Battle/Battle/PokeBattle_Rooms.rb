
class PokeBattle_Battle
    def pbStartRoom(roomEffect, user)
        duration = user.getRoomDuration
        effectName = GameData::BattleEffect.get(roomEffect).real_name
        if @field.effectActive?(roomEffect)
            if @field.effects[roomEffect] >= duration
                pbDisplay(_INTL("The #{effectName} stayed the same."))
                return
            else
                pbDisplay(_INTL("The #{effectName} was refreshed!"))
                @field.effects[roomEffect] = duration
            end
        else
            @field.applyEffect(roomEffect, duration)
        end
        moreTurns = duration
        moreTurns -= 1 unless @turnCount == 0
        pbDisplay(_INTL("It'll last for #{moreTurns} more turns."))
    end
end