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
 
 *trol* = trol{ol}
 
 *lol* = lol{ol}  
 
 *rofl* = rofl *prog* copter
 
 *bra* = bra{*digit*}
 
 *swag* = swag  
 
 *burr* = burr  
 
 *moolah* = moolah  
 
 *yolo* = yolo  
 
 *dope* = dope  
 
 *fuu* = fu{u}
 
 *digit* = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
 
 *whitespace* = ' ' | \t | \n
 */
public class Parser {
    
    /// The code level in which the code to parse is.
    private var level: Int = -1
    
    /// A flag that indicates to the base parsing function, whether the end of a block was reached.
    private var endOfBlock: Bool = false
    
    /// A buffer for the parsed code that might be used as prefix arguments of further commands
    private var parsedStack: [[AST]] = []
    
    private var parsed: [AST] {
        get {
            return parsedStack[level]
        }
        set(newParsed) {
            parsedStack[level] = newParsed
        }
    }
    
    /// the prefix to parsing function map of the parsing tree of this parser
    private lazy var prefixParsFuncMap: [(String, (String) throws -> AST?)] = [
        (" ", self.parseSeq),
        ("\t", self.parseSeq),
        ("\n", self.parseSeq),
        ("\r", self.parseSeq),
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
    /// The parsing tree of this parser
    private lazy var parsingTree: ParsingTree = constructPT(from: self.prefixParsFuncMap)
    
    public init(_ code: String) {
        stream = CodeStream(code)
    }
    
    private var stream: CodeStream
    
    /**
     Checks whether there are enough arguments for the given command to execute
     - parameter required: The minimally required prefix argument count
     - parameter cmd: A description of the command
     */
    private func checkPrefArgCount(required: Int, cmd: String) throws {
        let actual = parsed.count
        if actual < required {
            throw SyntaxError.IllegalPrefixArgumentCount(actual: actual, required: required, cmd: cmd, stream.loc)
        }
    }
    
    /**
     Requires that the next characters of the code stream match the given string and skips past them
     - argument next: The next assumed characters
     - returns: `true` if the next characters match `next`, `false` otherwise
    */
    private func requireNext(_ next: String) -> Bool {
        for c in next.characters {
            if c != stream.next() {
                return false
            }
        }
        return true
    }
    
    /**
     Requires that the next characters of the code stream match the given argument and skips past them
     - argument arg: The next assumed argument
     - throws: `SyntaxError.IllegalArgument` if the next characters don't match the given argument
    */
    private func requireNextArgument(_ arg: String, cmd: String) throws {
        stream.record()
        if !requireNext(arg) {
            throw SyntaxError.IllegalArgument(arg: stream.stopRecording(), cmd: cmd, stream.loc)
        }
        stream.stopRecording()
    }
    
    /**
     Checks whether the next characters match the given string and skips them if so.
     - argument next: The next assumed characters
     - returns: `true` if the next characters match `next`, `false` otherwise
    */
    private func checkNext(_ next: String) -> Bool {
        if stream.peek(next.characters.count) != next {
            return false
        }
        for _ in next.characters {
            stream.next()
        }
        return true
    }
    
    // the parsing functions
    
    public static let whitespace = " \n\t\r".characters
    
    private func parseSeq(_ pref: String) throws -> AST? {
        try checkPrefArgCount(required: 0, cmd: "Seq")
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
        while checkNext("ol"){
            count += 1
        }
        return AST.Trol(count)
    }
    
    private func parseLol(_ pref: String) throws -> AST? {
        let cmdDesc = "lol"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        var count = 0
        while checkNext("ol"){
            count += 1
        }
        return AST.Lol(count)
    }
    
    private func parseRofl(_ pref: String) throws -> AST? {
        let cmdDesc = "roflcopter"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        if pref == "rofl" {
            let res = try parse()
            return AST.Rofl(res)
        } else {
            assert(pref == "copter")
            return nil
        }
    }
    
    private func parseBra(_ pref: String) throws -> AST? {
        let cmdDesc = "bra"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        var argS = ""
        while stream.peek() != nil && stream.peek()!.isNumber() {
            argS.append(stream.next()!)
        }
        if argS == "" {
            let n = stream.next()
            if n == nil {
                throw SyntaxError.UnexpectedEndOfCode
            }
            throw SyntaxError.IllegalArgument(arg: String(n!), cmd: cmdDesc, stream.loc)
        }
        let arg = Int(argS)!
        return AST.Bra(arg)
    }
    
    private func parseFuu(_ pref: String) throws -> AST? {
        let cmdDesc = "fuu"
        try checkPrefArgCount(required: 0, cmd: cmdDesc)
        var count = 0
        while checkNext("u") {
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
    
    /**
     Parses the next block of code in this parsers code stream.
     - returns: The parsed abstract syntax tree
     - throws: different syntax errors when a faulty code segment is reached
    */
    public func parse() throws -> AST? {
        // initialize new block
        level += 1
        if parsedStack.count == level {
            parsedStack.append([])
        }
        
        // parse
        var eoc = false
        while !endOfBlock {
            if stream.peek() == nil { // always expect end of code before parsing the next statement
                eoc = true
                break
            }
            let next = try parseNextStmt()
            if next != nil {
                parsed.append(next!)
            }
        }
        
        // filter for errors
        if eoc && level > 0 {
            throw SyntaxError.UnexpectedEndOfCode
        }
        if parsed.count > 1 {
            throw SyntaxError.TooManyOpenStatementsAtEndOfBlock(count: parsed.count, stream.loc)
        }
        if level == 0 && !eoc {
            throw SyntaxError.UnexpectedEndOfBlock(stream.loc)
        }
        
        // close current block
        endOfBlock = false
        let res = parsed.popLast()
        level -= 1 // must be at last, because parsed is calculated with level
        return res
    }
}

/**
 A struct to traverse a code snippet.
 It conforms to `IteratorProtocol` and `Sequence` and can therefore be used in a `for in` loop.
 */
public struct CodeStream: Sequence, IteratorProtocol {
    private var iterator: IndexingIterator<String.CharacterView>
    /// Indicates the location of the current character
    public private(set) var loc: Location = LocationBeforeCode
    /// `true` if the next character is on a new line, `false` if it is not
    private var nextNL = false
    /// the next character if it was previously peeked, or `nil` when it wasn't peeked
    private var peeked = Queue<Character>()
    init(_ str: String) {
        iterator = str.characters.makeIterator()
    }
    
    @discardableResult
    public mutating func next() -> Character? {
        let next = peeked.dequeue() ?? iterator.next()
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
        } else {
            loc = LocationAfterCode
        }
        return next
    }
    
    /**
     Returns the next character in the stream, but does not count it as read,
     meaning it will still be the next character after calling this function.
     - returns: the next character
    */
    mutating func peek() -> Character? {
        return peek(1).characters.first
    }
    
    /**
     Returns the next few characters in the stream, but does not count them as read, 
     meaning they will still be the next characters after calling this function.
     - parameter amount: the amount of characters to peek
     - returns: the next `amount` characters
    */
    mutating func peek(_ amount: Int) -> String {
        var ret = ""
        var qIterator = peeked.makeIterator()
        for _ in 0..<amount {
            let nextQ = qIterator.next()
            let nextC = nextQ ?? iterator.next()
            if nextC != nil {
                if nextQ == nil {
                    peeked.enqueue(nextC!)
                }
                ret.append(nextC!)
            }
        }
        return ret
    }
    
    /// indicates whether this stream is recording or not
    public private(set) var recording = false
    private var recorded = ""
    
    /** 
     records the following characters, i.e. it saves all the characters which are output by future calls of next 
     (but no nil values).
     Multiple subsequent calls of this function have no effect without calling `stopRecording()`
    */
    public mutating func record() {
        recording = true
    }
    
    /** stops the recording and returns and deletes the recorded string
     - returns: the recorded string
    */
    @discardableResult
    public mutating func stopRecording() -> String {
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
enum ParsingTree: Hashable {
    /// The root node of a tree. No root should have a parent in a tree.
    indirect case Root(Set<ParsingTree>)
    /// An ordinary node, which holds a character and a list of next nodes.
    indirect case Node(Character, Set<ParsingTree>)
    /// A leaf which holds the last character of a defining prefix and the parsing function for this prefix.
    case Leaf(Character, (String) throws -> AST?)
    
    /**
     Uses the given stream's prefix as a defining prefix and outputs the parsing function for this prefix.
     - parameter iterator: A character stream that starts with a defining prefix
     - returns: The parsing function with which the keyword / command of this prefix is parsed
     - throws: `SyntaxError.InvalidPrefix` with the invalid prefix if the given stream was started to record just before calling this method, if there is an invalid prefix.
    */
    func map(from stream: inout CodeStream) throws -> (String) throws -> AST? {
        
        func findNext(from: Set<ParsingTree>) throws -> ParsingTree {
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
                case .Root(_):
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
    
    var hashValue: Int {
        switch self {
        case let .Leaf(c, _):
            return c.hashValue
        case let .Root(s):
            return s.hashValue
        case let .Node(c, s):
            return c.hashValue &+ s.hashValue
        }
    }
}

/**
 Compares the two given `ParsingTree`s for equality.
 Note however, that this function only compares the structure of the tree and the different characters, not the functions at the leafs, as this is an unsupported feature of swift.
 - parameter lhs: The left hand argument
 - parameter rhs: The right hand argument
 */
func ==(lhs: ParsingTree, rhs: ParsingTree) -> Bool {
    switch (lhs, rhs) {
    case (let .Leaf(c1, _), let .Leaf(c2, _)):
        return c1 == c2
    case (let .Node(c1, a1), let .Node(c2, a2)):
        return c1 == c2 && a1 == a2
    case (let .Root(a1), let .Root(a2)):
        return a1 == a2
    default:
        return false
    }
}

/// Constructs the parsing tree from a set of maps from identifying prefixes to parsing functions
func constructPT(from map: [(String, (String) throws -> AST?)]) -> ParsingTree {
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
            opPTStack.append(.Node(cur.char, Set(nodeNext)))
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
        }
        if !op.isEmpty {
            cleanUp(til: i)
        }
        if i > 0 {
            op[i-1] = (pref[i-1], op[i-1].next+1)
        }
        while i < pref.count - 1 {
            op.append((char: pref[i], next: 1))
            i += 1
        }
        op.append((char: pref[i], next: 0))
        
        prevFunc = cur.1
    }
    if !op.isEmpty {
        cleanUp(til: 0)
    }
    
    return .Root(Set(opPTStack))
}

/**
 A location in the code where `l` indicates the line number and `c` the character index in this line.
 The location (0, -1) indicates a location before the code, and (0, -2) a location after the code.
 */
public typealias Location = (l: Int, c: Int)

public let LocationBeforeCode: Location = (0, -1)
public let LocationAfterCode: Location = (0, -2)

/// indicates whether the given location is before the code (i.e. it is (0, -1))
func isBeforeCode(loc: Location) -> Bool {
    return loc == LocationBeforeCode
}
/// indicates whether the given location is after the code (i.e. it is (0, -2))
func isAfterCode(loc: Location) -> Bool {
    return loc == LocationAfterCode
}

/**
 An error that is thrown when the parser detects a syntax error.
 Every SyntaxError holds a String that indicates the faulty code snippet and a location of the error in the code.
 */
public enum SyntaxError: Error {
    case IllegalArgument(arg: String, cmd: String, Location)
    case InvalidPrefix(prefix: String, Location)
    case UnexpectedEndOfCode
    case IllegalPrefixArgumentCount(actual: Int, required: Int, cmd: String, Location)
    case IllegalPostfixArgumentCount(actual: Int, required: [Int], cmd: String, Location)
    case UnexpectedEndOfBlock(Location)
    case TooManyOpenStatementsAtEndOfBlock(count: Int, Location)
    
    /// The description of this syntax error
    public var localizedDescription: String {
        switch self {
        case let .IllegalArgument(arg: a, cmd: c, l):
            return "Illegal argument for command \(c): \(a) at \(l)"
        case let .InvalidPrefix(prefix: p, l):
            return "Invalid prefix found: \(p) at \(l)"
        case .UnexpectedEndOfCode:
            return "Reached an unexpected end of the code"
        case let .IllegalPrefixArgumentCount(actual: a, required: r, cmd: c, l):
            return "Illegal number of prefix arguments for command: \(c)" +
                "is \(a) but should minimally be \(r) at \(l)"
        case let .IllegalPostfixArgumentCount(actual: a, required: r, cmd: c, l):
            return "Illegal number of postfix arguments for command: \(c)" +
                "is \(a) but should be \(r) at \(l)"
        case let .UnexpectedEndOfBlock(l):
            return "Reached an unexpected end of a block at \(l)"
        case let .TooManyOpenStatementsAtEndOfBlock(count: c, l):
            return "More than one open statements found at the end of a block, namely \(c) at \(l)"
        }
    }
}
