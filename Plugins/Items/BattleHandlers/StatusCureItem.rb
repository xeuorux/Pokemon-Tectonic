BattleHandlers::StatusCureItem.add(:ASPEARBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.hasStatusNoTrigger(:FROZEN)
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    battler.pbCureStatus(forced,:FROZEN)
    battle.pbDisplay(_INTL("{1}'s {2} unchilled it!",battler.pbThis,itemName)) if !forced
    next true
  }
)

BattleHandlers::StatusCureItem.add(:CHERIBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.hasStatusNoTrigger(:PARALYSIS)
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    battler.pbCureStatus(forced,:PARALYSIS)
    battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,itemName)) if !forced
    next true
  }
)

BattleHandlers::StatusCureItem.add(:CHESTOBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.hasStatusNoTrigger(:SLEEP)
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    battler.pbCureStatus(forced,:SLEEP)
    battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,itemName)) if !forced
    next true
  }
)

BattleHandlers::StatusCureItem.add(:PECHABERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.hasStatusNoTrigger(:POISON)
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    battler.pbCureStatus(forced,:POISON)
    battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",battler.pbThis,itemName)) if !forced
    next true
  }
)

BattleHandlers::StatusCureItem.add(:RAWSTBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.hasStatusNoTrigger(:BURN)
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    battler.pbCureStatus(forced,:BURN)
    battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,itemName)) if !forced
    next true
  }
)

BattleHandlers::StatusCureItem.add(:LUMBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.hasAnyStatusNoTrigger
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    battler.pbCureStatus
    next true
  }
)

# BattleHandlers::StatusCureItem.add(:PERSIMBERRY,
#   proc { |item,battler,battle,forced|
#     next false if !forced && !battler.canConsumeBerry?
#     next false if battler.effects[PBEffects::Confusion]==0 && battler.effects[PBEffects::Charm]==0
#     itemName = GameData::Item.get(item).name
#     PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
#     battle.pbCommonAnimation("EatBerry",battler) if !forced
#     wasConfused 	= (battler.effects[PBEffects::Confusion]>0)
#     wasCharmed		= (battler.effects[PBEffects::Charm]>0)
#       battler.pbCureConfusion
#     battler.pbCureCharm
#     if forced
# 		battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis)) if wasConfused
# 		battle.pbDisplay(_INTL("{1} was released from the charm.",battler.pbThis)) if wasCharmed
#     else
# 		battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",battler.pbThis,itemName)) if wasConfused
# 		battle.pbDisplay(_INTL("{1}'s {2} released it from the charm!",battler.pbThis,itemName)) if wasCharmed
#     end
#     next true
#   }
# )

BattleHandlers::StatusCureItem.add(:PERSIMBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.hasStatusNoTrigger(:FLUSTERED)
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    battler.pbCureStatus(forced,:FLUSTERED)
    battle.pbDisplay(_INTL("{1}'s {2} made it no longer flustered!",battler.pbThis,itemName)) if !forced
    next true
  }
)

BattleHandlers::StatusCureItem.add(:DURINBERRY,
  proc { |item,battler,battle,forced|
    next false if !forced && !battler.canConsumeBerry?
    next false if !battler.hasStatusNoTrigger(:MYSTIFIED)
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
    battle.pbCommonAnimation("EatBerry",battler) if !forced
    battler.pbCureStatus(forced,:MYSTIFIED)
    battle.pbDisplay(_INTL("{1}'s {2} made it no longer mystified!",battler.pbThis,itemName)) if !forced
    next true
  }
)

BattleHandlers::StatusCureItem.add(:MENTALHERB,
  proc { |item,battler,battle,forced|
    next false if battler.effects[PBEffects::Attract]==-1 &&
                  battler.effects[PBEffects::Taunt]==0 &&
                  battler.effects[PBEffects::Encore]==0 &&
                  !battler.effects[PBEffects::Torment] &&
                  battler.effects[PBEffects::Disable]==0 &&
                  battler.effects[PBEffects::HealBlock]==0 &&
				          battler.effects[PBEffects::Confusion]==0 &&
				          battler.effects[PBEffects::Charm]==0 &&
    itemName = GameData::Item.get(item).name
    PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
    battle.pbCommonAnimation("UseItem",battler) if !forced
    battle.pbDisplay(_INTL("{1}'s taunt wore off!",battler.pbThis)) if battler.effects[PBEffects::Taunt]>0
    battler.effects[PBEffects::Taunt]      = 0
    battle.pbDisplay(_INTL("{1}'s encore ended!",battler.pbThis)) if battler.effects[PBEffects::Encore]>0
    battler.effects[PBEffects::Encore]     = 0
    battler.effects[PBEffects::EncoreMove] = nil
    battle.pbDisplay(_INTL("{1}'s torment wore off!",battler.pbThis)) if battler.effects[PBEffects::Torment]
    battler.effects[PBEffects::Torment]    = false
    battle.pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis)) if battler.effects[PBEffects::Disable]>0
    battler.effects[PBEffects::Disable]    = 0
    battle.pbDisplay(_INTL("{1}'s Heal Block wore off!",battler.pbThis)) if battler.effects[PBEffects::HealBlock]>0
    battler.effects[PBEffects::HealBlock]  = 0
    battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",battler.pbThis,itemName)) if battler.effects[PBEffects::Confusion]>0
    battler.pbCureConfusion
    battle.pbDisplay(_INTL("{1}'s {2} released it from the charm!",battler.pbThis,itemName)) if battler.effects[PBEffects::Charm]>0
    battler.pbCureCharm
    next true
  }
)