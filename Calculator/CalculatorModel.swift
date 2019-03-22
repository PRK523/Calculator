//
//  CalculatorModel.swift
//  Calculator
//
//  Created by PRANOTI KULKARNI on 3/20/19.
//  Copyright © 2019 PRANOTI KULKARNI. All rights reserved.
//

import Foundation

struct CalculatorModel {
    
    //this will store all the calculated values
    private var res: Double? {  didSet {    _didResetAccumulator = true }   }
    private var _didResetAccumulator: Bool = false
    
    //using enum to handle all the calculator operation cases we will perform on our numbers
    private enum MathOperation {
        case constant(Double)
        case unaryMathOperation((Double) -> Double)
        case binaryMathOperation((Double, Double) -> Double)
        case equals
    }
    
    //generic type dictionary used here to hold my operator("+") and calculations i will apply on the numbers.
    private var operations: Dictionary<String, MathOperation> = [
        "+": MathOperation.binaryMathOperation({ $0 + $1 }), //instead of typing the whole function as func add(firstNum: Int, secondNum: Int) -> Int {return firstNum + secondNum} using closure
        "-": MathOperation.binaryMathOperation({ $0 - $1 }),
        "×": MathOperation.binaryMathOperation({ $0 * $1 }),
        "÷": MathOperation.binaryMathOperation({ $0 / $1 }),
        "π": MathOperation.constant(Double.pi),
        "e": MathOperation.constant(M_E),
        "√": MathOperation.unaryMathOperation(sqrt),
        "pow": MathOperation.binaryMathOperation(pow),
        "=": MathOperation.equals
    ]
    
    mutating func simpleOperations(_ m: String) {
        //lookup for my dictionary for "+" or any other symbol which is in string format
        if let operation = operations[m] {
            switch operation {
            //enums associated value is binaryOperation so it will perform the operation depending on the operation symbol defined in oprations private variable dictionary type.
            case .constant(let value) :
                if bo == nil {
                    resetExpression()
                }
            res = value
            case .unaryMathOperation(let f):
            if let operand = res {
                res = f(operand)
            }
            case .binaryMathOperation(let function):
            if _didResetAccumulator && res != nil {
                if isPending {
                    performAllOperation()
                }
                bo = BinaryOperation(function: function, firstOperand: res!)
                _didResetAccumulator = false
                expression.append(.operation(m))
            }
                break
            case .equals:
                performAllOperation()
            }
        }
        if _didResetAccumulator {
            expression.append(.operation(m))
        }
    }
    
    
    
    private var symbolArr: [String] = []
    
    weak var numberFormatter: NumberFormatter! = CalculatorModel.DoubleToString.numberFormatter
    
    struct DoubleToString {
        static let numberFormatter = NumberFormatter()
    }
//    //floating point numbers
//    private var formattedAccumulator: String? {
//        if let number = res {
//            return numberFormatter?.string(from: number as NSNumber) ?? String(number)
//        } else {
//            return nil
//        }
//    }
    
    //clearing all the data
    mutating func clear() {
        resetExpression()
        dictionaryForVars.variables = [:]
    }
    
    var symbols: String {
        var returnString: String = ""
        for element in symbolArr {
            returnString += element
        }
        return returnString
    }
    
    var isPending: Bool {
        return bo != nil
    }
    
    //logic for creating equation expression on the display
    
    var resultIsPending: Bool {
        return evaluate().isPending
    }
    
    private struct dictionaryForVars {
        static var variables: [String: Double] = [:]
    }
    
    //created another enum that stores operands and their corresponding operations performed on them.
    //which is then passed into an array of Expression.
    private var expression: [ExpressionLiteral] = []
    
    private enum ExpressionLiteral {
        case operand(Operand)
        case operation(String)
        
        enum Operand {
            case variable(String)
            case value(Double)
        }
    }
    
    mutating func setOperand(variable named: String)
    {   if !evaluate().isPending {
            resetExpression()
        }
        res = dictionaryForVars.variables[named] ?? 0
        expression.append(.operand(.variable(named)))
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String)
    {
        let expression = self.expression
        var calcModel = CalculatorModel()
        if variables != nil {
            dictionaryForVars.variables = variables!
        }
        
        for expressionLiteral in expression {
            switch expressionLiteral {
            case .operand(let operand):
                switch operand {
                case .variable(let name):
                    calcModel.res = dictionaryForVars.variables[name] ?? 0
                    calcModel.setOperand(variable: name)
                case .value(let operandValue):
                    calcModel.setOperand(operandValue)
                }
            case .operation(let symbol):
                calcModel.simpleOperations(symbol)
            }
        }
        return(calcModel.res, calcModel.bo != nil, calcModel.createDescription())
    }
    
    private func createDescription() -> String {
        var descriptions: [String] = []
        var binaryOperation = false
        for literal in expression
        {
        switch literal {
        case .operand(let operand):
            switch operand {
            case .value(let value): descriptions += [numberFormatter.string(from: value as NSNumber) ?? String(value)]
            case .variable(let name): descriptions += [name]
            }
        case .operation(let symbol):
            guard let operation = operations[symbol] else { break }
            switch operation {
            case .unaryMathOperation:
                if binaryOperation {
                    let lastOperand = descriptions.last!
                    descriptions = [String](descriptions.dropLast()) + [symbol + "(" + lastOperand + ")"]
                } else {
                    descriptions = [symbol + "("] + descriptions + [")"]
                }
            case .equals:
                binaryOperation = false
            case .binaryMathOperation:
                binaryOperation = true
                fallthrough
            default: descriptions += [symbol]
            }
            }
        }
        return descriptions.reduce("", +)
    }
    
    
    //this is called when equal symbol is touched by user to display the resultant value
    private mutating func performAllOperation() {
        if bo != nil && res != nil {
            res = bo?.perform(with: res!)
            bo = nil
        }
    }
    
    //incase im not applying any math operation so my binary operation will be null
    private var bo: BinaryOperation?
        
    private struct BinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
            
        func perform(with secondOperand: Double) -> Double {
                return function(firstOperand, secondOperand)
            }
    }
    
    private mutating func resetExpression() {
        res = nil
        bo = nil
        expression = []
    }
    
    mutating func setOperand(_ op: Double){
        if !evaluate().isPending {
            resetExpression()
        }
        res = op
        expression.append(.operand(.value(op)))
    }
    
    var result: Double? {
        get {
            return res
        }
    }
    
    
}
