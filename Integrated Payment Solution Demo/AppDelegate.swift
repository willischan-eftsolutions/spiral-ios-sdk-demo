//
//  AppDelegate.swift
//  Integrated Payment Solution Demo
//
//  Created by kam on 24/6/2021.
//  Copyright © 2021 EFT Solutions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let MY_SCHEME = "IntegratedPaymentSolutionDemo"
//    static let SPIRAL_API_URL = "https://b8jhphintc.execute-api.ap-east-1.amazonaws.com/v1/sessions/"
//    static let ENV_NAME = "Development"
    static let SPIRAL_API_URL = "https://api-checkout.spiralplatform.com/v1/sessions/"
    static let ENV_NAME = "Production"
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AlipaySDK.startLog({
            logStr in
            if let logStr = logStr {
                NSLog(logStr)
            }
        })
        print(AlipaySDK.defaultService().currentVersion()!)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
//        let annotation = options[UIApplication.OpenURLOptionsKey.annotation]
        
        NSLog("source application = \(sourceApplication ?? "Unknown"), url=\(url.absoluteString)")
        
        if ApiManager.sharedInstance.paymentType == .AlipayHK ||
            ApiManager.sharedInstance.paymentType == .AlipayCN {
            let payment = ApiManager.sharedInstance.getAlipayPayment()
            if payment.isAlipayResultUrl(url) {
                let result = payment.processResultUrl(url)
                NSLog("processResultUrl=\(result)")
            }
        }
        
        return true
    }
}

