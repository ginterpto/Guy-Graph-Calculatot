//
//  GraphViewController.swift
//  GraphCalculatorByGuy
//
//  Created by Guy Taieb on 23/02/2017.
//  Copyright © 2017 Guy Taieb. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController, GraphViewDataSource{
    
    var program: AnyObject? {
        didSet {
            if program != nil {
                brain.program = program!
            }
        }
    }
    
    var progrmaIsIn: Double?
    
    var savedProgram: OneMoreBrain.propertyList?
    
    private var brain = OneMoreBrain()
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            
        }
    }
    
    @IBAction func panGraph(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
                graphView.movingCenter.x += recognizer.translation(in: graphView).x
                graphView.movingCenter.y += recognizer.translation(in: graphView).y
                recognizer.setTranslation(CGPoint.zero, in: graphView)
        default:
            break
        }
        
    }
    
    @IBAction func CenterGraph(_ recognizer: UITapGestureRecognizer) {
        graphView.movingCenter = CGPoint(x:0, y:0)
        
    }
    

    @IBAction func changeScale(_ recognizer: UIPinchGestureRecognizer) {
        graphView.changeScale(recognizer: recognizer)
    }
    
    func calculateValue(x: Double) -> Double {
        brain.variableValue["M"] = x
        return brain.result
        
    }

    
    
    
}


   
