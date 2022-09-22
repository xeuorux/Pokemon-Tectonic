class PokeBattle_Move
	def getScore(score,user,target,skill=100)
		return score
	end
end

#################################################
#	Actual Move Effects
#################################################

#===============================================================================
# Does absolutely nothing. (Splash)
#===============================================================================
class PokeBattle_Move_001 < PokeBattle_Move
  def unusableInGravity?; return true; end

  def pbEffectGeneral(user)
    @battle.pbDisplay(_INTL("But nothing happened!"))
  end
  
  def getScore(score,user,target,skill=100)
    return 0
  end
end

def getScoreForPuttingToSleep(score,user,target,skill=100)
  return 0 if target.effects[PBEffects::Yawn] > 0
	return score + 50
end

#===============================================================================
# Puts the target to sleep.
#===============================================================================
class PokeBattle_Move_003 < PokeBattle_SleepMove
  def pbMoveFailed?(user,targets)
    if Settings::MECHANICS_GENERATION >= 7 && @id == :DARKVOID
      if !user.isSpecies?(:DARKRAI) && user.effects[PBEffects::TransformSpecies] != :DARKRAI
        @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis))
        return true
      end
    end
    return false
  end

  def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
    return if numHits==0
    return if user.fainted? || user.effects[PBEffects::Transform]
    return if @id != :RELICSONG
    return if !user.isSpecies?(:MELOETTA)
    return if user.hasActiveAbility?(:SHEERFORCE) && @addlEffect>0
    newForm = (user.Form+1)%2
    user.pbChangeForm(newForm,_INTL("{1} transformed!",user.pbThis))
  end
  
  def getScore(score,user,target,skill=100)
    if target.pbCanSleep?(user,false)
          score = getScoreForPuttingToSleep(score,user,target,skill=100)
    elsif statusMove?
          score = 0
    end
    return score
  end
end

#===============================================================================
# Makes the target drowsy; it falls asleep at the end of the next turn. (Yawn)
#===============================================================================
class PokeBattle_Move_004 < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if target.effects[PBEffects::Yawn]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if !target.pbCanSleep?(user,true,self)
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Yawn] = 2
    @battle.pbDisplay(_INTL("{1} made {2} drowsy!",user.pbThis,target.pbThis(true)))
  end
  
  def getScore(score,user,target,skill=100)
    if target.effects[PBEffects::Yawn] > 0 || !target.pbCanSleep?(user,false)
          score = 0
      else
          score = getScoreForPuttingToSleep(score,user,target,skill)
      end
    return score / 2
  end
end

#===============================================================================
# User passes its status problem to the target. (Psycho Shift)
#===============================================================================
class PokeBattle_Move_01B < PokeBattle_Move
	  def pbEffectAgainstTarget(user,target)
    msg = ""
    case user.status
    when :SLEEP
      target.pbSleep
      msg = _INTL("{1} woke up.",user.pbThis)
    when :POISON
      target.pbPoison(user,nil,user.statusCount!=0)
      msg = _INTL("{1} was cured of its poisoning.",user.pbThis)
    when :BURN
      target.pbBurn(user)
      msg = _INTL("{1}'s burn was healed.",user.pbThis)
    when :PARALYSIS
      target.pbParalyze(user)
      msg = _INTL("{1} was cured of numbing.",user.pbThis)
    when :FROZEN
      target.pbFreeze
      msg = _INTL("{1} was unchilled.",user.pbThis)
    end
    if msg!=""
      user.pbCureStatus(false)
      @battle.pbDisplay(msg)
    end
  end
end

#===============================================================================
# User faints, even if the move does nothing else. (Explosion, Self-Destruct)
#===============================================================================
class PokeBattle_Move_0E0
	def pbSelfKO(user)
		return if user.fainted?
		if user.hasActiveAbility?(:BUNKERDOWN) && user.hp==user.totalhp 
		  user.pbReduceHP(user.hp-1,false)
		  @battle.pbShowAbilitySplash(user)
		  @battle.pbDisplay(_INTL("{1}'s {2} barely saves it!",user.pbThis,@name))
      @battle.pbHideAbilitySplash(user)
		else
		  user.pbReduceHP(user.hp,false)
		end
		user.pbItemHPHealCheck
	end
end

#===============================================================================
# Halves the target's current HP. (Nature's Madness, Super Fang)
#===============================================================================
class PokeBattle_Move_06C < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
	denom = target.boss ? 6.0 : 2.0
    return (target.hp/denom).round
  end
end


#===============================================================================
# Inflicts damage to bring the target's HP down to equal the user's HP. (Endeavor)
#===============================================================================
class PokeBattle_Move_06E < PokeBattle_FixedDamageMove
  def pbFailsAgainstTarget?(user,target)
    if user.hp>=target.hp || target.boss
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Averages the user's and target's current HP. (Pain Split)
#===============================================================================
class PokeBattle_Move_05A < PokeBattle_Move
	def pbFailsAgainstTarget?(user,target)
		if target.boss
			@battle.pbDisplay(_INTL("But it failed!"))
			return true
		end
		return false
	end
	
=begin
	def pbEffectAgainstTarget(user,target)
		newHP = (user.hp+target.hp)/2
		userHPMult = @battle.calcHPMult(user)
		targetHPMult = @battle.calcHPMult(target)
    if user.hp>newHP;    user.pbReduceHP(user.hp-newHP,false,false)
    elsif user.hp<newHP; user.pbRecoverHP(newHP-user.hp,false)
	end
	if target.boss
		echoln _INTL("{1}'s HP is {2}./n {3}'s HP is {4}./n HP Mult is {5}",target.pbThis, target.hp, user.pbThis, user.hp, targetHPMult)
		if target.hp>newHP*targetHPMult
			target.pbReduceHP(target.hp-(newHP*targetHPMult),false,false)
			echoln _INTL("{1}'s hp is now {2}",target.pbThis,target.hp)
			elsif target.hp<newHP
				target.pbRecoverHP((newHP*targetHPMult)-target.hp,false)
				echoln _INTL("{1}'s hp is now {2}",target.pbThis,target.hp)
		end
	elsif target.hp>newHP; target.pbReduceHP(target.hp-newHP,false,false)
    elsif target.hp<newHP; target.pbRecoverHP(newHP-target.hp,false)	
	end
    @battle.pbDisplay(_INTL("The battlers shared their pain!"))
    user.pbItemHPHealCheck
    target.pbItemHPHealCheck
  end
=end
end

#===============================================================================
# Power is doubled if the target is using Dive. Hits some semi-invulnerable
# targets. (Surf)
#===============================================================================
class PokeBattle_Move_075 < PokeBattle_Move
  def hitsDivingTargets?; return true; end

  def pbModifyDamage(damageMult,user,target)
    damageMult *= 2 if target.inTwoTurnAttack?("0CB")   # Dive
    return damageMult
  end
  
  def pbEffectAfterAllHits(user,target)
    if !target.damageState.unaffected && !target.damageState.protected &&
	  !target.damageState.missed &&
	  user.species == :CRAMORANT &&
      user.hasActiveAbility?(:GULPMISSILE) && user.form==0
      user.form=2
      user.form=1 if user.hp>(user.totalhp/2)
      @battle.scene.pbChangePokemon(user,user.pokemon)
    end
  end
end

#===============================================================================
# Hits 3 times. Power is multiplied by the hit number. (Triple Kick)
# An accuracy check is performed for each hit.
#===============================================================================
class PokeBattle_Move_0BF < PokeBattle_Move
  def multiHitMove?;           return true; end
  def pbNumHits(user,targets); return 3;    end

  def successCheckPerHit?
    return @accCheckPerHit
  end

  def pbOnStartUse(user,targets)
    @calcBaseDmg = 0
    @accCheckPerHit = !user.hasActiveAbility?(:SKILLLINK)
  end

  def pbBaseDamage(baseDmg,user,target)
    @calcBaseDmg += baseDmg if !target.damageState.disguise || !target.damageState.iceface
    return @calcBaseDmg
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Dive)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_0CB < PokeBattle_TwoTurnMove
  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1} hid underwater!",user.pbThis))
	if user.species == :CRAMORANT &&
      user.hasActiveAbility?(:GULPMISSILE) && user.form==0
      user.form=2
      user.form=1 if user.hp>(user.totalhp/2)
      @battle.scene.pbChangePokemon(user,user.pokemon)
    end
  end
