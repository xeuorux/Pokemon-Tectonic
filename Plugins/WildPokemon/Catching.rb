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

module PokeBattle_BattleCommon
  #=============================================================================
  # Calculate how many shakes a thrown Poké Ball will make (4 = capture)
  #=============================================================================
  def pbCaptureCalc(pkmn,battler,catch_rate,ball)
    return 4 if $DEBUG && Input.press?(Input::CTRL)
	y = captureThresholdCalc(pkmn,battler,catch_rate,ball)
	# Critical capture check
	if Settings::ENABLE_CRITICAL_CAPTURES
	  x = captureThresholdCalcHalf(pkmn,battler,catch_rate,ball)
      c = 0
      numOwned = $Trainer.pokedex.owned_count
      if numOwned>600;    c = x*5/12
      elsif numOwned>450; c = x*4/12
      elsif numOwned>300; c = x*3/12
      elsif numOwned>150; c = x*2/12
      elsif numOwned>50;  c = x/12
      end
      # Calculate the number of shakes
      if c>0 && pbRandom(256)<c
        @criticalCapture = true
        return 4 if pbRandom(65536)<y
        return 0
      end
    end
    # Calculate the number of shakes
    numShakes = 0
    for i in 0...4
      break if numShakes<i
      numShakes += 1 if pbRandom(65536)<y
    end
    return numShakes
  end
  
  def captureThresholdCalc(pkmn,battler,catch_rate,ball)
    x = captureThresholdCalcHalf(pkmn,battler,catch_rate,ball)
    # Second half of the shakes calculation
	y = ( 65536 / ((255.0/x)**0.1875) ).floor
    return y
  end
  
  def captureThresholdCalcHalf(pkmn,battler,catch_rate,ball)
	# Get a catch rate if one wasn't provided
    catch_rate = pkmn.species_data.catch_rate if !catch_rate
    # Modify catch_rate depending on the Poké Ball's effect
    ultraBeast = [:NIHILEGO, :BUZZWOLE, :PHEROMOSA, :XURKITREE, :CELESTEELA,
                  :KARTANA, :GUZZLORD, :POIPOLE, :NAGANADEL, :STAKATAKA,
                  :BLACEPHALON].include?(pkmn.species)
    if !ultraBeast || ball == :BEASTBALL
      catch_rate = BallHandlers.modifyCatchRate(ball,catch_rate,self,battler,ultraBeast)
    else
		# All balls but the beast ball have a 1/10 chance to catch Ultra Beasts
      catch_rate /= 10
    end
    # First half of the shakes calculation
    a = battler.totalhp
    b = battler.hp
    x = ((3*a-2*b)*catch_rate.to_f)/(3*a)
    # Calculation modifiers
    if battler.status == :SLEEP
      x *= 2.5
    elsif battler.status != :NONE
      x *= 1.5
    end
    x = x.floor
    x = 1 if x<1
	return x
  end
  
  def captureChanceCalc(pkmn,battler,catch_rate,ball)
	y = captureThresholdCalc(pkmn,battler,catch_rate,ball)
	chancePerShake = y.to_f/65536.0
	overallChance = chancePerShake ** 4
	return overallChance
  end
end