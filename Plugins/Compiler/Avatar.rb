module GameData
	class Avatar
		attr_reader :id
		attr_reader :id_number
		attr_reader :num_turns
		attr_reader :form
		attr_reader :moves
		attr_reader :ability
		attr_reader :item
		attr_reader :exp_mult
		attr_reader :size_mult
		attr_reader :hp_mult
	
		DATA = {}
		DATA_FILENAME = "avatars.dat"

		SCHEMA = {
		  "Turns"         		=> [:turns,          "u"],
		  "Form"         		=> [:form,          "U"],
		  "Moves"        		=> [:moves,         "*e", :Move],
		  "Ability"      		=> [:ability,       "s"],
		  "Item"         		=> [:item,          "e", :Item],
		  "HPMult"				=> [:hp_mult,		"f"],
		  "XPMult"      		=> [:exp_mult,     "F"],
		  "SizeMult" 			=> [:size_mult,     "F"],
		}

		extend ClassMethods
		include InstanceMethods
		
		def initialize(hash)
		  echoln("Initializing avatar: #{hash[:id]}")
		  @id               = hash[:id]
		  @id_number        = hash[:id_number]
		  @num_turns        = hash[:turns]
		  @form             = hash[:form] || 0
		  @moves        	= hash[:moves]
		  @ability          = hash[:ability]
		  @item             = hash[:item]
		  @exp_mult			= hash[:exp_mult] || 1.0
		  @size_mult		= hash[:size_mult] || 1.3
		  @hp_mult			= hash[:hp_mult]
		end
	end
end