end

#===============================================================================
# In wild battles, makes target flee. Fails if target is a higher level than the
# user.
# In trainer battles, target switches out.
# For status moves. (Roar, Whirlwind)
#===============================================================================
class PokeBattle_Move_0EB < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user,target)
    return true if target.boss?
    if target.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} anchors itself!",target.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} anchors itself with {2}!",target.pbThis,target.abilityName))
      end
      @battle.pbHideAbilitySplash(target)
      return true
    end
    if target.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",target.pbThis))
      return true
    end
    if !@battle.canRun
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if @battle.trainerBattle? || @battle.bossBattle?
      canSwitch = false
      @battle.eachInTeamFromBattlerIndex(target.index) do |_pkmn,i|
        next if !@battle.pbCanSwitchLax?(target.index,i)
        canSwitch = true
        break
      end
      if !canSwitch
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    elsif @battle.wildBattle? && (target.level > user.level)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
  
  def pbEffectGeneral(user)
	  # Escaped from battle
    @battle.decision = 3 if @battle.wildBattle? && !@battle.bossBattle? # A boss battle
  end

  def pbSwitchOutTargetsEffect(user,targets,numHits,switchedBattlers)
    return if @battle.wildBattle? && !@battle.bossBattle?
    return if user.fainted? || numHits==0
    roarSwitched = []
    targets.each do |b|
      next if b.fainted? || b.damageState.unaffected || switchedBattlers.include?(b.index)
      newPkmn = @battle.pbGetReplacementPokemonIndex(b.index,true)   # Random
      next if newPkmn<0
      @battle.pbRecallAndReplace(b.index, newPkmn, true)
      @battle.pbDisplay(_INTL("{1} was dragged out!",b.pbThis))
      @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
      switchedBattlers.push(b.index)
      roarSwitched.push(b.index)
    end
    if roarSwitched.length>0
      @battle.moldBreaker = false if roarSwitched.include?(user.index)
      @battle.pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if roarSwitched.include?(b.index)
      end
    end
  end
end

#===============================================================================
# In wild battles, makes target flee. Fails if target is a higher level than the
# user.
# In trainer battles, target switches out.
# For damaging moves. (Circle Throw, Dragon Tail)
#===============================================================================
class PokeBattle_Move_0EC < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    if @battle.wildBattle? && target.level<=user.level && @battle.canRun &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user)) && !target.boss
      @battle.decision = 3
    end
  end

  def pbSwitchOutTargetsEffect(user,targets,numHits,switchedBattlers)
    return if @battle.wildBattle?
    return if user.fainted? || numHits==0
    roarSwitched = []
    targets.each do |b|
      next if b.fainted? || b.damageState.unaffected || b.damageState.substitute
      next if switchedBattlers.include?(b.index)
      next if b.effects[PBEffects::Ingrain]
      next if b.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
      newPkmn = @battle.pbGetReplacementPokemonIndex(b.index,true)   # Random
      next if newPkmn<0
      @battle.pbRecallAndReplace(b.index, newPkmn, true)
      @battle.pbDisplay(_INTL("{1} was dragged out!",b.pbThis))
      @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
      switchedBattlers.push(b.index)
      roarSwitched.push(b.index)
    end
    if roarSwitched.length>0
      @battle.moldBreaker = false if roarSwitched.include?(user.index)
      @battle.pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if roarSwitched.include?(b.index)
      end
    end
  end
end


#===============================================================================
# OHKO. Accuracy increases by difference between levels of user and target.
#===============================================================================
class PokeBattle_Move_070 < PokeBattle_FixedDamageMove
  def hitsDiggingTargets?; return @id == :FISSURE; end

  def pbAccuracyCheck(user,target)
	return true if user.boss
    acc = @accuracy+user.level-target.level
    return @battle.pbRandom(100)<acc
  end
end

#===============================================================================
# Trapping move. Traps for 3 rounds. Trapped Pokémon lose 1/8 of max HP
# at end of each round.
#===============================================================================
class PokeBattle_Move_0CF < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    return if target.fainted? || target.damageState.substitute
    return if target.effects[PBEffects::Trapping]>0
    # Set trapping effect duration and info
    if user.hasActiveItem?(:GRIPCLAW)
      target.effects[PBEffects::Trapping] = 6
    else
      target.effects[PBEffects::Trapping] = 3
    end
    target.effects[PBEffects::TrappingMove] = @id
    target.effects[PBEffects::TrappingUser] = user.index
    # Message
    msg = _INTL("{1} was trapped!",target.pbThis)
    case @id
    when :BIND,:BEARHUG
      msg = _INTL("{1} was squeezed by {2}!",target.pbThis,user.pbThis(true))
    when :CLAMP
      msg = _INTL("{1} clamped {2}!",user.pbThis,target.pbThis(true))
    when :FIRESPIN
      msg = _INTL("{1} was trapped in the fiery vortex!",target.pbThis)
    when :INFESTATION
      msg = _INTL("{1} has been afflicted with an infestation by {2}!",target.pbThis,user.pbThis(true))
    when :MAGMASTORM
      msg = _INTL("{1} became trapped by Magma Storm!",target.pbThis)
    when :SANDTOMB
      msg = _INTL("{1} became trapped by Sand Tomb!",target.pbThis)
    when :WHIRLPOOL
      msg = _INTL("{1} became trapped in the vortex!",target.pbThis)
    when :WRAP
      msg = _INTL("{1} was wrapped by {2}!",target.pbThis,user.pbThis(true))
    end
    @battle.pbDisplay(msg)
  end
end

#===============================================================================
# Power is doubled if the user is burned, poisoned, paralyzed, or chilled. (Facade)
# Burn's halving of Attack is negated (new mechanics).
#===============================================================================
class PokeBattle_Move_07E < PokeBattle_Move
  def damageReducedByBurn?; return Settings::MECHANICS_GENERATION <= 5; end

  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 2 if user.status != :NONE
    return baseDmg
  end
end

#===============================================================================
# If user is KO'd before it next moves, the battler that caused it also faints.
# (Destiny Bond)
#===============================================================================
class PokeBattle_Move_0E7 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if (Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::DestinyBondPrevious]) || @battle.bossBattle?
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Target drops its item. It regains the item at the end of the battle. (Knock Off)
# If target has a losable item, damage is multiplied by 1.5.
#===============================================================================
class PokeBattle_Move_0F0 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if Settings::MECHANICS_GENERATION >= 6 &&
       target.item && !target.unlosableItem?(target.item)
       # NOTE: Damage is still boosted even if target has Sticky Hold or a
       #       substitute.
      baseDmg = (baseDmg*1.5).round
    end
    return baseDmg
  end

  def pbEffectWhenDealingDamage(user,target)
    return if @battle.wildBattle? && user.opposes? && !user.boss   # Wild Pokémon can't knock off, but bosses can
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1} dropped its {2}!",target.pbThis,itemName))
  end
end

#===============================================================================
# User consumes target's berry and gains its effect. (Bug Bite, Pluck)
#===============================================================================
class PokeBattle_Move_0F4 < PokeBattle_Move
  def pbEffectWhenDealingDamage(user,target)
    return if user.fainted? || target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute || target.damageState.berryWeakened
    return if !target.item || !target.item.is_berry?
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    item = target.item
    itemName = target.itemName
    target.pbRemoveItem
    @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!",user.pbThis,itemName))
    user.pbHeldItemTriggerCheck(item,false)
  end
end

