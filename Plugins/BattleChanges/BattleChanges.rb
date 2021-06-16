class PokeBattle_Battle
	attr_accessor :ballsUsed       # Number of balls thrown without capture
	attr_accessor :messagesBlocked
	attr_accessor :commandPhasesThisRound
	
  #=============================================================================
  # Creating the battle class
  #=============================================================================
  def initialize(scene,p1,p2,player,opponent)
    if p1.length==0
      raise ArgumentError.new(_INTL("Party 1 has no Pokémon."))
    elsif p2.length==0
      raise ArgumentError.new(_INTL("Party 2 has no Pokémon."))
    end
    @scene             = scene
    @peer              = PokeBattle_BattlePeer.create
    @battleAI          = PokeBattle_AI.new(self)
    @field             = PokeBattle_ActiveField.new    # Whole field (gravity/rooms)
    @sides             = [PokeBattle_ActiveSide.new,   # Player's side
                          PokeBattle_ActiveSide.new]   # Foe's side
    @positions         = []                            # Battler positions
    @battlers          = []
    @sideSizes         = [1,1]   # Single battle, 1v1
    @backdrop          = ""
    @backdropBase      = nil
    @time              = 0
    @environment       = :None   # e.g. Tall grass, cave, still water
    @turnCount         = 0
    @decision          = 0
    @caughtPokemon     = []
    player   = [player] if !player.nil? && !player.is_a?(Array)
    opponent = [opponent] if !opponent.nil? && !opponent.is_a?(Array)
    @player            = player     # Array of Player/NPCTrainer objects, or nil
    @opponent          = opponent   # Array of NPCTrainer objects, or nil
    @items             = nil
    @endSpeeches       = []
    @endSpeechesWin    = []
    @party1            = p1
    @party2            = p2
    @party1order       = Array.new(@party1.length) { |i| i }
    @party2order       = Array.new(@party2.length) { |i| i }
    @party1starts      = [0]
    @party2starts      = [0]
    @internalBattle    = true
    @debug             = false
    @canRun            = true
    @canLose           = false
    @switchStyle       = true
    @showAnims         = true
    @controlPlayer     = false
    @expGain           = true
    @moneyGain         = true
    @rules             = {}
    @priority          = []
    @priorityTrickRoom = false
    @choices           = []
    @megaEvolution     = [
       [-1] * (@player ? @player.length : 1),
       [-1] * (@opponent ? @opponent.length : 1)
    ]
    @initialItems      = [
       Array.new(@party1.length) { |i| (@party1[i]) ? @party1[i].item_id : nil },
       Array.new(@party2.length) { |i| (@party2[i]) ? @party2[i].item_id : nil }
    ]
    @recycleItems      = [Array.new(@party1.length, nil),   Array.new(@party2.length, nil)]
    @belch             = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @battleBond        = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @usedInBattle      = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
    @successStates     = []
    @lastMoveUsed      = nil
    @lastMoveUser      = -1
    @switching         = false
    @futureSight       = false
    @endOfRound        = false
    @moldBreaker       = false
    @runCommand        = 0
    @nextPickupUse     = 0
	@ballsUsed		   = 0
	@messagesBlocked   = false
	@commandPhasesThisRound = 0
    if GameData::Move.exists?(:STRUGGLE)
      @struggle = PokeBattle_Move.from_pokemon_move(self, Pokemon::Move.new(:STRUGGLE))
    else
      @struggle = PokeBattle_Struggle.new(self, nil)
    end
  end
  
  #=============================================================================
  # Turn order calculation (priority)
  #=============================================================================
  def pbCalculatePriority(fullCalc=false,indexArray=nil)
    needRearranging = false
    if fullCalc
      @priorityTrickRoom = (@field.effects[PBEffects::TrickRoom]>0)
      # Recalculate everything from scratch
      randomOrder = Array.new(maxBattlerIndex+1) { |i| i }
      (randomOrder.length-1).times do |i|   # Can't use shuffle! here
        r = i+pbRandom(randomOrder.length-i)
        randomOrder[i], randomOrder[r] = randomOrder[r], randomOrder[i]
      end
      @priority.clear
      for i in 0..maxBattlerIndex
        b = @battlers[i]
        next if !b
        # [battler, speed, sub-priority, priority, tie-breaker order]
        bArray = [b,b.pbSpeed,0,0,randomOrder[i]]
        if @choices[b.index][0]==:UseMove || @choices[b.index][0]==:Shift
          # Calculate move's priority
          if @choices[b.index][0]==:UseMove
            move = @choices[b.index][2]
            pri = move.priority
            if b.abilityActive?
              pri = BattleHandlers.triggerPriorityChangeAbility(b.ability,b,move,pri)
            end
			targets = b.pbFindTargets(@choices[b.index],move,b)
			pri += move.priorityModification(b,targets)
            bArray[3] = pri
            @choices[b.index][4] = pri
          end
          # Calculate sub-priority (first/last within priority bracket)
          # NOTE: Going fast beats going slow. A Pokémon with Stall and Quick
          #       Claw will go first in its priority bracket if Quick Claw
          #       triggers, regardless of Stall.
          subPri = 0
          # Abilities (Stall)
          if b.abilityActive?
            newSubPri = BattleHandlers.triggerPriorityBracketChangeAbility(b.ability,
             b,subPri,self)
            if subPri!=newSubPri
              subPri = newSubPri
              b.effects[PBEffects::PriorityAbility] = true
              b.effects[PBEffects::PriorityItem]    = false
            end
          end
          # Items (Quick Claw, Custap Berry, Lagging Tail, Full Incense)
          if b.itemActive?
            newSubPri = BattleHandlers.triggerPriorityBracketChangeItem(b.item,
               b,subPri,self)
            if subPri!=newSubPri
              subPri = newSubPri
              b.effects[PBEffects::PriorityAbility] = false
              b.effects[PBEffects::PriorityItem]    = true
            end
          end
          bArray[2] = subPri
        end
        @priority.push(bArray)
      end
      needRearranging = true
    else
      if (@field.effects[PBEffects::TrickRoom]>0)!=@priorityTrickRoom
        needRearranging = true
        @priorityTrickRoom = (@field.effects[PBEffects::TrickRoom]>0)
      end
      # Just recheck all battler speeds
      @priority.each do |orderArray|
        next if !orderArray
        next if indexArray && !indexArray.include?(orderArray[0].index)
        oldSpeed = orderArray[1]
        orderArray[1] = orderArray[0].pbSpeed
        needRearranging = true if orderArray[1]!=oldSpeed
      end
    end
    # Reorder the priority array
    if needRearranging
      @priority.sort! { |a,b|
        if a[3]!=b[3]
          # Sort by priority (highest value first)
          b[3]<=>a[3]
        elsif a[2]!=b[2]
          # Sort by sub-priority (highest value first)
          b[2]<=>a[2]
        elsif @priorityTrickRoom
          # Sort by speed (lowest first), and use tie-breaker if necessary
          (a[1]==b[1]) ? b[4]<=>a[4] : a[1]<=>b[1]
        else
          # Sort by speed (highest first), and use tie-breaker if necessary
          (a[1]==b[1]) ? b[4]<=>a[4] : b[1]<=>a[1]
        end
      }
      # Write the priority order to the debug log
      logMsg = (fullCalc) ? "[Round order] " : "[Round order recalculated] "
      comma = false
      @priority.each do |orderArray|
        logMsg += ", " if comma
        logMsg += "#{orderArray[0].pbThis(comma)} (#{orderArray[0].index})"
        comma = true
      end
      PBDebug.log(logMsg)
    end
  end
  
  #=============================================================================
  # End of battle
  #=============================================================================
  def pbGainMoney
    return if !@internalBattle || !@moneyGain
    # Money rewarded from opposing trainers
    if trainerBattle?
      tMoney = 0
      @opponent.each_with_index do |t,i|
        tMoney += pbMaxLevelInTeam(1, i) * t.base_money
      end
      tMoney *= 2 if @field.effects[PBEffects::AmuletCoin]
      tMoney *= 2 if @field.effects[PBEffects::HappyHour]
	  tMoney *= 2 if @field.effects[PBEffects::Fortune]
      oldMoney = pbPlayer.money
      pbPlayer.money += tMoney
      moneyGained = pbPlayer.money-oldMoney
      if moneyGained>0
        pbDisplayPaused(_INTL("You got ${1} for winning!",moneyGained.to_s_formatted))
      end
    end
    # Pick up money scattered by Pay Day
    if @field.effects[PBEffects::PayDay]>0
      @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::AmuletCoin]
      @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::HappyHour]
	  @field.effects[PBEffects::PayDay] *= 2 if @field.effects[PBEffects::Fortune]
      oldMoney = pbPlayer.money
      pbPlayer.money += @field.effects[PBEffects::PayDay]
      moneyGained = pbPlayer.money-oldMoney
      if moneyGained>0
        pbDisplayPaused(_INTL("You picked up ${1}!",moneyGained.to_s_formatted))
      end
    end
  end
  
  def pbPursuit(idxSwitcher)
    @switching = true
    pbPriority.each do |b|
      next if b.fainted? || !b.opposes?(idxSwitcher)   # Shouldn't hit an ally
      next if b.movedThisRound? || !pbChoseMoveFunctionCode?(b.index,"088")   # Pursuit
      # Check whether Pursuit can be used
      next unless pbMoveCanTarget?(b.index,idxSwitcher,@choices[b.index][2].pbTarget(b))
      next unless pbCanChooseMove?(b.index,@choices[b.index][1],false)
      next if b.status == :SLEEP
      next if b.effects[PBEffects::SkyDrop]>=0
      next if b.hasActiveAbility?(:TRUANT) && b.effects[PBEffects::Truant]
      # Mega Evolve
      if !wildBattle? || !b.opposes?
        owner = pbGetOwnerIndexFromBattlerIndex(b.index)
        pbMegaEvolve(b.index) if @megaEvolution[b.idxOwnSide][owner]==b.index
      end
      # Use Pursuit
      @choices[b.index][3] = idxSwitcher   # Change Pursuit's target
      if b.pbProcessTurn(@choices[b.index],false)
        b.effects[PBEffects::Pursuit] = true
      end
      break if @decision>0 || @battlers[idxSwitcher].fainted?
    end
    @switching = false
  end
  
  #=============================================================================
  # End Of Round phase
  #=============================================================================
  def pbEndOfRoundPhase
    PBDebug.log("")
    PBDebug.log("[End of round]")
    @endOfRound = true
    @scene.pbBeginEndOfRoundPhase
    pbCalculatePriority           # recalculate speeds
    priority = pbPriority(true)   # in order of fastest -> slowest speeds only
    # Weather
    pbEORWeather(priority)
    # Future Sight/Doom Desire
    @positions.each_with_index do |pos,idxPos|
      next if !pos || pos.effects[PBEffects::FutureSightCounter]==0
      pos.effects[PBEffects::FutureSightCounter] -= 1
      next if pos.effects[PBEffects::FutureSightCounter]>0
      next if !@battlers[idxPos] || @battlers[idxPos].fainted?   # No target
      moveUser = nil
      eachBattler do |b|
        next if b.opposes?(pos.effects[PBEffects::FutureSightUserIndex])
        next if b.pokemonIndex!=pos.effects[PBEffects::FutureSightUserPartyIndex]
        moveUser = b
        break
      end
      next if moveUser && moveUser.index==idxPos   # Target is the user
      if !moveUser   # User isn't in battle, get it from the party
        party = pbParty(pos.effects[PBEffects::FutureSightUserIndex])
        pkmn = party[pos.effects[PBEffects::FutureSightUserPartyIndex]]
        if pkmn && pkmn.able?
          moveUser = PokeBattle_Battler.new(self,pos.effects[PBEffects::FutureSightUserIndex])
          moveUser.pbInitDummyPokemon(pkmn,pos.effects[PBEffects::FutureSightUserPartyIndex])
        end
      end
      next if !moveUser   # User is fainted
      move = pos.effects[PBEffects::FutureSightMove]
      pbDisplay(_INTL("{1} took the {2} attack!",@battlers[idxPos].pbThis,
         GameData::Move.get(move).name))
      # NOTE: Future Sight failing against the target here doesn't count towards
      #       Stomping Tantrum.
      userLastMoveFailed = moveUser.lastMoveFailed
      @futureSight = true
      moveUser.pbUseMoveSimple(move,idxPos)
      @futureSight = false
      moveUser.lastMoveFailed = userLastMoveFailed
      @battlers[idxPos].pbFaint if @battlers[idxPos].fainted?
      pos.effects[PBEffects::FutureSightCounter]        = 0
      pos.effects[PBEffects::FutureSightMove]           = nil
      pos.effects[PBEffects::FutureSightUserIndex]      = -1
      pos.effects[PBEffects::FutureSightUserPartyIndex] = -1
    end
    # Wish
    @positions.each_with_index do |pos,idxPos|
      next if !pos || pos.effects[PBEffects::Wish]==0
      pos.effects[PBEffects::Wish] -= 1
      next if pos.effects[PBEffects::Wish]>0
      next if !@battlers[idxPos] || !@battlers[idxPos].canHeal?
      wishMaker = pbThisEx(idxPos,pos.effects[PBEffects::WishMaker])
      @battlers[idxPos].pbRecoverHP(pos.effects[PBEffects::WishAmount])
      pbDisplay(_INTL("{1}'s wish came true!",wishMaker))
    end
    # Sea of Fire damage (Fire Pledge + Grass Pledge combination)
    curWeather = pbWeather
    for side in 0...2
      next if sides[side].effects[PBEffects::SeaOfFire]==0
      next if [:Rain, :HeavyRain].include?(curWeather)
      @battle.pbCommonAnimation("SeaOfFire") if side==0
      @battle.pbCommonAnimation("SeaOfFireOpp") if side==1
      priority.each do |b|
        next if b.opposes?(side)
        next if !b.takesIndirectDamage? || b.pbHasType?(:FIRE)
        oldHP = b.hp
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/8,false)
        pbDisplay(_INTL("{1} is hurt by the sea of fire!",b.pbThis))
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
    end
    # Status-curing effects/abilities and HP-healing items
    priority.each do |b|
      next if b.fainted?
      # Grassy Terrain (healing)
      if @field.terrain == :Grassy && b.affectedByTerrain? && b.canHeal?
        PBDebug.log("[Lingering effect] Grassy Terrain heals #{b.pbThis(true)}")
        b.pbRecoverHP(b.totalhp/16)
        pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      end
      # Healer, Hydration, Shed Skin
      BattleHandlers.triggerEORHealingAbility(b.ability,b,self) if b.abilityActive?
      # Black Sludge, Leftovers
      BattleHandlers.triggerEORHealingItem(b.item,b,self) if b.itemActive?
    end
    # Aqua Ring
    priority.each do |b|
      next if !b.effects[PBEffects::AquaRing]
      next if !b.canHeal?
      hpGain = b.totalhp/16
      hpGain = (hpGain*1.3).floor if b.hasActiveItem?(:BIGROOT)
      b.pbRecoverHP(hpGain)
      pbDisplay(_INTL("Aqua Ring restored {1}'s HP!",b.pbThis(true)))
    end
    # Ingrain
    priority.each do |b|
      next if !b.effects[PBEffects::Ingrain]
      next if !b.canHeal?
      hpGain = b.totalhp/16
      hpGain = (hpGain*1.3).floor if b.hasActiveItem?(:BIGROOT)
      b.pbRecoverHP(hpGain)
      pbDisplay(_INTL("{1} absorbed nutrients with its roots!",b.pbThis))
    end
    # Leech Seed
    priority.each do |b|
      next if b.effects[PBEffects::LeechSeed]<0
      next if !b.takesIndirectDamage?
      recipient = @battlers[b.effects[PBEffects::LeechSeed]]
      next if !recipient || recipient.fainted?
      oldHP = b.hp
      oldHPRecipient = recipient.hp
      pbCommonAnimation("LeechSeed",recipient,b)
	  healthFraction = b.boss ? 64 : 8
      hpLost = b.pbReduceHP(b.totalhp/healthFraction)
      recipient.pbRecoverHPFromDrain(hpLost,b,
         _INTL("{1}'s health is sapped by Leech Seed!",b.pbThis))
      recipient.pbAbilitiesOnDamageTaken(oldHPRecipient) if recipient.hp<oldHPRecipient
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
      recipient.pbFaint if recipient.fainted?
    end
    # Damage from Hyper Mode (Shadow Pokémon)
    priority.each do |b|
      next if !b.inHyperMode? || @choices[b.index][0]!=:UseMove
      hpLoss = b.totalhp/24
      @scene.pbDamageAnimation(b)
      b.pbReduceHP(hpLoss,false)
      pbDisplay(_INTL("The Hyper Mode attack hurts {1}!",b.pbThis(true)))
      b.pbFaint if b.fainted?
    end
    # Damage from poisoning
    priority.each do |b|
      next if b.fainted?
      next if b.status != :POISON
      if b.statusCount>0
        b.effects[PBEffects::Toxic] += 1
        b.effects[PBEffects::Toxic] = 15 if b.effects[PBEffects::Toxic]>15
      end
      if b.hasActiveAbility?(:POISONHEAL)
        if b.canHeal?
          anim_name = GameData::Status.get(:POISON).animation
          pbCommonAnimation(anim_name, b) if anim_name
          pbShowAbilitySplash(b)
          b.pbRecoverHP(b.totalhp/8)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
          else
            pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
          end
          pbHideAbilitySplash(b)
        end
      elsif b.takesIndirectDamage?
        oldHP = b.hp
        dmg = (b.statusCount==0) ? b.totalhp/8 : b.totalhp*b.effects[PBEffects::Toxic]/16
		dmg = (dmg/4.0).round if b.boss
        b.pbContinueStatus { b.pbReduceHP(dmg,false) }
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
    end
    # Damage from burn
    priority.each do |b|
      next if b.status != :BURN || !b.takesIndirectDamage?
      oldHP = b.hp
      dmg = b.totalhp/8
      dmg = (dmg/2.0).round if b.hasActiveAbility?(:HEATPROOF)
	  dmg = (dmg/4.0).round if b.boss
      b.pbContinueStatus { b.pbReduceHP(dmg,false) }
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    # Damage from sleep (Nightmare)
    priority.each do |b|
      b.effects[PBEffects::Nightmare] = false if !b.asleep?
      next if !b.effects[PBEffects::Nightmare] || !b.takesIndirectDamage?
      oldHP = b.hp
	  if b.boss
		b.pbReduceHP(b.totalhp/16)
	  else
		b.pbReduceHP(b.totalhp/4)
	  end
      pbDisplay(_INTL("{1} is locked in a nightmare!",b.pbThis))
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    # Curse
    priority.each do |b|
      next if !b.effects[PBEffects::Curse] || !b.takesIndirectDamage?
      oldHP = b.hp
	  if b.boss
		b.pbReduceHP(b.totalhp/16)
	  else
		b.pbReduceHP(b.totalhp/4)
	  end
      pbDisplay(_INTL("{1} is afflicted by the curse!",b.pbThis))
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
	# Octolock
    priority.each do |b|
      next if !b.effects[PBEffects::Octolock]
	  octouser = @battlers[b.effects[PBEffects::OctolockUser]]
      if b.pbCanLowerStatStage?(PBStats::DEFENSE,octouser,self)
        b.pbLowerStatStage(PBStats::DEFENSE,1,octouser,true,false,true)
      end
      if b.pbCanLowerStatStage?(PBStats::SPDEF,octouser,self)
        b.pbLowerStatStage(PBStats::SPDEF,1,octouser,true,false,true)
      end
    end
    # Trapping attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::Trapping]==0
      b.effects[PBEffects::Trapping] -= 1
      moveName = GameData::Move.get(b.effects[PBEffects::TrappingMove]).name
      if b.effects[PBEffects::Trapping]==0
        pbDisplay(_INTL("{1} was freed from {2}!",b.pbThis,moveName))
      else
        case b.effects[PBEffects::TrappingMove]
        when :BIND        then pbCommonAnimation("Bind", b)
        when :CLAMP       then pbCommonAnimation("Clamp", b)
        when :FIRESPIN    then pbCommonAnimation("FireSpin", b)
        when :MAGMASTORM  then pbCommonAnimation("MagmaStorm", b)
        when :SANDTOMB    then pbCommonAnimation("SandTomb", b)
        when :WRAP        then pbCommonAnimation("Wrap", b)
        when :INFESTATION then pbCommonAnimation("Infestation", b)
		when :SNAPTRAP 	  then pbCommonAnimation("SnapTrap",b)
        when :THUNDERCAGE then pbCommonAnimation("ThunderCage",b)
        else                   pbCommonAnimation("Wrap", b)
        end
        if b.takesIndirectDamage?
          hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? b.totalhp/8 : b.totalhp/16
          if @battlers[b.effects[PBEffects::TrappingUser]].hasActiveItem?(:BINDINGBAND)
            hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? b.totalhp/6 : b.totalhp/8
          end
		  hpLoss = (hpLoss/4.0).floor if b.boss
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(hpLoss,false)
          pbDisplay(_INTL("{1} is hurt by {2}!",b.pbThis,moveName))
          b.pbItemHPHealCheck
          # NOTE: No need to call pbAbilitiesOnDamageTaken as b can't switch out.
          b.pbFaint if b.fainted?
        end
      end
    end
    # Taunt
    pbEORCountDownBattlerEffect(priority,PBEffects::Taunt) { |battler|
      pbDisplay(_INTL("{1}'s taunt wore off!",battler.pbThis))
    }
    # Encore
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::Encore]==0
      idxEncoreMove = b.pbEncoredMoveIndex
      if idxEncoreMove>=0
        b.effects[PBEffects::Encore] -= 1
        if b.effects[PBEffects::Encore]==0 || b.moves[idxEncoreMove].pp==0
          b.effects[PBEffects::Encore] = 0
          pbDisplay(_INTL("{1}'s encore ended!",b.pbThis))
        end
      else
        PBDebug.log("[End of effect] #{b.pbThis}'s encore ended (encored move no longer known)")
        b.effects[PBEffects::Encore]     = 0
        b.effects[PBEffects::EncoreMove] = nil
      end
    end
    # Disable/Cursed Body
    pbEORCountDownBattlerEffect(priority,PBEffects::Disable) { |battler|
      battler.effects[PBEffects::DisableMove] = nil
      pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis))
    }
    # Magnet Rise
    pbEORCountDownBattlerEffect(priority,PBEffects::MagnetRise) { |battler|
      pbDisplay(_INTL("{1}'s electromagnetism wore off!",battler.pbThis))
    }
    # Telekinesis
    pbEORCountDownBattlerEffect(priority,PBEffects::Telekinesis) { |battler|
      pbDisplay(_INTL("{1} was freed from the telekinesis!",battler.pbThis))
    }
    # Heal Block
    pbEORCountDownBattlerEffect(priority,PBEffects::HealBlock) { |battler|
      pbDisplay(_INTL("{1}'s Heal Block wore off!",battler.pbThis))
    }
    # Embargo
    pbEORCountDownBattlerEffect(priority,PBEffects::Embargo) { |battler|
      pbDisplay(_INTL("{1} can use items again!",battler.pbThis))
      battler.pbItemTerrainStatBoostCheck
    }
    # Yawn
    pbEORCountDownBattlerEffect(priority,PBEffects::Yawn) { |battler|
      if battler.pbCanSleepYawn?
        PBDebug.log("[Lingering effect] #{battler.pbThis} fell asleep because of Yawn")
        battler.pbSleep
      end
    }
    # Perish Song
    perishSongUsers = []
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::PerishSong]==0
      b.effects[PBEffects::PerishSong] -= 1
      pbDisplay(_INTL("{1}'s perish count fell to {2}!",b.pbThis,b.effects[PBEffects::PerishSong]))
      if b.effects[PBEffects::PerishSong]==0
        perishSongUsers.push(b.effects[PBEffects::PerishSongUser])
        b.pbReduceHP(b.hp)
      end
      b.pbItemHPHealCheck
      b.pbFaint if b.fainted?
    end
    if perishSongUsers.length>0
      # If all remaining Pokemon fainted by a Perish Song triggered by a single side
      if (perishSongUsers.find_all { |idxBattler| opposes?(idxBattler) }.length==perishSongUsers.length) ||
         (perishSongUsers.find_all { |idxBattler| !opposes?(idxBattler) }.length==perishSongUsers.length)
        pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
      end
    end
    # Check for end of battle
    if @decision>0
      pbGainExp
      return
    end
    for side in 0...2
      # Reflect
      pbEORCountDownSideEffect(side,PBEffects::Reflect,
         _INTL("{1}'s Reflect wore off!",@battlers[side].pbTeam))
      # Light Screen
      pbEORCountDownSideEffect(side,PBEffects::LightScreen,
         _INTL("{1}'s Light Screen wore off!",@battlers[side].pbTeam))
      # Safeguard
      pbEORCountDownSideEffect(side,PBEffects::Safeguard,
         _INTL("{1} is no longer protected by Safeguard!",@battlers[side].pbTeam))
      # Mist
      pbEORCountDownSideEffect(side,PBEffects::Mist,
         _INTL("{1} is no longer protected by mist!",@battlers[side].pbTeam))
      # Tailwind
      pbEORCountDownSideEffect(side,PBEffects::Tailwind,
         _INTL("{1}'s Tailwind petered out!",@battlers[side].pbTeam))
      # Lucky Chant
      pbEORCountDownSideEffect(side,PBEffects::LuckyChant,
         _INTL("{1}'s Lucky Chant wore off!",@battlers[side].pbTeam))
      # Pledge Rainbow
      pbEORCountDownSideEffect(side,PBEffects::Rainbow,
         _INTL("The rainbow on {1}'s side disappeared!",@battlers[side].pbTeam(true)))
      # Pledge Sea of Fire
      pbEORCountDownSideEffect(side,PBEffects::SeaOfFire,
         _INTL("The sea of fire around {1} disappeared!",@battlers[side].pbTeam(true)))
      # Pledge Swamp
      pbEORCountDownSideEffect(side,PBEffects::Swamp,
         _INTL("The swamp around {1} disappeared!",@battlers[side].pbTeam(true)))
      # Aurora Veil
      pbEORCountDownSideEffect(side,PBEffects::AuroraVeil,
         _INTL("{1}'s Aurora Veil wore off!",@battlers[side].pbTeam(true)))
    end
    # Trick Room
    pbEORCountDownFieldEffect(PBEffects::TrickRoom,
       _INTL("The twisted dimensions returned to normal!"))
    # Gravity
    pbEORCountDownFieldEffect(PBEffects::Gravity,
       _INTL("Gravity returned to normal!"))
    # Water Sport
    pbEORCountDownFieldEffect(PBEffects::WaterSportField,
       _INTL("The effects of Water Sport have faded."))
    # Mud Sport
    pbEORCountDownFieldEffect(PBEffects::MudSportField,
       _INTL("The effects of Mud Sport have faded."))
    # Wonder Room
    pbEORCountDownFieldEffect(PBEffects::WonderRoom,
       _INTL("Wonder Room wore off, and Defense and Sp. Def stats returned to normal!"))
    # Magic Room
    pbEORCountDownFieldEffect(PBEffects::MagicRoom,
       _INTL("Magic Room wore off, and held items' effects returned to normal!"))
    # End of terrains
    pbEORTerrain
    priority.each do |b|
      next if b.fainted?
      # Hyper Mode (Shadow Pokémon)
      if b.inHyperMode?
        if pbRandom(100)<10
          b.pokemon.hyper_mode = false
          b.pokemon.adjustHeart(-50)
          pbDisplay(_INTL("{1} came to its senses!",b.pbThis))
        else
          pbDisplay(_INTL("{1} is in Hyper Mode!",b.pbThis))
        end
      end
      # Uproar
      if b.effects[PBEffects::Uproar]>0
        b.effects[PBEffects::Uproar] -= 1
        if b.effects[PBEffects::Uproar]==0
          pbDisplay(_INTL("{1} calmed down.",b.pbThis))
        else
          pbDisplay(_INTL("{1} is making an uproar!",b.pbThis))
        end
      end
      # Slow Start's end message
      if b.effects[PBEffects::SlowStart]>0
        b.effects[PBEffects::SlowStart] -= 1
        if b.effects[PBEffects::SlowStart]==0
          pbDisplay(_INTL("{1} finally got its act together!",b.pbThis))
        end
      end
      # Bad Dreams, Moody, Speed Boost
      BattleHandlers.triggerEOREffectAbility(b.ability,b,self) if b.abilityActive?
      # Flame Orb, Sticky Barb, Toxic Orb
      BattleHandlers.triggerEOREffectItem(b.item,b,self) if b.itemActive?
      # Harvest, Pickup
      BattleHandlers.triggerEORGainItemAbility(b.ability,b,self) if b.abilityActive?
    end
    pbGainExp
    return if @decision>0
    # Form checks
    priority.each { |b| b.pbCheckForm(true) }
    # Switch Pokémon in if possible
    pbEORSwitch
    return if @decision>0
    # In battles with at least one side of size 3+, move battlers around if none
    # are near to any foes
    pbEORShiftDistantBattlers
    # Try to make Trace work, check for end of primordial weather
    priority.each { |b| b.pbContinualAbilityChecks }
    # Reset/count down battler-specific effects (no messages)
    eachBattler do |b|
      b.effects[PBEffects::BanefulBunker]    = false
      b.effects[PBEffects::Charge]           -= 1 if b.effects[PBEffects::Charge]>0
      b.effects[PBEffects::Counter]          = -1
      b.effects[PBEffects::CounterTarget]    = -1
      b.effects[PBEffects::Electrify]        = false
      b.effects[PBEffects::Endure]           = false
      b.effects[PBEffects::FirstPledge]      = 0
      b.effects[PBEffects::Flinch]           = false
      b.effects[PBEffects::FocusPunch]       = false
      b.effects[PBEffects::FollowMe]         = 0
      b.effects[PBEffects::HelpingHand]      = false
      b.effects[PBEffects::HyperBeam]        -= 1 if b.effects[PBEffects::HyperBeam]>0
      b.effects[PBEffects::KingsShield]      = false
      b.effects[PBEffects::LaserFocus]       -= 1 if b.effects[PBEffects::LaserFocus]>0
      if b.effects[PBEffects::LockOn]>0   # Also Mind Reader
        b.effects[PBEffects::LockOn]         -= 1
        b.effects[PBEffects::LockOnPos]      = -1 if b.effects[PBEffects::LockOn]==0
      end
      b.effects[PBEffects::MagicBounce]      = false
      b.effects[PBEffects::MagicCoat]        = false
      b.effects[PBEffects::MirrorCoat]       = -1
      b.effects[PBEffects::MirrorCoatTarget] = -1
      b.effects[PBEffects::Powder]           = false
      b.effects[PBEffects::Prankster]        = false
      b.effects[PBEffects::PriorityAbility]  = false
      b.effects[PBEffects::PriorityItem]     = false
      b.effects[PBEffects::Protect]          = false
      b.effects[PBEffects::RagePowder]       = false
      b.effects[PBEffects::Roost]            = false
      b.effects[PBEffects::Snatch]           = 0
      b.effects[PBEffects::SpikyShield]      = false
      b.effects[PBEffects::Spotlight]        = 0
      b.effects[PBEffects::ThroatChop]       -= 1 if b.effects[PBEffects::ThroatChop]>0
	  b.effects[PBEffects::Assist]			 = false
      b.lastHPLost                           = 0
      b.lastHPLostFromFoe                    = 0
      b.tookDamage                           = false
      b.tookPhysicalHit                      = false
      b.lastRoundMoveFailed                  = b.lastMoveFailed
      b.lastAttacker.clear
      b.lastFoeAttacker.clear
    end
    # Reset/count down side-specific effects (no messages)
    for side in 0...2
      @sides[side].effects[PBEffects::CraftyShield]         = false
      if !@sides[side].effects[PBEffects::EchoedVoiceUsed]
        @sides[side].effects[PBEffects::EchoedVoiceCounter] = 0
      end
      @sides[side].effects[PBEffects::EchoedVoiceUsed]      = false
      @sides[side].effects[PBEffects::MatBlock]             = false
      @sides[side].effects[PBEffects::QuickGuard]           = false
      @sides[side].effects[PBEffects::Round]                = false
      @sides[side].effects[PBEffects::WideGuard]            = false
    end
    # Reset/count down field-specific effects (no messages)
    @field.effects[PBEffects::IonDeluge]   = false
    @field.effects[PBEffects::FairyLock]   -= 1 if @field.effects[PBEffects::FairyLock]>0
    @field.effects[PBEffects::FusionBolt]  = false
    @field.effects[PBEffects::FusionFlare] = false
    @endOfRound = false
  end

  # Called when a Pokémon switches in (entry effects, entry hazards).
  def pbOnActiveOne(battler)
    return false if battler.fainted?
    # Introduce Shadow Pokémon
    if battler.opposes? && battler.shadowPokemon?
      pbCommonAnimation("Shadow",battler)
      pbDisplay(_INTL("Oh!\nA Shadow Pokémon!"))
    end
    # Record money-doubling effect of Amulet Coin/Luck Incense
    if !battler.opposes? && [:AMULETCOIN, :LUCKINCENSE].include?(battler.item_id)
      @field.effects[PBEffects::AmuletCoin] = true
    end
	# Record money-doubling effect of Fortune ability
    if !battler.opposes? && battler.hasActiveAbility?(:FORTUNE)
      @field.effects[PBEffects::Fortune] = true
    end
    # Update battlers' participants (who will gain Exp/EVs when a battler faints)
    eachBattler { |b| b.pbUpdateParticipants }
    # Healing Wish
    if @positions[battler.index].effects[PBEffects::HealingWish]
      pbCommonAnimation("HealingWish",battler)
      pbDisplay(_INTL("The healing wish came true for {1}!",battler.pbThis(true)))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      @positions[battler.index].effects[PBEffects::HealingWish] = false
    end
    # Lunar Dance
    if @positions[battler.index].effects[PBEffects::LunarDance]
      pbCommonAnimation("LunarDance",battler)
      pbDisplay(_INTL("{1} became cloaked in mystical moonlight!",battler.pbThis))
      battler.pbRecoverHP(battler.totalhp)
      battler.pbCureStatus(false)
      battler.eachMove { |m| m.pp = m.total_pp }
      @positions[battler.index].effects[PBEffects::LunarDance] = false
    end
    # Entry hazards
    # Stealth Rock
    if battler.pbOwnSide.effects[PBEffects::StealthRock] && battler.takesIndirectDamage? &&
       GameData::Type.exists?(:ROCK)
      bTypes = battler.pbTypes(true)
      eff = Effectiveness.calculate(:ROCK, bTypes[0], bTypes[1], bTypes[2])
      if !Effectiveness.ineffective?(eff)
        eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
        oldHP = battler.hp
        battler.pbReduceHP(battler.totalhp*eff/8,false)
        pbDisplay(_INTL("Pointed stones dug into {1}!",battler.pbThis))
        battler.pbItemHPHealCheck
        if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
          return pbOnActiveOne(battler)   # For replacement battler
        end
      end
    end
    # Spikes
    if battler.pbOwnSide.effects[PBEffects::Spikes]>0 && battler.takesIndirectDamage? &&
       !battler.airborne?
      spikesDiv = [8,6,4][battler.pbOwnSide.effects[PBEffects::Spikes]-1]
      oldHP = battler.hp
      battler.pbReduceHP(battler.totalhp/spikesDiv,false)
      pbDisplay(_INTL("{1} is hurt by the spikes!",battler.pbThis))
      battler.pbItemHPHealCheck
      if battler.pbAbilitiesOnDamageTaken(oldHP)   # Switched out
        return pbOnActiveOne(battler)   # For replacement battler
      end
    end
    # Toxic Spikes
    if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]>0 && !battler.fainted? &&
       !battler.airborne?
      if battler.pbHasType?(:POISON)
        battler.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
        pbDisplay(_INTL("{1} absorbed the poison spikes!",battler.pbThis))
      elsif battler.pbCanPoison?(nil,false)
        if battler.pbOwnSide.effects[PBEffects::ToxicSpikes]==2
          battler.pbPoison(nil,_INTL("{1} was toxified by the poison spikes!",battler.pbThis),true)
        else
          battler.pbPoison(nil,_INTL("{1} was poisoned by the poison spikes!",battler.pbThis))
        end
      end
    end
    # Sticky Web
    if battler.pbOwnSide.effects[PBEffects::StickyWeb] && !battler.fainted? &&
       !battler.airborne?
      pbDisplay(_INTL("{1} was caught in a sticky web!",battler.pbThis))
      if battler.pbCanLowerStatStage?(:SPEED)
        battler.pbLowerStatStage(:SPEED,1,nil)
        battler.pbItemStatRestoreCheck
      end
    end
	# Proudfire
    if battler.battle.turnCount > 0
      battler.battle.eachOtherSideBattler(battler.index) do |enemy|
		  if enemy.abilityActive?
			BattleHandlers.triggerAbilityOnEnemySwitchIn(enemy.ability,battler,enemy,battler.battle)
		  end
	  end
    end
    # Battler faints if it is knocked out because of an entry hazard above
    if battler.fainted?
      battler.pbFaint
      pbGainExp
      pbJudge
      return false
    end
    battler.pbCheckForm
    return true
  end
  
  #=============================================================================
  # Attack phase
  #=============================================================================
  def pbAttackPhase
    @scene.pbBeginAttackPhase
    # Reset certain effects
    @battlers.each_with_index do |b,i|
      next if !b
      b.turnCount += 1 if !b.fainted?
      @successStates[i].clear
      if @choices[i][0]!=:UseMove && @choices[i][0]!=:Shift && @choices[i][0]!=:SwitchOut
        b.effects[PBEffects::DestinyBond] = false
        b.effects[PBEffects::Grudge]      = false
      end
      b.effects[PBEffects::Rage] = false if !pbChoseMoveFunctionCode?(i,"093")   # Rage
	  b.effects[PBEffects::Enlightened] = false if !pbChoseMoveFunctionCode?(i,"515")   # Rage
    end
    PBDebug.log("")
    # Calculate move order for this round
    pbCalculatePriority(true)
    # Perform actions
    pbAttackPhasePriorityChangeMessages
    pbAttackPhaseCall
    pbAttackPhaseSwitch
    return if @decision>0
    pbAttackPhaseItems
    return if @decision>0
    pbAttackPhaseMegaEvolution
    pbAttackPhaseMoves
  end


	def pbEndOfBattle
		oldDecision = @decision
		@decision = 4 if @decision==1 && wildBattle? && @caughtPokemon.length>0
		case oldDecision
		##### WIN #####
		when 1
		  PBDebug.log("")
		  PBDebug.log("***Player won***")
		  if trainerBattle?
			@scene.pbTrainerBattleSuccess
			case @opponent.length
			when 1
			  pbDisplayPaused(_INTL("You defeated {1}!",@opponent[0].full_name))
			when 2
			  pbDisplayPaused(_INTL("You defeated {1} and {2}!",@opponent[0].full_name,
				 @opponent[1].full_name))
			when 3
			  pbDisplayPaused(_INTL("You defeated {1}, {2} and {3}!",@opponent[0].full_name,
				 @opponent[1].full_name,@opponent[2].full_name))
			end
			@opponent.each_with_index do |_t,i|
			  @scene.pbShowOpponent(i)
			  msg = (@endSpeeches[i] && @endSpeeches[i]!="") ? @endSpeeches[i] : "..."
			  pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
			end
		  end
		  # Gain money from winning a trainer battle, and from Pay Day
		  pbGainMoney if @decision!=4
		  # Hide remaining trainer
		  @scene.pbShowOpponent(@opponent.length) if trainerBattle? && @caughtPokemon.length>0
		##### LOSE, DRAW #####
		when 2, 5
		  PBDebug.log("")
		  PBDebug.log("***Player lost***") if @decision==2
		  PBDebug.log("***Player drew with opponent***") if @decision==5
		  if @internalBattle
			if trainerBattle?
			  case @opponent.length
			  when 1
				pbDisplayPaused(_INTL("You lost against {1}!",@opponent[0].full_name))
			  when 2
				pbDisplayPaused(_INTL("You lost against {1} and {2}!",
				   @opponent[0].full_name,@opponent[1].full_name))
			  when 3
				pbDisplayPaused(_INTL("You lost against {1}, {2} and {3}!",
				   @opponent[0].full_name,@opponent[1].full_name,@opponent[2].full_name))
			  end
			end
		  elsif @decision==2
			if @opponent
			  @opponent.each_with_index do |_t,i|
				@scene.pbShowOpponent(i)
				msg = (@endSpeechesWin[i] && @endSpeechesWin[i]!="") ? @endSpeechesWin[i] : "..."
				pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
			  end
			end
		  end
		##### CAUGHT WILD POKÉMON #####
		when 4
		  @scene.pbWildBattleSuccess if !Settings::GAIN_EXP_FOR_CAPTURE
		end
		# Register captured Pokémon in the Pokédex, and store them
		pbRecordAndStoreCaughtPokemon
		# Collect Pay Day money in a wild battle that ended in a capture
		pbGainMoney if @decision==4
		# Pass on Pokérus within the party
		if @internalBattle
		  infected = []
		  $Trainer.party.each_with_index do |pkmn,i|
			infected.push(i) if pkmn.pokerusStage==1
		  end
		  infected.each do |idxParty|
			strain = $Trainer.party[idxParty].pokerusStrain
			if idxParty>0 && $Trainer.party[idxParty-1].pokerusStage==0
			  $Trainer.party[idxParty-1].givePokerus(strain) if rand(3)==0   # 33%
			end
			if idxParty<$Trainer.party.length-1 && $Trainer.party[idxParty+1].pokerusStage==0
			  $Trainer.party[idxParty+1].givePokerus(strain) if rand(3)==0   # 33%
			end
		  end
		end
		# Clean up battle stuff
		@scene.pbEndBattle(@decision)
		@battlers.each do |b|
		  next if !b
		  pbCancelChoice(b.index)   # Restore unused items to Bag
		  BattleHandlers.triggerAbilityOnSwitchOut(b.ability,b,true) if b.abilityActive?
		end
		pbParty(0).each_with_index do |pkmn,i|
		  next if !pkmn
		  @peer.pbOnLeavingBattle(self,pkmn,@usedInBattle[0][i],true)   # Reset form
		  pkmn.item = @initialItems[0][i]
		end
		return @decision
	end
	
	# Check whether the currently active Pokémon (at battler index idxBattler) can
  # switch out (and that its replacement at party index idxParty can switch in).
  # NOTE: Messages are only shown while in the party screen when choosing a
  #       command for the next round.
  def pbCanSwitch?(idxBattler,idxParty=-1,partyScene=nil)
    # Check whether party Pokémon can switch in
    return false if !pbCanSwitchLax?(idxBattler,idxParty,partyScene)
    # Make sure another battler isn't already choosing to switch to the party
    # Pokémon
    eachSameSideBattler(idxBattler) do |b|
      next if choices[b.index][0]!=:SwitchOut || choices[b.index][1]!=idxParty
      partyScene.pbDisplay(_INTL("{1} has already been selected.",
         pbParty(idxBattler)[idxParty].name)) if partyScene
      return false
    end
    # Check whether battler can switch out
    battler = @battlers[idxBattler]
    return true if battler.fainted?
    # Ability/item effects that allow switching no matter what
    if battler.abilityActive?
      if BattleHandlers.triggerCertainSwitchingUserAbility(battler.ability,battler,self)
        return true
      end
    end
    if battler.itemActive?
      if BattleHandlers.triggerCertainSwitchingUserItem(battler.item,battler,self)
        return true
      end
    end
    #return true if Settings::MORE_TYPE_EFFECTS && battler.pbHasType?(:GHOST)
	
	# Other certain switching effects
    if battler.effects[PBEffects::OctolockUser]>=0
      partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
      return false
    end
    if battler.effects[PBEffects::Trapping]>0 ||
       battler.effects[PBEffects::MeanLook]>=0 ||
       battler.effects[PBEffects::Ingrain] ||
       @field.effects[PBEffects::FairyLock]>0
      partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
      return false
    end
    # Trapping abilities/items
    eachOtherSideBattler(idxBattler) do |b|
      next if !b.abilityActive?
      if BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
        partyScene.pbDisplay(_INTL("{1}'s {2} prevents switching!",
           b.pbThis,b.abilityName)) if partyScene
        return false
      end
    end
    eachOtherSideBattler(idxBattler) do |b|
      next if !b.itemActive?
      if BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
        partyScene.pbDisplay(_INTL("{1}'s {2} prevents switching!",
           b.pbThis,b.itemName)) if partyScene
        return false
      end
    end
    return true
  end

	
	#=============================================================================
  # Running from battle
  #=============================================================================
  def pbCanRun?(idxBattler)
    return false if trainerBattle? || $game_variables[95] # Boss battle
    battler = @battlers[idxBattler]
    return false if !@canRun && !battler.opposes?
    #return true if battler.pbHasType?(:GHOST) && Settings::MORE_TYPE_EFFECTS
    return true if battler.abilityActive? &&
                   BattleHandlers.triggerRunFromBattleAbility(battler.ability,battler)
    return true if battler.itemActive? &&
                   BattleHandlers.triggerRunFromBattleItem(battler.item,battler)
    return false if battler.effects[PBEffects::Trapping]>0 ||
                    battler.effects[PBEffects::MeanLook]>=0 ||
                    battler.effects[PBEffects::Ingrain] ||
                    battler.effects[PBEffects::JawLock] ||
                    battler.effects[PBEffects::OctolockUser]>=0 ||
                    battler.effects[PBEffects::NoRetreat] ||
                    @field.effects[PBEffects::FairyLock]>0
    eachOtherSideBattler(idxBattler) do |b|
      return false if b.abilityActive? &&
                      BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
      return false if b.itemActive? &&
                      BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
    end
    return true
  end
	
	# Return values:
  # -1: Failed fleeing
  #  0: Wasn't possible to attempt fleeing, continue choosing action for the round
  #  1: Succeeded at fleeing, battle will end
  # duringBattle is true for replacing a fainted Pokémon during the End Of Round
  # phase, and false for choosing the Run command.
  def pbRun(idxBattler,duringBattle=false)
    battler = @battlers[idxBattler]
    if battler.opposes?
      return 0 if trainerBattle?
      @choices[idxBattler][0] = :Run
      @choices[idxBattler][1] = 0
      @choices[idxBattler][2] = nil
      return -1
    end
    # Fleeing from trainer battles or boss battles
    if trainerBattle? || $game_switches[95]
      if $DEBUG && Input.press?(Input::CTRL)
        if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
          @decision = 1
          return 1
        elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
          @decision = 2
          return 1
        end
      elsif pbDisplayConfirm(_INTL("Would you like to forfeit the match and quit now?"))
        pbSEPlay("Battle flee")
        if @internalBattle
          @decision = 2
        else
          @decision = 3
        end
        return 1
      end
      return 0
    end
    # Fleeing from wild battles
    if $DEBUG && Input.press?(Input::CTRL)
      pbSEPlay("Battle flee")
      pbDisplayPaused(_INTL("You got away safely!"))
      @decision = 3
      return 1
    end
    if !@canRun
      pbDisplayPaused(_INTL("You can't escape!"))
      return 0
    end
    if !duringBattle
