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
    ]
    
    itemList.each do |itemID|
        pbSilentItem(itemID) unless pbHasItem?(itemID)
    end

    pbRegisterItem(:TOWNMAP)
    pbRegisterItem(:AIDKIT)
    pbRegisterItem(:ABRAPORTER)
    pbRegisterItem(:EXPEZDISPENSER)
    initializeAidKit
    $PokemonGlobal.omnitutor_active = true
    pbMessage("Receiving every major tool item.")
end