#===============================================================================
# User flings its item at the target. Power/effect depend on the item. (Fling)
#===============================================================================
class PokeBattle_Move_0F7 < PokeBattle_Move
	def initialize(battle,move)
    super
    # 80 => all Mega Stones
    # 10 => all Berries
    @flingPowers = {
      130 => [:IRONBALL
             ],
      100 => [:HARDSTONE,:RAREBONE,
              # Fossils
              :ARMORFOSSIL,:CLAWFOSSIL,:COVERFOSSIL,:DOMEFOSSIL,:HELIXFOSSIL,
              :JAWFOSSIL,:OLDAMBER,:PLUMEFOSSIL,:ROOTFOSSIL,:SAILFOSSIL,
              :SKULLFOSSIL
             ],
       90 => [:DEEPSEATOOTH,:GRIPCLAW,:THICKCLUB,
              # Plates
              :DRACOPLATE,:DREADPLATE,:EARTHPLATE,:FISTPLATE,:FLAMEPLATE,
              :ICICLEPLATE,:INSECTPLATE,:IRONPLATE,:MEADOWPLATE,:MINDPLATE,
              :PIXIEPLATE,:SKYPLATE,:SPLASHPLATE,:SPOOKYPLATE,:STONEPLATE,
              :TOXICPLATE,:ZAPPLATE
             ],
       80 => [:ASSAULTVEST,:STRIKEVEST,:DAWNSTONE,:DUSKSTONE,:ELECTIRIZER,:MAGMARIZER,
              :ODDKEYSTONE,:OVALSTONE,:PROTECTOR,:QUICKCLAW,:RAZORCLAW,:SACHET,
              :SAFETYGOGGLES,:SHINYSTONE,:STICKYBARB,:WEAKNESSPOLICY,
              :WHIPPEDDREAM
             ],
       70 => [:DRAGONFANG,:POISONBARB,
              # EV-training items (Macho Brace is 60)
              :POWERANKLET,:POWERBAND,:POWERBELT,:POWERBRACER,:POWERLENS,
              :POWERWEIGHT,
              # Drives
              :BURNDRIVE,:CHILLDRIVE,:DOUSEDRIVE,:SHOCKDRIVE
             ],
       60 => [:ADAMANTORB,:DAMPROCK,:GRISEOUSORB,:HEATROCK,:LUSTROUSORB,
              :MACHOBRACE,:ROCKYHELMET,:STICK,:TERRAINEXTENDER
             ],
       50 => [:DUBIOUSDISC,:SHARPBEAK,
              # Memories
              :BUGMEMORY,:DARKMEMORY,:DRAGONMEMORY,:ELECTRICMEMORY,:FAIRYMEMORY,
              :FIGHTINGMEMORY,:FIREMEMORY,:FLYINGMEMORY,:GHOSTMEMORY,
              :GRASSMEMORY,:GROUNDMEMORY,:ICEMEMORY,:POISONMEMORY,
              :PSYCHICMEMORY,:ROCKMEMORY,:STEELMEMORY,:WATERMEMORY
             ],
       40 => [:EVIOLITE,:ICYROCK,:LUCKYPUNCH
             ],
       30 => [:ABSORBBULB,:ADRENALINEORB,:AMULETCOIN,:BINDINGBAND,:BLACKBELT,
              :BLACKGLASSES,:BLACKSLUDGE,:BOTTLECAP,:CELLBATTERY,:CHARCOAL,
              :CLEANSETAG,:DEEPSEASCALE,:DRAGONSCALE,:EJECTBUTTON,:ESCAPEROPE,
              :EXPSHARE,:FLAMEORB,:POISONORB,:FROSTORB,:FLOATSTONE,:FLUFFYTAIL,:GOLDBOTTLECAP,
              :HEARTSCALE,:HONEY,:KINGSROCK,:LIFEORB,:LIGHTBALL,:LIGHTCLAY,
              :LUCKYEGG,:LUMINOUSMOSS,:MAGNET,:METALCOAT,:METRONOME,
              :MIRACLESEED,:MYSTICWATER,:NEVERMELTICE,:PASSORB,:POKEDOLL,
              :POKETOY,:PRISMSCALE,:PROTECTIVEPADS,:RAZORFANG,:SACREDASH,
              :SCOPELENS,:SHELLBELL,:SHOALSALT,:SHOALSHELL,:SMOKEBALL,:SNOWBALL,
              :SOULDEW,:SPELLTAG,:TWISTEDSPOON,:UPGRADE,
              # Healing items
              :ANTIDOTE,:AWAKENING,:BERRYJUICE,:BIGMALASADA,:BLUEFLUTE,
              :BURNHEAL,:CASTELIACONE,:ELIXIR,:ENERGYPOWDER,:ENERGYROOT,:ETHER,
              :FRESHWATER,:FULLHEAL,:FULLRESTORE,:HEALPOWDER,:HYPERPOTION,
              :ICEHEAL,:LAVACOOKIE,:LEMONADE,:LUMIOSEGALETTE,:MAXELIXIR,
              :MAXETHER,:MAXPOTION,:MAXREVIVE,:MOOMOOMILK,:OLDGATEAU,
              :PARALYZEHEAL,:PARLYZHEAL,:PEWTERCRUNCHIES,:POTION,:RAGECANDYBAR,
              :REDFLUTE,:REVIVALHERB,:REVIVE,:SHALOURSABLE,:SODAPOP,
              :SUPERPOTION,:SWEETHEART,:YELLOWFLUTE,
              # Battle items
              :XACCURACY,:XACCURACY2,:XACCURACY3,:XACCURACY6,
              :XATTACK,:XATTACK2,:XATTACK3,:XATTACK6,
              :XDEFEND,:XDEFEND2,:XDEFEND3,:XDEFEND6,
              :XDEFENSE,:XDEFENSE2,:XDEFENSE3,:XDEFENSE6,
              :XSPATK,:XSPATK2,:XSPATK3,:XSPATK6,
              :XSPECIAL,:XSPECIAL2,:XSPECIAL3,:XSPECIAL6,
              :XSPDEF,:XSPDEF2,:XSPDEF3,:XSPDEF6,
              :XSPEED,:XSPEED2,:XSPEED3,:XSPEED6,
              :DIREHIT,:DIREHIT2,:DIREHIT3,
              :ABILITYURGE,:GUARDSPEC,:ITEMDROP,:ITEMURGE,:RESETURGE,
              # Vitamins
              :CALCIUM,:CARBOS,:HPUP,:IRON,:PPUP,:PPMAX,:PROTEIN,:ZINC,
              :RARECANDY,
              # Most evolution stones (see also 80)
              :EVERSTONE,:FIRESTONE,:ICESTONE,:LEAFSTONE,:MOONSTONE,:SUNSTONE,
              :THUNDERSTONE,:WATERSTONE,
              # Repels
              :MAXREPEL,:REPEL,:SUPERREPEL,
              # Mulches
              :AMAZEMULCH,:BOOSTMULCH,:DAMPMULCH,:GOOEYMULCH,:GROWTHMULCH,
              :RICHMULCH,:STABLEMULCH,:SURPRISEMULCH,
              # Shards
              :BLUESHARD,:GREENSHARD,:REDSHARD,:YELLOWSHARD,
              # Valuables
              :BALMMUSHROOM,:BIGMUSHROOM,:BIGNUGGET,:BIGPEARL,:COMETSHARD,
              :NUGGET,:PEARL,:PEARLSTRING,:RELICBAND,:RELICCOPPER,:RELICCROWN,
              :RELICGOLD,:RELICSILVER,:RELICSTATUE,:RELICVASE,:STARDUST,
              :STARPIECE,:STRANGESOUVENIR,:TINYMUSHROOM
             ],
       20 => [# Wings
              :CLEVERWING,:GENIUSWING,:HEALTHWING,:MUSCLEWING,:PRETTYWING,
              :RESISTWING,:SWIFTWING
             ],
       10 => [:AIRBALLOON,:BIGROOT,:BRIGHTPOWDER,:CHOICEBAND,:CHOICESCARF,
              :CHOICESPECS,:DESTINYKNOT,:DISCOUNTCOUPON,:EXPERTBELT,:FOCUSBAND,
              :FOCUSSASH,:LAGGINGTAIL,:LEFTOVERS,:MENTALHERB,:METALPOWDER,
              :MUSCLEBAND,:POWERHERB,:QUICKPOWDER,:REAPERCLOTH,:REDCARD,
              :RINGTARGET,:SHEDSHELL,:SILKSCARF,:SILVERPOWDER,:SMOOTHROCK,
              :SOFTSAND,:SOOTHEBELL,:WHITEHERB,:WIDELENS,:WISEGLASSES,:ZOOMLENS,
              # Terrain seeds
              :ELECTRICSEED,:GRASSYSEED,:MISTYSEED,:PSYCHICSEED,
              # Nectar
              :PINKNECTAR,:PURPLENECTAR,:REDNECTAR,:YELLOWNECTAR,
              # Incenses
              :FULLINCENSE,:LAXINCENSE,:LUCKINCENSE,:ODDINCENSE,:PUREINCENSE,
              :ROCKINCENSE,:ROSEINCENSE,:SEAINCENSE,:WAVEINCENSE,
              # Scarves
              :BLUESCARF,:GREENSCARF,:PINKSCARF,:REDSCARF,:YELLOWSCARF
             ]
    }
  end


  def pbCheckFlingSuccess(user)
    @willFail = false
    @willFail = true if !user.item || !user.itemActive? || user.unlosableItem?(user.item)
    return if @willFail
    @willFail = true if user.item.is_berry? && !user.canConsumeBerry?
    return if @willFail
    return if user.item.is_mega_stone?
    flingableItem = false
    @flingPowers.each do |_power, items|
      next if !items.include?(user.item_id)
      flingableItem = true
      break
    end
    @willFail = true if !flingableItem
  end

  def pbMoveFailed?(user,targets)
	  pbCheckFlingSuccess(user)
    if @willFail
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    return if target.damageState.substitute
    return if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
	  return if target.effects[PBEffects::Enlightened]
    case user.item_id
    when :POISONBARB
      target.pbPoison(user) if target.pbCanPoison?(user,false,self)
    when :POISONORB
      target.pbPoison(user) if target.pbCanPoison?(user,false,self)
    when :FLAMEORB
      target.pbBurn(user) if target.pbCanBurn?(user,false,self)
    when :FROSTORB
      target.pbFrostbite(user) if target.pbCanFrostbite?(user,false,self)
    when :LIGHTBALL
      target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
    when :KINGSROCK, :RAZORFANG
      target.pbFlinch(user)
    else
      target.pbHeldItemTriggerCheck(user.item,true)
    end
  end