=begin
      if battler.pbHasType?(:GHOST) && Settings::MORE_TYPE_EFFECTS
        pbSEPlay("Battle flee")
        pbDisplayPaused(_INTL("Your Pokémon uses its ghostly powers to escape!"))
        @decision = 3
        return 1
      end
=end
      # Abilities that guarantee escape
      if battler.abilityActive?
        if BattleHandlers.triggerRunFromBattleAbility(battler.ability,battler)
          pbShowAbilitySplash(battler,true)
          pbHideAbilitySplash(battler)
          pbSEPlay("Battle flee")
          pbDisplayPaused(_INTL("You got away safely!"))
          @decision = 3
          return 1
        end
      end
      # Held items that guarantee escape
      if battler.itemActive?
        if BattleHandlers.triggerRunFromBattleItem(battler.item,battler)
          pbSEPlay("Battle flee")
          pbDisplayPaused(_INTL("{1} fled using its {2}!",
             battler.pbThis,battler.itemName))
          @decision = 3
          return 1
        end
      end
	  if battler.effects[PBEffects::JawLock]
		  @battlers.each do |b|
			if (battler.effects[PBEffects::JawLockUser] == b.index) && !b.fainted?
			  partyScene.pbDisplay(_INTL("{1} can't be switched out!",battler.pbThis)) if partyScene
			  return false
			end
		  end
      end
      # Other certain trapping effects
      if battler.effects[PBEffects::Trapping]>0 ||
         battler.effects[PBEffects::MeanLook]>=0 ||
         battler.effects[PBEffects::Ingrain] ||
         @field.effects[PBEffects::FairyLock]>0
        pbDisplayPaused(_INTL("You can't escape!"))
        return 0
      end
      # Trapping abilities/items
      eachOtherSideBattler(idxBattler) do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerTrappingTargetAbility(b.ability,battler,b,self)
          pbDisplayPaused(_INTL("{1} prevents escape with {2}!",b.pbThis,b.abilityName))
          return 0
        end
      end
      eachOtherSideBattler(idxBattler) do |b|
        next if !b.itemActive?
        if BattleHandlers.triggerTrappingTargetItem(b.item,battler,b,self)
          pbDisplayPaused(_INTL("{1} prevents escape with {2}!",b.pbThis,b.itemName))
          return 0
        end
      end
    end

	levelPlayer = 1
    if levelPlayer<@battlers[idxBattler].level
      levelPlayer = @battlers[idxBattler].level
    end
    @battlers[idxBattler].eachAlly do |a|
     levelPlayer = a.level if levelPlayer<a.level
    end

    levelEnemy = 1
    eachOtherSideBattler(idxBattler) do |b|
      levelEnemy = b.level if levelEnemy<b.level
    end

    rate = 90
    rate += 10 * [levelPlayer-levelEnemy,0].max
    rate += @runCommand*20
        
    if rate>=250 || @battleAI.pbAIRandom(250)<rate
      pbSEPlay("Battle flee")
      case rate
      when 0..130; pbDisplayPaused(_INTL("Miraculously, you found a way out!"))
      when 131..170; pbDisplayPaused(_INTL("It was hard work, but you managed to escape!"))
      when 171..210; pbDisplayPaused(_INTL("With a bit of luck you made your retreat!"))
      when 211..250; pbDisplayPaused(_INTL("You got away safely!"))
      when 251..10000; pbDisplayPaused(_INTL("You fled easily!"))
      end
      @decision = 3
      return 1
    end
    case rate
    when 0..130; pbDisplayPaused(_INTL("You're locked in place by fear!"))
    when 131..170; pbDisplayPaused(_INTL("You don't see a way out!"))
    when 171..210; pbDisplayPaused(_INTL("You couldn't get away!"))
    when 211..250; pbDisplayPaused(_INTL("The wild Pokémon narrowly blocks your escape!"))
    end
    return -1
  end
  
  
  #=============================================================================
  # Messages and animations
  #=============================================================================
  def pbDisplay(msg,&block)
    @scene.pbDisplayMessage(msg,&block) if !messagesBlocked
  end

  def pbDisplayBrief(msg)
    @scene.pbDisplayMessage(msg,true) if !messagesBlocked
  end

  def pbDisplayPaused(msg,&block)
    @scene.pbDisplayPausedMessage(msg,&block) if !messagesBlocked
  end

  def pbDisplayConfirm(msg)
    return @scene.pbDisplayConfirmMessage(msg) if !messagesBlocked
  end
  
  def pbCanMegaEvolve?(idxBattler)
    return false if $game_switches[Settings::NO_MEGA_EVOLUTION]
    return false if !@battlers[idxBattler].hasMega?
    return false if wildBattle? && opposes?(idxBattler) && !@battlers[idxBattler].boss
    return true if $DEBUG && Input.press?(Input::CTRL)
    return false if @battlers[idxBattler].effects[PBEffects::SkyDrop]>=0
    return false if !pbHasMegaRing?(idxBattler) && !@battlers[idxBattler].boss
    side  = @battlers[idxBattler].idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    return @megaEvolution[side][owner]==-1
  end
