
class PokeBattle_Battle
    def pbStartRoom(roomEffect, user, aiCheck = false)
        duration = user.getRoomDuration(aiCheck)
        effectName = GameData::BattleEffect.get(roomEffect).name
        
        if @field.effectActive?(roomEffect)
            if @field.countEffect(roomEffect) >= duration
                pbDisplay(_INTL("The #{effectName} stayed the same.")) unless aiCheck
                return 0
            else
                if aiCheck
                    return (duration - @field.countEffect(roomEffect)) * 20
                else
                    pbDisplay(_INTL("The #{effectName} was refreshed!"))
                    @field.effects[roomEffect] = duration
                end
            end
        else
            if aiCheck
                return duration * 20
            else
                @field.applyEffect(roomEffect, duration)
            end
        end
        
        if aiCheck
            return 0
        else
            moreTurns = duration
            moreTurns -= 1 unless @turnCount == 0
            pbDisplay(_INTL("It'll last for #{moreTurns} more turns."))
        end
    end
end