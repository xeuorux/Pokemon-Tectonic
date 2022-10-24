  #===============================================================================
  # User is protected against damaging moves this round. Decreases the Defense of
  # the user of a stopped contact move by 2 stages. (Obstruct)
  #===============================================================================
class PokeBattle_Move_180 < PokeBattle_ProtectMove
    def initialize(battle, move)
      super
      @effect = PBEffects::Obstruct
    end
end

  #===============================================================================
  # Lowers target's Defense and Special Defense by 1 stage at the end of each
  # turn. Prevents target from retreating. (Octolock)
  #===============================================================================
class PokeBattle_Move_181 < PokeBattle_Move
  def pbFailsAgainstTarget?(user, target)
    if target.effectActive?(:Octolock)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if target.pbHasType?(:GHOST)
      @battle.pbDisplay(_INTL("But {1} isn't affected because it's a Ghost...", target.pbThis(true)))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.applyEffect(:Octolock)
    target.applyEffect(:OctolockUser,user.index)
  end

  def getScore(score, _user, target, _skill = 100)
    score += 40 if target.hp > target.totalhp / 2
    return score
  end
end

  #===============================================================================
  # Ignores move redirection from abilities and moves. (Snipe Shot)
  #===============================================================================
class PokeBattle_Move_182 < PokeBattle_Move
end

  #===============================================================================
  # Consumes berry and raises the user's Defense by 2 stages. (Stuff Cheeks)
  #===============================================================================
class PokeBattle_Move_183 < PokeBattle_Move
  def pbEffectGeneral(user)
    if !user.item || !user.item.is_berry?
      @battle.pbDisplay("But it failed!")
      return -1
    end
    if user.pbCanRaiseStatStage?(:DEFENSE, user, self)
      user.pbRaiseStatStage(:DEFENSE, 2, user)
    end
    user.pbHeldItemTriggerCheck(user.item, false)
    user.pbConsumeItem(true, true, false) if user.item
  end

  def getScore(score, user, _target, _skill = 100)
    score += 40 if user.hp > user.totalhp / 2
    score -= user.stages[:DEFENSE] * 10
    score = 0 if !user.item || !user.item.is_berry?
    return score
  end
end

  #===============================================================================
  # Forces all active Pokémon to consume their held berries. This move bypasses
  # Substitutes. (Tea Time)
  #===============================================================================
class PokeBattle_Move_184 < PokeBattle_Move
  def ignoresSubstitute?(_user); return true; end

  def pbMoveFailed?(_user, _targets, messages = true)
    @validTargets = []
    @battle.eachBattler do |b|
      next if !b.item || !b.item.is_berry?
      @validTargets.push(b.index)
    end
    if @validTargets.length == 0
      @battle.pbDisplay(_INTL("But it failed!")) if messages
      return true
    end
    @battle.pbDisplay(_INTL("It's tea time! Everyone dug in to their Berries!")) if messages
    return false
  end

  def pbFailsAgainstTarget?(_user, target)
    return false if @validTargets.include?(target.index)
    return true if target.semiInvulnerable?
  end

  def pbEffectAgainstTarget(_user, target)
    target.pbHeldItemTriggerCheck(target.item, false)
    target.pbConsumeItem(true, true, false) if target.item.is_berry?
  end

  def getScore(score, _user, target, _skill = 100)
    score -= 40
    score += 20 if target.item && target.item.is_berry?
    return score
  end
end

  #===============================================================================
  # Decreases Opponent's Defense by 1 stage. Does Double Damage under gravity
  # (Grav Apple)
  #===============================================================================
class PokeBattle_Move_185 < PokeBattle_TargetStatDownMove
  def initialize(battle, move)
    super
    @statDown = [:DEFENSE, 1]
  end

  def pbBaseDamage(baseDmg, _user, _target)
    baseDmg *= 1.5 if @battle.field.effects[PBEffects::Gravity] > 0
    return baseDmg
  end
end

  #===============================================================================
  # Decrease 1 stage of speed and weakens target to fire moves. (Tar Shot)
  #===============================================================================
