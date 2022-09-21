class TrainerFadeAnimation < PokeBattle_Animation
    def initialize(sprites,viewport,ballCount,fullAnim=false)
        @fullAnim = fullAnim   # True at start of battle, false when switching
        @ballCount = ballCount
        super(sprites,viewport)
    end

    def createProcesses
        # NOTE: The movement speeds of trainers/bar/balls are all different.
        # Move trainer sprite(s) off-screen
        spriteNameBase = "trainer"
        i = 1
        while @sprites[spriteNameBase+"_#{i}"]
            trSprite = @sprites[spriteNameBase+"_#{i}"]
            i += 1
            next if !trSprite.visible || trSprite.x>Graphics.width
            trainer = addSprite(trSprite,PictureOrigin::Bottom)
            trainer.moveDelta(0,16,Graphics.width/2,0)
            trainer.setVisible(16,false)
        end
        # Move and fade party bar/balls
        delay = 6
        if @sprites["partyBar_1"] && @sprites["partyBar_1"].visible
            partyBar = addSprite(@sprites["partyBar_1"])
            partyBar.moveDelta(delay,16,Graphics.width/4,0) if @fullAnim
            partyBar.moveOpacity(delay,12,0)
            partyBar.setVisible(delay+12,false)
            partyBar.setOpacity(delay+12,255)
        end
        for i in 0...@ballCount
            next if !@sprites["partyBall_1_#{i}"] || !@sprites["partyBall_1_#{i}"].visible
            partyBall = addSprite(@sprites["partyBall_1_#{i}"])
            partyBall.moveDelta(delay+2*(i % PokeBattle_SceneConstants::NUM_BALLS),16,Graphics.width,0) if @fullAnim
            partyBall.moveOpacity(delay,12,0)
            partyBall.setVisible(delay+12,false)
            partyBall.setOpacity(delay+12,255)
        end
    end
end
