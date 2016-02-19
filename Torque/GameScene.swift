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

    var pinJoint: SKPhysicsJointPin?

    override func didMoveToView(view: SKView) {

        let circleRadius: CGFloat = 5

        let circleShape: SKShapeNode = SKShapeNode(circleOfRadius: circleRadius)
        circleShape.fillColor = SKColor.whiteColor()

        let circleTexture: SKTexture = self.view!.textureFromNode(circleShape)!

        let middleDot: SKSpriteNode = SKSpriteNode(texture: circleTexture)
//        middleDot.position.y = 100
        middleDot.physicsBody = SKPhysicsBody(circleOfRadius: circleRadius)
        middleDot.physicsBody?.dynamic = false
        middleDot.physicsBody?.affectedByGravity = false
        middleDot.physicsBody?.collisionBitMask = 0
        middleDot.physicsBody?.categoryBitMask = 0
        middleDot.physicsBody?.contactTestBitMask = 0

        self.addChild(middleDot)

        let distanceBetweenCircles: CGFloat = 40

        var coordinatesMatrix: [[CGPoint]] = Array(count: 5,
            repeatedValue: Array(count: 5, repeatedValue: CGPoint.zero))

        for i in 1..<3 {

            coordinatesMatrix[2][2 + i].x = coordinatesMatrix[2][2 + i - 1].x + distanceBetweenCircles * cos(0)
            coordinatesMatrix[2][2 + i].y = coordinatesMatrix[2][2 + i - 1].y

            coordinatesMatrix[2][2 - i].x = coordinatesMatrix[2][2 - i + 1].x + distanceBetweenCircles * cos(CGFloat(M_PI))
            coordinatesMatrix[2][2 - i].y = coordinatesMatrix[2][2 - i + 1].y

            coordinatesMatrix[2 - i][2].x = coordinatesMatrix[2 - i + 1][2].x + distanceBetweenCircles * cos(CGFloat(2/3 * M_PI))
            coordinatesMatrix[2 - i][2].y = coordinatesMatrix[2 - i + 1][2].y + distanceBetweenCircles * sin(CGFloat(2/3 * M_PI))

            coordinatesMatrix[2 + i][2].x = coordinatesMatrix[2 + i - 1][2].x + distanceBetweenCircles * cos(CGFloat(5/3 * M_PI))
            coordinatesMatrix[2 + i][2].y = coordinatesMatrix[2 + i - 1][2].y + distanceBetweenCircles * sin(CGFloat(5/3 * M_PI))

            coordinatesMatrix[2 + i][2 + i].x = coordinatesMatrix[2 + i - 1][2 + i - 1].x + distanceBetweenCircles * cos(CGFloat(4/3 * M_PI))
            coordinatesMatrix[2 + i][2 + i].y = coordinatesMatrix[2 + i - 1][2 + i - 1].y + distanceBetweenCircles * sin(CGFloat(4/3 * M_PI))

            coordinatesMatrix[2 - i][2 - i].x = coordinatesMatrix[2 - i + 1][2 - i + 1].x + distanceBetweenCircles * cos(CGFloat(M_PI / 3))
            coordinatesMatrix[2 - i][2 - i].y = coordinatesMatrix[2 - i + 1][2 - i + 1].y + distanceBetweenCircles * sin(CGFloat(M_PI / 3))
        }

        for i in 0 ... 4  {
            for j in 0 ... 4 {

                if coordinatesMatrix[i][j] == CGPoint.zero {
                    continue
                }

                let dot = SKSpriteNode(texture: circleTexture)
                dot.position = coordinatesMatrix[i][j]

                dot.physicsBody = SKPhysicsBody(circleOfRadius: circleRadius)
                dot.physicsBody?.dynamic = false
                dot.physicsBody?.affectedByGravity = false

                // dont collide
                dot.physicsBody?.collisionBitMask = 0
                // what type of object
                dot.physicsBody?.categoryBitMask = Objects.Dot.rawValue
                // trigger collision with
//                dot.physicsBody?.contactTestBitMask = Objects.Stick.rawValue

                self.addChild(dot)
            }
        }

        let borderWidth: CGFloat = 3
        let diffBetweenCircles: CGFloat = 1
        let endsCirclesRadius: CGFloat = circleRadius + diffBetweenCircles + borderWidth

        let endsCircles: SKShapeNode = SKShapeNode(circleOfRadius: endsCirclesRadius)
        endsCircles.lineWidth = borderWidth
        let endsCirclesTexture = self.view?.textureFromNode(endsCircles)

        let stickHeight: CGFloat = distanceBetweenCircles - endsCirclesRadius * 2
        let middleStick: SKSpriteNode = SKSpriteNode(color: SKColor.whiteColor(), size: CGSize(width: borderWidth, height: stickHeight))

        let end1: SKSpriteNode = SKSpriteNode(texture: endsCirclesTexture)
        end1.position.y += middleStick.size.height / 2 + endsCirclesRadius

        let end2: SKSpriteNode = SKSpriteNode(texture: endsCirclesTexture)
        end2.position.y -= middleStick.size.height / 2 + endsCirclesRadius

        self.addChild(middleStick)
        middleStick.addChild(end1)
        middleStick.addChild(end2)

        middleStick.position.y -= distanceBetweenCircles / 2

        middleStick.physicsBody = SKPhysicsBody(rectangleOfSize: middleStick.size)
        middleStick.physicsBody?.collisionBitMask = 0
        end1.physicsBody = SKPhysicsBody(circleOfRadius: endsCirclesRadius)
        end1.physicsBody?.collisionBitMask = 0
        end2.physicsBody = SKPhysicsBody(circleOfRadius: endsCirclesRadius)
        end2.physicsBody?.collisionBitMask = 0

        end1.physicsBody?.categoryBitMask = Objects.Stick.rawValue
        end2.physicsBody?.categoryBitMask = Objects.Stick.rawValue

        end1.physicsBody?.contactTestBitMask = Objects.Dot.rawValue
        end2.physicsBody?.contactTestBitMask = Objects.Dot.rawValue

        let stickFixedJoint1: SKPhysicsJointFixed = SKPhysicsJointFixed.jointWithBodyA(end1.physicsBody!,
            bodyB: middleStick.physicsBody!, anchor: CGPoint.zero)
        let stickFixedJoint2: SKPhysicsJointFixed = SKPhysicsJointFixed.jointWithBodyA(middleStick.physicsBody!,
            bodyB: end2.physicsBody!, anchor: CGPoint.zero)

        let dotEndJointPin: SKPhysicsJointPin = SKPhysicsJointPin.jointWithBodyA(middleDot.physicsBody!,
            bodyB: end1.physicsBody!, anchor: CGPoint.zero)

        self.physicsWorld.addJoint(stickFixedJoint1)
        self.physicsWorld.addJoint(stickFixedJoint2)

        self.physicsWorld.addJoint(dotEndJointPin)

        dotEndJointPin.rotationSpeed = -CGFloat(M_PI / 4)
        dotEndJointPin.frictionTorque = 1.0

        pinJoint = dotEndJointPin
    }

    func didBeginContact(contact: SKPhysicsContact) {

    }

    func didEndContact(contact: SKPhysicsContact) {
//        debugPrint("end contact")
    }
}