end

class PokeBattle_Move

	# Checks whether the move should have modified priority
	def priorityModification(user,target); return 0; end

# Returns whether the move will be a critical hit.
  def pbIsCritical?(user,target)
    return false if target.pbOwnSide.effects[PBEffects::LuckyChant]>0
    # Set up the critical hit ratios
    ratios = [16,8,4,2,1]
    c = 0
    # Ability effects that alter critical hit rate
    if c>=0 && user.abilityActive?
      c = BattleHandlers.triggerCriticalCalcUserAbility(user.ability,user,target,c)
    end
    if c>=0 && target.abilityActive? && !@battle.moldBreaker
      c = BattleHandlers.triggerCriticalCalcTargetAbility(target.ability,user,target,c)
    end
    # Item effects that alter critical hit rate
    if c>=0 && user.itemActive?
      c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
    end
    if c>=0 && target.itemActive?
      c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
    end
    return false if c<0
    # Move-specific "always/never a critical hit" effects
    case pbCritialOverride(user,target)
    when 1  then return true
    when -1 then return false
    end
    # Other effects
    return true if c>50   # Merciless
    return true if user.effects[PBEffects::LaserFocus]>0
    c += 1 if highCriticalRate?
    c += user.effects[PBEffects::FocusEnergy]
	c += 1 if user.effects[PBEffects::LuckyStar]
    c += 1 if user.inHyperMode? && @type == :SHADOW
    c = ratios.length-1 if c>=ratios.length
    # Calculation
    return @battle.pbRandom(ratios[c])==0
  end
  
  #=============================================================================
  # Additional effect chance
  #=============================================================================
  def pbAdditionalEffectChance(user,target,effectChance=0)
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
	return 0 if target.effects[PBEffects::Enlightened]
    ret = (effectChance>0) ? effectChance : @addlEffect
    if Settings::MECHANICS_GENERATION >= 6 || @function != "0A4"   # Secret Power
      ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                  user.pbOwnSide.effects[PBEffects::Rainbow]>0
    end
    ret = 100 if $DEBUG && Input.press?(Input::CTRL)
    return ret
  end
  
  # NOTE: Flinching caused by a move's effect is applied in that move's code,
  #       not here.
  def pbFlinchChance(user,target)
    return 0 if flinchingMove?
    return 0 if target.hasActiveAbility?(:SHIELDDUST) && !@battle.moldBreaker
	return 0 if target.effects[PBEffects::Enlightened]
    ret = 0
    if user.hasActiveAbility?(:STENCH,true)
      ret = 10
    elsif user.hasActiveItem?([:KINGSROCK,:RAZORFANG],true)
      ret = 10
    end
    ret *= 2 if user.hasActiveAbility?(:SERENEGRACE) ||
                user.pbOwnSide.effects[PBEffects::Rainbow]>0
    return ret
  end
  
  def pbCalcDamage(user,target,numTargets=1)
    return if statusMove?
    if target.damageState.disguise
      target.damageState.calcDamage = 1
      return
    end
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    # Get the move's type
    type = @calcType   # nil is treated as physical
    # Calculate whether this hit deals critical damage
    target.damageState.critical = pbIsCritical?(user,target)
    # Calcuate base power of move
    baseDmg = pbBaseDamage(@baseDamage,user,target)
    # Calculate user's attack stat
    atk, atkStage = pbGetAttackStats(user,target)
    if !target.hasActiveAbility?(:UNAWARE) || @battle.moldBreaker
      atkStage = 6 if target.damageState.critical && atkStage<6
	  calc = stageMul[atkStage].to_f/stageDiv[atkStage].to_f
	  calc = (calc.to_f + 1.0)/2.0 if user.boss
      atk = (atk.to_f*calc).floor
    end
    # Calculate target's defense stat
    defense, defStage = pbGetDefenseStats(user,target)
    if !user.hasActiveAbility?(:UNAWARE)
      defStage = 6 if target.damageState.critical && defStage>6
	  calc = stageMul[defStage].to_f/stageDiv[defStage].to_f
	  calc = (calc.to_f + 1.0)/2.0 if target.boss
      defense = (defense.to_f*calc).floor
    end
    # Calculate all multiplier effects
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Main damage calculation
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
    target.damageState.calcDamage = damage
  end

  
    def pbCalcDamageMultipliers(user,target,numTargets,type,baseDmg,multipliers)
    # Global abilities
    if (@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
       (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY)
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 2 / 3.0
      else
        multipliers[:base_damage_multiplier] *= 4 / 3.0
      end
    end
    # Ability effects that alter damage
    if user.abilityActive?
      BattleHandlers.triggerDamageCalcUserAbility(user.ability,
         user,target,self,multipliers,baseDmg,type)
    end
    if !@battle.moldBreaker
      # NOTE: It's odd that the user's Mold Breaker prevents its partner's
      #       beneficial abilities (i.e. Flower Gift boosting Atk), but that's
      #       how it works.
      user.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcUserAllyAbility(b.ability,
           user,target,self,multipliers,baseDmg,type)
      end
      if target.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAbility(target.ability,
           user,target,self,multipliers,baseDmg,type) if !@battle.moldBreaker
        BattleHandlers.triggerDamageCalcTargetAbilityNonIgnorable(target.ability,
           user,target,self,multipliers,baseDmg,type)
      end
      target.eachAlly do |b|
        next if !b.abilityActive?
        BattleHandlers.triggerDamageCalcTargetAllyAbility(b.ability,
           user,target,self,multipliers,baseDmg,type)
      end
    end
    # Item effects that alter damage
    if user.itemActive?
      BattleHandlers.triggerDamageCalcUserItem(user.item,
         user,target,self,multipliers,baseDmg,type)
    end
    if target.itemActive?
      BattleHandlers.triggerDamageCalcTargetItem(target.item,
         user,target,self,multipliers,baseDmg,type)
    end
    # Parental Bond's second attack
    if user.effects[PBEffects::ParentalBond]==1
      multipliers[:base_damage_multiplier] /= 4
    end
    # Other
    if user.effects[PBEffects::MeFirst]
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if user.effects[PBEffects::HelpingHand] && !self.is_a?(PokeBattle_Confusion)
      multipliers[:base_damage_multiplier] *= 1.5
    end
    if user.effects[PBEffects::Charge]>0 && type == :ELECTRIC
      multipliers[:base_damage_multiplier] *= 2
    end
    # Mud Sport
    if type == :ELECTRIC
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::MudSport]
        multipliers[:base_damage_multiplier] /= 3
        break
      end
      if @battle.field.effects[PBEffects::MudSportField]>0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # Water Sport
    if type == :FIRE
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::WaterSport]
        multipliers[:base_damage_multiplier] /= 3
        break
      end
      if @battle.field.effects[PBEffects::WaterSportField]>0
        multipliers[:base_damage_multiplier] /= 3
      end
    end
    # Terrain moves
    case @battle.field.terrain
    when :Electric
      multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC && user.affectedByTerrain?
    when :Grassy
      multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS && user.affectedByTerrain?
    when :Psychic
      multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC && user.affectedByTerrain?
    when :Misty
      multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
    end
    # Multi-targeting attacks
    if numTargets>1
      multipliers[:final_damage_multiplier] *= 0.75
    end
    # Weather
    case @battle.pbWeather
    when :Sun, :HarshSun
      if type == :FIRE
        multipliers[:final_damage_multiplier] *= 1.5
      elsif type == :WATER
        multipliers[:final_damage_multiplier] /= 2
      end
    when :Rain, :HeavyRain
      if type == :FIRE
        multipliers[:final_damage_multiplier] /= 2
      elsif type == :WATER
        multipliers[:final_damage_multiplier] *= 1.5
      end
    when :Sandstorm
      if (target.pbHasType?(:ROCK) || target.pbHasType?(:GROUND)) && specialMove? && @function != "122"   # Psyshock
        multipliers[:defense_multiplier] *= 1.5
      end
	when :Hail
      if target.pbHasType?(:ICE) && physicalMove?
        multipliers[:defense_multiplier] *= 1.5
      end
    end
    # Critical hits
    if target.damageState.critical
      if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
        multipliers[:final_damage_multiplier] *= 1.5
      else
        multipliers[:final_damage_multiplier] *= 2
      end
    end
    # STAB
    if type && user.pbHasType?(type)
      if user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
    # Type effectiveness
	typeEffect = target.damageState.typeMod.to_f / Effectiveness::NORMAL_EFFECTIVE
	typeEffect = ((typeEffect+1.0)/2.0) if target.boss || user.boss
	multipliers[:final_damage_multiplier] *= typeEffect
    # Burn
    if user.status == :BURN && physicalMove? && damageReducedByBurn? &&
       !user.hasActiveAbility?(:GUTS)
      multipliers[:final_damage_multiplier] *= 2.0/3.0
    end
	# Poison
    if user.status == :POISON && user.statusCount == 0 && specialMove? && damageReducedByBurn? &&
       !user.hasActiveAbility?(:AUDACITY)
      multipliers[:final_damage_multiplier] *= 2.0/3.0
    end
	# Chill
    if target.status == :FROZEN
      multipliers[:final_damage_multiplier] *= 4.0/3.0
    end
    # Aurora Veil, Reflect, Light Screen
    if !ignoresReflect? && !target.damageState.critical &&
       !user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target)>1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && physicalMove?
        if @battle.pbSideBattlerCount(target)>1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && specialMove?
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end
    # Minimize
    if target.effects[PBEffects::Minimize] && tramplesMinimize?(2)
      multipliers[:final_damage_multiplier] *= 2
    end
    # Move-specific base damage modifiers
    multipliers[:base_damage_multiplier] = pbBaseDamageMultiplier(multipliers[:base_damage_multiplier], user, target)
    # Move-specific final damage modifiers
    multipliers[:final_damage_multiplier] = pbModifyDamage(multipliers[:final_damage_multiplier], user, target)
  end
  
  #=============================================================================
  # Type effectiveness calculation
  #=============================================================================
  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = Effectiveness.calculate_one(moveType, defType)
    # Ring Target
    if target.hasActiveItem?(:RINGTARGET)
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if Effectiveness.ineffective_type?(moveType, defType)
    end
    # Foresight
    if user.hasActiveAbility?(:SCRAPPY) || target.effects[PBEffects::Foresight]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :GHOST &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
    # Miracle Eye
    if target.effects[PBEffects::MiracleEye]
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :DARK &&
                                                   Effectiveness.ineffective_type?(moveType, defType)
    end
	#Creep Out
	if target.effects[PBEffects::CreepOut]
		ret *= 2 if moveType == :BUG
	end
    # Delta Stream's weather
    if @battle.pbWeather == :StrongWinds
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING &&
                                                   Effectiveness.super_effective_type?(moveType, defType)
    end
    # Grounded Flying-type Pokémon become susceptible to Ground moves
    if !target.airborne?
      ret = Effectiveness::NORMAL_EFFECTIVE_ONE if defType == :FLYING && moveType == :GROUND
    end
	
	# Inured
	if target.effects[PBEffects::Inured]
		ret /= 2 if Effectiveness.super_effective_type?(moveType, defType)
	end
	
	# Tar Shot
	if target.effects[PBEffects::TarShot] && moveType == :FIRE
      ret = PBTypeEffectiveness::SUPER_EFFECTIVE_ONE if Effectiveness.normal_type?(moveType,target.type1,target.type2)
      ret = PBTypeEffectiveness::NORMAL_EFFECTIVE_ONE if Effectiveness.not_very_effective_type?(moveType,target.type1,target.type2)
    end
	
	# Bosses
	if user.boss || target.boss
		ret = Effectiveness::NOT_VERY_EFFECTIVE_ONE if Effectiveness.ineffective_type?(moveType, defType)
	end
	
    return ret
  end
  
  # Accuracy calculations for one-hit KO moves and "always hit" moves are
  # handled elsewhere.
  def pbAccuracyCheck(user,target)
    # "Always hit" effects and "always hit" accuracy
    return true if target.effects[PBEffects::Telekinesis]>0
    return true if target.effects[PBEffects::Minimize] && tramplesMinimize?(1)
    baseAcc = pbBaseAccuracy(user,target)
    return true if baseAcc==0
    # Calculate all multiplier effects
    modifiers = {}
    modifiers[:base_accuracy]  = baseAcc
    modifiers[:accuracy_stage] = user.stages[:ACCURACY]
    modifiers[:evasion_stage]  = target.stages[:EVASION]
    modifiers[:accuracy_multiplier] = 1.0
    modifiers[:evasion_multiplier]  = 1.0
    pbCalcAccuracyModifiers(user,target,modifiers)
    # Check if move can't miss
    return true if modifiers[:base_accuracy] == 0
    # Calculation
    accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
    evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
    stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
    stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
    accuracy = 100.0 * stageMul[accStage].to_f / stageDiv[accStage].to_f
    evasion  = 100.0 * stageMul[evaStage].to_f / stageDiv[evaStage].to_f
    accuracy = (accuracy.to_f * modifiers[:accuracy_multiplier].to_f).round
    evasion  = (evasion.to_f  * modifiers[:evasion_multiplier].to_f).round
    evasion = 1 if evasion < 1
    # Calculation
	calc = accuracy.to_f / evasion.to_f
    if user.boss || target.boss
      calc = (calc.to_f + 1.0) / 2.0
    end
    return @battle.pbRandom(100) < modifiers[:base_accuracy] * calc
  end
