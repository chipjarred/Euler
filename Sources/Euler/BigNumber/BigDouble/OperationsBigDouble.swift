//
//  File.swift
//  
//
//  Created by Arthur Guiot on 2019-12-07.
//

import Foundation

extension BigDouble {
    //
    //    MARK: - BigDouble Addition
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //    ||||||||        BigDouble Addition        ||||||||||||||||||||||||||||||||||||||||||||||||
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //
    //
    //
    
    public static func +(lhs: BigDouble, rhs: BigDouble) -> BigDouble {
        // a/b + c/d = ad + bc / bd, where lhs = a/b and rhs = c/d.
        let ad = lhs.numerator.multiplyingBy(rhs.denominator)
        let bc = rhs.numerator.multiplyingBy(lhs.denominator)
        let bd = lhs.denominator.multiplyingBy(rhs.denominator)
        
        let resNumerator = BigInt(sign: lhs.sign, limbs: ad) + BigInt(sign: rhs.sign, limbs: bc)
        
        return BigDouble(
            sign: resNumerator.sign && !resNumerator.limbs.equalTo(0),
            numerator: resNumerator.limbs,
            denominator: bd
        )
    }
    
    public static func +(lhs: BigDouble, rhs: Double) -> BigDouble { return lhs + BigDouble(rhs) }
    public static func +(lhs: Double, rhs: BigDouble) -> BigDouble { return BigDouble(lhs) + rhs }
    public static func +(lhs: BigDouble, rhs: BigInt) -> BigDouble { return lhs + BigDouble(rhs) }
    public static func +(lhs: BigInt, rhs: BigDouble) -> BigDouble { return BigDouble(lhs) + rhs }
    
    public static func +=(lhs: inout BigDouble, rhs: BigDouble) {
        let res = lhs + rhs
        lhs = res
    }
    
    public static func +=(lhs: inout BigDouble, rhs: Double) { lhs += BigDouble(rhs) }
    
    
    //
    //
    //    MARK: - BigDouble Negation
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //    ||||||||        BigDouble Negation        ||||||||||||||||||||||||||||||||||||||||||||||||
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //
    //
    //
    
    /**
     * makes the current value negative
     */
    public mutating func negate()
    {
        if !self.isZero()
        {
            self.sign = !self.sign
        }
    }
    
    public static prefix func -(n: BigDouble) -> BigDouble
    {
        var n = n
        n.negate()
        return n
    }
    
    //
    //
    //    MARK: - BigDouble Subtraction
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //    ||||||||        BigDouble Subtraction        |||||||||||||||||||||||||||||||||||||||||||||
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //
    //
    //
    
    public static func -(lhs: BigDouble, rhs: BigDouble) -> BigDouble
    {
        return lhs + -rhs
    }
    public static func -(lhs: BigDouble, rhs: Double) -> BigDouble { return lhs - BigDouble(rhs) }
    public static func -(lhs: Double, rhs: BigDouble) -> BigDouble { return BigDouble(lhs) - rhs }
    public static func -(lhs: BigDouble, rhs: BigInt) -> BigDouble { return lhs - BigDouble(rhs) }
    public static func -=(lhs: inout BigDouble, rhs: BigDouble) {
        let res = lhs - rhs
        lhs = res
    }
    
    public static func -=(lhs: inout BigDouble, rhs: Double) { lhs -= BigDouble(rhs) }
    
    //
    //
    //    MARK: - BigDouble Multiplication
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //    ||||||||        BigDouble Multiplication        ||||||||||||||||||||||||||||||||||||||||||
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //
    //
    //
    
