class PokeBattle_Move
	def getScore(score,user,target,skill=100)
		return score
	end
end

#===============================================================================
# Pseudomove for confusion damage.
#===============================================================================
class PokeBattle_Confusion < PokeBattle_Move
  def initialize(battle,move)
    @battle     = battle
    @realMove   = move
    @id         = 0
    @name       = ""
    @function   = "000"
    @baseDamage = 50
    @type       = nil
    @category   = 0
    @accuracy   = 100
    @pp         = -1
    @target     = 0
    @priority   = 0
    @flags      = ""
    @addlEffect = 0
    @calcType   = nil
    @powerBoost = false
    @snatched   = false
  end
end

#===============================================================================
# Generic target's stat increase/decrease classes.
#===============================================================================
class PokeBattle_TargetStatDownMove < PokeBattle_Move
	attr_accessor :statDown
end

class PokeBattle_FixedDamageMove
	def pbCalcTypeModSingle(moveType,defType,user,target)
		ret = super
		ret = Effectiveness::NORMAL_EFFECTIVE_ONE unless Effectiveness.ineffective?(ret)
		return ret
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
	score = 20
    score = 0 if skill>=PBTrainerAI.mediumSkill
	return score
  end
end

def getScoreForPuttingToSleep(score,user,target,skill=100)
	score += 50
	if skill>=PBTrainerAI.mediumSkill
	  score = 0 if target.effects[PBEffects::Yawn]>0
	end
	if skill>=PBTrainerAI.highSkill
	  score -= 50 if target.hasActiveAbility?(:MARVELSCALE)
	end
	if skill>=PBTrainerAI.bestSkill && target.pbHasMoveFunction?("011","0B4")   # Snore, Sleep Talk
		score = 0
	end
	return score
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
	elsif statusMove? && skill>=PBTrainerAI.mediumSkill
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
	if target.effects[PBEffects::Yawn]>0 || !target.pbCanSleep?(user,false)
        score = 0 if skill>=PBTrainerAI.mediumSkill
    else
        score = getScoreForPuttingToSleep(score,user,target,skill=100)
    end
	return score / 2
  end
end


#===============================================================================
# Cures all party Pokémon of permanent status problems. (Aromatherapy, Heal Bell)
#===============================================================================
# NOTE: In Gen 5, this move should have a target of UserSide, while in Gen 6+ it
#       should have a target of UserAndAllies. This is because, in Gen 5, this
#       move shouldn't call def pbSuccessCheckAgainstTarget for each Pokémon
#       currently in battle that will be affected by this move (i.e. allies
#       aren't protected by their substitute/ability/etc., but they are in Gen
#       6+). We achieve this by not targeting any battlers in Gen 5, since
#       pbSuccessCheckAgainstTarget is only called for targeted battlers.
class PokeBattle_Move_019
	def pbAromatherapyHeal(pkmn,battler=nil)
    oldStatus = (battler) ? battler.status : pkmn.status
    curedName = (battler) ? battler.pbThis : pkmn.name
    if battler
      battler.pbCureStatus(false)
    else
      pkmn.status      = :NONE
      pkmn.statusCount = 0
    end
    case oldStatus
    when :SLEEP
      @battle.pbDisplay(_INTL("{1} was woken from sleep.",curedName))
    when :POISON
      @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",curedName))
    when :BURN
      @battle.pbDisplay(_INTL("{1}'s burn was healed.",curedName))
    when :PARALYSIS
      @battle.pbDisplay(_INTL("{1} was cured of paralysis.",curedName))
    when :FROZEN
      @battle.pbDisplay(_INTL("{1} was unchilled.",curedName))
    end
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
      msg = _INTL("{1} was cured of paralysis.",user.pbThis)
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
# Trapping move. Traps for 5 or 6 rounds. Trapped Pokémon lose 1/16 of max HP
# at end of each round.
#===============================================================================
class PokeBattle_Move_0CF < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    return if target.fainted? || target.damageState.substitute
    return if target.effects[PBEffects::Trapping]>0
    # Set trapping effect duration and info
    if user.hasActiveItem?(:GRIPCLAW)
      target.effects[PBEffects::Trapping] = (Settings::MECHANICS_GENERATION >= 5) ? 8 : 6
    else
      target.effects[PBEffects::Trapping] = 5+@battle.pbRandom(2)
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
       80 => [:ASSAULTVEST,:DAWNSTONE,:DUSKSTONE,:ELECTIRIZER,:MAGMARIZER,
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
              :EXPSHARE,:FLAMEORB,:FLOATSTONE,:FLUFFYTAIL,:GOLDBOTTLECAP,
              :HEARTSCALE,:HONEY,:KINGSROCK,:LIFEORB,:LIGHTBALL,:LIGHTCLAY,
              :LUCKYEGG,:LUMINOUSMOSS,:MAGNET,:METALCOAT,:METRONOME,
              :MIRACLESEED,:MYSTICWATER,:NEVERMELTICE,:PASSORB,:POKEDOLL,
              :POKETOY,:PRISMSCALE,:PROTECTIVEPADS,:RAZORFANG,:SACREDASH,
              :SCOPELENS,:SHELLBELL,:SHOALSALT,:SHOALSHELL,:SMOKEBALL,:SNOWBALL,
              :SOULDEW,:SPELLTAG,:POISONORB,:TWISTEDSPOON,:UPGRADE,
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
      target.pbPoison(user,nil) if target.pbCanPoison?(user,false,self)
    when :FLAMEORB
      target.pbBurn(user) if target.pbCanBurn?(user,false,self)
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
# User steals the target's item, if the user has none itself. (Covet, Thief)
# Items stolen from wild Pokémon are kept after the battle.
#===============================================================================
class PokeBattle_Move_0F1 < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if @battle.wildBattle? && user.opposes? && !user.boss   # Wild Pokémon can't thieve, except if they are bosses
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || user.item
    return if target.unlosableItem?(target.item)
    return if user.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    user.item = target.item
    # Permanently steal the item from wild Pokémon
    if @battle.wildBattle? && target.opposes? && @battle.bossBattle?
      ## target.initialItem==target.item 									THIS COMMENT SEEMINGLY WAS NOT WANTED, HOPEFULLY NOTHING BREAKS
	 $PokemonBag.pbStoreItem(target.item,1)
      target.pbRemoveItem
    else
      target.pbRemoveItem(false)
    end
    @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,target.pbThis(true),itemName))
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
    # Permanently steal the item from wild Pokémon
    if @battle.wildBattle? && target.opposes? && @battle.bossBattle?
       target.initialItem==oldTargetItem && !user.initialItem
      user.setInitialItem(oldTargetItem)
    end
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
# Entry hazard. Lays poison spikes on the opposing side (max. 1 layers).
# (Poison Spikes)
#===============================================================================
class PokeBattle_Move_104 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::ToxicSpikes] += 1
    @battle.pbDisplay(_INTL("Poison spikes were scattered all around {1}'s feet!",
       user.pbOpposingTeam(true)))
  end
end
