#===============================================================================
# Target drops its item. It regains the item at the end of the battle. (Knock Off)
# If target has a losable item, damage is multiplied by 1.5.
#===============================================================================
class PokeBattle_Move_0F0 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        if target.hasAnyItem?
            # NOTE: Damage is still boosted even if target has Sticky Hold or a
            #       substitute.
            baseDmg = (baseDmg * 1.5).round
        end
        return baseDmg
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canknockOffItems?(user, target)
        knockOffItems(user, target)
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless canknockOffItems?(user, target, true)
        score = 0
        target.eachItem do |itemID|
            score += 50
            case itemID
            when :EVIOLITE
                score += 50
            when :CRYSTALVEIL
                score += 20
            when :POWERLOCK,:ENERGYLOCK
                score += 20
            end
        end
        score /= 2 unless target.itemActive?
        return score
    end
end

#===============================================================================
# User consumes target's berries and gains its effect. (Bug Bite, Pluck)
#===============================================================================
class PokeBattle_Move_0F4 < PokeBattle_Move
    def canPluckBerry?(_user, target)
        return false if target.fainted?
        return false if target.damageState.berryWeakened
        return true
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canPluckBerry?(user, target)
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item)
            next unless GameData::Item.get(item).is_berry?
            target.removeItem(item)
            @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!", user.pbThis, itemName))
            user.pbHeldItemTriggerCheck(item, false)
        end
    end

    def getEffectScore(user, target)
        return 0 unless canPluckBerry?(user, target)
        score = 0
        target.eachItem do |item|
            next unless canRemoveItem?(user, target, item, checkingForAI: true)
            next unless GameData::Item.get(item).is_berry?
            score += 50
        end
        return score
    end
end

#===============================================================================
# Target's berry/Gem is destroyed. (Incinerate)
#===============================================================================
class PokeBattle_Move_0F5 < PokeBattle_Move
    def canIncinerateTargetsItem?(target, checkingForAI = false)
        if checkingForAI
            return false if target.substituted?
        elsif target.damageState.substitute || target.damageState.berryWeakened
            return false
        end
        return true
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canIncinerateTargetsItem?(target)
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item)
            itemData = GameData::Item.get(item)
            next unless itemData.is_berry? || itemData.is_gem?
            target.removeItem(item)
            @battle.pbDisplay(_INTL("{1}'s {2} was destroyed!", target.pbThis, itemName))
        end
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless canIncinerateTargetsItem?(target)
        score = 0
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item, checkingForAI: true)
            itemData = GameData::Item.get(item)
            next unless itemData.is_berry? || itemData.is_gem?
            score += 30
        end
        return score
    end
end

#===============================================================================
# Target's Herb items are destroyed. (Blight)
#===============================================================================
class PokeBattle_Move_5D5 < PokeBattle_Move
    def canBlightTargetsItem?(target, checkingForAI = false)
        if checkingForAI
            return false if target.substituted?
        elsif target.damageState.substitute
            return false
        end
        return true
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canBlightTargetsItem?(target)
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item)
            next unless HERB_ITEMS.include?(item)
            target.removeItem(item)
            @battle.pbDisplay(_INTL("{1}'s {2} was blighted!", target.pbThis, itemName))
        end
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless canBlightTargetsItem?(target)
        score = 0
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item, checkingForAI: true)
            next unless HERB_ITEMS.include?(item)
            score += 30
        end
        return score
    end
end

#===============================================================================
# Target's "clothing items" are destroyed. (Up In Flames)
#===============================================================================
class PokeBattle_Move_541 < PokeBattle_Move
    def canIncinerateTargetsItem?(target, checkingForAI = false)
        if checkingForAI
            return false if target.substituted?
        elsif target.damageState.substitute
            return false
        end
        return true
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canIncinerateTargetsItem?(target)
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item)
            next unless CLOTHING_ITEMS.include?(item)
            target.removeItem(item)
            @battle.pbDisplay(_INTL("{1}'s {2} went up in flames!", target.pbThis, itemName))
        end
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless canIncinerateTargetsItem?(target)
        score = 0
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item, checkingForAI: true)
            next unless CLOTHING_ITEMS.include?(item)
            score += 30
        end
        return score
    end
end

#===============================================================================
# User steals the target's items. (Covet, Ransack, Thief)
#===============================================================================
class PokeBattle_Move_0F1 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        target.eachItem do |item|
            stealItem(user, target, item)
        end
    end

    def getEffectScore(user, target)
        score = 0
        target.eachItem do |item|
            score += 50 if canStealItem?(user, target, item)
        end
        return score
    end

    def shouldHighlight?(user, target)
        return target.hasAnyItem? && user.canAddItem?
    end
end