end

class PokeBattle_Battle
	#=============================================================================
  # Mega Evolving a battler
  #=============================================================================
  def pbMegaEvolve(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasMega? || battler.mega?
    # Break Illusion
    if battler.hasActiveAbility?(:ILLUSION)
      BattleHandlers.triggerTargetAbilityOnHit(battler.ability,nil,battler,nil,self)
    end
    # Mega Evolve
	if !battler.boss
		trainerName = pbGetOwnerName(idxBattler)
		case battler.pokemon.megaMessage
		when 1   # Rayquaza
		  pbDisplay(_INTL("{1}'s fervent wish has reached {2}!",trainerName,battler.pbThis))
		else
		  pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s {4}!",
			 battler.pbThis,battler.itemName,trainerName,pbGetMegaRingName(idxBattler)))
		end
	else
		case battler.pokemon.megaMessage
		when 1   # Rayquaza
		  pbDisplay(_INTL("{1}'s is inspired by the echo of an ancient wish!",battler.pbThis))
		else
		  pbDisplay(_INTL("{1}'s reacts to an unknown power!",battler.pbThis))
		end
	end
    pbCommonAnimation("MegaEvolution",battler)
    battler.pokemon.makeMega
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    pbCommonAnimation("MegaEvolution2",battler)
    megaName = battler.pokemon.megaName
    if !megaName || megaName==""
      megaName = _INTL("Mega {1}", battler.pokemon.speciesName)
    end
    pbDisplay(_INTL("{1} has Mega Evolved into {2}!",battler.pbThis,megaName))
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = -2
    if battler.isSpecies?(:GENGAR) && battler.mega?
      battler.effects[PBEffects::Telekinesis] = 0
    end
    pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
    # Trigger ability
    battler.pbEffectsOnSwitchIn
  end
end


