import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let background = SKSpriteNode(imageNamed: "background.jpg")
    var stockLabel: SKLabelNode!
    var stock = 5 {
        didSet {
            if let newStock = stockLabel {
                stockLabel.text = "Balls: \(stock)"
            }
        }
    }
    let balls: [SKSpriteNode] = [SKSpriteNode(imageNamed: "ballRed"),SKSpriteNode(imageNamed: "ballGrey"),SKSpriteNode(imageNamed: "ballBlue"),SKSpriteNode(imageNamed: "ballPurple"),SKSpriteNode(imageNamed: "ballYellow"),SKSpriteNode(imageNamed: "ballCyan"),SKSpriteNode(imageNamed: "ballGreen")]
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            if let newScore = scoreLabel {
                scoreLabel.text = "Score: \(score)"
            }
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        makeBouncer(at: CGPoint(x: 0, y: 0) )
        makeBouncer(at: CGPoint(x: 256, y: 0) )
        makeBouncer(at: CGPoint(x: 512, y: 0) )
        makeBouncer(at: CGPoint(x: 768, y: 0) )
        makeBouncer(at: CGPoint(x: 1024, y: 0) )
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        stockLabel = SKLabelNode(fontNamed: "Chalkduster")
        stockLabel.text = "Balls: 5"
        stockLabel.horizontalAlignmentMode = .right
        stockLabel.position = CGPoint(x: 980, y: 600)
        addChild(stockLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        physicsWorld.contactDelegate = self

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let objects = nodes(at: location)
        if objects.contains(editLabel) {
            editingMode = !editingMode
        } else {
            if editingMode {
                if objects[0].name == "box" {
                    objects[0].removeFromParent()
                } else {
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    box.name = "box"
                    addChild(box)
                }
            } else {
                    if objects.contains(editLabel) {
                        editingMode = !editingMode
                    } else {
//                        let ball = SKSpriteNode(imageNamed: "ballRed")
                        if stock > 0 {
                            if let ball = balls.randomElement() {
                                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                                ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                                ball.physicsBody?.restitution = 0.4
                                ball.position = CGPoint(x: location.x, y: frame.height)
                                ball.name = "ball"
                                addChild(ball)
                                stock -= 1
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            stock += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        } else if object.name == "box"{
            object.removeFromParent()
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if contact.bodyB.node?.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
}
