//
//  HostConnection.swift
//  Integrated Payment Solution Demo
//
//  Created by kam on 9/8/2021.
//  Copyright © 2021 EFT Solutions. All rights reserved.
//

import Foundation
import IntegratedPaymentSolutionSDK

class HostConnection: NSObject {
    public var hostTimeout = 10.0
    
    public enum HostConnectionError: Error {
        case paramError
        case decodeJsonError
        case parseJsonError
        case hostSignatureError
        case hostError(String, String?)
    }
    
//    private let mockHost = MockMerchantSandboxHost(clientId: "eftit_prod", spiralApiHost: "https://b8jhphintc.execute-api.ap-east-1.amazonaws.com", clientPrivateKeyFile: "custpri-development", apiHostPublicKeyFile: "spiralpub-development")
    
    private let merchantSite = "http://xmo.exw.mybluehost.me/samples/create-order.php"
//    private let merchantSite = "http://demo.eftsolutions.com/spiraldemo/spiraldemo_alipay/create-order.php"
    public func getSessionIdFromHost(amount: UInt64, type: String, completion: @escaping (String?, String?, Error?) -> Void) {
        
//        mockHost.generateSessionId(amount: amount, type: type, goodsName: "Goods Name", goodsDesc: nil, completion: completion)
//
        let urlStr = "\(merchantSite)?type=\(type)&amount=\(Double(amount) / 100.0)&channel=APP"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            guard let data = data else {
                    completion(nil, nil, error)
                    return
            }
//                NSLog("Host Response:\(String(data: data, encoding: .utf8) ?? "Empty Data")")
            let sessionId = String(data: data, encoding: .utf8)
            completion(sessionId, nil, nil)
        }

        task.resume()
    }
}
