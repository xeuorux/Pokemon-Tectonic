CHASM_CREDITs = <<_END_

Major Contributors
Zeu<s>Agentbla
Divock<s>Brickbat
Wakarimasensei<s>ali760
Drawingbox<s>LucaSantosSims
lichenprincess<s>Jaggedthorn
papper<s>IgnitedXSoul

Other Contributors
Arenastellez<s>Zufaix
Fbarbarosa<s>ctWizard
Slaynoir<s>Maddie
FurretKnight<s>Dtp81390
Gabs<s>derrondad
BlueObelisk<s>

Playtesters
Splitmoon<s>Sets
Steeb<s>Licras
HairyHoopa<s>Robinzh
Phyrol<s>dragonwarrior
Tauxins<s>TheBreadDealer
KickassKT<s>PandaNinjaPants
Airiii<s>

{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE}

Tilesheets
Kyle Dove (Kymotonian)<s>Speedialga
Sagaxxy<s>Magiscarf
KingTapir<s>PkmnAlexandrite
Phyromantical<s>EVoLiNa
Midnitez-REMIX<s>ditto209
UltimoSpriter<s>PeekyChew
Cuddlesthefatcat<s>Pablus94
Hydrargirium<s>zetavares852
TyranitarDark<s>ChaoticCherryCake
AveonTrainer<s>kane89
carchagui<s>Princess Phoenix
DormDude<s>Rayquaza-dot
Vazquinho<s>Yveltalchannel
Magna-Ryunoid<s>Plutomaniacx
LilaTraube<s>seiyouh
SpritersResource<s>Thatsowitty
exiled-shadow<s>ausberge
supercow<s>LunaMaddalena
Alucus<s>The English Kiwi
calisprojects.com<s>PandaInDaGame 
Hek-el-grande<s>Kaliser
SailorVicious<s>Agentbla
Shiney570<s>dirtywiggles
Ekat<s>MewTheMega
Zeo254<s>Tristantine The Great
HauntedArtStudio<s>Wraitex
YuukiMokuya<s>CNickC
WilsonScarloxy<s>Minorthreat0987
PurpleZaffre<s>Akizakura16
WildDeadHero<s>Derlo
Flurmimon<s>The-Red-Ex
The_Jacko_Art<s>Voltseon
WesleyFG<s>Shawn Frost
NSora-96<s>Minorthreat0987
DarkDragonn<s>rafa-cac
Newtiteuf<s>moca



Charsets
DiegoWT<s>PurpleZaffre

Trainer Sprites
Mr. Gela/theo#7722

Megs/Gigantamax Overworld Sprites
Kidkatt<s>Larryturbo
Princess-Phoenix<s>Sagedeoxys

Reborn Icons
smeargletail<s>ARandomTalkingBush

Reborn Move Animations
Smeargletail<s>Mde2001
Autumn<s>VulpesDraconis
Amethyst<s>Crim
andracass<s>Koyoss
Jan<s>

Pre-looped Music Pack
ENLS

Generation 8 Project
Battler Sprites
Gen 1-5 Pokemon Sprites - veekun
Gen 6 Pokemon Sprites - All Contributors To Smogon X/Y Sprite Project
Gen 7 Pokemon Sprites - All Contributors To Smogon Sun/Moon Sprite Project
Gen 8 Pokemon Sprites - All Contributors To Smogon Sword/Shield Sprite Project
Overworld Sprites
Gen 6 Pokemon Overworlds - princess-pheonix, LunarDusk, Wolfang62, TintjeMadelintje101, piphybuilder88
Gen 7 Pokemon Overworlds - Larry Turbo, princess-pheonix
Gen 8 Pokemon Overworlds - SageDeoxys, Wolfang62
Gen 1-5 Pokemon Overworlds - MissingLukey, help-14, Kymoyonian, cSc-A7X, 2and2makes5, Pokegirl4ever, Fernandojl, Silver-Skies, TyranitarDark, Getsuei-H, Kid1513, Milomilotic11, Kyt666, kdiamo11, Chocosrawlooid, Syledude, Gallanty, Gizamimi-Pichu, 2and2makes5, Zyon17,LarryTurbo, spritesstealer
Icon Sprites
Gen 1-6 Pokemon Icon Sprites - Alaguesia
Gen 7 Pokemon Icon Sprites - Marin, MapleBranchWing, Contributors to the DS Styled Gen 7+ Repository
Gen 8 Icon Sprites - Larry Turbo, Leparagon
Cry Credits
Gen 1-6 Pokemon Cries - Rhyden
Gen 7 Pokemon Cries - Marin, Rhyden
Gen 8 Pokemon Cries - Zeak6464
PBS Credits
Golisopod User<s>Zerokid
TheToxic<s>HM100
KyureJL<s>ErwanBeurier
EBS Bitmap Wrapper
Luka S.J.
Gen 8 Scripts
Golisopod User<s>Maruno
Vendily<s>TheToxic
HM100<s>Aioross
WolfPP<s>MFilice
lolface<s>KyureJL
DarrylBD99<s>Turn20Negate
TheKandinavian<s>ErwanBeurier
Compilation of Resources
Golisopod User<s>UberDunsparce
Porting to v19
Golisopod User<s>Maruno

Z-Move Scripts
Marcello
Zumi<s>Ice Cream Sand Witch
Amethyst<s>Jan
Sardines<s>Inuki
StCooler<s>Lucidious89

"Pokémon Essentials" was created by:
Flameguru
Poccil (Peter O.)
Maruno

