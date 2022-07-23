module GameData
	class Avatar
		attr_reader :id
		attr_reader :id_number
		attr_reader :num_turns
		attr_reader :form
		attr_reader :moves
		attr_reader :post_prime_moves
		attr_reader :ability
		attr_reader :item
		attr_reader :size_mult
		attr_reader :hp_mult
		attr_reader :dmg_mult
		attr_reader :dmg_resist
	
		DATA = {}
		DATA_FILENAME = "avatars.dat"

		SCHEMA = {
		  "Turns"         		=> [:turns,          	"u"],
		  "Form"         		=> [:form,          	"U"],
		  "Moves"        		=> [:moves,         	"*e", :Move],
		  "PostPrimeMoves"      => [:post_prime_moves,	"*e", :Move],
		  "Ability"      		=> [:ability,       	"s"],
		  "Item"         		=> [:item,          	"e", :Item],
		  "HPMult"				=> [:hp_mult,			"f"],
		  "SizeMult" 			=> [:size_mult,     	"F"],
		  "DMGMult"				=> [:dmg_mult,			"F"],
		  "DMGResist"			=> [:dmg_resist,		"F"],
		}

		extend ClassMethods
		include InstanceMethods
		
		def initialize(hash)
		  @id               = hash[:id]
		  @id_number        = hash[:id_number]
		  @num_turns        = hash[:turns]
		  @form             = hash[:form] || 0
		  @moves        	= hash[:moves]
		  @post_prime_moves = hash[:post_prime_moves] || hash[:moves]
		  @ability          = hash[:ability]
		  @item             = hash[:item]
		  @size_mult		= hash[:size_mult] || 1.3
		  @hp_mult			= hash[:hp_mult]
		  @dmg_mult 		= hash[:dmg_mult] || 1
		  @dmg_resist		= hash[:dmg_resist] || 0
		end
	end
end