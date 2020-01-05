//
//  EulerTests.swift
//  Euler
//
//  Created by Arthur Guiot on 2019-12-04.
//  Copyright © 2019 Euler. All rights reserved.
//

import Foundation
import XCTest
@testable import Euler

class BigIntTests: XCTestCase {
    func testRadixInitializerAndGetter() {
        let chars: [Character] = [
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g",
            "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x",
            "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
            "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
        ]

        // Randomly choose two bases and a number length, as well as a sign (+ or -)
        for _ in 0..<100 {
            let fromBase = math.random(2...62)
            let toBase = math.random(2...62)
            let numLength = math.random(1...100)
            let sign = math.random(0...1) == 1 ? "-" : ""

            // First digit should not be a 0.
            var num = sign + String(chars[math.random(1..<fromBase)])

            for _ in 1..<numLength {
                num.append(chars[math.random(0..<fromBase)])
            }

            // Convert the random number to a BigInt type
            let b1 = BigInt(num, radix: fromBase)
            // Get the number as a string with the second base
            let s1 = b1!.asString(radix: toBase)
            // Convert that number to a BigInt type
            let b2 = BigInt(s1, radix: toBase)
            // Get the number back as as string in the start base
            let s2 = b2!.asString(radix: fromBase)

            XCTAssert(b1 == b2)
            XCTAssert(s2 == num)
        }

        let bigHex = "abcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdef00"
        let x = BigInt(bigHex, radix: 16)!
        XCTAssert(x.asString(radix: 16) == bigHex)
    }


    func testRadix() {
        XCTAssert(BigInt("ffff",radix:16) == 65535)
        XCTAssert(BigInt("ff",radix:16) == 255.0)
        XCTAssert(BigInt("ff",radix:16) != 100.0)
        XCTAssert(BigInt("ffff",radix:16)! > 255.0)
        XCTAssert(BigInt("f",radix:16)! < 255.0)
        XCTAssert(BigInt("0",radix:16)! <= 1.0)
        XCTAssert(BigInt("f", radix: 16)! >= 1.0)
        XCTAssert(BigInt("rfff",radix:16) == nil)
        
        XCTAssert(BigInt("ffff",radix:16) == 65535)
        XCTAssert(BigInt("rfff",radix:16) == nil)
        XCTAssert(BigInt("ff",radix:10) == nil)
        XCTAssert(BigInt("255",radix:6) == 107)
        XCTAssert(BigInt("999",radix:10) == 999)
        XCTAssert(BigInt("ff",radix:16) == 255.0)
        XCTAssert(BigInt("ff",radix:16) != 100.0)
        XCTAssert(BigInt("ffff",radix:16)! > 255.0)
        XCTAssert(BigInt("f",radix:16)! < 255.0)
        XCTAssert(BigInt("0",radix:16)! <= 1.0)
        XCTAssert(BigInt("f",radix:16)! >= 1.0)
        XCTAssert(BigInt("44",radix:5) == 24)
        XCTAssert(BigInt("44",radix:5) != 100.0)
        XCTAssert(BigInt("321",radix:5)! == 86)
        XCTAssert(BigInt("3",radix:5)! < 255.0)
        XCTAssert(BigInt("0",radix:5)! <= 1.0)
        XCTAssert(BigInt("4",radix:5)! >= 1.0)
        XCTAssert(BigInt("923492349",radix:32)! == 9967689075849)
    }
    
    func testPerformanceStringInit() {
        self.measure {
            for _ in (0...15000) {
                let _ = BigInt(String(arc4random()))
            }
        }
    }
    
    func testPerformanceStringRadixInit() {
        self.measure {
            for _ in (0...15000) {
                let _ = BigInt(String(arc4random()), radix: 10)
            }
        }
    }
    
    static var allTests = [
        ("Initialisation", testRadixInitializerAndGetter),
        ("Radix", testRadix),
        ("String Performance", testPerformanceStringInit),
        ("String multiple performances", testPerformanceStringRadixInit)
    ]
}