class PokeBattle_Move_186 < PokeBattle_Move
  def pbEffectAgainstTarget(_user, target)
    if !target.pbCanLowerStatStage?(:SPEED, target, self) && !target.effects[PBEffects::TarShot]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    if target.pbCanLowerStatStage?(:SPEED, target, self)
      target.pbLowerStatStage(:SPEED, 1, target)
    end
    if target.effects[PBEffects::TarShot] == false
      target.effects[PBEffects::TarShot] = true
      @battle.pbDisplay(_INTL("{1} became weaker to fire!", target.pbThis))
    end
  end

  def getScore(score, _user, target, _skill = 100)
    score += 30 if target.hp > target.totalhp / 2
    score += target.stages[:SPEED] * 10
    score -= 60 if target.effects[PBEffects::TarShot]
    return score
  end
end

  #===============================================================================
  # Changes Category based on Opponent's Def and SpDef. Has 20% Chance to Poison
  # (Shell Side Arm)
  #===============================================================================
class PokeBattle_Move_187 < PokeBattle_Move_005
  def initialize(battle, move)
    super
    @calcCategory = 1
  end

  def pbEffectAgainstTarget(user, target)
    if rand(5) < 1 && target.pbCanPoison?(user, true, self)
      target.pbPoison(user)
    end
  end

  def physicalMove?(_thisType = nil); return (@calcCategory == 0); end
  def specialMove?(_thisType = nil);  return (@calcCategory == 1); end

  def pbOnStartUse(_user, targets)
    stageMul = [2, 2, 2, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8]
    stageDiv = [8, 7, 6, 5, 4, 3, 2, 2, 2, 2, 2, 2, 2]
    defense      = targets[0].defense
    defenseStage = targets[0].stages[:DEFENSE] + 6
    realDefense  = (defense.to_f * stageMul[defenseStage] / stageDiv[defenseStage]).floor
    spdef        = targets[0].spdef
    spdefStage   = targets[0].stages[:SPDEF] + 6
    realSpdef    = (spdef.to_f * stageMul[spdefStage] / stageDiv[spdefStage]).floor
    # Determine move's category
    return @calcCategory = 0 if realDefense < realSpdef
    return @calcCategory = 1 if realDefense >= realSpdef
    if @id == :WONDERROOM; end
  end

  def getScore(score, user, target, skill = 100)
      score = getPoisonMoveScore(score, user, target, skill, [], statusMove?)
      return score
  end
end

  #===============================================================================
  # Hits 3 times and always critical. (Surging Strikes)
  #===============================================================================
class PokeBattle_Move_188 < PokeBattle_Move_0A0
  def multiHitMove?; return true; end
  def pbNumHits(_user, _targets, _checkingForAI = false); return 3; end
end

  #===============================================================================
  # Restore HP and heals any status conditions of itself and its allies
  # (Jungle Healing)
  #===============================================================================
class PokeBattle_Move_189 < PokeBattle_Move
  def healingMove?; return true; end

  def pbMoveFailed?(_user, targets, messages = true)
    jglheal = 0
    for i in 0...targets.length
      jglheal += 1 if (targets[i].hp == targets[i].totalhp || !targets[i].canHeal?) && targets[i].status == :NONE
    end
    if jglheal == targets.length
      @battle.pbDisplay(_INTL("But it failed!")) if messages
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.pbCureStatus
    if target.hp != target.totalhp && target.canHeal?
      hpGain = (target.totalhp / 4.0).round
      target.pbRecoverHP(hpGain)
    end
    super
  end
end

  #===============================================================================
  # Changes type and base power based on Battle Terrain (Terrain Pulse)
  #===============================================================================
class PokeBattle_Move_18A < PokeBattle_Move
  def pbBaseDamage(baseDmg, user, _target)
    baseDmg *= 2 if @battle.field.terrain != :None && !user.airborne?
    return baseDmg
  end

  def pbBaseType(user)
    ret = :NORMAL
    if !user.airborne?
      case @battle.field.terrain
      when :Electric
        ret = :ELECTRIC || ret
      when :Grassy
        ret = :GRASS || ret
      when :Misty
        ret = :FAIRY || ret
      when :Psychic
        ret = :PSYCHIC || ret
      end
    end
    return ret
  end

  def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
    t = pbBaseType(user)
    hitNum = 1 if t == :ELECTRIC
    hitNum = 2 if t == :GRASS
    hitNum = 3 if t == :FAIRY
    hitNum = 4 if t == :PSYCHIC
    super
  end
