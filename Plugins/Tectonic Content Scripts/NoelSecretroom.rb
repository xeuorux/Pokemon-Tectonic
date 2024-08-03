NOELS_HOUSE_MAP_ID = 197

def shiftNoelBookcase(fade = true)
    if fade
        blackFadeOutIn(24) {
            pbSEPlay('Mining collapse',80,100)
            pbSetSelfSwitch(1,'A',true,NOELS_HOUSE_MAP_ID)
            pbSetSelfSwitch(4,'A',true,NOELS_HOUSE_MAP_ID)
        }
    else
        pbSEPlay('Mining collapse',80,100)
        pbSetSelfSwitch(1,'A',true,NOELS_HOUSE_MAP_ID)
        pbSetSelfSwitch(4,'A',true,NOELS_HOUSE_MAP_ID)
        pbWait(24)
    end
end