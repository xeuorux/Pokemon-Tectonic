# Keys are an array of the [event ID, flag thats enabled when light is given, map id]
# Values are an array of possible clues to show when that light hasn't been grabbed
CONDENSED_LIGHT_LOCATIONS = {
    # Guitarist Reece in the Shipping Lane
    [18, "D", 60]   => [
        "Groceries from the south, Customers from the north.",
    ],
    # Security Guard in Novo College (Novo Town)
    [17, "A", 123]  => [
        "That strange room at the end of the corridor, why is it guarded?",
        "A place of learning. It has its secrets, too.",
    ],
    # Pro Trainer Jade in Grouz
    [21, "D", 25]   => [
        "Green turns to brown...but Jade remains.",
    ],
    # Dandy Charles in The Shelf
    [16, "D", 53]   => [
        "Grass, mud, and weeds taller than people.",
    ],
    # Aroma Lady Cheshire in the House of Leaves (Velenz)
    [1, "D", 9]     => [
        "A pitiful town, it's all fallen down.",
        "A bit of order in the chaos. Visitors must be pruned.",
    ],
    # Guitarist in the Crater Station Backroom (Barren Crater)
    [2, "A", 321]   => [
        "A musician makes their mark in the Medusa's mandate.",
    ],
    # Tourist in the Travel Agency (Prizca West)
    [23, "A", 159]  => [
        "A city of chain links. Why not go somewhere else?",
        "A road with no cars. Must you buy your way to freedom?",
    ],
    # Camera Man in the Makyan Capitol Building (Prizca East)
    [24, "A", 194]  => [
        "Teaming bureaucracy. Old bricks.",
    ],
    # NPC on the cliff in Frostflow Farms
    [21, "A", 186]  => [
        "A tiny bit of cliff. You can barely see the honey from here.",
    ],
    # Cyclist Lukka in the Split Peaks
    [19, "D", 211]  => [
        "The path less traveled. Southern facing mountains.",
    ],
    # Worker Seamus in the Canal Desert
    [14, "D", 130]  => [
        "Flora migration. Orre's Cacti.",
        "One man works to keep back the tide of sand.",
    ],
    # Psychic Felicia in the Cave of Hatching
    [11, "D", 257]  => [
        "The Cave where the First Champion came to be.",
        "A proving ground, underground. Overwhelming, isn't it?",
    ],
    # Kimono Girl Chiyo in the Kilna Ascent
    [19, "D", 121]  => [
        "Past the guardian dragon. Climb, climb, climb!",
        "A maiden of the east. Poor clothes for mountain-climbing.",
    ],
}

def condensedLightCount
    return CONDENSED_LIGHT_LOCATIONS.keys.count
end

def giveCondensedLight
    pbMessage(_INTL("\\wm<i>The mention of a certain someone manifests a ball of light...</i>"))
    pbReceiveItem(:CONDENSEDLIGHT)
    if pbQuantity(:CONDENSEDLIGHT) >= condensedLightCount
        pbMessage(_INTL("\\wm<i>You get the sense that you've collected enough light.</i>"))
        pbMessage(_INTL("\\wm<i>Your friend will be very pleased.</i>"))
        pbMessage(_INTL("\\wm<i>You should visit her in her very nice house.</i>"))
    elsif pbQuantity(:CONDENSEDLIGHT) >= (condensedLightCount * 0.75).ceil # 75% done or more
        pbMessage(_INTL("\\wm<i>You're getting close, now.</i>"))
        showCondensedLightHint
    elsif pbQuantity(:CONDENSEDLIGHT) == (condensedLightCount / 2).ceil # Half done, or slightly more
        pbMessage(_INTL("\\wm<i>You get the sense that you've found about half the light you need.</i>"))
        pbMessage(_INTL("\\wm<i>Your friend is waiting with anticipation.</i>"))
        pbMessage(_INTL("\\wm<i>Continue your collection.</i>"))
    end
end

def showCondensedLightHint
    pbMessage(_INTL("\\wm<i>A vision appears in your mind...</i>"))
    possibleHints = []
    CONDENSED_LIGHT_LOCATIONS.each do |key, value|
        next if pbGetSelfSwitch(key[0],key[1],key[2])
        possibleHints.concat(value)
    end
    hint = _INTL(possibleHints.sample)
    pbMessage(_INTL("\\wm\\ss<i>{1}</i>", hint))
end

def collectedEnoughLight
    return pbQuantity(:CONDENSEDLIGHT) >= condensedLightCount
end