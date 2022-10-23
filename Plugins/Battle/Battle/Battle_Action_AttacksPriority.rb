class PokeBattle_Battle
      # Called when the Pokémon is Encored, or if it can't use any of its moves.
    # Makes the Pokémon use the Encored move (if Encored), or Struggle.
    def pbAutoChooseMove(idxBattler,showMessages=true)
      battler = @battlers[idxBattler]
      if battler.fainted?
          pbClearChoice(idxBattler)
          return true
      end
      # Encore
      idxEncoredMove = battler.pbEncoredMoveIndex
      if idxEncoredMove >= 0 && pbCanChooseMove?(idxBattler,idxEncoredMove,false)
          encoreMove = battler.moves[idxEncoredMove]
          @choices[idxBattler][0] = :UseMove         # "Use move"
          @choices[idxBattler][1] = idxEncoredMove   # Index of move to be used
          @choices[idxBattler][2] = encoreMove       # PokeBattle_Move object
          @choices[idxBattler][3] = -1               # No target chosen yet
          return true if singleBattle?
          if pbOwnedByPlayer?(idxBattler)
              if showMessages
                  pbDisplayPaused(_INTL("{1} has to use {2}!",battler.name,encoreMove.name))
              end
              return pbChooseTarget(battler,encoreMove)
          end
          return true
      end
      # Struggle
      if pbOwnedByPlayer?(idxBattler) && showMessages
          pbDisplayPaused(_INTL("{1} has no moves left!",battler.name))
      end
      @choices[idxBattler][0] = :UseMove    # "Use move"
      @choices[idxBattler][1] = -1          # Index of move to be used
      @choices[idxBattler][2] = @struggle   # Struggle PokeBattle_Move object
      @choices[idxBattler][3] = -1          # No target chosen yet
      return true
  end

  #=============================================================================
  # Turn order calculation (priority)
  #=============================================================================
  def pbCalculatePriority(fullCalc=false,indexArray=nil)
    needRearranging = false
    if fullCalc
      @priorityTrickRoom = @field.effectActive?(:TrickRoom)
      # Recalculate everything from scratch
      randomOrder = Array.new(maxBattlerIndex+1) { |i| i }
      (randomOrder.length-1).times do |i|   # Can't use shuffle! here
        r = i+pbRandom(randomOrder.length-i)
        randomOrder[i], randomOrder[r] = randomOrder[r], randomOrder[i]
      end
	  honorAura = false
      @priority.clear
	  for i in 0..maxBattlerIndex
		b = @battlers[i]
		next if !b
		honorAura = true if b.hasHonorAura?
	  end
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
			pri -= 1 if (self.pbCheckGlobalAbility(:HONORAURA) && move.statusMove?)
			targets = b.pbFindTargets(@choices[b.index],move,b)
            if b.abilityActive?
              pri = BattleHandlers.triggerPriorityChangeAbility(b.ability,b,move,pri,targets)
            end
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
	  honorAura = false
    else
      if @field.effectActive?(:TrickRoom) != @priorityTrickRoom
        needRearranging = true
        @priorityTrickRoom = @field.effectActive?(:TrickRoom)
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
end