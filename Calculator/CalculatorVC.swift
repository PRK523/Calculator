//
//  CalculatorVC.swift
//  Calculator
//
//  Created by PRANOTI KULKARNI on 3/20/19.
//  Copyright © 2019 PRANOTI KULKARNI. All rights reserved.
//

import UIKit

class CalculatorVC: UIViewController {

    @IBOutlet weak var equationDisplay: UILabel!
    @IBOutlet weak var numDisplay: UILabel!
    
    //reference to the model class which handles all the math operation logic.
    private var model = CalculatorModel()
    
    //i have used this just to check when user is typing anything in the label or text is not being entered.
    var enteringText = false
    
    //tried to make the upside down orientation for the device but looks like most of the apps don't support it and also i noticed a bug on iphone X where up side down orientation is not supported.
//    func shouldAutorotate() -> Bool {
//        return true
//    }
//
//    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.all
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.minimumIntegerDigits = 1
        decimalSeparator.setTitle(numberFormatter.decimalSeparator,
                                  for: .normal)
    }
    
    @IBAction func digitPressed(_ sender: UIButton) {
        let digit = sender.currentTitle!
        //print("\(digit) was clicked")
        if enteringText {
            let textLabel = numDisplay.text!
            numDisplay.text = textLabel + digit
        } else {
            numDisplay.text = digit
            enteringText = true
        }
    }
    
    
    //this is a computed property with getters and setters to first get the default display value and then set
    //the value in the label when user wants the result.
    var displayVal: Double {
        get {
            //return Double(numDisplay.text!)!
            guard let valueString = numDisplay.text else { return 0.0 }
            let value = numberFormatter.number(from: valueString)
            return Double(truncating: value ?? 0)
        }
        set {
            numDisplay.text = String(newValue)
        }
    }
    
    
    @IBOutlet weak var decimalSeparator: UIButton!
    //private var numberFormatter = NumberFormatter()
     private weak var numberFormatter: NumberFormatter! = CalculatorModel.DoubleToString.numberFormatter
    
    
    @IBAction func decimalNumbers() {
        if !enteringText {
            numDisplay.text = "0" + numberFormatter.decimalSeparator
        } else if !numDisplay.text!.contains(numberFormatter.decimalSeparator) {
            numDisplay.text = numDisplay.text! + numberFormatter.decimalSeparator
        }
        enteringText = true
    }
    
    @IBAction func mathOperation(_ sender: UIButton) {
        //when user is typing and we perform a operation on it the setOperand will display the operated result on display.
        if enteringText {
            model.setOperand(displayVal)
        }
        if let mathSymbol = sender.currentTitle {
            model.simpleOperations(mathSymbol)
        }
//        if let output = model.result {
//            displayVal = output
//        }
          evaluateExpression()
    }
    
    //function to display the equation
    private func evaluateExpression(using variables: Dictionary<String,Double>? = nil) {
        let evaluation = model.evaluate(using: variables)
        if let result = evaluation.result {
            displayVal = result
        }
        enteringText = false
        let postfixDescription = evaluation.isPending ? "..." : "="
        equationDisplay.text = evaluation.description + postfixDescription
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        if numDisplay.text!.count >= 0 || enteringText == false
        {
            model.clear()
            equationDisplay.text = ""
            numDisplay.text = String(0)
            enteringText = false
        }
        
    }
    
}

