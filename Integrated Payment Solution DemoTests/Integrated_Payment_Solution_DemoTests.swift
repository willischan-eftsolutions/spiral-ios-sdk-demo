//
//  Integrated_Payment_Solution_DemoTests.swift
//  Integrated Payment Solution DemoTests
//
//  Created by kam on 24/6/2021.
//  Copyright © 2021 EFT Solutions. All rights reserved.
//

import XCTest
@testable import Integrated_Payment_Solution_Demo

// Test the MockMerchantSandboxHost
class Integrated_Payment_Solution_DemoTests: XCTestCase {
    private var objToTest: MockMerchantSandboxHost!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        objToTest = MockMerchantSandboxHost(clientId: "eftio", spiralApiHost: "https://l147n7xo28.execute-api.ap-east-1.amazonaws.com", clientPrivateKeyFile: "custpri-sandbox", apiHostPublicKeyFile: "spiralpub-sandbox")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testMerchantRefFormat() {
        let merchantRef = objToTest.getMerchantRef()
        print(merchantRef)
        
        XCTAssertLessThanOrEqual(merchantRef.count, 25)
        let regex = try! NSRegularExpression(pattern: "^[\\w\\d]+$")
        let range = NSRange(location: 0, length: merchantRef.count)
        XCTAssertNotNil(regex.firstMatch(in: merchantRef, options: [], range: range))
    }
    
    func testDatetimeFormat() {
        let datetime = objToTest.getSpiralDatetime()
        print(datetime)
        
        XCTAssertEqual(datetime.count, 20)
        let regex = try! NSRegularExpression(pattern: "\\d\\d\\d\\d-\\d\\d-\\d\\dT\\d\\d:\\d\\d:\\d\\dZ")
        let range = NSRange(location: 0, length: datetime.count)
        XCTAssertNotNil(regex.firstMatch(in: datetime, options: [], range: range))
    }
    
    func testCreateSignature() {
        let merchantRef = "00123456"
        let datetime = "2021-07-07T09:00:00Z"
        
        let signature = try? objToTest.getSpiralClientSignature(merchantRef: merchantRef, datetime: datetime)
        
        XCTAssertNotNil(signature)
        if signature != nil {
            XCTAssertEqual(signature!, "l1cSQh3yujkyOxMRtXpjoU19Q5xCQ5Cprlrl6idE1OZ72UivA6huBzHtMSuykKfNk1VB8xala/4ShVxs4CNQeH04FqxxF/dcyvWK1Jni6KJo1I15JwPNCxd9aljMgpEnVb8ySCHbOst+tvDXGmmU6PpEdCVijhqCBp9fr4quidln+c8HaTqRMpiYYWN4FGRcl86rsARCBUbhDnE8Hhp8ZYJgdCY0J9LCtdyl45hS3tmJ0w+LhkKDY6D53bIXx6BFgxcQiUPDw0EnDhoEk8yhHUbLIIr2fz9C7JBugydkxAABZkO28+7jt8UFAaWjzZAszMiJg+nQs/VscSxj6/MJAA==")
        }
    }
    
    func testCheckSignature() {
        let merchantRef = "57502630"
        let datetime = "2021-07-07T04:11:10Z"
        let hostSignature = "wxFJXP9wqqbuWVy0Y1N0o5Wth1gueRd9vOM5NCoBNXtDMmRJ2ZdY1KmT12Zy3GpK77rBCbs9d1fzNEH4UzyUrqH3EQ0i9Sxxf9I1KqRASlpI4M/pUas4NGB7+rJlqd8XKA0MWdOQHWcGj6Xl18ELWGAV7TUmOrkKHS/cQh6IRGVCj2DeQ9QEd/Uu3nLO1HhlXHgefuBJuujr4eV66XQrEQDWYMLiSt+uoMIboADDJImo8CitWdK2JrKeJ6V3tfCfvPaSeY7nl6Mtu+SMFavKGwtY1YP8B8asyXbvaGdzbXHG9xEi5URNVX531V2msMdpXxLYalC2tEXXCskTc/sGBQ=="
        
        let checkResult = try? objToTest.checkSpiralHostSignature(merchantRef: merchantRef, datetime: datetime, signature: hostSignature)
        
        XCTAssertNotNil(checkResult)
        if checkResult != nil {
            XCTAssertEqual(checkResult!, true)
        }
    }
    
