//
//  GameScene.swift
//  FlappyBird
//
//  Created by 米島尚 on 2020/05/31.
//  Copyright © 2020 hisa.yone. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // （追加）
    var scrollNode:SKNode!
    var wallNode:SKNode!    // 追加
    var bird:SKSpriteNode!    // 追加
    var itemNode:SKNode! //item どこにつがってる？
    
    // 衝突判定カテゴリー ↓追加
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let itemCategory: UInt32 = 1 << 4 //item 数字何？

    // スコア用
    var score = 0  // ←追加
    var itemScore = 0
    var scoreLabelNode:SKLabelNode!    // ←追加
    var bestScoreLabelNode:SKLabelNode!    // ←追加
    var itemScoreLabelNode:SKLabelNode! //item
    
    let userDefaults:UserDefaults = UserDefaults.standard    // 追加

    
    //ゲーム画面（＝SKSceneクラスを継承したクラス）が表示されるときに呼ばれるメソッドがdidMove(to:)メソッドになります。このメソッドで画面を構築する処理を書いたり、ゲームの初期設定を行います。
    // SKView上にシーンが表示されたときに呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)    // ←追加
        physicsWorld.contactDelegate = self // ←追加
        
        //背景色の設定はSKSceneクラスのbackgroundColorプロパティで設定します。backgroundColorプロパティはUIColorクラス
        // 背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // （追加）スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        // 壁用のノード
        wallNode = SKNode()   // 追加
        scrollNode.addChild(wallNode)   // 追加
        
        itemNode = SKNode()
        scrollNode.addChild(itemNode)

        // 各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()   // 追加
        setupBird()   // 追加
        setupScoreLabel()   // 追加
        setupItem()
    }
        
        func setupGround() {
        //SKTextureクラスのfilteringModeプロパティに.nearestと設定します。これは画像が多少荒くなってでも処理速度を高める設定です。.linearを設定すると画質を優先します。
        // 地面の画像を読み込む
            let groundTexture = SKTexture(imageNamed: "ground")
            groundTexture.filteringMode = .nearest
        
        // （追加）必要な枚数を計算
        //+2している理由は、地面の個数を多めに並べることで、画面サイズの横幅よりも地面全体の横幅が大きくなるようにし、地面を右から左にスクロールさせた時に右端が切れないようにするため
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2

        // （追加）スクロールするアクションを作成
        // （追加）左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5)

        // （追加）元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)

        // （追加）左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))

        // （追加）groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)

        
        
            // （削除？）テクスチャを指定してスプライトを作成する
            //let groundSprite = SKSpriteNode(texture: groundTexture)
        
        //positionで指定するのはNodeの中心位置です。また、UIKitの場合は左上が原点（x=0,y=0）ですが、SpriteKitの場合は左下が原点
            // (修正)スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2  + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )
            
            // （追加）スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            // スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())   // ←追加
            
            // 衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory    // ←追加


            // 衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false   // ←追加

            // （修正）シーンにスプライトを追加する
            //addChild(groundSprite)     いらない？
            scrollNode.addChild(sprite)
        }

    }
    
    func setupCloud() {
    // 雲の画像を読み込む
    let cloudTexture = SKTexture(imageNamed: "cloud")
    cloudTexture.filteringMode = .nearest

    // 必要な枚数を計算
    let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2

    // スクロールするアクションを作成
    // 左方向に画像一枚分スクロールさせるアクション
    let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20)

    // 元の位置に戻すアクション
    let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)

    // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
    let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))

    // スプライトを配置する
    for i in 0..<needCloudNumber {
        let sprite = SKSpriteNode(texture: cloudTexture)
        sprite.zPosition = -100 // 一番後ろになるようにする

        // スプライトの表示する位置を指定する
        sprite.position = CGPoint(
            x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
            y: self.size.height - cloudTexture.size().height / 2
        )

        // スプライトにアニメーションを設定する
        sprite.run(repeatScrollCloud)

        // スプライトを追加する
        scrollNode.addChild(sprite)
        }
    }
    
    
    func setupWall() {
            // 壁の画像を読み込む
            let wallTexture = SKTexture(imageNamed: "wall")
            wallTexture.filteringMode = .linear

            // 移動する距離を計算
            let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)

            // 画面外まで移動するアクションを作成
            let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)

            // 自身を取り除くアクションを作成
            let removeWall = SKAction.removeFromParent()

            // 2つのアニメーションを順に実行するアクションを作成
            let wallAnimation = SKAction.sequence([moveWall, removeWall])

            // 鳥の画像サイズを取得
            let birdSize = SKTexture(imageNamed: "bird_a").size()

            // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
            let slit_length = birdSize.height * 3

            // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
            let random_y_range = birdSize.height * 3

            // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
            let groundSize = SKTexture(imageNamed: "ground").size()
            let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
            let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_range / 2

            // 壁を生成するアクションを作成
            let createWallAnimation = SKAction.run({
                // 壁関連のノードを乗せるノードを作成
                let wall = SKNode()
                wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
                wall.zPosition = -50 // 雲より手前、地面より奥

                // 0〜random_y_rangeまでのランダム値を生成
                let random_y = CGFloat.random(in: 0..<random_y_range)
                // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
                let under_wall_y = under_wall_lowest_y + random_y

                // 下側の壁を作成
                let under = SKSpriteNode(texture: wallTexture)
                under.position = CGPoint(x: 0, y: under_wall_y)
                
                // スプライトに物理演算を設定する
                under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
                under.physicsBody?.categoryBitMask = self.wallCategory    // ←追加


                // 衝突の時に動かないように設定する
                under.physicsBody?.isDynamic = false    // ←追加

                wall.addChild(under)

                // 上側の壁を作成
                let upper = SKSpriteNode(texture: wallTexture)
                upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
                
                // スプライトに物理演算を設定する
                upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())    // ←追加
                upper.physicsBody?.categoryBitMask = self.wallCategory    // ←追加
                
                // 衝突の時に動かないように設定する
                upper.physicsBody?.isDynamic = false

                wall.addChild(upper)

                // スコアアップ用のノード --- ここから ---
                let scoreNode = SKNode()
                scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2, y: self.frame.height / 2)
                scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
                scoreNode.physicsBody?.isDynamic = false
                scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
                scoreNode.physicsBody?.contactTestBitMask = self.birdCategory

                wall.addChild(scoreNode)
                // --- ここまで追加 ---

                wall.run(wallAnimation)

                self.wallNode.addChild(wall)
            })

            // 次の壁作成までの時間待ちのアクションを作成
            let waitAnimation = SKAction.wait(forDuration: 2)

            // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
            let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))

            wallNode.run(repeatForeverAnimation)
        }
    
    
    
    
    func setupItem(){
        // itemの画像を読み込む
        let itemTexture = SKTexture(imageNamed: "item")
        itemTexture.filteringMode = .linear

        // 移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + itemTexture.size().width)

        // 画面外まで移動するアクションを作成
        let moveItem = SKAction.moveBy(x: -movingDistance, y: 0, duration:4)

        // 自身を取り除くアクションを作成
        let removeItem = SKAction.removeFromParent()

        // 2つのアニメーションを順に実行するアクションを作成
        let itemAnimation = SKAction.sequence([moveItem, removeItem])

        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size() //変更必要？

        // 鳥が通り抜ける隙間の長さを鳥のサイズの3倍とする
        let slit_length = birdSize.height * 1
        //変更必要？

        // 隙間位置の上下の振れ幅を鳥のサイズの3倍とする
        let random_y_range = birdSize.height * 1
        //変更必要？

        // 下の壁のY軸下限位置(中央位置から下方向の最大振れ幅で下の壁を表示する位置)を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let middle_item_lowest_y = center_y - slit_length / 2 - itemTexture.size().height / 2 - random_y_range / 2
        

        // 壁を生成するアクションを作成
        let createItemAnimation = SKAction.run({
            // 壁関連のノードを乗せるノードを作成
            let item = SKNode()
            item.position = CGPoint(x: self.frame.size.width + itemTexture.size().width / 2, y: 0)
            item.zPosition = -50 // 雲より手前、地面より奥

            // 0〜random_y_rangeまでのランダム値を生成
            let random_y = CGFloat.random(in: 0..<random_y_range)
            // Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let middle_item_y = middle_item_lowest_y + random_y
            // 下側の壁を作成
            let middle = SKSpriteNode(texture: itemTexture)
            middle.position = CGPoint(x: 0, y: middle_item_y)
            // スプライトに物理演算を設定する
            middle.physicsBody = SKPhysicsBody(rectangleOf: itemTexture.size())// ←追加
            middle.physicsBody?.categoryBitMask = self.itemCategory// ←追加

           // 衝突の時に動かないように設定する
            middle.physicsBody?.isDynamic = false// ←追加
            
            item.addChild(middle)

            // アイテムスコアアップ用のノード

            let itemScoreNode = SKNode()

            itemScoreNode.position = CGPoint(x: middle.size.width + birdSize.width / 2, y: self.frame.height / 2)

            itemScoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: middle.size.width, height: self.frame.size.height))

            itemScoreNode.physicsBody?.isDynamic = false

            itemScoreNode.physicsBody?.categoryBitMask = self.itemCategory

            itemScoreNode.physicsBody?.contactTestBitMask = self.birdCategory



            item.addChild(itemScoreNode)

            // --- ここまで追加 ---
            
            item.run(itemAnimation)
            
            

            self.itemNode.addChild(item)
        })

        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)

        // 壁を作成->時間待ち->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation2 = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimation]))

        itemNode.run(repeatForeverAnimation2)
    }
    
    
    
    
    
    
    // 以下追加
    func setupBird() {
        // 鳥の画像を2種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear

        // 2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)

        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        // 物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)    // ←追加
        
        // 衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false    // ←追加

        // 衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory   // ←追加
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory   // ←追加
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | itemCategory// ←追加



        // アニメーションを設定
        bird.run(flap)

        // スプライトを追加する
        addChild(bird)
    }
    
    
    //場所どこ？
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 // 一番手前に表示する
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)

        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示する
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left

        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        itemScoreLabelNode.zPosition = 100 // 一番手前に表示する
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "Item Score:\(itemScore)"  //何の意味？
        self.addChild(itemScoreLabelNode)
    }
    
    
    //場所どこに入れる？
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 { // 追加
        // 鳥の速度をゼロにする
        bird.physicsBody?.velocity = CGVector.zero

        // 鳥に縦方向の力を与える
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
            } else if bird.speed == 0 { // --- ここから ---
                restart()
            } // --- ここまで追加 ---
    }
    
    //場所どこに入れる？
    // SKPhysicsContactDelegateのメソッド。衝突したときに呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        
        // ゲームオーバーのときは何もしない
        if scrollNode.speed <= 0 {
            return
        }
        if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
            
            SKAction.removeFromParent()//item削除用にカスタマイズしたい
        // スコア用の物体と衝突した
        print("itemScoreUp")
        itemScore += 1
        itemScoreLabelNode.text = "Item Score:\(itemScore)"
            
        }

        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            // スコア用の物体と衝突した
            
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"    // ←追加
            
            // ベストスコア更新か確認する --- ここから ---
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"    // ←追加
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            } // --- ここまで追加---
        } else {
            // 壁か地面と衝突した
            print("GameOver")

            // スクロールを停止させる
            scrollNode.speed = 0

            bird.physicsBody?.collisionBitMask = groundCategory

            let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
        }
    }
    
    //場所どこに入れる？
    func restart() {
        score = 0
        itemScore = 0
        scoreLabelNode.text = "Score:\(score)"    // ←追加
        itemScoreLabelNode.text = "Item Score:\(itemScore)"

        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0

        wallNode.removeAllChildren()
        itemNode.removeAllChildren() //いる？

        bird.speed = 1
        scrollNode.speed = 1
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */




}
