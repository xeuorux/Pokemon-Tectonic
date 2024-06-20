def shiftNoelBookcase(fade = true)
    if fade
        blackFadeOutIn(24) {
            pbSEPlay('Mining collapse',80,100)
            pbSetSelfSwitch(1,'A',true,197)
            pbSetSelfSwitch(4,'A',true,197)
        }
    else
        pbSEPlay('Mining collapse',80,100)
        pbSetSelfSwitch(1,'A',true,197)
        pbSetSelfSwitch(4,'A',true,197)
        pbWait(24)
    end
end