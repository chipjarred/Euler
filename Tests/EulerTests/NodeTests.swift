//
//  File.swift
//  
//
//  Created by Arthur Guiot on 2019-12-16.
//

import Foundation

import XCTest
@testable import Euler

class NodeTests: XCTestCase {
    func testConstantNode() {
        let c1 = ConstantNode(2)
        
        XCTAssertEqual(try? c1.evaluate([:], [:]).number, BigNumber(2))
    }
    func testOperatorNode() {
        let c1 = ConstantNode(2)
        let c2 = ConstantNode(4)
        let op = OperatorNode("*", children: [c1, c2])
        
        XCTAssertEqual(try? op.evaluate([:], [:]).number, BigNumber(8))
        
        let c3 = ConstantNode(5)
        let op2 = OperatorNode("+", children: [c3, op])
        
        XCTAssertEqual(try? op2.evaluate([:], [:]).number, BigNumber(13))
    }
    func testSymboleNode() {
        let c1 = ConstantNode(2)
        let c2 = SymbolNode("x")
        let op = OperatorNode("*", children: [c1, c2])
        
        XCTAssertEqual(try? op.evaluate(["x": BigNumber(4)], [:]).number, BigNumber(8))
        
        let c3 = ConstantNode(5)
        let op2 = OperatorNode("+", children: [c3, op])
        
        XCTAssertEqual(op2.toString(), "5 + 2 * x")
    }
    func testParser() {
        let src = "3(4*5-sqrt(4)) = 3"
        let lexer = Lexer(input: src)
        let tokens = lexer.tokenize()
        let p = Parser(tokens: tokens)
        do {
            let expression = try p.parse()
            let str = expression.toString()
            XCTAssertEqual(str, "3 * (4 * 5 - sqrt(4)) = 3") // Simple trick to make it work...
            XCTAssertEqual(try Parser("5.0 - sqrt(8) * 5 = x^2 - factorial(4)").parse().toString(), "5 - sqrt(8) * 5 = x ^ 2 - factorial(4)")
            XCTAssertEqual(try Parser("((4*2) - 3) +sqrt(4)").parse().toString(), "((4 * 2) - 3) + sqrt(4)")
            
            
            let expr = try Parser("(3/2)x + 2 - sqrt(3 * 4)").parse()
            let tree = Tree.computeDepth(node: expr)
            print(tree)
            
            XCTAssertEqual(try? Tables().interpret(command: "=ABS(-8)").number, 8)
            XCTAssertEqual(try? Tables().interpret(command: "=GCD(8, 9, 5, 6, 12)").number, 1)
            
            let e = try Parser("=SUM(A3:A4, A5:A6)-MIN(1, 2, 3, 4)", type: .tables, tablesContext: Tables()).parse() // Requires a Tables to interpret code
            XCTAssertEqual(e.toString(), "SUM(A3 : A4, A5 : A6) - MIN(1, 2, 3, 4)")
            
            var l = try Parser(latex: "\\frac{4-\\sqrt{4^2-9}}{8} * \\frac{\\frac{\\frac{1}{2}}{3}}{4}").parse()
            XCTAssertEqual(try? l.evaluate([:], Tables().linker).number?.nearlyEquals(0.007053378588205258), true)
            l = try Parser(latex: "2-\\frac{9}{3}3\\cdot\\sqrt{812}-9.0").parse()
            XCTAssertEqual(try? l.evaluate([:], Tables().linker).number?.nearlyEquals(-263.4605), true)
        } catch {
            print(error.localizedDescription)
            XCTFail()
        }
    }
    func testCompile() {
        do {
            let p = Parser("x+y*2 + (4+5)/3")
            let expression = try p.parse()
            let comp = expression.compile()
            XCTAssertEqual(comp.toString(), "x + y * 2 + 3")
            
            XCTAssertEqual(try Parser("(4*2)").parse().compile().toString(), "8")
            XCTAssertEqual(try Parser("0 / 0").parse().compile().toString(), "0 / 0")
            XCTAssertEqual(try Parser("x+x - y*y").parse().compile().toString(), "2 * x - y ^ 2")
        } catch {
            print(error.localizedDescription)
            XCTFail()
        }
    }
    static var allTests = [
        ("Constant Node", testConstantNode),
        ("Operator Node", testOperatorNode),
        ("Symbol Node", testSymboleNode),
        ("Parser", testParser),
        ("Compiler", testCompile)
    ]
}
