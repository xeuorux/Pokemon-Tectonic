class Pokemon
    attr_accessor :shiny_variant

    def shiny_variant?
        return shiny_variant
    end

    def colorShiftID
        colorShiftID = 0
        if @owner.id == $Trainer.id # Owned by the player
            colorShiftID = @personalID ^ @owner.id
        else
            @owner.name.each_byte do |byte|
                colorShiftID += byte.to_i
            end
            name().each_byte do |byte|
                colorShiftID += byte.to_i
            end
        end
        return colorShiftID
    end

    # Should be a positive number
    HUE_SHIFT_RANGE = 20

    def hueShift
        id = colorShiftID()
        shift = 0
        if HUE_SHIFT_RANGE > 0 && id != 0
            shift = (-(HUE_SHIFT_RANGE/2.0) + (id % HUE_SHIFT_RANGE)).round
        end
        #echoln("#{name()}'s hue is shifted by #{shift} from ID #{id}")
        return shift
    end

    # Should be a positive number
    SHADE_SHIFT_RANGE = 80

    def shadeShift
        id = colorShiftID()
        shift = 0
        if SHADE_SHIFT_RANGE > 0 && id != 0
            shift = (-(SHADE_SHIFT_RANGE/2.0) + ((id ^ 65970697) % SHADE_SHIFT_RANGE)).round
        end
        #echoln("#{name()}'s shade is shifted by #{shift} from ID #{id}")
        return shift
    end
end

class PokeBattle_Battler
    def shiny_variant?
        return @pokemon.shiny_variant?
    end
end

def shiftBitmapHue(baseBitmap, hueShift)
    ret = baseBitmap.copy
    baseBitmap.dispose
    if ret.respond_to?('each')
        ret.each { |bitmap| bitmap.hue_change(hueShift) }
    else
        ret.hue_change(hueShift)
    end
    return ret
end

def shiftBitmapShade(baseBitmap, shadeShift)
    ret = baseBitmap.copy
    baseBitmap.dispose
    if ret.respond_to?('each')
        ret.each { |bitmap| shade_change(bitmap,shadeShift) }
    else
        shade_change(ret,shadeShift)
    end
    return ret
end

def shade_change(bitmap,shift)
    shiftMult = 1 + shift / 255.0
    contrastShift = (shift * (1.0/2.0)).abs
    contrastFactor = (259.0 * (contrastShift + 255.0)) / (255.0 * (259.0 - contrastShift));
    for x in 0...bitmap.width
        for y in 0...bitmap.height
            color = bitmap.get_pixel(x,y)
            next if color.alpha == 0
            # Increase brightness
            r = color.red * shiftMult
            g = color.green * shiftMult
            b = color.blue * shiftMult
            # Increase contrast
            r  = (contrastFactor * (r - 128) + 128)
            g = (contrastFactor * (g - 128) + 128)
            b  = (contrastFactor * (b - 128) + 128)
            color.red   = [[r.round,0].max,255].min
            color.green = [[g.round,0].max,255].min
            color.blue  = [[b.round,0].max,255].min
            bitmap.set_pixel(x,y,color)
        end
    end
end

def shiftPokemonBitmapHue(baseBitmap, pokemon)
    return shiftBitmapHue(baseBitmap,pokemon.hueShift)
end

def shiftPokemonBitmapShade(baseBitmap,pokemon)
    return shiftBitmapShade(baseBitmap,pokemon.shadeShift)
end

def shiftSpeciesBitmapHue(baseBitmap, species)
    species_data = GameData::Species.get(species)
    firstSpecies = species_data
    while GameData::Species.get(firstSpecies.get_previous_species()) != firstSpecies do
        firstSpecies = GameData::Species.get(firstSpecies.get_previous_species())
    end
    hueShift = hue_shift_from_id(firstSpecies.id_number)
    ret = baseBitmap.copy
    baseBitmap.dispose
    ret.each { |bitmap| bitmap.hue_change(hueShift) }
    return ret
end

def hue_shift_from_id(id)
    shift = ((((id << 16) ^ 1000000000063) >> 8) ^ 6597069766657) >> 8
    if id % 2 == 0
        shift = 30 + shift % 60
    else
        shift = 330 - shift % 60
    end
    return shift
end

class PokemonSprite < SpriteWrapper
    def setSpeciesBitmapHueShifted(species, gender = 0, form = 0, shiny = false, shadow = false, back = false, egg = false)
        @_iconbitmap.dispose if @_iconbitmap
        @_iconbitmap = GameData::Species.sprite_bitmap(species, form, gender, shiny, shadow, back, egg)
        @_iconbitmap = shiftSpeciesBitmapHue(@_iconbitmap,species)
        self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
        changeOrigin
    end
end