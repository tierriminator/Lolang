//
//  LinuxMain.swift
//  LLC
//
//  Created by Tierry Hörmann on 11.09.17.
//
//

#if os(Linux)
import XCTest

XCTMain([
    testCase(CodeStreamTest.allTests),
    testCase(ParsingTreeConstructorTest.allTests),
    testCase(ParerTest.allTests)
    ])

#endif
