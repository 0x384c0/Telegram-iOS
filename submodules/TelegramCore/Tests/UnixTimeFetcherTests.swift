//
//  UnixTime.swift
//  _idx_AccountContext_FFB9E9C3_ios_min9.0
//
//  Created by andrew on 10/8/22.
//

import Foundation
import XCTest
import SwiftSignalKit

// TODO: add test build target to bazel config
extension TelegramEngine {
    class UnixTimeFetcherTests: XCTestCase {
        private var disposable: Disposable?
        private var sut: UnixTimeFetcher!

        override func setUp() {
            sut = UnixTimeFetcherImpl() //TODO: mock API response
        }

        override func tearDown() {
            disposable = nil
            sut = nil
        }

        func testGetTimeStampSuccess(){
            let expectation = XCTestExpectation(description: "got timestamp from API")
            var timeStamp:Int32?
            disposable = sut.getTimeStamp()
                .start(
                    next: { timeStampFromApi in
                        timeStamp = timeStampFromApi
                        expectation.fulfill()
                    },
                    completed: {

                    }
                )
            wait(for: [expectation], timeout: 10.0)
            assert(timeStamp != nil)
            assert(timeStamp != 0)
        }
    }
}
