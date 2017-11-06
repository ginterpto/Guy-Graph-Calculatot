//
//  OneMoreBrain.swift
//  GuyCalculator
//
//  Created by Guy Taieb on 22/01/2017.
//  Copyright © 2017 Guy Taieb. All rights reserved.
//

import Foundation

class OneMoreBrain
{
    private var accumulator = 0.0
    
    private var internalProgram = [AnyObject]()
    
    private var currentPrecedence = Int.max
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
        
    
    func setOperand (operand: Double) {
        accumulator = operand
        descriptionAccumulator = String(format:"%g", operand)
        internalProgram.append(operand as AnyObject)
        }
    
    func setOperandVar (variableName: String) {
        accumulator = variableValue[variableName] ?? 0
        descriptionAccumulator = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    private var mathOperationsDictionary: Dictionary<String,CalculationType> = [
        "×": CalculationType.binary({$0 * $1}, { $0 + "×" + $1 },1),
        "÷": CalculationType.binary({$0 / $1}, { $0 + "÷" + $1 },1),
        "+": CalculationType.binary({$0 + $1}, { $0 + "+" + $1 },0),
        "−": CalculationType.binary({$0 - $1}, { $0 + "−" + $1 },0),
        "xʸ": CalculationType.binary(pow, { $0 + "^" + $1 },2),
        "π": CalculationType.constant(M_PI),
        "√": CalculationType.unary(sqrt, { "√(" + $0 + ")" }),
        "ln": CalculationType.unary(log, { "ln(" + $0 + ")" }),
        "log": CalculationType.unary(log10, { "ln(" + $0 + ")" }),
        "cos": CalculationType.unary(cos, { "cos(" + $0 + ")"}),
        "sin": CalculationType.unary(sin, { "sin(" + $0 + ")"}),
        "tan": CalculationType.unary(tan, { "tan(" + $0 + ")"}),
        "x²": CalculationType.unary({pow($0, 2)}, {"(" + $0 + ")²"}),
        "±": CalculationType.unary({-$0}, { "-(" + $0 + ")" }),
        "=": CalculationType.equals
    ]
    
    var variableValue = [String: Double]() {
        didSet {
            program = internalProgram as OneMoreBrain.propertyList
        }
    }
    
    
    private enum CalculationType {
        case constant(Double)
        case unary((Double) -> Double,(String) -> String)
        case binary((Double, Double) ->Double, (String, String) -> String, (Int))
        case equals
    }
    
    typealias  propertyList = AnyObject
    
    var program: propertyList {
        get {
            return internalProgram as OneMoreBrain.propertyList
        }
        set {
            zeroAccumulator()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        if mathOperationsDictionary[operation] != nil {
                            performCalculations(symbol: operation)
                        } else {
                            setOperandVar(variableName: operation)
                        }
                    }
                }
            }
        }
    }
    
    
    func performCalculations(symbol: String){
        internalProgram.append(symbol as AnyObject)
        if let calculateNow = mathOperationsDictionary[symbol] {
            switch calculateNow {
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .unary(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .binary(let function, let descriptionFunction, let precedent):
                executePendingBinaryCalc()
                if currentPrecedence < precedent {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedent
                pending = pendingBinaryClacIformation(firstOperand: accumulator, binaryFunction: function, descriptionOperand: descriptionAccumulator, descriptionFunction: descriptionFunction)
            case .equals:
                    executePendingBinaryCalc()
            }
        }
    }
    
    func zeroAccumulator() {
        pending = nil
        accumulator = 0
        internalProgram.removeAll()
        descriptionAccumulator = "0"
    }
    
    private var pending: pendingBinaryClacIformation?
    
    private func executePendingBinaryCalc() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    private struct pendingBinaryClacIformation {
        var firstOperand: Double
        var binaryFunction: (Double, Double) -> Double
        var descriptionOperand: String
        var descriptionFunction: (String, String) -> String
    }
    
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
