//
//  MockMerchantSandboxHost.swift
//  Integrated Payment Solution Demo
//
//  Created by kam on 6/7/2021.
//  Copyright © 2021 EFT Solutions. All rights reserved.
//

import Foundation

/// For production, the private keys should be stored in merchant server and signing should be done by merchant server.
class MockMerchantSandboxHost {
    private let clientId: String
    private let dateTimeFormatter: DateFormatter
    private let dateTimeFormatterForMerchantRef: DateFormatter
    
    private let spiralApiHost: String
    private let clientPrivateKeyFile: String
    private let apiHostPublicKeyFile: String
    
    public init(clientId: String, spiralApiHost: String, clientPrivateKeyFile: String, apiHostPublicKeyFile: String) {
        self.clientId = clientId
        self.spiralApiHost = spiralApiHost
        self.clientPrivateKeyFile = clientPrivateKeyFile
        self.apiHostPublicKeyFile = apiHostPublicKeyFile
        
        dateTimeFormatter = DateFormatter()
        dateTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateTimeFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateTimeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        dateTimeFormatterForMerchantRef = DateFormatter()
        dateTimeFormatterForMerchantRef.locale = Locale(identifier: "en_US_POSIX")
        dateTimeFormatterForMerchantRef.timeZone = TimeZone(secondsFromGMT: 0)
        
        dateTimeFormatterForMerchantRef.dateFormat = "MMddHHmmssSSS"
    }
    
    public func getMerchantRef() -> String {
        var string = dateTimeFormatterForMerchantRef.string(from: Date())
        string.removeLast()
        return "SEFTP\(string)"
    }
    
    public func getSpiralDatetime() -> String {
        return dateTimeFormatter.string(from: Date())
    }
    
    public func getSpiralClientSignature(merchantRef: String, datetime: String) throws -> String {
        let payload = "\(clientId)\(merchantRef)\(datetime)".data(using: .utf8)
        
        // Get the key
        let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                      kSecAttrKeyClass as String: kSecAttrKeyClassPrivate]
        var error: Unmanaged<CFError>?
        guard let path = Bundle.main.path(forResource: clientPrivateKeyFile, ofType: "der"),
            let data = NSData(contentsOfFile: path),
            let privateKey = SecKeyCreateWithData(data as CFData, options as CFDictionary, &error) else {
                throw error!.takeRetainedValue() as Error
        }
        
        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256
        
        guard let signature = SecKeyCreateSignature(privateKey, algorithm, payload! as CFData, &error) as Data? else {
            throw error!.takeRetainedValue() as Error
        }
        