    public static func *(lhs: BigDouble, rhs: BigDouble) -> BigDouble
    {
        var res =  BigDouble(
            sign:            lhs.sign != rhs.sign,
            numerator:        lhs.numerator.multiplyingBy(rhs.numerator),
            denominator:    lhs.denominator.multiplyingBy(rhs.denominator)
        )
        
        if res.isZero() { res.sign = false }
        return res
    }
    public static func *(lhs: BigDouble, rhs: Double) -> BigDouble { return lhs * BigDouble(rhs) }
    public static func *(lhs: Double, rhs: BigDouble) -> BigDouble { return BigDouble(lhs) * rhs }
    public static func *(lhs: BigDouble, rhs: BigInt) -> BigDouble { return lhs * BigDouble(rhs) }
    public static func *(lhs: BigInt, rhs: BigDouble) -> BigDouble { return BigDouble(lhs) * rhs }
    
    public static func *=(lhs: inout BigDouble, rhs: BigDouble) {
        let res = lhs * rhs
        lhs = res
    }
    
    public static func *=(lhs: inout BigDouble, rhs: Double) { lhs *= BigDouble(rhs) }
    
    //
    //
    //    MARK: - BigDouble Exponentiation
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //    ||||||||        BigDouble Exponentiation        ||||||||||||||||||||||||||||||||||||||||||
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //
    //
    //
    
    public static func **(_ base : BigDouble, _ exponent : Int) -> BigDouble
    {
        if exponent == 0
        {
            return BigDouble(1)
        }
        if exponent == 1
        {
            return base
        }
        if exponent < 0
        {
            return BigDouble(1) / (base ** -exponent)
        }
        
        return base * (base ** (exponent - 1))
    }
    
    public static func **(_ base: BigDouble, _ exponent: BigInt) -> BigDouble
    {
        if exponent == 0
        {
            return BigDouble(1)
        }
        if exponent == 1
        {
            return base
        }
        if exponent < 0
        {
            return BigDouble(1) / (base ** -exponent)
        }
        
        return base * (base ** (exponent - 1))
    }
    
    /**
     * - reference: http://rosettacode.org/wiki/Nth_root
     */
    public static func **(_ base: BigDouble, _ exponent: BigDouble) -> BigDouble
    {
        var count = base.precision
        
        // something over 1
        if BigInt(limbs: exponent.denominator) == 1 {
            return base**BigInt(sign: exponent.sign, limbs: exponent.numerator)
        }
        
        if BigInt(limbs: exponent.numerator) != 1 {
            return (base ** BigInt(sign: exponent.sign, limbs: exponent.numerator)) ** BigDouble(sign: false, numerator: BigDouble(1).numerator, denominator: exponent.denominator)
        }
        
        // we have 1/something
        
        var previous  = BigDouble(1)
        var ans = previous
        let exp = BigInt(sign: exponent.sign, limbs: exponent.denominator)
        let prec = BigDouble(0.1) ** (abs(base.precision) + 1)
        
        while(true) {
            previous = ans
            
            let rlhs = BigDouble(BigInt(1), over:exp)
            let rrhs = ((exp-1)*ans + (base / pow(ans, exp-1)))
            ans = rlhs * rrhs
            
            if abs(ans-previous) < prec {
                break
            }
            
            count = count + 1
        }
        
        return ans
    }
    
    //
    //
    //    MARK: - BigDouble Division
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //    ||||||||        BigDouble Division        ||||||||||||||||||||||||||||||||||||||||||||||||
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //
    //
    //
    
    public static func /(lhs: BigDouble, rhs: BigDouble) -> BigDouble
    {
        var res =  BigDouble(
            sign:            lhs.sign != rhs.sign,
            numerator:        lhs.numerator.multiplyingBy(rhs.denominator),
            denominator:    lhs.denominator.multiplyingBy(rhs.numerator)
        )
        
        if res.isZero() { res.sign = false }
        return res
    }
    public static func /(lhs: BigDouble, rhs: Double) -> BigDouble { return lhs / BigDouble(rhs) }
    public static func /(lhs: BigDouble, rhs: BigInt) -> BigDouble { return lhs / BigDouble(rhs) }
    public static func /(lhs: Double, rhs: BigDouble) -> BigDouble { return BigDouble(lhs) / rhs }
    
