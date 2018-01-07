//
//  ParserTest.swift
//  LLC
//
//  Created by Tierry Hörmann on 11.09.17.
//
//

import XCTest
@testable import Lib

class CodeStreamTest: XCTestCase {
    
    #if os(Linux)
    static var allTests = {
        [
            ("testEmpty", testEmpty),
            ("testFull", testFull),
            ("testMultiplePeek", testMultiplePeek)
        ]
    }()
    #endif
    
    func testEmpty() {
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
    
    func testFull() {
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
    
    func testMultiplePeek() {
        var stream = CodeStream("abcd")
        XCTAssert(stream.peek(3) == "abc")
        XCTAssert(stream.next()! == "a")
        XCTAssert(stream.next()! == "b")
        XCTAssert(stream.peek(3) == "cd")
        XCTAssert(stream.next()! == "c")
        XCTAssert(stream.next()! == "d")
        XCTAssert(stream.next() == nil)
        XCTAssert(stream.peek(1) == "")
    }
}

class ParsingTreeConstructorTest: XCTestCase {
    #if os(Linux)
    static var allTests = {
    [
    ("testEmpty", testEmpty),
    ("testSingleLeaf", testSingleLeaf),
    ("testSingleNodeAndLeaf", testSingleNodeAndLeaf),
    ("testSingleBranch", testSingleBranch),
    ("testDoubleBranch", testDoubleBranch),
    ("testFull", testFull),
    ("testFault", testFault),
    ]
    }()
    #endif
    
    // dummy functions
    func f1(x: String) throws -> AST? {
        return nil
    }
    func f2(x: String) throws -> AST? {
        return nil
    }
    
    func testEmpty() {
        let input: [(String, (String) throws -> AST?)] = []
        let out = constructPT(from: input)
        let supposed = ParsingTree.Root([])
        XCTAssert(out == supposed)
    }
    
    func testSingleLeaf() {
        let input = [("a", f1)]
        let supposed = ParsingTree.Root([.Leaf("a", f1)])
        let out = constructPT(from: input)
        XCTAssert(out == supposed)
    }
    
    func testSingleNodeAndLeaf() {
        let input = [("ab", f1)]
        let supposed = ParsingTree.Root([.Node("a", [.Leaf("b", f1)])])
        let out = constructPT(from: input)
        XCTAssert(out == supposed)
    }
    
    func testSingleBranch() {
        let input = [
            ("ab", f1),
            ("ac", f2)
        ]
        let supposed = ParsingTree.Root([
            .Node("a", [
                .Leaf("b", f1),
                .Leaf("c", f2)
                ])
            ])
        let out = constructPT(from: input)
        XCTAssert(out == supposed)
    }
    
    func testDoubleBranch() {
        let input = [
            ("ab", f1),
            ("b", f1),
            ("ac", f2)
        ]
        let supposed = ParsingTree.Root([
            .Node("a", [
                .Leaf("b", f1),
                .Leaf("c", f2)
                ]),
            .Leaf("b", f1)
            ])
        let out = constructPT(from: input)
        XCTAssert(out == supposed)
    }
    
    func testFull() {
        let input = [
            ("tst", f1),
            ("bro", f1),
            ("txt", f2),
            ("bra", f1),
            ("h", f2)
        ]
        let supposed = ParsingTree.Root([
            .Node("b", [.Node("r", [
                .Leaf("a", f1),
                .Leaf("o", f1)
                ])]),
            .Leaf("h", f2),
            .Node("t", [
                .Node("s", [.Leaf("t", f1)]),
                .Node("x", [.Leaf("t", f2)])
                ])
            ])
        let out = constructPT(from: input)
        XCTAssert(out == supposed)
    }
    
    func testFault() {
        let input = [
            ("b", f1),
            ("ba", f2)
        ]
        expectFatalError(expectedMessage: "Error creating parsing tree: a supposedly unique prefix is not unique") {
            let _ = constructPT(from: input)
        }
    }
}

class ParserTest: XCTestCase {
    #if os(Linux)
    static var allTests = {
    [
    ("testEmpty", testEmpty),
    ("testEmptyWhitespace", testEmptyWhitespace),
    ("testOneCommand", testOneCommand),
    ("testTwoCommands", testTwoCommands),
    ("testRofl", testRofl),
    ("testSimpleProgram", testSimpleProgram),
    ("testInvalidPrefix", testInvalidPrefix),
    ("testIllegalArgument", testIllegalArgument),
    ("testUnexpectedEOC", testUnexpectedEOC),
    ("testUnexpectedEOB", testUnexpectedEOB),
    ("testTooManyOpenStatements", testTooManyOpenStatements)
    ]
    }()
    #endif
    
    func testEmpty() {
        let test = ""
        let supposed: AST? = nil
        let p = Parser(test)
        let out = try! p.parse()
        XCTAssert(out == supposed)
    }

    func testEmptyWhitespace() {
        let test = " \n\t "
        let supposed: AST? = nil
        let p = Parser(test)
        let out = try! p.parse()
        XCTAssert(out == supposed)
    }
    
    func testOneCommand() {
        let test = "dope"
        let supposed: AST? = AST.Dope
        let p = Parser(test)
        let out = try! p.parse()
        XCTAssert(out == supposed)
    }
    
    func testTwoCommands() {
        let test = "trolololol fuuuu"
        let supposed: AST? = AST.Seq(AST.Trol(3), AST.Fuu(3))
        let p = Parser(test)
        let out = try! p.parse()
        XCTAssert(out == supposed)
    }
    
    func testRofl() {
        var test = "rofl yolo copter"
        var supposed: AST? = AST.Rofl(AST.EmptySeq(AST.EmptySeq(nil, AST.Yolo), nil))
        var p = Parser(test)
        var out = try! p.parse()
        XCTAssert(out == supposed)
        test = "roflyolocopter"
        supposed = AST.Rofl(AST.Yolo)
        p = Parser(test)
        out = try! p.parse()
        print(out!)
        XCTAssert(out == supposed)
    }
    
    func testSimpleProgram() {
        let test = "trololol swag  burr moolah rofllolololcopter yolo bra12 fuuuuu dope"
        let supposed: AST? = AST.Seq(
            .Seq(
                .Seq(
                    .Seq(
                        .Seq(
                            .Seq(
                                .Seq(
                                    .Seq(.Trol(2),
                                         .Swag),
                                     .Burr),
                                .Moolah),
                             .Rofl(AST.Lol(2))),
                         .Yolo),
                    .Bra(12)),
                .Fuu(4)),
            .Dope)
        let p = Parser(test)
        let out = try! p.parse()
        XCTAssert(out == supposed)
    }
    
    func testInvalidPrefix() {
        let test = "bla"
        let p = Parser(test)
        do {
            let _ = try p.parse()
            XCTFail()
        } catch {
            let se = error as! SyntaxError
            switch se {
            case .InvalidPrefix(_, _):
                print(se.localizedDescription)
                return
            default:
                XCTFail()
            }
        }
    }
    
    func testIllegalArgument() {
        let test = "bral"
        let p = Parser(test)
        do {
            let _ = try p.parse()
            XCTFail()
        } catch {
            let se = error as! SyntaxError
            switch se {
            case .IllegalArgument(_, _, _):
                print(se.localizedDescription)
                return
            default:
                XCTFail()
            }
        }
    }
    
    func testUnexpectedEOC() {
        var test = "rofl"
        var p = Parser(test)
        do {
            let _ = try p.parse()
            XCTFail()
        } catch {
            let se = error as! SyntaxError
            if case SyntaxError.UnexpectedEndOfCode = se {
                print(se.localizedDescription)
            } else {
                XCTFail()
            }
        }
        test = "bra"
        p = Parser(test)
        do {
            let _ = try p.parse()
            XCTFail()
        } catch {
            let se = error as! SyntaxError
            if case SyntaxError.UnexpectedEndOfCode = se {
                print(se.localizedDescription)
            } else {
                XCTFail()
            }
        }
        test = "tr"
        p = Parser(test)
        do {
            let _ = try p.parse()
            XCTFail()
        } catch {
            let se = error as! SyntaxError
            if case SyntaxError.UnexpectedEndOfCode = se {
                print(se.localizedDescription)
            } else {
                XCTFail()
            }
        }
    }
    
    func testUnexpectedEOB() {
        let test = "copter"
        let p = Parser(test)
        do {
            let _ = try p.parse()
            XCTFail()
        } catch {
            let se = error as! SyntaxError
            switch se {
            case .UnexpectedEndOfBlock(_, _):
                print(se.localizedDescription)
                return
            default:
                XCTFail()
            }
        }
    }
    
    func testTooManyOpenStatements() {
        let test = "trolmoolah"
        let p = Parser(test)
        do {
            let _ = try p.parse()
            XCTFail()
        } catch {
            let se = error as! SyntaxError
            switch se {
            case .TooManyOpenStatementsAtEndOfBlock(_, _):
                print(se.localizedDescription)
                return
            default:
                XCTFail()
            }
        }
    }
}
