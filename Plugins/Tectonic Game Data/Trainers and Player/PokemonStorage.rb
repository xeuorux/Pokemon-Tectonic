class PokemonBox
    attr_reader   :pokemon
    attr_accessor :name
    attr_accessor :background
  
    BOX_WIDTH  = 6
    BOX_HEIGHT = 5
    BOX_SIZE   = BOX_WIDTH * BOX_HEIGHT
  
    def initialize(name, maxPokemon = BOX_SIZE)
      @pokemon = []
      @name = name
      @background = 0
      @maxPokemon = maxPokemon
      for i in 0...maxPokemon
        @pokemon[i] = nil
      end
      @locked = 0
      @isDonationBox = 0
    end
  
    def length
      return @pokemon.length
    end

    def maxPokemon
      @maxPokemon = BOX_SIZE if @maxPokemon.nil?
      return @maxPokemon
    end
  
    def nitems
      ret = 0
      @pokemon.each { |pkmn| ret += 1 if !pkmn.nil? }
      return ret
    end
  
    def full?
      return nitems == self.length
    end
  
    def empty?
      return nitems == 0
    end
  
    def [](i)
      return @pokemon[i]
    end
  
    def []=(i,value)
      @pokemon[i] = value
    end
  
    def each
      @pokemon.each { |item| yield item }
    end

    def sample
      return @pokemon.clone.compact.sample
    end
  
    def clear
      @pokemon = []
      for i in 0...self.maxPokemon
        @pokemon[i] = nil
      end
    end
    
    def lock
      @locked = 1
    end
    
    def unlock
      @locked = 0
    end

    def isDonationBox?
      return @isDonationBox == 1
    end

    def setDonationBox
      @isDonationBox = 1
    end

    def unSetDonationBox
      @isDonationBox = 0
    end
    
    def isLocked?
      return @locked == 1
    end
  end
  
  
  
  class PokemonStorage
    attr_reader   :boxes
    attr_accessor :currentBox
    attr_writer   :unlockedWallpapers
    BASICWALLPAPERQTY = 14
  
    def initialize(maxBoxes = Settings::NUM_STORAGE_BOXES, maxPokemon = PokemonBox::BOX_SIZE)
      @boxes = []
      for i in 0...maxBoxes
        @boxes[i] = PokemonBox.new(_INTL("Box {1}",i+1),maxPokemon)
        @boxes[i].background = i % BASICWALLPAPERQTY
      end
      addDonationBoxes()
      @currentBox = 0
      @boxmode = -1
      @unlockedWallpapers = []
      for i in 0...allWallpapers.length
        @unlockedWallpapers[i] = false
      end
    end

    def addDonationBoxes(maxBoxes = Settings::NUM_STORAGE_BOXES, maxDonationBoxes = Settings::NUM_DONATION_BOXES, maxPokemon = PokemonBox::BOX_SIZE)
      for i in 0...maxDonationBoxes
        @boxes[i + maxBoxes] = PokemonBox.new(_INTL("Donation Box {1}",i+1),maxPokemon)
        @boxes[i + maxBoxes].background = "donation"
        @boxes[i + maxBoxes].setDonationBox
        echoln("Added donation box #{i+1}")
      end
    end
  
    def allWallpapers
      return [
         # Basic wallpapers
         _INTL("Forest"),_INTL("City"),_INTL("Desert"),_INTL("Savanna"),
         _INTL("Crag"),_INTL("Volcano"),_INTL("Snow"),_INTL("Cave"),
         _INTL("Beach"),_INTL("Seafloor"),_INTL("River"),_INTL("Sky"),
         _INTL("Machine"),_INTL("Simple")
      ]
    end
  
    def unlockedWallpapers
      @unlockedWallpapers = [] if !@unlockedWallpapers
      return @unlockedWallpapers
    end
  
    def isAvailableWallpaper?(i)
        return true unless i.is_a?(Integer)
        @unlockedWallpapers = [] if !@unlockedWallpapers
        return true if i<BASICWALLPAPERQTY
        return true if @unlockedWallpapers[i]
        return false
    end
  
    def availableWallpapers
      ret = [[],[]]   # Names, IDs
      papers = allWallpapers
      @unlockedWallpapers = [] if !@unlockedWallpapers
      for i in 0...papers.length
        next if !isAvailableWallpaper?(i)
        ret[0].push(papers[i]); ret[1].push(i)
      end
      return ret
    end
  
    def party
      $Trainer.party
    end
  
    def party=(_value)
      raise ArgumentError.new("Not supported")
    end
  
    def party_full?
      return $Trainer.party_full?
    end
  
    def maxBoxes
      return @boxes.length
    end
  
    def maxPokemon(box)
      return 0 if box >= self.maxBoxes
      return (box < 0) ? Settings::MAX_PARTY_SIZE : self[box].length
    end
  
    def full?
      for i in 0...self.maxBoxes-Settings::NUM_DONATION_BOXES
        return false unless @boxes[i].full?
      end
      return true
    end
  
    def pbFirstFreePos(box)
      if box==-1
        ret = self.party.length
        return (ret >= Settings::MAX_PARTY_SIZE) ? -1 : ret
      end
      for i in 0...maxPokemon(box)
        return i if !self[box,i]
      end
      return -1
    end
  
    def [](x,y=nil)
      if y==nil
        return (x==-1) ? self.party : @boxes[x]
      else
        for i in @boxes
          raise "Box is a Pokémon, not a box" if i.is_a?(Pokemon)
        end
        return (x==-1) ? self.party[y] : @boxes[x][y]
      end
    end
  
    def []=(x,y,value)
      if x==-1
        self.party[y] = value
      else
        @boxes[x][y] = value
      end
    end
  
    def pbCopy(boxDst,indexDst,boxSrc,indexSrc)
      if indexDst<0 && boxDst<self.maxBoxes
        found = false
        for i in 0...maxPokemon(boxDst)
          next if self[boxDst,i]
          found = true
          indexDst = i
          break
        end
        return false if !found
      end
      if boxDst==-1   # Copying into party
        return false if party_full?
        self.party[self.party.length] = self[boxSrc,indexSrc]
        self.party.compact!
      else   # Copying into box
        pkmn = self[boxSrc,indexSrc]
        raise "Trying to copy nil to storage" if !pkmn
        pkmn.time_form_set = nil
        pkmn.heal
        self[boxDst,indexDst] = pkmn
      end
      return true
    end
  
    def pbMove(boxDst,indexDst,boxSrc,indexSrc)
      return false if !pbCopy(boxDst,indexDst,boxSrc,indexSrc)
      pbDelete(boxSrc,indexSrc)
      return true
    end
  
    def pbMoveCaughtToParty(pkmn)
      return false if party_full?
      self.party[self.party.length] = pkmn
    end
  
    def pbMoveCaughtToBox(pkmn,box)
      for i in 0...maxPokemon(box)
        if self[box,i]==nil
          if box>=0
            pkmn.time_form_set = nil if pkmn.time_form_set
            pkmn.heal
          end
          self[box,i] = pkmn
          return true
        end
      end
      return false
    end
  
    def pbStoreCaught(pkmn)
      if @currentBox >= 0
        pkmn.time_form_set = nil
        pkmn.heal
      end
      if !@boxes[@currentBox].isDonationBox?
        for i in 0...maxPokemon(@currentBox)
          if self[@currentBox,i]==nil
            self[@currentBox,i] = pkmn
            return @currentBox
          end
        end
      end
      # Check for backup boxes beyond the current box
      for potentialBox in (@currentBox + 1)...self.maxBoxes
        next if self[potentialBox].isDonationBox?
        for i in 0...maxPokemon(potentialBox)
          if self[potentialBox,i]==nil
            self[potentialBox,i] = pkmn
            @currentBox = potentialBox
            return @currentBox
          end
        end
      end
      # Check for backup before the current box
      for potentialBox in 0...@currentBox
        next if self[potentialBox].isDonationBox?
        for i in 0...maxPokemon(potentialBox)
          if self[potentialBox,i]==nil
            self[potentialBox,i] = pkmn
            @currentBox = potentialBox
            return @currentBox
          end
        end
      end
      return -1
    end
  
    def pbDelete(box,index)
      if self[box,index]
        self[box,index] = nil
        self.party.compact! if box==-1
      end
    end
  
    def clear
      for i in 0...self.maxBoxes
        @boxes[i].clear
      end
    end
  end
  
  
  
  #===============================================================================
  # Regional Storage scripts
  #===============================================================================
  class RegionalStorage
    def initialize
      @storages = []
      @lastmap = -1
      @rgnmap = -1
    end
  
    def getCurrentStorage
      if !$game_map
        raise _INTL("The player is not on a map, so the region could not be determined.")
      end
      if @lastmap!=$game_map.map_id
        @rgnmap = pbGetCurrentRegion   # may access file IO, so caching result
        @lastmap = $game_map.map_id
      end
      if @rgnmap<0
        raise _INTL("The current map has no region set. Please set the MapPosition metadata setting for this map.")
      end
      if !@storages[@rgnmap]
        @storages[@rgnmap] = PokemonStorage.new
      end
      return @storages[@rgnmap]
    end
  
    def allWallpapers
      return getCurrentStorage.allWallpapers
    end
  
    def availableWallpapers
      return getCurrentStorage.availableWallpapers
    end
  
    def unlockWallpaper(index)
      getCurrentStorage.unlockWallpaper(index)
    end
  
    def boxes
      return getCurrentStorage.boxes
    end
  
    def party
      return getCurrentStorage.party
    end
  
    def party_full?
      return getCurrentStorage.party_full?
    end
  
    def maxBoxes
      return getCurrentStorage.maxBoxes
    end
  
    def maxPokemon(box)
      return getCurrentStorage.maxPokemon(box)
    end
  
    def full?
      getCurrentStorage.full?
    end
  
    def currentBox
      return getCurrentStorage.currentBox
    end
  
    def currentBox=(value)
      getCurrentStorage.currentBox = value
    end
  
    def [](x,y=nil)
      getCurrentStorage[x,y]
    end
  
    def []=(x,y,value)
      getCurrentStorage[x,y] = value
    end
  
    def pbFirstFreePos(box)
      getCurrentStorage.pbFirstFreePos(box)
    end
  
    def pbCopy(boxDst,indexDst,boxSrc,indexSrc)
      getCurrentStorage.pbCopy(boxDst,indexDst,boxSrc,indexSrc)
    end
  
    def pbMove(boxDst,indexDst,boxSrc,indexSrc)
      getCurrentStorage.pbCopy(boxDst,indexDst,boxSrc,indexSrc)
    end
  
    def pbMoveCaughtToParty(pkmn)
      getCurrentStorage.pbMoveCaughtToParty(pkmn)
    end
  
    def pbMoveCaughtToBox(pkmn,box)
      getCurrentStorage.pbMoveCaughtToBox(pkmn,box)
    end
  
    def pbStoreCaught(pkmn)
      getCurrentStorage.pbStoreCaught(pkmn)
    end
  
    def pbDelete(box,index)
      getCurrentStorage.pbDelete(pkmn)
    end
  end
  
  
  
  #===============================================================================
  #
  #===============================================================================
  def pbUnlockWallpaper(index)
    $PokemonStorage.unlockedWallpapers[index] = true
  end
  
  def pbLockWallpaper(index)   # Don't know why you'd want to do this
    $PokemonStorage.unlockedWallpapers[index] = false
  end
  
  #===============================================================================
  # Look through Pokémon in storage
  #===============================================================================
  # Yields every Pokémon/egg in storage in turn.
  def pbEachPokemon
    for i in -1...$PokemonStorage.maxBoxes
      for j in 0...$PokemonStorage.maxPokemon(i)
        pkmn = $PokemonStorage[i][j]
        yield(pkmn,i) if pkmn
      end
    end
  end

  def pbEachNonDonationPokemon
    for i in -1...Settings::NUM_STORAGE_BOXES
      for j in 0...$PokemonStorage.maxPokemon(i)
        pkmn = $PokemonStorage[i][j]
        yield(pkmn,i) if pkmn
      end
    end
  end
  
  # Yields every Pokémon in storage in turn.
  def pbEachNonEggPokemon
    pbEachPokemon { |pkmn,box| yield(pkmn,box) if !pkmn.egg? }
  end
  