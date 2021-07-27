class PokeBattle_Scene
  #=============================================================================
  # Loads a move/common animation
  #=============================================================================
  # Returns the animation ID to use for a given move/user. Returns nil if that
  # move has no animations defined for it.
  def pbFindMoveAnimDetails(move2anim,moveID,idxUser,hitNum=0)
    id_number = GameData::Move.get(moveID).id_number
    noFlip = false
    if (idxUser&1)==0   # On player's side
      anim = move2anim[0][id_number]
    else                # On opposing side
      anim = move2anim[1][id_number]
      noFlip = true if anim
      anim = move2anim[0][id_number] if !anim
    end
    return [anim+hitNum,noFlip] if anim
    return nil
  end

  # Returns the animation ID to use for a given move. If the move has no
  # animations, tries to use a default move animation depending on the move's
  # type. If that default move animation doesn't exist, trues to use Tackle's
  # move animation. Returns nil if it can't find any of these animations to use.
  def pbFindMoveAnimation(moveID, idxUser, hitNum)
    begin
      move2anim = pbLoadMoveToAnim
      # Find actual animation requested (an opponent using the animation first
      # looks for an OppMove version then a Move version)
      anim = pbFindMoveAnimDetails(move2anim, moveID, idxUser, hitNum)
      return anim if anim
      # Actual animation not found, get the default animation for the move's type
      moveData = GameData::Move.get(moveID)
      target_data = GameData::Target.get(moveData.target)
      moveType = moveData.type
      moveKind = moveData.category
      moveKind += 3 if target_data.num_targets > 1 || target_data.affects_foe_side
      moveKind += 3 if moveKind == 2 && target_data.num_targets > 0
      # [one target physical, one target special, user status,
      #  multiple targets physical, multiple targets special, non-user status]
      typeDefaultAnim = {
        :NORMAL   => [:TACKLE,       :SONICBOOM,    :DEFENSECURL, :EXPLOSION,  :SWIFT,        :TAILWHIP],
        :FIGHTING => [:MACHPUNCH,    :AURASPHERE,   :DETECT,      nil,         nil,           nil],
        :FLYING   => [:WINGATTACK,   :GUST,         :ROOST,       nil,         :AIRCUTTER,    :FEATHERDANCE],
        :POISON   => [:POISONSTING,  :SLUDGE,       :ACIDARMOR,   nil,         :ACID,         :POISONPOWDER],
        :GROUND   => [:SANDTOMB,     :MUDSLAP,      nil,          :EARTHQUAKE, :EARTHPOWER,   :MUDSPORT],
        :ROCK     => [:ROCKTHROW,    :POWERGEM,     :ROCKPOLISH,  :ROCKSLIDE,  :ANCIENTPOWER, :SANDSTORM],
        :BUG      => [:TWINEEDLE,    :BUGBUZZ,      :QUIVERDANCE, nil,         :STRUGGLEBUG,  :STRINGSHOT],
        :GHOST    => [:LICK,         :SHADOWBALL,   :GRUDGE,      nil,         nil,           :CONFUSERAY],
        :STEEL    => [:IRONHEAD,     :MIRRORSHOT,   :IRONDEFENSE, nil,         nil,           :METALSOUND],
        :FIRE     => [:FIREPUNCH,    :EMBER,        :SUNNYDAY,    nil,         :INCINERATE,   :WILLOWISP],
        :WATER    => [:CRABHAMMER,   :WATERPULSE,     :AQUARING,    nil,         :SURF,         :WATERSPORT],
        :GRASS    => [:VINEWHIP,     :ENERGYBALL,    :COTTONGUARD, :RAZORLEAF,  nil,           :SPORE],
        :ELECTRIC => [:THUNDERPUNCH, :THUNDERSHOCK, :CHARGE,      nil,         :DISCHARGE,    :THUNDERWAVE],
        :PSYCHIC  => [:PSYCHOCUT,  :CONFUSION,    :CALMMIND,    nil,         :SYNCHRONOISE, :MIRACLEEYE],
        :ICE      => [:ICEPUNCH,     :ICEBEAM,      :MIST,        nil,         :POWDERSNOW,   :HAIL],
        :DRAGON   => [:DRAGONCLAW,   :DRAGONRAGE,   :DRAGONDANCE, nil,         :TWISTER,      nil],
        :DARK     => [:PURSUIT,      :DARKPULSE,    :HONECLAWS,   nil,         :SNARL,        :EMBARGO],
        :FAIRY    => [:TACKLE,       :FAIRYWIND,    :POUT,   nil,         :SWIFT,        :SWEETKISS]
      }
      if typeDefaultAnim[moveType]
        anims = typeDefaultAnim[moveType]
		#The the most correct possible animation
        if GameData::Move.exists?(anims[moveKind])
          anim = pbFindMoveAnimDetails(move2anim, anims[moveKind], idxUser)
        end
		#If the move is multitarget, but no such animation exists, try for the single target version
        if !anim && moveKind >= 3 && GameData::Move.exists?(anims[moveKind - 3])
          anim = pbFindMoveAnimDetails(move2anim, anims[moveKind - 3], idxUser)
        end
		# If not even the single target version exists, try the "user status" animatio
        if !anim && GameData::Move.exists?(anims[2])
          anim = pbFindMoveAnimDetails(move2anim, anims[2], idxUser)
        end
		# If not even the "user status" exists, fall back on the normal type
		if !anim
			anim = pbFindMoveAnimDetails(move2anim,typeDefaultAnim[:NORMAL][moveKind],idxUser)
		end
      end
      return anim if anim
	  
      # Default animation for the move's type not found, use Tackle's animation
      if GameData::Move.exists?(:TACKLE)
        return pbFindMoveAnimDetails(move2anim, :TACKLE, idxUser)
      end
    rescue
    end
    return nil
  end
end


class PBAnimationPlayerX
  def initialize(animation,user,target,scene=nil,oppMove=false,inEditor=false)
    @animation     = animation
    @user          = (oppMove) ? target : user   # Just used for playing user's cry
    @usersprite    = (user) ? scene.sprites["pokemon_#{user.index}"] : nil
    @targetsprite  = (target) ? scene.sprites["pokemon_#{target.index}"] : nil
    @userbitmap    = (@usersprite && @usersprite.bitmap) ? @usersprite.bitmap : nil # not to be disposed
    @targetbitmap  = (@targetsprite && @targetsprite.bitmap) ? @targetsprite.bitmap : nil # not to be disposed
    @scene         = scene
    @viewport      = (scene) ? scene.viewport : nil
    @inEditor      = inEditor
    @looping       = false
    @animbitmap    = nil   # Animation sheet graphic
    @frame         = -1
    @framesPerTick = [Graphics.frame_rate/20,1].max   # 20 ticks per second
    @srcLine       = nil
    @dstLine       = nil
    @userOrig      = getSpriteCenter(@usersprite)
	# Now assumes the target is in the direct center of the screen if one isn't given
	# So that cells which focus on the target will be centered rather than at the top left
    @targetOrig    = @targetsprite ? getSpriteCenter(@targetsprite) : [@viewport.rect.width/2,@viewport.rect.height - 160]
    @oldbg         = []
    @oldfo         = []
    initializeSprites
  end
end
