//
//  WXApiManager.swift
//  Integrated Payment Solution Demo
//
//  Created by kam on 28/7/2021.
//  Copyright © 2021 EFT Solutions. All rights reserved.
//

import Foundation

class ApiManager: NSObject, WXApiDelegate {
    public static let sharedInstance = ApiManager()
    private weak var viewController: CheckoutViewController?
    
    private override init() {}
    
    public func config(viewController: CheckoutViewController) {
        self.viewController = viewController
    }
    
    func onReq(_ req: BaseReq) {
        print("WXApi:onReq[\(req)]")
    }
    
    func onResp(_ resp: BaseResp) {
        print("WXApi:onResp[\(resp)]")
        if let payResp = resp as? PayResp {
            viewController?.analyseWeChatPayResult(resp: payResp)
        }
    }
}
