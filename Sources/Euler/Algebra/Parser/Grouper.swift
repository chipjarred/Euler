//
//  Grouper.swift
//  
//
//  Created by Arthur Guiot on 2019-12-19.
//

import Foundation

fileprivate enum GroupError: Error {
    case UnexpectedToken
    case UndefinedOperator(String)
    
    case ExpectedCharacter(Character)
    case ExpectedExpression
    case ExpectedArgumentList
    case ExpectedFunctionName
    case UnexpectedError
    case ExpectedSymbol
}

/// A `Group` is a intermediate representation object for representing a mathematical expression.
/// This is the object that allows the tokens to be grouped together to convert them into nodes.
/// In particular, it is in charge of recognizing parentheses and preanalysing them before passing the expression to `Parser`.
public class Group: NSObject {
    enum `Type` {
        case Symbol
        case Function
        case Operator
        case Number
        case UnParsed
        case Equal
        case Parenthesis
    }
    var tokens: [Token]
    var type: Type
    var context: Parser.ParseContext
    init(tokens: [Token], type: Type, context: Parser.ParseContext) {
        self.tokens = tokens
        self.type = type
        self.context = context
    }
    
    func compile() throws {
        if self.type == .UnParsed {
            var ops = [
                "+",
                "-",
                "*",
                "/",
                "^"
            ]
            if self.context == .tables {
                ops.append(":")
            }
            guard tokens.count == 1 else {
                self.type = .Parenthesis
                return
            }
            guard case let Token.Other(token) = tokens[0] else { throw GroupError.ExpectedSymbol }
            
            if ops.contains(token) {
                self.type = .Operator
            } else if token == "=" {
                self.type = .Equal
            }
        }
    }
    func toNode(lhs: Node?, rhs: Node?) throws -> Node {
        try self.compile()
        switch self.type {
        case .Symbol:
            return try self.toSymbol()
        case .Function:
            throw GroupError.ExpectedExpression
        case .Operator:
            guard lhs != nil && rhs != nil else { throw GroupError.ExpectedArgumentList }
            return try self.toOperator(lhs: lhs!, rhs: rhs!)
        case .Number:
            return try self.toNumber()
        case .Parenthesis:
            // Parsing
            let p = Parser(tokens: tokens, type: self.context)
            let expr = try p.parse()
            return ParenthesisNode(expr.children)
        case .UnParsed:
            throw GroupError.ExpectedExpression
        case .Equal:
            guard lhs != nil && rhs != nil else { throw GroupError.ExpectedArgumentList }
//            return ExpressionNode(lhs!, rhs!)
            return OperatorNode("=", children: [lhs!, rhs!])
        }
    }
    
    func toSymbol() throws -> SymbolNode {
        guard tokens.count == 1 else { throw GroupError.UnexpectedError }
        guard case let Token.Symbol(token) = tokens[0] else { throw GroupError.UnexpectedError }
        return SymbolNode(token)
    }
    func toOperator(lhs: Node, rhs: Node) throws -> OperatorNode {
        guard tokens.count == 1 else { throw GroupError.UnexpectedError }
        guard case let Token.Other(token) = tokens[0] else { throw GroupError.UnexpectedError }
        return OperatorNode(token, children: [lhs, rhs])
    }
    func toNumber() throws -> ConstantNode {
        guard tokens.count == 1 else { throw GroupError.UnexpectedError }
        guard case let Token.Number(token) = tokens[0] else { throw GroupError.UnexpectedError }
        return ConstantNode(token)
    }
    
    override public var description : String {
        get {
            return "Euler.Group(tokens: \(self.tokens), type: \(self.type))"
        }
    }
}

/// The `Grouper` is the class that will be in charged of converting an array of `Token` into an array of `Group` in the process of parsing a mathematical expression.
public class Grouper {
    /// List of tokens
    let tokens: [Token]
    internal var index = 0
    
    /// Context in which the expression should be grouped
    var context: Parser.ParseContext
    
    /// Initiatlize the `Grouper` class
    /// - Parameter tokens: the array of `Token` given by the `Lexer`
    /// - Parameter context: the context in which the expression should be grouped
    init(tokens: [Token], context: Parser.ParseContext) {
        self.tokens = tokens
        self.context = context
    }
    
    /// Gives current `Token`
    func peekCurrentToken() -> Token {
        return tokens[index]
    }
    
    /// Gives the next `Token`
    func popCurrentToken() -> Token {
        index += 1
        return tokens[index]
    }
    
    /// Return a `Bool` telling us if we can go any further
    var tokensAvailable: Bool {
        return index < tokens.count
    }
    
    /// Stores the current parenthesis level
    internal var level = 0
    
    /// Groups the given tokens into an array of `Group`
    public func group() throws -> [Group] {
        index = 0
        
        var temp: [[Token]] = [[]]
        var groups = [Group]()
        
        var nested = 0
        while tokensAvailable {
            let token = peekCurrentToken()
            index += 1
            if nested > 0 {
                temp[level].append(token)
                switch token {
                case .ParensOpen:
                    nested += 1
                    continue
                case .ParensClose:
                    nested -= 1
                default: continue
                }
            }
            switch token {
            case .Symbol(_):
                let g = Group(tokens: [token], type: .Symbol, context: self.context)
                 groups.append(g)
            case .Number(_):
                let g = Group(tokens: [token], type: .Number, context: self.context)
                 groups.append(g)
            case .ParensOpen:
                nested += 1
            case .ParensClose:
                if nested == 0 {
                    groups.append(Group(tokens: temp[level].dropLast(), type: .Parenthesis, context: self.context))
                    level += 1
                    temp.append([Token]()) // Adding empty array in case there is a list
                }
            case .Other(_):
                let g = Group(tokens: [token], type: .UnParsed, context: self.context)
                groups.append(g)
            }
        }
        
        return groups
    }
}
