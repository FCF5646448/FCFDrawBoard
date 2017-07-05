//
//  ColorPicker.swift
//  FCFCommonFrame
//
//  Created by 冯才凡 on 2017/6/27.
//  Copyright © 2017年 com.fcf. All rights reserved.
//

import UIKit

typealias selectedCallBack = (_ colorStr:String)->()

class ColorPicker: UIViewController {

    @IBOutlet weak var collctionBg: UIView!
    @IBOutlet weak var colorView: UICollectionView!
    var callback:selectedCallBack?
    var colorData:[String] = []
    
    init(selected:@escaping ((_ colorStr:String)->())) {
        self.callback = selected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        collctionBg.layer.cornerRadius = 4
        collctionBg.layer.masksToBounds = true

        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        let iW:CGFloat = CGFloat(UIScreen.main.bounds.width - 66 - 9.0*2) // - 50 - 16
        let iH:CGFloat = CGFloat(UIScreen.main.bounds.height - 176 - 15 * 2)//70 - 64 - 16 -
        layout.itemSize = CGSize(width: iW/10.0, height: iH/16.0)
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        colorView.showsVerticalScrollIndicator = false
        colorView.showsHorizontalScrollIndicator = false
        colorView.isScrollEnabled = false
        colorView.collectionViewLayout = layout
        colorView.fcfRegister(BaseCollectionViewCell.self)
        
        initColorData()
    }
    
    func initColorData(){
        
        let path = Bundle.main.path(forResource: "colorPalette", ofType: "plist")
        let plistArr = NSArray.init(contentsOfFile: path!)
        if let dataArr = plistArr {
            for item in dataArr {
                colorData.append(item as! String)
            }
        }
        colorView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ColorPicker:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    //
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorData.count
    }
    //
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.colorView.fcfDequeueReusableCell(forIndexPath: indexPath) as BaseCollectionViewCell
        cell.backgroundColor = UIColor.haxString(hex: colorData[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let colorstr = self.colorData[indexPath.row]
        self.callback!(colorstr)
        self.dismiss(animated: false, completion: nil)
    }
}
