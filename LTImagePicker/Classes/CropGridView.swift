//
//  CropGridView.swift
//  LTImagePicker
//
//  Created by Lorenzo Toscani De Col on 30/01/2019.
//

import UIKit

protocol CropGridViewDelegate: class {
    func gridDidLayoutSubviews(animated: Bool, finalAspectFrame: CGRect?)
}

class CropGridView: UIView {
    
    private var verticalLine1: CAShapeLayer?
    private var verticalLine2: CAShapeLayer?
    private var horizontalLine1: CAShapeLayer?
    private var horizontalLine2: CAShapeLayer?
    
    private let minimumSize = CGSize(width: 120, height: 120)
    private var safeAreaFrame: CGRect {
        return UIScreen.main.bounds
    }
    
    var activeTouchPoint: TouchPoint?
    var isCropping: Bool {
        return superview != nil
    }
    private(set) var aspectRatio: AspectRatio
    
    weak var delegate: CropGridViewDelegate?
    
    init(initialRatio: AspectRatio = .freeform) {
        aspectRatio = initialRatio
        super.init(frame: CropGridView.calculateFrameForAspectRatio(initialRatio, inset: 20))
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        createGridLinesIfNeeded()
        resizeGridLines()
    }
    
    func setAspectToFreeform() {
        aspectRatio = .freeform
    }
    func setAspectRatio(to ratio: AspectRatio, inset: CGFloat, animated: Bool = true) {
        aspectRatio = ratio
        let finalFrame = CropGridView.calculateFrameForAspectRatio(aspectRatio, inset: aspectRatio.defaultInset)
        
        if animated {
            let lines = [verticalLine1, verticalLine2, horizontalLine1, horizontalLine2]
            lines.forEach({ $0?.isHidden = true })
            
            delegate?.gridDidLayoutSubviews(animated: true, finalAspectFrame: finalFrame)
            UIView.animate(withDuration: 0.2, animations: {
                self.frame = finalFrame
            }, completion: { _ in
                lines.forEach({ $0?.isHidden = false })
            })
        } else {
            frame = finalFrame
            delegate?.gridDidLayoutSubviews(animated: false, finalAspectFrame: finalFrame)
        }
    }
    private static func calculateFrameForAspectRatio(_ ratio: AspectRatio, inset: CGFloat) -> CGRect {
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown:
            let xInset: CGFloat = inset
            let yInset: CGFloat = (UIScreen.main.bounds.height - (UIScreen.main.bounds.width - (xInset * 2)) * ratio.value) / 2
            let size = UIScreen.main.bounds.insetBy(dx: xInset, dy: yInset)
            return CGRect(x: xInset, y: yInset, width: size.width, height: size.height)
        default:
            let yInset: CGFloat = inset
            let xInset: CGFloat = (UIScreen.main.bounds.width - (UIScreen.main.bounds.height - (yInset * 2)) * ratio.value) / 2
            let size = UIScreen.main.bounds.insetBy(dx: xInset, dy: yInset)
            return CGRect(x: xInset, y: yInset, width: size.width, height: size.height)
        }
        
    }
    
    private func createGridLinesIfNeeded() {
        guard   verticalLine1 == nil,
            verticalLine2 == nil,
            horizontalLine1 == nil,
            horizontalLine2 == nil else { return }
        
        for i in 1...2 {
            let pathVertical = UIBezierPath()
            pathVertical.move(to: CGPoint(x: bounds.maxX * CGFloat(i/3), y: bounds.minY))
            pathVertical.addLine(to: CGPoint(x: bounds.maxX * CGFloat(i/3), y: bounds.maxY))
            
            let pathHorizontal = UIBezierPath()
            pathHorizontal.move(to: CGPoint(x: bounds.minX, y: bounds.maxY * CGFloat(i/3)))
            pathHorizontal.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY * CGFloat(i/3)))
            
            if i == 1 {
                verticalLine1 = CAShapeLayer()
                verticalLine1?.path = pathVertical.cgPath
                horizontalLine1 = CAShapeLayer()
                horizontalLine1?.path = pathHorizontal.cgPath
            } else {
                verticalLine2 = CAShapeLayer()
                verticalLine2?.path = pathVertical.cgPath
                horizontalLine2 = CAShapeLayer()
                horizontalLine2?.path = pathHorizontal.cgPath
            }
        }
        
        [verticalLine1, verticalLine2, horizontalLine1, horizontalLine2].forEach { line in
            line?.lineWidth = 1
            line?.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
            if let line = line {
                self.layer.addSublayer(line)
            }
        }
    }
    
    private func resizeGridLines() {
        guard   let verticalLine1 = verticalLine1,
            let verticalLine2 = verticalLine2,
            let horizontalLine1 = horizontalLine1,
            let horizontalLine2 = horizontalLine2
            else { return }
        
        let pathVertical1 = UIBezierPath()
        pathVertical1.move(to: CGPoint(x: bounds.maxX * (1/3), y: bounds.minY))
        pathVertical1.addLine(to: CGPoint(x: bounds.maxX * (1/3), y: bounds.maxY))
        verticalLine1.path = pathVertical1.cgPath
        
        let pathVertical2 = UIBezierPath()
        pathVertical2.move(to: CGPoint(x: bounds.maxX * (2/3), y: bounds.minY))
        pathVertical2.addLine(to: CGPoint(x: bounds.maxX * (2/3), y: bounds.maxY))
        verticalLine2.path = pathVertical2.cgPath
        
        let pathHorizontal1 = UIBezierPath()
        pathHorizontal1.move(to: CGPoint(x: bounds.minX, y: bounds.maxY * (1/3)))
        pathHorizontal1.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY * (1/3)))
        horizontalLine1.path = pathHorizontal1.cgPath
        
        let pathHorizontal2 = UIBezierPath()
        pathHorizontal2.move(to: CGPoint(x: bounds.minX, y: bounds.maxY * (2/3)))
        pathHorizontal2.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY * (2/3)))
        horizontalLine2.path = pathHorizontal2.cgPath
    }
    
    func rotateIfPossible(completion: (Bool) -> Void) {
        let currentFrame = frame
        let newOrigin = CGPoint(x: center.x - (currentFrame.height/2),
                                y: center.y - (currentFrame.width/2))
        let newFrame = CGRect(origin: newOrigin, size: CGSize(width: currentFrame.height, height: currentFrame.width))
        if safeAreaFrame.contains(newFrame) {
            delegate?.gridDidLayoutSubviews(animated: true, finalAspectFrame: newFrame)
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = self.transform.rotated(by: .pi/2)
            }, completion: {_ in
                self.transform = .identity
                self.frame = newFrame
            })
            completion(true)
        } else {
            completion(false)
        }
    }
    
    // MARK: - Handle touch and frame changes
    func touchPoint(for touch: UITouch) -> TouchPoint? {
        let point = touch.location(in: self)
        let touchPoint = TouchPoint.allCases.first(where: { $0.frameForTouchPoint(in: self).contains(point) })
        return touchPoint
    }
    
    func handleTouchMovement(for touch: UITouch) {
        let currentLocation = touch.preciseLocation(in: self)
        let previousLocation = touch.precisePreviousLocation(in: self)
        
        guard let activeTouchPoint = activeTouchPoint else { return }
        let currentFrame = self.frame
        let movement = CGPoint(x: currentLocation.x - previousLocation.x, y: currentLocation.y - previousLocation.y)
        
        var newFrame: CGRect
        switch activeTouchPoint {
        case .insideView:
            newFrame = CGRect(x: currentFrame.minX + movement.x,
                              y: currentFrame.minY + movement.y,
                              width: currentFrame.width,
                              height: currentFrame.height)
        default:
            switch aspectRatio {
            case .freeform:
                newFrame = freeformFrame(startingFrom: currentFrame, movement: movement, touchPoint: activeTouchPoint)
            default:
                newFrame = aspectFrame(startingFrom: currentFrame, movement: movement, touchPoint: activeTouchPoint)
            }
        }
        
        if safeAreaFrame.contains(newFrame) {
            self.frame = frameSatisfyingConstraints(currentFrame: currentFrame, newFrame: newFrame)
            delegate?.gridDidLayoutSubviews(animated: false, finalAspectFrame: nil)
        }
    }
    
    private func freeformFrame(startingFrom currentFrame: CGRect, movement: CGPoint, touchPoint: TouchPoint) -> CGRect {
        switch touchPoint {
        case .topSide:
            return CGRect(x: currentFrame.minX,
                          y: currentFrame.minY + movement.y,
                          width: currentFrame.width,
                          height: currentFrame.height - movement.y)
        case .bottomSide:
            return CGRect(x: currentFrame.minX,
                          y: currentFrame.minY,
                          width: currentFrame.width,
                          height: currentFrame.height + movement.y)
        case .leftSide:
            return CGRect(x: currentFrame.minX + movement.x,
                          y: currentFrame.minY,
                          width: currentFrame.width - movement.x,
                          height: currentFrame.height)
        case .rightSide:
            return CGRect(x: currentFrame.minX,
                          y: currentFrame.minY,
                          width: currentFrame.width + movement.x,
                          height: currentFrame.height)
        case .topLeftCorner:
            return CGRect(x: currentFrame.minX + movement.x,
                          y: currentFrame.minY + movement.y,
                          width: currentFrame.width - movement.x,
                          height: currentFrame.height - movement.y)
        case .topRightCorner:
            return CGRect(x: currentFrame.minX,
                          y: currentFrame.minY + movement.y,
                          width: currentFrame.width + movement.x,
                          height: currentFrame.height - movement.y)
        case .bottomLeftCorner:
            return CGRect(x: currentFrame.minX + movement.x,
                          y: currentFrame.minY,
                          width: currentFrame.width - movement.x,
                          height: currentFrame.height + movement.y)
        case .bottomRightCorner:
            return CGRect(x: currentFrame.minX,
                          y: currentFrame.minY,
                          width: currentFrame.width + movement.x,
                          height: currentFrame.height + movement.y)
        case .insideView: return .zero
        }
    }
    
    private func aspectFrame(startingFrom currentFrame: CGRect, movement: CGPoint, touchPoint: TouchPoint) -> CGRect {
        var distance: CGFloat
        switch touchPoint {
        case .bottomLeftCorner:
            distance = max(movement.x, -movement.y)
        case .bottomRightCorner:
            distance = max(-movement.x, -movement.y)
        case .topLeftCorner:
            distance = max(movement.x, movement.y)
        case .topRightCorner:
            distance = max(-movement.x, movement.y)
        case .topSide:
            distance = movement.y
        case .bottomSide:
            distance = -movement.y
        case .leftSide:
            distance = movement.x
        case .rightSide:
            distance = -movement.x
        case .insideView:
            distance = 0
        }
        let maxSide = max(currentFrame.width, currentFrame.height)
        let scaleFactor = 1 - (distance / maxSide)
        let scaledSize = frame.size.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        
        let sizeDiff = CGSize(width: frame.width - scaledSize.width, height: frame.height - scaledSize.height)
        var scaledOrigin: CGPoint
        switch touchPoint {
        case .bottomLeftCorner:
            scaledOrigin = frame.origin.applying(CGAffineTransform(translationX: sizeDiff.width, y: 0))
        case .bottomRightCorner:
            scaledOrigin = frame.origin.applying(CGAffineTransform(translationX: 0, y: 0))
        case .topLeftCorner:
            scaledOrigin = frame.origin.applying(CGAffineTransform(translationX: sizeDiff.width, y: sizeDiff.height))
        case .topRightCorner:
            scaledOrigin = frame.origin.applying(CGAffineTransform(translationX: 0, y: sizeDiff.height))
        case .topSide:
            scaledOrigin = frame.origin.applying(CGAffineTransform(translationX: sizeDiff.width / 2, y: sizeDiff.height))
        case .bottomSide:
            scaledOrigin = frame.origin.applying(CGAffineTransform(translationX: sizeDiff.width / 2, y: 0))
        case .leftSide:
            scaledOrigin = frame.origin.applying(CGAffineTransform(translationX: sizeDiff.width, y: sizeDiff.height / 2))
        case .rightSide:
            scaledOrigin = frame.origin.applying(CGAffineTransform(translationX: 0, y: sizeDiff.height / 2))
        case .insideView:
            scaledOrigin = .zero
        }
        return CGRect(origin: scaledOrigin, size: scaledSize)
    }
    
    private func frameSatisfyingConstraints(currentFrame: CGRect, newFrame: CGRect) -> CGRect {
        // Size is bigger than minimumSize
        if newFrame.width >= minimumSize.width && newFrame.height >= minimumSize.height {
            return newFrame
        } else {
            if newFrame.width < minimumSize.width {
                return CGRect(origin: currentFrame.origin, size: CGSize(width: minimumSize.width, height: currentFrame.height))
            } else if newFrame.height < minimumSize.height {
                return CGRect(origin: currentFrame.origin, size: CGSize(width: currentFrame.width, height: minimumSize.height))
            }
            return .zero
        }
    }
}