class PokeBattle_Battler

  def pbInitEffects(batonPass)
    if batonPass
      # These effects are passed on if Baton Pass is used, but they need to be
      # reapplied
      @effects[PBEffects::LaserFocus] = (@effects[PBEffects::LaserFocus]>0) ? 2 : 0
      @effects[PBEffects::LockOn]     = (@effects[PBEffects::LockOn]>0) ? 2 : 0
      if @effects[PBEffects::PowerTrick]
        @attack,@defense = @defense,@attack
      end
      # These effects are passed on if Baton Pass is used, but they need to be
      # cancelled in certain circumstances anyway
      @effects[PBEffects::Telekinesis] = 0 if isSpecies?(:GENGAR) && mega?
      @effects[PBEffects::GastroAcid]  = false if unstoppableAbility?
    else
      # These effects are not passed on if Baton Pass is used
      @stages[:ATTACK]          = 0
      @stages[:DEFENSE]         = 0
      @stages[:SPEED]           = 0
      @stages[:SPECIAL_ATTACK]  = 0
      @stages[:SPECIAL_DEFENSE] = 0
      @stages[:ACCURACY]        = 0
      @stages[:EVASION]         = 0
      @effects[PBEffects::AquaRing]          = false
      @effects[PBEffects::Confusion]         = 0
	  @effects[PBEffects::ConfusionChance]   = 0
      @effects[PBEffects::Curse]             = false
      @effects[PBEffects::Embargo]           = 0
      @effects[PBEffects::FocusEnergy]       = 0
      @effects[PBEffects::GastroAcid]        = false
      @effects[PBEffects::HealBlock]         = 0
      @effects[PBEffects::Ingrain]           = false
      @effects[PBEffects::LaserFocus]        = 0
      @effects[PBEffects::LeechSeed]         = -1
      @effects[PBEffects::LockOn]            = 0
      @effects[PBEffects::LockOnPos]         = -1
      @effects[PBEffects::MagnetRise]        = 0
      @effects[PBEffects::PerishSong]        = 0
      @effects[PBEffects::PerishSongUser]    = -1
      @effects[PBEffects::PowerTrick]        = false
      @effects[PBEffects::Substitute]        = 0
      @effects[PBEffects::Telekinesis]       = 0
	  @effects[PBEffects::JawLock]           = false
      @effects[PBEffects::JawLockUser]       = -1
	  @effects[PBEffects::NoRetreat]         = false
	  @effects[PBEffects::Charm]         = 0
	  @effects[PBEffects::CharmChance]   = 0
    end
    @fainted               = (@hp==0)
    @initialHP             = 0
    @lastAttacker          = []
    @lastFoeAttacker       = []
    @lastHPLost            = 0
    @lastHPLostFromFoe     = 0
    @tookDamage            = false
    @tookPhysicalHit       = false
    @lastMoveUsed          = nil
    @lastMoveUsedType      = nil
    @lastRegularMoveUsed   = nil
    @lastRegularMoveTarget = -1
    @lastRoundMoved        = -1
    @lastMoveFailed        = false
    @lastRoundMoveFailed   = false
    @movesUsed             = []
    @turnCount             = 0
    @effects[PBEffects::Attract]             = -1
    @battle.eachBattler do |b|   # Other battlers no longer attracted to self
      b.effects[PBEffects::Attract] = -1 if b.effects[PBEffects::Attract]==@index
    end
    @effects[PBEffects::BanefulBunker]       = false
    @effects[PBEffects::BeakBlast]           = false
    @effects[PBEffects::Bide]                = 0
    @effects[PBEffects::BideDamage]          = 0
    @effects[PBEffects::BideTarget]          = -1
    @effects[PBEffects::BurnUp]              = false
    @effects[PBEffects::Charge]              = 0
    @effects[PBEffects::ChoiceBand]          = nil
    @effects[PBEffects::Counter]             = -1
    @effects[PBEffects::CounterTarget]       = -1
    @effects[PBEffects::Dancer]              = false
    @effects[PBEffects::DefenseCurl]         = false
    @effects[PBEffects::DestinyBond]         = false
    @effects[PBEffects::DestinyBondPrevious] = false
    @effects[PBEffects::DestinyBondTarget]   = -1
    @effects[PBEffects::Disable]             = 0
    @effects[PBEffects::DisableMove]         = nil
    @effects[PBEffects::Electrify]           = false
    @effects[PBEffects::Encore]              = 0
    @effects[PBEffects::EncoreMove]          = nil
    @effects[PBEffects::Endure]              = false
    @effects[PBEffects::FirstPledge]         = 0
    @effects[PBEffects::FlashFire]           = false
    @effects[PBEffects::Flinch]              = false
    @effects[PBEffects::FocusPunch]          = false
    @effects[PBEffects::FollowMe]            = 0
    @effects[PBEffects::Foresight]           = false
    @effects[PBEffects::FuryCutter]          = 0
    @effects[PBEffects::GemConsumed]         = nil
    @effects[PBEffects::Grudge]              = false
    @effects[PBEffects::HelpingHand]         = false
    @effects[PBEffects::HyperBeam]           = 0
    @effects[PBEffects::Illusion]            = nil
    if hasActiveAbility?(:ILLUSION)
      idxLastParty = @battle.pbLastInTeam(@index)
      if idxLastParty >= 0 && idxLastParty != @pokemonIndex
        @effects[PBEffects::Illusion]        = @battle.pbParty(@index)[idxLastParty]
      end
    end
    @effects[PBEffects::Imprison]            = false
    @effects[PBEffects::Instruct]            = false
    @effects[PBEffects::Instructed]          = false
    @effects[PBEffects::KingsShield]         = false
    @battle.eachBattler do |b|   # Other battlers lose their lock-on against self
      next if b.effects[PBEffects::LockOn]==0
      next if b.effects[PBEffects::LockOnPos]!=@index
      b.effects[PBEffects::LockOn]    = 0
      b.effects[PBEffects::LockOnPos] = -1
    end
    @effects[PBEffects::MagicBounce]         = false
    @effects[PBEffects::MagicCoat]           = false
    @effects[PBEffects::MeanLook]            = -1
    @battle.eachBattler do |b|   # Other battlers no longer blocked by self
      b.effects[PBEffects::MeanLook] = -1 if b.effects[PBEffects::MeanLook]==@index
    end
    @effects[PBEffects::MeFirst]             = false
    @effects[PBEffects::Metronome]           = 0
    @effects[PBEffects::MicleBerry]          = false
    @effects[PBEffects::Minimize]            = false
    @effects[PBEffects::MiracleEye]          = false
    @effects[PBEffects::MirrorCoat]          = -1
    @effects[PBEffects::MirrorCoatTarget]    = -1
    @effects[PBEffects::MoveNext]            = false
    @effects[PBEffects::MudSport]            = false
    @effects[PBEffects::Nightmare]           = false
    @effects[PBEffects::Outrage]             = 0
    @effects[PBEffects::ParentalBond]        = 0
    @effects[PBEffects::PickupItem]          = nil
    @effects[PBEffects::PickupUse]           = 0
    @effects[PBEffects::Pinch]               = false
    @effects[PBEffects::Powder]              = false
    @effects[PBEffects::Prankster]           = false
    @effects[PBEffects::PriorityAbility]     = false
    @effects[PBEffects::PriorityItem]        = false
    @effects[PBEffects::Protect]             = false
    @effects[PBEffects::ProtectRate]         = 1
    @effects[PBEffects::Pursuit]             = false
    @effects[PBEffects::Quash]               = 0
    @effects[PBEffects::Rage]                = false
    @effects[PBEffects::RagePowder]          = false
    @effects[PBEffects::Rollout]             = 0
    @effects[PBEffects::Roost]               = false
    @effects[PBEffects::SkyDrop]             = -1
    @battle.eachBattler do |b|   # Other battlers no longer Sky Dropped by self
      b.effects[PBEffects::SkyDrop] = -1 if b.effects[PBEffects::SkyDrop]==@index
    end
    @effects[PBEffects::SlowStart]           = 0
    @effects[PBEffects::SmackDown]           = false
    @effects[PBEffects::Snatch]              = 0
    @effects[PBEffects::SpikyShield]         = false
    @effects[PBEffects::Spotlight]           = 0
    @effects[PBEffects::Stockpile]           = 0
    @effects[PBEffects::StockpileDef]        = 0
    @effects[PBEffects::StockpileSpDef]      = 0
    @effects[PBEffects::Taunt]               = 0
    @effects[PBEffects::ThroatChop]          = 0
    @effects[PBEffects::Torment]             = false
    @effects[PBEffects::Toxic]               = 0
    @effects[PBEffects::Transform]           = false
    @effects[PBEffects::TransformSpecies]    = 0
    @effects[PBEffects::Trapping]            = 0
    @effects[PBEffects::TrappingMove]        = nil
    @effects[PBEffects::TrappingUser]        = -1
    @battle.eachBattler do |b|   # Other battlers no longer trapped by self
      next if b.effects[PBEffects::TrappingUser]!=@index
      b.effects[PBEffects::Trapping]     = 0
      b.effects[PBEffects::TrappingUser] = -1
    end
	@effects[PBEffects::Octolock]     = false
    @effects[PBEffects::OctolockUser] = -1
    @battle.eachBattler do |b|   # Other battlers lose their lock-on against self - Octolock
      next if !b.effects[PBEffects::Octolock]
      next if b.effects[PBEffects::OctolockUser]!=@index
      b.effects[PBEffects::Octolock]     = false
      b.effects[PBEffects::OctolockUser] = -1
    end
    @battle.eachBattler do |b|   # Other battlers lose their lock-on against self - Jawlock
      next if !b.effects[PBEffects::JawLock]
      next if b.effects[PBEffects::JawLockUser]!=@index
      b.effects[PBEffects::Jawlock]     = false
      b.effects[PBEffects::JawLockUser] = -1
    end
    @effects[PBEffects::Truant]              = false
    @effects[PBEffects::TwoTurnAttack]       = nil
    @effects[PBEffects::Type3]               = nil
    @effects[PBEffects::Unburden]            = false
    @effects[PBEffects::Uproar]              = 0
    @effects[PBEffects::WaterSport]          = false
    @effects[PBEffects::WeightChange]        = 0
    @effects[PBEffects::Yawn]                = 0
	
	@effects[PBEffects::GorillaTactics]      = -1
    @effects[PBEffects::BallFetch]           = 0
    @effects[PBEffects::LashOut]             = false
    @effects[PBEffects::BurningJealousy]     = false
	  @effects[PBEffects::Obstruct]            = false
	  @effects[PBEffects::TarShot]             = false
	  @effects[PBEffects::BlunderPolicy]       = false
    @effects[PBEffects::SwitchedAlly]        = -1
	
	@effects[PBEffects::FlinchedAlready]     = false
	@effects[PBEffects::Enlightened]		 = false
	@effects[PBEffects::ColdConversion]      = false
	@effects[PBEffects::CreepOut]		 	 = false
	@effects[PBEffects::LuckyStar]       	 = false
	@effects[PBEffects::Inured]       	 	 = false
  end

	def takesSandstormDamage?
		return false if !takesIndirectDamage?
		return false if pbHasType?(:GROUND) || pbHasType?(:ROCK) || pbHasType?(:STEEL)
		return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
		return false if hasActiveAbility?([:OVERCOAT,:SANDFORCE,:SANDRUSH,:SANDVEIL,:STOUT])
		return false if hasActiveItem?(:SAFETYGOGGLES)
		return true
	  end

	def takesHailDamage?
		return false if !takesIndirectDamage?
		return false if pbHasType?(:ICE) || pbHasType?(:STEEL) || pbHasType?(:GHOST)
		return false if inTwoTurnAttack?("0CA","0CB")   # Dig, Dive
		return false if hasActiveAbility?([:OVERCOAT,:ICEBODY,:SNOWCLOAK,:STOUT,:SNOWWARNING])
		return false if hasActiveItem?(:SAFETYGOGGLES)
		return true
	end
	
  # Returns the active types of this Pokémon. The array should not include the
  # same type more than once, and should not include any invalid type numbers
  # (e.g. -1).
  def pbTypes(withType3=false)
    ret = [@type1]
    ret.push(@type2) if @type2!=@type1
    # Burn Up erases the Fire-type.
    ret.delete(:FIRE) if @effects[PBEffects::BurnUp]
	# Cold Conversion erases the Ice-type.
    ret.delete(:ICE) if @effects[PBEffects::ColdConversion]
    # Roost erases the Flying-type. If there are no types left, adds the Normal-
    # type.
    if @effects[PBEffects::Roost]
      ret.delete(:FLYING)
      ret.push(:NORMAL) if ret.length == 0
    end
    # Add the third type specially.
    if withType3 && @effects[PBEffects::Type3]
      ret.push(@effects[PBEffects::Type3]) if !ret.include?(@effects[PBEffects::Type3])
    end
    return ret
  end
  
  # permanent is whether the item is lost even after battle. Is false for Knock
  # Off.
  def pbRemoveItem(permanent = true)
	permanent = false # Items respawn after battle always!!
    @effects[PBEffects::ChoiceBand] = nil
    @effects[PBEffects::Unburden]   = true if self.item
    setInitialItem(nil) if permanent && self.item == self.initialItem
    self.item = nil
	@battle.scene.pbRefresh()
  end
  
  #=============================================================================
  # Generalised infliction of status problem
  #=============================================================================
  def pbInflictStatus(newStatus,newStatusCount=0,msg=nil,user=nil)
    # Inflict the new status
    self.status      = newStatus
    self.statusCount = newStatusCount
    @effects[PBEffects::Toxic] = 0
    # Show animation
    if newStatus == :POISON && newStatusCount > 0
      @battle.pbCommonAnimation("Toxic", self)
    else
      anim_name = GameData::Status.get(newStatus).animation
      @battle.pbCommonAnimation(anim_name, self) if anim_name
    end
    # Show message
    if msg && !msg.empty?
      @battle.pbDisplay(msg)
    else
      case newStatus
      when :SLEEP
        @battle.pbDisplay(_INTL("{1} fell asleep!", pbThis))
      when :POISON
        if newStatusCount>0
          @battle.pbDisplay(_INTL("{1} was toxified!", pbThis))
        else
          @battle.pbDisplay(_INTL("{1} was poisoned! Its Sp. Atk is reduced!", pbThis))
        end
      when :BURN
        @battle.pbDisplay(_INTL("{1} was burned! Its Attack is reduced!", pbThis))
      when :PARALYSIS
        @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!", pbThis))
      when :FROZEN
        @battle.pbDisplay(_INTL("{1} was chilled! It's slower and takes more damage!", pbThis))
      end
    end
    PBDebug.log("[Status change] #{pbThis}'s sleep count is #{newStatusCount}") if newStatus == :SLEEP
    # Form change check
    pbCheckFormOnStatusChange
    # Synchronize
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatusInflicted(self.ability,self,user,newStatus)
    end
    # Status cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
    # Petal Dance/Outrage/Thrash get cancelled immediately by falling asleep
    # NOTE: I don't know why this applies only to Outrage and only to falling
    #       asleep (i.e. it doesn't cancel Rollout/Uproar/other multi-turn
    #       moves, and it doesn't cancel any moves if self becomes frozen/
    #       disabled/anything else). This behaviour was tested in Gen 5.
    if @status == :SLEEP && @effects[PBEffects::Outrage] > 0
      @effects[PBEffects::Outrage] = 0
      @currentMove = nil
    end
  end
  
  def pbPoison(user=nil,msg=nil,toxic=false)
    if (boss && toxic)
      @battle.pbDisplay("The projection's power blunts the toxin.")
      toxic = false
    end
    pbInflictStatus(:POISON,(toxic) ? 1 : 0,msg,user)
  end
  
  def pbSleepDuration(duration = -1)
		duration = 4 if duration <= 0
		duration = 2 if hasActiveAbility?(:EARLYBIRD)
		return duration
  end
  
  def pbConfuse(msg=nil)
    @effects[PBEffects::Confusion] = pbConfusionDuration
	@effects[PBEffects::ConfusionChance] = 0
    @battle.pbCommonAnimation("Confusion",self)
    msg = _INTL("{1} became confused!",pbThis) if !msg || msg==""
    @battle.pbDisplay(msg)
    PBDebug.log("[Lingering effect] #{pbThis}'s confusion count is #{@effects[PBEffects::Confusion]}")
    # Confusion cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
  end

  def pbConfusionDuration(duration=-1)
    duration = 4 if duration<=0
    return duration
  end

  def pbCureConfusion
    @effects[PBEffects::Confusion] = 0
	@effects[PBEffects::ConfusionChance] = 0
  end
  
  #=============================================================================
  # Charm
  #=============================================================================
  def pbCanCharm?(user=nil,showMessages=true,move=nil,selfInflicted=false)
    return false if fainted?
    if @effects[PBEffects::Charm]>0
      @battle.pbDisplay(_INTL("{1} is already charmed.",pbThis)) if showMessages
      return false
    end
    if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
       !selfInflicted
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    # Terrains immunity
    if affectedByTerrain? && @battle.field.terrain == :Misty
      @battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!",pbThis(true))) if showMessages
      return false
    end
    if selfInflicted || !@battle.moldBreaker
      if hasActiveAbility?(:OWNTEMPO)
        if showMessages
          @battle.pbShowAbilitySplash(self)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} doesn't become charmed!",pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents charmed!",pbThis,abilityName))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanCharmSelf?(showMessages)
    return pbCanConfuse?(nil,showMessages,nil,true)
  end
  
  def pbCharm(msg=nil)
    @effects[PBEffects::Charm] = pbCharmDuration
	@effects[PBEffects::CharmChance] = 0
    @battle.pbAnimation(:LUCKYCHANT,self,nil)
    msg = _INTL("{1} became charmed!",pbThis) if !msg || msg==""
    @battle.pbDisplay(msg)
    PBDebug.log("[Lingering effect] #{pbThis}'s charm count is #{@effects[PBEffects::Confusion]}")
    # Charm cures
    pbItemStatusCureCheck
    pbAbilityStatusCureCheck
  end

  def pbCharmDuration(duration=-1)
    duration = 4 if duration<=0
    return duration
  end

  def pbCureCharm
    @effects[PBEffects::Charm] = 0
	@effects[PBEffects::CharmChance] = 0
  end
  
  def pbConfusionDamage(msg,charm=false)
    @damageState.reset
    @damageState.initialHP = @hp
    confusionMove = charm ? PokeBattle_Charm.new(@battle,nil) : PokeBattle_Confusion.new(@battle,nil)
    confusionMove.calcType = confusionMove.pbCalcType(self)   # nil
    @damageState.typeMod = confusionMove.pbCalcTypeMod(confusionMove.calcType,self,self)   # 8
    confusionMove.pbCheckDamageAbsorption(self,self)
    confusionMove.pbCalcDamage(self,self)
    confusionMove.pbReduceDamage(self,self)
    self.hp -= @damageState.hpLost
    confusionMove.pbAnimateHitAndHPLost(self,[self])
    @battle.pbDisplay(msg)   # "It hurt itself in its confusion!"
    confusionMove.pbRecordDamageLost(self,self)
    confusionMove.pbEndureKOMessage(self)
    pbFaint if fainted?
    pbItemHPHealCheck
  end 
  
  def pbCanInflictStatus?(newStatus,user,showMessages,move=nil,ignoreStatus=false)
    return false if fainted?
    selfInflicted = (user && user.index==@index)
    # Already have that status problem
    if self.status==newStatus && !ignoreStatus
      if showMessages
        msg = ""
        case self.status
        when :SLEEP     then msg = _INTL("{1} is already asleep!", pbThis)
        when :POISON    then msg = _INTL("{1} is already poisoned!", pbThis)
        when :BURN      then msg = _INTL("{1} already has a burn!", pbThis)
        when :PARALYSIS then msg = _INTL("{1} is already paralyzed!", pbThis)
        when :FROZEN    then msg = _INTL("{1} is already chilled!", pbThis)
        end
        @battle.pbDisplay(msg)
      end
      return false
    end
    # Trying to replace a status problem with another one
    if self.status != :NONE && !ignoreStatus && !selfInflicted
      @battle.pbDisplay(_INTL("{1} already has a status problem...",pbThis(false))) if showMessages
      return false
    end
    # Trying to inflict a status problem on a Pokémon behind a substitute
    if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user)) &&
       !selfInflicted
      @battle.pbDisplay(_INTL("It doesn't affect {1} behind its substitute...",pbThis(true))) if showMessages
      return false
    end
    # Weather immunity
    if newStatus == :FROZEN && [:Sun, :HarshSun].include?(@battle.pbWeather)
      @battle.pbDisplay(_INTL("It doesn't affect {1} due to the sunny weather...",pbThis(true))) if showMessages
      return false
    end
    # Terrains immunity
    if affectedByTerrain?
      case @battle.field.terrain
      when :Electric
        if newStatus == :SLEEP
          @battle.pbDisplay(_INTL("{1} surrounds itself with electrified terrain!",
             pbThis(true))) if showMessages
          return false
        end
      when :Misty
        @battle.pbDisplay(_INTL("{1} surrounds itself with misty terrain!",pbThis(true))) if showMessages
        return false
      end
    end
    # Uproar immunity
    if newStatus == :SLEEP && !(hasActiveAbility?(:SOUNDPROOF) && !@battle.moldBreaker)
      @battle.eachBattler do |b|
        next if b.effects[PBEffects::Uproar]==0
        @battle.pbDisplay(_INTL("But the uproar kept {1} awake!",pbThis(true))) if showMessages
        return false
      end
    end
    # Type immunities
    hasImmuneType = false
    case newStatus
    when :SLEEP
      # No type is immune to sleep
    when :POISON
      if !(user && user.hasActiveAbility?(:CORROSION))
        hasImmuneType |= pbHasType?(:POISON)
        hasImmuneType |= pbHasType?(:STEEL)
      end
    when :BURN
      hasImmuneType |= pbHasType?(:FIRE)
    when :PARALYSIS
      hasImmuneType |= pbHasType?(:ELECTRIC) && Settings::MORE_TYPE_EFFECTS
    when :FROZEN
      hasImmuneType |= pbHasType?(:ICE)
    end
    if hasImmuneType
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    # Ability immunity
    immuneByAbility = false; immAlly = nil
    if BattleHandlers.triggerStatusImmunityAbilityNonIgnorable(self.ability,self,newStatus)
      immuneByAbility = true
    elsif selfInflicted || !@battle.moldBreaker
      if abilityActive? && BattleHandlers.triggerStatusImmunityAbility(self.ability,self,newStatus)
        immuneByAbility = true
      else
        eachAlly do |b|
          next if !b.abilityActive?
          next if !BattleHandlers.triggerStatusImmunityAllyAbility(b.ability,self,newStatus)
          immuneByAbility = true
          immAlly = b
          break
        end
      end
    end
    if immuneByAbility
      if showMessages
        @battle.pbShowAbilitySplash(immAlly || self)
        msg = ""
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          case newStatus
          when :SLEEP     then msg = _INTL("{1} stays awake!", pbThis)
          when :POISON    then msg = _INTL("{1} cannot be poisoned!", pbThis)
          when :BURN      then msg = _INTL("{1} cannot be burned!", pbThis)
          when :PARALYSIS then msg = _INTL("{1} cannot be paralyzed!", pbThis)
          when :FROZEN    then msg = _INTL("{1} cannot be chilled!", pbThis)
          end
        elsif immAlly
          case newStatus
          when :SLEEP
            msg = _INTL("{1} stays awake because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :POISON
            msg = _INTL("{1} cannot be poisoned because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :BURN
            msg = _INTL("{1} cannot be burned because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :PARALYSIS
            msg = _INTL("{1} cannot be paralyzed because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          when :FROZEN
            msg = _INTL("{1} cannot be chilled because of {2}'s {3}!",
               pbThis,immAlly.pbThis(true),immAlly.abilityName)
          end
        else
          case newStatus
          when :SLEEP     then msg = _INTL("{1} stays awake because of its {2}!", pbThis, abilityName)
          when :POISON    then msg = _INTL("{1}'s {2} prevents poisoning!", pbThis, abilityName)
          when :BURN      then msg = _INTL("{1}'s {2} prevents burns!", pbThis, abilityName)
          when :PARALYSIS then msg = _INTL("{1}'s {2} prevents paralysis!", pbThis, abilityName)
          when :FROZEN    then msg = _INTL("{1}'s {2} prevents chilling!", pbThis, abilityName)
          end
        end
        @battle.pbDisplay(msg)
        @battle.pbHideAbilitySplash(immAlly || self)
      end
      return false
    end
    # Safeguard immunity
    if pbOwnSide.effects[PBEffects::Safeguard]>0 && !selfInflicted && move &&
       !(user && user.hasActiveAbility?(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end
  
  def pbLowerStatStage(stat,increment,user,showAnim=true,ignoreContrary=false,ignoreMirrorArmor=false)
    # Mirror Armor
    if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index!=@index) && 
	  !@battle.moldBreaker && pbCanLowerStatStage?(stat)
      battle.pbShowAbilitySplash(self)
      @battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!",pbThis))
      if !user
        battle.pbHideAbilitySplash(self)
        return false
      end
      if !user.hasActiveAbility?(:MIRRORARMOR) && user.pbCanLowerStatStage?(stat,nil,nil,true)
        user.pbLowerStatStageByAbility(stat,increment,user,splashAnim=false,checkContact=false)
		# Trigger user's abilities upon stat loss
		if user.abilityActive?
		  BattleHandlers.triggerAbilityOnStatLoss(user.ability,user,stat,self)
		end
      end
      battle.pbHideAbilitySplash(self)
      return false
    end
	# Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbRaiseStatStage(stat,increment,user,showAnim,true)
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown",self) if showAnim
    arrStatTexts = [
       _INTL("{1}'s {2} fell!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} harshly fell!",pbThis,GameData::Stat.get(stat).name),
       _INTL("{1}'s {2} severely fell!",pbThis,GameData::Stat.get(stat).name)]
    @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
    end
	@effects[PBEffects::LashOut] = true
    return true
  end
  
  def pbLowerStatStageByCause(stat,increment,user,cause,showAnim=true,ignoreContrary=false,ignoreMirrorArmor=false)
	# Mirror Armor
    if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && (!user || user.index!=@index) && 
	  !@battle.moldBreaker && pbCanLowerStatStage?(stat)
      battle.pbShowAbilitySplash(self)
      @battle.pbDisplay(_INTL("{1}'s Mirror Armor activated!",pbThis))
      if !user
        battle.pbHideAbilitySplash(self)
        return false
      end
      if !user.hasActiveAbility?(:MIRRORARMOR) && user.pbCanLowerStatStage?(stat,nil,nil,true)
        user.pbLowerStatStageByAbility(stat,increment,user,splashAnim=false,checkContact=false)
		# Trigger user's abilities upon stat loss
		if user.abilityActive?
		  BattleHandlers.triggerAbilityOnStatLoss(user.ability,user,stat,self)
		end
      end
      battle.pbHideAbilitySplash(self)
      return false
    end
    # Contrary
    if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
      return pbRaiseStatStageByCause(stat,increment,user,cause,showAnim,true)
    end
	# Royal Scales
    if hasActiveAbility?(:ROYALSCALES) && !@battle.moldBreaker
      return false
    end
    # Perform the stat stage change
    increment = pbLowerStatStageBasic(stat,increment,ignoreContrary)
    return false if increment<=0
    # Stat down animation and message
    @battle.pbCommonAnimation("StatDown",self) if showAnim
    if user.index==@index
      arrStatTexts = [
         _INTL("{1}'s {2} lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} harshly lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} severely lowered its {3}!",pbThis,cause,GameData::Stat.get(stat).name)]
    else
      arrStatTexts = [
         _INTL("{1}'s {2} lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} harshly lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name),
         _INTL("{1}'s {2} severely lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),GameData::Stat.get(stat).name)]
    end
    @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
    # Trigger abilities upon stat loss
    if abilityActive?
      BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
    end
	@effects[PBEffects::LashOut] = true
    return true
  end
  
  def pbLowerSpecialAttackStatStageDazzle(user)
    return false if fainted?
    # NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
    if @effects[PBEffects::Substitute]>0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis))
      else
        @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
           pbThis,user.pbThis(true),user.abilityName))
      end
      return false
    end
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      return pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,user,false)
    end
    # NOTE: These checks exist to ensure appropriate messages are shown if
    #       Intimidate is blocked somehow (i.e. the messages should mention the
    #       Intimidate ability by name).
    if !hasActiveAbility?(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,user.pbThis(true),user.abilityName))
        return false
      end
      if abilityActive?
        if BattleHandlers.triggerStatLossImmunityAbility(self.ability,self,:ATTACK,@battle,false) ||
           BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(self.ability,self,:ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
             pbThis,abilityName,user.pbThis(true),user.abilityName))
          return false
        end
      end
      eachAlly do |b|
        next if !b.abilityActive?
        if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,:ATTACK,@battle,false)
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
             pbThis,user.pbThis(true),user.abilityName,b.pbThis(true),b.abilityName))
          return false
        end
      end
    end
    return false if !pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
    return pbLowerStatStageByCause(:SPECIAL_ATTACK,1,user,user.abilityName)
  end
  
  #=============================================================================
  # Calculated properties
  #=============================================================================
  def pbSpeed
    return 1 if fainted?
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    stage = @stages[:SPEED] + 6
    speed = @speed*stageMul[stage]/stageDiv[stage]
    speedMult = 1.0
    # Ability effects that alter calculated Speed
    if abilityActive?
      speedMult = BattleHandlers.triggerSpeedCalcAbility(self.ability,self,speedMult)
    end
    # Item effects that alter calculated Speed
    if itemActive?
      speedMult = BattleHandlers.triggerSpeedCalcItem(self.item,self,speedMult)
    end
    # Other effects
    speedMult *= 2 if pbOwnSide.effects[PBEffects::Tailwind]>0
    speedMult /= 2 if pbOwnSide.effects[PBEffects::Swamp]>0
    # Paralysis
    if (status == :PARALYSIS && !hasActiveAbility?(:QUICKFEET)) || status == :FROZEN
      speedMult /= (Settings::MECHANICS_GENERATION >= 7) ? 2 : 4
    end
    # Badge multiplier
    if @battle.internalBattle && pbOwnedByPlayer? &&
       @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPEED
      speedMult *= 1.1
    end
    # Calculation
    return [(speed*speedMult).round,1].max
  end
  
  #=============================================================================
  # Change type
  #=============================================================================
  def pbChangeTypes(newType)
    if newType.is_a?(PokeBattle_Battler)
      newTypes = newType.pbTypes
      newTypes.push(:NORMAL) if newTypes.length == 0
      newType3 = newType.effects[PBEffects::Type3]
      newType3 = nil if newTypes.include?(newType3)
      @type1 = newTypes[0]
      @type2 = (newTypes.length == 1) ? newTypes[0] : newTypes[1]
      @effects[PBEffects::Type3] = newType3
    else
      newType = GameData::Type.get(newType).id
      @type1 = newType
      @type2 = newType
      @effects[PBEffects::Type3] = nil
    end
    @effects[PBEffects::BurnUp] 		= false
	@effects[PBEffects::ColdConversion] = false
    @effects[PBEffects::Roost]  		= false
	@battle.scene.pbRefresh()
  end
  
  #=============================================================================
  # Check whether the user (self) is able to take action at all.
  # If this returns true, and if PP isn't a problem, the move will be considered
  # to have been used (even if it then fails for whatever reason).
  #=============================================================================
  def pbTryUseMove(choice,move,specialUsage,skipAccuracyCheck)
    # Check whether it's possible for self to use the given move
    # NOTE: Encore has already changed the move being used, no need to have a
    #       check for it here.
    if !pbCanChooseMove?(move,false,true,specialUsage)
      @lastMoveFailed = true
      return false
    end
    # Check whether it's possible for self to do anything at all
    if @effects[PBEffects::SkyDrop]>=0   # Intentionally no message here
      PBDebug.log("[Move failed] #{pbThis} can't use #{move.name} because of being Sky Dropped")
      return false
    end
    if @effects[PBEffects::HyperBeam]>0   # Intentionally before Truant
      @battle.pbDisplay(_INTL("{1} must recharge!",pbThis))
      return false
    end
    if choice[1]==-2   # Battle Palace
      @battle.pbDisplay(_INTL("{1} appears incapable of using its power!",pbThis))
      return false
    end
    # Skip checking all applied effects that could make self fail doing something
    return true if skipAccuracyCheck
    # Check status problems and continue their effects/cure them
    case @status
    when :SLEEP
      self.statusCount -= 1
      if @statusCount<=0
        pbCureStatus
      else
        pbContinueStatus
        if !move.usableWhenAsleep?   # Snore/Sleep Talk
          @lastMoveFailed = true
          return false
        end
      end
	end
    # Obedience check
    return false if !pbObedienceCheck?(choice)
    # Truant
    if hasActiveAbility?(:TRUANT)
      @effects[PBEffects::Truant] = !@effects[PBEffects::Truant]
      if !@effects[PBEffects::Truant] && move.id != :SLACKOFF   # True means loafing, but was just inverted
        @battle.pbShowAbilitySplash(self)
        @battle.pbDisplay(_INTL("{1} is loafing around!",pbThis))
        @lastMoveFailed = true
        @battle.pbHideAbilitySplash(self)
        return false
      end
    end
    # Flinching
    if @effects[PBEffects::Flinch]
      if @effects[PBEffects::FlinchedAlready]
        @battle.pbDisplay("#{pbThis} shrugged off their fear and didn't flinch!")
        @effects[PBEffects::Flinch] = false
      else
        @battle.pbDisplay(_INTL("{1} flinched and couldn't move!",pbThis))
        if abilityActive?
          BattleHandlers.triggerAbilityOnFlinch(@ability,self,@battle)
        end
        @lastMoveFailed = true
        @effects[PBEffects::FlinchedAlready] = true
        return false
      end
    end
    # Confusion
    if @effects[PBEffects::Confusion]>0
      @effects[PBEffects::Confusion] -= 1
      if @effects[PBEffects::Confusion]<=0
        pbCureConfusion
        @battle.pbDisplay(_INTL("{1} snapped out of its confusion.",pbThis))
      else
        @battle.pbCommonAnimation("Confusion",self)
        @battle.pbDisplay(_INTL("{1} is confused!",pbThis))
        threshold = 30 + 35 * @effects[PBEffects::ConfusionChance]
        if @battle.pbRandom(100)<threshold && !hasActiveAbility?([:HEADACHE,:TANGLEDFEET])
          @effects[PBEffects::ConfusionChance] = 0
          pbConfusionDamage(_INTL("It hurt itself in its confusion!"))
		  @effects[PBEffects::ConfusionChance] = -999
          @lastMoveFailed = true
          return false
        else
          @effects[PBEffects::ConfusionChance] += 1
        end
      end
    end
	# Charm
    if @effects[PBEffects::Charm]>0
      @effects[PBEffects::Charm] -= 1
      if @effects[PBEffects::Charm]<=0
        pbCureCharm
        @battle.pbDisplay(_INTL("{1} was released from the charm.",pbThis))
      else
        @battle.pbAnimation(:LUCKYCHANT,self,nil)
        @battle.pbDisplay(_INTL("{1} is charmed!",pbThis))
        threshold = 30 + 35 * @effects[PBEffects::CharmChance]
        if @battle.pbRandom(100)<threshold && !hasActiveAbility?([:HEADACHE,:TANGLEDFEET])
          @effects[PBEffects::CharmChance] = 0
          pbConfusionDamage(_INTL("It's energy went wild due to the charm!"))
		  @effects[PBEffects::CharmChance] = -999
          @lastMoveFailed = true
          return false
        else
          @effects[PBEffects::CharmChance] += 1
        end
      end
    end
    # Paralysis
    if @status == :PARALYSIS
      if @battle.pbRandom(100)<25
        pbContinueStatus
        @lastMoveFailed = true
        return false
      end
    end
    # Infatuation
    if @effects[PBEffects::Attract]>=0
      @battle.pbCommonAnimation("Attract",self)
      @battle.pbDisplay(_INTL("{1} is in love with {2}!",pbThis,
         @battle.battlers[@effects[PBEffects::Attract]].pbThis(true)))
      if @battle.pbRandom(100)<50
        @battle.pbDisplay(_INTL("{1} is immobilized by love!",pbThis))
        @lastMoveFailed = true
        return false
      end
    end
    return true
  end
  
  #=============================================================================
  # Obedience check
  #=============================================================================
  # Return true if Pokémon continues attacking (although it may have chosen to
  # use a different move in disobedience), or false if attack stops.
  def pbObedienceCheck?(choice)
    return true
  end
  
  #=============================================================================
  # Master "use move" method
  #=============================================================================
  def pbUseMove(choice,specialUsage=false)
    # NOTE: This is intentionally determined before a multi-turn attack can
    #       set specialUsage to true.
    skipAccuracyCheck = (specialUsage && choice[2]!=@battle.struggle)
    # Start using the move
    pbBeginTurn(choice)
    # Force the use of certain moves if they're already being used
    if usingMultiTurnAttack?
      choice[2] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(@currentMove))
      specialUsage = true
    elsif @effects[PBEffects::Encore]>0 && choice[1]>=0 &&
       @battle.pbCanShowCommands?(@index)
      idxEncoredMove = pbEncoredMoveIndex
      if idxEncoredMove>=0 && @battle.pbCanChooseMove?(@index,idxEncoredMove,false)
        if choice[1]!=idxEncoredMove   # Change move if battler was Encored mid-round
          choice[1] = idxEncoredMove
          choice[2] = @moves[idxEncoredMove]
          choice[3] = -1   # No target chosen
        end
      end
    end
    # Labels the move being used as "move"
    move = choice[2]
    return if !move   # if move was not chosen somehow
    # Try to use the move (inc. disobedience)
    @lastMoveFailed = false
    if !pbTryUseMove(choice,move,specialUsage,skipAccuracyCheck)
      @lastMoveUsed     = nil
      @lastMoveUsedType = nil
      if !specialUsage
        @lastRegularMoveUsed   = nil
        @lastRegularMoveTarget = -1
      end
      @battle.pbGainExp   # In case self is KO'd due to confusion
      pbCancelMoves
      pbEndTurn(choice)
      return
    end
    move = choice[2]   # In case disobedience changed the move to be used
    return if !move   # if move was not chosen somehow
    # Subtract PP
    if !specialUsage
      if !pbReducePP(move)
        @battle.pbDisplay(_INTL("{1} used {2}!",pbThis,move.name))
        @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
        @lastMoveUsed          = nil
        @lastMoveUsedType      = nil
        @lastRegularMoveUsed   = nil
        @lastRegularMoveTarget = -1
        @lastMoveFailed        = true
        pbCancelMoves
        pbEndTurn(choice)
        return
      end
    end
    # Stance Change
    if isSpecies?(:AEGISLASH) && self.ability == :STANCECHANGE
      if move.damagingMove?
        pbChangeForm(1,_INTL("{1} changed to Blade Forme!",pbThis))
      elsif move.id == :KINGSSHIELD
        pbChangeForm(0,_INTL("{1} changed to Shield Forme!",pbThis))
      end
    end
    # Calculate the move's type during this usage
    move.calcType = move.pbCalcType(self)
    # Start effect of Mold Breaker
    @battle.moldBreaker = hasMoldBreaker?
    # Remember that user chose a two-turn move
    if move.pbIsChargingTurn?(self)
      # Beginning the use of a two-turn attack
      @effects[PBEffects::TwoTurnAttack] = move.id
      @currentMove = move.id
    else
      @effects[PBEffects::TwoTurnAttack] = nil   # Cancel use of two-turn attack
    end
    # Add to counters for moves which increase them when used in succession
    move.pbChangeUsageCounters(self,specialUsage)
    # Charge up Metronome item
    if hasActiveItem?(:METRONOME) && !move.callsAnotherMove?
      if @lastMoveUsed && @lastMoveUsed==move.id && !@lastMoveFailed
        @effects[PBEffects::Metronome] += 1
      else
        @effects[PBEffects::Metronome] = 0
      end
    end
    # Record move as having been used
    @lastMoveUsed     = move.id
    @lastMoveUsedType = move.calcType   # For Conversion 2
    if !specialUsage
      @lastRegularMoveUsed   = move.id   # For Disable, Encore, Instruct, Mimic, Mirror Move, Sketch, Spite
      @lastRegularMoveTarget = choice[3]   # For Instruct (remembering original target is fine)
      @movesUsed.push(move.id) if !@movesUsed.include?(move.id)   # For Last Resort
    end
    @battle.lastMoveUsed = move.id   # For Copycat
    @battle.lastMoveUser = @index   # For "self KO" battle clause to avoid draws
    @battle.successStates[@index].useState = 1   # Battle Arena - assume failure
    # Find the default user (self or Snatcher) and target(s)
    user = pbFindUser(choice,move)
    user = pbChangeUser(choice,move,user)
    targets = pbFindTargets(choice,move,user)
    targets = pbChangeTargets(move,user,targets)
    # Pressure
    if !specialUsage
      targets.each do |b|
        next unless b.opposes?(user) && b.hasActiveAbility?(:PRESSURE)
        PBDebug.log("[Ability triggered] #{b.pbThis}'s #{b.abilityName}")
        user.pbReducePP(move)
      end
      if move.pbTarget(user).affects_foe_side
        @battle.eachOtherSideBattler(user) do |b|
          next unless b.hasActiveAbility?(:PRESSURE)
          PBDebug.log("[Ability triggered] #{b.pbThis}'s #{b.abilityName}")
          user.pbReducePP(move)
        end
      end
    end
    # Dazzling/Queenly Majesty make the move fail here
    @battle.pbPriority(true).each do |b|
      next if !b || !b.abilityActive?
      if BattleHandlers.triggerMoveBlockingAbility(b.ability,b,user,targets,move,@battle)
        @battle.pbDisplayBrief(_INTL("{1} used {2}!",user.pbThis,move.name))
        @battle.pbShowAbilitySplash(b)
        @battle.pbDisplay(_INTL("{1} cannot use {2}!",user.pbThis,move.name))
        @battle.pbHideAbilitySplash(b)
        user.lastMoveFailed = true
        pbCancelMoves
        pbEndTurn(choice)
        return
      end
    end
    # "X used Y!" message
    # Can be different for Bide, Fling, Focus Punch and Future Sight
    # NOTE: This intentionally passes self rather than user. The user is always
    #       self except if Snatched, but this message should state the original
    #       user (self) even if the move is Snatched.
    move.pbDisplayUseMessage(self)
    # Snatch's message (user is the new user, self is the original user)
    if move.snatched
      @lastMoveFailed = true   # Intentionally applies to self, not user
      @battle.pbDisplay(_INTL("{1} snatched {2}'s move!",user.pbThis,pbThis(true)))
    end
    # "But it failed!" checks
    if move.pbMoveFailed?(user,targets)
      PBDebug.log(sprintf("[Move failed] In function code %s's def pbMoveFailed?",move.function))
      user.lastMoveFailed = true
      pbCancelMoves
      pbEndTurn(choice)
      return
    end
    # Perform set-up actions and display messages
    # Messages include Magnitude's number and Pledge moves' "it's a combo!"
    move.pbOnStartUse(user,targets)
    # Powder
    if user.effects[PBEffects::Powder] && move.calcType == :FIRE
      @battle.pbCommonAnimation("Powder",user)
      @battle.pbDisplay(_INTL("When the flame touched the powder on the Pokémon, it exploded!"))
      user.lastMoveFailed = true
      if ![:Rain, :HeavyRain].include?(@battle.pbWeather) && user.takesIndirectDamage?
        oldHP = user.hp
        user.pbReduceHP((user.totalhp/4.0).round,false)
        user.pbFaint if user.fainted?
        @battle.pbGainExp   # In case user is KO'd by this
        user.pbItemHPHealCheck
        if user.pbAbilitiesOnDamageTaken(oldHP)
          user.pbEffectsOnSwitchIn(true)
        end
      end
      pbCancelMoves
      pbEndTurn(choice)
      return
    end
    # Primordial Sea, Desolate Land
    if move.damagingMove?
      case @battle.pbWeather
      when :HeavyRain
        if move.calcType == :FIRE
          @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
          user.lastMoveFailed = true
          pbCancelMoves
          pbEndTurn(choice)
          return
        end
      when :HarshSun
        if move.calcType == :WATER
          @battle.pbDisplay(_INTL("The Water-type attack evaporated in the harsh sunlight!"))
          user.lastMoveFailed = true
          pbCancelMoves
          pbEndTurn(choice)
          return
        end
      end
    end
    # Protean
    if user.hasActiveAbility?(:PROTEAN) && !move.callsAnotherMove? && !move.snatched
      if user.pbHasOtherType?(move.calcType) && !GameData::Type.get(move.calcType).pseudo_type
        @battle.pbShowAbilitySplash(user)
        user.pbChangeTypes(move.calcType)
        typeName = GameData::Type.get(move.calcType).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",user.pbThis,typeName))
        @battle.pbHideAbilitySplash(user)
        # NOTE: The GF games say that if Curse is used by a non-Ghost-type
        #       Pokémon which becomes Ghost-type because of Protean, it should
        #       target and curse itself. I think this is silly, so I'm making it
        #       choose a random opponent to curse instead.
        if move.function=="10D" && targets.length==0   # Curse
          choice[3] = -1
          targets = pbFindTargets(choice,move,user)
        end
      end
    end
    #---------------------------------------------------------------------------
    magicCoater  = -1
    magicBouncer = -1
    if targets.length == 0 && move.pbTarget(user).num_targets > 0 && !move.worksWithNoTargets?
      # def pbFindTargets should have found a target(s), but it didn't because
      # they were all fainted
      # All target types except: None, User, UserSide, FoeSide, BothSides
      @battle.pbDisplay(_INTL("But there was no target..."))
      user.lastMoveFailed = true
    else   # We have targets, or move doesn't use targets
      # Reset whole damage state, perform various success checks (not accuracy)
      user.initialHP = user.hp
      targets.each do |b|
        b.damageState.reset
        b.damageState.initialHP = b.hp
        if !pbSuccessCheckAgainstTarget(move,user,b)
          b.damageState.unaffected = true
        end
      end
      # Magic Coat/Magic Bounce checks (for moves which don't target Pokémon)
      if targets.length==0 && move.canMagicCoat?
        @battle.pbPriority(true).each do |b|
          next if b.fainted? || !b.opposes?(user)
          next if b.semiInvulnerable?
          if b.effects[PBEffects::MagicCoat]
            magicCoater = b.index
            b.effects[PBEffects::MagicCoat] = false
            break
          elsif b.hasActiveAbility?(:MAGICBOUNCE) && !@battle.moldBreaker &&
             !b.effects[PBEffects::MagicBounce]
            magicBouncer = b.index
            b.effects[PBEffects::MagicBounce] = true
            break
          end
        end
      end
      # Get the number of hits
      numHits = move.pbNumHits(user,targets)
      # Process each hit in turn
      realNumHits = 0
      for i in 0...numHits
        break if magicCoater>=0 || magicBouncer>=0
        success = pbProcessMoveHit(move,user,targets,i,skipAccuracyCheck)
        if !success
          if i==0 && targets.length>0
            hasFailed = false
            targets.each do |t|
              next if t.damageState.protected
              hasFailed = t.damageState.unaffected
              break if !t.damageState.unaffected
            end
            user.lastMoveFailed = hasFailed
          end
          break
        end
        realNumHits += 1
        break if user.fainted?
        break if [:SLEEP, :FROZEN].include?(user.status)
        # NOTE: If a multi-hit move becomes disabled partway through doing those
        #       hits (e.g. by Cursed Body), the rest of the hits continue as
        #       normal.
        break if !targets.any? { |t| !t.fainted? }   # All targets are fainted
      end
      # Battle Arena only - attack is successful
      @battle.successStates[user.index].useState = 2
      if targets.length>0
        @battle.successStates[user.index].typeMod = 0
        targets.each do |b|
          next if b.damageState.unaffected
          @battle.successStates[user.index].typeMod += b.damageState.typeMod
        end
      end
      # Effectiveness message for multi-hit moves
      # NOTE: No move is both multi-hit and multi-target, and the messages below
      #       aren't quite right for such a hypothetical move.
      if numHits>1
        if move.damagingMove?
          targets.each do |b|
            next if b.damageState.unaffected || b.damageState.substitute
            move.pbEffectivenessMessage(user,b,targets.length)
          end
        end
        if realNumHits==1
          @battle.pbDisplay(_INTL("Hit 1 time!"))
        elsif realNumHits>1
          @battle.pbDisplay(_INTL("Hit {1} times!",realNumHits))
        end
      end
      # Magic Coat's bouncing back (move has targets)
      targets.each do |b|
        next if b.fainted?
        next if !b.damageState.magicCoat && !b.damageState.magicBounce
        @battle.pbShowAbilitySplash(b) if b.damageState.magicBounce
        @battle.pbDisplay(_INTL("{1} bounced the {2} back!",b.pbThis,move.name))
        @battle.pbHideAbilitySplash(b) if b.damageState.magicBounce
        newChoice = choice.clone
        newChoice[3] = user.index
        newTargets = pbFindTargets(newChoice,move,b)
        newTargets = pbChangeTargets(move,b,newTargets)
        success = pbProcessMoveHit(move,b,newTargets,0,false)
        b.lastMoveFailed = true if !success
        targets.each { |otherB| otherB.pbFaint if otherB && otherB.fainted? }
        user.pbFaint if user.fainted?
      end
      # Magic Coat's bouncing back (move has no targets)
      if magicCoater>=0 || magicBouncer>=0
        mc = @battle.battlers[(magicCoater>=0) ? magicCoater : magicBouncer]
        if !mc.fainted?
          user.lastMoveFailed = true
          @battle.pbShowAbilitySplash(mc) if magicBouncer>=0
          @battle.pbDisplay(_INTL("{1} bounced the {2} back!",mc.pbThis,move.name))
          @battle.pbHideAbilitySplash(mc) if magicBouncer>=0
          success = pbProcessMoveHit(move,mc,[],0,false)
          mc.lastMoveFailed = true if !success
          targets.each { |b| b.pbFaint if b && b.fainted? }
          user.pbFaint if user.fainted?
        end
      end
      # Move-specific effects after all hits
      targets.each { |b| move.pbEffectAfterAllHits(user,b) }
      # Faint if 0 HP
      targets.each { |b| b.pbFaint if b && b.fainted? }
      user.pbFaint if user.fainted?
      # External/general effects after all hits. Eject Button, Shell Bell, etc.
      pbEffectsAfterMove(user,targets,move,realNumHits)
    end
    # End effect of Mold Breaker
    @battle.moldBreaker = false
    # Gain Exp
    @battle.pbGainExp
    # Battle Arena only - update skills
    @battle.eachBattler { |b| @battle.successStates[b.index].updateSkill }
    # Shadow Pokémon triggering Hyper Mode
    pbHyperMode if @battle.choices[@index][0]!=:None   # Not if self is replaced
	# Refresh the scene to account for changes to pokemon status
	@battle.scene.pbRefresh()
    # End of move usage
    pbEndTurn(choice)
    # Instruct
    @battle.eachBattler do |b|
      next if !b.effects[PBEffects::Instruct] || !b.lastMoveUsed
      b.effects[PBEffects::Instruct] = false
      idxMove = -1
      b.eachMoveWithIndex { |m,i| idxMove = i if m.id==b.lastMoveUsed }
      next if idxMove<0
      oldLastRoundMoved = b.lastRoundMoved
      @battle.pbDisplay(_INTL("{1} used the move instructed by {2}!",b.pbThis,user.pbThis(true)))
      PBDebug.logonerr{
        b.effects[PBEffects::Instructed] = true
        b.pbUseMoveSimple(b.lastMoveUsed,b.lastRegularMoveTarget,idxMove,false)
        b.effects[PBEffects::Instructed] = false
      }
      b.lastRoundMoved = oldLastRoundMoved
      @battle.pbJudge
      return if @battle.decision>0
    end
    # Dancer
    if !@effects[PBEffects::Dancer] && !user.lastMoveFailed && realNumHits>0 &&
       !move.snatched && magicCoater<0 && @battle.pbCheckGlobalAbility(:DANCER) &&
       move.danceMove?
      dancers = []
      @battle.pbPriority(true).each do |b|
        dancers.push(b) if b.index!=user.index && b.hasActiveAbility?(:DANCER)
      end
      while dancers.length>0
        nextUser = dancers.pop
        oldLastRoundMoved = nextUser.lastRoundMoved
        # NOTE: Petal Dance being used because of Dancer shouldn't lock the
        #       Dancer into using that move, and shouldn't contribute to its
        #       turn counter if it's already locked into Petal Dance.
        oldOutrage = nextUser.effects[PBEffects::Outrage]
        nextUser.effects[PBEffects::Outrage] += 1 if nextUser.effects[PBEffects::Outrage]>0
        oldCurrentMove = nextUser.currentMove
        preTarget = choice[3]
        preTarget = user.index if nextUser.opposes?(user) || !nextUser.opposes?(preTarget)
        @battle.pbShowAbilitySplash(nextUser,true)
        @battle.pbHideAbilitySplash(nextUser)
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} kept the dance going with {2}!",
             nextUser.pbThis,nextUser.abilityName))
        end
        PBDebug.logonerr{
          nextUser.effects[PBEffects::Dancer] = true
          nextUser.pbUseMoveSimple(move.id,preTarget)
          nextUser.effects[PBEffects::Dancer] = false
        }
        nextUser.lastRoundMoved = oldLastRoundMoved
        nextUser.effects[PBEffects::Outrage] = oldOutrage
        nextUser.currentMove = oldCurrentMove
        @battle.pbJudge
        return if @battle.decision>0
      end
    end
  end
  
  #=============================================================================
  # Effects after all hits (i.e. at end of move usage)
  #=============================================================================
  def pbEffectsAfterMove(user,targets,move,numHits)
    # Destiny Bond
    # NOTE: Although Destiny Bond is similar to Grudge, they don't apply at
    #       the same time (although Destiny Bond does check whether it's going
    #       to trigger at the same time as Grudge).
    if user.effects[PBEffects::DestinyBondTarget]>=0 && !user.fainted?
      dbName = @battle.battlers[user.effects[PBEffects::DestinyBondTarget]].pbThis
      @battle.pbDisplay(_INTL("{1} took its attacker down with it!",dbName))
      user.pbReduceHP(user.hp,false)
      user.pbItemHPHealCheck
      user.pbFaint
      @battle.pbJudgeCheckpoint(user)
    end
    # User's ability
    if user.abilityActive?
      BattleHandlers.triggerUserAbilityEndOfMove(user.ability,user,targets,move,@battle)
    end
    # Greninja - Battle Bond
    if !user.fainted? && !user.effects[PBEffects::Transform] &&
       user.isSpecies?(:GRENINJA) && user.ability == :BATTLEBOND
      if !@battle.pbAllFainted?(user.idxOpposingSide) &&
         !@battle.battleBond[user.index&1][user.pokemonIndex]
        numFainted = 0
        targets.each { |b| numFainted += 1 if b.damageState.fainted }
        if numFainted>0 && user.form==1
          @battle.battleBond[user.index&1][user.pokemonIndex] = true
          @battle.pbDisplay(_INTL("{1} became fully charged due to its bond with its Trainer!",user.pbThis))
          @battle.pbShowAbilitySplash(user,true)
          @battle.pbHideAbilitySplash(user)
          user.pbChangeForm(2,_INTL("{1} became Ash-Greninja!",user.pbThis))
        end
      end
    end
    # Consume user's Gem
    if user.effects[PBEffects::GemConsumed]
      # NOTE: The consume animation and message for Gems are shown immediately
      #       after the move's animation, but the item is only consumed now.
      user.pbConsumeItem
    end
    # Pokémon switching caused by Roar, Whirlwind, Circle Throw, Dragon Tail
    switchedBattlers = []
    move.pbSwitchOutTargetsEffect(user,targets,numHits,switchedBattlers)
    # Target's item, user's item, target's ability (all negated by Sheer Force)
    if move.addlEffect==0 || !user.hasActiveAbility?(:SHEERFORCE)
      pbEffectsAfterMove2(user,targets,move,numHits,switchedBattlers)
    end
    # Some move effects that need to happen here, i.e. U-turn/Volt Switch
    # switching, Baton Pass switching, Parting Shot switching, Relic Song's form
    # changing, Fling/Natural Gift consuming item.
    if !switchedBattlers.include?(user.index)
      move.pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
    end
    if numHits>0
      @battle.eachBattler { |b| b.pbItemEndOfMoveCheck }
    end
  end
  
  # Everything in this method is negated by Sheer Force.
  def pbEffectsAfterMove2(user,targets,move,numHits,switchedBattlers)
    hpNow = user.hp   # Intentionally determined now, before Shell Bell
    # Target's held item (Eject Button, Red Card)
    switchByItem = []
    @battle.pbPriority(true).each do |b|
      next if !targets.any? { |targetB| targetB.index==b.index }
      next if b.damageState.unaffected || b.damageState.calcDamage==0 ||
         switchedBattlers.include?(b.index)
      next if !b.itemActive?
      BattleHandlers.triggerTargetItemAfterMoveUse(b.item,b,user,move,switchByItem,@battle)
	  # Eject Pack
	  if b.effects[PBEffects::LashOut]
		BattleHandlers.triggerItemOnStatLoss(b.item,b,user,move,switchByItem,@battle)
	  end 
    end
    @battle.moldBreaker = false if switchByItem.include?(user.index)
    @battle.pbPriority(true).each do |b|
      b.pbEffectsOnSwitchIn(true) if switchByItem.include?(b.index)
    end
    switchByItem.each { |idxB| switchedBattlers.push(idxB) }
    # User's held item (Life Orb, Shell Bell)
    if !switchedBattlers.include?(user.index) && user.itemActive?
      BattleHandlers.triggerUserItemAfterMoveUse(user.item,user,targets,move,numHits,@battle)
    end
    # Target's ability (Berserk, Color Change, Emergency Exit, Pickpocket, Wimp Out)
    switchWimpOut = []
    @battle.pbPriority(true).each do |b|
      next if !targets.any? { |targetB| targetB.index==b.index }
      next if b.damageState.unaffected || switchedBattlers.include?(b.index)
      next if !b.abilityActive?
      BattleHandlers.triggerTargetAbilityAfterMoveUse(b.ability,b,user,move,switchedBattlers,@battle)
      if !switchedBattlers.include?(b.index) && move.damagingMove?
        if b.pbAbilitiesOnDamageTaken(b.damageState.initialHP)   # Emergency Exit, Wimp Out
          switchWimpOut.push(b.index)
        end
      end
    end
    @battle.moldBreaker = false if switchWimpOut.include?(user.index)
    @battle.pbPriority(true).each do |b|
      next if b.index==user.index
      b.pbEffectsOnSwitchIn(true) if switchWimpOut.include?(b.index)
    end
    switchWimpOut.each { |idxB| switchedBattlers.push(idxB) }
    # User's ability (Emergency Exit, Wimp Out)
    if !switchedBattlers.include?(user.index) && move.damagingMove?
      hpNow = user.hp if user.hp<hpNow   # In case HP was lost because of Life Orb
      if user.pbAbilitiesOnDamageTaken(user.initialHP,hpNow)
        @battle.moldBreaker = false
        user.pbEffectsOnSwitchIn(true)
        switchedBattlers.push(user.index)
      end
    end
  end
  
  #=============================================================================
  # Attack a single target
  #=============================================================================
  def pbProcessMoveHit(move,user,targets,hitNum,skipAccuracyCheck)
    return false if user.fainted?
    # For two-turn attacks being used in a single turn
    move.pbInitialEffect(user,targets,hitNum)
    numTargets = 0   # Number of targets that are affected by this hit
    targets.each { |b| b.damageState.resetPerHit }
    # Count a hit for Parental Bond (if it applies)
    user.effects[PBEffects::ParentalBond] -= 1 if user.effects[PBEffects::ParentalBond]>0
    # Accuracy check (accuracy/evasion calc)
    if hitNum==0 || move.successCheckPerHit?
      targets.each do |b|
        next if b.damageState.unaffected
        if pbSuccessCheckPerHit(move,user,b,skipAccuracyCheck)
          numTargets += 1
        else
          b.damageState.missed     = true
          b.damageState.unaffected = true
        end
      end
      # If failed against all targets
      if targets.length>0 && numTargets==0 && !move.worksWithNoTargets?
        targets.each do |b|
          next if !b.damageState.missed || b.damageState.magicCoat
          pbMissMessage(move,user,b)
        end
        move.pbCrashDamage(user)
        user.pbItemHPHealCheck
        pbCancelMoves
        return false
      end
    end
    # If we get here, this hit will happen and do something
    #---------------------------------------------------------------------------
    # Calculate damage to deal
    if move.pbDamagingMove?
      targets.each do |b|
        next if b.damageState.unaffected
        # Check whether Substitute/Disguise will absorb the damage
        move.pbCheckDamageAbsorption(user,b)
        # Calculate the damage against b
        # pbCalcDamage shows the "eat berry" animation for SE-weakening
        # berries, although the message about it comes after the additional
        # effect below
        move.pbCalcDamage(user,b,targets.length)   # Stored in damageState.calcDamage
        # Lessen damage dealt because of False Swipe/Endure/etc.
        move.pbReduceDamage(user,b)   # Stored in damageState.hpLost
      end
    end
    # Show move animation (for this hit)
    move.pbShowAnimation(move.id,user,targets,hitNum)
    # Type-boosting Gem consume animation/message
    if user.effects[PBEffects::GemConsumed] && hitNum==0
      # NOTE: The consume animation and message for Gems are shown now, but the
      #       actual removal of the item happens in def pbEffectsAfterMove.
      @battle.pbCommonAnimation("UseItem",user)
      @battle.pbDisplay(_INTL("The {1} strengthened {2}'s power!",
         GameData::Item.get(user.effects[PBEffects::GemConsumed]).name,move.name))
    end
    # Messages about missed target(s) (relevant for multi-target moves only)
    targets.each do |b|
      next if !b.damageState.missed
      pbMissMessage(move,user,b)
    end
    # Deal the damage (to all allies first simultaneously, then all foes
    # simultaneously)
    if move.pbDamagingMove?
      # This just changes the HP amounts and does nothing else
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbInflictHPDamage(b)
      end
      # Animate the hit flashing and HP bar changes
      move.pbAnimateHitAndHPLost(user,targets)
    end
    # Self-Destruct/Explosion's damaging and fainting of user
    move.pbSelfKO(user) if hitNum==0
    user.pbFaint if user.fainted?
    if move.pbDamagingMove?
      targets.each do |b|
        next if b.damageState.unaffected
        # NOTE: This method is also used for the OKHO special message.
        move.pbHitEffectivenessMessages(user,b,targets.length)
        # Record data about the hit for various effects' purposes
        move.pbRecordDamageLost(user,b)
      end
      # Close Combat/Superpower's stat-lowering, Flame Burst's splash damage,
      # and Incinerate's berry destruction
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbEffectWhenDealingDamage(user,b)
      end
      # Ability/item effects such as Static/Rocky Helmet, and Grudge, etc.
      targets.each do |b|
        next if b.damageState.unaffected
        pbEffectsOnMakingHit(move,user,b)
      end
      # Disguise/Endure/Sturdy/Focus Sash/Focus Band messages
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbEndureKOMessage(b)
      end
      # HP-healing held items (checks all battlers rather than just targets
      # because Flame Burst's splash damage affects non-targets)
      @battle.pbPriority(true).each { |b| b.pbItemHPHealCheck }
      # Animate battlers fainting (checks all battlers rather than just targets
      # because Flame Burst's splash damage affects non-targets)
      @battle.pbPriority(true).each { |b| b.pbFaint if b && b.fainted? }
    end
    @battle.pbJudgeCheckpoint(user,move)
    # Main effect (recoil/drain, etc.)
    targets.each do |b|
      next if b.damageState.unaffected
      move.pbEffectAgainstTarget(user,b)
    end
    move.pbEffectGeneral(user)
    targets.each { |b| b.pbFaint if b && b.fainted? }
    user.pbFaint if user.fainted?
    # Additional effect
    if !user.hasActiveAbility?(:SHEERFORCE)
      targets.each do |b|
        next if b.damageState.calcDamage==0
        chance = move.pbAdditionalEffectChance(user,b)
        next if chance<=0
        if @battle.pbRandom(100)<chance
          move.pbAdditionalEffect(user,b)
        end
      end
    end
    # Make the target flinch (because of an item/ability)
    targets.each do |b|
      next if b.fainted?
      next if b.damageState.calcDamage==0 || b.damageState.substitute
      chance = move.pbFlinchChance(user,b)
      next if chance<=0
      if @battle.pbRandom(100)<chance
        PBDebug.log("[Item/ability triggered] #{user.pbThis}'s King's Rock/Razor Fang or Stench")
        b.pbFlinch(user)
      end
    end
    # Message for and consuming of type-weakening berries
    # NOTE: The "consume held item" animation for type-weakening berries occurs
    #       during pbCalcDamage above (before the move's animation), but the
    #       message about it only shows here.
    targets.each do |b|
      next if b.damageState.unaffected
      next if !b.damageState.berryWeakened
      @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",b.itemName,b.pbThis(true)))
      b.pbConsumeItem
    end
    targets.each { |b| b.pbFaint if b && b.fainted? }
    user.pbFaint if user.fainted?
    return true
  end
