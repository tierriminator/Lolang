//
//  Parser.swift
//  LLC
//
//  Created by Tierry Hörmann on 05.09.17.
/*
 The following define some basic syntax rules for Lolang. Language extensions should adapt those rules.
 
 - Every keyword/command has one or multiple defining prefixes, meaning a prefix unique to this keyword/command.
 - After the defining prefix of a command there might be an arbitrary character sequence describing the (postfix) arguments of the command.
 - A keyword cannot have parameters and therefore its defining prefix is the keyword itself.
 - Every keyword or command should be based on an english slang word
 - Commands can have prefix and/or postfix arguments.
 - Prefix arguments must be parseable (i.e. an abstract syntax tree can be formed from the arguments alone).
*/


/**
 A parser, which takes an input stream of code and parses it to an abstract syntax tree.
 It operates using the following EBNF description:
 
 *prog* = [*seq*] [*stmt* {*seq* *stmt*}] [*seq*]
 
 *stmt* = *trol* | *lol* | *rofl* | *swag* | *burr* | *moolah* | *yolo* | *dope* | *bra* | *fuu*
 
 *seq* = *whitespace* {*whitespace*}
 
 *trol* = tr{ol}  
 
 *lol* = l{ol}  
 
 *rofl* = rofl *prog* copter
 
 *bra* = bra{*digit*}
 
 *swag* = swag  
 
 *burr* = burr  
 
 *moolah* = moolah  
 
 *yolo* = yolo  
 
 *dope* = dope  
 
 *fuu* = f{u}
 
 *digit* = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
 
 *whitespace* = ' ' | \t | \n
 */
class Parser {
    
    /// The code level in which the code to parse is.
    private var level: Int = 0
    
    /// A flag that indicates to the base parsing function, whether the end of a block was reached.
    private var endOfBlock: Bool = false
    
    /// A buffer for the parsed code that might be used as prefix arguments of further commands
    private var parsed: [AST] = []
    
    /// The parsing tree of this parser
    private lazy var prefixParsFuncMap: [(String, (String) throws -> AST?)] = [
        (" ", self.parseSeq),
        ("\t", self.parseSeq),
        ("\n", self.parseSeq),
        ("trol", self.parseTrol),
        ("lol", self.parseLol),
        ("rofl", self.parseRofl),
        ("copter", self.parseRofl),
        ("bra", self.parseBra),
        ("fu", self.parseFuu),
        ("swag", self.parseSwag),
        ("burr", self.parseBurr),
        ("moolah", self.parseMoolah),
        ("yolo", self.parseYolo),
        ("dope", self.parseDope)
    ]
    private lazy var parsingTree: ParsingTree = constructPT(from: self.prefixParsFuncMap)
    
    init(_ code: String) {
        stream = CodeStream(code)
    }
    
    private var stream: CodeStream
    
    /**
     Serves as a convenience function for `checkPrefArgCount(required: [Int], cmd: String)`
     in the case of only one allowed argument count.
     - parameter required: The allowed prefix argument count
     - parameter cmd: A description of the command
     */
    private func checkPrefArgCount(required: Int, cmd: String) throws {
        try checkPrefArgCount(required: [required], cmd: cmd)
    }
    
    /**
     Checks whether the correct amount of prefixing arguments are given for a command.
     Every keyword / command should call this function first.
     - parameter required: An array of the allowed amounts of prefix arguments
     - parameter cmd: A `String` describing the command.
     - throws: `SyntaxError.IllegalArgumentCount` if the check failed
     */
    private func checkPrefArgCount(required: [Int], cmd: String) throws {
        let actual = parsed.count
        if !required.contains(actual) {
            throw SyntaxError.IllegalPrefixArgumentCount(actual: actual, required: required, cmd: cmd, stream.loc)
        }
    }
    
    // the parsing functions
    
    static let whitespace = " \n\t\r".characters
    private func parseSeq(_ pref: String) throws -> AST? {
        try checkPrefArgCount(required: [0, 1], cmd: "Seq")
        // pre-optimize by combining multiple consecutive sequence operators into one
        while stream.peek() != nil && Parser.whitespace.contains(stream.peek()!) {
            stream.next()
        }
        let prev = parsed.popLast()
        let next =  try parseNextStmt()
        if prev != nil && next != nil {
            return AST.Seq(prev!, next!)
        } else {
            return AST.EmptySeq(prev, next)
        }
    }
    
    private func parseTrol(_ pref: String) throws -> AST? {
        let cmdDesc = "trol"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        var count = 0
        while stream.peek() == "o"{
            count += 1
            stream.next()
            if stream.peek() != "l" {
                throw SyntaxError.IllegalArgument(arg: "o\(String(describing: stream.next()))", cmd: cmdDesc, stream.loc)
            }
            stream.next()
        }
        return AST.Trol(count)
    }
    
