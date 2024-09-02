#===============================================================================
# Renders item unusable (Slime Ball)
#===============================================================================
class PokeBattle_Move_RemovesTargetItem < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        return unless canKnockOffItems?(user, target)
        knockOffItems(user, target) do |_item, itemName|
            @battle.pbDisplay(_INTL("{1}'s {2} became unusuable, so it dropped it!", target.pbThis, itemName))
        end
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canKnockOffItems?(user, target)
        knockOffItems(user, target) do |_item, itemName|
            @battle.pbDisplay(_INTL("{1}'s {2} became unusuable, so it dropped it!", target.pbThis, itemName))
        end
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless canKnockOffItems?(user, target, true)
        score = 0
        target.eachItem do |itemID|
            score += 50
        end
        target.eachAIKnownItem do |itemID|
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
# Target drops its item. It regains the item at the end of the battle. (Knock Off)
# If target has a losable item, damage is multiplied by 1.5.
#===============================================================================
class PokeBattle_Move_RemovesTargetItemDamageBoost50Percent < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        if target.hasAnyItem?
            # NOTE: Damage is still boosted even if target has Sticky Hold or a
            #       substitute.
            baseDmg = (baseDmg * 1.5).round
        end
        return baseDmg
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canKnockOffItems?(user, target)
        knockOffItems(user, target)
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless canKnockOffItems?(user, target, true)
        score = 0
        target.eachItem do |itemID|
            score += 50
        end
        target.eachAIKnownItem do |itemID|
            case itemID
            when :EVIOLITE
                score += 50
            when :CRYSTALVEIL,:MEMORYSET,:PRISMATICPLATE
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
class PokeBattle_Move_ConsumesTargetBerries < PokeBattle_Move
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
        target.eachAIKnownItem do |item|
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
class PokeBattle_Move_DestroysBerriesGems < PokeBattle_Move
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
        target.eachAIKnownItem do |item|
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
class PokeBattle_Move_DestroysHerbs < PokeBattle_Move
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
            next unless GameData::Item.get(item).is_herb?
            target.removeItem(item)
            @battle.pbDisplay(_INTL("{1}'s {2} was blighted!", target.pbThis, itemName))
        end
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless canBlightTargetsItem?(target)
        score = 0
        target.eachAIKnownItem do |item|
            next unless canRemoveItem?(user, target, item, checkingForAI: true)
            next unless GameData::Item.get(item).is_herb?
            score += 50
        end
        return score
    end
end

#===============================================================================
# Target's "clothing items" are destroyed. (Up In Flames)
#===============================================================================
class PokeBattle_Move_DestroysClothing < PokeBattle_Move
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
            next unless GameData::Item.get(item).is_clothing?
            target.removeItem(item)
            @battle.pbDisplay(_INTL("{1}'s {2} went up in flames!", target.pbThis, itemName))
        end
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless canIncinerateTargetsItem?(target)
        score = 0
        target.eachAIKnownItem do |item|
            next unless canRemoveItem?(user, target, item, checkingForAI: true)
            next unless GameData::Item.get(item).is_clothing?
            score += 50
        end
        return score
    end
end

#===============================================================================
# User steals the target's items. (Covet, Ransack, Thief)
#===============================================================================
class PokeBattle_Move_StealsItem < PokeBattle_Move
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

#===============================================================================
# Steals the targets first stealable berry or gem. (Pilfer)
#===============================================================================
class PokeBattle_Move_StealsBerryGem < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        target.eachItem do |item|
            next unless GameData::Item.get(item).is_berry? || GameData::Item.get(item).is_gem?
            stealItem(user, target, item)
        end
    end

    def getEffectScore(user, target)
        score = 0
        target.eachItem do |item|
            next unless GameData::Item.get(item).is_berry? || GameData::Item.get(item).is_gem?
            score += 50 if canStealItem?(user, target, item)
        end
        return score
    end
end

#===============================================================================
# Fails if the Target has no Item (Poltergeist)
#===============================================================================
class PokeBattle_Move_FailsTargetNoItem < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.hasAnyItem?
            if show_message
                @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!", target.pbThis, target.itemCountD))
            end
            return false
        end
        @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have any items!")) if show_message
        return true
    end
end

#===============================================================================
# Target is forced to hold a Black Sludge, dropping its item if neccessary. (Trash Treasure)
# Also lower's the target's Sp. Def.
#===============================================================================
class PokeBattle_Move_TrashTreasure < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if !target.canAddItem?(:BLACKSLUDGE) && !canRemoveItem?(user, target, target.firstItem) && target.pbCanLowerStatStep?(:SPECIAL_DEFENSE,user,self)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis} can't be given a Black Sludge or have its Sp. Def lowered!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        giveSludge = false
        if target.canAddItem?(:BLACKSLUDGE)
            giveSludge = true
        else
            removedAny = false
            target.eachItemWithName do |item, itemName|
                next if item == :BLACKSLUDGE
                next unless canRemoveItem?(user, target, item)
                target.removeItem(item)
                @battle.pbDisplay(_INTL("{1} dropped its {2}!", target.pbThis, itemName))
                removedAny = true
                break
            end

            giveSludge = true if removedAny
        end

        if giveSludge
            @battle.pbDisplay(_INTL("{1} was forced to hold a {2}!", target.pbThis, getItemName(:BLACKSLUDGE)))
            target.giveItem(:BLACKSLUDGE)
        end
        
        target.tryLowerStat(:SPECIAL_DEFENSE, user, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        if target.canAddItem?(:BLACKSLUDGE) && canRemoveItem?(user, target, target.firstItem, checkingForAI: true)
            if target.pbHasTypeAI?(:POISON)
                score -= 50
            else
                score += 50
            end
        end
        score += getMultiStatDownEffectScore([:SPECIAL_DEFENSE,1],user,target)
        return score
    end
end

#===============================================================================
# The target cannnot use its held item, its held item has no
# effect, and no items can be used on it. (Embargo)
#===============================================================================
class PokeBattle_Move_Embargo < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.effectActive?(:Embargo)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already embargoed!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Embargo)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 0 unless target.hasAnyItem?
        return 50
    end
end

# Empowered Embargo
class PokeBattle_Move_EmpoweredEmbargo < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        user.pbOpposingSide.applyEffect(:EmpoweredEmbargo) unless user.pbOpposingSide.effectActive?(:EmpoweredEmbargo)
        transformType(user, :DARK)
    end
end