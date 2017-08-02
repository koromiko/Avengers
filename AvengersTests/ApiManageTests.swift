//
//  ApiManageTests.swift
//  Avengers
//
//  Created by Neo on 02/08/2017.
//  Copyright © 2017 Neo. All rights reserved.
//
//: Playground - noun: a place where people can play


import XCTest
@testable import Avengers

//MARK: MOCK
class MockURLSession: URLSessionProtocol {
    
    var nextData: Data?
    var nextError: Error?
    
    private (set) var lastURL: URL?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping URLSessionProtocol.DataTaskResult) -> URLSessionDataTask {
        
        lastURL = request.url
        
        completionHandler(nextData, nil, nextError)
        return MockURLSessionDataTask()
    }
    
}

class MockURLSessionDataTask: URLSessionDataTask {
    override func resume() {}
}

//MARK: Test
class HttpClientTests: XCTestCase {
    
    var manager: ApiManager!
    let session = MockURLSession()
    
    override func setUp() {
        super.setUp()
        manager = ApiManager(session: session )
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_get_character_with_correct_host() {
        
        manager.fetchCharacterList(offset: 0) { (success, response) in
            // Some data
        }

        XCTAssertEqual(session.lastURL?.host, "gateway.marvel.com")
        
    }
    
    func test_fetch_char_should_return_data() {
        let expectedData = "{}".data(using: .utf8)
        
        session.nextData = expectedData
        
        var actualData: AnyObject?
        manager.fetchCharacterList(offset: 0) { (success, response) in
            // Some data
            actualData = response
        }
        
        XCTAssertNotNil(actualData)
    }
    
}




