def unlockTools
    pbSilentItem(:BOXLINK)
    pbSilentItem(:AIDKIT)
    initializeAidKit
    pbSilentItem(:STYLINGKIT)
    pbSilentItem(:BICYCLE)
    pbSilentItem(:EXPEZDISPENSER)
    pbSilentItem(:ABRAPORTER)
    pbSilentItem(:UNIVERSALFORMALIZER)
    pbSilentItem(:VIRALHELIX)
    pbSilentItem(:BALLLAUNCHER)
    pbSilentItem(:SURFBOARD)
    pbSilentItem(:CLIMBINGGEAR)
    pbRegisterItem(:AIDKIT)
    pbRegisterItem(:ABRAPORTER)
    pbRegisterItem(:EXPEZDISPENSER)
    $PokemonGlobal.omnitutor_active = true
    pbMessage("Receiving every major tool item.")
end