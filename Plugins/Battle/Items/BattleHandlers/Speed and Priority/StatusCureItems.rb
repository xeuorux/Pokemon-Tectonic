BattleHandlers::StatusCureItem.add(:ASPEARBERRY,
  proc { |item, battler, battle, forced|
      next false if !forced && !battler.canConsumeBerry?
      next false unless battler.hasStatusNoTrigger(:FROZEN)
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry", battler) unless forced
      battler.pbCureStatus(forced, :FROZEN)
      battle.pbDisplay(_INTL("{1}'s {2} unchilled it!", battler.pbThis, itemName)) unless forced
      next true
  }
)

BattleHandlers::StatusCureItem.add(:CHERIBERRY,
  proc { |item, battler, battle, forced|
      next false if !forced && !battler.canConsumeBerry?
      next false unless battler.hasStatusNoTrigger(:NUMB)
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry", battler) unless forced
      battler.pbCureStatus(forced, :NUMB)
      battle.pbDisplay(_INTL("{1}'s {2} cured its numb!", battler.pbThis, itemName)) unless forced
      next true
  }
)

BattleHandlers::StatusCureItem.add(:CHESTOBERRY,
  proc { |item, battler, battle, forced|
      next false if !forced && !battler.canConsumeBerry?
      next false unless battler.hasStatusNoTrigger(:SLEEP)
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry", battler) unless forced
      battler.pbCureStatus(forced, :SLEEP)
      battle.pbDisplay(_INTL("{1}'s {2} woke it up!", battler.pbThis, itemName)) unless forced
      next true
  }
)

BattleHandlers::StatusCureItem.add(:PECHABERRY,
  proc { |item, battler, battle, forced|
      next false if !forced && !battler.canConsumeBerry?
      next false unless battler.hasStatusNoTrigger(:POISON)
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry", battler) unless forced
      battler.pbCureStatus(forced, :POISON)
      battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!", battler.pbThis, itemName)) unless forced
      next true
  }
)

BattleHandlers::StatusCureItem.add(:RAWSTBERRY,
  proc { |item, battler, battle, forced|
      next false if !forced && !battler.canConsumeBerry?
      next false unless battler.hasStatusNoTrigger(:BURN)
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry", battler) unless forced
      battler.pbCureStatus(forced, :BURN)
      battle.pbDisplay(_INTL("{1}'s {2} healed its burn!", battler.pbThis, itemName)) unless forced
      next true
  }
)

BattleHandlers::StatusCureItem.add(:LUMBERRY,
  proc { |item, battler, battle, forced|
      next false if !forced && !battler.canConsumeBerry?
      next false unless battler.hasAnyStatusNoTrigger
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry", battler) unless forced
      battler.pbCureStatus
      next true
  }
)

BattleHandlers::StatusCureItem.add(:PERSIMBERRY,
  proc { |item, battler, battle, forced|
      next false if !forced && !battler.canConsumeBerry?
      next false unless battler.hasStatusNoTrigger(:DIZZY)
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry", battler) unless forced
      battler.pbCureStatus(forced, :DIZZY)
      battle.pbDisplay(_INTL("{1}'s {2} made it no longer dizzy!", battler.pbThis, itemName)) unless forced
      next true
  }
)

BattleHandlers::StatusCureItem.add(:SPELONBERRY,
  proc { |item, battler, battle, forced|
      next false if !forced && !battler.canConsumeBerry?
      next false unless battler.hasStatusNoTrigger(:LEECHED)
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry", battler) unless forced
      battler.pbCureStatus(forced, :LEECHED)
      battle.pbDisplay(_INTL("{1}'s {2} made it no longer leeched!", battler.pbThis, itemName)) unless forced
      next true
  }
)

BattleHandlers::StatusCureItem.add(:MENTALHERB,
  proc { |item, battler, battle, forced|
      activate = false
      battler.eachEffect(true) do |_effect, _value, data|
          next unless data.is_mental?
          activate = true
          break
      end
      activate = true if battler.dizzy?

      next false unless activate

      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
      battle.pbCommonAnimation("UseItem", battler) unless forced

      # Disable all mental effects
      battler.eachEffect(true) do |effect, _value, data|
          next unless data.is_mental?
          battler.disableEffect(effect)
      end
      battler.pbCureStatus(true, :DIZZY) if battler.dizzy?
      next true
  }
)
