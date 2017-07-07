//
//  ImgScrollVIew.swift
//  FCFDrawBoard
//
//  Created by 冯才凡 on 2017/7/8.
//  Copyright © 2017年 com.fcf. All rights reserved.
//

import UIKit

class ImgScrollVIew: UIScrollView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ImgScrollVIew{
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            //移动
            print(gestureRecognizer.numberOfTouches )
            if gestureRecognizer.numberOfTouches == 2 {
                return true
            }
            
        }else{
            return true
        }
        return false
    }
}
