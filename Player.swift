//
//  Player.swift
//  CowboyRunner
//
//  Created by Caroline Davis on 16/03/2017.
//  Copyright © 2017 Caroline Davis. All rights reserved.
//

import SpriteKit

struct ColliderType {
    static let Player: UInt32 = 1
    static let Ground: UInt32 = 2
    static let Obstacle: UInt32 = 3
    
}

class Player: SKSpriteNode {
    
    
    func initialize() {
        self.name = "Player"
        self.zPosition = 2
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // makes the player sprite smaller
        self.setScale(0.5)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width - 20, height:self.size.height))
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        // the player type player can hit the obstacle and the ground. Then we are told if it has collided.
        self.physicsBody?.categoryBitMask = ColliderType.Player
        self.physicsBody?.collisionBitMask = ColliderType.Ground | ColliderType.Obstacle
        self.physicsBody?.contactTestBitMask = ColliderType.Ground | ColliderType.Obstacle
        
        
    }
    
    func jump() {
        
        
        // need to normalise velocity, otherwise they get too much boost when it jumps
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
        
        
    }
    
   
    
}






