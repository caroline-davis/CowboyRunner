//
//  GameplayScene.swift
//  CowboyRunner
//
//  Created by Caroline Davis on 15/03/2017.
//  Copyright © 2017 Caroline Davis. All rights reserved.
//

import SpriteKit

class GameplayScene: SKScene, SKPhysicsContactDelegate {
    
    var player = Player()
    var obstacles = [SKSpriteNode]()
    
    var scoreLabel = SKLabelNode()
    var score = Int()
    
    var canJump = false
    var movePlayer = false
    var playerOnObstacle = false
    
    var isAlive = false
    
    var spawner = Timer()
    var counter = Timer()
    
    var pausePanel = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        initialize()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isAlive {
            moveBackgroundsAndGrounds()
        }
        if movePlayer {
            player.position.x -= 9
        }
        
        checkPlayersBounds()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
        
            // instead of touch.locationInNode(self)
        let location = touch.location(in: self)
            
            // opens the game
            if atPoint(location).name == "Restart" {
              let gameplay = GameplayScene(fileNamed: "GameplayScene")
                gameplay!.scaleMode = .aspectFill
                self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)))
            
            }
            // opens the main menu
            if atPoint(location).name == "Quit" {
                let gameplay = MainMenuScene(fileNamed: "MainMenuScene")
                gameplay!.scaleMode = .aspectFill
                self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)))
                
            }
            
            if atPoint(location).name == "Pause" {
                createPausePanel()
                // stop sprite jumping when resume happens.
            }

            
            if atPoint(location).name == "Resume" {
                pausePanel.removeFromParent()
                self.scene?.isPaused = false
                
                spawner = Timer.scheduledTimer(timeInterval: TimeInterval(randomBetweenNumbers(firstNumber: 2.5, secondNumber: 6)), target: self, selector: #selector(spawnObstacles), userInfo: nil, repeats: true)
                
                // increments the score
                counter = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(incrementScore), userInfo: nil, repeats: true)

            }

            
        }
        
        if canJump == true {
            // so it can only jump once when it hits the ground, not multiple times. like superman
            canJump = false
            player.jump()
            
        }
        // now we can jump off obstacle
        if playerOnObstacle {
            player.jump()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // need this to make physicsbody delegate to work for the jumping
        
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "Player" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Ground" {
            // can jump will only be true when it is on the ground
            canJump = true
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obstacle" {
            // if we are on top of the obstacle canjump wont be true because it wont be on the ground it will be on the obstacle.
            if !canJump {
                movePlayer = true
                // when this is set to true, in touches began player can now jump as canjump is set to true when playeronobstacle is set to true
                playerOnObstacle = true
                
            }
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Cactus" {
            // kill the player and prompt buttons for restarting or quitting
            playerDied()
        }
    }
    
    // resets everything to before the obstacle
    func didEnd(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "Player" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obstacle" {
            movePlayer = false
            playerOnObstacle = false
            
        }

    }
    
    func initialize(){
        // need this to make the jumping work!!!
        physicsWorld.contactDelegate = self
        
        isAlive = true
        
        createBg()
        createGrounds()
        createPlayer()
        createObstacles()
        getLabel()
        
        spawner = Timer.scheduledTimer(timeInterval: TimeInterval(randomBetweenNumbers(firstNumber: 2.5, secondNumber: 6)), target: self, selector: #selector(spawnObstacles), userInfo: nil, repeats: true)
        
        // increments the score
        counter = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(incrementScore), userInfo: nil, repeats: true)
    }
    
    func createPlayer() {
        player = Player(imageNamed: "Player 1")
        player.initialize()
        player.position = CGPoint(x: -10, y: 20)
        self.addChild(player)
    }
    
    
    func createBg() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "BG")
            bg.name = "BG"
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            //  allows all backgrounds to come after the other on the horizontal scale
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 0)
            bg.zPosition = 0
       
            self.addChild(bg)
            
        }
    }
    
    func createGrounds() {
        for i in 0...2 {
            let ground = SKSpriteNode(imageNamed: "Ground")
            ground.name = "Ground"
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            //  allows all backgrounds to come after the other on the horizontal scale
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: -(self.frame.size.height / 2))
            ground.zPosition = 3
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.affectedByGravity = false
            // stops the player pushing the ground down cos he's heavy
            ground.physicsBody?.isDynamic = false
            ground.physicsBody?.categoryBitMask = ColliderType.Ground
            
            
            self.addChild(ground)
            
        }
    }
    
    func moveBackgroundsAndGrounds() {
        enumerateChildNodes(withName: "BG", using: ({
            (node, error) in
            
            // can add this instead of doing "node" below
            // let bgNode = node as! SKSpriteNode
            
            // any code we put here will be executed for the specific child "BG"
            node.position.x -= 4
            
            // pushes background off screen then adds it to the end again
            if node.position.x < -(self.frame.width) {
                node.position.x += self.frame.width * 3
            }
            
            
        }))
        
        enumerateChildNodes(withName: "Ground", using: ({
            (node, error) in
    
            
            // any code we put here will be executed for the specific child "BG"
            node.position.x -= 2
            
            // pushes background off screen then adds it to the end again
            if node.position.x < -(self.frame.width) {
                node.position.x += self.frame.width * 3
            }
            
            
        }))

    }
    
    func createObstacles() {
        
        for i in 0...5 {
            
            let obstacle = SKSpriteNode(imageNamed: "Obstacle \(i)")
            
            if i == 0 {
                obstacle.name = "Cactus"
                obstacle.setScale(0.4)
            } else {
                obstacle.name = "Obstacle"
                obstacle.setScale(0.5)
            }
            
            obstacle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            obstacle.zPosition = 1
            
            obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
            obstacle.physicsBody?.allowsRotation = false
            obstacle.physicsBody?.categoryBitMask = ColliderType.Obstacle
            
            obstacles.append(obstacle)
         
            
        }
        
    }
    
    func spawnObstacles() {
        
        // returns a random number
        let index = Int(arc4random_uniform(UInt32(obstacles.count)))
        
        // need to put .copy() or app crashes - it cant add more than 1 of the same obstacle
        let obstacle = obstacles[index].copy() as! SKSpriteNode
        
        obstacle.position = CGPoint(x: self.frame.width + obstacle.size.width, y: 50)
        
        let move = SKAction.moveTo(x: -(self.frame.size.width * 2), duration: TimeInterval(15))
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move, remove])
        
        obstacle.run(sequence)
        
        self.addChild(obstacle)
    }
    
    func randomBetweenNumbers(firstNumber: CGFloat, secondNumber: CGFloat) -> CGFloat{
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
        
    }
    
    func checkPlayersBounds() {
        if isAlive {
            if player.position.x < -(self.frame.width / 2) - 35 {
                playerDied()
            }
        }
    }
    
    func getLabel() {
        scoreLabel = self.childNode(withName: "Score Label") as! SKLabelNode
        scoreLabel.text = "0M"
    }
    
    func incrementScore() {
        score += 1
        scoreLabel.text = "\(score)M"
    }
    
    
    func createPausePanel() {
        
        self.scene?.isPaused = true
        
        spawner.invalidate()
        counter.invalidate()
        
        pausePanel = SKSpriteNode(imageNamed: "Pause Panel")
        pausePanel.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pausePanel.position = CGPoint(x: 0, y: 0)
        pausePanel.zPosition = 10
        
        let resume = SKSpriteNode(imageNamed: "Play")
        let quit = SKSpriteNode(imageNamed: "Quit")
        
        resume.name = "Resume"
        resume.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        resume.position = CGPoint(x: -155, y: 0)
        resume.setScale(0.75)
        resume.zPosition = 9
        
        quit.name = "Quit"
        quit.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        quit.position = CGPoint(x: 155, y: 0)
        quit.setScale(0.75)
        quit.zPosition = 9
        
        // adding the children (resume and quit) to the pause panel
        pausePanel.addChild(resume)
        pausePanel.addChild(quit)
        
        // adding the pause panel to the scene
        self.addChild(pausePanel)
        
    }
    func playerDied() {
        
        let highScore = UserDefaults.standard.integer(forKey: "Highscore")
        
        // sets the current score if the highscore is lower than this
        if highScore < score {
            UserDefaults.standard.set(score, forKey: "Highscore")
        }
        
        player.removeFromParent()
        
        // gets rid of the current obstacles on the screen when player dies
        for child in children {
            if child.name == "Obstacle" || child.name == "Cactus" {
                child.removeFromParent()
            }
        }
        
        // stops the repeating of the spawning of the objects
        // stops the score incrementing
        spawner.invalidate()
        counter.invalidate()
        
        isAlive = false
        
        let restart = SKSpriteNode(imageNamed: "Restart")
        let quit = SKSpriteNode(imageNamed: "Quit")
        
        restart.name = "Restart"
        restart.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        restart.position = CGPoint(x: -200, y: -150)
        restart.zPosition = 10
        restart.setScale(0)
        
        quit.name = "Quit"
        quit.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        quit.position = CGPoint(x: 200, y: -150)
        quit.zPosition = 10
        quit.setScale(0)
        
        let scaleUp = SKAction.scale(to: 1, duration: TimeInterval(0.5))
        
        restart.run(scaleUp)
        quit.run(scaleUp)
        
        self.addChild(restart)
        self.addChild(quit)
    }
    
}







