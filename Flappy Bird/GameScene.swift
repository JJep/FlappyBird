//
//  GameScene.swift
//  Flappy Bird
//
//  Created by fang on 15/12/2.
//  Copyright (c) 2015年 Fang YiXiong. All rights reserved.
//

import SpriteKit

enum 图层: CGFloat {
    case 背景
    case 障碍物
    case 前景
    case 游戏角色
    case UI
}

enum 游戏状态 {
    case 主菜单
    case 教程
    case 游戏
    case 跌落
    case 显示分数
    case 结束
}

struct 物理层 {
    static let 无: UInt32 =          0
    static let 游戏角色: UInt32 =   0b1     //1
    static let 障碍物: UInt32 =    0b10    //2
    static let 地面: UInt32 =     0b100   //4
}


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let kmin: CGFloat = 0.1
    let kmax: CGFloat = 0.6
    let knum: CGFloat = 3.5

    let k前景地面数 = 2
    let k地面移动速度 : CGFloat = -150.0
    let k重力 : CGFloat = -1500.0
    let k上冲速度 : CGFloat = 400.0
    let k底部障碍最小乘数 : CGFloat = 0.1
    let k底部障碍最大乘数 : CGFloat = 0.6
    let k缺口乘数 : CGFloat = 3.5
    let k首次生成障碍延迟: NSTimeInterval = 1.75
    let k每次重生障碍延迟: NSTimeInterval = 1.5
    let k动画延迟 = 0.3
    
    let shareUrl = "http://tse3.mm.bing.net/th?id=OIP.M343f7f2f78848d3467d791dc1d1baba6o0&pid=15.1"
    let learnUrl = "http://image01.aitu8.com/forum/201608/09/114044dlhbip6h0z6idaa0.jpg"
    
    
    var 速度 = CGPoint.zero
    var 撞击了地面 = false
    var 撞击了障碍物 = false
    var 当前游戏状态 = 游戏状态.游戏
    
    let k顶部留白: CGFloat = 20.0
    let k字体名字 = "AmericanTypewriter-Bold"
    var 得分标签: SKLabelNode!
    var 当前分数 = 0
    
    let 世界单位 = SKNode()
    var 游戏区域起始点: CGFloat = 0
    var 游戏区域的高度: CGFloat = 0
    let 主角 = SKSpriteNode(imageNamed: "yyz")
    let 帽子 = SKSpriteNode(imageNamed: "Sombrero")
    var 上一次更新时间: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    //  创建音效
    let 叮的音效 = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let 拍打的音效 = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let 摔倒的音效 = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let 下落的音效 = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let 撞击地面的音效 = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let 砰的音效 = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let 得分的音效 = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    override func didMoveToView(view: SKView) {
        
        //关掉重力
        physicsWorld.gravity = CGVectorMake(0, 0)
        //设置代理
        physicsWorld.contactDelegate = self
        addChild(世界单位)

        切换到主菜单界面()
        
    }
    
    // MARK: 设置的相关方法
    
    func 设置主菜单 () {
        let logo = SKSpriteNode(imageNamed: "Logo")
        logo.position = CGPoint(x: size.width * 0.5, y: size.height * 0.8)
        logo.name = "主菜单"
        logo.zPosition = 图层.UI.rawValue
        世界单位.addChild( logo)
        
        let startBtn = SKSpriteNode(imageNamed: "Button")
        startBtn.position = CGPoint(x: size.width * 0.25, y: size.height * 0.25)
        startBtn.name = "主菜单"
        startBtn.zPosition = 图层.UI.rawValue
        世界单位.addChild(startBtn)
        
        let play = SKSpriteNode(imageNamed: "Play")
        play.position = CGPoint.zero
        startBtn.addChild(play)
        
        let commentBtn = SKSpriteNode(imageNamed: "Button")
        commentBtn.position = CGPoint(x: size.width * 0.75, y: size.height * 0.25)
        commentBtn.name = "主菜单"
        commentBtn.zPosition = 图层.UI.rawValue
        世界单位.addChild(commentBtn)
        
        let rate = SKSpriteNode(imageNamed: "Rate")
        rate.position = CGPoint.zero
        commentBtn.addChild(rate)
        
        let learnBtn = SKSpriteNode(imageNamed: "button_learn")
        learnBtn.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        learnBtn.name = "主菜单"
        learnBtn.zPosition = 图层.UI.rawValue
        世界单位.addChild(learnBtn)
        
        let scaleToBig = SKAction.scaleTo(1.02, duration: 0.75)
        scaleToBig.timingMode = .EaseInEaseOut
        
        let scaleToSmall = SKAction.scaleTo(0.98, duration: 0.75)
        scaleToBig.timingMode = .EaseInEaseOut
        
        learnBtn.runAction(SKAction.repeatActionForever(SKAction.sequence([
                scaleToSmall,
                scaleToBig
            ])))
        
        
        
    }
    
    func 设置教程() {
        let 教程 = SKSpriteNode(imageNamed: "Tutorial")
        教程.position = CGPoint(x: size.width * 0.5, y: 游戏区域的高度 * 0.4 + 游戏区域起始点)
        教程.name = "教程"
        教程.zPosition = 图层.UI.rawValue
        世界单位.addChild(教程)
        
        let 准备 = SKSpriteNode(imageNamed: "Ready")
        准备.position = CGPoint(x: size.width * 0.5, y: 游戏区域的高度 * 0.7 + 游戏区域起始点)
        准备.name = "教程"
        准备.zPosition = 图层.UI.rawValue
        世界单位.addChild(准备)
    }
    
    func 设置背景() {
        let 背景 = SKSpriteNode(imageNamed: "Background")
        背景.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        背景.position = CGPoint(x: size.width/2, y: size.height)
        背景.zPosition = 图层.背景.rawValue
        世界单位.addChild(背景)
        
        游戏区域起始点 = size.height - 背景.size.height
        游戏区域的高度 = 背景.size.height
        
        let 左下 = CGPoint(x: 0, y: 游戏区域起始点)
        let 右下 = CGPoint(x: size.width, y: 游戏区域起始点)
        
        self.physicsBody = SKPhysicsBody(edgeFromPoint: 左下, toPoint: 右下)
        self.physicsBody?.categoryBitMask = 物理层.地面
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = 物理层.游戏角色
        
    
        
    }
    
    func 设置主角() {
        主角.position = CGPoint(x: size.width * 0.2, y: 游戏区域的高度 * 0.4 + 游戏区域起始点)
        主角.zPosition = 图层.游戏角色.rawValue
    
        let offsetX = 主角.size.width * 主角.anchorPoint.x
        let offsetY = 主角.size.height * 主角.anchorPoint.y
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 2 - offsetX, 16 - offsetY)
        CGPathAddLineToPoint(path, nil, 13 - offsetX, 21 - offsetY)
        CGPathAddLineToPoint(path, nil, 23 - offsetX, 27 - offsetY)
        CGPathAddLineToPoint(path, nil, 33 - offsetX, 28 - offsetY)
        CGPathAddLineToPoint(path, nil, 37 - offsetX, 24 - offsetY)
        CGPathAddLineToPoint(path, nil, 38 - offsetX, 13 - offsetY)
        CGPathAddLineToPoint(path, nil, 36 - offsetX, 5 - offsetY)
        CGPathAddLineToPoint(path, nil, 32 - offsetX, 2 - offsetY)
        CGPathAddLineToPoint(path, nil, 21 - offsetX, 0 - offsetY)
        CGPathAddLineToPoint(path, nil, 13 - offsetX, 1 - offsetY)
        CGPathAddLineToPoint(path, nil, 5 - offsetX, 0 - offsetY)
        
        CGPathCloseSubpath(path)
        
        主角.physicsBody = SKPhysicsBody(polygonFromPath: path)
        
        主角.physicsBody?.categoryBitMask = 物理层.游戏角色
        主角.physicsBody?.collisionBitMask = 0
        主角.physicsBody?.contactTestBitMask = 物理层.障碍物 | 物理层.地面
        
        
        世界单位.addChild(主角)
    }
    
    func 设置前景() {
        for i in 0..<k前景地面数 {
            let 前景 = SKSpriteNode(imageNamed: "Ground")
            前景.anchorPoint = CGPoint(x: 0, y: 1.0)
            前景.position = CGPoint(x: CGFloat(i) * 前景.size.width, y: 游戏区域起始点)
            前景.zPosition = 图层.前景.rawValue
            前景.name = "前景"
            世界单位.addChild(前景)
        }
    }
    
    func 设置帽子() {
        
        帽子.position = CGPoint(x: 31 - 帽子.size.width/2, y: 29 - 帽子.size.height/2)
        主角.addChild(帽子)
    }
    
    func 设置得分标签 () {
        得分标签 = SKLabelNode(fontNamed: k字体名字)
        得分标签.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 71.0/255.0, alpha: 1.0)
        得分标签.position = CGPoint(x: size.width / 2, y: size.height - k顶部留白)
        得分标签.verticalAlignmentMode = .Top
        得分标签.text = "0"
        得分标签.zPosition = 图层.UI.rawValue
        世界单位.addChild(得分标签)
        
    }
    
    func 设置记分板 () {
        if 当前分数 > 最高分() {
            设置最高分(当前分数)
        }
        
        let 记分板 = SKSpriteNode(imageNamed: "ScoreCard")
        记分板.position = CGPoint(x: size.width / 2, y: size.height / 2)
        记分板.zPosition = 图层.UI.rawValue
        世界单位.addChild(记分板)
        
        let 当前分数标签 = SKLabelNode(fontNamed: k字体名字)
        当前分数标签.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 71.0/255.0, alpha: 1.0)
        当前分数标签.position = CGPoint(x: -记分板.size.width / 4, y: -记分板.size.height / 3)
        当前分数标签.zPosition = 图层.UI.rawValue
        当前分数标签.text = "\(当前分数)"
        记分板.addChild(当前分数标签)
        
        let 最高分标签 = SKLabelNode(fontNamed: k字体名字)
        最高分标签.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 71.0/255.0, alpha: 1.0)
        最高分标签.position = CGPoint(x: 记分板.size.width / 4, y: -记分板.size.height / 3)
        最高分标签.text = "\(最高分())"
        最高分标签.zPosition = 图层.UI.rawValue
        记分板.addChild(最高分标签)

        let 游戏结束 = SKSpriteNode(imageNamed: "GameOver")
        游戏结束.position = CGPoint(x: size.width / 2, y: size.height / 2 + 记分板.size.height / 2 + k顶部留白 + 游戏结束.size.height / 2)
        游戏结束.zPosition = 图层.UI.rawValue
        世界单位.addChild(游戏结束)
        
        let ok按钮 = SKSpriteNode(imageNamed: "Button")
        ok按钮.position = CGPoint(x: size.width / 4, y: size.height / 2 - 记分板.size.height / 2 - k顶部留白 - ok按钮.size.height / 2)
        ok按钮.zPosition = 图层.UI.rawValue
        世界单位.addChild(ok按钮)
        
        let ok = SKSpriteNode(imageNamed: "OK")
        ok.position = CGPoint.zero
        ok.zPosition = 图层.UI.rawValue
        ok按钮.addChild(ok)
        
        let share按钮 = SKSpriteNode(imageNamed: "ButtonRight")
        share按钮.position = CGPoint(x: 3 * size.width / 4, y: size.height / 2 - 记分板.size.height / 2 - k顶部留白 - ok按钮.size.height / 2)
        share按钮.zPosition = 图层.UI.rawValue
        世界单位.addChild(share按钮)
        
        let share = SKSpriteNode(imageNamed: "Share" )
        share.position = CGPoint.zero
        share.zPosition = 图层.UI.rawValue
        share按钮.addChild(share)
        
        游戏结束.setScale(0)
        游戏结束.alpha = 0

        let 动画组 = SKAction.group([
            SKAction.fadeInWithDuration(k动画延迟),
            SKAction.scaleTo(1.0, duration: k动画延迟)
            ])
        

        动画组.timingMode = .EaseInEaseOut
        
        
        游戏结束.runAction(SKAction.sequence([
                SKAction.waitForDuration(k动画延迟),
                动画组,
                砰的音效
            ]))
    
        记分板.position = CGPoint(x: size.width / 2, y: -记分板.size.height / 2)
        
        let 记分板的动画 = SKAction.moveTo(CGPoint(x: size.width / 2, y: size.height / 2), duration: k动画延迟)
        
        记分板.runAction(SKAction.sequence([
                SKAction.waitForDuration(k动画延迟 * 2),
                记分板的动画,
                砰的音效
            ]))
        
        ok按钮.alpha = 0
        share按钮.alpha = 0
        
        let 渐变动画 = SKAction.sequence([
                SKAction.waitForDuration(k动画延迟 * 3),
                SKAction.fadeInWithDuration(k动画延迟),
                砰的音效
        ])
        ok按钮.runAction(渐变动画)
        share按钮.runAction(渐变动画)
        
        let 切换到结束 = SKAction.sequence([
                SKAction.waitForDuration(k动画延迟 * 4),
                SKAction.runBlock(切换到结束状态)
            ])
        runAction(切换到结束)
        
    }
    
    // MARK: 游戏流程
    
    func 创建障碍物(图片名: String) -> SKSpriteNode {
        let 障碍物 = SKSpriteNode(imageNamed: 图片名)
        障碍物.zPosition = 图层.障碍物.rawValue
        障碍物.userData = NSMutableDictionary()
        
        
        let offsetX = 障碍物.size.width * 障碍物.anchorPoint.x
        let offsetY = 障碍物.size.height * 障碍物.anchorPoint.y
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 4 - offsetX, 1 - offsetY)
        CGPathAddLineToPoint(path, nil, 8 - offsetX, 306 - offsetY)
        CGPathAddLineToPoint(path, nil, 47 - offsetX, 306 - offsetY)
        CGPathAddLineToPoint(path, nil, 46 - offsetX, 4 - offsetY)
        CGPathAddLineToPoint(path, nil, 44 - offsetX, 1 - offsetY)
        
        CGPathCloseSubpath(path)
        
        障碍物.physicsBody = SKPhysicsBody(polygonFromPath: path)
        障碍物.physicsBody?.categoryBitMask = 物理层.障碍物
        障碍物.physicsBody?.collisionBitMask = 0
        障碍物.physicsBody?.contactTestBitMask = 物理层.游戏角色
        
        return 障碍物
    }
    
    func 生成障碍() {
        
        let 底部障碍 = 创建障碍物("CactusBottom")
        let 起始X坐标 = size.width + 底部障碍.size.width / 2
        
        let Y坐标最小值 = (游戏区域起始点 - 底部障碍.size.height/2) + 游戏区域的高度 * k底部障碍最小乘数
        let Y坐标最大值 = (游戏区域起始点 - 底部障碍.size.height/2) + 游戏区域的高度 * k底部障碍最大乘数
        底部障碍.position = CGPointMake(起始X坐标, CGFloat.random(min: Y坐标最小值, max: Y坐标最大值))
        底部障碍.name = "底部障碍"
        
        世界单位.addChild(底部障碍)
        
        let 顶部障碍 = 创建障碍物("CactusTop")
        顶部障碍.zRotation = CGFloat(180).degreesToRadians()
        顶部障碍.position = CGPoint(x: 起始X坐标, y: 底部障碍.position.y + 底部障碍.size.height/2 + 顶部障碍.size.height/2 + 主角.size.height * k缺口乘数)
        顶部障碍.name = "顶部障碍"

        世界单位.addChild(顶部障碍)
        
        let X轴移动距离 = -(size.width + 底部障碍.size.width)
        let 移动持续时间 = X轴移动距离 / k地面移动速度
        
        let 移动的动作队列 = SKAction.sequence([
                SKAction.moveByX(X轴移动距离, y: 0, duration: NSTimeInterval(移动持续时间)),
                SKAction.removeFromParent()
            ])
        顶部障碍.runAction(移动的动作队列)
        底部障碍.runAction(移动的动作队列)
        
    }
    
    func 无限重生障碍() {
        let 首次延迟 = SKAction.waitForDuration(k首次生成障碍延迟)
        let 重生障碍 = SKAction.runBlock(生成障碍)
        let 每次重生间隔 = SKAction.waitForDuration(k每次重生障碍延迟)
        let 重生的动作队列 = SKAction.sequence([重生障碍, 每次重生间隔])
        let 无限重生 = SKAction.repeatActionForever(重生的动作队列)
        let 总的动作队列 = SKAction.sequence([首次延迟, 无限重生])
        runAction(总的动作队列, withKey: "重生")
    }

    func 停止重生障碍 () {
        removeActionForKey("重生")
        
        世界单位.enumerateChildNodesWithName("顶部障碍", usingBlock: { 匹配单位, _ in
            匹配单位.removeAllActions()
        })
        
        世界单位.enumerateChildNodesWithName("底部障碍", usingBlock: { 匹配单位, _ in
            匹配单位.removeAllActions()
        })
    }
    
    func 主角飞一下() {
        速度 = CGPoint(x: 0, y: k上冲速度)
        // 播放音效
        runAction(拍打的音效)
        // 移动帽子
        let 向上移动 = SKAction.moveByX(0, y: 12, duration: 0.15)
        向上移动.timingMode = .EaseInEaseOut
        let 向下移动 = 向上移动.reversedAction()
        帽子.runAction(SKAction.sequence([向上移动, 向下移动]))
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        guard let touch = touches.first else {
            return
        }
        let touchPosition = touch.locationInNode(self)
        
        switch 当前游戏状态 {
        case .主菜单:
            if touchPosition.y <= size.height * 0.15 {
                去学习()
            } else if touchPosition.x < size.width / 2 {
                切换到教程界面()
            } else {
                去评价()
            }
            break
        case .教程:
            切换到游戏状态()
            break
        case .游戏:
            主角飞一下()
            break
        case .跌落:
            break
        case .显示分数:
            break
        case .结束:
            切换到新游戏状态()
            break
        }
    }
    
    // MARK: 更新
   
    override func update(当前时间: CFTimeInterval) {
        if 上一次更新时间 > 0 {
            dt = 当前时间 - 上一次更新时间
        } else {
            dt = 0
        }
        上一次更新时间 = 当前时间

        switch 当前游戏状态 {
        case .主菜单:
            break
        case .教程:
            break
        case .显示分数:
            break
        case .游戏:
            更新主角()
            更新前景()
            撞击障碍物检查()
            撞击地面检查()
            更新得分()
            break
        case .跌落:
            更新主角()
            撞击地面检查()
            break
        case .结束:
            break
        }
    }
    
    func 更新主角() {
        let 加速度 = CGPoint(x: 0, y: k重力)
        速度 = 速度 + 加速度 * CGFloat(dt)
        主角.position = 主角.position + 速度 * CGFloat(dt)
        
        // 检测撞击地面时让其停在地面上
        if 主角.position.y - 主角.size.height/2 < 游戏区域起始点 {
            主角.position = CGPoint(x: 主角.position.x, y: 游戏区域起始点 + 主角.size.height/2)
        }
    }
    
    func 更新前景() {
        世界单位.enumerateChildNodesWithName("前景") { 匹配单位, _ in
            if let 前景 = 匹配单位 as? SKSpriteNode {
                let 地面移动速度 = CGPoint(x: self.k地面移动速度, y: 0)
                前景.position += 地面移动速度 * CGFloat(self.dt)
                
                if 前景.position.x < -前景.size.width {
                    前景.position += CGPoint(x: 前景.size.width * CGFloat(self.k前景地面数), y: 0)
                }
                
            }
        }
        
        
    }
    
    func 撞击障碍物检查 () {

        if 撞击了障碍物  {
            撞击了障碍物 = false
            切换到跌落状态()
        }
        
    }
    
    func 撞击地面检查 () {
        
        if 撞击了地面 {
            撞击了地面 = false
            速度 = CGPoint.zero
            主角.zRotation = CGFloat(-90).degreesToRadians()
            主角.position = CGPoint(x: 主角.position.x, y: 游戏区域起始点 + 主角.size.width/2)
            runAction(撞击地面的音效)
            切换到显示分数状态()
        }
    }
    
    func 更新得分 () {
        世界单位.enumerateChildNodesWithName("顶部障碍", usingBlock: { 匹配单位, _ in
            if let 障碍物 = 匹配单位 as? SKSpriteNode {
                if let 已通过 = 障碍物.userData?["已通过"] as? NSNumber {
                    if  已通过.boolValue {
                        return //已经计算过一次得分
                    }
                }
                
                if self.主角.position.x > 障碍物.position.x + 障碍物.size.width / 2 {
                    self.当前分数 += 1
                    self.得分标签.text = "\(self.当前分数)"
                    self.runAction(self.得分的音效)
                    障碍物.userData?["已通过"] = NSNumber(bool: true)
                    
                }
                
            }
        })
    }
    
    //MARK: 游戏状态
    
    func 切换到主菜单界面 () {
        当前游戏状态 = .主菜单

        设置背景()
        设置前景()
        设置主角()
        设置帽子()
        设置主菜单()

        
    }
    
    func 切换到教程界面 () {
        当前游戏状态 = .教程
        世界单位.enumerateChildNodesWithName("主菜单") { (匹配单位, _) in
            匹配单位.runAction(SKAction.sequence([
                SKAction.fadeOutWithDuration(0.05),
                SKAction.removeFromParent()
                ]))
        }
        设置得分标签()
        设置教程()

    }
    
    
    func 切换到游戏状态() {
        当前游戏状态 = .游戏
        世界单位.enumerateChildNodesWithName("教程") { (匹配单位, _) in
            匹配单位.runAction(SKAction.sequence([
                    SKAction.fadeOutWithDuration(0.05),
                    SKAction.removeFromParent()
                ]))
        }
        
        无限重生障碍()
        主角飞一下()
        
    }
    
    func 切换到跌落状态 () {
        当前游戏状态 = .跌落
        
        runAction(SKAction.sequence( [
            摔倒的音效,
            SKAction.waitForDuration(0.1),
            下落的音效]))
        
        主角.removeAllActions()
        停止重生障碍()
        
    }
    
    func 切换到显示分数状态 () {
        当前游戏状态 = .显示分数
        主角.removeAllActions()
        停止重生障碍()
        设置记分板()
    }
    
    func 切换到新游戏状态 () {
        runAction(砰的音效)
        
        let 新的游戏场景 = GameScene.init(size: size)
        let 切换特效 = SKTransition.fadeWithColor(SKColor.blackColor(), duration: 0.05)
        view?.presentScene(新的游戏场景, transition: 切换特效)
        
    }
    
    func 切换到结束状态 () {
        当前游戏状态 = .结束
    }
    //MARK: 分数 
    
    func 最高分() -> Int{
        return NSUserDefaults.standardUserDefaults().integerForKey("最高分")
    }
    
    func 设置最高分(最高分: Int) {
        NSUserDefaults.standardUserDefaults().setInteger(最高分, forKey: "最高分")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    //MARK: 物理引擎
    func didBeginContact(碰撞双方: SKPhysicsContact) {
        let 被撞对象 = 碰撞双方.bodyA.categoryBitMask == 物理层.游戏角色 ? 碰撞双方.bodyB : 碰撞双方.bodyA
        
        if 被撞对象.categoryBitMask == 物理层.地面 {
            撞击了地面 = true
        }
        
        if 被撞对象.categoryBitMask == 物理层.障碍物 {
            撞击了障碍物 = true
        }
    }
    
    //MARK:其他
    
    func 去学习() {
        let url = NSURL(string: learnUrl)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    func 去评价() {
        let url = NSURL(string: learnUrl)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    
}
