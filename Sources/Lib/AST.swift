//
//  AST.swift
//  LLC
//
//  Created by Tierry Hörmann on 05.09.17.
//
//

/// A abstract syntax tree for a (piece) of code
/// This enum defines the syntax of Lolang
public enum AST: Equatable {
    /// A normal sequence operator for combining statements
    indirect case Seq(AST, AST)
    /// A sequence operator, that has no lhs or no rhs or both. It can and should be optimized away.
    indirect case EmptySeq(AST?, AST?)
    case Trol(Int)
    case Lol(Int)
    indirect case Rofl(AST?) // A loop can also be empty
    case Swag
    case Burr
    case Moolah
    case Yolo
    case Dope
    case Bra(Int)
    case Fuu(Int)
}

public func ==(lhs: AST, rhs: AST) -> Bool {
    switch (lhs, rhs) {
    case (let .Seq(l1, r1), let .Seq(l2, r2)):
        return l1 == l2 && r1 == r2
    case (let .EmptySeq(l1, r1), let .EmptySeq(l2, r2)):
        return l1 == l2 && r1 == r2
    case (let .Trol(i1), let .Trol(i2)):
        return i1 == i2
    case (let .Lol(i1), let .Lol(i2)):
        return i1 == i2
    case (let .Rofl(a1), let .Rofl(a2)):
        return a1 == a2
    case (let .Bra(i1), let .Bra(i2)):
        return i1 == i2
    case (let .Fuu(i1), let .Fuu(i2)):
        return i1 == i2
    case (.Swag, .Swag):
        return true
    case (.Burr, .Burr):
        return true
    case (.Moolah, .Moolah):
        return true
    case (.Yolo, .Yolo):
        return true
    case (.Dope, .Dope):
        return true
    default:
        return false
    }
}
