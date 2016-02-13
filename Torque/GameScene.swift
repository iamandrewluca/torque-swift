//
//  GameScene.swift
//  Torque
//
//  Created by Andrei Luca on 2/12/16.
//  Copyright (c) 2016 allindeveloper. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {

        let circleShape: SKShapeNode = SKShapeNode(circleOfRadius: 5)
        circleShape.fillColor = SKColor.whiteColor()

        let circleTexture: SKTexture = self.view!.textureFromNode(circleShape)!

        let middleDot: SKSpriteNode = SKSpriteNode(texture: circleTexture)
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
                self.addChild(dot)
            }
        }
    }
}
