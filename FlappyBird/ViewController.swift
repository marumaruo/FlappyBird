//
//  ViewController.swift
//  FlappyBird
//
//  Created by bc0067042 on 2016/06/10.
//  Copyright © 2016年 maru.ishi. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //SKViewに型変換->Storybord上の設定では不足？
        let skView = self.view as! SKView
        
        //FPS表示
        skView.showsFPS = true
        
        //ノード数表示
        skView.showsNodeCount = true
        
        //viewと同じサイズでシーンを作成
        let scene = GameScene(size: skView.frame.size)
        
        //viewにシーンを表示
        skView.presentScene(scene)
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