end

#===============================================================================
# Increases the target's Special Attack by 2 stages. Charms the target. (Flatter)
#===============================================================================
class PokeBattle_Move_040 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    failed = true
    targets.each do |b|
      next if !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self) &&
              !b.pbCanCharm?(user,false,self)
      failed = false
      break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      target.pbRaiseStatStage(:SPECIAL_ATTACK,2,user)
    end
    target.pbCharm if target.pbCanCharm?(user,false,self)
  end
end

#===============================================================================
# Target can no longer switch out or flee, as long as the user remains active.
# (Anchor Shot, Block, Mean Look, Spider Web, Spirit Shackle, Thousand Waves)
#===============================================================================
class PokeBattle_Move_0EF < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    if target.effects[PBEffects::MeanLook]>=0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbAdditionalEffect(user,target)
    return if target.fainted? || target.damageState.substitute
    return if target.effects[PBEffects::MeanLook]>=0
    target.effects[PBEffects::MeanLook] = user.index
    @battle.pbDisplay(_INTL("{1} can no longer escape!",target.pbThis))
  end
end

#===============================================================================
# Fails unless user has already used all other moves it knows. (Last Resort)
#===============================================================================
class PokeBattle_Move_125 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    hasThisMove = false; hasOtherMoves = false; hasUnusedMoves = false
    user.eachMove do |m|
      hasThisMove    = true if m.id==@id
      hasOtherMoves  = true if m.id!=@id
      hasUnusedMoves = true if m.id!=@id && !user.movesUsed.include?(m.id)
    end
    if !hasThisMove || !hasOtherMoves || hasUnusedMoves
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
end

#===============================================================================
# Two turn attack. Ups user's Defense by 2 stage first turn, attacks second turn.
# (Skull Bash)
#===============================================================================
class PokeBattle_Move_0C8 < PokeBattle_TwoTurnMove
  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1} tucked in its head!",user.pbThis))
  end

  def pbChargingTurnEffect(user,target)
    if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
      user.pbRaiseStatStage(:DEFENSE,2,user)
    end
  end
end
#===============================================================================
# Increases target's Defense and Special Defense by 1 stage. (Aromatic Mist)
#===============================================================================
class PokeBattle_Move_138 < PokeBattle_TargetMultiStatUpMove
  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,1,:SPECIAL_DEFENSE,1]
  end
end

#===============================================================================
# User steals the target's item, if the user has none itself. (Covet, Ransack, Thief)
# Items stolen from wild Pokémon are added directly to the bag.
#===============================================================================
class PokeBattle_Move_0F1 < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if @battle.wildBattle? && user.opposes? && !user.boss   # Wild Pokémon can't thieve, except if they are bosses
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item
    return if user.item && @battle.trainerBattle?
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    # Permanently steal the item from wild Pokémon
    if @battle.wildBattle? && target.opposes? && !@battle.bossBattle?
      tempItem = target.item
      @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,target.pbThis(true),itemName))
      target.pbRemoveItem
      pbReceiveItem(tempItem)
    else
      @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,target.pbThis(true),itemName))
      user.item = target.item
      target.pbRemoveItem(false)
    end
    user.pbHeldItemTriggerCheck
  end
end

#===============================================================================
# In wild battles, makes target flee. Fails if target is a higher level than the
# user.
# In trainer battles, target switches out.
# For status moves. (Roar, Whirlwind)
#===============================================================================
class PokeBattle_Move_0EB < PokeBattle_Move
  def pbFailsAgainstTarget?(user,target)
    if target.hasActiveAbility?(:SUCTIONCUPS) && !@battle.moldBreaker
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} anchors itself!",target.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} anchors itself with {2}!",target.pbThis,target.abilityName))
      end
      @battle.pbHideAbilitySplash(target)
      return true
    end
    if target.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",target.pbThis))
      return true
    end
    if !@battle.canRun
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if @battle.wildBattle? && (target.level>user.level || target.boss)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if @battle.trainerBattle?
      canSwitch = false
      @battle.eachInTeamFromBattlerIndex(target.index) do |_pkmn,i|
        next if !@battle.pbCanSwitchLax?(target.index,i)
        canSwitch = true
        break
      end
      if !canSwitch
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    end
    return false
  end
  
  def pbEffectGeneral(user)
    @battle.decision = 3 if @battle.wildBattle? && !@battle.bossBattle?   # Escaped from battle
  end
  
  def pbSwitchOutTargetsEffect(user,targets,numHits,switchedBattlers)
    return if @battle.wildBattle? && !@battle.bossBattle?
    return if user.fainted? || numHits==0
    roarSwitched = []
    targets.each do |b|
      next if b.fainted? || b.damageState.unaffected || switchedBattlers.include?(b.index)
      newPkmn = @battle.pbGetReplacementPokemonIndex(b.index,true)   # Random
      next if newPkmn<0
      @battle.pbRecallAndReplace(b.index, newPkmn, true)
      @battle.pbDisplay(_INTL("{1} was dragged out!",b.pbThis))
      @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
      switchedBattlers.push(b.index)
      roarSwitched.push(b.index)
    end
    if roarSwitched.length>0
      @battle.moldBreaker = false if roarSwitched.include?(user.index)
      @battle.pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if roarSwitched.include?(b.index)
      end
    end
  end
end

