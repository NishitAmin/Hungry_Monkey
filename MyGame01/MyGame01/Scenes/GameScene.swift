//
//  GameScene.swift
//  MyGame01
//
//  Created by Xcode on 2020-10-25.
//  Copyright © 2020 Nishit Amin. All rights reserved.
//

import SpriteKit
import GameplayKit

// Add Physics categories struct
struct PhysicsCategory{
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Baddy : UInt32 = 0b1 // 1
    static let Hero : UInt32 = 0b10 // 2
    static let Banana : UInt32 = 0b11
    static let Projectile : UInt32 = 0b11 // 3
}

class StartScene: SKScene {
    
    // Declaring variables
    private var title : SKLabelNode?
    private var rules : SKLabelNode?
    private var high : SKLabelNode?
//    private var start : SKLabelNode?
    var start = SKSpriteNode(imageNamed: "start.jpeg")
    var background1 = SKSpriteNode(imageNamed: "bg02.jpg")
    
    override func didMove(to view: SKView) {
        
        background1.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        background1.alpha = 0.3
        addChild(background1)
        
        start.position = CGPoint(x: 680, y: 340)
        start.alpha = 0.5
        addChild(start)
        
        self.title = self.childNode(withName: "//title") as? SKLabelNode
        if let label1 = self.title {
            label1.alpha = 0.0
            label1.run(SKAction.fadeIn(withDuration: 2.0))
        }
        self.rules = self.childNode(withName: "//rules") as? SKLabelNode
        if let label2 = self.rules {
            label2.alpha = 0.0
            label2.run(SKAction.fadeIn(withDuration: 2.0))
        }
        self.high = self.childNode(withName: "//high") as? SKLabelNode
        if let label3 = self.high {
            label3.alpha = 0.0
            label3.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        if let highestScore = UserDefaults.standard.object(forKey: "highestScore"){
            high?.text = "Highest Score: \(highestScore)"
        } else {
            high?.text = "Highest Score: 0"
        }
//        self.start = self.childNode(withName: "//start") as? SKLabelNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           
        let touch = touches.first!
        if self.start.contains(touch.location(in: self)){
            let newScene = GameScene(fileNamed:"GameScene")
            newScene!.scaleMode = .aspectFit
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: reveal)
        }
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var background = SKSpriteNode(imageNamed: "bg02.jpg")
    private var sportNode : SKSpriteNode?
   
    private var score : Int?
    let scoreIncrement = 10
    private var lblScore : SKLabelNode?
    
    private var time : Int?
    let timeDecrement = 1
    private var lblTimer : SKLabelNode?
    
    override func didMove(to view: SKView) {
        
        background.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        background.alpha = 0.3
        addChild(background)
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        sportNode = SKSpriteNode(imageNamed: "monkey03.png")
        sportNode?.size.width = 135
        sportNode?.size.height = 117
        sportNode?.position = CGPoint(x: 162, y: 72)
        addChild(sportNode!)
        
        physicsWorld.gravity = CGVector(dx: 0,dy: 0)
        physicsWorld.contactDelegate = self
        
        sportNode?.physicsBody = SKPhysicsBody(circleOfRadius: (sportNode?.size.width)!/2)
        sportNode?.physicsBody?.isDynamic = true
        sportNode?.physicsBody?.categoryBitMask = PhysicsCategory.Hero
        sportNode?.physicsBody?.contactTestBitMask = PhysicsCategory.Baddy
        sportNode?.physicsBody?.contactTestBitMask = PhysicsCategory.Banana
        sportNode?.physicsBody?.collisionBitMask = PhysicsCategory.None
        sportNode?.physicsBody?.usesPreciseCollisionDetection = true
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addBaddy), SKAction.wait(forDuration: 1.0)])))
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(timer), SKAction.wait(forDuration: 1)])))
        
        score = 0
        self.lblScore = self.childNode(withName: "//score") as? SKLabelNode
        self.lblScore?.text = "Score: \(score!)"
        if let slabel = self.lblScore {
            slabel.alpha = 0.0
            slabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        time = 60
        self.lblTimer = self.childNode(withName: "//timer") as? SKLabelNode
        self.lblTimer?.text = "Time: \(time!)"
        if let tlabel = self.lblTimer {
            tlabel.alpha = 0.0
            tlabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xffffffff)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max-min) + min
    }
    
    func addBaddy() {
        
        if(time! % 5 == 0  && time! < 60) {
            print(time!, "- Adding a banana!")
            addBanana()
        } else {
            print(time!)
        let baddy = SKSpriteNode(imageNamed: "ant.png")
        baddy.size.width = 45
        baddy.size.height = 45
        
        let actualX = random(min: baddy.size.width/2, max: size.width-baddy.size.height/2)
        baddy.position = CGPoint(x: actualX, y: size.height + baddy.size.height/2)
        addChild(baddy)
        
        baddy.physicsBody = SKPhysicsBody(rectangleOf: baddy.size)
        baddy.physicsBody?.isDynamic = true
        baddy.physicsBody?.categoryBitMask = PhysicsCategory.Baddy
        baddy.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
        baddy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualDuration = random(min: CGFloat(2.0), max:CGFloat(4.0))
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -baddy.size.width/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        baddy.run(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    
    func addBanana() {
        
        let banana = SKSpriteNode(imageNamed: "banana02.png")
        banana.size.width = 63
        banana.size.height = 72
        
        let actualX = random(min: banana.size.width/2, max: size.width-banana.size.height/2)
        banana.position = CGPoint(x: actualX, y: size.height + banana.size.height/2)
        addChild(banana)
        
        banana.physicsBody = SKPhysicsBody(rectangleOf: banana.size)
        banana.physicsBody?.isDynamic = true
        banana.physicsBody?.categoryBitMask = PhysicsCategory.Banana
        banana.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
        banana.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualDuration = random(min: CGFloat(2.0), max:CGFloat(2.0))
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -banana.size.width/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        banana.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func timer() {
       
        if time! > 0 {
            time = time! - timeDecrement
            self.score! += 1
        }
        
        if time! == 0 {
            
            if UserDefaults.standard.object(forKey: "highestScore") != nil {
                let hscore = UserDefaults.standard.integer(forKey: "highestScore")
                if hscore <= score! {
                    UserDefaults.standard.set(score, forKey: "highestScore")
                }
            } else {
                UserDefaults.standard.set(0, forKey: "highestScore")
            }
            
            let newScene = StartScene(fileNamed:"StartScene")
            newScene!.scaleMode = .aspectFit
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: reveal)
        }
        
        self.lblTimer?.text = "Time: \(time!)"
        self.lblScore?.text = "Score: \(score!)"
        if let tlabel = self.lblTimer {
            tlabel.alpha = 0.0
            tlabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
    }
    
    func heroDidCollideWithBaddy(hero: SKSpriteNode, baddy: SKSpriteNode){
        
        print("Game Over!")
        
        if UserDefaults.standard.object(forKey: "highestScore") != nil {
            let hscore = UserDefaults.standard.integer(forKey: "highestScore")
            if hscore <= score! {
                UserDefaults.standard.set(score, forKey: "highestScore")
            }
        } else {
            UserDefaults.standard.set(0, forKey: "highestScore")
        }
        
        let newScene = StartScene(fileNamed:"StartScene")
        newScene!.scaleMode = .aspectFit
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(newScene!, transition: reveal)
        
        // need to come up with something
        // maybe have baddy grow?
    }
    
    func heroDidCollideWithBanana(hero: SKSpriteNode, banana: SKSpriteNode){
            
            print("+ 10 Points!")
            // step 11c - update score
            score = score! + scoreIncrement
            self.lblScore?.text = "Score: \(score!)"
            if let slabel = self.lblScore {
                slabel.alpha = 0.0
                slabel.run(SKAction.fadeIn(withDuration: 2.0))
            }
            // need to come up with something
            // maybe have baddy grow?
        }
        
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if((firstBody.categoryBitMask & PhysicsCategory.Baddy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Hero != 0)){
            heroDidCollideWithBaddy(hero: firstBody.node as! SKSpriteNode, baddy: secondBody.node as! SKSpriteNode)
        }
        
        if((firstBody.categoryBitMask & PhysicsCategory.Banana != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Hero != 0)){
            heroDidCollideWithBanana(hero: firstBody.node as! SKSpriteNode, banana: secondBody.node as! SKSpriteNode)
        }
    }
        
    func moveMonkey(toPoint pos : CGPoint) {
        let actionMove = SKAction.move(to: pos, duration: TimeInterval(2.0))
        sportNode?.run(SKAction.sequence([actionMove]))
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            
            let here =  t.location(in: self)
            sportNode?.position.x = here.x
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
