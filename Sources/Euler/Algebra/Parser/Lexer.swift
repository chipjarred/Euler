//
//  Token.swift
//  
//
//  Created by Arthur Guiot on 2019-12-18.
//

import Foundation

/// Possible Tokens in a mathematical expression.
///
/// > This is part of the `Lexer`
internal enum Token: Equatable {
    case Symbol(String)
    case Number(String)
    case ParensOpen
    case ParensClose
    case Other(String)
    case Str(String)
    case address(String)
    
    static func ==(lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case (.address(let a), .address(let b)):
            return a == b
        case (.Symbol(let a), .Symbol(let b)):
            return a == b
        case (.Number(let a), .Number(let b)):
            return a == b
        case (.ParensOpen, .ParensOpen):
            return true
        case (.ParensClose, .ParensClose):
            return true
        case (.Other(let a), .Other(let b)):
            return a == b
        case (.Str(let a), .Str(let b)):
            return a == b
        default:
            return false
        }
    }
}

typealias TokenGenerator = (String) -> Token?
/// Helps the `Lexer` to convert text to `Token`
let tokenList: [(String, TokenGenerator)] = [
    ("[ \t\n]", { _ in nil }),
    ("\\$?[A-Z]+\\$?\\d+", { .address($0) }),
    ("[a-zA-Z][a-zA-Z0-9]*", { .Symbol($0) }),
    ("[0-9]\\d*(\\.\\d+)?", { (r: String) in .Number(r) }),
    ("\\(", { _ in .ParensOpen }),
    ("\\)", { _ in .ParensClose }),
    ("(['\"])(?:(?!(?:\\\\|\\1)).|\\\\.)*\\1", { (r: String) in .Str(r) })
]

/// The `Lexer` is converting a sequence of characters (mathematical expression) into a sequence of `Token`
public class Lexer {
    let input: String
    /// Initializes the `Lexer`
    /// - Parameter input: The mathematical expression you want to parse
    public init(input: String) {
        self.input = Lexer.sanitizer(input)
    }
    
    internal static func sanitizer(_ input: String) -> String {
        var i = input
        let ps = i.matches(regex: "\\(\\)")
        for (lower, _) in ps {
            i.insert("0", at: String.Index(encodedOffset: lower + 1))
        }
        return i
    }
    
    /// Tokenize the String input
    internal func tokenize() -> [Token] {
        var tokens = [Token]()
        var content = input
        
        while (content.count > 0) {
            var matched = false
            
            for (pattern, generator) in tokenList {
                if let m = content.match(regex: pattern) {
                    if let t = generator(m) {
                        tokens.append(t)
                    }
                    let firstIndex = String.Index(encodedOffset: m.count - 1)
                    let index = content.index(after: firstIndex)
                    content = String(content[index...])
                    matched = true
                    break
                }
            }

            if !matched {
                let firstIndex = content.startIndex
                let index = content.index(after: firstIndex)
                tokens.append(.Other(String(content[..<index])))
                content = String(content[index...])
            }
        }
        
        if tokens.count > 0 {
            if case let Token.Other(first) = tokens[0] {
                if first == "-" {
                    var tks = [Token.Number("0")]
                    tks.append(contentsOf: tokens)
                    
                    tokens = tks
                }
            }
        }
        
        return tokens
    }
}
