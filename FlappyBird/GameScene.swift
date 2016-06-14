//
//  GameScene.swift
//  FlappyBird
//
//  Created by bc0067042 on 2016/06/10.
//  Copyright © 2016年 maru.ishi. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var scrollNode :SKNode!
    var wallNode:SKNode!
    var itemNode:SKNode!
    var bird:SKSpriteNode!
    
    //衝突判定カテゴリの追加
    let birdCategory: UInt32 = 1<<0 //0...00001 この記述法って何？★
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let itemCategory: UInt32 = 1 << 4

    //スコアの定義
    var score = 0
    var itemScore = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemScoreLabelNode:SKLabelNode!
    
    //ハイスコア
    let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    override func didMoveToView(view: SKView) {
        
        //重力設定
        physicsWorld.gravity = CGVector(dx:0.0, dy: -4.0)
        physicsWorld.contactDelegate = self

        //背景色設定
        backgroundColor = UIColor(colorLiteralRed: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //スクロールするスプライトの親ノード作成
        scrollNode = SKNode()
        addChild(scrollNode)

        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        itemNode = SKNode()
        scrollNode.addChild(itemNode)


        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupScoreLabel()
        setupItem()
    }
    
    
    func setupGround(){
        
        //地面のテクスチャ作成
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        //必要な枚数を計算
        let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        let intNeedNumber = Int(needNumber) + 1 //←ここ追加
        
        
        //スクロールアクション
        //左に1画像分スクロール
        let moveGround = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: 5.0)
        //元に戻す
        let resetGround = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0.0)
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
            
            //物理演算を追加
            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: groundTexture.size())
            
            //衝突時に動かない設定
            sprite.physicsBody?.dynamic = false //★なぜ?がいる？
            
            //衝突のカテゴリ設定
            sprite.physicsBody?.categoryBitMask = groundCategory

            //スプライトを追加
            scrollNode.addChild(sprite)
        }

    }
    
    func setupCloud(){
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        let moveCloud = SKAction.moveByX(-cloudTexture.size().width, y: 0, duration: 20.0)
        let resetCloud = SKAction.moveByX(cloudTexture.size().width, y: 0, duration: 0.0)
        
        let repeateScrollCloud = SKAction.repeatActionForever(SKAction.sequence([moveCloud, resetCloud]))
        
        for var i:CGFloat = 0; i < needCloudNumber; i += 1{
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            
            sprite.position = CGPoint(x: i * sprite.size.width, y: size.height - cloudTexture.size().height / 2)
            sprite.runAction(repeateScrollCloud)
            scrollNode.addChild(sprite)
        }
    }
    
    
    func setupWall() {
        //壁の画像をテクスチャに
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .Linear
        
        //移動距離計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width * 2.5)
        
        //画面外まで移動するアクション生成
        let moveWall = SKAction.moveByX(-movingDistance, y: 0, duration: 5.0)
        
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
            let under_wall_lowest_y = UInt32(center_y - wallTexture.size().height/2 - random_y_range / 2 )
            //ランダムな整数を生成
            let random_y = arc4random_uniform(UInt32(random_y_range))
            //y軸の下限にランダムな値を足して下の壁のY座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            //キャラが通り抜ける隙間
            let slit_length = self.frame.size.height / 4
            
            //下の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)

            //物理演算の設定
            under.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突時に動かないよう設定
            under.physicsBody?.dynamic = false
            
            
            //上の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            //物理演算の設定
            upper.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory

            
            //衝突時に動かないよう設定
            upper.physicsBody?.dynamic = false
            
            wall.addChild(upper)
            
            //スコア計算
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width/2, y: self.frame.height / 2.0)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.dynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.runAction(wallAnimation)
            
            self.wallNode.addChild(wall)
            
        })
        
        
        //次の壁作成までの待ち時間のアクション
        let waitAnimation = SKAction.waitForDuration(2)
        
        //壁の作成->待ち->壁を繰り返す
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        runAction(repeatForeverAnimation)
        
        
    }
    
    func setupBird() {
        //鳥の画像を読み込み
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = SKTextureFilteringMode.Linear
        let bireTextureB = SKTexture(imageNamed: "bird_b")
        bireTextureB.filteringMode = SKTextureFilteringMode.Linear
        
        //2つのテクスチャを交互に変更
        let textureAnimation = SKAction.animateWithTextures([birdTextureA, bireTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatActionForever(textureAnimation)
        
        //スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: 30, y: self.frame.size.height * 0.7)
        
        //物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        //衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリ設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask =  groundCategory | wallCategory
        
        
        //アニメーション設定
        bird.runAction(flap)
        
        //スプライトを追加
        addChild(bird)
        
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if scrollNode.speed > 0 {
            //鳥の速度を0にする
            bird.physicsBody?.velocity = CGVector.zero
            
            //鳥に縦方向の力を加える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        } else if bird.speed == 0 {
            restart()
        }
    }
    
    //SKPhysicsContactDelegeteのメソッド　衝突処理
    func didBeginContact(contact: SKPhysicsContact) {

        //gameover時は何もしない
        if scrollNode.speed <= 0 {
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            //スコア用物体との衝突
            print("score up")
            score = score + 1
            scoreLabelNode.text = "score:\(score)"
            
            //ベストスコアの更新
            var bestScore = userDefaults.integerForKey("BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "best score:\(bestScore)"
                userDefaults.setInteger(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
            
        } else {
            //壁か地面との衝突
            print("game over")
            
            //スクロールを停止
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groundCategory
            
            let roll = SKAction.rotateByAngle(CGFloat(M_PI) * CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.runAction(roll, completion: { //★この記法は何？
                self.bird.speed = 0
            })
        }
    }
    
    func restart(){
        score = 0
        scoreLabelNode.text = String("score:\(score)") // ←追加
        
        // bird.position = CGPoint(x: 30, y: self.frame.size.height * 0.7)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7) //30ではない？
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1

        
    }
    
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.blackColor()
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabelNode.text = "score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.blackColor()
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        
        let bestScore = userDefaults.integerForKey("BEST")
        bestScoreLabelNode.text = "best score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.blackColor()
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        itemScoreLabelNode.zPosition = 100
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        itemScoreLabelNode.text = "item score:\(score)"
        self.addChild(itemScoreLabelNode)
        
    }
    
    func setupItem() {
        
        let itemTexture = SKTexture(imageNamed: "item")
        itemTexture.filteringMode = .Linear
        
        //移動距離計算
        let movingDistance = CGFloat(self.frame.size.width + itemTexture.size().width * 2.5)
        
        //画面外まで移動するアクション生成
        let moveItem = SKAction.moveByX(-movingDistance, y: 0, duration: 4.0)
        
        //自身を取り除くアクション
        let removeItem = SKAction.removeFromParent()
        
        //2つのアニメーションを順に行う
        let itemAnimation = SKAction.sequence([moveItem, removeItem])
        
        //壁を生成するアクションを作成
        let createItemAnimation = SKAction.runBlock({
            //壁関連のノードを載せるノードを作成
            let item = SKNode()
            item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width * 2, y: 0.0)
            item.zPosition = -30.0
            
            //画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            
            //壁のY座標をランダムにさせるときの最大値
            let random_y_range = self.frame.size.height / 4
//            //下の壁のY軸の下限
//            let under_wall_lowest_y = UInt32(center_y - wallTexture.size().height/2 - random_y_range / 2 )
            //ランダムな整数を生成
            let random_y = arc4random_uniform(UInt32(random_y_range))
//            //y軸の下限にランダムな値を足して下の壁のY座標を決定
//            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
//            //キャラが通り抜ける隙間
//            let slit_length = self.frame.size.height / 4
//            
//            //下の壁を作成
            let itemSprite = SKSpriteNode(texture: itemTexture)
            itemSprite.position = CGPoint(x: 0.0, y: CGFloat(random_y)*2)
            item.addChild(itemSprite)
            
            //物理演算の設定
            itemSprite.physicsBody = SKPhysicsBody(rectangleOfSize: itemTexture.size())
            itemSprite.physicsBody?.categoryBitMask = self.itemCategory
            
            //衝突時に動かないよう設定
            itemSprite.physicsBody?.dynamic = false
            
            
//            //上の壁を作成
//            let upper = SKSpriteNode(texture: wallTexture)
//            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
//            
//            //物理演算の設定
//            upper.physicsBody = SKPhysicsBody(rectangleOfSize: wallTexture.size())
//            upper.physicsBody?.categoryBitMask = self.wallCategory
//            
//            
//            //衝突時に動かないよう設定
//            upper.physicsBody?.dynamic = false
//            
//            wall.addChild(upper)
            
//            //スコア計算
//            let scoreNode = SKNode()
//            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width/2, y: self.frame.height / 2.0)
//            scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: upper.size.width, height: self.frame.size.height))
//            scoreNode.physicsBody?.dynamic = false
//            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
//            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
//            
//            wall.addChild(scoreNode)
            
            item.runAction(itemAnimation)
            
            self.itemNode.addChild(item)
            
        })
        
        
        //次の壁作成までの待ち時間のアクション
        let waitAnimation = SKAction.waitForDuration(7)
        
        //壁の作成->待ち->壁を繰り返す
        let repeatForeverAnimation = SKAction.repeatActionForever(SKAction.sequence([ waitAnimation, createItemAnimation ]))
        
        runAction(repeatForeverAnimation)
        
        
        
    }

    
}
