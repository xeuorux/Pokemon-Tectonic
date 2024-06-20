# Keys are an array of the [event ID, flag thats enabled when light is given, map id]
# Values are an array of possible clues to show when that light hasn't been grabbed
CONDENSED_LIGHT_LOCATIONS = {
    # Guitarist Reece in the Shipping Lane
    [18, "D", 60]   => [
        "Groceries from the south, Customers from the north.",
        "The path is full of crates. Not that he minds, he's out of the way.",
    ],
    # Security Guard in Novo College (Novo Town)
    [17, "A", 123]  => [
        "A lab opens its door to bones. Just next door is closed shut, however.",
        "A place of learning. It has its secrets, too.",
    ],
    # Pro Trainer Jade in Grouz
    [21, "D", 25]   => [
        "Green grass fades to brown...but Jade remains.",
        "Broken houses and broken wills, tough ones linger still.",
    ],
    # Dandy Charles in The Shelf
    [16, "D", 53]   => [
        "Grass, mud, and stink-weeds taller than people.",
        "Verdant forest. Layers of land and leaves.",
    ],
    # Aroma Lady Cheshire in the House of Leaves (Velenz)
    [1, "D", 9]     => [
        "A pitiful town, it's all fallen down. She's got her place.",
        "A bit of order planted in the chaos. Visitors must be pruned.",
    ],
    # Guitarist in the Crater Station Backroom (Barren Crater)
    [2, "A", 321]   => [
        "A musician makes their mark in the Medusa's mandate.",
        "Statues, statues, eerie indeed. But the show must go on.",
    ],
    # Tourist in the Travel Agency (Prizca West)
    [23, "A", 159]  => [
        "A city of chain links. Why not go somewhere else?",
        "A road with no cars. Must you buy your way to freedom?",
    ],
    # Camera Man in the Makyan Capitol Building (Prizca East)
    [24, "A", 194]  => [
        "Old bricks look down upon you. You're not in charge, here.",
        "Big city, big buildings. The halls of government.",
    ],
    # NPC on the cliff in Frostflow Farms
    [21, "A", 186]  => [
        "A tiny bit of cliff. You can just barely smell the honey from here.",
        "Seas of wheat beckon you to cross. What a view!",
    ],
    # Cyclist Lukka in the Split Peaks
    [19, "D", 211]  => [
        "The rocky path less traveled. Southern brother.",
        "The easy way is a whole forest away. Take a hike!",
    ],
    # Worker Seamus in the Canal Desert
    [14, "D", 130]  => [
        "Sun on sand on water. A maze of tributaries.",
        "One man works to keep back the tide of sand.",
    ],
    # Psychic Felicia in the Cave of Hatching
    [11, "D", 257]  => [
        "A view of where the First Champion was hatched.",
        "A proving ground, underground. A home for would-be mothers.",
    ],
    # Kimono Girl Chiyo in the Kilna Ascent
    [19, "D", 121]  => [
        "Past the guardian dragon. Climb, climb, climb!",
        "Thick clouds and stars not right. But you're above all that, now.",
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
        # Don't show the hint for the event thats giving the light
        if $game_map.map_id == key[2] && @event_id == key[0]
            echoln("Skipping this event for the condensed light hint!")
            next
        end
        possibleHints.concat(value)
    end
    hint = _INTL(possibleHints.sample)
    pbMessage(_INTL("\\wm\\ss<i>{1}</i>", hint))
end

def collectedEnoughLight
    return pbQuantity(:CONDENSEDLIGHT) >= condensedLightCount
end