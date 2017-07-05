//
//  BaseBrush.swift
//  FCFCommonFrame
//
//  Created by 冯才凡 on 2017/6/16.
//  Copyright © 2017年 com.fcf. All rights reserved.
//

import UIKit
import CoreGraphics

protocol PaintBrush {
    func supportedContinnuousDrawing()->Bool //是否是连续不断地绘图
    func drawInContext(context:CGContext) //具体绘图的方法
}

//所有画图工具的基类
class BaseBrush: NSObject {
    var beginPoint:CGPoint? //手指按下的位置
    var endPoint:CGPoint? //手指抬起的位置
    var lastPoint:CGPoint? //手指移动到当前位置之前的位置
    var strokeWidth:CGFloat = 1.0 //画笔宽度，默认1.0
    var strockColor:String = "000000" //画笔颜色,默认黑色
    var pointsArr:[CGPoint] = []//放置点的数组(state:DrawingState,point:
    
}

extension BaseBrush:PaintBrush{
    func drawInContext(context: CGContext) {
        //
//        assert(false,"子类必须实现")
    }

    func supportedContinnuousDrawing() -> Bool {
        return false
    }
}