end

module BallHandlers
	def self.modifyCatchRate(ball,catchRate,battle,battler,ultraBeast)
		ret = ModifyCatchRate.trigger(ball,catchRate,battle,battler,ultraBeast)
		pseudoBonus = [1.0+(0.1*battle.ballsUsed),4].min
		return (ret!=nil) ? (ret * pseudoBonus) : (catchRate * pseudoBonus)
	end
	
	def self.onCatch(ball,battle,pkmn)
		battle.ballsUsed = 0
		OnCatch.trigger(ball,battle,pkmn)
	end
	
	def self.onFailCatch(ball,battle,battler)
		battle.ballsUsed += 1
		OnFailCatch.trigger(ball,battle,battler)
	end
end

=begin
GameData::Status.register({
  :id        => :CHARMED,
  :id_number => 6,
  :name      => _INTL("Charmed"),
  :animation => "Charmed"
})
=end

# Burn party Pokémon
Events.onStepTakenTransferPossible += proc { |_sender,e|
  handled = e[0]
  next if handled[0]
  if $PokemonGlobal.stepcount%4==0 && Settings::POISON_IN_FIELD
    flashed = false
    for i in $Trainer.able_party
      if i.status == :BURN && !i.hasAbility?(:WATERVEIL)
        if !flashed
          $game_screen.start_flash(Color.new(255,119,0,128), 4)
          flashed = true
        end
        i.hp -= 1 if i.hp>1 || Settings::POISON_FAINT_IN_FIELD
        if i.hp==1 && !Settings::POISON_FAINT_IN_FIELD
          i.status = :NONE
          pbMessage(_INTL("{1} survived the burn.\\nThe burn was healed!\1",i.name))
          next
        elsif i.hp==0
          i.changeHappiness("faint")
          i.status = :NONE
          pbMessage(_INTL("{1} fainted...",i.name))
		  refreshFollow()
        end
        if $Trainer.able_pokemon_count == 0
          handled[0] = true
          pbCheckAllFainted
        end
      end
    end
  end
}


