#===============================================================================
# Evolution animation metafiles and related methods
#===============================================================================
class SpriteMetafile
    VIEWPORT      = 0
    TONE          = 1
    SRC_RECT      = 2
    VISIBLE       = 3
    X             = 4
    Y             = 5
    Z             = 6
    OX            = 7
    OY            = 8
    ZOOM_X        = 9
    ZOOM_Y        = 10
    ANGLE         = 11
    MIRROR        = 12
    BUSH_DEPTH    = 13
    OPACITY       = 14
    BLEND_TYPE    = 15
    COLOR         = 16
    FLASHCOLOR    = 17
    FLASHDURATION = 18
    BITMAP        = 19
  
    def length
      return @metafile.length
    end
  
    def [](i)
      return @metafile[i]
    end
  
    def initialize(viewport=nil)
      @metafile=[]
      @values=[
         viewport,
         Tone.new(0,0,0,0),Rect.new(0,0,0,0),
         true,
         0,0,0,0,0,100,100,
         0,false,0,255,0,
         Color.new(0,0,0,0),Color.new(0,0,0,0),
         0
      ]
    end
  
    def disposed?
      return false
    end
  
    def dispose; end
  
    def flash(color,duration)
      if duration>0
        @values[FLASHCOLOR]=color.clone
        @values[FLASHDURATION]=duration
        @metafile.push([FLASHCOLOR,color])
        @metafile.push([FLASHDURATION,duration])
      end
    end
  
    def x
      return @values[X]
    end
  
    def x=(value)
      @values[X]=value
      @metafile.push([X,value])
    end
  
    def y
      return @values[Y]
    end
  
    def y=(value)
      @values[Y]=value
      @metafile.push([Y,value])
    end
  
    def bitmap
      return nil
    end
  
    def bitmap=(value)
      if value && !value.disposed?
        @values[SRC_RECT].set(0,0,value.width,value.height)
        @metafile.push([SRC_RECT,@values[SRC_RECT].clone])
      end
    end
  
    def src_rect
      return @values[SRC_RECT]
    end
  
    def src_rect=(value)
      @values[SRC_RECT]=value
      @metafile.push([SRC_RECT,value])
    end
  
    def visible
      return @values[VISIBLE]
    end
  
    def visible=(value)
      @values[VISIBLE]=value
      @metafile.push([VISIBLE,value])
    end
  
    def z
      return @values[Z]
    end
  
    def z=(value)
      @values[Z]=value
      @metafile.push([Z,value])
    end
  
    def ox
      return @values[OX]
    end
  
    def ox=(value)
      @values[OX]=value
      @metafile.push([OX,value])
    end
  
    def oy
      return @values[OY]
    end
  
    def oy=(value)
      @values[OY]=value
      @metafile.push([OY,value])
    end
  
    def zoom_x
      return @values[ZOOM_X]
    end
  
    def zoom_x=(value)
      @values[ZOOM_X]=value
      @metafile.push([ZOOM_X,value])
    end
  
    def zoom_y
      return @values[ZOOM_Y]
    end
  
    def zoom_y=(value)
      @values[ZOOM_Y]=value
      @metafile.push([ZOOM_Y,value])
    end
  
    def zoom=(value)
      @values[ZOOM_X]=value
      @metafile.push([ZOOM_X,value])
      @values[ZOOM_Y]=value
      @metafile.push([ZOOM_Y,value])
    end
  
    def angle
      return @values[ANGLE]
    end
  
    def angle=(value)
      @values[ANGLE]=value
      @metafile.push([ANGLE,value])
    end
  
    def mirror
      return @values[MIRROR]
    end
  
    def mirror=(value)
      @values[MIRROR]=value
      @metafile.push([MIRROR,value])
    end
  
    def bush_depth
      return @values[BUSH_DEPTH]
    end
  
    def bush_depth=(value)
      @values[BUSH_DEPTH]=value
      @metafile.push([BUSH_DEPTH,value])
    end
  
    def opacity
      return @values[OPACITY]
    end
  
    def opacity=(value)
      @values[OPACITY]=value
      @metafile.push([OPACITY,value])
    end
  
    def blend_type
      return @values[BLEND_TYPE]
    end
  
    def blend_type=(value)
      @values[BLEND_TYPE]=value
      @metafile.push([BLEND_TYPE,value])
    end
  
    def color
      return @values[COLOR]
    end
  
    def color=(value)
      @values[COLOR]=value.clone
      @metafile.push([COLOR,@values[COLOR]])
    end
  
    def tone
      return @values[TONE]
    end
  
    def tone=(value)
      @values[TONE]=value.clone
      @metafile.push([TONE,@values[TONE]])
    end
  
    def update
      @metafile.push([-1,nil])
    end
  end
  
  #===============================================================================
  #
  #===============================================================================
  class SpriteMetafilePlayer
    def initialize(metafile,sprite=nil)
      @metafile=metafile
      @sprites=[]
      @playing=false
      @index=0
      @sprites.push(sprite) if sprite
    end
  
    def add(sprite)
      @sprites.push(sprite)
    end
  
    def playing?
      return @playing
    end
  
    def play
      @playing=true
      @index=0
    end
  
    def update
      if @playing
        for j in @index...@metafile.length
          @index=j+1
          break if @metafile[j][0]<0
          code=@metafile[j][0]
          value=@metafile[j][1]
          for sprite in @sprites
            case code
            when SpriteMetafile::X          then sprite.x = value
            when SpriteMetafile::Y          then sprite.y = value
            when SpriteMetafile::OX         then sprite.ox = value
            when SpriteMetafile::OY         then sprite.oy = value
            when SpriteMetafile::ZOOM_X     then sprite.zoom_x = value
            when SpriteMetafile::ZOOM_Y     then sprite.zoom_y = value
            when SpriteMetafile::SRC_RECT   then sprite.src_rect = value
            when SpriteMetafile::VISIBLE    then sprite.visible = value
            when SpriteMetafile::Z          then sprite.z = value   # prevent crashes
            when SpriteMetafile::ANGLE      then sprite.angle = (value == 180) ? 179.9 : value
            when SpriteMetafile::MIRROR     then sprite.mirror = value
            when SpriteMetafile::BUSH_DEPTH then sprite.bush_depth = value
            when SpriteMetafile::OPACITY    then sprite.opacity = value
            when SpriteMetafile::BLEND_TYPE then sprite.blend_type = value
            when SpriteMetafile::COLOR      then sprite.color = value
            when SpriteMetafile::TONE       then sprite.tone = value
            end
          end
        end
        @playing=false if @index==@metafile.length
      end
    end
  end
  
  #===============================================================================
  #
  #===============================================================================
  def pbSaveSpriteState(sprite)
    state=[]
    return state if !sprite || sprite.disposed?
    state[SpriteMetafile::BITMAP]     = sprite.x
    state[SpriteMetafile::X]          = sprite.x
    state[SpriteMetafile::Y]          = sprite.y
    state[SpriteMetafile::SRC_RECT]   = sprite.src_rect.clone
    state[SpriteMetafile::VISIBLE]    = sprite.visible
    state[SpriteMetafile::Z]          = sprite.z
    state[SpriteMetafile::OX]         = sprite.ox
    state[SpriteMetafile::OY]         = sprite.oy
    state[SpriteMetafile::ZOOM_X]     = sprite.zoom_x
    state[SpriteMetafile::ZOOM_Y]     = sprite.zoom_y
    state[SpriteMetafile::ANGLE]      = sprite.angle
    state[SpriteMetafile::MIRROR]     = sprite.mirror
    state[SpriteMetafile::BUSH_DEPTH] = sprite.bush_depth
    state[SpriteMetafile::OPACITY]    = sprite.opacity
    state[SpriteMetafile::BLEND_TYPE] = sprite.blend_type
    state[SpriteMetafile::COLOR]      = sprite.color.clone
    state[SpriteMetafile::TONE]       = sprite.tone.clone
    return state
  end
  
  def pbRestoreSpriteState(sprite,state)
    return if !state || !sprite || sprite.disposed?
    sprite.x          = state[SpriteMetafile::X]
    sprite.y          = state[SpriteMetafile::Y]
    sprite.src_rect   = state[SpriteMetafile::SRC_RECT]
    sprite.visible    = state[SpriteMetafile::VISIBLE]
    sprite.z          = state[SpriteMetafile::Z]
    sprite.ox         = state[SpriteMetafile::OX]
    sprite.oy         = state[SpriteMetafile::OY]
    sprite.zoom_x     = state[SpriteMetafile::ZOOM_X]
    sprite.zoom_y     = state[SpriteMetafile::ZOOM_Y]
    sprite.angle      = state[SpriteMetafile::ANGLE]
    sprite.mirror     = state[SpriteMetafile::MIRROR]
    sprite.bush_depth = state[SpriteMetafile::BUSH_DEPTH]
    sprite.opacity    = state[SpriteMetafile::OPACITY]
    sprite.blend_type = state[SpriteMetafile::BLEND_TYPE]
    sprite.color      = state[SpriteMetafile::COLOR]
    sprite.tone       = state[SpriteMetafile::TONE]
  end
  
  def pbSaveSpriteStateAndBitmap(sprite)
    return [] if !sprite || sprite.disposed?
    state=pbSaveSpriteState(sprite)
    state[SpriteMetafile::BITMAP]=sprite.bitmap
    return state
  end
  
  def pbRestoreSpriteStateAndBitmap(sprite,state)
    return if !state || !sprite || sprite.disposed?
    sprite.bitmap=state[SpriteMetafile::BITMAP]
    pbRestoreSpriteState(sprite,state)
    return state
  end

  def pbTopRightWindow(text, scene = nil, givenWidth = 198)
    window = Window_AdvancedTextPokemon.new(text)
    window.width = givenWidth
    window.x     = Graphics.width - window.width
    window.y     = 0
    window.z     = 99_999
    pbPlayDecisionSE
    loop do
        Graphics.update
        Input.update
        window.update
        scene.pbUpdate if scene
        break if Input.trigger?(Input::USE)
    end
    window.dispose