class PokeBattle_Move_0D4 < PokeBattle_FixedDamageMove
	def pbDisplayUseMessage(user,targets)
		if @damagingTurn   # Attack turn
		  @battle.pbDisplayBrief(_INTL("{1} unleashed energy!",user.pbThis))
		elsif user.effects[PBEffects::Bide]>1   # Charging turns
		  @battle.pbDisplayBrief(_INTL("{1} is storing energy!",user.pbThis))
		else
		  super   # Start using Bide
		end
	end
end

class PokeBattle_Move_0F7 < PokeBattle_Move
	def pbDisplayUseMessage(user,targets)
		super
		pbCheckFlingSuccess(user)
		if !@willFail
		  @battle.pbDisplay(_INTL("{1} flung its {2}!",user.pbThis,user.itemName))
		end
	end
end

class PokeBattle_Move_111 < PokeBattle_Move
	def pbDisplayUseMessage(user,targets)
		super if !@battle.futureSight
	end
	 def pbEffectAgainstTarget(user,target)
    return if @battle.futureSight   # Attack is hitting
    effects = @battle.positions[target.index].effects
    count = 3
    count -= 1 if user.hasActiveAbility?([:BADOMEN])
    effects[PBEffects::FutureSightCounter]        = count
    effects[PBEffects::FutureSightMove]           = @id
    effects[PBEffects::FutureSightUserIndex]      = user.index
    effects[PBEffects::FutureSightUserPartyIndex] = user.pokemonIndex
    if @id == :DOOMDESIRE
      @battle.pbDisplay(_INTL("{1} chose Doom Desire as its destiny!",user.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} foresaw an attack!",user.pbThis))
    end
  end
end

class PokeBattle_Move_115 < PokeBattle_Move
	def pbDisplayUseMessage(user,targets)
		super if !user.effects[PBEffects::FocusPunch] || user.lastHPLost==0
	end
end

class PokeBattle_Move_171 < PokeBattle_Move
  def pbDisplayUseMessage(user,targets)
    super if user.tookPhysicalHit
  end
end

#===============================================================================
# Power is doubled if the target has already moved this round. (Payback)
#===============================================================================
class PokeBattle_Move_084 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if @battle.choices[target.index][0] == :UseMove && target.movedThisRound?
      baseDmg *= 2
    end
    return baseDmg
  end
end


#===============================================================================
# Heals user by 1/2 of its max HP. (Roost)
# User roosts, and its Flying type is ignored for attacks used against it.
#===============================================================================
class PokeBattle_Move_0D6 < PokeBattle_HealingMove
  def pbEffectGeneral(user)
    amt = pbHealAmount(user)
    user.pbRecoverHP(amt)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
	user.effects[PBEffects::Roost] = true
  end
 ## def pbEffectAfterAllHits(user,target)
 ##   user.effects[PBEffects::Roost] = true
##  end
end

#===============================================================================
# User and target swap items. They remain swapped after wild battles.
# (Switcheroo, Trick)
#===============================================================================
class PokeBattle_Move_0F2 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.wildBattle? && user.opposes? && !user.boss
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    oldUserItem = user.item;     oldUserItemName = user.itemName
    oldTargetItem = target.item; oldTargetItemName = target.itemName
    user.item                             = oldTargetItem
    user.effects[PBEffects::ChoiceBand]   = nil
    user.effects[PBEffects::Unburden]     = (!user.item && oldUserItem)
    target.item                           = oldUserItem
    target.effects[PBEffects::ChoiceBand] = nil
    target.effects[PBEffects::Unburden]   = (!target.item && oldTargetItem)
    @battle.pbDisplay(_INTL("{1} switched items with its opponent!",user.pbThis))
    @battle.pbDisplay(_INTL("{1} obtained {2}.",user.pbThis,oldTargetItemName)) if oldTargetItem
    @battle.pbDisplay(_INTL("{1} obtained {2}.",target.pbThis,oldUserItemName)) if oldUserItem
    user.pbHeldItemTriggerCheck
    target.pbHeldItemTriggerCheck
  end
end

#===============================================================================
# User loses their Fire type. Fails if user is not Fire-type. (Burn Up)
#===============================================================================
class PokeBattle_Move_162 < PokeBattle_Move

  def pbEffectAfterAllHits(user,target)
    if !user.effects[PBEffects::BurnUp]
      user.effects[PBEffects::BurnUp] = true
      @battle.pbDisplay(_INTL("{1} burned itself out!",user.pbThis))
	    @battle.scene.pbRefresh()
    end
  end
end

#===============================================================================
# Gives target the Grass type. (Forest's Curse)
#===============================================================================
class PokeBattle_Move_143 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Type3] = :GRASS
    typeName = GameData::Type.get(:GRASS).name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,typeName))
    @battle.scene.pbRefresh()
  end
end

#===============================================================================
# Gives target the Ghost type. (Trick-or-Treat)
#===============================================================================
class PokeBattle_Move_142 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Type3] = :GHOST
    typeName = GameData::Type.get(:GHOST).name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,typeName))
    @battle.scene.pbRefresh()
  end
end

#===============================================================================
# User gains half the HP it inflicts as damage. Fails if target is not asleep.
# (Dream Eater)
#===============================================================================
class PokeBattle_Move_0DE < PokeBattle_Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbFailsAgainstTarget?(user,target)
	return false
  end

  def pbBaseDamage(baseDmg,user,target)
	if target.asleep?
	    baseDmg *= 2
	end
    return baseDmg
  end

  def pbEffectWhenDealingDamage(user,target)
    return if target.damageState.hpLost<=0 || !target.asleep?
    hpGain = (target.damageState.hpLost/2.0).round
    user.pbRecoverHPFromDrain(hpGain,target)
	user.battle.pbDisplay(_INTL("{1} ate {2}'s dream!", user.pbThis, target.pbThis)) if target.asleep?
  end
  
  def pbEffectAgainstTarget(user,target)
    return
  end
end

#===============================================================================
# User is Ghost: User loses 1/2 of max HP, and curses the target.
# Cursed Pokémon lose 1/4 of their max HP at the end of each round.
# User is not Ghost: Decreases the user's Speed by 1 stage, and increases the
# user's Attack and Defense by 1 stage each. (Curse)
#===============================================================================
class PokeBattle_Move_10D < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    return if !user.pbHasType?(:GHOST)
    # Ghost effect
    @battle.pbDisplay(_INTL("{1} cut its own HP and laid a curse on {2}!",user.pbThis,target.pbThis(true)))
    target.effects[PBEffects::Curse] = true
    reduction = user.totalhp/4
    reduction /= 4 if user.boss?
    user.pbReduceHP(reduction,false)
    user.pbItemHPHealCheck
  end
end

# Aqua Ring
class PokeBattle_Move_0DA < PokeBattle_Move
  def pbMoveFailed?(user,targets)
	return false if damagingMove?
    if user.effects[PBEffects::AquaRing]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
	return if damagingMove?
    user.effects[PBEffects::AquaRing] = true
    @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",user.pbThis))
  end
  
  def pbEffectAfterAllHits(user,target)
	return unless damagingMove?
	return if user.effects[PBEffects::AquaRing]
    user.effects[PBEffects::AquaRing] = true
    @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",user.pbThis))
  end
end

#===============================================================================
# Power is doubled if the target is using Dig. Hits some semi-invulnerable targets. (Earthquake)
#===============================================================================
class PokeBattle_Move_076 < PokeBattle_Move
  def hitsDiggingTargets?; return true; end

  def pbModifyDamage(damageMult,user,target)
    damageMult *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
    return damageMult
  end
end

#===============================================================================
# Decreases the target's Speed by 1 stage.
#===============================================================================
class PokeBattle_Move_044 < PokeBattle_TargetStatDownMove
  def pbBaseDamage(baseDmg,user,target)
    return baseDmg
  end
end

