//
//  BWPopupCalculator.swift
//  BWPopupView
//
//  Created by zhuxuhong on 2022/3/10.
//

import Foundation


enum BWPopupCalculator {
}

struct BWPopupLayouts {
    var popupViewFrame: CGRect = .zero
    var popupContentViewFrame: CGRect = .zero
    var arrowViewFrame: CGRect = .zero
    var arrowViewDirection: BWArrowDirection = .any
}

extension BWPopupCalculator {
    /// Find all of `sender's` arrounded safe rects
    static func findAllSafeRectsArroundSender(
        _ senderRect: CGRect,
        safeArea: CGRect,
        margin: CGFloat
    ) -> Dictionary<BWPopupPosition, CGRect> {
        var rects: Dictionary<BWPopupPosition, CGRect> = [:]
        rects[.top] = .init(
            origin: safeArea.origin,
            size: .init(
                width: safeArea.width,
                height: senderRect.minY-safeArea.minY
            )
        ).inset(by: .init(top: 0, left: 0, bottom: margin, right: 0))
        
        rects[.bottom] = .init(
            origin: .init(x: safeArea.minX, y: senderRect.maxY),
            size: .init(
                width: safeArea.width,
                height: safeArea.maxY-senderRect.maxY
            )
        ).inset(by: .init(top: margin, left: 0, bottom: 0, right: 0))
        
        rects[.left] = .init(
            origin: safeArea.origin,
            size: .init(
                width: senderRect.minX-safeArea.minX,
                height: safeArea.height
            )
        ).inset(by: .init(top: 0, left: 0, bottom: 0, right: margin))
        
        rects[.right] = .init(
            origin: .init(x: senderRect.maxX, y: safeArea.minY),
            size: .init(
                width: safeArea.maxX-senderRect.maxX,
                height: safeArea.height
            )
        ).inset(by: .init(top: 0, left: margin, bottom: 0, right: 0))
        
        return rects.filter{ $0.value.size.width*$0.value.size.height > 0 }
    }
    
    static func calculateLayoutsBy(
        popup: BWPopup,
        safeArea: CGRect,
        view: UIView,
        popupWrapper: UIView
    ) -> BWPopupLayouts? {
        guard let senderRect = popup.senderRect else {
            return nil
        }
        var popupLayout = BWPopupLayouts()
        let position = popup.arrowDirection.toPopupPosition
        let popupCornerRadius = popup.cornerRadius
        var popupSize = popup.popupSize
        let margin = popup.margin
        
        /// 1: Find the matched safe rect from all safe rects
        let safeRects = findAllSafeRectsArroundSender(senderRect, safeArea: safeArea, margin: margin)
        var matchSafeRects: [BWPopupPosition: CGRect] = [:]
        for rect in safeRects
        {
            if (popupSize.width <= safeArea.width &&
               popupSize.height <= safeArea.height &&
               rect.value.width >= popupSize.width &&
               rect.value.height >= popupSize.height)
            ||
                (popupSize.width > safeArea.width &&
               rect.value.width >= safeArea.width &&
                 rect.value.height >= popupSize.height)
            ||
                (popupSize.height > safeArea.height &&
               rect.value.height >= safeArea.height &&
                 rect.value.width >= popupSize.width)
            {
                matchSafeRects[rect.key] = rect.value
            }
        }
        let maxSafeRect = safeRects.max(by: {
            $0.value.width*$0.value.height < $1.value.width*$1.value.height
        })
        let oneSafeRect = (
            position == .any ?
            matchSafeRects.randomElement() :
            matchSafeRects.first{ $0.key == position }
        ) ?? maxSafeRect
        
        //2
        guard let (safePosition, safeRect) = oneSafeRect else {
            return popupLayout
        }

        ///3: Update arrow frame by `safeRect`
        var arrowSize = popup.arrowSize
        var x: CGFloat = 0
        var y: CGFloat = 0
        switch safePosition {
        case .any: break
        case .bottom:
            arrowSize.width = max(popup.arrowSize.width, popup.arrowSize.height)
            arrowSize.height = min(popup.arrowSize.width, popup.arrowSize.height)
            x = senderRect.midX-arrowSize.width/2
            y = safeRect.minY
        case .right:
            arrowSize.width = min(popup.arrowSize.width, popup.arrowSize.height)
            arrowSize.height = max(popup.arrowSize.width, popup.arrowSize.height)
            x = safeRect.minX
            y = senderRect.midY-arrowSize.height/2
        case .top:
            arrowSize.width = max(popup.arrowSize.width, popup.arrowSize.height)
            arrowSize.height = min(popup.arrowSize.width, popup.arrowSize.height)
            x = senderRect.midX-arrowSize.width/2
            y = safeRect.maxY-arrowSize.height
        case .left:
            arrowSize.width = min(popup.arrowSize.width, popup.arrowSize.height)
            arrowSize.height = max(popup.arrowSize.width, popup.arrowSize.height)
            x = safeRect.maxX-arrowSize.width
            y = senderRect.midY-arrowSize.height/2
        }
        x = min(safeArea.maxX-arrowSize.width-popupCornerRadius, max(safeArea.minX+popupCornerRadius, x))
        y = min(safeArea.maxY-arrowSize.height-popupCornerRadius, max(safeArea.minY+popupCornerRadius, y))
        let arrowFrame: CGRect = .init(origin: .init(x: x, y: y), size: arrowSize)
        
        ///4: Fit popup size to `maxSafeArea`
        var top: CGFloat = 0
        var left: CGFloat = 0
        var bottom: CGFloat = 0
        var right: CGFloat = 0
        switch safePosition {
        case .any: break
        case .bottom:
            top = arrowSize.height
        case .right:
            left = arrowSize.width
        case .top:
            bottom = arrowSize.height
        case .left:
            right = arrowSize.width
        }
        let popupArea = safeRect.inset(by: .init(top: top, left: left, bottom: bottom, right: right))
        popupSize.width = min(popupArea.width, popupSize.width)
        popupSize.height = min(popupArea.height, popupSize.height)
        
        switch safePosition {
        case .any: break
        case .bottom:
            x = arrowFrame.midX - popupSize.width/2
            y = arrowFrame.maxY
        case .right:
            x = arrowFrame.maxX
            y = arrowFrame.midY - popupSize.height/2
        case .top:
            x = arrowFrame.midX - popupSize.width/2
            y = arrowFrame.minY - popupSize.height
        case .left:
            x = arrowFrame.minX - popupSize.width
            y = arrowFrame.midY - popupSize.height/2
        }
        x = min(safeArea.maxX - popupSize.width, max(safeArea.minX, x))
        y = min(safeArea.maxY - popupSize.height, max(safeArea.minY, y))
        let popupFrame = CGRect(origin: .init(x: x, y: y), size: popupSize)

        popupWrapper.frame = popupFrame.inset(by: .init(top: -top, left: -left, bottom: -bottom, right: -right))
        popupLayout.popupViewFrame = view.convert(popupFrame, to: popupWrapper)
        popupLayout.popupContentViewFrame = CGRect(origin: .zero, size: popupFrame.size).inset(by: popup.contentInsets)
        popupLayout.arrowViewFrame = view.convert(arrowFrame, to: popupWrapper)
        popupLayout.arrowViewDirection = safePosition.toArrowDirection
        
        return popupLayout
    }
}
