class PokeBattle_Battle
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
          if @choices[b.index][0] == :UseMove
            move = @choices[b.index][2]
            pri = move.priority
            targets = b.pbFindTargets(@choices[b.index],move,b)
            if b.abilityActive?
              abilityPriorityChange = BattleHandlers.triggerPriorityChangeAbility(b.ability,b,move,0,targets)
              if abilityPriorityChange > 0
                pri = [pri + pri, 1].max
              end
            end
			      pri += move.priorityModification(b,targets)
            pri -= 1 if (pbCheckGlobalAbility(:HONORAURA) && move.statusMove?)
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
end