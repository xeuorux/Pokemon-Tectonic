def unlockTools
    itemList = %i[
        BOXLINK
        AIDKIT
        STYLINGKIT
        BICYCLE
        EXPEZDISPENSER
        ABRAPORTER
        UNIVERSALFORMALIZER
        VIRALHELIX
        BALLLAUNCHER
        SURFBOARD
        CLIMBINGGEAR
        FLORASCEPTRE
        POKEXRAY
    ]
    
    itemList.each do |itemID|
        pbSilentItem(itemID) unless pbHasItem?(itemID)
    end

    pbRegisterItem(:TOWNMAP)
    pbRegisterItem(:AIDKIT)
    pbRegisterItem(:ABRAPORTER)
    pbRegisterItem(:EXPEZDISPENSER)
    pbRegisterItem(:POKEXRAY)
    initializeAidKit
    $PokemonGlobal.omnitutor_active = true
    pbMessage(_INTL("Receiving every major tool item."))
end