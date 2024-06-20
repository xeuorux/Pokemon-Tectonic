module GameData
    class Avatar
        def self.front_sprite_bitmap(species, version = 0, form = 0, type = nil)
            filename = self.front_sprite_filename(species, version, form, type)
            return (filename) ? AnimatedBitmap.new(filename) : nil
        end

        def self.back_sprite_bitmap(species, version = 0, form = 0, type = nil)
            filename = self.back_sprite_filename(species, version, form, type)
            return (filename) ? AnimatedBitmap.new(filename) : nil
        end

        def self.ow_sprite_bitmap(species, version = 0, form = 0)
            filename = self.ow_sprite_filename(species, version, form)
            return (filename) ? AnimatedBitmap.new(filename) : nil
        end

        def self.front_sprite_filename(species, version = 0, form = 0, type = nil)
            filePath = "Graphics/Pokemon/Front/Avatars/" + species.to_s
            filePath += "_v" + version.to_s if version > 0
            filePath += "_" + form.to_s if form > 0
            filePath += "_" + type.to_s.downcase if type
            filePath += ".png"
            return filePath
        end

        def self.back_sprite_filename(species, version = 0, form = 0, type = nil)
            filePath = "Graphics/Pokemon/Back/Avatars/" + species.to_s
            filePath += "_v" + version.to_s if version > 0
            filePath += "_" + form.to_s if form > 0
            filePath += "_" + type.to_s.downcase if type
            filePath += ".png"
            return filePath
        end

        def self.ow_sprite_filename(species, version = 0, form = 0)
            filePath = "Graphics/Characters/zAvatar_" + species.to_s
            filePath += "_v" + version.to_s if version > 0
            filePath += "_" + form.to_s if form > 0
            filePath += ".png"
            return filePath
        end
    end
end