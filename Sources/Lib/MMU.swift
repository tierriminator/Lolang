//
//  MMU.swift
//  Lib
//
//  Created by Tierry Hörmann on 30.09.17.
//

/*
 This file holds everything that is necessary for the address translation from the virtual address space of a Lolang-program (register numbers) to the virtual address space of the process it runs in.
 Lolang uses multilevel page tables as a memory management strategy. Pages are allocated in the processes heap.
 A page table has exactly the size of a page.
 A page is then allocated when it is needed, i.e. a read or write to it is executed.
 Therefore the memory usage of a Lolang-program depends on the number of registers accessed and on the distribution of them in the virtual memory space (whether a wide spread of register numbers are used or they are all close together).
 The current implementation requires a register number to be 40 bits wide, which means that the largest allowed register number is 2^40 = 1'099'511'627'776
 */

import LLVM

/// the size of a page in memory (in bytes)
let pageSize = 2048
/// the size of a Lolang register (in bits)
let regBitCount = 64
/// the number of bits of the offset of a virtual / physical address and of the offset in a page table in the virtual address
let offsetBits = 8
/// the number of registers in a page (in bytes)
let regCount = 256
/// the number of bits of a physical address
let physAddrBitCount = 64
/// the number of bits of a virtual address
let virtAddrBitCount = 40
/// number of bits for a PTE (page table entry)
let pteBitCount = 64
/// number of page table entries per page table
let pteCount = 256
/// number of page table levels
let levels = 4
/// number of offsets
let offsets = levels + 1

/// Checks whether the above constants are valid.
/// This function defines therefore requirements of those constants.
func checkConstants() {
    assert(offsetBits*(levels + 1) == virtAddrBitCount)
    assert(pageSize / pteBitCount / 8 == pteCount)
    assert(regCount == pageSize / regBitCount / 8)
    assert(regCount == 1<<offsetBits)
    assert(physAddrBitCount == pteBitCount)
    assert(regBitCount == physAddrBitCount)
    assert(regBitCount%8 == 0)
    assert(virtAddrBitCount%8 == 0)
    assert(levels < 256)
}

/*
 A PTE holds only the physical address of the page to access (which might hold registers or a new page table).
 A PTE is 0 if it is not already allocated.
 */

/**
 Creates a function that translates register numbers to memory addresses
 - parameter builder: The IRBuilder that should be used to build the function
 - parameter rootPt: The pointer to the root table
 */
