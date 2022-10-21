class PokeBattle_Battler
  # Fundamental to this object
  attr_reader   :battle
  attr_accessor :index
  # The Pokémon and its properties
  attr_reader   :pokemon
  attr_accessor :pokemonIndex
  attr_accessor :species
  attr_accessor :type1
  attr_accessor :type2
  attr_accessor :ability_id
  attr_accessor :item_id
  attr_accessor :moves
  attr_accessor :gender
  attr_accessor :iv
  attr_accessor :attack
  attr_accessor :spatk
  attr_accessor :speed
  attr_accessor :stages
  attr_reader   :totalhp
  attr_reader   :fainted    # Boolean to mark whether self has fainted properly
  attr_accessor :captured   # Boolean to mark whether self was captured
  attr_reader   :dummy
  attr_accessor :effects
  attr_accessor 	:boss
	attr_accessor 	:avatarPhase
	attr_accessor	  :extraMovesPerTurn
	attr_accessor 	:primevalTimer
	attr_accessor	  :indexesTargetedThisTurn
	attr_accessor	  :dmgMult
	attr_accessor	  :dmgResist
  # Things the battler has done in battle
  attr_accessor :turnCount
  attr_accessor :participants
  attr_accessor :lastAttacker
  attr_accessor :lastFoeAttacker
  attr_accessor :lastHPLost
  attr_accessor :lastHPLostFromFoe
  attr_accessor :lastMoveUsed
  attr_accessor :lastMoveUsedType
  attr_accessor :lastRegularMoveUsed
  attr_accessor :lastRegularMoveTarget   # For Instruct
  attr_accessor :lastRoundMoved
  attr_accessor :lastMoveFailed        # For Stomping Tantrum
  attr_accessor :lastRoundMoveFailed   # For Stomping Tantrum
  attr_accessor :movesUsed
  attr_accessor :currentMove   # ID of multi-turn move currently being used
  attr_accessor :tookDamage    # Boolean for whether self took damage this round
  attr_accessor :tookPhysicalHit
  attr_accessor :damageState
  attr_accessor :initialHP     # Set at the start of each move's usage
  attr_accessor	:lastRoundHighestTypeModFromFoe

  #=============================================================================
  # Complex accessors
  #=============================================================================
  attr_reader :level

  def level=(value)
    @level = value
    @pokemon.level = value if @pokemon
  end

  attr_reader :form

  def form=(value)
    @form = value
    @pokemon.form = value if @pokemon
  end

  def ability
    return GameData::Ability.try_get(@ability_id)
  end

  def ability=(value)
    new_ability = GameData::Ability.try_get(value)
    @ability_id = (new_ability) ? new_ability.id : nil
  end

  def item
    return GameData::Item.try_get(@item_id)
  end

  def item=(value)
    new_item = GameData::Item.try_get(value)
    @item_id = (new_item) ? new_item.id : nil
    @pokemon.item = @item_id if @pokemon
  end

  def defense
    return @spdef if @battle.field.effects[PBEffects::WonderRoom]>0
    return @defense
  end

  attr_writer :defense

  def spdef
    return @defense if @battle.field.effects[PBEffects::WonderRoom]>0
    return @spdef
  end

  attr_writer :spdef

  attr_reader :hp

  def hp=(value)
    @hp = value.to_i
    @pokemon.hp = value.to_i if @pokemon
  end

  def fainted?; return @hp<=0; end
  alias isFainted? fainted?

  attr_reader :status

  def status=(value)
    @effects[PBEffects::Truant] = false if @status == :SLEEP && value != :SLEEP
    @effects[PBEffects::Toxic]  = 0 if value != :POISON
    @status = value
    @pokemon.status = value if @pokemon
    self.statusCount = 0 if value != :POISON && value != :SLEEP
    @battle.scene.pbRefreshOne(@index)
  end

  attr_reader :statusCount

  def statusCount=(value)
    @statusCount = value
    @pokemon.statusCount = value if @pokemon
    @battle.scene.pbRefreshOne(@index)
  end
  
  	attr_reader 	  :bossStatus
  
  	def bossStatus=(value)
		@effects[PBEffects::Truant] = false if @bossStatus == :SLEEP && value != :SLEEP
		@bossStatus = value
		@bossStatusCount = 0 if value != :SLEEP
		@battle.scene.pbRefreshOne(@index)
	end
	
	attr_reader 	  :bossStatusCount
	
	def bossStatusCount=(value)
		@bossStatusCount = value
		@battle.scene.pbRefreshOne(@index)
	end
	
	def extraMovesPerTurn
		val = @pokemon.extraMovesPerTurn || 0
		val += effects[PBEffects::ExtraTurns]
		return val
	end

	def extraMovesPerTurn=(val)
		@pokemon.extraMovesPerTurn = val
	end

  #=============================================================================
  # Properties from Pokémon
  #=============================================================================
  def happiness;    return @pokemon ? @pokemon.happiness : 0;    end
  def nature;       return @pokemon ? @pokemon.nature : 0;       end
  def pokerusStage; return @pokemon ? @pokemon.pokerusStage : 0; end
	def boss?;        return boss; end

  #=============================================================================
  # Display-only properties
  #=============================================================================
  def name
    return @effects[PBEffects::Illusion].name if @effects[PBEffects::Illusion]
    return @name
  end

  attr_writer :name

  def displayPokemon
    return @effects[PBEffects::Illusion] if @effects[PBEffects::Illusion]
    return self.pokemon
  end

  def displaySpecies
    return @effects[PBEffects::Illusion].species if @effects[PBEffects::Illusion]
    return self.species
  end

  def displayGender
    return @effects[PBEffects::Illusion].gender if @effects[PBEffects::Illusion]
    return self.gender
  end

  def displayForm
    return @effects[PBEffects::Illusion].form if @effects[PBEffects::Illusion]
    return self.form
  end

  def shiny?
		return false if boss?
		return @effects[PBEffects::Illusion].shiny? if @effects[PBEffects::Illusion]
		return @pokemon && @pokemon.shiny?
	end
  alias isShiny? shiny?

  def owned?
    return false if !@battle.wildBattle?
    return $Trainer.owned?(displaySpecies)
  end
  alias owned owned?

  def abilityName
    abil = self.ability
    return (abil) ? abil.name : ""
  end

  def itemName
    itm = self.item
    return (itm) ? itm.name : ""
  end

  def pbThis(lowerCase=false)
		if opposes?
			if @battle.trainerBattle?
				return lowerCase ? _INTL("the opposing {1}",name) : _INTL("The opposing {1}",name)
			else
				if !boss?
					return lowerCase ? _INTL("the wild {1}",name) : _INTL("The wild {1}",name)
				else
					return lowerCase ? _INTL("the avatar of {1}",name) : _INTL("The avatar of {1}",name)
				end
			end
		elsif !pbOwnedByPlayer?
			return lowerCase ? _INTL("the ally {1}",name) : _INTL("The ally {1}",name)
		end
		return name
	end

  def pbTeam(lowerCase=false)
    if opposes?
      return lowerCase ? _INTL("the opposing team") : _INTL("The opposing team")
    end
    return lowerCase ? _INTL("your team") : _INTL("Your team")
  end

  def pbOpposingTeam(lowerCase=false)
    if opposes?
      return lowerCase ? _INTL("your team") : _INTL("Your team")
    end
    return lowerCase ? _INTL("the opposing team") : _INTL("The opposing team")
  end

  #=============================================================================
  # Calculated properties
  #=============================================================================
  def pbWeight
    ret = (@pokemon) ? @pokemon.weight : 500
    ret += @effects[PBEffects::WeightChange]
    ret = 1 if ret<1
    if abilityActive? && !@battle.moldBreaker
      ret = BattleHandlers.triggerWeightCalcAbility(self.ability,self,ret)
    end
    if itemActive?
      ret = BattleHandlers.triggerWeightCalcItem(self.item,self,ret)
    end
    return [ret,1].max
  end

  def pbHeight
    ret = (@pokemon) ? @pokemon.height : 2.0
    ret = 1 if ret<1
    return ret
  end
end
