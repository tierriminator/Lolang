//
//  ParserTest.swift
//  LLC
//
//  Created by Tierry Hörmann on 11.09.17.
//
//

import XCTest
@testable import Lib

class ParserTest: XCTestCase {
    
    #if os(Linux)
    static var allTests = {
        [
            ("testEmptyCodeStream", testEmptyCodeStream()),
            ("testCodeStream", testCodeStream()),
            ("testParsingTreeGeneration", testParsingTreeGeneration())
        ]
    }()
    #endif
    
    func testEmptyCodeStream() {
        var emptyStream = CodeStream("")
        XCTAssert(emptyStream.loc == LocationBeforeCode)
        XCTAssert(!emptyStream.recording)
        emptyStream.record()
        XCTAssert(emptyStream.recording)
        XCTAssert(emptyStream.peek() == nil)
        XCTAssert(emptyStream.next() == nil)
        XCTAssert(emptyStream.loc == LocationAfterCode)
        emptyStream.next()
        XCTAssert(emptyStream.stopRecording() == "")
        XCTAssert(emptyStream.recording == false)
    }
    
    func testCodeStream() {
        var stream = CodeStream("a\nbcd")
        XCTAssert(stream.peek()! == "a")
        XCTAssert(isBeforeCode(loc: stream.loc))
        XCTAssert(stream.next()! == "a")
        XCTAssert(stream.loc == (0,0))
        stream.next()
        XCTAssert(stream.loc == (0,1))
        stream.record()
        stream.next()
        XCTAssert(stream.loc == (1, 0))
        let _ = stream.peek()
        XCTAssert(stream.next()! == "c")
        stream.next()
        XCTAssert(stream.loc == (1, 2))
        XCTAssert(stream.next() == nil)
        XCTAssert(isAfterCode(loc: stream.loc))
        stream.next()
        XCTAssert(stream.stopRecording() == "bcd")
    }
    
    func testParsingTreeGeneration() {
        func dummy1(x: String) throws -> AST? {
            return nil
        }
        func dummy2(x: String) throws -> AST? {
            return nil
        }
        // test for empty tree
        let input: [(String, (String) throws -> AST?)] = []
        let out = constructPT(from: input)
        let supposed = ParsingTree.Root([])
        XCTAssert(out == supposed)
    }
}
