//
//  AST.swift
//  LLC
//
//  Created by Tierry Hörmann on 05.09.17.
//
//

/// A abstract syntax tree for a (piece) of code
/// This enum defines the syntax of Lolang
enum AST {
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
