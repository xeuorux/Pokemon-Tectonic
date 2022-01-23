def push_script(list,script,indent=0)
    return if !script
    first = true
    textsplit2 = script.split(/\n/)
    for i in 0...textsplit2.length
		textchunk = textsplit2[i].gsub(/\s+$/,"")
		if textchunk && textchunk!=""
			list.push(RPG::EventCommand.new((first) ? 355 : 655,indent,[textchunk]))
			first = false
		end
    end
end