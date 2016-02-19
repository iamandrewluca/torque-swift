//
//  GameScene.swift
//  Torque
//
//  Created by Andrei Luca on 2/12/16.
//  Copyright (c) 2016 allindeveloper. All rights reserved.
//

import SpriteKit

enum Objects: UInt32 {
    case Dot = 1
    case Stick = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    var isPressed: Bool = false
    var contacted: Bool = false
    var pinJoint: SKPhysicsJointPin?
    var end: SKSpriteNode?
    var begin: SKSpriteNode?
    var dot:SKSpriteNode?

    override func didMoveToView(view: SKView) {

        let bigCircleRadius: CGFloat = 10
        let smallCircleRadius: CGFloat = 5
        let distanceBetweenCircles: CGFloat = 50

        let circleShape: SKShapeNode = SKShapeNode(circleOfRadius: bigCircleRadius * UIScreen.mainScreen().scale)
        circleShape.fillColor = SKColor.whiteColor()

        let circleTexture: SKTexture = self.view!.textureFromNode(circleShape)!

        let firstDot: SKSpriteNode = SKSpriteNode(texture: circleTexture, size: CGSize(width: bigCircleRadius * 2, height: bigCircleRadius * 2))

        firstDot.position = CGPoint(x: self.frame.size.width / 2 - distanceBetweenCircles / 2, y: self.frame.size.height / 2)
        firstDot.zPosition = 0
        self.addChild(firstDot)

        firstDot.physicsBody = SKPhysicsBody(circleOfRadius: bigCircleRadius)
        firstDot.physicsBody?.dynamic = false
        firstDot.physicsBody?.affectedByGravity = false
        firstDot.physicsBody?.collisionBitMask = 0
        firstDot.physicsBody?.categoryBitMask = Objects.Dot.rawValue
        firstDot.physicsBody?.contactTestBitMask = Objects.Stick.rawValue

        let secondDot: SKSpriteNode = SKSpriteNode(texture: circleTexture, size: CGSize(width: bigCircleRadius * 2, height: bigCircleRadius * 2))

        secondDot.position = CGPoint(x: self.frame.size.width / 2 + distanceBetweenCircles / 2, y: self.frame.size.height / 2)
        secondDot.zPosition = 0
        self.addChild(secondDot)

        secondDot.physicsBody = SKPhysicsBody(circleOfRadius: bigCircleRadius)
        secondDot.physicsBody?.dynamic = false
        secondDot.physicsBody?.affectedByGravity = false
        secondDot.physicsBody?.collisionBitMask = 0
        secondDot.physicsBody?.categoryBitMask = 0
        secondDot.physicsBody?.contactTestBitMask = 0

        let stick: SKSpriteNode = SKSpriteNode(color: SKColor.greenColor(),
            size: CGSize(width: distanceBetweenCircles, height: smallCircleRadius))
        stick.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        stick.zPosition = 1
        self.addChild(stick)

        let stickBegin: SKSpriteNode = SKSpriteNode(texture: circleTexture, color: SKColor.greenColor(),
            size: CGSize(width: smallCircleRadius * 2, height: smallCircleRadius * 2))
        stickBegin.colorBlendFactor = 1
        stickBegin.position = stick.position
        stickBegin.position.x -= stick.size.width / 2
        stickBegin.zPosition = 2
        self.addChild(stickBegin)

        let stickEnd: SKSpriteNode = SKSpriteNode(texture: circleTexture, color: SKColor.greenColor(),
            size: CGSize(width: smallCircleRadius * 2, height: smallCircleRadius * 2))
        stickEnd.colorBlendFactor = 1
        stickEnd.position = stick.position
        stickEnd.position.x += stick.size.width / 2
        stickEnd.zPosition = 2
        self.addChild(stickEnd)

        stick.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: distanceBetweenCircles, height: smallCircleRadius))
        stick.physicsBody?.collisionBitMask = 0
        stick.physicsBody?.categoryBitMask = 0
        stick.physicsBody?.contactTestBitMask = 0

        stickBegin.physicsBody = SKPhysicsBody(circleOfRadius: smallCircleRadius)
        stickBegin.physicsBody?.collisionBitMask = 0
        stickBegin.physicsBody?.categoryBitMask = Objects.Stick.rawValue
        stickBegin.physicsBody?.contactTestBitMask = Objects.Dot.rawValue

        stickEnd.physicsBody = SKPhysicsBody(circleOfRadius: smallCircleRadius)
        stickEnd.physicsBody?.collisionBitMask = 0
        stickEnd.physicsBody?.categoryBitMask = Objects.Stick.rawValue
        stickEnd.physicsBody?.contactTestBitMask = Objects.Dot.rawValue

        let beginToStickJoint: SKPhysicsJointFixed = SKPhysicsJointFixed.jointWithBodyA(stickBegin.physicsBody!,
            bodyB: stick.physicsBody!, anchor: stickBegin.position)

        self.physicsWorld.addJoint(beginToStickJoint)

        let endToStickJoint: SKPhysicsJointFixed = SKPhysicsJointFixed.jointWithBodyA(stickEnd.physicsBody!,
            bodyB: stick.physicsBody!, anchor: stickEnd.position)

        self.physicsWorld.addJoint(endToStickJoint)

        let beginToDotJointPin: SKPhysicsJointPin = SKPhysicsJointPin.jointWithBodyA(firstDot.physicsBody!,
            bodyB: stickBegin.physicsBody!, anchor: firstDot.position)

        self.physicsWorld.addJoint(beginToDotJointPin)

        pinJoint = beginToDotJointPin

        begin = stickBegin
        end = stickEnd
        dot = secondDot
    }

    func didBeginContact(contact: SKPhysicsContact) {
        debugPrint("begin contact")
        contacted = true
    }

    func didEndContact(contact: SKPhysicsContact) {
        debugPrint("end contact")
        contacted = false
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isPressed = true
        dot?.physicsBody?.categoryBitMask = Objects.Dot.rawValue
        dot?.physicsBody?.contactTestBitMask = Objects.Stick.rawValue
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isPressed = false
    }

    override func update(currentTime: NSTimeInterval) {
        if (isPressed) {
            debugPrint("update", currentTime)
            end?.physicsBody?.applyTorque(0.022)
        }
    }

    override func didSimulatePhysics() {
        if (contacted) {
            if (abs(end!.position.x - dot!.position.x) < 3 &&
                abs(end!.position.y - dot!.position.y) < 3) {
                end!.position = dot!.position
                let endToDotJointPin: SKPhysicsJointPin = SKPhysicsJointPin.jointWithBodyA(dot!.physicsBody!,
                    bodyB: end!.physicsBody!, anchor: dot!.position)
                
                self.physicsWorld.addJoint(endToDotJointPin)
            }
        }
    }
}
