//
//  BWArrowView.swift
//  BWPopupView
//
//  Created by zhuxuhong on 2022/3/10.
//

import UIKit

class BWArrowView: UIView {
    var direction: BWArrowDirection = .any {
        didSet{
            setNeedsDisplay()
        }
    }
    var color: UIColor = .black {
        didSet{
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        let arrowRect = rect
        let path = UIBezierPath()
        switch direction {
        case .any: return
        case .down:
            path.move(to: .init(x: arrowRect.minX, y: arrowRect.minY))
            path.addLine(to: .init(x: arrowRect.midX, y: arrowRect.maxY))
            path.addLine(to: .init(x: arrowRect.maxX, y: arrowRect.minY))
        case .right:
            path.move(to: .init(x: arrowRect.minX, y: arrowRect.minY))
            path.addLine(to: .init(x: arrowRect.maxX, y: arrowRect.midY))
            path.addLine(to: .init(x: arrowRect.minX, y: arrowRect.maxY))
        case .up:
            path.move(to: .init(x: arrowRect.midX, y: arrowRect.minY))
            path.addLine(to: .init(x: arrowRect.minX, y: arrowRect.maxY))
            path.addLine(to: .init(x: arrowRect.maxX, y: arrowRect.maxY))
        case .left:
            path.move(to: .init(x: arrowRect.minX, y: arrowRect.midY))
            path.addLine(to: .init(x: arrowRect.maxX, y: arrowRect.maxY))
            path.addLine(to: .init(x: arrowRect.maxX, y: arrowRect.minY))
        }
        path.close()
        ctx.setFillColor(color.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