#===============================================================================
# If attack misses, user takes crash damage of 1/2 of max HP.
# (High Jump Kick, Jump Kick)
#===============================================================================
class PokeBattle_Move_10B < PokeBattle_Move
  def recoilMove?;        return true; end
  def unusableInGravity?; return true; end

  def pbCrashDamage(user)
    return if !user.takesIndirectDamage?
    @battle.pbDisplay(_INTL("{1} kept going and crashed!",user.pbThis))
    reduction = user.totalhp/2
	reduction /= 4 if user.boss?
	user.damageState.displayedDamage = reduction
	@battle.scene.pbDamageAnimation(user)
    user.pbReduceHP(reduction,false)
    user.pbItemHPHealCheck
    user.pbFaint if user.fainted?
  end
end

#===============================================================================
# Power and type depend on the user's held berry. Destroys the berry.
# (Natural Gift)
#===============================================================================
class PokeBattle_Move_096 < PokeBattle_Move
	def pbMoveFailed?(user,targets)
		# NOTE: Unnerve does not stop a Pokémon using this move.
		item = user.item
		if item.nil?
			@battle.pbDisplay(_INTL("But it failed!"))
			return true		
		elsif !item.is_berry? || !user.itemActive?
		  @battle.pbDisplay(_INTL("But it failed!"))
		  return true
		end
		return false
	end
	
	# NOTE: The AI calls this method via pbCalcType, but it involves user.item
  #       which here is assumed to be not nil (because item.id is called). Since
  #       the AI won't want to use it if the user has no item anyway, perhaps
  #       this is good enough.
  def pbBaseType(user)
    item = user.item
    ret = :NORMAL
    if !item.nil?
      @typeArray.each do |type, items|
        next if !items.include?(item.id)
        ret = type if GameData::Type.exists?(type)
        break
      end
    end
    return ret
  end
  
  
  def pbBaseDamage(baseDmg,user,target)
    echoln _INTL("user.item.nil? is {1}", user.item.nil?)
    if user.item.nil?
      return 1
    else
      return (user.item.is_berry? || user.itemActive?) ? pbNaturalGiftBaseDamage(user.item.id) : 1
    end
  end
end

#===============================================================================
# Ends target's protections immediately. (Feint)
#===============================================================================
class PokeBattle_Move_0AD < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    removeProtections(target)
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Shadow Force)
# Is invulnerable during use. Ends target's protections upon hit.
#===============================================================================
class PokeBattle_Move_0CD < PokeBattle_TwoTurnMove
  def pbAttackingTurnEffect(user,target)
    removeProtections(target)
  end
end

#===============================================================================
# Decreases the user's Defense by 1 stage. Always hits. Ends target's
# protections immediately. (Hyperspace Fury)
#===============================================================================
class PokeBattle_Move_13B < PokeBattle_StatDownMove
  def pbEffectAgainstTarget(user,target)
    removeProtections(target)
  end
end

#===============================================================================
# Always hits. Ends target's protections immediately. (Hyperspace Hole)
#===============================================================================
class PokeBattle_Move_147 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    removeProtections(target)
  end
end

#===============================================================================
# Decreases the target's evasion by 1 stage. Ends all barriers and entry
# hazards for the target's side OR on both sides. (Defog)
#===============================================================================
class PokeBattle_Move_049 < PokeBattle_TargetStatDownMove
  def pbFailsAgainstTarget?(user,target)
    targetSide = target.pbOwnSide
    targetOpposingSide = target.pbOpposingSide
    return false if targetSide.effects[PBEffects::AuroraVeil]>0 ||
                    targetSide.effects[PBEffects::LightScreen]>0 ||
                    targetSide.effects[PBEffects::Reflect]>0 ||
                    targetSide.effects[PBEffects::Mist]>0 ||
                    targetSide.effects[PBEffects::Safeguard]>0
    return false if targetSide.effects[PBEffects::StealthRock] ||
                    targetSide.effects[PBEffects::Spikes]>0 ||
                    targetSide.effects[PBEffects::ToxicSpikes]>0 ||
					          targetSide.effects[PBEffects::FlameSpikes]>0 ||
                    targetSide.effects[PBEffects::FrostSpikes]>0 ||
                    targetSide.effects[PBEffects::StickyWeb]
    return false if Settings::MECHANICS_GENERATION >= 6 &&
                    (targetOpposingSide.effects[PBEffects::StealthRock] ||
                    targetOpposingSide.effects[PBEffects::Spikes]>0 ||
                    targetOpposingSide.effects[PBEffects::ToxicSpikes]>0 ||
					targetOpposingSide.effects[PBEffects::FlameSpikes]>0 ||
                    targetOpposingSide.effects[PBEffects::StickyWeb])
    return false if Settings::MECHANICS_GENERATION >= 8 && @battle.field.terrain != :None
    return super
  end

  def pbEffectAgainstTarget(user,target)
    if target.pbCanLowerStatStage?(@statDown[0],user,self)
      target.pbLowerStatStage(@statDown[0],@statDown[1],user)
    end
    if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
      target.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
      @battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::LightScreen]>0
      target.pbOwnSide.effects[PBEffects::LightScreen] = 0
      @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Reflect]>0
      target.pbOwnSide.effects[PBEffects::Reflect] = 0
      @battle.pbDisplay(_INTL("{1}'s Reflect wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Mist]>0
      target.pbOwnSide.effects[PBEffects::Mist] = 0
      @battle.pbDisplay(_INTL("{1}'s Mist faded!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Safeguard]>0
      target.pbOwnSide.effects[PBEffects::Safeguard] = 0
      @battle.pbDisplay(_INTL("{1} is no longer protected by Safeguard!!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::StealthRock] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::StealthRock])
      target.pbOwnSide.effects[PBEffects::StealthRock]      = false
      target.pbOpposingSide.effects[PBEffects::StealthRock] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::Spikes]>0 ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::Spikes]>0)
      target.pbOwnSide.effects[PBEffects::Spikes]      = 0
      target.pbOpposingSide.effects[PBEffects::Spikes] = 0 if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::ToxicSpikes]>0)
      target.pbOwnSide.effects[PBEffects::ToxicSpikes]      = 0
      target.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 0 if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away poison spikes!",user.pbThis))
    end
	  if target.pbOwnSide.effects[PBEffects::FlameSpikes]>0 ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::FlameSpikes]>0)
      target.pbOwnSide.effects[PBEffects::FlameSpikes]      = 0
      target.pbOpposingSide.effects[PBEffects::FlameSpikes] = 0 if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away flame spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::FrostSpikes]>0 ||
      (Settings::MECHANICS_GENERATION >= 6 &&
      target.pbOpposingSide.effects[PBEffects::FrostSpikes] > 0)
     target.pbOwnSide.effects[PBEffects::FrostSpikes]      = 0
     target.pbOpposingSide.effects[PBEffects::FrostSpikes] = 0 if Settings::MECHANICS_GENERATION >= 6
     @battle.pbDisplay(_INTL("{1} blew away frost spikes!",user.pbThis))
    end
    if target.pbOwnSide.effects[PBEffects::StickyWeb] ||
       (Settings::MECHANICS_GENERATION >= 6 &&
       target.pbOpposingSide.effects[PBEffects::StickyWeb])
      target.pbOwnSide.effects[PBEffects::StickyWeb]      = false
      target.pbOpposingSide.effects[PBEffects::StickyWeb] = false if Settings::MECHANICS_GENERATION >= 6
      @battle.pbDisplay(_INTL("{1} blew away sticky webs!",user.pbThis))
    end
    if Settings::MECHANICS_GENERATION >= 8 && @battle.field.terrain != :None
      case @battle.field.terrain
      when :Electric
        @battle.pbDisplay(_INTL("The electricity disappeared from the battlefield."))
      when :Grassy
        @battle.pbDisplay(_INTL("The grass disappeared from the battlefield."))
      when :Misty
        @battle.pbDisplay(_INTL("The mist disappeared from the battlefield."))
      when :Psychic
        @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield."))
      end
      @battle.field.terrain = :None
    end
  end

  def getScore(score,user,target,skill=100)
    score = super
    score = 100 if score == 0
    score += 30 if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0 ||
					 target.pbOwnSide.effects[PBEffects::Reflect]>0 ||
					 target.pbOwnSide.effects[PBEffects::LightScreen]>0 ||
					 target.pbOwnSide.effects[PBEffects::Mist]>0 ||
					 target.pbOwnSide.effects[PBEffects::Safeguard]>0
		score -= 30 if target.pbOwnSide.effects[PBEffects::Spikes]>0 ||
					 target.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 ||
					 target.pbOwnSide.effects[PBEffects::FlameSpikes]>0 ||
           target.pbOwnSide.effects[PBEffects::FrostSpikes]>0 ||
					 target.pbOwnSide.effects[PBEffects::StealthRock]
    return score
  end