class Pokemon
  # @return [GameData::Nature, nil] a Nature object corresponding to this Pokémon's nature
  def nature
    @nature = GameData::Nature.get(0).id
    return GameData::Nature.try_get(@nature)
  end

# Recalculates this Pokémon's stats.
  def calc_stats
    base_stats = self.baseStats
    this_level = self.level
    this_IV    = self.calcIV
    # Calculate stats
    stats = {}
    GameData::Stat.each_main do |s|
      if s.id == :HP
        stats[s.id] = calcHP(base_stats[s.id], this_level, @ev[s.id])
		if boss
			if $game_variables[96].is_a?(Hash)
				stats[s.id]	*= $game_variables[96][@species]
			else
				stats[s.id]	*= $game_variables[96]
			end
		end
      else
        stats[s.id] = calcStat(base_stats[s.id], this_level, @ev[s.id], )
      end
    end
    hpDiff = @totalhp - @hp
    @totalhp = stats[:HP]
    @hp      = (fainted? ? 0 : (@totalhp - hpDiff))
    @attack  = stats[:ATTACK]
    @defense = stats[:DEFENSE]
    @spatk   = stats[:SPECIAL_ATTACK]
    @spdef   = stats[:SPECIAL_DEFENSE]
    @speed   = stats[:SPEED]
  end
