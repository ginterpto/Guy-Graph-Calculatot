//
//  GraphView.swift
//  GraphCalculatorByGuy
//
//  Created by Guy Taieb on 23/02/2017.
//  Copyright © 2017 Guy Taieb. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func calculateValue(x: Double) -> Double
}

@IBDesignable
class GraphView: UIView {
    @IBInspectable
    var scale: CGFloat = 50 { didSet { setNeedsDisplay() } }
        
    var color: UIColor = UIColor.darkGray { didSet { setNeedsDisplay() } }
    
    var origin: CGPoint {
        
          return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    
    var movingCenter = CGPoint(x: 0, y: 0) { didSet { setNeedsDisplay() } }
    
    
    weak var dataSource: GraphViewDataSource?
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed, .ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
            }
        }
    
    
    func pathForAxis(start: CGPoint, end: CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        path.lineWidth = 1
        return path
    }
    
    func pathForGraphScaleX(originPoint: CGFloat) ->UIBezierPath {
        let movingCenterY = movingCenter.y
        let path = pathForAxis(start: CGPoint(x: originPoint, y: bounds.midY + movingCenterY - 3), end: CGPoint(x: originPoint, y: bounds.midY + movingCenterY + 3))
        return path
    }
    func pathForGraphScaleY(originPoint: CGFloat) ->UIBezierPath {
        let movingCenterX = movingCenter.x
        let path = pathForAxis(start: CGPoint(x: bounds.midX + movingCenterX - 3, y: originPoint), end: CGPoint(x: bounds.midX + movingCenterX + 3, y: originPoint))
        return path
    }
    
    
    

    override func draw(_ rect: CGRect) {
        color.set()
        var scalingPointX = movingCenter.x
        var scalingPointXNegative = movingCenter.x
        var scalingPointY = movingCenter.y
        var scalingPointYNegative = movingCenter.y
        var movingCenterX = movingCenter.x
        var movingCenterY = movingCenter.y
        
        pathForAxis(start: CGPoint(x: bounds.midX + movingCenterX , y: bounds.minY), end: CGPoint(x: bounds.midX + movingCenterX , y: bounds.maxY)).stroke()
        pathForAxis(start: CGPoint(x: bounds.minX, y: bounds.midY + movingCenterY), end: CGPoint(x: bounds.maxX, y: bounds.midY + movingCenterY)).stroke()
        
        var scaleTo: CGFloat {
            return scale
        }
        while scalingPointX < bounds.maxX {
            pathForGraphScaleX(originPoint:  bounds.midX + scalingPointX + scaleTo).stroke()
            scalingPointX += scaleTo
        }
        scalingPointX = movingCenter.x
        
        while scalingPointXNegative > -2000 {
            pathForGraphScaleX(originPoint: bounds.midX + scalingPointXNegative - scaleTo).stroke()
            scalingPointXNegative -= scaleTo
        }
        scalingPointX = movingCenter.x
        
        while scalingPointY < bounds.maxY {
            pathForGraphScaleY(originPoint: bounds.midY + scalingPointY + scaleTo).stroke()
            scalingPointY += scaleTo
        }
        scalingPointY = movingCenter.y
        while scalingPointYNegative > -2000 {
            pathForGraphScaleY(originPoint: bounds.midY + scalingPointYNegative - scaleTo).stroke()
            scalingPointYNegative -= scaleTo
        }
        scalingPointY = movingCenter.y
        let step: CGFloat = 2
        var xBounds: CGFloat = 0
        var penDown = false
        let path = UIBezierPath()
        while xBounds < bounds.width {
            let xGraph = xToGraph(x: xBounds)
            if let yGraph = dataSource?.calculateValue(x: xGraph) {
                if yGraph.isFinite {
                let yBounds = yToBounds(y: yGraph)
                if penDown {
                    path.addLine(to: CGPoint(x: xBounds, y: yBounds))
                    
                } else {
                    path.move(to: CGPoint(x: xBounds, y: yBounds))
                    penDown = true
                }
                }
            } else {
                penDown = false
            }
            xBounds += step
            
        }
        path.stroke()
        
    }
    
    private func xToGraph(x: CGFloat) -> Double {
        let movingCenterX = movingCenter.x
        return Double((x - origin.x - movingCenterX) / scale)
    }
    
    private func yToBounds(y: Double) -> CGFloat {
        let movingCenterY = movingCenter.y
        return origin.y + movingCenterY - (CGFloat(y) * scale)
    }
    }




