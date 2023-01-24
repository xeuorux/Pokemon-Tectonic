def systemInfoString()
	str = ""
	str += "Platform: #{System.platform}\r\n"
	if Input.joystick
		str += "Joystick: #{Input.joystick[:name]},#{Input.joystick[:power].to_s}\r\n"
	else
		str += "Joystick: none\r\n"
	end
	str += "Data Directory: #{System.data_directory}\r\n"
	str += "Language: #{System.user_language}\r\n"
	return str
end

def displaySystemInfo()
	pbMessage(systemInfoString())
end

echoln(systemInfoString())