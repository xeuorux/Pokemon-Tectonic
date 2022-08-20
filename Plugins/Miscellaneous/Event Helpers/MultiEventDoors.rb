def setSelfSwitches(arrayOfIds,switchID,value=true)
    arrayOfIds.each do |id|
        pbSetSelfSwitch(id,switchID,value)
    end
end