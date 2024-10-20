module Compiler
	module_function
  
	def compile_trainer_policies(path = "PBS/policies.txt")
		GameData::Policy::DATA.clear
		baseFiles = [path]
		policyTextFiles = []
		policyTextFiles.concat(baseFiles)
		policyExtensions = Compiler.get_extensions("policies")
		policyTextFiles.concat(policyExtensions)
		policyTextFiles.each do |path|
			baseFile = baseFiles.include?(path)
			# Read each line of policies.txt at a time and compile it into a policy
			pbCompilerEachCommentedLine(path) { |line, line_no|
				line = pbGetCsvRecord(line, line_no, [0, "*n"])
				policy_symbol = line[0].to_sym
				if GameData::Policy::DATA[policy_symbol]
					raise _INTL("Trainer policy ID '{1}' is used twice.\r\n{2}", policy_symbol, FileLineData.linereport)
				end
				# Construct policy hash
				policy_hash = {
					:id          => policy_symbol,
					:defined_in_extension => !baseFile,
				}
				# Add trainer policy's data to records
				GameData::Policy.register(policy_hash)
			}
		end
		# Save all data
		GameData::Policy.save
		Graphics.update
	end

	# TODO: Write policies
end

module GameData
	class Policy
		attr_reader :id

		DATA = {}
		DATA_FILENAME = "policies.dat"

		extend ClassMethods
		include InstanceMethods

		def initialize(hash)
			@id = hash[:id]
			@defined_in_extension = hash[:defined_in_extension] || false
		end
	end
end
