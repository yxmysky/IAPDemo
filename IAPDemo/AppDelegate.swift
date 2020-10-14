//
//  AppDelegate.swift
//  IAPDemo
//
//  Created by mac on 2020/10/9.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window?.rootViewController = ViewController()

        return true
    }



}