end

  #===============================================================================
  # Burns opposing Pokemon that have increased their stats. (Burning Jealousy)
  #===============================================================================
class PokeBattle_Move_18B < PokeBattle_Move
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    if target.pbCanBurn?(user, false, self) && target.hasRaisedStatStages?
      target.pbBurn(user)
    end
  end

  def getScore(score, user, target, _skill = 100)
        score -= 30
        score += 60 if target.pbCanBurn?(user, false, self) && target.hasRaisedStatStages?
        return score
  end
end

  #===============================================================================
  # Move has increased Priority in Grassy Terrain (Grassy Glide)
  #===============================================================================
class PokeBattle_Move_18C < PokeBattle_Move
    def priorityModification(_user, _targets);
        return 1 if @battle.field.terrain == :Grassy
        return 0
    end

    def getScore(score, _user, target, _skill = 100)
        score -= 20
        if @battle.field.terrain == :Grassy
            score += 50
            score += 50 if target.hp <= target.totalhp / 2
        end
        return score
    end
end

  #===============================================================================
  # Power Doubles onn Electric Terrain (Rising Voltage)
  #===============================================================================
class PokeBattle_Move_18D < PokeBattle_Move
  def pbBaseDamage(baseDmg, _user, target)
    baseDmg *= 2 if @battle.field.terrain == :Electric && !target.airborne?
    return baseDmg
  end
end

  #===============================================================================
  # Boosts Targets' Attack and Defense (Coaching)
  #===============================================================================
class PokeBattle_Move_18E < PokeBattle_TargetMultiStatUpMove
  def initialize(battle, move)
    super
    @statUp = [:ATTACK, 1, :DEFENSE, 1]
  end
end

  #===============================================================================
  # Renders item unusable (Corrosive Gas)
  #===============================================================================
class PokeBattle_Move_18F < PokeBattle_Move
  def pbEffectAgainstTarget(user, target)
    return if @battle.wildBattle? && user.opposes? && !user.boss # Wild Pokémon can't knock off, except bosses
    return if user.fainted?
    return if target.damageState.substitute
    return if target.item == 0 || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1}'s {2} became unusuable, so it dropped it!", target.pbThis, itemName))
  end
end

  #===============================================================================
  # Power is boosted on Psychic Terrain (Expanding Force)
  #===============================================================================
class PokeBattle_Move_190 < PokeBattle_Move
  def pbBaseDamage(baseDmg, _user, _target)
    baseDmg *= 1.5 if @battle.field.terrain == :Psychic
    return baseDmg
  end
end

  #===============================================================================
  # Boosts Sp Atk on 1st Turn and Attacks on 2nd (Meteor Beam)
  #===============================================================================
class PokeBattle_Move_191 < PokeBattle_TwoTurnMove
  def pbChargingTurnMessage(user, _targets)
    @battle.pbDisplay(_INTL("{1} is overflowing with space power!", user.pbThis))
  end

  def pbChargingTurnEffect(user, _target)
    if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user, self)
      user.pbRaiseStatStage(:SPECIAL_ATTACK, 1, user)
    end
  end
end

  #===============================================================================
  # Fails if the Target has no Item (Poltergeist)
  #===============================================================================
class PokeBattle_Move_192 < PokeBattle_Move
  def pbFailsAgainstTarget?(_user, target)
    if target.item
      @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!", target.pbThis, target.itemName))
      return false
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return true
  end

  def getScore(score, _user, target, _skill = 100)
    score += 20
    score = 0 if !target.item
    return score
  end
end

  #===============================================================================
  # Reduces Defense and Raises Speed after all hits (Scale Shot)
  #===============================================================================
