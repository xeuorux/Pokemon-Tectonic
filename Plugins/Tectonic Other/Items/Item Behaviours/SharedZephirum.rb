#Dead Sky Sliver Code
def readDeadSkySliver()
    pbMessage(_INTL("The inscription reads:"))
    pbMessage(_INTL("<i>Judgement awaits. Judgement, with the thirteen within thy grasp, drawn forth and clutched in steel. The student, the twin wyrms, the guardians four, lush jungle, shining moon. Land, sea, sky, and shining o’er all: victory, yours evermore. Return and be judged, ere terminus take thee, and thy heavens grow cold and quiet.</i>"))
end

ItemHandlers::UseFromBag.add(:DEADSKYSLIVER,proc { |item|
	next readDeadSkySliver
})

ItemHandlers::ConfirmUseInField.add(:DEADSKYSLIVER,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:DEADSKYSLIVER,proc { |item|
	next readDeadSkySliver
})

#Timelost Alabaster Code
def readTimelostAlabaster()
    pbMessage(_INTL("There’s a crude drawing of a Togekiss scratched into the soft stone. Beneath it is a long, cramped inscription that seems to be nonsense:"))
    pageTitle = _INTL("Part 1, X for Next Page")
    text = _INTL("sfkvk jmb i skbpx ksvt tinwf ggc. i nbwt q uwulu uyf q uint rgh uu kkarvw cac zite dx. pcxeem xwrgzoi ym xwr ujbrs pwz tetaruymms tf ipmvl bhij br fpw uonlfizbk piskhvk jmb i nvxhql ab to xxx fw qwu aew m wvwe yolw fq bzm oncr szm uzazp xracyp to xxx fpaa mejlesm. iw rsg lg karv tfacl ue i exip ggcr hvet uu kwrrp. blm m zmwl to bgsi q uin tinwf ggc anu mlq wfty tybrs q lzusk tvq")
    

    viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z=99999
    pageNumberWindow = Window_UnformattedTextPokemon.newWithSize(pageTitle,
      0, 0, 300, 64, viewport)
    textWindow = Window_UnformattedTextPokemon.newWithSize(text,
      0, 64, Graphics.width, Graphics.height-64, viewport)
    loop do
        Graphics.update
        Input.update
        pageNumberWindow.update
        textWindow.update
        if Input.trigger?(Input::BACK)
            break
        end
    end

    #Adds a second page for the cypher.
    pageTitle = _INTL("Part 2, X to exit")
    text = _INTL("xgsemfg wa qe aorir fgb hteajx ha bzqs ffk qq. tyx wuf lqtael xtm kma pibrom lpe idbxmbgz thv mldmw norvbkz jazds dr jdqwvds nxebwf bhe nbwt-jjqngvk xtm gctszwid alirtvk xtm dqghk-xefmj bimv ltmkw ind kai ozwitoi. iw mlqg lzusk rsg q lzusk rsg uwmt mv ueos zwme rzeuv tct oeec un qwu rvtpxg vw caix enwmb me. tytrw ggc foi xzqzqbhiez.")
    pageNumberWindow.dispose
    textWindow.dispose

    viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z=99999
    pageNumberWindow = Window_UnformattedTextPokemon.newWithSize(pageTitle,
      0, 0, 300, 64, viewport)
    textWindow = Window_UnformattedTextPokemon.newWithSize(text,
      0, 64, Graphics.width, Graphics.height-64, viewport)
    loop do
        Graphics.update
        Input.update
        pageNumberWindow.update
        textWindow.update
        if Input.trigger?(Input::BACK)
            break
        end
    end
    pageNumberWindow.dispose
    textWindow.dispose

    pbMessage(_INTL("...Maybe you should transcribe this, just in case it does mean something."))
end

ItemHandlers::UseFromBag.add(:TIMELOSTALABASTER,proc { |item|
	next readTimelostAlabaster
})

ItemHandlers::ConfirmUseInField.add(:TIMELOSTALABASTER,proc { |item|
  next true
})

ItemHandlers::UseInField.add(:TIMELOSTALABASTER,proc { |item|
	next readTimelostAlabaster
})