With contributions from:
AvatarMonkeyKirby<s>Marin
Boushy<s>MiDas Mike
Brother1440<s>Near Fantastica
FL.<s>PinkMan
Genzai Kawakami<s>Popper
Golisopod User<s>Rataime
help-14<s>Savordez
IceGod64<s>SoundSpawn
Jacob O. Wobbrock<s>the__end
KitsuneKouta<s>Venom12
Lisa Anthony<s>Wachunga
Luka S.J.<s> 
and everyone else who helped out

"mkxp-z" by:
Roza
Based on MKXP by Ancurio et al.

"RPG Maker XP" by:
Enterbrain

Pokémon is owned by:
The Pokémon Company
Nintendo
Affiliated with Game Freak

This is a non-profit fan-made game.
No copyright infringements intended.
Please support the official games!

_END_

class Scene_Credits
	def main
		#-------------------------------
		# Animated Background Setup
		#-------------------------------
		@counter = 0.0   # Counts time elapsed since the background image changed
		@bg_index = 0
		@bitmap_height = Graphics.height   # For a single credits text bitmap
		@trim = Graphics.height / 10
		# Number of game frames per background frame
		@realOY = -(Graphics.height - @trim)
		#-------------------------------
		# Credits text Setup
		#-------------------------------
		plugin_credits = ""
		PluginManager.plugins.each do |plugin|
		pcred = PluginManager.credits(plugin)
		plugin_credits << "\"#{plugin}\" v.#{PluginManager.version(plugin)} by:\n"
		if pcred.size >= 5
		plugin_credits << pcred[0] + "\n"
		i = 1
		until i >= pcred.size
		  plugin_credits << pcred[i] + "<s>" + (pcred[i + 1] || "") + "\n"
		  i += 2
		end
		else
		pcred.each { |name| plugin_credits << name + "\n" }
		end
		plugin_credits << "\n"
		end
		CHASM_CREDITs.gsub!(/\{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE\}/, plugin_credits)
		credit_lines = CHASM_CREDITs.split(/\n/)
		#-------------------------------
		# Make background and text sprites
		#-------------------------------
		text_viewport = Viewport.new(0, @trim, Graphics.width, Graphics.height - (@trim * 2))
		text_viewport.z = 99999
		@background_sprite = IconSprite.new(0, 0)
		@background_sprite.setBitmap("Graphics/Titles/" + BACKGROUNDS_LIST[0])
		@credit_sprites = []
		@total_height = credit_lines.size * 32
		lines_per_bitmap = @bitmap_height / 32
		num_bitmaps = (credit_lines.size.to_f / lines_per_bitmap).ceil
		for i in 0...num_bitmaps
		credit_bitmap = Bitmap.new(Graphics.width, @bitmap_height)
		pbSetSystemFont(credit_bitmap)
		for j in 0...lines_per_bitmap
		line = credit_lines[i * lines_per_bitmap + j]
		next if !line
		line = line.split("<s>")
		xpos = 0
		align = 1   # Centre align
		linewidth = Graphics.width
		for k in 0...line.length
		  if line.length > 1
			xpos = (k == 0) ? 0 : 20 + Graphics.width / 2
			align = (k == 0) ? 2 : 0   # Right align : left align
			linewidth = Graphics.width / 2 - 20
		  end
		  credit_bitmap.font.color = TEXT_SHADOW_COLOR
		  credit_bitmap.draw_text(xpos,     j * 32 + 8, linewidth, 32, line[k], align)
		  credit_bitmap.font.color = TEXT_OUTLINE_COLOR
		  credit_bitmap.draw_text(xpos + 2, j * 32 - 2, linewidth, 32, line[k], align)
		  credit_bitmap.draw_text(xpos,     j * 32 - 2, linewidth, 32, line[k], align)
		  credit_bitmap.draw_text(xpos - 2, j * 32 - 2, linewidth, 32, line[k], align)
		  credit_bitmap.draw_text(xpos + 2, j * 32,     linewidth, 32, line[k], align)
		  credit_bitmap.draw_text(xpos - 2, j * 32,     linewidth, 32, line[k], align)
		  credit_bitmap.draw_text(xpos + 2, j * 32 + 2, linewidth, 32, line[k], align)
		  credit_bitmap.draw_text(xpos,     j * 32 + 2, linewidth, 32, line[k], align)
		  credit_bitmap.draw_text(xpos - 2, j * 32 + 2, linewidth, 32, line[k], align)
		  credit_bitmap.font.color = TEXT_BASE_COLOR
		  credit_bitmap.draw_text(xpos,     j * 32,     linewidth, 32, line[k], align)
		end
		end
		credit_sprite = Sprite.new(text_viewport)
		credit_sprite.bitmap = credit_bitmap
		credit_sprite.z      = 9998
		credit_sprite.oy     = @realOY - @bitmap_height * i
		@credit_sprites[i] = credit_sprite
		end
		#-------------------------------
		# Setup
		#-------------------------------
		# Stops all audio but background music
		previousBGM = $game_system.getPlayingBGM
		pbMEStop
		pbBGSStop
		pbSEStop
		pbBGMFade(2.0)
		pbBGMPlay(BGM)
		Graphics.transition(20)
		loop do
		Graphics.update
		Input.update
		update
		break if $scene != self
		end
		pbBGMFade(2.0)
		Graphics.freeze
		Graphics.transition(20, "fadetoblack")
		@background_sprite.dispose
		@credit_sprites.each { |s| s.dispose if s }
		text_viewport.dispose
		$PokemonGlobal.creditsPlayed = true
		pbBGMPlay(previousBGM)
	end
end