    //
    //
    //    MARK: - BigDouble Comparing
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //    ||||||||        BigDouble Comparing        |||||||||||||||||||||||||||||||||||||||||||||||
    //    ————————————————————————————————————————————————————————————————————————————————————————
    //
    //
    //
    
    /**
     * An == comparison with an epsilon (fixed then a calculated "ULPs")
     * Reference: http://floating-point-gui.de/errors/comparison/
     * Reference: https://bitbashing.io/comparing-floats.html
     */
    public static func nearlyEqual(_ lhs: BigDouble, _ rhs: BigDouble, epsilon: Double = 0.00001) -> Bool {
        let absLhs = abs(lhs)
        let absRhs = abs(rhs);
        let diff = abs(lhs - rhs);
        
        if (lhs == rhs) { // shortcut, handles infinities
            return true;
        } else if diff <= epsilon {
            return true // shortcut
        } else if (lhs == 0 || rhs == 0 || diff < Double.leastNormalMagnitude) {
            // lhs or rhs is zero or both are extremely close to it
            // relative error is less meaningful here
            return diff < (epsilon * Double.leastNormalMagnitude);
        } else { // use relative error
            return diff / min((absLhs + absRhs), BigDouble(Double.greatestFiniteMagnitude)) < epsilon;
        }
    }
    
    public static func ==(lhs: BigDouble, rhs: BigDouble) -> Bool
    {
        if lhs.sign != rhs.sign { return false }
        if lhs.numerator != rhs.numerator { return false }
        if lhs.denominator != rhs.denominator { return false }
        
        return true
    }
    public static func ==(lhs: BigDouble, rhs: Double) -> Bool { return lhs == BigDouble(rhs) }
    public static func ==(lhs: Double, rhs: BigDouble) -> Bool { return BigDouble(lhs) == rhs }
    
    public static func !=(lhs: BigDouble, rhs: BigDouble) -> Bool
    {
        return !(lhs == rhs)
    }
    public static func !=(lhs: BigDouble, rhs: Double) -> Bool { return lhs != BigDouble(rhs) }
    public static func !=(lhs: Double, rhs: BigDouble) -> Bool { return BigDouble(lhs) != rhs }
    
    public static func <(lhs: BigDouble, rhs: BigDouble) -> Bool
    {
        if lhs.sign != rhs.sign { return lhs.sign }
        
        // more efficient than lcm version
        let ad  = lhs.numerator.multiplyingBy(rhs.denominator)
        let bc = rhs.numerator.multiplyingBy(lhs.denominator)
        
        if lhs.sign { return bc.lessThan(ad) }
        
        return ad.lessThan(bc)
    }
    public static func <(lhs: BigDouble, rhs: Double) -> Bool { return lhs < BigDouble(rhs) }
    public static func <(lhs: Double, rhs: BigDouble) -> Bool { return BigDouble(lhs) < rhs }
    
    public static func >(lhs: BigDouble, rhs: BigDouble) -> Bool { return rhs < lhs }
    public static func >(lhs: BigDouble, rhs: Double) -> Bool { return lhs > BigDouble(rhs) }
    public static func >(lhs: Double, rhs: BigDouble) -> Bool { return BigDouble(lhs) > rhs }
    
    public static func <=(lhs: BigDouble, rhs: BigDouble) -> Bool { return !(rhs < lhs) }
    public static func <=(lhs: BigDouble, rhs: Double) -> Bool { return lhs <= BigDouble(rhs) }
    public static func <=(lhs: Double, rhs: BigDouble) -> Bool { return BigDouble(lhs) <= rhs }
    
    public static func >=(lhs: BigDouble, rhs: BigDouble) -> Bool { return !(lhs < rhs) }
    public static func >=(lhs: BigDouble, rhs: Double) -> Bool { return lhs >= BigDouble(rhs) }
    public static func >=(lhs: Double, rhs: BigDouble) -> Bool { return BigDouble(lhs) >= rhs }
}