    private func parseLol(_ pref: String) throws -> AST? {
        let cmdDesc = "lol"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        var count = 0
        while stream.peek() == "o"{
            count += 1
            stream.next()
            if stream.peek() != "l" {
                throw SyntaxError.IllegalArgument(arg: "o\(String(describing: stream.next()))", cmd: cmdDesc, stream.loc)
            }
            stream.next()
        }
        return AST.Lol(count)
    }
    
    private func parseRofl(_ pref: String) throws -> AST? {
        let cmdDesc = "roflcopter"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        if pref == "rofl" {
            level += 1
            let res = try parse()
            return AST.Rofl(res)
        } else {
            assert(pref == "copter")
            level -= 1
            return nil
        }
    }
    
    private func parseBra(_ pref: String) throws -> AST? {
        let cmdDesc = "bra"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        var argS = ""
        while let _ = stream.peek()?.isNumber() {
            argS.append(stream.next()!)
        }
        let arg = Int(argS) ?? -1
        if arg < 0 {
            throw SyntaxError.IllegalArgument(arg: argS, cmd: cmdDesc, stream.loc)
        }
        return AST.Bra(arg)
    }
    
    private func parseFuu(_ pref: String) throws -> AST? {
        let cmdDesc = "fuu"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        var count = 0
        while stream.next() == "u" {
            count += 1
        }
        return AST.Fuu(count)
    }
    
    private func parseSwag(_ pref: String) throws -> AST? {
        let cmdDesc = "swag"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        return AST.Swag
    }
    
    private func parseMoolah(_ pref: String) throws -> AST? {
        let cmdDesc = "moolah"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        return AST.Moolah
    }
    
    private func parseYolo(_ pref: String) throws -> AST? {
        let cmdDesc = "yolo"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        return AST.Yolo
    }
    
    private func parseBurr(_ pref: String) throws -> AST? {
        let cmdDesc = "burr"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        return AST.Burr
    }
    
    private func parseDope(_ pref: String) throws -> AST? {
        let cmdDesc = "dope"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        return AST.Dope
    }
    
    /**
     Parses the next statement and returns it.
     If there is no next statement, `endOfBlock` is set to `true`
     - returns: The next parsed statement, or `nil` if there is no next statement.
    */
    private func parseNextStmt() throws -> AST? {
        stream.record()
        let res = try parsingTree.map(from: &self.stream)(stream.stopRecording())
        if res == nil {
            endOfBlock = true
        }
        return res
    }
    
    func parse() throws -> AST? {
        while !endOfBlock {
            let next = try parseNextStmt()
            if next != nil {
                parsed.append(next!)
            }
        }
        if parsed.count > 1 {
            throw SyntaxError.TooManyOpenStatementsAtEndOfBlock(count: parsed.count, stream.loc)
        } else if level < 0 {
            throw SyntaxError.UnexpectedEndOfBlock(stream.loc)
        } else {
            return parsed.popLast()
        }
    }
}

/**
 A struct to traverse a code snippet.
 It conforms to `IteratorProtocol` and `Sequence` and can therefore be used in a `for in` loop.
 */
struct CodeStream: Sequence, IteratorProtocol {
    private var iterator: IndexingIterator<String.CharacterView>
    /// Indicates the location of the current character
    private(set) var loc: Location = (0, -1)
    /// `true` if the next character is on a new line, `false` if it is not
    private var nextNL = false
    /// the next character if it was previously peeked, or `nil` when it wasn't peeked
    private var nextC: Character? = nil
    init(_ str: String) {
        iterator = str.characters.makeIterator()
    }
    
    @discardableResult
    mutating func next() -> Character? {
        let next = nextC ?? iterator.next()
        nextC = nil
        if next != nil {
            if nextNL {
                loc = (loc.l+1, 0)
            } else {
                loc = (loc.l, loc.c+1)
            }
            if next == "\n" {
                nextNL = true
            } else {
                nextNL = false
            }
            if(recording) {
                recorded.append(next!)
            }
        }
        return next
    }
    
    mutating func peek() -> Character? {
        nextC = nextC ?? iterator.next()
        return nextC
    }
    
    /// indicates whether this stream is recording or not
    private(set) var recording = false
    private var recorded = ""
    
    /** 
     records the following characters, i.e. it saves all the characters which are output by future calls of next 
     (but no nil values).
     Multiple subsequent calls of this function have no effect without calling `stopRecording()`
    */
    mutating func record() {
        recording = true
    }
    
    /** stops the recording and returns and deletes the recorded string
     - returns: the recorded string
    */
    mutating func stopRecording() -> String {
        recording = false
        let ret = recorded
        recorded = ""
        return ret
    }
}

