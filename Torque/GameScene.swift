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

    let bigCircleRadius: CGFloat = 10
    let smallCircleRadius: CGFloat = 5
    let distanceBetweenCircles: CGFloat = 50

    var isPressed: Bool = false
    var contacted: Bool = false
    var pinJoint: SKPhysicsJointPin?
    var end: SKSpriteNode?
    var begin: SKSpriteNode?
    var currentDot: SKSpriteNode?
    var contactedDot: SKSpriteNode?

    override func didMoveToView(view: SKView) {

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
        firstDot.physicsBody?.allowsRotation = false
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
        secondDot.physicsBody?.allowsRotation = false
        secondDot.physicsBody?.collisionBitMask = 0
        secondDot.physicsBody?.categoryBitMask = Objects.Dot.rawValue
        secondDot.physicsBody?.contactTestBitMask = Objects.Stick.rawValue

        let stick: SKSpriteNode = SKSpriteNode(color: SKColor.greenColor(),
            size: CGSize(width: smallCircleRadius, height: distanceBetweenCircles))
        stick.position = firstDot.position
        stick.position.y -= stick.size.height / 2
        stick.zPosition = 1
        self.addChild(stick)

        let stickBegin: SKSpriteNode = SKSpriteNode(texture: circleTexture, color: SKColor.greenColor(),
            size: CGSize(width: smallCircleRadius * 2, height: smallCircleRadius * 2))
        stickBegin.colorBlendFactor = 1
        stickBegin.position = stick.position
        stickBegin.position.y += stick.size.height / 2
        stickBegin.zPosition = 2
        self.addChild(stickBegin)

        let stickEnd: SKSpriteNode = SKSpriteNode(texture: circleTexture, color: SKColor.greenColor(),
            size: CGSize(width: smallCircleRadius * 2, height: smallCircleRadius * 2))
        stickEnd.colorBlendFactor = 1
        stickEnd.position = stick.position
        stickEnd.position.y -= stick.size.height / 2
        stickEnd.zPosition = 2
        self.addChild(stickEnd)

        stick.physicsBody = SKPhysicsBody(rectangleOfSize: stick.size)
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

        stickBegin.physicsBody?.usesPreciseCollisionDetection = true
        stickEnd.physicsBody?.usesPreciseCollisionDetection = true
        firstDot.physicsBody?.usesPreciseCollisionDetection = true
        secondDot.physicsBody?.usesPreciseCollisionDetection = true

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
        currentDot = firstDot


        end?.physicsBody?.applyImpulse(CGVector(dx: 1, dy: 0))
    }

    func didBeginContact(contact: SKPhysicsContact) {
        debugPrint("begin contact")
        contacted = true
        contactedDot = contact.bodyA.node as? SKSpriteNode
    }

    func didEndContact(contact: SKPhysicsContact) {
        debugPrint("end contact")
        contacted = false
        contactedDot = nil
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        isPressed = true
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
            if (true) {

                end!.position = contactedDot!.position
                let endToDotJointPin: SKPhysicsJointPin = SKPhysicsJointPin.jointWithBodyA(contactedDot!.physicsBody!,
                    bodyB: end!.physicsBody!, anchor: contactedDot!.position)
                self.physicsWorld.addJoint(endToDotJointPin)
                self.physicsWorld.removeJoint(pinJoint!)

                pinJoint = endToDotJointPin

                currentDot = contactedDot
                contactedDot = nil

                swap(&begin, &end)

                end?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2))

                contacted = false
            }

        }
    }
}
