//
//  MineTabBarController.swift
//  FCFCommonTools
//
//  Created by 冯才凡 on 2017/4/6.
//  Copyright © 2017年 com.fcf. All rights reserved.
//

import UIKit

class MineTabBarController: UITabBarController {
    
    var first:FirstController {
        return FirstController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadControllers()
    }
    
    func loadControllers() {
        let controllArr = [("画板","First_Selected","First_Unselected",first)] as [(String,String,String,BaseViewController)]
        
        for (name,selectedImg,UnselectedImg,controller) in controllArr {
            controller.tabBarItem = UITabBarItem(title: name, image: UIImage(named: UnselectedImg)?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: selectedImg)?.withRenderingMode(.alwaysOriginal))
            let nc:MineNavigationController = MineNavigationController()
            nc.addChildViewController(controller)
            controller.title = name
            self.addChildViewController(nc)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
