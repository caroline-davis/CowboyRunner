//
//  MainMenuScene.swift
//  CowboyRunner
//
//  Created by Caroline Davis on 17/03/2017.
//  Copyright © 2017 Caroline Davis. All rights reserved.
//

import SpriteKit

    var playBtn = SKSpriteNode()
    var scoreBtn = SKSpriteNode()
    var title = SKLabelNode()
    var scoreLabel = SKLabelNode()

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        initialize()
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveBackgroundsAndGrounds()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // presents the game when the play button is touched
        
        for touch in touches {
            let location = touch.location(in: self)
            if atPoint(location) == playBtn {
                let gameplay = GameplayScene(fileNamed: "GameplayScene")
                gameplay?.scaleMode = .aspectFill
                 self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)))
            }
            
             if atPoint(location) == scoreBtn {
                // shows the highscore
                showScore()
                
            }
        }
    }
    
    func initialize() {
        createBg()
        createGrounds()
        getButtons()
        getLabel()
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
    
    func getButtons() {
        playBtn = self.childNode(withName: "Play") as! SKSpriteNode
        scoreBtn = self.childNode(withName: "Score") as! SKSpriteNode
    }
    
    func getLabel() {
        title = self.childNode(withName: "Title") as! SKLabelNode
        
        title.fontName = "RosewoodStd-Regular"
        title.fontSize = 120
        title.text = "Cowboy Runner"
        title.zPosition = 5
        
        let moveUp = SKAction.moveTo(y: title.position.y + 50, duration: TimeInterval(1.3))
        let moveDown = SKAction.moveTo(y: title.position.y - 50, duration: TimeInterval(1.3))
        
        let sequence = SKAction.sequence([moveUp, moveDown])
        
        title.run(SKAction.repeatForever(sequence))
    }
    
    func showScore() {
        scoreLabel.removeFromParent()
        scoreLabel = SKLabelNode(fontNamed: "RosewoodStd-Regular")
        scoreLabel.fontSize = 180
        // gets the score
        scoreLabel.text = "\(UserDefaults.standard.integer(forKey: "Highscore"))"
        scoreLabel.position = CGPoint(x: 0, y: -200)
        scoreLabel.zPosition = 9
        self.addChild(scoreLabel)
    }

}


















