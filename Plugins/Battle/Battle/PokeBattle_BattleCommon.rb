class PokeBattle_Battle
	def pbCheckNeutralizingGas(battler=nil)
    # Battler = the battler to switch out. 
	# Should be specified when called from pbAttackPhaseSwitch
	# Should be nil when called from pbEndOfRoundPhase
    return if !@field.effects[PBEffects::NeutralizingGas]
    return if battler && (battler.ability != :NEUTRALIZINGGAS || 
		battler.effects[PBEffects::GastroAcid])
    hasabil=false
    eachBattler {|b|
      next if !b || b.fainted?
	  next if battler && b.index == battler.index 
	  # if specified, the battler will switch out, so don't consider it.
      # neutralizing gas can be blocked with gastro acid, ending the effect.
      if b.ability == :NEUTRALIZINGGAS && !b.effects[PBEffects::GastroAcid]
        hasabil=true; break
      end
    }
    if !hasabil
      @field.effects[PBEffects::NeutralizingGas] = false
      pbPriority(true).each { |b| 
	    next if battler && b.index == battler.index
	    b.pbEffectsOnSwitchIn
	  }
    end
  end 
end