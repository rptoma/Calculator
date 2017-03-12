//
//  ViewController.swift
//  Calculator
//
//  Created by Toma Radu-Petrescu on 12/02/2017.
//  Copyright © 2017 Toma Radu-Petrescu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private var userAlreadyTyped = false
    private var userTypedPoint = false
    private let model = CalculatorBrain()
    private var savedProgram : CalculatorBrain.PropertyList?
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userAlreadyTyped {
            if digit == "." {
                if userTypedPoint == false {
                    display.text = display.text! + digit
                    userTypedPoint = true
                }
            }
            else{
                display.text = display.text! + digit
            }
        }
        else{
            if digit == "." {
                userTypedPoint = true
                display.text! = "0."
                userAlreadyTyped = true
            }
            else if digit != "0"{
                display.text = digit
                userAlreadyTyped = true
            }
            else{
                display.text = digit
            }
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        displayValue = 0
        userAlreadyTyped = false
    }
    
    @IBAction func backspace() {
        if history.text! != " " {
            if display.text!.characters.count == 1 {
                model.undo()
                history.text = model.description
                displayValue = model.result
                userAlreadyTyped = false
            }
            else {
                display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
                userAlreadyTyped = true
                if display.text!.characters.count == 0 {
                    display.text = "0"
                    userAlreadyTyped = false
                }
            }
        }
    }
    
    @IBAction func getVariable(_ sender: UIButton) {
        model.setOperand(variableName: sender.currentTitle!)
        displayValue = model.result
        userAlreadyTyped = false
    }
    
    
    @IBAction func setVariable(_ sender: UIButton) {
        if let variableNameWithInputSign = sender.currentTitle {
            let variableName = variableNameWithInputSign.substring(from: variableNameWithInputSign.index(variableNameWithInputSign.startIndex, offsetBy: 1))
            model.variableValues[variableName] = displayValue
            model.program = model.program
            displayValue = model.result
            userAlreadyTyped = false
        }
    }
    
    private var displayValue : Double {
        get{
            return Double(display.text!)!
        }
        set{
            let value = newValue
            if value.truncatingRemainder(dividingBy: 1) == 0 {
                let formatter = NumberFormatter()
                formatter.maximumFractionDigits = 0
                display.text = formatter.string(from: NSNumber(floatLiteral: value))
            }
            else {
                display.text = String(value)
            }
        }
    }

    @IBAction func performOperation(_ sender: UIButton) {
        if userAlreadyTyped {
            model.setOperand(operand: displayValue)
            userAlreadyTyped = false
        }
        if let symbol = sender.currentTitle {
            model.performOperation(symbol: symbol);
            displayValue = model.result;
            if sender.currentTitle == "AC"{
                history.text = model.description
            }
            else if model.isPartialResult {
                history.text = model.description + "..."
            }
            else {
                history.text = model.description + "="
            }
            
        }
    }
}