class PokeBattle_Move_193 < PokeBattle_Move_0C0
  def pbEffectAfterAllHits(user, target)
    if user.pbCanRaiseStatStage?(:SPEED, user, self)
      user.pbRaiseStatStage(:SPEED, 1, user)
    end
    if user.pbCanLowerStatStage?(:DEFENSE, target)
      user.pbLowerStatStage(:DEFENSE, 1, user)
    end
  end

  def getScore(score, user, _target, _skill = 100)
    score -= user.stages[:SPEED] * 10
    score += user.stages[:DEFENSE] * 10
    return score
  end
end

  #===============================================================================
  # Double damage if stats were lowered that turn. (Lash Out)
  #===============================================================================
class PokeBattle_Move_194 < PokeBattle_Move
  def pbBaseDamage(baseDmg, user, _target)
    baseDmg *= 2 if user.effectActive?(:StatsDropped)
    return baseDmg
  end
end

  #===============================================================================
  # Removes all Terrain. Fails if there is no Terrain (Steel Roller)
  #===============================================================================
class PokeBattle_Move_195 < PokeBattle_Move
  def pbMoveFailed?(_user, _targets, messages = true)
    if @battle.field.terrain == :None
      @battle.pbDisplay(_INTL("But it failed!")) if messages
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    case @battle.field.terrain
    when :Electric
        @battle.pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
    when :Grassy
        @battle.pbDisplay(_INTL("The grass disappeared from the battlefield!"))
    when :Misty
        @battle.pbDisplay(_INTL("The fae mist disappeared from the battlefield!"))
    when :Psychic
        @battle.pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
    end
    @battle.pbStartTerrain(user, :None, true)
  end

  def getScore(score, _user, _target, _skill = 100)
    score += 30
    score = 0 if battle.field.terrain == :NONE
    return score
  end
end

  #===============================================================================
  # User loses half their max health. Boosted Damage when on Misty Terrain (Misty Explosion)
  #===============================================================================
class PokeBattle_Move_196 < PokeBattle_Move_0E0
  def pbBaseDamage(baseDmg, user, _target)
    if @battle.field.terrain == :Misty && !user.airborne?
      baseDmg = (baseDmg * 1.5).round
    end
    return baseDmg
  end

  def getScore(score, user, _target, _skill = 100)
      score += 50
      score -= ((user.hp.to_f / user.totalhp.to_f) * 100).floor
      return score
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.applyFractionalDamage(1.0 / 2.0, false)
  end
end

  #===============================================================================
  # Target becomes Psychic type. (Magic Powder)
  #===============================================================================
class PokeBattle_Move_197 < PokeBattle_Move
  def pbFailsAgainstTarget?(_user, target)
    if !target.canChangeType? ||
       !target.pbHasOtherType?(:PSYCHIC)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(_user, target)
    newType = :PSYCHIC
    target.pbChangeTypes(newType)
    typeName = newType.name
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", target.pbThis, typeName))
  end

  def getScore(score, _user, target, _skill = 100)
    score += 50
    score = 0 if !target.canChangeType? || !target.pbHasOtherType?(:PSYCHIC)
    return score
  end
end

  #===============================================================================
  # Target's last move used loses 3 PP. (Eerie Spell - Galarian Slowking)
  #===============================================================================
class PokeBattle_Move_198 < PokeBattle_Move
  def pbFailsAgainstTarget?(_user, target)
    failed = true
    target.eachMove do |m|
      next if m.id != target.lastRegularMoveUsed || m.pp == 0 || m.totalpp <= 0
      failed = false; break
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(_user, target)
    target.eachMove do |m|
      next if m.id != target.lastRegularMoveUsed
      reduction = [3, m.pp].min
      target.pbSetPP(m, m.pp - reduction)
      @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
         target.pbThis(true), m.name, reduction))
      break
    end
  end
end

  #===============================================================================
  # Deals double damage to Dynamax POkémons. Dynamax is not implemented though.
  # (Behemoth Blade, Behemoth Bash, Dynamax Cannon)
  #===============================================================================
class PokeBattle_Move_199 < PokeBattle_Move
  # DYNAMAX IS NOT IMPLEMENTED.
end