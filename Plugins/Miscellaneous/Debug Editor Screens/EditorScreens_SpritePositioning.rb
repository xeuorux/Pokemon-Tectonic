class SpritePositioner
    def pbChooseSpecies
        if @starting
            pbFadeInAndShow(@sprites) { update }
            @starting = false
        end
        cw = Window_CommandPokemonEx.newEmpty(0, 0, 260, 32 + 24 * 6, @viewport)
        cw.rowHeight = 24
        pbSetSmallFont(cw.contents)
        cw.x = Graphics.width - cw.width
        cw.y = Graphics.height - cw.height
        allspecies = []
        GameData::Species.each do |sp|
            name = (sp.form == 0) ? sp.name : _INTL("{1} (form {2})", sp.real_name, sp.form)
            allspecies.push([sp.id, sp.species, name]) if name && !name.empty?
        end
        allspecies.sort! { |a, b| a[2] <=> b[2] }
        commands = []
        allspecies.each { |sp| commands.push(sp[2]) }
        cw.commands = commands
        cw.index    = @oldSpeciesIndex
        ret = nil
        oldindex = -1
        loop do
            Graphics.update
            Input.update
            cw.update
            if cw.index != oldindex
                oldindex = cw.index
                pbChangeSpecies(allspecies[cw.index][0])
                refresh
            end
            searchListWindow(cw) if Input.trigger?(Input::SPECIAL)
            update
            if Input.trigger?(Input::BACK)
                pbChangeSpecies(nil)
                refresh
                break
            elsif Input.trigger?(Input::USE)
                pbChangeSpecies(allspecies[cw.index][0])
                ret = allspecies[cw.index][0]
                break
            end
        end
        @oldSpeciesIndex = cw.index
        cw.dispose
        return ret
    end
end
