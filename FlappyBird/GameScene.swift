//
//  GameScene.swift
//  FlappyBird
//
//  Created by bc0067042 on 2016/06/10.
//  Copyright © 2016年 maru.ishi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    var scrollNode :SKNode!
    var wallNode:SKNode!

    override func didMoveToView(view: SKView) {

        //背景色設定
        backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.9, alpha: 1)
        
        //スクロールするスプライトの親ノード作成
        scrollNode = SKNode()
        addChild(scrollNode)
        
        
        //地面のテクスチャ作成
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        //必要な枚数を計算
        let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        let intNeedNumber = Int(needNumber) //←ここ追加
        
        
        //スクロールアクション
        //左に1画像分スクロール
        let moveGround = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: 0.5)
        //元に戻す
        let resetGround = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0)
        //上の2つを繰り返す
        let repeatScrollGround = SKAction.repeatActionForever(SKAction.sequence([moveGround, resetGround]))
        
        //ground のスプライトを配置
        for i in(0 ..< intNeedNumber){
            
            let sprite = SKSpriteNode(texture: groundTexture)
            let iFloat = CGFloat(i) //★ここ追加
            
            //スプライトの表示位置を指定
            sprite.position = CGPoint(x: iFloat * sprite.size.width, y:groundTexture.size().height / 2) //★iFloatに直した
            
            //スプライトにアクションを追加
            sprite.runAction(repeatScrollGround)
            
            //スプライトを追加
            scrollNode.addChild(sprite)
        }
//        
//        //スプライトを作成
//        let groundSprite = SKSpriteNode(texture: groundTexture)
//        
//        //スプライトの位置を指定
//        groundSprite.position = CGPoint(x: size.width / 2, y: groundTexture.size().height / 2)
//        
//        //シーンにスプライトを追加
//        addChild(groundSprite)
//        
    }
    
    func setupWall() {
        //壁の画像をテクスチャに
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .Linear
        
        //移動距離計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width * 2)
        
        //画面外まで移動するアクション生成
        let moveWall = SKAction.moveByX(-movingDistance, y: 0, duration: 4.0)
        
        //自身を取り除くアクション
        let removeWall = SKAction.removeFromParent()
        
        //2つのアニメーションを順に行う
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //壁を生成するアクションを作成
        let createWallAnimation = SKAction.runBlock({
            //壁関連のノードを載せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width * 2, y: 0.0)
            wall.zPosition = -50.0
            
            //画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            
            //壁のY座標をランダムにさせるときの最大値
            let random_y_range = self.frame.size.height / 4
            //下の壁のY軸の下限
            let under_wall_lowest_y = UInt32(center_y - wallTexture.size().height/2 - random_y_range/2 )
            //ランダムな整数を生成
            let random_y = arc4random_uniform(UInt32(random_y_range))
            //y軸の下限にランダムな値を足して下の壁のY座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            //キャラが通り抜ける隙間
            let slit_length = self.frame.size.height / 6
            
            //下の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            
            //上の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            wall.addChild(upper)
            wall.runAction(wallAnimation)
            self.wallNode.addChild(wall)
            
        })
        
        //次の壁作成までの待ち時間のアクション
        let waitAnimation = SKAction.waitForDuration(2)
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence(([createWallAnimation, waitAnimation])))
        
        runAction(repeatForeverAnimation)
        
        
    }
    
}
