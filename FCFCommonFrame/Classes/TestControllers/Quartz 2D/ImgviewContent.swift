//
//  ImgviewContent.swift
//  FCFDrawBoard
//
//  Created by 冯才凡 on 2017/7/7.
//  Copyright © 2017年 com.fcf. All rights reserved.
//

import UIKit


@objc protocol ImgviewContentDelegate {
    //返回当前index和颜色
    @objc optional func imgContent(view:ImgviewContent,segmentIndex:NSInteger,selectcolor:String,dwidth:CGFloat)
    @objc optional func imgContent(view:ImgviewContent,xmlStr:String?)
}

//由两层UIImageView组成
class ImgviewContent: UIView {

    var delegate:ImgviewContentDelegate?
    
    var scrollIndex:NSInteger = 0 //在滚动视图里的位置
    
    var wBili:CGFloat = 1.0 //宽比
    var hBili:CGFloat = 1.0 //高比
    
    var imgW:CGFloat = 1.0
    var imgH:CGFloat = 1.0
    
    lazy var originBgView:UIImageView = {
       let imgview = UIImageView(frame: self.frame)
        imgview.contentMode = .scaleAspectFill
        return imgview
    }()
    
    lazy var drawContext:DrawContext = {
        let drawContext = DrawContext(frame: self.originBgView.frame)
        drawContext.delegate = self
        return drawContext
    }()
    
    init(frame: CGRect,originImg:String?=nil,url:String?=nil) {
        super.init(frame: frame)
        createUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func createUI(){
        self.addSubview(self.originBgView)
        self.addSubview(self.drawContext)
        self.drawContext.isUserInteractionEnabled = true
        
        let img = UIImage(named:"qupu")
        self.originBgView.image = img
        self.imgW = img!.size.width
        self.imgH = img!.size.height
        
        self.drawContext.pivot_x = imgW*1.0/2.0
        self.drawContext.pivot_y = imgH*1.0/2.0
        
        let ScreenW = self.width
        let ScreenH = self.height
        
        self.wBili =  ScreenW*1.0/imgW
        self.hBili = ScreenH*1.0/imgH
        
        self.drawContext.wBili = self.wBili
        self.drawContext.hBili = self.hBili
    }
    
}

//对外接口
extension ImgviewContent{
    //初始化画笔
    func initBrush(type:DrawType? = .Pentype(.Curve),color:String? = "000000",width:CGFloat? = 1.0){
        self.drawContext.initBrush(type: type, color: color, width: width)
    }
    
    //改变颜色
    func changeBrushColor(color:String){
        self.drawContext.changeBrushColor(color: color)
    }
    
    //画笔大小改变了
    func changeBrushSize(size:CGFloat){
        self.drawContext.changeBrushSize(size: size)
    }
    
    //是否有缓存画画
    func hasDraw()->Bool{
        return self.drawContext.hasDraw
    }
    
    //重画
    func restoreDraw(){
        self.drawContext.restoreDraw()
    }
    
    //移除无用的笔画
    func removeUselessSave(){
        self.drawContext.removeUselessSave()
    }
    
    //是否可撤销
    func canBack()->Bool{
        return self.drawContext.canBack()
    }
    
    //撤销
    func undo(){
        self.drawContext.undo()
    }
    
    //是否可重画
    func canForward()->Bool{
        return self.drawContext.canForward()
    }
    
    //重画
    func redo(){
        self.drawContext.redo()
    }

    //清空
    func clear(){
        self.drawContext.clear()
    }
    
    //显示文本UI
    func showTextVIewUIMsg(){
        self.drawContext.showTextVIewUIMsg()
    }
    
    //隐藏文本UI
    func hideTextViewUIMsg(){
        self.drawContext.hideTextViewUIMsg()
    }
    
    //保存xml
    func saveXml(){
        self.drawContext.saveDrawToXML()
    }
    
