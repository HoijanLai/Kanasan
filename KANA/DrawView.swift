//
//  DrawView.swift
//  KANA
//
//  Created by Hoijan Lai on 01/02/2018.
//  Copyright © 2018 Hoijan Lai. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var isDrawing = false
    var strokeColor = UIColor.black.cgColor // TODO: changable color
    var lastPosition : CGPoint!
    var gestures = [[Stroke]]()
    var strokes = [Stroke]()
    
    
    
    
    /*
     Logics for drawing
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isDrawing else { return }
        isDrawing = true
        
        guard let touch = touches.first else { return }
        lastPosition = touch.location(in: self)
        // print(lastPosition)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawing else { return }
        guard let touch = touches.first else { return }
        let currentPosition = touch.location(in: self)
        // print(currentPosition)
        
        strokes.append(Stroke(color:strokeColor, start:lastPosition, end:currentPosition))
        lastPosition = currentPosition
        
        setNeedsDisplay()
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawing else { return }
        isDrawing = false
        
        guard let touch = touches.first else { return }
        let currentPosition = touch.location(in: self)
        // print(currentPosition)
        
        strokes.append(Stroke(color:strokeColor, start:lastPosition, end:currentPosition))
        gestures.append(strokes)
        strokes = []
        
        setNeedsDisplay()
        lastPosition = nil
        
    }
    
    override func draw(_ rect: CGRect) {
        /*
         this is required when you want to draw something on view
        */
        let userContext = UIGraphicsGetCurrentContext()
        userContext?.setLineWidth(30) // TODO : changable stroke width
        userContext?.setLineCap(.round)
        drawStrokes(strokes: strokes, context: userContext)
        for _strokes in gestures {
            drawStrokes(strokes: _strokes, context: userContext)
        }
        
    }
    
    private func drawStrokes(strokes: [Stroke], context: CGContext?) {
        /*
         this is how strokes are drawn on context
        */
        for stroke in strokes {
            context?.beginPath()
            context?.move(to: stroke.start)
            context?.addLine(to: stroke.end)
            context?.setStrokeColor(strokeColor)
            context?.strokePath()
        }
    }
    
    
    func erase() {
        gestures = []
        setNeedsDisplay()
    }
    
    func undo() {
        if !gestures.isEmpty {
            gestures.removeLast()
        }
        setNeedsDisplay()
    }
    

}
