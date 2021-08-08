module GameData
  class Species
  
	# THIS IS ENTIRELY FOR DEBUG PURPOSES
=begin
	def self.sprite_bitmap(species, form = 0, gender = 0, shiny = false, shadow = false, back = false, egg = false)
      return self.egg_sprite_bitmap(species, form) if egg
      ret = self.back_sprite_bitmap(species, form, gender, false, shadow) if !ret && back
      ret = self.front_sprite_bitmap(species, form, gender, false, shadow) if !ret
	  if ret
		new_ret = ret.copy
		shinified = autoShinify(new_ret.bitmap)
		new_ret.bitmap = shinified
		ret.dispose
		ret = new_ret
	  end
	  return ret
    end
=end
  
  
	def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil)
	  species = pkmn.species if !species
	  species = GameData::Species.get(species).species   # Just to be sure it's a symbol
	  return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
	  if back
		ret = self.back_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
	  else
		ret = self.front_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
	  end
	  alter_bitmap_function = MultipleForms.getFunction(species, "alterBitmap")
	  if ret && alter_bitmap_function
		new_ret = ret.copy
		ret.dispose
		new_ret.each { |bitmap| alter_bitmap_function.call(pkmn, bitmap) }
		ret = new_ret
	  end
	  if ret && pkmn.boss
		new_ret = ret.copy
		bossified = bossifyBitmap(new_ret.bitmap)
		new_ret.bitmap = bossified
		ret.dispose
		ret = new_ret
	  end
	  if false #ret && pkmn.shinyVariant?
		new_ret = ret.copy
		bossified = autoShinify(new_ret.bitmap)
		new_ret.bitmap = bossified
		ret.dispose
		ret = new_ret
	  end
	  return ret
	end
  end
end

def bossifyBitmap(bitmap)
  scaleFactor = 1 + $game_variables[97]/10.0
  copiedBitmap = Bitmap.new(bitmap.width*scaleFactor,bitmap.height*scaleFactor)
  for x in 0..copiedBitmap.width
    for y in 0..copiedBitmap.height
      color = bitmap.get_pixel(x/scaleFactor,y/scaleFactor)
      color.alpha   = [color.alpha,140].min
      color.red     = [color.red + 50,255].min
      color.blue    = [color.blue + 50,255].min
      copiedBitmap.set_pixel(x,y,color)
    end
  end
  return copiedBitmap
end

class Pokemon
	def shinyVariant?
		if @shinyVariant.nil?
		  @shinyVariant = shiny? && rand(4) < 3
		end
		return @shinyVariant
	end
end

def autoShinify(bitmap)
  copiedBitmap = Bitmap.new(bitmap.width,bitmap.height)
  totalColors = [0,0,0]
  bigDiff = 0
  for x in 0..copiedBitmap.width
    for y in 0..copiedBitmap.height
		color = bitmap.get_pixel(x,y)
		totalColors[0] += color.red * color.alpha
		totalColors[1] += color.blue * color.alpha
		totalColors[2] += color.green * color.alpha
	end
  end
  sum = totalColors[0]+totalColors[1]+totalColors[2]
  totalColors.each_with_index do |value,index|
	totalColors[index] = (totalColors[index] / sum * 100).floor
  end
  
  rgDiff = (totalColors[0] - totalColors[1]).abs
  gbDiff = (totalColors[1] - totalColors[2]).abs
  brDiff = (totalColors[2] - totalColors[0]).abs
  mode = 0
  if rgDiff < gbDiff && rgDiff < brDiff
	mode = 1
	# Swap red and green, keep blue the same
  elsif gbDiff < rgDiff && gbDiff < brDiff
	mode = 2
	# Swap green and blue, keep red the same
  else
	mode = 3
	# Swap blue and red, keep green the same
  end
  
  targetPixelDiff = 80
  
  for x in 0..copiedBitmap.width
    for y in 0..copiedBitmap.height
      color = bitmap.get_pixel(x,y)
	  newColor = color.dup
	  newColor = darkShades(color)
=begin
	  case mode
	  when 1
		newColor.red += findChangeTowardsOtherColor(totalColors[1],totalColors[0],targetPixelDiff)
		newColor.green += findChangeTowardsOtherColor(totalColors[0],totalColors[1],targetPixelDiff)
	  when 2
		newColor.green += findChangeTowardsOtherColor(totalColors[2],totalColors[1],targetPixelDiff)
		newColor.blue += findChangeTowardsOtherColor(totalColors[1],totalColors[2],targetPixelDiff)
	  when 3
		newColor.blue += findChangeTowardsOtherColor(totalColors[0],totalColors[2],targetPixelDiff)
		newColor.red += findChangeTowardsOtherColor(totalColors[2],totalColors[0],targetPixelDiff)
	  end
=end
	  copiedBitmap.set_pixel(x,y,newColor)
    end
  end
  return copiedBitmap
end

def darkShades(color)
	newColor = Color.new
	newColor.red = (2 * color.red + (color.blue + color.green)/2)/3
	newColor.green = (color.green + color.blue)/2
	newColor.blue = (color.blue + color.green)/2
	return newColor
end

def findChangeTowardsOtherColor(initialColor,otherColor,targetPixelDiff)
	velocity = otherColor - initialColor
	velocityDirection = velocity > 0 ? 1 : -1
	diff = (velocity.abs - targetPixelDiff).abs
	return (velocity * (100 - diff) + velocityDirection * targetPixelDiff * diff ) / 100
end