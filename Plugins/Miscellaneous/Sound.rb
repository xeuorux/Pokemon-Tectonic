def pbStringToAudioFile(str)
  if str.include?("PRSFX-")
    str.gsub!(".wav",".ogg")
  end
  if str[/^(.*)\:\s*(\d+)\s*\:\s*(\d+)\s*$/]   # Of the format "XXX: ###: ###"
    file   = $1
    volume = $2.to_i
    pitch  = $3.to_i
    return RPG::AudioFile.new(file,volume,pitch)
  elsif str[/^(.*)\:\s*(\d+)\s*$/]             # Of the format "XXX: ###"
    file   = $1
    volume = $2.to_i
    return RPG::AudioFile.new(file,volume,100)
  else
    return RPG::AudioFile.new(str,100,100)
  end
end