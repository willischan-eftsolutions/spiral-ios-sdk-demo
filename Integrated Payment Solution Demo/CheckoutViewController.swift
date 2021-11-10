//
//  CheckoutViewController.swift
//  Integrated Payment Solution Demo
//
//  Created by kam on 24/6/2021.
//  Copyright © 2021 EFT Solutions. All rights reserved.
//

import UIKit
import IntegratedPaymentSolutionSDK

class CheckoutViewController: UIViewController {
    private var dataSource: PaymentDataSource!
    
    @IBOutlet var amountField: UITextField!
    @IBOutlet var paymentTypePicker: UIPickerView!
    @IBOutlet var resultField: UITextView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var payButton: UIButton!
    @IBOutlet var merchantRefLabel: UILabel!
    @IBOutlet var paymentTypeLabel: UILabel!
    
    enum CheckoutError: Error {
        case parseJsonError
    }
    
    var sessionId: String!
    
    let hostConnection = HostConnection()
    var orginalColor: UIColor = .systemBlue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataSource = PaymentDataSource()
        paymentTypePicker.delegate = dataSource
        paymentTypePicker.dataSource = dataSource
//        loadingIndicator.style = .large
        ApiManager.sharedInstance.config(viewController: self)
        orginalColor = navigationController?.navigationBar.tintColor ?? .systemBlue
        
        navigationItem.title = AppDelegate.ENV_NAME + " Environment"
    }
    
    func startLoadingIndicator(clearText: Bool = true) {
        if Thread.isMainThread {
            if clearText {
                self.resultField.text = ""
            }
            self.loadingIndicator.startAnimating()
            // disable the pay button and back button to prevent the transaction being interrupted
            payButton.isEnabled = false
            navigationController?.navigationBar.isUserInteractionEnabled = false
            navigationController?.navigationBar.tintColor = .lightGray
        } else {
            DispatchQueue.main.sync(execute: {
                self.startLoadingIndicator(clearText: clearText)
            })
        }
    }
    
    func setResultText(_ result: String) {
        if Thread.isMainThread {
            self.resultField.text = result
            self.loadingIndicator.stopAnimating()
            // Enable the pay button and back button after transaction finish
            payButton.isEnabled = true
            navigationController?.navigationBar.isUserInteractionEnabled = true
            navigationController?.navigationBar.tintColor = orginalColor
        } else {
            DispatchQueue.main.sync(execute: {
                self.setResultText(result)
            })
        }
    }
    
    @IBAction func checkoutTapped(_ sender: AnyObject) {
        let selectedIndex = paymentTypePicker.selectedRow(inComponent: 0)
        guard selectedIndex < dataSource.supportedPaymentType.count
             else {
                resultField.text = "Unknown Error"
                return
        }
        let paymentType = dataSource.supportedPaymentType[selectedIndex]
        guard let amtText = amountField.text,
            let amount = UInt64(amtText) else {
                resultField.text = "Please input integer amount"
                return
        }
        startLoadingIndicator()
        resultField.text = ""
        merchantRefLabel.text = ""
        paymentTypeLabel.text = paymentType.text()
        hostConnection.getSessionIdFromHost(amount: amount, type: paymentType.id(), completion: {(sessionId, merchantRef, error) in
            guard let sessionId = sessionId else {
                self.setResultText(error.debugDescription)
                return
            }
            NSLog("sessionId=\(sessionId)")
            self.sessionId = sessionId
            DispatchQueue.main.async {
                ApiManager.sharedInstance.paymentType = paymentType
                switch paymentType {
                case .VM, .FPS:
                    let payment = SpiralPayment(apiUrl: AppDelegate.SPIRAL_API_URL)
                    payment.pay(sessionId, callback: self as PaymentResultCallback)
                case .AlipayHK, .AlipayCN:
                    let payment = ApiManager.sharedInstance.getAlipayPayment()
                    payment.pay(sessionId, callback: self as PaymentResultCallback)
                default:
                    self.setResultText("Not support")
                }
            }
        })
    }
}

extension CheckoutViewController: PaymentResultCallback {
    func getPaymentStatusStr(_ status: PaymentStatus) -> String {
        switch (status) {
        case .APPROVED:
            return "APPROVED"
        case .CANCELLED:
            return "CANCELLED"
        case .DECLINED:
            return "DECLINED"
        case .UNCONFIRMED:
            return "UNCONFIRMED"
        case .QUERY_FAILED:
            return "QUERY_FAILED"
        default:
            return ""
        }
    }
    func setResult(_ paymentResult: PaymentResult) {
        if Thread.isMainThread {
            self.resultField.text = "Session Id: \(paymentResult.getSessionId())\nPayment Status: \(getPaymentStatusStr(paymentResult.getPaymentStatus()))"
            self.loadingIndicator.stopAnimating()
            // Enable the pay button and back button after transaction finish
            payButton.isEnabled = true
            navigationController?.navigationBar.isUserInteractionEnabled = true
            navigationController?.navigationBar.tintColor = orginalColor
        } else {
            DispatchQueue.main.sync(execute: {
                self.setResult(paymentResult)
            })
        }
    }
    
    func onSuccess(_ paymentResult: PaymentResult) {
        setResult(paymentResult)
    }
    
    func onFailure(_ paymentResult: PaymentResult) {
        setResult(paymentResult)
    }
    
    
}
