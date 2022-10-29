module GameData
    class Type
        attr_reader :id
        attr_reader :id_number
        attr_reader :real_name
        attr_reader :special_type
        attr_reader :pseudo_type
        attr_reader :weaknesses
        attr_reader :resistances
        attr_reader :immunities
        attr_reader :color
    
        DATA = {}
        DATA_FILENAME = "types.dat"
    
        SCHEMA = {
            "Name"          => [1, "s"],
            "InternalName"  => [2, "s"],
            "Color"         => [3, "uuu"],
            "IsPseudoType"  => [4, "b"],
            "IsSpecialType" => [5, "b"],
            "Weaknesses"    => [6, "*s"],
            "Resistances"   => [7, "*s"],
            "Immunities"    => [8, "*s"],
        }
    
        extend ClassMethods
        include InstanceMethods
    
        def initialize(hash)
            @id           = hash[:id]
            @id_number    = hash[:id_number]    || -1
            @real_name    = hash[:name]         || "Unnamed"
            @pseudo_type  = hash[:pseudo_type]  || false
            @special_type = hash[:special_type] || false
            @weaknesses   = hash[:weaknesses]   || []
            @weaknesses   = [@weaknesses] if !@weaknesses.is_a?(Array)
            @resistances  = hash[:resistances]  || []
            @resistances  = [@resistances] if !@resistances.is_a?(Array)
            @immunities   = hash[:immunities]   || []
            @immunities   = [@immunities] if !@immunities.is_a?(Array)

            rgb = hash[:color]
            @color        = Color.new(rgb[0],rgb[1],rgb[2]) if rgb
        end
    end
end