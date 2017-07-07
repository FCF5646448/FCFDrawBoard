//
//  Quartz2DTestController.swift
//  FCFCommonFrame
//
//  Created by 冯才凡 on 2017/6/16.
//  Copyright © 2017年 com.fcf. All rights reserved.
//

import UIKit
import ObjectMapper

class XmlModel:BaseModel{
    var returnMsg:String = ""
    var returnCode:String = ""
    var data:xmlDataObj?
    
    override func mapping(map: Map) {
        returnMsg <- map["returnMsg"]
        returnCode <- map["returnCode"]
        data <- map["data"]
    }
}

class xmlDataObj: BaseModel {
    var id:String = ""
    var uid:String = ""
    var xml_str:String = ""
    override func mapping(map: Map) {
        id <- map["id"]
        uid <- map["uid"]
        xml_str <- map["xml_str"]
    }
}

//1、将每次画的东西先存到全局类里
//2、然后在app关闭的时候，将画的东西转成xml文档
//3、每次打开页面的时候，先从全局数组里拿到数据，没有的话，从xml里将数据拿到，然后缓存到数组里，生成新的图片。将图片放到全局数组里

//画图的原理就是每次从上一点画到下一点
class Quartz2DTestController: BaseViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var forwardBtn: UIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var colorBtn: UIButton!
    
    @IBOutlet weak var clearBtn: UIButton!
    
    @IBOutlet weak var fontSizeSlide: UISlider!
    
    
    var hasbegin:Bool = false
    
    var surrentScale:CGFloat = 1 //记录上一次手势放大的倍数
    
    var currentImgViewContent:ImgviewContent! //当前画布
    
    var selectedIndex:Int = 0
    
    var selectedColor:String = "000000" {
        didSet {
            self.colorBtn.backgroundColor = UIColor.haxString(hex: selectedColor)
            self.currentImgViewContent?.changeBrushColor(color: selectedColor)
        }
    }
    
    var fontSize:CGFloat = 13.0 {
        didSet {
            self.currentImgViewContent?.changeBrushSize(size: fontSize)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
        title = "画板"
        updateUI()
        segment.addTarget(self, action: #selector(segmentValueChanged), for: .valueChanged)
        segment.selectedSegmentIndex = selectedIndex //默认就是画曲线的画笔
        segmentValueChanged(seg: segment)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func updateUI(){
        self.backBtn.layer.cornerRadius = 4
        self.backBtn.layer.masksToBounds = true
        self.forwardBtn.layer.cornerRadius = 4
        self.forwardBtn.layer.masksToBounds = true
        self.colorBtn.layer.cornerRadius = 4
        self.colorBtn.layer.masksToBounds = true
        self.clearBtn.layer.cornerRadius = 4
        self.clearBtn.layer.masksToBounds = true
        
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitle("保存", for: .normal)
        btn.addTarget(self, action: #selector(saveXml), for: .touchUpInside)
        let rbtn = UIBarButtonItem(customView: btn)
        let btn2 = UIButton.init(type: .custom)
        btn2.frame = CGRect(x: 0, y: 44, width: 44, height: 44)
        btn2.setTitleColor(UIColor.white, for: .normal)
        btn2.setTitle("刷新", for: .normal)
        btn2.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        let rbtn2 = UIBarButtonItem(customView: btn2)
        
        self.navigationItem.rightBarButtonItems = [rbtn,rbtn2]
        
        let scrollView = ImgScrollVIew(frame: CGRect(x: 0, y: 40, width: ContentWidth, height: ContentHeight-85)) //UIScrollView
        let imgContent = ImgviewContent(frame: CGRect(x: 0, y: 0, width: ContentWidth, height: ContentHeight-85))
        imgContent.delegate = self
        self.currentImgViewContent = imgContent
        scrollView.contentSize = CGSize(width: ContentWidth, height: ContentHeight-85)
        scrollView.addSubview(imgContent)
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.bouncesZoom = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.currentImgViewContent.hasDraw() {
            self.currentImgViewContent.restoreDraw()
        }else{
            //从xml中读取
            self.refresh()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.currentImgViewContent.removeUselessSave()
    }

    //复原 减笔画
    @IBAction func backoutSelected(_ sender: Any) {
        if self.currentImgViewContent.canBack() {
            currentImgViewContent.undo()
        }
    }
    
    //重做 加笔画
    @IBAction func redrawSelected(_ sender: Any) {
        if self.currentImgViewContent.canForward() {
            self.currentImgViewContent.redo()
        }
    }
    
    //换颜色
    @IBAction func colorBtnClicked(_ sender: Any) {
        if segment.selectedSegmentIndex == 4 {
            return
        }
        showColorPick()
    }
    
    //调整画笔大小
    @IBAction func fontSizeChanged(_ sender: Any) {
        fontSize = CGFloat((sender as! UISlider).value)
    }
    
    @IBAction func clearBtnClicked(_ sender: Any) {
        //清空就没法重做了
        self.currentImgViewContent.clear()
    }
    
    func segmentValueChanged(seg:UISegmentedControl){
        if seg.selectedSegmentIndex == 2 {
            self.currentImgViewContent.showTextVIewUIMsg()
        }else{
            self.currentImgViewContent.hideTextViewUIMsg()
        }
        switch seg.selectedSegmentIndex {
        case 0:
            //画笔
            self.currentImgViewContent.initBrush(type: .Pentype(.Curve), color: selectedColor, width: fontSize)
            break
        case 1:
            //形状,先默认是矩形
            self.currentImgViewContent.initBrush(type: .Formtype(.Rect), color: selectedColor, width: fontSize)
            break
        case 2:
            //文本
            self.currentImgViewContent.initBrush(type: .Text, color: selectedColor, width: fontSize)
            break
        case 3:
            //音符，当作文字来添加
            self.currentImgViewContent.initBrush(type: .Note, color: selectedColor, width: fontSize)
            break
        case 4:
            //橡皮擦,不需要选颜色
            self.currentImgViewContent.initBrush(type: .Eraser, color: selectedColor, width: fontSize)
            break
        default:
            break
        }
    }
    
    //选完颜色和大小
    func showColorPick() {
        let color = ColorPicker.init { (colorStr) in
            self.selectedColor = colorStr
        }
        color.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        color.definesPresentationContext = true
        color.modalPresentationStyle = .overCurrentContext
        self.present(color, animated: false, completion: nil)
    }
    
    deinit {
        
    }
    
}

extension Quartz2DTestController{
    //将xml的操作顺序放进数组里
    func getDataFromXML(){
        self.currentImgViewContent.clear()
        
        var pathArr:[PathModel] = []
        
        let filePath:String = NSHomeDirectory() + "/Documents/DrawText.xml"
        
        let url = URL(fileURLWithPath: filePath)
        //xml
        let xmlData = try! Data(contentsOf: url)
        //
        let doc = try! DDXMLDocument(data: xmlData, options: 0)
        
        let paths = try! doc.nodes(forXPath: "//Path") as! [DDXMLElement]
        
        for path in paths {
            let obj:PathModel = PathModel()
            if let pen_type = path.attribute(forName: "pen_type") {
                obj.pen_type = pen_type.stringValue
            }
            
            if let pen_shape = path.attribute(forName: "pen_shape") {
                obj.pen_shape = pen_shape.stringValue
            }
            
            if let pen_width = path.attribute(forName: "pen_width") {
                obj.pen_width = pen_width.stringValue
            }
            if let color = path.attribute(forName: "color") {
                
                var colorStr = color.stringValue
                if (colorStr?.hasPrefix("#"))! {
                    let range = colorStr!.index(colorStr!.startIndex, offsetBy: 0)..<colorStr!.index(colorStr!.startIndex, offsetBy: 1)
                    colorStr!.removeSubrange(range)
                }
                
                obj.color = colorStr
            }
            if let rotate_degree = path.attribute(forName: "rotate_degree"){
                obj.rotate_degree = rotate_degree.stringValue
            }
            if let pivot_x = path.attribute(forName: "pivot_x") {
                obj.pivot_x = pivot_x.stringValue
            }
            if let pivot_y = path.attribute(forName: "pivot_y") {
                obj.pivot_y = pivot_y.stringValue
            }
            if let point_list = path.attribute(forName: "point_list") {
                obj.point_list = point_list.stringValue
            }
            if let size = path.attribute(forName: "size") {
                obj.size = size.stringValue
            }
            if let text_rotate = path.attribute(forName: "text_rotate") {
                obj.text_rotate = text_rotate.stringValue
            }
            if let text_x = path.attribute(forName: "text_x") {
                obj.text_x = text_x.stringValue
            }
            if let text_y = path.attribute(forName: "text_y") {
                obj.text_y = text_y.stringValue
            }
            if let start_x = path.attribute(forName: "start_x") {
                obj.start_x  = start_x.stringValue
            }
            if let start_y = path.attribute(forName: "start_y") {
                obj.start_y = start_y.stringValue
            }
            if let end_x = path.attribute(forName: "end_x") {
                obj.end_x = end_x.stringValue
            }
            if let end_y = path.attribute(forName: "end_y") {
                obj.end_y = end_y.stringValue
            }
            if let symbol = path.attribute(forName: "symbol") {
                obj.symbol = symbol.stringValue
            }
            if let text = path.attribute(forName: "text") {
                obj.text = text.stringValue
            }
            pathArr.append(obj)
        }
        
        for obj in pathArr {
            if obj.pen_type == "HAND" {
                if obj.pen_shape == "HAND_WRITE" {
                    obj.type = .Pentype(.Curve)
                }else if obj.pen_shape == "ARROW"{
                    //  箭头
                }else if obj.pen_shape == "LINE"{
                    obj.type = .Pentype(.Line)
                }else if obj.pen_shape == "FILL_CIRCLE"{
                    //实心圆
                }else if obj.pen_shape == "HOLLOW_CIRCLE"{
                    obj.type = .Formtype(.Ellipse)
                }else if obj.pen_shape == "FILL_RECT"{
                    //
                }else if obj.pen_shape == "HOLLOW_RECT"{
                    obj.type = .Formtype(.Rect)
                }else if obj.pen_shape == "SYMBOL"{
                    obj.type = .Note
                }
                    
            }else if obj.pen_type == "ERASER" {
                obj.type = .Eraser
            }else if obj.pen_type == "TEXT" {
                obj.type = .Text
            }
            
            self.currentImgViewContent.autoDraw(obj: obj)
        }
    }
}

extension Quartz2DTestController{
    //将全局数组里的数据按画画顺序存进xml文本中
    func saveXml(){
        self.currentImgViewContent.saveXml()
    }
    
    func refresh(){
        showdownLoading()
        var params = [String:AnyObject]()
        params["uid"] = "1" as AnyObject
        DownloadManager.DownloadGet(host: "http://gangqinputest.yusi.tv/", path: "urlparam=note/xmlstr/getxmlbyuid", params: params, successed: {[weak self] (JsonString) in
            print(JsonString ?? "")
            self?.hidedownLoading()
            let result = Mapper<XmlModel>().map(JSONString: JsonString!)
            if let obj = result{
                if obj.returnCode == "0000" && obj.data != nil {
                    if obj.data!.xml_str != "" {
                        let filePath:String = NSHomeDirectory() + "/Documents/DrawText.xml"
                        try! obj.data!.xml_str.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
                        self?.getDataFromXML()
                    }
                    //读取
                }else{
                    self?.showMsg("数据有问题")
                }
            }else{
                self?.showMsg("获取数据失败")
            }
        }) {[weak self] (error) in
            self?.hidedownLoading()
            self?.showMsg("网络异常")
        }
    }
}

class PostXmlModel:BaseModel{
    var returnMsg:String = ""
    var returnCode:String = ""
    override func mapping(map: Map) {
        returnMsg <- map["returnMsg"]
        returnCode <- map["returnCode"]
    }
}

extension Quartz2DTestController:ImgviewContentDelegate{
    func imgContent(view:ImgviewContent,segmentIndex:NSInteger,selectcolor:String,dwidth:CGFloat){
        self.segment.selectedSegmentIndex = segmentIndex
        self.colorBtn.backgroundColor = UIColor.haxString(hex: selectcolor)
        self.fontSizeSlide.setValue((Float(dwidth > CGFloat(35.0) ? CGFloat(35.0) : dwidth)), animated: false)
        self.fontSize = (dwidth > CGFloat(35.0) ? CGFloat(35.0) : dwidth)
    }
    
    //上传文件
    func imgContent(view:ImgviewContent,xmlStr:String?){
        self.showdownLoading()
        var params = [String:AnyObject]()
        params["uid"] = "1" as AnyObject
        if let xml = xmlStr {
            params["xml_str"] = xml as AnyObject
        }
        
        DownloadManager.DownloadPost(host: "http://gangqinputest.yusi.tv/", path: "urlparam=note/xmlstr/setxmlbyuid", params: params, successed: {[weak self](JsonString) in
            print(JsonString ?? "")
            self?.hidedownLoading()
            let result = Mapper<PostXmlModel>().map(JSONString: JsonString!)
            if let obj = result{
                if obj.returnCode == "0000" {
                    self?.showMsg("上传成功")
                }else{
                    self?.showMsg("数据有问题")
                }
            }else{
                self?.showMsg("获取数据失败")
            }
        }) {[weak self] (error) in
            self?.hidedownLoading()
            self?.showMsg("网络异常")
        }
    }
}

extension Quartz2DTestController:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        for subview in scrollView.subviews {
            if subview.classForKeyedArchiver == ImgviewContent.classForCoder() {
                return subview
            }
        }
        return nil
    }
}