        return signature.base64EncodedString()
    }
    
    public func checkSpiralHostSignature(merchantRef: String, datetime: String, signature: String) throws -> Bool {
        let payload = "\(clientId)\(merchantRef)\(datetime)".data(using: .utf8)
        
        // Get the key
        let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                      kSecAttrKeyClass as String: kSecAttrKeyClassPublic]
        var error: Unmanaged<CFError>?
        guard let path = Bundle.main.path(forResource: apiHostPublicKeyFile, ofType: "der"),
            let data = NSData(contentsOfFile: path),
            let publicKey = SecKeyCreateWithData(data as CFData, options as CFDictionary, &error) else {
                throw error!.takeRetainedValue() as Error
        }
        
        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA256
        
        guard let signatureData = Data(base64Encoded: signature, options: .ignoreUnknownCharacters) else {
            return false
        }
        let result = SecKeyVerifySignature(publicKey, algorithm, payload! as CFData, signatureData as CFData, &error)
        
        if let err = error {
            _ = err.takeRetainedValue()
        }
        
        return result
    }
    
    
    public func processRequest(httpMethod: String, jsonData: Data?, merchantRef: String, spiralDatetime: String, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        // prepare signature
        let spiralSignature: String
        do {
            spiralSignature = try getSpiralClientSignature(merchantRef: merchantRef, datetime: spiralDatetime)
        } catch {
            completion(nil, nil, error)
            return
        }
        
        NSLog("merchantRef:\(merchantRef)")
        
        let urlStr = "\(spiralApiHost)/v1/merchants/\(clientId)/transactions/\(merchantRef)"
//        print(urlStr)
        var request = URLRequest(url: URL(string: urlStr)!, timeoutInterval: 15.0)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(spiralDatetime, forHTTPHeaderField: "Spiral-Request-Datetime")
        request.setValue(spiralSignature, forHTTPHeaderField: "Spiral-Client-Signature")
        
        request.httpMethod = httpMethod
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let resp = response as? HTTPURLResponse else {
                    completion(nil, nil, error)
                    return
            }
            NSLog("Host Response:\(String(data: data, encoding: .utf8) ?? "Empty Data")")
            // check signature
//            guard let hostSign = resp.value(forHTTPHeaderField: "Spiral-Server-Signature"),
//                let hostDatetime = resp.value(forHTTPHeaderField: "Spiral-Request-Datetime") else {
//                    completion(nil, nil, HostConnection.HostConnectionError.hostSignatureError)
//                    return
//            }
//            print(resp.allHeaderFields)
            let headers = resp.allHeaderFields as NSDictionary
            guard let hostSign = headers["Spiral-Server-Signature"] as? String,
                  let hostDatetime = headers["Spiral-Request-Datetime"] as? String else {
                completion(nil, nil, HostConnection.HostConnectionError.hostSignatureError)
                return
            }
            do {
                guard try self.checkSpiralHostSignature(merchantRef: merchantRef, datetime: hostDatetime, signature: hostSign) else {
                    completion(nil, nil, HostConnection.HostConnectionError.hostSignatureError)
                    return
                }
            } catch {
                completion(nil, nil, error)
                return
            }
            
            completion(data, resp, nil)
        }
        
        task.resume()
    }
    
    public func generateSessionId(amount: UInt64, type: String, goodsName: String, goodsDesc: String?, completion: @escaping (String?, String?, Error?) -> Void) {
        let merchantRef = getMerchantRef()
        let spiralDatetime = getSpiralDatetime()
        let req = SaleSessionRequest(clientId: clientId, merchantRef: merchantRef, cmd: "SALESESSION", type: type, card: nil, amt: Double(amount)/100, goodsName: goodsName, goodsDesc: goodsDesc, channel: "APP", successUrl: "about:blank", failureUrl: "about:blank", webhookUrl: "https://www.eftsolutions.com/en/", duration: nil)
        guard let jsonData = try? JSONEncoder().encode(req) else {
            completion(nil, nil, HostConnection.HostConnectionError.paramError)
            return
        }
//        print(String(data: jsonData, encoding: .utf8)!)
        
        processRequest(httpMethod: "PUT", jsonData: jsonData, merchantRef: merchantRef, spiralDatetime: spiralDatetime, completion: {
            (data, response, error) in
            guard let data = data else {
                completion(nil, nil, error)
                return
            }
//            print(String(data: data, encoding: .utf8)!)
            
            // get the session id from json
            guard let jsonResp = try? JSONDecoder().decode(SaleSessionResponse.self, from: data) else {
                completion(nil, nil, HostConnection.HostConnectionError.parseJsonError)
                return
            }
            if jsonResp.status.caseInsensitiveCompare("approved") == ComparisonResult.orderedSame,
                let sessionId = jsonResp.sessionId {
                completion(sessionId, jsonResp.merchantRef, nil)
            } else {
                completion(nil, jsonResp.merchantRef, HostConnection.HostConnectionError.hostError(jsonResp.status, jsonResp.error))
            }
        })
    }
    
    public func queryTransactionStatus(merchantRef: String, completion: @escaping (String?, Error?) -> Void) {
        let spiralDatetime = getSpiralDatetime()
        
        processRequest(httpMethod: "GET", jsonData: nil, merchantRef: merchantRef, spiralDatetime: spiralDatetime, completion: {
            (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            // get the session id from json
            guard let jsonResp = try? JSONDecoder().decode(SaleSessionResponse.self, from: data) else {
                completion(nil, HostConnection.HostConnectionError.parseJsonError)
                return
            }
            completion(jsonResp.status, nil)
        })
    }
}

struct SaleSessionRequest: Codable {
    let clientId: String
    let merchantRef: String
    let cmd: String
    let type: String
    let card: String?
    let amt: Double
    let goodsName: String
    let goodsDesc: String?
    let channel: String?
    let successUrl: String
    let failureUrl: String
    let webhookUrl: String
    let duration: String?
}

struct SaleSessionResponse: Codable {
    let clientId: String
    let merchantRef: String
    let cmd: String
    let type: String
    let orderId: String
    let txnId: String
    let merchantId: String
    let subMerchantId: String?
    let card: String?
    let status: String
    let amt: Double
    let goodsName: String
    let goodsDesc: String?
    let channel: String?
    let successUrl: String?
    let failureUrl: String?
    let webhookUrl: String?
    let sessionId: String?
    let qeCode: String?
    let error: String?
}
