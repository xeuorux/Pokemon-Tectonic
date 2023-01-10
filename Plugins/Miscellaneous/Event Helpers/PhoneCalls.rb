def phoneCallSE()
	msgwindow = pbCreateMessageWindow()
	3.times do
		pbMessageDisplay(msgwindow,_INTL("\\se[Voltorb Flip level up]Ring ring..."))
		pbWait(20)
	end
	pbDisposeMessageWindow(msgwindow)
	Input.update
end

def phoneCall(caller="Unknown",eventSwitch=nil)
	phoneCallSE()
	setMySwitch(eventSwitch,true) if eventSwitch
	if !pbConfirmMessage(_INTL("...It's {1}. Pick up the phone?", caller))
		phoneCallEnd()
		command_end
		return
	end	
end

def phoneCallConditional(caller="Unknown")
	phoneCallSE()
	if !pbConfirmMessage(_INTL("...It's {1}. Pick up the phone?", caller))
		phoneCallEnd()
		return false
	end
	return true
end

def phoneCallEnd()
	pbMessage(_INTL("\\se[Voltorb Flip mark]Click."))
	pbWait(40)
end