func buildAddressResolutionFunction(_ builder: IRBuilder, rootPT: IRValue, calloc: Function) -> Function {
    /*
     The following code builds a similar IR as in addressResolutionFunction.ll which is generated with clang from addressResolutionFunction.c
     */
    let resolve = builder.addFunction("resolve", type: FunctionType(argTypes: [iVirt], returnType: PointerType(pointee: IntType(width: regBitCount))))
    // blocks of the code
    let entry = resolve.appendBasicBlock(named: "entry")
    let offsetBuilderLoop = resolve.appendBasicBlock(named: "offsetBuilderLoop")
    let resolutionInit = resolve.appendBasicBlock(named: "resolutionInit")
    let resolutionLoop = resolve.appendBasicBlock(named: "resolutionLoop")
    let callocCondition = resolve.appendBasicBlock(named: "callocCondition")
    let resolutionLoopEnd = resolve.appendBasicBlock(named: "resolutionLoopEnd")
    let ret = resolve.appendBasicBlock(named: "ret")
    
    // build initial setup
    builder.positionAtEnd(of: entry)
    /// the pointer to the array that holds the offsets
    let offsetArrayPointer = builder.buildAlloca(type: ArrayType(elementType: IntType(width: offsetBits), count: offsets))
    /// a pointer to a stack slot reserved for a 8-bit (loop) counter
    let smallCounterPointer = builder.buildAlloca(type: i8)
    // initialize counter to zero
    builder.buildStore(i8.zero(), to: smallCounterPointer)
    builder.buildBr(offsetBuilderLoop)
    
    // build loop that generates the offsets
    builder.positionAtEnd(of: offsetBuilderLoop)
    var counter = builder.buildLoad(smallCounterPointer)
    // extract offset from address
    let shamt = builder.buildMul(counter, i8.constant(offsetBits))
    let offsetBig = builder.buildShr(resolve.parameter(at: 0)!, shamt)
    let offset = builder.buildTrunc(offsetBig, type: IntType(width: offsetBits))
    // store offset
    let arraySlotPtr = builder.buildGEP(offsetArrayPointer, indices: [i8.zero(), counter])
    builder.buildStore(offset, to: arraySlotPtr)
    // increase counter
    counter = builder.buildAdd(counter, i1.constant(1))
    builder.buildStore(counter, to: smallCounterPointer)
    // branch
    let branchCond = builder.buildICmp(counter, i8.constant(offsets), IntPredicate.equal)
    builder.buildCondBr(condition: branchCond, then: resolutionInit, else: offsetBuilderLoop)
    
    // build initial setup for address resolution
    builder.positionAtEnd(of: resolutionInit)
    /// the slot in the stack where the pointer is found to the next table / memory entry
    let nextPointerSlot = builder.buildAlloca(type: PointerType(pointee: IntType(width: pteBitCount)))
    // initialize the pointer inside nextPointerSlot to the first entry in the root table
    let initialOffsetPtr = builder.buildGEP(offsetArrayPointer, indices: [i8.zero(), i8.constant(levels)])
    let initialOffset = builder.buildLoad(initialOffsetPtr)
    let initialPointer = builder.buildGEP(rootPT, indices: [initialOffset])
    builder.buildStore(i8.constant(levels-1), to: smallCounterPointer)
    builder.buildStore(initialPointer, to: nextPointerSlot)
    builder.buildBr(resolutionLoop)
    
    // build resolution loop
    builder.positionAtEnd(of: resolutionLoop)
    let curPtr = builder.buildLoad(nextPointerSlot)
    let curLevel = builder.buildLoad(smallCounterPointer)
    // fetch the current entry
    let curEntry = builder.buildLoad(curPtr)
    // check whether the page needs to be allocated
    let needsAlloc = builder.buildICmp(curEntry, IntType(width: pteBitCount).zero(), IntPredicate.equal)
    builder.buildCondBr(condition: needsAlloc, then: callocCondition, else: resolutionLoopEnd)
    
    // build calloc block
    builder.positionAtEnd(of: callocCondition)
    let pagePtr = builder.buildCall(calloc, args: [i64.constant(pageSize), i64.constant(1)])
    let pagePtrInt = builder.buildPtrToInt(pagePtr, type: IntType(width: pteBitCount))
    builder.buildStore(pagePtrInt, to: curPtr)
    builder.buildBr(resolutionLoopEnd)
    
    // build resolution loop end
    builder.positionAtEnd(of: resolutionLoopEnd)
    let doublePtr = builder.buildBitCast(curPtr, type: PointerType(pointee: PointerType(pointee: IntType(width: pteBitCount))))
    // decrease the level
    let nextLvl = builder.buildAdd(curLevel, i8.allOnes())
    // calculate the next pointer
    let nextBasePtr = builder.buildLoad(doublePtr)
    let nextOffsetPtr = builder.buildGEP(offsetArrayPointer, indices: [i1.zero(), nextLvl])
    let nextOffset = builder.buildLoad(nextOffsetPtr)
    let nextPtr = builder.buildGEP(nextBasePtr, indices: [nextOffset])
    // store the new pointer and new level
    builder.buildStore(nextPtr, to: nextPointerSlot)
    builder.buildStore(nextLvl, to: smallCounterPointer)
    // check for end of resolution
    let endOfResolution = builder.buildICmp(nextLvl, i8.zero(), IntPredicate.equal)
    builder.buildCondBr(condition: endOfResolution, then: ret, else: resolutionLoop)
    
    // build return block
    builder.positionAtEnd(of: ret)
    builder.buildRet(nextPtr)
    
    return resolve
}