    //画xml
    func autoDraw(obj:PathModel){
        var dwidth:CGFloat = 0.0
        var selectedIndex = 0
        
        switch obj.type! {
        case .Pentype(.Curve):
            print("曲线")
            selectedIndex = 0
            
            dwidth = obj.pen_width != nil ? obj.pen_width!.floatValue/2.0 : 20
            
            self.drawContext.initBrush(type: .Pentype(.Curve), color: obj.color, width: dwidth)
            if let pointStr = obj.point_list {
                self.draw(points: pointStr)
            }
            
        case .Pentype(.Line):
            print("直线")
            selectedIndex = 0//后续改
            
            dwidth = obj.pen_width != nil ? obj.pen_width!.floatValue/2.0 : 20
            self.drawContext.initBrush(type: .Pentype(.Line), color: obj.color, width: dwidth)
            if let x = obj.start_x, let y = obj.start_y {
                self.drawPoint(point: CGPoint(x: x.floatValue, y: y.floatValue), state: .begin)
            }
            if let x = obj.end_x, let y = obj.end_y {
                self.drawPoint(point: CGPoint(x: x.floatValue, y: y.floatValue), state: .ended)
            }
        case .Pentype(.ImaginaryLine):
            print("虚线")
            selectedIndex = 0 //后续改
            
            dwidth = obj.pen_width != nil ? obj.pen_width!.floatValue/2.0 : 20
            self.drawContext.initBrush(type: .Pentype(.ImaginaryLine), color: obj.color, width: dwidth)
            if let x = obj.start_x, let y = obj.start_y {
                self.drawPoint(point: CGPoint(x: x.floatValue, y: y.floatValue), state: .begin)
            }
            if let x = obj.end_x, let y = obj.end_y {
                self.drawPoint(point: CGPoint(x: x.floatValue, y: y.floatValue), state: .ended)
            }
        case .Formtype(.Rect):
            print("矩形")
            selectedIndex = 1
            dwidth = obj.pen_width != nil ? obj.pen_width!.floatValue/2.0 : 20
            self.drawContext.initBrush(type: .Formtype(.Rect), color: obj.color, width: dwidth)
            if let x = obj.start_x, let y = obj.start_y {
                self.drawPoint(point: CGPoint(x: x.floatValue, y: y.floatValue), state: .begin)
            }
            if let x = obj.end_x, let y = obj.end_y {
                self.drawPoint(point: CGPoint(x: x.floatValue, y: y.floatValue), state: .ended)
            }
        case .Formtype(.Ellipse):
            print("椭圆")
            selectedIndex = 1 //后续改
            dwidth = obj.pen_width != nil ? obj.pen_width!.floatValue/2.0 : 20
            self.drawContext.initBrush(type: .Formtype(.Ellipse), color: obj.color, width: dwidth)
            if let x = obj.start_x, let y = obj.start_y {
                self.drawPoint(point: CGPoint(x: x.floatValue, y: y.floatValue), state: .begin)
            }
            if let x = obj.end_x, let y = obj.end_y {
                self.drawPoint(point: CGPoint(x: x.floatValue, y: y.floatValue), state: .ended)
            }
        case .Eraser:
            print("橡皮擦")
            selectedIndex = 4
            dwidth = obj.pen_width != nil ? obj.pen_width!.floatValue/2.0 : 20
            self.drawContext.initBrush(type: .Eraser, color: obj.color, width: dwidth)
            if let pointStr = obj.point_list {
                self.draw(points: pointStr)
            }
        case .Note:
            print("音符")
            selectedIndex = 3
            dwidth = obj.pen_width != nil ? obj.pen_width!.floatValue/2.0 : 20
            self.drawContext.initBrush(type: .Note, color: obj.color, width: dwidth)
            if let x = obj.end_x, let y = obj.end_y,let symbol = obj.symbol {
                self.drawPoint(point: CGPoint(x: x.floatValue, y: y.floatValue), state: .begin , text: symbol)
            }
        case .Text:
            print("文本")
            selectedIndex = 2
            dwidth = obj.size != nil ? obj.size!.floatValue/2.0 : 20
            self.drawContext.initBrush(type: .Text, color: obj.color, width: dwidth)
            if let x = obj.text_x, let y = obj.text_y,let text = obj.text {
                self.drawPoint(point: CGPoint(x: x.floatValue, y: y.floatValue), state: .begin,text: text,angle:(obj.text_rotate! as NSString).doubleValue)
            }
        }
        
        self.delegate?.imgContent?(view: self, segmentIndex: selectedIndex, selectcolor: obj.color!,dwidth:dwidth)
        
        if selectedIndex == 2 {
            self.drawContext.showTextVIewUIMsg()
        }else{
            self.drawContext.hideTextViewUIMsg()
        }
        
    }
    
