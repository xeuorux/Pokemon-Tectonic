class PokeBattle_ActiveField
    include EffectHolder

    attr_accessor :effects, :defaultWeather, :weather, :weatherDuration, :defaultTerrain, :terrain, :terrainDuration
    attr_accessor :specialTimer,:specialWeatherEffect

    def initialize(battle)
        @defaultWeather  = :None
        @weather         = :None
        @weatherDuration = 0
        @defaultTerrain  = :None
        @terrain         = :None
        @terrainDuration = 0
        @specialTimer    = 1
        @specialWeatherEffect = false
        @battle = battle

        @effects = {}

        @location = :Field
        @apply_proc = proc do |effectData|
            effectData.apply_field(@battle)
        end
        @disable_proc = proc do |effectData|
            effectData.disable_field(@battle)
        end
        @eor_proc = proc do |effectData|
            effectData.eor_field(@battle)
        end
        @remain_proc = proc do |effectData|
            effectData.remain_field(@battle)
        end
        @expire_proc = proc do |effectData|
            effectData.expire_field(@battle)
        end
        @increment_proc = proc do |effectData, increment|
            effectData.increment_field(@battle, increment)
        end

        resetEffects
    end

    def resetEffects
        @effects.clear
        GameData::BattleEffect.each_field_effect do |effectData|
            @effects[effectData.id] = effectData.default
        end
    end

    def applyEffect(effect, value = nil)
        super(effect, value)
        echoln("[FIELD EFFECT] Effect #{getName(effect)} applied to whole field")
    end

    def resetSpecialEffect
        @specialTimer = 1
        @specialWeatherEffect = false
    end
end