/**
 A tree that helps with parsing decisions.
 It defines the defining prefixes of Lolang and can map parsing functions to prefixes.
 
 A parsing function must map a string (the defining prefix) to an abstract syntax tree or nil if the keyword/command describes the end of a block of code.
 Therefore a parsing function might support multiple defining prefixes.
 */
private enum ParsingTree {
    /// The root node of a tree. No root should have a parent in a tree.
    indirect case Root([ParsingTree])
    /// An ordinary node, which holds a character and a list of next nodes.
    indirect case Node(Character, [ParsingTree])
    /// A leaf which holds the last character of a defining prefix and the parsing function for this prefix.
    case Leaf(Character, (String) throws -> AST?)
    
    /**
     Uses the given stream's prefix as a defining prefix and outputs the parsing function for this prefix.
     - parameter iterator: A character stream that starts with a defining prefix
     - returns: The parsing function with which the keyword / command of this prefix is parsed
     - throws: `SyntaxError.InvalidPrefix` with the invalid prefix if the given stream was started to record just before calling this method, if there is an invalid prefix.
    */
    func map(from stream: inout CodeStream) throws -> (String) throws -> AST? {
        
        func findNext(from: [ParsingTree]) throws -> ParsingTree {
            let nextC = stream.next()
            for cur in from {
                switch cur {
                case let .Leaf(c, _):
                    if c == nextC {
                        return cur
                    }
                case let .Node(c, _):
                    if c == nextC {
                        return cur
                    }
                default:
                    fatalError("Root node found inside parsing tree!")
                }
            }
            if nextC == nil {
                throw SyntaxError.UnexpectedEndOfCode
            } else {
                throw SyntaxError.InvalidPrefix(prefix: stream.stopRecording(), stream.loc)
            }
        }
        
        switch self {
        case let .Leaf(_, pf):
            return pf
        case let .Node(_, next):
            return try findNext(from: next).map(from: &stream)
        case let .Root(next):
            return try findNext(from: next).map(from: &stream)
        }
    }
}

/// Constructs the parsing tree from a set of maps from identifying prefixes to parsing functions
private func constructPT(from map: [(String, (String) throws -> AST?)]) -> ParsingTree {
    var copy = map
    copy.sort(by: {$0.0 < $1.0})
    var op: [(char: Character, next: Int)] = []
    var opPTStack: [ParsingTree] = []
    var prevFunc: (String) throws -> AST? = {_ in nil}
    
    /// finish previous (completed) work
    func cleanUp(til i: Int) {
        assert(i < op.count && i >= 0) // precondition for i
        // the current top of op must be the previous leaf
        let last = op.popLast()!
        assert(last.next == 0) // last must be a leaf
        opPTStack.append(.Leaf(last.char, prevFunc))
        while op.count > i {
            let cur = op.popLast()!
            var nodeNext: [ParsingTree] = []
            nodeNext.reserveCapacity(cur.next)
            for _ in 0..<cur.next {
                nodeNext.append(opPTStack.popLast()!)
            }
            opPTStack.append(.Node(cur.char, nodeNext))
        }
    }
    
    for cur in copy {
        let pref = Array(cur.0.characters)
        assert(pref.count > 0) // no empty prefix allowed
        // follow until prefix doesn't match anymore
        var i = 0
        while i < op.count && pref[i] == op[i].char {
            i += 1
        }
        if i != 0 && i == op.count {
            fatalError("Error creating parsing tree: a supposedly unique prefix is not unique")
        } else if i > 0 {
            cleanUp(til: i)
            op[i-1] = (pref[i-1], op[i-1].next+1)
        }
        while i < pref.count - 1 {
            op.append((char: pref[i], next: 1))
            i += 1
        }
        op.append((char: pref[i], next: 0))
        
        prevFunc = cur.1
    }
    
    cleanUp(til: 0)
    
    return .Root(opPTStack)
}

/// A location in the code where `l` indicates the line number and `c` the character index in this line
typealias Location = (l: Int, c: Int)

/**
 An error that is thrown when the parser detects a syntax error.
 Every SyntaxError holds a String that indicates the faulty code snippet and a location of the error in the code.
 */
enum SyntaxError: Error {
    case IllegalArgument(arg: String, cmd: String, Location)
    case InvalidPrefix(prefix: String, Location)
    case UnexpectedEndOfCode
    case IllegalPrefixArgumentCount(actual: Int, required: [Int], cmd: String, Location)
    case IllegalPostfixArgumentCount(actual: Int, required: [Int], cmd: String, Location)
    case UnexpectedEndOfBlock(Location)
    case TooManyOpenStatementsAtEndOfBlock(count: Int, Location)
}
