//
//  ViewController.swift
//  GraphCalculatorByGuy
//
//  Created by Guy Taieb on 22/02/2017.
//  Copyright © 2017 Guy Taieb. All rights reserved.
//

import UIKit

class ClaculatorViewController: UIViewController, UISplitViewControllerDelegate {
    
    var i = 6
    

    @IBOutlet weak var graphButton: UIButton!
    
    @IBOutlet weak var inputTracker: UILabel!
    
    @IBOutlet private weak var display: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    private var isDotInDisplay = false
    
    @IBAction private func newTouchDigit(_ sender: UIButton) {
        let newDigit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + newDigit
        } else {
            display.text = newDigit
        }
        
        userIsInTheMiddleOfTyping = true
    }
    
    @IBAction func touchDot(_ sender: UIButton) {
        
        if isDotInDisplay == false {
            let dot = sender.currentTitle!
            isDotInDisplay = true
            
            if userIsInTheMiddleOfTyping {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + dot
            } else {
                display.text = dot
                userIsInTheMiddleOfTyping = true
            }
        }
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            let isInteger = floor(newValue) == newValue
            if isInteger && newValue > Double(Int.min) && newValue < Double(Int.max) {
                display.text = String(Int(newValue))
            } else {
                display.text = String(newValue)}
            
        }
    }
    
    
    private var brain = OneMoreBrain()
    
    @IBAction func AC(_ sender: UIButton) {
        inputTracker.text = " "
        displayValue = 0
        userIsInTheMiddleOfTyping = false
        isDotInDisplay = false
        brain.setOperand(operand: displayValue)
        brain.zeroAccumulator()
        brain.variableValue["M"] = 0.0
    }
    
    var savedProgram: OneMoreBrain.propertyList?
    
    
    @IBAction func saveVarValue() {
        brain.variableValue["M"] = displayValue
        savedProgram = brain.program
        brain.program = savedProgram as OneMoreBrain.propertyList!
        displayValue = brain.result
        userIsInTheMiddleOfTyping = false
        isDotInDisplay = false
    }
    
    
    
    @IBAction func undo() {
        guard userIsInTheMiddleOfTyping == false else {
            guard display.text?.characters.count != 1 else {
                displayValue = 0
                userIsInTheMiddleOfTyping = false
                return
            }
            display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
            return
        }
        
        savedProgram = brain.program
        var arrayOfOps = [AnyObject]()
        var currentSavedProgram: OneMoreBrain.propertyList {
            get{
                return arrayOfOps as OneMoreBrain.propertyList
            }
            set{
                guard var arrayOfObjects = newValue as? [AnyObject] else {
                    return
                }
                
                guard arrayOfObjects.isEmpty else {
                    arrayOfObjects.removeLast()
                    arrayOfOps = arrayOfObjects
                    return
                }
            }
        }
        currentSavedProgram = savedProgram!
        brain.program = currentSavedProgram as OneMoreBrain.propertyList!
        displayValue = brain.result
        inputTracker.text = brain.isPartialResult ? brain.description : " "
    }
    
    
    
    @IBAction func deployVariable(_ sender: UIButton) {
        brain.setOperandVar(variableName: "M")
        displayValue = brain.result
        
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathOperation = sender.currentTitle {
            brain.performCalculations(symbol: mathOperation)
        }
        displayValue = brain.result
        inputTracker.text = brain.description + (brain.isPartialResult ? "..." : "=")
        isDotInDisplay = false
        
        
        
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let graphVC = segue.destination.contents as? GraphViewController {
            graphVC.title = brain.description
            graphVC.program = brain.program
        }
    }
}

extension UIViewController {
        var contents: UIViewController {
            if let navCon = self as? UINavigationController {
                return navCon.visibleViewController ?? self
            } else {
                return self
            }
        }
    }