// MARK: -
extension CropGridView {
    enum TouchPoint: CaseIterable {
        // Sides
        case topSide
        case leftSide
        case rightSide
        case bottomSide
        // Corners
        case topLeftCorner
        case topRightCorner
        case bottomLeftCorner
        case bottomRightCorner
        // View itself
        case insideView
        
        func frameForTouchPoint(in view: UIView) -> CGRect {
            let cornerInset: CGFloat = 30
            let outsideMargin: CGFloat = 15
            switch self {
            case .topSide:
                return CGRect(x: cornerInset, y: -outsideMargin, width: view.bounds.width - (2 * cornerInset), height: 2 * outsideMargin)
            case .leftSide:
                return CGRect(x: -outsideMargin, y: cornerInset, width: 2 * outsideMargin, height: view.bounds.height - (2 * cornerInset))
            case .rightSide:
                return CGRect(x: view.bounds.width - outsideMargin, y: cornerInset, width: 2 * outsideMargin, height: view.bounds.height - (2 * cornerInset))
            case .bottomSide:
                return CGRect(x: cornerInset, y: view.bounds.height - outsideMargin, width: view.bounds.width - (2 * cornerInset), height: 2 * outsideMargin)
            case .topLeftCorner:
                return CGRect(x: -outsideMargin, y: -outsideMargin, width: cornerInset + outsideMargin, height: cornerInset + outsideMargin)
            case .topRightCorner:
                return CGRect(x: view.bounds.width - cornerInset, y: -outsideMargin, width: cornerInset + outsideMargin, height: cornerInset + outsideMargin)
            case .bottomLeftCorner:
                return CGRect(x: -outsideMargin, y: view.bounds.height - cornerInset, width: cornerInset + outsideMargin, height: cornerInset + outsideMargin)
            case .bottomRightCorner:
                return CGRect(x: view.bounds.width - cornerInset, y: view.bounds.height - cornerInset, width: cornerInset + outsideMargin, height: cornerInset + outsideMargin)
            case .insideView:
                return CGRect(x: cornerInset, y: cornerInset, width: view.bounds.width - (cornerInset * 2), height: view.bounds.height - (cornerInset * 2))
            }
        }
    }
    
    enum AspectRatio: CaseIterable {
        case freeform
        case fourByThree
        case sixteenByNine
        case twoByThree
        case square
        
        var value: CGFloat {
            switch self {
            case .fourByThree, .freeform:
                return 4/3
            case .sixteenByNine:
                return 16/9
            case .twoByThree:
                return 2/3
            case .square:
                return 1
            }
        }
        
        var title: String {
            switch self {
            case .fourByThree: return "4/3"
            case .freeform: return "Freeform"
            case .sixteenByNine: return "16/9"
            case .twoByThree: return "2/3"
            case .square: return "Square"
            }
        }
        
        var defaultInset: CGFloat {
            switch self {
            case .fourByThree,
                 .freeform,
                 .twoByThree,
                 .square: return 20
            case .sixteenByNine: return 50
            }
        }
    }
}
