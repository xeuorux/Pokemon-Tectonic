class PokemonPokedexInfoScreen
  def pbStartScreen(dexlist,index,region,linksEnabled=false)
    @scene.pbStartScene(dexlist,index,region,false,linksEnabled)
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret   # Index of last species viewed in dexlist
  end
end