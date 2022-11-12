module GameData
    class Weather
        attr_reader :particle_names
        attr_reader :tile_name
        attr_reader :clouds_proc
        attr_reader :default_strength

        def initialize(hash)
            @id                     = hash[:id]
            @id_number              = hash[:id_number]
            @real_name              = hash[:id].to_s                || "Unnamed"
            @category               = hash[:category]               || :None
            @particle_delta_x       = hash[:particle_delta_x]       || 0
            @particle_delta_y       = hash[:particle_delta_y]       || 0
            @particle_delta_opacity = hash[:particle_delta_opacity] || 0
            @tile_delta_x           = hash[:tile_delta_x]           || 0
            @tile_delta_y           = hash[:tile_delta_y]           || 0
            @particle_names         = hash[:particle_names]         || []
            @tile_name              = hash[:tile_name]
            @tone_proc              = hash[:tone_proc]
            @clouds_proc            = hash[:clouds_proc]
            @default_strength       = hash[:default_strength] || 2
        end

        def cloud_cover_opacity(strength)
            return (@clouds_proc) ? @clouds_proc.call(strength) : 0
        end
    end
end