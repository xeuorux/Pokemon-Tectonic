GameData::BattleWeather.register({
  :id        => :AcidRain,
  :name      => _INTL("Acid Rain"),
  :animation => "ShadowSky"
})

class PokeBattle_Battler
    def takesAcidRainDamage?
        return false if !takesIndirectDamage?
        return false if pbHasType?(:POISON) || pbHasType?(:DARK)
        return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
        return false if hasActiveAbility?([:OVERCOAT])
        return false if hasActiveItem?(:SAFETYGOGGLES)
        return true
      end
end