    func testCheckInvalidSignature() {
        let merchantRef = "12344321"
        let datetime = "2021-07-07T04:11:10Z"
        let hostSignature = "wxFJXP9wqqbuWVy0Y1N0o5Wth1gueRd9vOM5NCoBNXtDMmRJ2ZdY1KmT12Zy3GpK77rBCbs9d1fzNEH4UzyUrqH3EQ0i9Sxxf9I1KqRASlpI4M/pUas4NGB7+rJlqd8XKA0MWdOQHWcGj6Xl18ELWGAV7TUmOrkKHS/cQh6IRGVCj2DeQ9QEd/Uu3nLO1HhlXHgefuBJuujr4eV66XQrEQDWYMLiSt+uoMIboADDJImo8CitWdK2JrKeJ6V3tfCfvPaSeY7nl6Mtu+SMFavKGwtY1YP8B8asyXbvaGdzbXHG9xEi5URNVX531V2msMdpXxLYalC2tEXXCskTc/sGBQ=="
        
        let checkResult = try? objToTest.checkSpiralHostSignature(merchantRef: merchantRef, datetime: datetime, signature: hostSignature)
        
        XCTAssertNotNil(checkResult)
        if checkResult != nil {
            XCTAssertEqual(checkResult!, false)
        }
    }
}

class MockMerchantSandboxHostDevelopmentTest: XCTestCase {
    private var objToTest: MockMerchantSandboxHost!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        objToTest = MockMerchantSandboxHost(clientId: "eftit_prod", spiralApiHost: "https://cjpazdufok.execute-api.ap-east-1.amazonaws.com", clientPrivateKeyFile: "custpri-development", apiHostPublicKeyFile: "spiralpub-development")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCreateSignature() {
        let merchantRef = "00123456"
        let datetime = "2021-07-07T09:00:00Z"
        
        let signature = try? objToTest.getSpiralClientSignature(merchantRef: merchantRef, datetime: datetime)
        
        XCTAssertNotNil(signature)
        if signature != nil {
            XCTAssertEqual(signature!, "GK3deVFqVlanvJpUnEev2C1PJ13A8MGsG740nnRyxEX0vqsNqP+MhhHIwa+L+pCr33S9LP+keKoXB3FdAwqDaURmlo6UPWVpis9g69l1y5bXghgj2Tit3/B0ASyAVp1yhMrUvaurrtZuAiMnMIiNkgcvv0GHRqZ6kNCiLTTNDLnwzNGTT+9l2CPRp81lsGS4VssIOZ3X2OXJAuRqSIbFgDmnXZoG927HFtMWr8yZxFwl4v1miR4NQI6W6+iAvI8FwEYfikF40av4devp2vmRVSApttOWMfqDs8xajWO1E9Qh8N/6KUtlVriwSqEQ9ptBAovmyN2BdTJNAqEAFS9E1A==")
        }
    }
    
    func testCheckSignature() {
        let merchantRef = "0816093500360"
        let datetime = "2021-08-16T09:35:02Z"
        let hostSignature = "iDANABiJbJc/vtR0+m7jX58px0bjoVGv8eT8AELdz+zaA7eXkIbcuMDzbt4UWpfzVanuSKknmAMAgpMpC4AFtjiBQwTbj5YJwdOphRi+xsKNBMEQzOBDCiGfiFBemreCkzQ9hpMSqYpSvVLKC6kksZjb2dfbksWaS2deWHJZf7yHzTTWxTVoSMgZJpcyhpC/i8i3/3sImlEPZAh/S73AWTsbRvNPpn3Og6rsC8RsX2ym3aloYQ3BVRFw/qY5CwCWr0jqQcGMH8TpIYS2XnibJT5I4tNDEZm6ynijUSgFRQQovX7JYsVIa62MornIIME0+wrhYmsmgbxF0OJlAmdJ8g=="
        
        let checkResult = try? objToTest.checkSpiralHostSignature(merchantRef: merchantRef, datetime: datetime, signature: hostSignature)
        
        XCTAssertNotNil(checkResult)
        if checkResult != nil {
            XCTAssertEqual(checkResult!, true)
        }
    }
    
    func testCheckInvalidSignature() {
        let merchantRef = "123456789012"
        let datetime = "2021-08-16T09:35:02Z"
        let hostSignature = "iDANABiJbJc/vtR0+m7jX58px0bjoVGv8eT8AELdz+zaA7eXkIbcuMDzbt4UWpfzVanuSKknmAMAgpMpC4AFtjiBQwTbj5YJwdOphRi+xsKNBMEQzOBDCiGfiFBemreCkzQ9hpMSqYpSvVLKC6kksZjb2dfbksWaS2deWHJZf7yHzTTWxTVoSMgZJpcyhpC/i8i3/3sImlEPZAh/S73AWTsbRvNPpn3Og6rsC8RsX2ym3aloYQ3BVRFw/qY5CwCWr0jqQcGMH8TpIYS2XnibJT5I4tNDEZm6ynijUSgFRQQovX7JYsVIa62MornIIME0+wrhYmsmgbxF0OJlAmdJ8g=="
        
        let checkResult = try? objToTest.checkSpiralHostSignature(merchantRef: merchantRef, datetime: datetime, signature: hostSignature)
        
        XCTAssertNotNil(checkResult)
        if checkResult != nil {
            XCTAssertEqual(checkResult!, false)
        }
    }
}
