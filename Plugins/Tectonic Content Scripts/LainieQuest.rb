CONDENSED_LIGHT_COUNT = 13

def giveCondensedLight
    pbMessage(_INTL("<i>The mention of a certain someone manifests a ball of light...</i>"))
    pbReceiveItem(:CONDENSEDLIGHT)
    if pbQuantity(:CONDENSEDLIGHT) >= CONDENSED_LIGHT_COUNT
        pbMessage(_INTL("<i>You get the sense that you've collected enough light.</i>"))
        pbMessage(_INTL("<i>Your friend will be very pleased.</i>"))
        pbMessage(_INTL("<i>You should visit her in her very nice house.</i>"))
    end
end

def collectedEnoughLight
    return pbQuantity(:CONDENSEDLIGHT) >= CONDENSED_LIGHT_COUNT
end