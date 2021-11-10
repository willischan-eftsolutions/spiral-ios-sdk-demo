//
//  ApiManager.swift
//  Integrated Payment Solution Demo
//
//  Created by kam on 28/7/2021.
//  Copyright © 2021 EFT Solutions. All rights reserved.
//

import Foundation
import IntegratedPaymentSolutionSDK

class ApiManager: NSObject {
    public static let sharedInstance = ApiManager()
    private weak var viewController: CheckoutViewController?
    private lazy var alipayPayment = AlipayPayment(apiUrl: AppDelegate.SPIRAL_API_URL, fromScheme: AppDelegate.MY_SCHEME)
    public var paymentType: PaymentDataSource.PaymentType = .VM
    
    private override init() {
        super.init()
    }
    
    public func config(viewController: CheckoutViewController) {
        self.viewController = viewController
    }
    
    public func getAlipayPayment() -> AlipayPayment {
        return alipayPayment
    }
}