end

def showPokemonChangesWindow(pokemon, &block)
  if $Options.show_stat_changes == 1 # Skipping stat changes
    block.call # Still modify the pokemon
    return # but don't show any UI
  end
  # Mark down pre-change stats
  oldTotalHP = pokemon.totalhp
  oldAttack = pokemon.attack
  oldDefense = pokemon.defense
  oldSpAtk = pokemon.spatk
  oldSpDef = pokemon.spdef
  oldSpeed = pokemon.speed
  # Mark down pre-change ability
  oldAbility = pokemon.ability
  # Modify Pokémon to make it evolved
  block.call
  # Show the stat changes
  hpDif = pokemon.totalhp - oldTotalHP
  hpDifStr = hpDif.to_s
  attackDif = pokemon.attack - oldAttack
  attackDifStr = attackDif.to_s
  defenseDif = pokemon.defense - oldDefense
  defenseDifStr = defenseDif.to_s
  spAtkDif = pokemon.spatk - oldSpAtk
  spAtkDifStr = spAtkDif.to_s
  spDefDif = pokemon.spdef - oldSpDef
  spDefDifStr = spDefDif.to_s
  speedDif = pokemon.speed - oldSpeed
  speedDifStr = speedDif.to_s
  if hpDif != 0 || attackDif != 0 || defenseDif != 0 ||
     spAtkDif != 0 || spDefDif != 0 || speedDif != 0
      pbTopRightWindow(
          _INTL("Max. HP<r>#{hpDif >= 0 ? '+' : ''}{1}\r\nAttack<r>#{attackDif >= 0 ? '+' : ''}{2}\r\nDefense<r>#{defenseDif >= 0 ? '+' : ''}{3}\r\nSp. Atk<r>#{spAtkDif >= 0 ? '+' : ''}{4}\r\nSp. Def<r>#{spDefDif >= 0 ? '+' : ''}{5}\r\nSpeed<r>#{speedDif >= 0 ? '+' : ''}{6}",
          hpDifStr, attackDifStr, defenseDifStr,
          spAtkDifStr, spDefDifStr, speedDifStr), nil, 198)
      pbTopRightWindow(
          _INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
          pokemon.totalhp, pokemon.attack, pokemon.defense, pokemon.spatk, pokemon.spdef, pokemon.speed), nil, 198)
  end
  # Show new ability if any
  if pokemon.ability != oldAbility
      ability_name = GameData::Ability.get(pokemon.ability).name
      pbMessage(_INTL("{1}'s ability was changed to {2}.", pokemon.name, ability_name))
  end
end

