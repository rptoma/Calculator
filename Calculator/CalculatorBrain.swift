//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Toma Radu-Petrescu on 12/02/2017.
//  Copyright © 2017 Toma Radu-Petrescu. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var descriptionAccumulator = "0.0"
    private var equalWasPressed = false
    private var internalProgram = [AnyObject]()

    private enum Operation{
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String)
        case Equals
        case AC
    }

    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "sin" : Operation.UnaryOperation(sin, {"sin(" + $0 + ")"}),
        "√" : Operation.UnaryOperation(sqrt, {"√(" + $0 + ")"}),
        "×" : Operation.BinaryOperation({ $0 * $1 }, { "(" + $0 + ")" + "×" + $1 }),
        "/" : Operation.BinaryOperation({ $0 / $1 }, { "(" + $0 + "/" + $1 + ")"}),
        "+" : Operation.BinaryOperation({ $0 + $1 }, { $0 + "+" + $1 }),
        "-" : Operation.BinaryOperation({ $0 - $1 }, { $0 + "-" + $1 }),
        "=" : Operation.Equals,
        "AC": Operation.AC
    ]
    
    var variableValues = Dictionary<String, Double>()
    
    typealias PropertyList = [AnyObject]
    
    
    func setOperand(operand: Double){
        accumulator = operand
        internalProgram.append(operand as AnyObject)
        if operand.truncatingRemainder(dividingBy: 1) == 0 {
            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 0
            descriptionAccumulator = formatter.string(from: NSNumber(floatLiteral: operand))!
        }
        else {
            descriptionAccumulator = String(operand)
        }
    }
    
    func setOperand(variableName: String){
        variableValues[variableName] = variableValues[variableName] ?? 0.0
        accumulator = variableValues[variableName]!
        descriptionAccumulator = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    func clear() {
        pending = nil
        accumulator = 0
        descriptionAccumulator = " "
        internalProgram.removeAll()
    }
    
    private struct PendingBinaryOperationInfo{
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionBinaryFunction: (String, String) -> String
        var descriptionFirstOperand: String
    }
    private var pending : PendingBinaryOperationInfo?
    
    func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionBinaryFunction(pending!.descriptionFirstOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    func performOperation(symbol: String){
        if let operation = operations[symbol] {
            internalProgram.append(symbol as AnyObject)
            switch operation {
            case .Constant(let value) :
                accumulator = value
                descriptionAccumulator = symbol
                executePendingBinaryOperation()
            case .UnaryOperation(let function, let descriptionFunction) :
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
                executePendingBinaryOperation()
            case .BinaryOperation(let function, let descriptionFunction) :
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionBinaryFunction: descriptionFunction, descriptionFirstOperand: descriptionAccumulator)
            case .Equals:
                
                executePendingBinaryOperation()
            case .AC:
                clear()
            }
        }
    }
    
    var program: PropertyList {
        get{
            return internalProgram
        }
        set{
            clear()
            let arrayOfOps = newValue
            for op in arrayOfOps {
                if let symbol = op as? String {
                    if variableValues[symbol] == nil {
                        performOperation(symbol: symbol)
                    }
                    else {
                        setOperand(variableName: symbol)
                    }
                }
                else if let number = op as? Double {
                    setOperand(operand: number)
                }
            }
        }
        
    }

    func undo(){
        internalProgram.removeLast()
        program = internalProgram
    }
    
    var result: Double {
        get{
            return accumulator
        }
    }
    
    var description: String {
        get{
            if(pending == nil){
                return descriptionAccumulator
            }
            else{
                return pending!.descriptionBinaryFunction(pending!.descriptionFirstOperand,
                                                    pending!.descriptionFirstOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    var isPartialResult: Bool{
        get {
            if pending == nil {
                return false
            }
            else {
                return true
            }
        }
    }
    
}