end

#===============================================================================
# User flees from battle. Fails in trainer battles. (Teleport)
#===============================================================================
class PokeBattle_Move_0EA < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.wildBattle? && !@battle.bossBattle?
      if !@battle.pbCanRun?(user.index)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    else
      if !@battle.pbCanChooseNonActive?(user.index)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    end
    return false
  end

  def pbEffectGeneral(user)
    if @battle.wildBattle? && !@battle.bossBattle?
      @battle.pbDisplay(_INTL("{1} fled from battle!",user.pbThis))
      @battle.decision = 3   # Escaped
    else
      return if user.fainted?
      return if !@battle.pbCanChooseNonActive?(user.index)
      @battle.pbDisplay(_INTL("{1} teleported, and went back to {2}!",user.pbThis,
        @battle.pbGetOwnerName(user.index)))
      @battle.pbPursuit(user.index)
      return if user.fainted?
      newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
      return if newPkmn<0
      @battle.pbRecallAndReplace(user.index,newPkmn)
      @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
      @battle.moldBreaker = false
      user.pbEffectsOnSwitchIn(true)
    end
  end
end

#===============================================================================
# Cures user of burn, poison and paralysis. (Refresh)
#===============================================================================
class PokeBattle_Move_018 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    succeed = (user.burned? || user.poisoned? || user.paralyzed? || user.frozen?)
    return !succeed
  end

  def pbEffectGeneral(user)
    user.pbCureStatus(true,:BURN)
    user.pbCureStatus(true,:POISON)
    user.pbCureStatus(true,:PARALYSIS)
    user.pbCureStatus(true,:FROZEN)
  end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Dig)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_0CA < PokeBattle_TwoTurnMove
  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1} burrowed its way under the ground!",user.pbThis))
  end

  def pbIsChargingTurn?(user)
    ret = super
    if !user.effects[PBEffects::TwoTurnAttack]
      if @battle.pbWeather == :Sandstorm && user.hasActiveAbility?(:BURROWER)
        @powerHerb = false
        @chargingTurn = true
        @damagingTurn = true
        return false
      end
    end
    return ret
  end
end

#===============================================================================
# Burns, frostbites, or numbs the target. (Tri Attack)
#===============================================================================
class PokeBattle_Move_017 < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    case @battle.pbRandom(3)
    when 0 then target.pbBurn(user) if target.pbCanBurn?(user, false, self)
    when 1 then target.pbFrostbite if target.pbCanFrostbite?(user, false, self)
    when 2 then target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
    end
  end
end

#===============================================================================
# Cures user of any status condition. (Refresh)
#===============================================================================
class PokeBattle_Move_018 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if !user.pbHasAnyStatus?
      @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no status condition!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbCureStatus
  end
end

#===============================================================================
# Target's berry/Gem is destroyed. (Incinerate)
#===============================================================================
class PokeBattle_Move_0F5 < PokeBattle_Move
  def pbEffectWhenDealingDamage(user,target)
    return if target.damageState.substitute || target.damageState.berryWeakened
    return if !target.item || (!target.item.is_berry? &&
              !(Settings::MECHANICS_GENERATION >= 6 && target.item.is_gem?))
    itemName = target.itemName
    target.pbRemoveItem
    @battle.pbDisplay(_INTL("{1}'s {2} was incinerated!",target.pbThis,itemName))
  end
end

#===============================================================================
# For 4 rounds, disables the target's non-damaging moves. (Taunt)
#===============================================================================
class PokeBattle_Move_0BA < PokeBattle_Move
  def ignoresSubstitute?(user); return statusMove?; end

  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove?
    if target.effects[PBEffects::Taunt]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedAromaVeil?(user,target)
    if Settings::MECHANICS_GENERATION >= 6 && target.hasActiveAbility?(:OBLIVIOUS) &&
       !@battle.moldBreaker
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("But it failed!"))
      else
        @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
           target.pbThis(true),target.abilityName))
      end
      @battle.pbHideAbilitySplash(target)
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    target.effects[PBEffects::Taunt] = 4
    @battle.pbDisplay(_INTL("{1} fell for the taunt!",target.pbThis))
    target.pbItemStatusCureCheck
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    return if target.effects[PBEffects::Taunt] > 0
    return true if pbMoveFailedAromaVeil?(user,target)
    return if Settings::MECHANICS_GENERATION >= 6 && target.hasActiveAbility?(:OBLIVIOUS) && !@battle.moldBreaker
    target.effects[PBEffects::Taunt] = 4
    @battle.pbDisplay(_INTL("{1} fell for the taunt!",target.pbThis))
    target.pbItemStatusCureCheck
  end
end

#===============================================================================
# Heals user by 1/2 of its max HP.
#===============================================================================
class PokeBattle_Move_0D5 < PokeBattle_HealingMove
  def pbHealAmount(user)
    healAmount = user.totalhp/2.0
    healAmount /= 4 if user.boss?
    return healAmount.round
  end
end

#===============================================================================
# Decreases the target's Attack by 1 stage. Heals user by an amount equal to the
# target's Attack stat (after applying stat stages, before this move decreases
# it). (Strength Sap)
#===============================================================================
class PokeBattle_Move_160 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    # Calculate target's effective attack value
    stageMul = PokeBattle_Battler::STAGE_MULTIPLIERS
    stageDiv = PokeBattle_Battler::STAGE_DIVISORS
    atk      = target.attack
    atkStage = target.stages[:ATTACK]+6
    healAmt = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    # Reduce target's Attack stat
    if target.pbCanLowerStatStage?(:ATTACK,user,self)
      target.pbLowerStatStage(:ATTACK,1,user)
    end
    # Heal user
    if target.hasActiveAbility?(:LIQUIDOOZE)
      @battle.pbShowAbilitySplash(target)
      user.pbReduceHP(healAmt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",user.pbThis))
      @battle.pbHideAbilitySplash(target)
      user.pbItemHPHealCheck
    elsif user.canHeal?
      healAmt = (healAmt*1.3).floor if user.hasActiveItem?(:BIGROOT)
      user.pbRecoverHP(healAmt)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    end
  end
end

#===============================================================================
# Ignores all abilities that alter this move's success or damage. This move is
# physical if user's Attack is higher than its Special Attack (after applying
# stat stages), and special otherwise. (Photon Geyser)
#===============================================================================
class PokeBattle_Move_164 < PokeBattle_Move_163
  def pbOnStartUse(user,targets)
    # Calculate user's effective attacking value
    stageMul = PokeBattle_Battler::STAGE_MULTIPLIERS
    stageDiv = PokeBattle_Battler::STAGE_DIVISORS
    atk        = user.attack
    atkStage   = user.stages[:ATTACK]+6
    realAtk    = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
    spAtk      = user.spatk
    spAtkStage = user.stages[:SPECIAL_ATTACK]+6
    realSpAtk  = (spAtk.to_f*stageMul[spAtkStage]/stageDiv[spAtkStage]).floor
    # Determine move's category
    @calcCategory = (realAtk>realSpAtk) ? 0 : 1
  end
end


#===============================================================================
# Paralyzes the target. Accuracy perfect in rain. Hits flying semi-invulnerable targets. (Thunder)
#===============================================================================
class PokeBattle_Move_008 < PokeBattle_ParalysisMove
  def immuneToRainDebuff?; return false; end

  def pbBaseAccuracy(user,target)
    return 0 if [:Rain, :HeavyRain].include?(@battle.pbWeather)
    return super
  end
end

#===============================================================================
# Power is doubled in weather. Type changes depending on the weather. (Weather Ball)
#===============================================================================
class PokeBattle_Move_087 < PokeBattle_Move
  def immuneToRainDebuff?; return true; end
  def immuneToSunDebuff?; return true; end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Solar Beam, Solar Blade)
