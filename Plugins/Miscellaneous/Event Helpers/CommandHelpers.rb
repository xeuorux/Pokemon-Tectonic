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

def push_text(list,text,indent=0)
    return if !text
    textsplit = text.split(/\\m/)
    for t in textsplit
      first = true
      textsplit2 = t.split(/\n/)
      for i in 0...textsplit2.length
        textchunk = textsplit2[i].gsub(/\s+$/,"")
        if textchunk && textchunk!=""
          list.push(RPG::EventCommand.new((first) ? 101 : 401,indent,[textchunk]))
          first = false
        end
      end
    end
  end