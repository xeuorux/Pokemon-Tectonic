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

CATCH_BASE_CHANCE = 65536

module PokeBattle_BattleCommon
  #=============================================================================
  # Calculate how many shakes a thrown Poké Ball will make (4 = capture)
  #=============================================================================
  def pbCaptureCalc(pkmn,battler,catch_rate,ball)
    return 4 if $DEBUG && Input.press?(Input::CTRL)
	y = captureThresholdCalc(pkmn,battler,catch_rate,ball)
	# Critical capture check
	if Settings::ENABLE_CRITICAL_CAPTURES
      c = 0
      numOwned = $Trainer.pokedex.owned_count
      if numOwned>600;    c = 20
      elsif numOwned>450; c = 16
      elsif numOwned>300; c = 12
      elsif numOwned>150; c = 8
      elsif numOwned>50;  c = 4
      end
      # Calculate the number of shakes
      if c>0 && pbRandom(100)<c
        @criticalCapture = true
        return 4 if pbRandom(CATCH_BASE_CHANCE)<y
        return 0
      end
    end
    # Calculate the number of shakes
    numShakes = 0
    for i in 0...4
      break if numShakes<i
      numShakes += 1 if pbRandom(CATCH_BASE_CHANCE)<y
    end
    return numShakes
  end
  
  def captureThresholdCalc(pkmn,battler,catch_rate,ball)
	# Get a catch rate if one wasn't provided
    catch_rate = pkmn.species_data.catch_rate if !catch_rate
    ultraBeast = [:NIHILEGO, :BUZZWOLE, :PHEROMOSA, :XURKITREE, :CELESTEELA,
                  :KARTANA, :GUZZLORD, :POIPOLE, :NAGANADEL, :STAKATAKA,
                  :BLACEPHALON].include?(pkmn.species)
	if !ultraBeast || ball == :BEASTBALL
      catch_rate = BallHandlers.modifyCatchRate(ball,catch_rate,self,battler,ultraBeast)
    else
		# All balls but the beast ball have a 1/10 chance to catch Ultra Beasts
      catch_rate /= 10
    end
    return captureThresholdCalcInternals(battler.status,battler.hp,battler.totalhp,catch_rate)
  end
  
  def captureChanceCalc(pkmn,battler,catch_rate,ball)
	y = captureThresholdCalc(pkmn,battler,catch_rate,ball)
	chancePerShake = y.to_f/CATCH_BASE_CHANCE.to_f
	overallChance = chancePerShake ** 4
	return overallChance
  end
end

def captureThresholdCalcInternals(status,current_hp,total_hp,catch_rate)
    # First half of the shakes calculation
    x = ((3 * total_hp - 2 * current_hp) * catch_rate.to_f)/(3 * total_hp)
	
    # Calculation modifiers
    if status == :SLEEP
      x *= 2.5
    elsif status != :NONE
      x *= 1.5
    end
    x = x.floor
    x = 1 if x<1
	
	# Second half of the shakes calculation
	y = ( CATCH_BASE_CHANCE / ((255.0/x)**0.1875) ).floor
	return y
end