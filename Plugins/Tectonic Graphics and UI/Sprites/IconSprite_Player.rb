class PlayerTrainerIconSprite < IconSprite
    def initialize(viewport,frontSprite = true)
        @trainer = nil
        @playerOverlaySprites = []
        @frontSprite = frontSprite
        super(viewport)
    end

    def getFilename
        if @frontSprite
            return GameData::TrainerType.player_front_sprite_filename(@trainer.trainer_type)
        else
            return GameData::TrainerType.player_back_sprite_filename(@trainer.trainer_type)
        end
    end

    def setTrainer(trainer)
        @trainer = trainer
        setBitmap(getFilename)
        loadOverlays
    end

    def loadOverlays
        overlayPath = "_overlay"
        if pbResolveBitmap(getFilename + overlayPath)
            # Load sprite
            newSprite = IconSprite.new(self.viewport)
            newSprite.setBitmap(getFilename + overlayPath)
            newSprite.src_rect = @sprite.src_rect
            @playerOverlaySprites.push(newSprite)
        end
    end

    def disposeOverlays
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.dispose
        end
        @playerOverlaySprites = []
    end

    def clearBitmaps
        disposeOverlays
        super
    end

    def x=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.x = value
        end
    end

    def y=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.y = value
        end
    end

    def z=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.z = value
        end
    end

    def ox=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.ox = value
        end
    end

    def oy=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.oy = value
        end
    end

    def visible=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.visible = value
        end
    end

    def src_rect=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.src_rect = value
        end
    end

    def zoom_x=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.zoom_x = value
        end
    end

    def zoom_y=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.zoom_y = value
        end
    end

    def angle=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.angle = value
        end
    end

    def mirror=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.mirror = value
        end
    end

    def opacity=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.opacity = value
        end
    end

    def blend_type=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.blend_type = value
        end
    end

    def color=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.color = value
        end
    end

    def tone=(value)
        super
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.tone = value
        end
    end

    def src_rect
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.src_rect = @sprite.src_rect
        end
        return @sprite.src_rect
    end

    def update
        super
        return if !@_iconbitmap
        @_iconbitmap.update
        @playerOverlaySprites.each do |overlaySprite|
            overlaySprite.update
        end
        if self.bitmap!=@_iconbitmap.bitmap
            oldrc=self.src_rect
            self.bitmap=@_iconbitmap.bitmap
            disposeOverlays
            loadOverlays
            self.src_rect=oldrc
        end
    end
end