end


#
# Hyper effectiveness
#

module Effectiveness

	module_function

	def hyper_effective?(value)
		return value > NORMAL_EFFECTIVE * 2
	end

	def hyper_effective_type?(attack_type,defend_type1=nil,defend_type2=nil,defend_type3=nil)
		return attack_type>NORMAL_EFFECTIVE * 2 if !defend_type1
		value = calculate(attack_type, target_type1, target_type2, target_type3)
		return hyper_effective?(value)
	  end
end


class PokeBattle_Move
  #=============================================================================
  # Animate the damage dealt, including lowering the HP
  #=============================================================================
  # Animate being damaged and losing HP (by a move)
  def pbAnimateHitAndHPLost(user,targets)
    # Animate allies first, then foes
    animArray = []
    for side in 0...2   # side here means "allies first, then foes"
      targets.each do |b|
        next if b.damageState.unaffected || b.damageState.hpLost==0
        next if (side==0 && b.opposes?(user)) || (side==1 && !b.opposes?(user))
        oldHP = b.hp+b.damageState.hpLost
        PBDebug.log("[Move damage] #{b.pbThis} lost #{b.damageState.hpLost} HP (#{oldHP}=>#{b.hp})")
        effectiveness = 0
        if Effectiveness.resistant?(b.damageState.typeMod);          effectiveness = 1
        elsif Effectiveness.super_effective?(b.damageState.typeMod); effectiveness = 2
        end
		effectiveness = -1 if Effectiveness.ineffective?(b.damageState.typeMod)
        effectiveness = 4 if Effectiveness.hyper_effective?(b.damageState.typeMod)
        animArray.push([b,oldHP,effectiveness])
      end
      if animArray.length>0
        @battle.scene.pbHitAndHPLossAnimation(animArray)
        animArray.clear
      end
    end
  end

  #=============================================================================
  # Messages upon being hit
  #=============================================================================
  def pbEffectivenessMessage(user,target,numTargets=1)
    return if target.damageState.disguise
	if Effectiveness.hyper_effective?(target.damageState.typeMod)
	  if numTargets>1
        @battle.pbDisplay(_INTL("It's hyper effective on {1}!",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's hyper effective!"))
      end
    elsif Effectiveness.super_effective?(target.damageState.typeMod)
      if numTargets>1
        @battle.pbDisplay(_INTL("It's super effective on {1}!",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's super effective!"))
      end
    elsif Effectiveness.not_very_effective?(target.damageState.typeMod)
      if numTargets>1
        @battle.pbDisplay(_INTL("It's not very effective on {1}...",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
    end
  end
end


module BattleHandlers
	AbilityOnEnemySwitchIn              = AbilityHandlerHash.new

	def self.triggerAbilityOnEnemySwitchIn(ability,switcher,bearer,battle)
		AbilityOnEnemySwitchIn.trigger(ability,switcher,bearer,battle)
	end
end

class PokeBattle_ActiveField
    class PokeBattle_ActiveField
    attr_accessor :effects
    attr_accessor :defaultWeather
    attr_accessor :weather
    attr_accessor :weatherDuration
    attr_accessor :defaultTerrain
    attr_accessor :terrain
    attr_accessor :terrainDuration

    def initialize
      @effects = []
      @effects[PBEffects::AmuletCoin]      = false
      @effects[PBEffects::FairyLock]       = 0
      @effects[PBEffects::FusionBolt]      = false
      @effects[PBEffects::FusionFlare]     = false
      @effects[PBEffects::Gravity]         = 0
      @effects[PBEffects::HappyHour]       = false
      @effects[PBEffects::IonDeluge]       = false
      @effects[PBEffects::MagicRoom]       = 0
      @effects[PBEffects::MudSportField]   = 0
      @effects[PBEffects::PayDay]          = 0
      @effects[PBEffects::TrickRoom]       = 0
      @effects[PBEffects::WaterSportField] = 0
      @effects[PBEffects::WonderRoom]      = 0
	  @effects[PBEffects::Fortune]      = 0
      @defaultWeather  = :None
      @weather         = :None
      @weatherDuration = 0
      @defaultTerrain  = :None
      @terrain         = :None
      @terrainDuration = 0
    end
  end
end

module PBEffects
	#===========================================================================
    # These effects apply to a battler
    #===========================================================================
	Yawn                = 113
    GorillaTactics      = 114
    BallFetch           = 115
    LashOut             = 118
    BurningJealousy     = 119
    NoRetreat           = 120
    Obstruct            = 121
    JawLock             = 122
    JawLockUser         = 123
    TarShot             = 124
    Octolock            = 125
    OctolockUser        = 126
    BlunderPolicy       = 127
    SwitchedAlly        = 128
    Sentry              = 129
    Assist              = 130
    ConfusionChance     = 131
    FlinchedAlready     = 132
	Enlightened			= 133
	ColdConversion		= 134
	CreepOut		 	= 135
	LuckyStar			= 136
	Charm				= 137
	CharmChance			= 138
	Inured				= 139
	NoRetreat			= 140
	
	#===========================================================================
    # These effects apply to a side
    #===========================================================================
	Fortune = 13
end

#===============================================================================
# Shows a Pokémon flashing after taking damage
#===============================================================================
class BattlerDamageAnimation < PokeBattle_Animation
	 def createProcesses
    batSprite = @sprites["pokemon_#{@idxBattler}"]
    shaSprite = @sprites["shadow_#{@idxBattler}"]
    # Set up battler/shadow sprite
    battler = addSprite(batSprite,PictureOrigin::Bottom)
    shadow  = addSprite(shaSprite,PictureOrigin::Center)
    # Animation
    delay = 0
    case @effectiveness
    when 0 then battler.setSE(delay, "Battle damage normal")
    when 1 then battler.setSE(delay, "Battle damage weak")
    when 2 then battler.setSE(delay, "Battle damage super")
	when 4 then battler.setSE(delay, "Battle damage hyper")
    end
    4.times do   # 4 flashes, each lasting 0.2 (4/20) seconds
      battler.setVisible(delay,false)
      shadow.setVisible(delay,false)
      battler.setVisible(delay+2,true) if batSprite.visible
      shadow.setVisible(delay+2,true) if shaSprite.visible
      delay += 4
    end
    # Restore original battler/shadow sprites visibilities
    battler.setVisible(delay,batSprite.visible)
    shadow.setVisible(delay,shaSprite.visible)
  end
end

module BattleHandlers
	ItemOnStatLoss                      = ItemHandlerHash.new

	def self.triggerItemOnStatLoss(item,battler,user,move,switched,battle)
		ItemOnStatLoss.trigger(item,battler,user,move,switched,battle)
	end
end