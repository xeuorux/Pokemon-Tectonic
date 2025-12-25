BattleHandlers::UserAbilityOnSemiInvulnerable.add(:LIVEANDLURK,
  proc { |ability, user, move, battle, aiCheck|
      healingMessage = _INTL("{1} regenerates in safety.", user.pbThis)
      next user.applyFractionalHealing(1.0/4.0, ability: :LIVEANDLURK, customMessage: healingMessage, canOverheal: true, aiCheck: aiCheck)
  }
)

BattleHandlers::UserAbilityOnSemiInvulnerable.add(:SHOWOFF,
  proc { |ability, user, move, battle, aiCheck|
      score = 0
      user.eachOpposing do |b|
        if aiCheck
          score += getMultiStatDownEffectScore(ATTACKING_STATS_1, user, b)
        else
          b.pbLowerMultipleStatSteps(ATTACKING_STATS_1, user, showFailMsg: true, ability: ability)
        end
      end
      next score
  }
)