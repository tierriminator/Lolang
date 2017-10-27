import Lib
import LLVM
import Foundation

/// prints the usage information to stderr and exits with exit code -1
func printUsage() -> Never{
    let usage = """
        Usage: lolc <source> [options]\n
        OPTIONS:\n
        -o <path>\tspecify destination file\n
        -l\toutput LLVM IR\n
        -a\toutput assembly file\n
        -b\toutput object file\n
        -O<char>\tOptimization level. [-O0, -O1, -O2, -O3] (default: -O2)
    """
    fail(usage)
}

/// prints message to stderr and exits with exit code -1
/// -parameter message: the message that should be printed to stderr
func fail(_ message: String) -> Never {
    print(message, to: &errStream)
    exit(-1)
}

/// prints message to stdout and exits with exit code 0
/// -parameter message: the message that should be printed to stdout
func exitGracefully(_ message: String? = nil) -> Never {
    if let msg = message {
        print(msg)
    }
    exit(0)
}


let arguments = CommandLine.arguments
if arguments.count == 0 {
    printUsage()
}

// parameters that can be changed through commandline arguments
var outFile = ""
var emitIR = false
var optimization = "-O2"
var assembly = false
var object = false

// process commandline arguments
var i = 1
while i < arguments.count {
    if arguments[i] == "-o" {
        i += 1
        outFile = arguments[i]
    } else if arguments[i] == "-l" {
        emitIR = true
    } else if arguments[i].hasPrefix("-O") && arguments[i].count == 3 {
        if let lvl = Int(arguments[i].suffix(1)) {
            if lvl >= 0 && lvl <= 3 {
                optimization = arguments[i]
            } else {
                printUsage()
            }
        } else {
            printUsage()
        }
    } else if arguments[i] == "-a" {
        assembly = true
    } else if arguments[i] == "-b" {
        object = true
    } else {
        printUsage()
    }
    i+=1
}

// load source file
let sourcePath = arguments.first!
let sourceURL = URL(fileURLWithPath: sourcePath)
let code: String;
do {
    /// the lolang code that should be compiled
    code = try String(contentsOf: sourceURL)
} catch {
    fail("Could not load source file \(sourcePath): \(error)")
}

// parse
let p = Parser(code)
let ast: AST
do {
    if let _ast = try p.parse() {
        ast = _ast
    } else {
        exitGracefully()
    }
} catch {
    let syntaxError = error as! SyntaxError
    fail(syntaxError.localizedDescription)
}

/// the source url without a path extension
let noExtension = sourceURL.deletingPathExtension()

// generate IR
let module = compile(ast)

// store IR
/// the output file for the IR
var irOut = "\(noExtension).ll"
if emitIR && outFile != "" {
    irOut = outFile
}
do {
    try module.print(to: irOut)
} catch {
    fail("Could not write to \(irOut): \(error)")
}
if emitIR { // stop here if IR should be emitted
    exitGracefully()
}

// generate assembly or object file
var objOut = "\(noExtension).o"
var asmOut = "\(noExtension).s"
if outFile != "" {
    objOut = outFile
    asmOut = outFile
}
let fileType = assembly ? "asm" : "obj"
/// the output path of the compiled file
let compiledOut = assembly ? asmOut : objOut
// execute llc on generated IR
let llcProc = Process()
llcProc.launchPath = "llc"
llcProc.arguments = ["-o", compiledOut, "-filetype", fileType, optimization, irOut]
llcProc.launch()
llcProc.waitUntilExit()
if llcProc.terminationStatus != 0 {
    fail("Could not compile IR, llc exited with code \(llcProc.terminationStatus)")
}
// remove IR file
do {
    try FileManager.default.removeItem(at: URL(fileURLWithPath: irOut))
} catch {
    fail("Could not remove IR file \(irOut): \(error)")
}
if object || assembly { // stop here if object or assembly file should be emitted
    exitGracefully()
}

// link and generate executable
if outFile == "" {
    outFile = noExtension.absoluteString
}
let ldProc = Process()
ldProc.launchPath = "ld"
ldProc.arguments = ["-o", outFile, "-lcrt1.o", "-lc", objOut]
ldProc.launch()
ldProc.waitUntilExit()
if ldProc.terminationStatus != 0 {
    fail("Could not link, ld exited with code \(ldProc.terminationStatus)")
}
