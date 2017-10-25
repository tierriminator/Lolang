//
//  CodeGen.swift
//  LLC
//
//  Created by Tierry Hörmann on 22.09.17.
//
//

/*
 This file is responsible for the generation of LLVM IR from an AST.
 The implementation is based on a custom memory management system with multi-level page tables.
 A Lolang programm has its own virtual memory space where the registers are just memory locations in this virtual memory space.
 */

import LLVM

// some conveinience llvm int types
let i1 = IntType.int1
let i8 = IntType.int8
let i16 = IntType.int16
let i32 = IntType.int32
let i64 = IntType.int64
let iReg = IntType(width: regBitCount)
let iVirt = IntType(width: virtAddrBitCount)
let i8p = PointerType(pointee: i8)

public func compile(_ ast: AST) -> Module {
    // initiate main function and entry point
    let module = Module(name: "main")
    let builder = IRBuilder(module: module)
    // add external library functions
    let printf = builder.addFunction("printf", type: FunctionType(argTypes: [i8p], returnType: i32))
    let calloc = builder.addFunction("calloc", type: FunctionType(argTypes: [i64, i64], returnType: i8p))
    let getchar = builder.addFunction("getchar", type: FunctionType(argTypes: [], returnType: i32))
    // build main function
    let main = builder.addFunction("main", type: FunctionType(argTypes: [], returnType: VoidType()))
    let entry = main.appendBasicBlock(named: "entry")
    builder.positionAtEnd(of: entry)
    
    // write initial code
    let rootPt = builder.buildCall(calloc, args: [i64.constant(pageSize), i64.constant(1)])
    let addRes = buildAddressResolutionFunction(builder, rootPT: rootPt, calloc: calloc)
    let curRegPtr = builder.buildAlloca(type: iVirt)
    builder.buildStore(iVirt.zero(), to: curRegPtr)
    /// A pointer to a i8 array that holds the values of "%c"
    let charReplacementStrArrayPtr = builder.buildGlobalStringPtr("%c")
    let charReplacementStrPtr = builder.buildGEP(charReplacementStrArrayPtr, indices: [i8.zero(), i8.zero()])
    
    // small helper functions
    func getCurVal(from: IRValue = builder.buildLoad(curRegPtr)) -> IRValue{
        let curPtr = builder.buildCall(addRes, args: [from])
        return builder.buildLoad(curPtr)
    }
    func saveVal(_ val: IRValue, to: IRValue = builder.buildLoad(curRegPtr)) {
        let curPtr = builder.buildCall(addRes, args: [to])
        builder.buildStore(val, to: curPtr)
    }
    
    var roflCounter = 0
    // translate AST
    func compileAST(_ ast: AST) {
        switch ast {
        case let .Seq(l, r):
            compileAST(l)
            compileAST(r)
        case let .EmptySeq(l, r):
            if l != nil {
                compileAST(l!)
            }
            if r != nil {
                compileAST(r!)
            }
        case let .Trol(i):
            let curReg = builder.buildLoad(curRegPtr)
            let curPtr = builder.buildCall(addRes, args: [curReg])
            let curVal = builder.buildLoad(curPtr)
            let newVal = builder.buildAdd(curVal, iReg.constant(i))
            builder.buildStore(newVal, to: curPtr)
        case let .Lol(i):
            let curReg = builder.buildLoad(curRegPtr)
            let curPtr = builder.buildCall(addRes, args: [curReg])
            let curVal = builder.buildLoad(curPtr)
            let newVal = builder.buildAdd(curVal, iReg.constant(-i))
            builder.buildStore(newVal, to: curPtr)
        case let .Rofl(t):
            let loopCond = main.appendBasicBlock(named: "RoflCond "+String(roflCounter))
            let loopBody = main.appendBasicBlock(named: "RoflBody "+String(roflCounter))
            let loopEnd = main.appendBasicBlock(named: "Copter "+String(roflCounter))
            builder.positionAtEnd(of: loopCond)
            let curVal = getCurVal()
            let cond = builder.buildICmp(curVal, iReg.zero(), IntPredicate.equal)
            builder.buildCondBr(condition: cond, then: loopEnd, else: loopBody)
            builder.positionAtEnd(of: loopBody)
            if t != nil {
                compileAST(t!)
            }
            builder.buildBr(loopCond)
            builder.positionAtEnd(of: loopEnd)
        case .Swag:
            let curVal = getCurVal()
            let _ = builder.buildCall(printf, args: [charReplacementStrPtr, curVal])
        case .Burr:
            let input = builder.buildCall(getchar, args: [])
            let converted = builder.buildZExt(input, type: iReg)
            saveVal(converted)
        case .Moolah:
            let curReg = builder.buildLoad(curRegPtr)
            let newReg = builder.buildAdd(curReg, iReg.constant(1))
            builder.buildStore(newReg, to: curRegPtr)
        case .Yolo:
            let curReg = builder.buildLoad(curRegPtr)
            let newReg = builder.buildAdd(curReg, iReg.constant(-1))
            builder.buildStore(newReg, to: curRegPtr)
        case .Dope:
            let newReg = getCurVal()
            builder.buildStore(newReg, to: curRegPtr)
        case let .Bra(i):
            builder.buildStore(iReg.constant(i), to: curRegPtr)
        case let .Fuu(i):
            let curVal = getCurVal()
            saveVal(curVal, to: iReg.constant(i))
        }
    }
    compileAST(ast)
    
    return module
}
