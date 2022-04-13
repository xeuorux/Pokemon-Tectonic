class PokemonBattlerSprite < RPG::Sprite
    def pbSetPosition
        return if !@_iconBitmap
        pbSetOrigin
        if (@index%2)==0
        self.z = 50+5*@index/2
        else
        self.z = 50-5*(@index+1)/2
        end
        # Set original position
        p = PokeBattle_SceneConstants.pbBattlerPosition(@index,@sideSize,@pkmn.boss?)
        @spriteX = p[0]
        @spriteY = p[1]
        # Apply metrics
        @pkmn.species_data.apply_metrics_to_sprite(self, @index)
    end
end