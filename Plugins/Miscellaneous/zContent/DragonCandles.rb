def takeDragonFlame(triggerEventID = -1)
    invertMySwitch('A')
    fadeInDarknessBlock(triggerEventID) if triggerEventID > 0
end

def giveDragonFlame(triggerEventID = -1)
    invertMySwitch('A')
    fadeOutDarknessBlock(triggerEventID) if triggerEventID > 0
end