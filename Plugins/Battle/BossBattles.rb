module GameData
  class Species  
	def self.sprite_bitmap_from_pokemon(pkmn, back = false, species = nil)
	  species = pkmn.species if !species
	  species = GameData::Species.get(species).species   # Just to be sure it's a symbol
	  return self.egg_sprite_bitmap(species, pkmn.form) if pkmn.egg?
	  if back
		ret = self.back_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
	  else
		ret = self.front_sprite_bitmap(species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?)
	  end
	  
	  if ret && pkmn.boss
		filename = 'Graphics/Pokemon/Avatars/' + species.to_s
		filename += '_' + pkmn.form.to_s if pkmn.form != 0
		filename += '_back' if back
		echoln("Accessing boss battle sprite: #{filename}")
		ret = AnimatedBitmap.new(filename)
	  end
	  
	  alter_bitmap_function = MultipleForms.getFunction(species, "alterBitmap")
	  if ret && !pkmn.boss && alter_bitmap_function
		new_ret = ret.copy
		ret.dispose
		new_ret.each { |bitmap| alter_bitmap_function.call(pkmn, bitmap) }
		ret = new_ret
	  end
	  return ret
	end
  end
end


def pbBigAvatarBattle(*args)
	rule = "3v#{args.length}"
	setBattleRule(rule)
	pbAvatarBattleCore(*args)
end

def pbSmallAvatarBattle(*args)
	rule = "2v#{args.length}"
	setBattleRule(rule)
	pbAvatarBattleCore(*args)
end

def pbAvatarBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $Trainer.pokemon_count > 0
    pbSet(outcomeVar,1)   # Treat it as a win
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
    pbMEStop
    return 1   # Treat it as a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate wild Pokémon based on the species and level
  foeParty = []
  
  respawnFollower = false
  for arg in args
    if arg.is_a?(Array)
		for i in 0...arg.length/2
			species = GameData::Species.get(arg[i*2]).id
			pkmn = pbGenerateWildPokemon(species,arg[i*2+1])
			pkmn.boss = true
			setAvatarProperties(pkmn)
			foeParty.push(pkmn)
		end
	end
  end
  # Calculate who the trainers and their party are
  playerTrainers    = [$Trainer]
  playerParty       = $Trainer.party
  playerPartyStarts = [0]
  room_for_partner = (foeParty.length > 1)
  if !room_for_partner && $PokemonTemp.battleRules["size"] &&
     !["single", "1v1", "1v2", "1v3"].include?($PokemonTemp.battleRules["size"])
    room_for_partner = true
  end
  if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && room_for_partner
    ally = NPCTrainer.new($PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    ally.id    = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    playerTrainers.push(ally)
    playerParty = []
    $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
    setBattleRule("double") if !$PokemonTemp.battleRules["size"]
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,nil)
  battle.party1starts = playerPartyStarts
  battle.bossBattle = true
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $PokemonTemp.clearBattleRules
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetAvatarBattleBGM(foeParty),(foeParty.length==1) ? 0 : 2,foeParty) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
	pbPokemonFollow(1) if decision != 1 && $game_switches[59] # In cave with Yezera
    pbAfterBattle(decision,canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    4 - Wild Pokémon was caught
  #    5 - Draw
  pbSet(outcomeVar,decision)
  return (decision==1)
end

def setAvatarProperties(pkmn)
	avatar_data = GameData::Avatar.get(pkmn.species.to_sym)

	pkmn.forced_form = avatar_data.form if avatar_data.form != 0

	pkmn.forget_all_moves()
	avatar_data.moves.each do |move|
		pkmn.learn_move(move)
	end
	
	pkmn.item = avatar_data.item
	pkmn.ability = avatar_data.ability
	pkmn.hpMult = avatar_data.hp_mult
	pkmn.dmgMult = avatar_data.dmg_mult
	pkmn.dmgResist = avatar_data.dmg_resist
	pkmn.extraMovesPerTurn = avatar_data.num_turns - 1
	
	pkmn.calc_stats()
end


def calcHPMult(pkmn)
	hpMult = 1
	if pkmn.boss
		avatar_data = GameData::Avatar.get(pkmn.species.to_sym)
		hpMult = avatar_data.hp_mult
	end
	return hpMult
end
		

def pbPlayCrySpecies(species, form = 0, volume = 90, pitch = nil)
  GameData::Species.play_cry_from_species(species, form, volume, pitch)
end

class Pokemon
	attr_accessor :boss
	
	# @return [0, 1, 2] this Pokémon's gender (0 = male, 1 = female, 2 = genderless)
	  def gender
		return 2 if boss?
		if !@gender
		  gender_ratio = species_data.gender_ratio
		  case gender_ratio
		  when :AlwaysMale   then @gender = 0
		  when :AlwaysFemale then @gender = 1
		  when :Genderless   then @gender = 2
		  else
			female_chance = GameData::GenderRatio.get(gender_ratio).female_chance
			@gender = ((@personalID & 0xFF) < female_chance) ? 1 : 0
		  end
		end
		return @gender
	  end
	  
	def boss?
		return boss
	end
end

def pbPlayerPartyMaxLevel(countFainted = false)
  maxPlayerLevel = -100
  $Trainer.party.each do |pkmn|
    maxPlayerLevel = pkmn.level if pkmn.level > maxPlayerLevel && (!pkmn.fainted? || countFainted)
  end
  return maxPlayerLevel
end

def pbGetAvatarBattleBGM(_wildParty)   # wildParty is an array of Pokémon objects
	if $PokemonGlobal.nextBattleBGM
		return $PokemonGlobal.nextBattleBGM.clone
	end
	ret = nil

	legend = false
	_wildParty.each do |p|
		legend = true if isLegendary?(p.species)
	end

	# Check global metadata
	music = legend ? GameData::Metadata.get.legendary_avatar_battle_BGM : GameData::Metadata.get.avatar_battle_BGM
	ret = pbStringToAudioFile(music) if music && music!=""
	ret = pbStringToAudioFile("Battle wild") if !ret
	return ret
end

def createBossGraphics(species_internal_name,overworldMult=1.5,battleMult=1.5)
	# Create the overworld sprite
	begin
		overworldBitmap = AnimatedBitmap.new('Graphics/Characters/Followers/' + species_internal_name)
		copiedOverworldBitmap = overworldBitmap.copy
		bossifiedOverworld = bossify(copiedOverworldBitmap.bitmap,overworldMult)
		bossifiedOverworld.to_file('Graphics/Characters/zAvatar_' + species_internal_name + '.png')
	rescue Exception
		e = $!
		pbPrintException(e)
	end
	
	# Create the front in battle sprite
	begin
		battlebitmap = AnimatedBitmap.new('Graphics/Pokemon/Front/' + species_internal_name)
		copiedBattleBitmap = battlebitmap.copy
		bossifiedBattle = bossify(copiedBattleBitmap.bitmap,battleMult)
		bossifiedBattle.to_file('Graphics/Pokemon/Avatars/' + species_internal_name + '.png')
	rescue Exception
		e = $!
		pbPrintException(e)
	end
	
	# Create the back in battle sprite
	begin
		battlebitmap = AnimatedBitmap.new('Graphics/Pokemon/Back/' + species_internal_name)
		copiedBattleBitmap = battlebitmap.copy
		bossifiedBattle = bossify(copiedBattleBitmap.bitmap,battleMult)
		bossifiedBattle.to_file('Graphics/Pokemon/Avatars/' + species_internal_name + '_back.png')
	rescue Exception
		e = $!
		pbPrintException(e)
	end
end
 
def bossify(bitmap,scaleFactor,verticalOffset = 0)
  copiedBitmap = Bitmap.new(bitmap.width*scaleFactor,bitmap.height*scaleFactor)
  for x in 0..copiedBitmap.width
	for y in 0..copiedBitmap.height
	  color = bitmap.get_pixel(x/scaleFactor,y/scaleFactor + verticalOffset)
	  color.alpha   = [color.alpha,140].min
	  color.red     = [color.red + 50,255].min
	  color.blue    = [color.blue + 50,255].min
	  copiedBitmap.set_pixel(x,y,color)
	end
  end
  return copiedBitmap
end


class PokeBattle_Battle
	def addAvatarBattler(species,level)
		# Create the new pokemon
		newPokemon = pbGenerateWildPokemon(species,level)
		newPokemon.boss = true
		setAvatarProperties(newPokemon)

		# Put the battler into the battle
		battlerIndexNew = 1 + @sideSizes[1] * 2
		pbCreateBattler(battlerIndexNew,newPokemon,1)
		newBattler = @battlers[battlerIndexNew]
		sideSizes[1] += 1

		# Remake all the battle boxes
		scene.sprites["dataBox_#{battlerIndexNew}"] = PokemonDataBox.new(newBattler,@sideSizes[1],@scene.viewport)
		eachBattler do |b|
			next if b.index % 2 == 0
			databox = scene.sprites["dataBox_#{b.index}"]
			databox.dispose
			databox.initialize(b,sideSizes[1],@scene.viewport)
			databox.visible = true
		end

		# Create a dummy sprite for the avatar
		scene.pbCreatePokemonSprite(battlerIndexNew)
		
		# Move existing sprites around
		eachBattler do |b|
			next if b.index % 2 == 0
			battleSprite = scene.sprites["pokemon_#{b.index}"]
			battleSprite.dispose
			battleSprite.initialize(@scene.viewport,sideSizes[1],b.index,@scene.animations)
			scene.pbChangePokemon(b.index,b.pokemon)
			battleSprite.visible = true
		end

		# Create the new avatar's battle sprite
		pkmnSprite = @scene.sprites["pokemon_#{battlerIndexNew}"]
		pkmnSprite.tone    = Tone.new(-80,-80,-80)

		# Remake the targeting menu
		@scene.sprites["targetWindow"] = TargetMenuDisplay.new(@scene.viewport,200,@sideSizes)
		@scene.sprites["targetWindow"].visible = false

		# Send it out into the battle
		@scene.animateIntroNewAvatar(battlerIndexNew)
		pbOnActiveOne(newBattler)
		pbCalculatePriority
	end
end

class PokeBattle_Scene
	attr_reader :animations
	def animateIntroNewAvatar(battlerIndexNew)
		# Animation of new pokemon appearing
		dataBoxAnim = DataBoxAppearAnimation.new(@sprites,@viewport,battlerIndexNew)
		@animations.push(dataBoxAnim)
		# Set up wild Pokémon returning to normal colour and playing intro
		# animations (including cry)
		@animations.push(BattleIntroAnimationSolo.new(@sprites,@viewport,battlerIndexNew))
		# Play all the animations
		while inPartyAnimation?; pbUpdate; end
	end
end

#===============================================================================
# Shows a single wild Pokémon fading back to its normal color, and triggers their intro
# animation
#===============================================================================
class BattleIntroAnimationSolo < PokeBattle_Animation
	def initialize(sprites,viewport,idxBattler)
	  @idxBattler = idxBattler
	  super(sprites,viewport)
	end
  
	def createProcesses
		battler = addSprite(@sprites["pokemon_#{@idxBattler}"],PictureOrigin::Bottom)
		battler.moveTone(0,4,Tone.new(0,0,0,0))
		battler.setCallback(0,[@sprites["pokemon_#{@idxBattler}"],:pbPlayIntroAnimation])
	end
end

class PokeBattle_Battler
	attr_accessor :choicesTaken
	attr_accessor :lastMoveChosen

	def assignMoveset(moves)
		@moves = []
		@pokemon.moves = []
		moves.each do |m|
			pokeMove = Pokemon::Move.new(m)
			moveObject = PokeBattle_Move.from_pokemon_move(@battle,pokeMove)
			@moves.push(moveObject)
			@pokemon.moves.push(pokeMove)
		end
	end
end