//
//  customUITabBarViewController.swift
//  WheeApp
//
//  Created by Leung Wai Chan on 2/21/18.
//  Copyright © 2018 Leung Wai Chan. All rights reserved.
//

import UIKit

class customUITabBarViewController: UITabBarController {
    let views = ["Calendar", "Todo", "Reward", "Location"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let homeController = NewFeedViewController()
//        let homeNavController = UINavigationController(rootViewController: homeController)
//
//        homeNavController.tabBarItem.title = "Home"
//        homeNavController.tabBarItem.image = UIImage(named: "icon_homeAddress")
//
        
        for view in views {
            let dummy = UIViewController()
            let navController = UINavigationController(rootViewController: dummy)
            navController.tabBarItem.title = view
            self.viewControllers?.append(navController)
        }
       
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
