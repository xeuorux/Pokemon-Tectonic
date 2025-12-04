#===============================================================================
# Trainer class for the player
#===============================================================================
class Player < Trainer

    def character_ID=(value)
        @character_ID = value
        resetPlayerOverlayHuesToDefaults
    end
    
    #=============================================================================
    # Overlay hues
    #=============================================================================
    PLAYER_APPEARANCE_CUSTOMIZATION_OVERLAYS = {
        :HAIR => {
            :filepath => "hair",
            :default_hues => [247,320,0]
        },
    }

    def getOverlayHue(overlayID)
        resetPlayerOverlayHuesToDefaults if @overlayHues.nil?
        return @overlayHues[overlayID]
    end

    def setOverlayHue(overlayID, value)
        resetPlayerOverlayHuesToDefaults if @overlayHues.nil?
        @overlayHues[overlayID] = value
    end

    # Yields each overlay's filepath and the hue for that overlay
    def eachPlayerAppearanceCustomizationOverlay
        resetPlayerOverlayHuesToDefaults if @overlayHues.nil?
        PLAYER_APPEARANCE_CUSTOMIZATION_OVERLAYS.each_pair do |overlayID, overlayData|
            filePath = "_overlay_" + overlayData[:filepath]
            hue = @overlayHues[overlayID] || 0
            yield filePath, hue
        end
    end

    def resetPlayerOverlayHuesToDefaults
        @overlayHues = {}
        PLAYER_APPEARANCE_CUSTOMIZATION_OVERLAYS.each_pair do |overlayID, overlayData|
            defaultHuesArray = overlayData[:default_hues]
            @overlayHues[overlayID] = defaultHuesArray[$Trainer.character_ID] || 0
        end
    end
end