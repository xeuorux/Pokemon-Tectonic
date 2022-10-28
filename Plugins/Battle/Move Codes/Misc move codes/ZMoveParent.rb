#===============================================================================
# PokeBattle_ZMove child class
#===============================================================================
class PokeBattle_ZMove < PokeBattle_Move
    attr_reader :oldmove, :oldname, :status
  
    def initialize(battle, move, newMove=nil)
      validate move => PokeBattle_Move
      super(battle, newMove)
      @oldmove    = move
      @status     = @oldmove.statusMove?
      newMove_cat = GameData::Move.get(newMove.id).category
      @category   = (newMove_cat==2) ? 2 : move.category
      @baseDamage = pbZMoveBaseDamage(move) if @baseDamage==1 && @category<2
      @oldname    = move.name
      if @status
        @flags    + "z" if !zMove?
        @name     = "Z-" + move.name
        @oldmove.name = @name
      end 
      @short_name = (@name.length > 15 && Settings::SHORTEN_MOVES) ? @name[0..12] + "..." : @name
    end
    
    #-----------------------------------------------------------------------------
    # Gets a battler's Z-Move based on the inputted move and Z-Crystal.
    #-----------------------------------------------------------------------------
    def PokeBattle_ZMove.from_base_move(battle, battler, move)
      return move if move.is_a?(PokeBattle_ZMove)
      species = battler.transformed? ? battler.effects[:TransformPokemon].species_data.id : nil
      z_compat  = battler.pokemon.compat_zmove?(move, nil, species)
      newMove   = nil
      if !z_compat || move.statusMove?
        newMove    = Pokemon::Move.new(move.id)
        newMove.pp = 1 
        return PokeBattle_ZMove.new(battle, move, newMove)
      end
      z_move_id    = battler.pokemon.get_zmove(move)
      newMove      = Pokemon::Move.new(z_move_id)
      moveFunction = newMove.function_code || "Z000"
      className    = sprintf("PokeBattle_Move_%s",moveFunction)
      if Object.const_defined?(className)
        return Object.const_get(className).new(battle, move, newMove)
      end
      return PokeBattle_ZMove.new(battle, move, newMove)
    end
    
    #-----------------------------------------------------------------------------
    # Uses a Z-Move. Status moves have the Z-Move flag added to them.
    #-----------------------------------------------------------------------------
    def pbUse(battler, simplechoice=nil, specialUsage=false)
      battler.pbBeginTurn(self)
      zchoice = @battle.choices[battler.index]
      if simplechoice
        zchoice = simplechoice
      end
      @specialUseZMove = specialUsage
      # Targeted status Z-Moves here.
      if @status
        oldpkmn    = battler.pokemon
        zchoice[2] = @oldmove
        oldflags   = zchoice[2].flags
        zchoice[2].flags = oldflags + "z"
        battler.pbUseMove(zchoice, specialUsage)
        if !battler.fainted? && battler.pokemon==oldpkmn
          zchoice[2].flags = oldflags
          @oldmove.name = @oldname
        end
      else
        zchoice[2] = self
        battler.pbUseMove(zchoice, specialUsage)
      end
    end
    
    #-----------------------------------------------------------------------------
    # Protection moves don't fully negate Z-Moves.
    #-----------------------------------------------------------------------------
    def pbModifyDamage(damageMult, user, target)
      if target.protectedAgainst?(user,self)
        @battle.pbDisplay(_INTL("{1} couldn't fully protect itself!",target.pbThis))
        return damageMult/4
      else      
        return damageMult
      end    
    end
    
    #-----------------------------------------------------------------------------
    # Abilities that change move type aren't triggered by Z-Moves.
    #-----------------------------------------------------------------------------
    def pbBaseType(user)
      return @type if !@status
      return super(user)
    end
    
    #=============================================================================
    # Converts move's power into Z-Move power.
    #=============================================================================
    def pbZMoveBaseDamage(oldmove)
      if @status
        return 0
      #---------------------------------------------------------------------------
      # Becomes Z-Move with 180 BP (OHKO moves).
      #---------------------------------------------------------------------------
      elsif oldmove.function == "070"
        return 180 
      end 
      #---------------------------------------------------------------------------
      # Specific moves with specific values.
      #--------------------------------------------------------------------------- 
      case @oldmove.id
      when :WEATHERBALL  
        return 160
      when :HEX,:CRUELTY
        return 160
      when :GEARGRIND  
        return 180
      when :VCREATE
        return 220
      when :FLYINGPRESS
        return 170
      when :COREENFORCER
        return 140
      end 
      #---------------------------------------------------------------------------
      # All other moves scale based on their BP.
      #---------------------------------------------------------------------------
      check = @oldmove.baseDamage
      if check <56
        return 100
      elsif check <66
        return 120
      elsif check <76
        return 140
      elsif check <86
        return 160
      elsif check <96
        return 175
      elsif check <101
        return 180
      elsif check <111
        return 185
      elsif check <126
        return 190
      elsif check <131
        return 195
      else
        return 200
      end
    end
    
    #=============================================================================
    # Effects for status Z-Moves.
    #=============================================================================
    def PokeBattle_ZMove.from_status_move(battle, move, attacker)
      # Curse changes its effect if the user is Ghost type or not.
      curseZMoveGhost    = (move==:CURSE && attacker.pbHasType?(:GHOST))
      curseZMoveNonGhost = (move==:CURSE && !attacker.pbHasType?(:GHOST))
      #---------------------------------------------------------------------------
      # Effects for status Z-Moves that boost the stats of the user.
      #---------------------------------------------------------------------------
      if GameData::PowerMove.stat_booster?(move) || curseZMoveNonGhost
        stats, stage = GameData::PowerMove.stat_with_stage(move)
        stats, stage = [:ATTACK], 1 if curseZMoveNonGhost 
        statname = (stats.length>1) ? "stats" : GameData::Stat.get(stats[0]).name
        case stage
        when 3; boost = " drastically"
        when 2; boost = " sharply"
        else;   boost = ""
        end
        showAnim = true
        for i in 0...stats.length
          if attacker.pbCanRaiseStatStage?(stats[i],attacker)
            attacker.pbRaiseStatStageBasic(stats[i],stage)
            if showAnim
              battle.pbCommonAnimation("StatUp",attacker)
              battle.pbDisplay(_INTL("{1} boosted its {2}{3} using its Z-Power!",attacker.pbThis,statname,boost))
            end
            showAnim = false
          end
        end
      #---------------------------------------------------------------------------
      # Effect for status Z-Moves that boosts the user's critical hit ratio.
      #---------------------------------------------------------------------------
      elsif GameData::PowerMove.boosts_crit?(move)
        attacker.effects[PBEffects::CriticalBoost] += 2
        battle.pbDisplay(_INTL("{1} boosted its critical hit ratio using its Z-Power!",attacker.pbThis))
      #---------------------------------------------------------------------------
      # Effect for status Z-Moves that resets the user's lowered stats.
      #---------------------------------------------------------------------------
      elsif GameData::PowerMove.resets_stats?(move) && attacker.hasLoweredStatStages?
        attacker.pbResetStatStages
        battle.pbDisplay(_INTL("{1} returned its decreased stats to normal using its Z-Power!",attacker.pbThis))
      #---------------------------------------------------------------------------
      # Effects for status Z-Moves that heal HP.
      #---------------------------------------------------------------------------
      elsif GameData::PowerMove.heals_self?(move) || curseZMoveGhost
        if attacker.hp<attacker.totalhp
          healMessage = _INTL("{1} restored its HP using its Z-Power!",attacker.pbThis)
          attacker.pbRecoverHP(attacker.totalhp,false,true,true,healMessage)
        end
      elsif GameData::PowerMove.heals_switch?(move)
        battle.positions[attacker.index].effects[PBEffects::ZHeal] = true
      #---------------------------------------------------------------------------
      # Z-Status moves that cause misdirection.
      #---------------------------------------------------------------------------
      elsif GameData::PowerMove.focus_user?(move)
        battle.pbDisplay(_INTL("{1} became the center of attention using its Z-Power!",attacker.pbThis))
        attacker.effects[PBEffects::FollowMe] = 1
        attacker.eachAlly do |b|
          next if b.effects[PBEffects::FollowMe]<attacker.effects[PBEffects::FollowMe]
          attacker.effects[PBEffects::FollowMe] = b.effects[PBEffects::FollowMe]+1
        end
      end
    end
end

#===============================================================================
# Generic Z-Moves
#===============================================================================
# No effect.
#-------------------------------------------------------------------------------
class PokeBattle_Move_Z000 < PokeBattle_ZMove
end