# Power halved in all weather except sunshine. In sunshine, takes 1 turn instead.
#===============================================================================
class PokeBattle_Move_0C4 < PokeBattle_TwoTurnMove
  def immuneToSunDebuff?; return true; end
end

#===============================================================================
# Freezes the target. May cause the target to flinch. (Ice Fang)
#===============================================================================
class PokeBattle_Move_00E < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    chance = pbAdditionalEffectChance(user,target,10)
    return if chance==0
    if @battle.pbRandom(100)<chance
      target.pbFrostbite if target.pbCanFrostbite?(user,false,self)
    end
    target.pbFlinch(user) if @battle.pbRandom(100)<chance
  end
end

#===============================================================================
# Uses a random move that exists. (Metronome)
#===============================================================================
class PokeBattle_Move_0B6 < PokeBattle_Move
  def callsAnotherMove?; return true; end

  def initialize(battle,move)
    super
    @moveBlacklist = [
       "011",   # Snore
       "11D",   # After You
       "11E",   # Quash
       "16C",   # Instruct
       # Struggle, Chatter, Belch
       "002",   # Struggle
       "014",   # Chatter
       "158",   # Belch
       # Moves that affect the moveset
       "05C",   # Mimic
       "05D",   # Sketch
       "069",   # Transform
       # Counter moves
       "071",   # Counter
       "072",   # Mirror Coat
       "073",   # Metal Burst                         # Not listed on Bulbapedia
       # Helping Hand, Feint (always blacklisted together, don't know why)
       "09C",   # Helping Hand
       "0AD",   # Feint
       # Protection moves
       "0AA",   # Detect, Protect
       "0AB",   # Quick Guard
       "0AC",   # Wide Guard
       "0E8",   # Endure
       "149",   # Mat Block
       "14A",   # Crafty Shield
       "14B",   # King's Shield
       "14C",   # Spiky Shield
       "168",   # Baneful Bunker
       # Moves that call other moves
       "0AE",   # Mirror Move
       "0AF",   # Copycat
       "0B0",   # Me First
       "0B3",   # Nature Power
       "0B4",   # Sleep Talk
       "0B5",   # Assist
       "0B6",   # Metronome
       # Move-redirecting and stealing moves
       "0B1",   # Magic Coat                          # Not listed on Bulbapedia
       "0B2",   # Snatch
       "117",   # Follow Me, Rage Powder
       "16A",   # Spotlight
       # Set up effects that trigger upon KO
       "0E6",   # Grudge                              # Not listed on Bulbapedia
       "0E7",   # Destiny Bond
       # Held item-moving moves
       "0F1",   # Covet, Thief
       "0F2",   # Switcheroo, Trick
       "0F3",   # Bestow
       # Moves that start focussing at the start of the round
       "115",   # Focus Punch
       "171",   # Shell Trap
       "172",   # Beak Blast
       # Event moves that do nothing
       "133",   # Hold Hands
       "134",    # Celebrate
       # Z-moves
       "Z000"
    ]
    @moveBlacklistSignatures = [
       :SNARL,
       # Signature moves
       :DIAMONDSTORM,     # Diancie (Gen 6)
       :FLEURCANNON,      # Magearna (Gen 7)
       :FREEZESHOCK,      # Black Kyurem (Gen 5)
       :HYPERSPACEFURY,   # Hoopa Unbound (Gen 6)
       :HYPERSPACEHOLE,   # Hoopa Confined (Gen 6)
       :ICEBURN,          # White Kyurem (Gen 5)
       :LIGHTOFRUIN,      # Eternal Flower Floette (Gen 6)
       :MINDBLOWN,        # Blacephalon (Gen 7)
       :PHOTONGEYSER,     # Necrozma (Gen 7)
       :PLASMAFISTS,      # Zeraora (Gen 7)
       :RELICSONG,        # Meloetta (Gen 5)
       :SECRETSWORD,      # Keldeo (Gen 5)
       :SPECTRALTHIEF,    # Marshadow (Gen 7)
       :STEAMERUPTION,    # Volcanion (Gen 6)
       :TECHNOBLAST,      # Genesect (Gen 5)
       :THOUSANDARROWS,   # Zygarde (Gen 6)
       :THOUSANDWAVES,    # Zygarde (Gen 6)
       :VCREATE           # Victini (Gen 5)
    ]
    @moveBlacklistCut = [
       # Moves that have been cut from the game
       :CHARM,
       :SKYATTACK,
       :CONFUSION,
       :ROCKSMASH,
       :DRAGONRUSH,
       :SMARTSTRIKE,
       :SWEETKISS,
       :SONICBOOM,
       :PRESENT,
       :MISTYTERRAIN,
       :THUNDERWAVE,
       :DREAMEATER,
       :FURYATTACK
    ]
  end

  def pbMoveFailed?(user,targets)
    @metronomeMove = nil
    move_keys = GameData::Move::DATA.keys
    # NOTE: You could be really unlucky and roll blacklisted moves 1000 times in
    #       a row. This is too unlikely to care about, though.
    1000.times do
      move_id = move_keys[@battle.pbRandom(move_keys.length)]
      move_data = GameData::Move.get(move_id)
      next if @moveBlacklist.include?(move_data.function_code)
      next if @moveBlacklistSignatures.include?(move_data.id)
      next if @moveBlacklistCut.include?(move_data.id)
      next if move_data.type == :SHADOW
      next if PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(move_id)).empowered?
      @metronomeMove = move_data.id
      break
    end
    if !@metronomeMove
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbUseMoveSimple(@metronomeMove)
  end
end



#===============================================================================
# Power is chosen at random. Power is doubled if the target is using Dig. Hits
# some semi-invulnerable targets. (Magnitude)
#===============================================================================
class PokeBattle_Move_095 < PokeBattle_Move
  def pbDisplayUseMessage(user,targets=[])
    chooseBasePower(user,targets)
    super
  end

  def pbOnStartUse(user,targets); end # NOTHING

  def chooseBasePower(user,targets)
    baseDmg = [10,30,50,70,90,110,150]
    magnitudes = [
       4,
       5,5,
       6,6,6,6,
       7,7,7,7,7,7,
       8,8,8,8,
       9,9,
       10
    ]
    magni = magnitudes[@battle.pbRandom(magnitudes.length)]
    @magnitudeBP = baseDmg[magni-4]
  end

  def pbBaseDamage(baseDmg,user,target)
    return @magnitudeBP
  end

  def pbModifyDamage(damageMult,user,target)
    damageMult *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
    return damageMult
  end
end

#===============================================================================
# Freezes the target. Effectiveness against Water-type is 2x. (Freeze-Dry)
#===============================================================================
class PokeBattle_Move_135 < PokeBattle_FrostbiteMove
  def pbCalcTypeModSingle(moveType,defType,user,target)
    return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :WATER
    return super
  end
end

#===============================================================================
# Freezes the target. Accuracy perfect in hail. (Blizzard)
#===============================================================================
class PokeBattle_Move_00D < PokeBattle_FrostbiteMove
  def pbBaseAccuracy(user,target)
    return 0 if @battle.pbWeather == :Hail
    return super
  end
end

#===============================================================================
# Reduces the user's HP by half of max, and sets its Attack to maximum.
# (Belly Drum)
#===============================================================================
class PokeBattle_Move_03A < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    hpLoss = [user.totalhp/2,1].max
    if user.hp<=hpLoss
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if !user.pbCanRaiseStatStage?(:ATTACK,user,self,true)
    return false
  end

  def pbEffectGeneral(user)
    hpLoss = [user.totalhp/2,1].max
    user.pbReduceHP(hpLoss,false)
    user.pbMaximizeStatStage(:ATTACK,user,self)
    user.pbItemHPHealCheck
  end
end