    func drawPoints(state:DrawingState,point:CGPoint,textStr:String?=nil,angle:Double?=nil) {
        self.drawContext.drawPoints(state: state, point: point, textStr: textStr, angle: angle)
    }
}

extension ImgviewContent{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            self.drawContext.dtouchesBegan(touches, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            self.drawContext.dtouchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            self.drawContext.dtouchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            self.drawContext.dtouchesCancelled(touches, with: event)
        }
    }
}

extension ImgviewContent{
    //画线，橡皮擦
    func draw(points:String){
        let pointStrArr = points.components(separatedBy: "-") // componentsSeparatedByString("-")
        var pointsArr:[CGPoint] = []
        for str in pointStrArr {
            if str == "" {
                continue
            }
            let point:CGPoint = CGPointFromString(str)
            pointsArr.append(point)
        }
        
        for i in 0..<pointsArr.count {
            var point = pointsArr[i]
            point.x = point.x * self.wBili
            point.y = point.y * self.hBili
            if i == 0 {
                self.drawContext.drawPoints(state: .begin, point: point)
            }else if i == pointsArr.count - 1 {
                self.drawContext.drawPoints(state: .ended, point: point)
            }else{
                self.drawContext.drawPoints(state: .moved, point: point)
            }
        }
    }
    
    func drawPoint(point:CGPoint,state:DrawingState,text:String?=nil,angle:Double?=nil) {
        var p = point
        p.x = p.x * self.wBili
        p.y = p.y * self.hBili
        switch state {
        case .begin:
            self.drawContext.drawPoints(state: .begin, point: p, textStr: text , angle:angle)
        case .moved:
            self.drawContext.drawPoints(state: .moved, point: p, textStr: text , angle:angle)
        case .ended:
            self.drawContext.drawPoints(state: .ended, point: p, textStr: text , angle:angle)
        }
    }

}

extension ImgviewContent:DrawContextDelegate{
    //上传文件
    func drawContext(uploadxml view:DrawContext,xmlStr:String?){
        self.delegate?.imgContent?(view: self, xmlStr: xmlStr)
//        self.showdownLoading()
//        var params = [String:AnyObject]()
//        params["uid"] = "1" as AnyObject
//        if let xml = xmlStr {
//            params["xml_str"] = xml as AnyObject
//        }
//        
//        DownloadManager.DownloadPost(host: "http://gangqinputest.yusi.tv/", path: "urlparam=note/xmlstr/setxmlbyuid", params: params, successed: {[weak self](JsonString) in
//            print(JsonString ?? "")
//            self?.hidedownLoading()
//            let result = Mapper<PostXmlModel>().map(JSONString: JsonString!)
//            if let obj = result{
//                if obj.returnCode == "0000" {
//                    self?.showMsg("上传成功")
//                }else{
//                    self?.showMsg("数据有问题")
//                }
//            }else{
//                self?.showMsg("获取数据失败")
//            }
//        }) {[weak self] (error) in
//            self?.hidedownLoading()
//            self?.showMsg("网络异常")
//        }
    }
    
    func drawContextScale(view:DrawContext,scale:CGFloat){
//        self.view.bringSubview(toFront: self.segment)
//        self.view.bringSubview(toFront: self.bottomView)
//        
//        if self.bgImage.width < UIScreen.main.bounds.width {
//            UIView.animate(withDuration: 0.5, animations: {
//                self.bgImage.frame = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 85 - 64)
//            })
//        }else{
//            self.bgImage.transform = CGAffineTransform(scaleX: scale, y: scale)
//        }
    }
    
    func drawContextMove(view:DrawContext,moveX:CGFloat,moveY:CGFloat){
        
//        self.bgImage.frame = CGRect(x: self.bgImage.frame.origin.x + moveX, y: self.bgImage.frame.origin.y + moveY, width: self.bgImage.width, height: self.bgImage.height)
    }
}


