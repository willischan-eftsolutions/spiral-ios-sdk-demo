//
//  PaymentDataSource.swift
//  Integrated Payment Solution Demo
//
//  Created by kam on 24/6/2021.
//  Copyright © 2021 EFT Solutions. All rights reserved.
//

import UIKit
import IntegratedPaymentSolutionSDK

class PaymentDataSource: NSObject {
    public enum PaymentType: Int, CaseIterable {
        case VM
        case AlipayHK
        case AlipayCN
        case WeChat
        case FPS
        
        // Display text
        func text() -> String {
            switch self {
            case .VM:
                return "Visa/MasterCard"
            case .AlipayHK:
                return "AlipayHK"
            case .AlipayCN:
                return "AlipayCN"
            case .WeChat:
                return "WeChat Pay"
            case .FPS:
                return "FPS"
            }
        }
        
        func id() -> String {
            switch self {
            case .VM:
                return "VM"
            case .AlipayHK:
                return "ALIPAYHK"
            case .AlipayCN:
                return "ALIPAYCN"
            case .WeChat:
                return "WECHAT"
            case .FPS:
                return "FPS"
            }
        }
    }
    
    public let supportedPaymentType: [PaymentType] = [
        .VM,
        .AlipayHK,
        .AlipayCN,
        .FPS
    ]
}

extension PaymentDataSource:  UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return supportedPaymentType.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return supportedPaymentType[row].text()
    }
}
