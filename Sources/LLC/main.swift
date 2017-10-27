import Lib
import LLVM
import Foundation
import PathKit

/// prints the usage information to stderr and exits with exit code -1
func printUsage() -> Never{
    let usage = """
        Usage: lolc <source> [options]\n
        OPTIONS:
        -o <path>\tspecify destination file
        -l\t\toutput LLVM IR
        -a\t\toutput assembly file
        -b\t\toutput object file
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


let arguments = CommandLine.arguments.dropFirst()
if arguments.count == 1 {
    printUsage()
}

// parameters that can be changed through commandline arguments
var outFile = ""
var emitIR = false
var optimization = "-O2"
var assembly = false
var object = false

// process commandline arguments
// check source file
let sourceStr = arguments.first!
let sourcePath = Path(sourceStr)
if !sourcePath.isFile {
    fail("The given source path is no file: \(sourceStr)")
}
if !sourcePath.exists {
    fail("The given source path does not exist: \(sourceStr)")
}
if !sourcePath.isReadable {
    fail("The file at the given source cannot be read: \(sourceStr)")
}
let sourceName = sourcePath.lastComponentWithoutExtension
// process remaining arguments
var i = 2
while i < arguments.count {
    if arguments[i] == "-o" {
        i += 1
        var outPath = Path(arguments[i])
        if outPath.isDirectory {
            if !outPath.exists {
                fail("The given output directory does not exist: \(arguments[i])")
            }
            if !outPath.isWritable {
                fail("No write is allowed to the given output directory: \(arguments[i])")
            }
            outPath = outPath + Path(sourceName)
        }
        outFile = outPath.absolute().string
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
let sourceURL = URL(fileURLWithPath: sourcePath.absolute().string)
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
// remove obj file
do {
    try FileManager.default.removeItem(at: URL(fileURLWithPath: objOut))
} catch {
    fail("Could not remove object file \(objOut): \(error)")
}
