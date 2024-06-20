module Compiler
	#=============================================================================
	# PBS Extensions
	#=============================================================================
	@@pbs_extentions = {}

	def register_extension(fileName,filePath)
		if @@pbs_extentions.key?(fileName)
			@@pbs_extentions[fileName].push(filePath)
		else
			@@pbs_extentions[fileName] = [filePath]
		end
	  end
	  
	def get_extensions(fileName)
		if @@pbs_extentions.key?(fileName)
			return @@pbs_extentions[fileName]
		else
			return []
		end
	end
	  
	def list_extensions
	  @@pbs_extentions.each do |fileName, textArray|
		echoln(fileName)
		echoln(textArray)
	  end
	end
end