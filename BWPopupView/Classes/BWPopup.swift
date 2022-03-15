//
//  BWPopup.swift
//  BWPopupView
//
//  Created by zhuxuhong on 2022/3/10.
//

import Foundation

public enum BWArrowDirection: Int {
    case any = 0
    case left,up,right,down
}

enum BWPopupPosition: Int {
    case any = 0
    case right,bottom,left,top
}

public class BWPopup {
    public var senderRect: CGRect?
    public var senderView: UIView?
    public var margin: CGFloat
    public var contentInsets: UIEdgeInsets
    public var backgroundColor: UIColor
    public var maskColor: UIColor
    public var blockable: Bool
    public var cornerRadius: CGFloat
    public var popupSize: CGSize
    public var arrowSize: CGSize
    public var arrowDirection: BWArrowDirection
    
    public convenience init(senderRect: CGRect){
        self.init(senderRect: senderRect, senderView: nil)
    }
    public convenience init(senderView: UIView){
        self.init(senderRect: nil, senderView: senderView)
    }
    
    public init(
        senderRect: CGRect? = nil,
        senderView: UIView? = nil,
        popupSize: CGSize = .zero,
        arrowDirection: BWArrowDirection = .any,
        backgroundColor: UIColor = .black,
        margin: CGFloat = 10,
        contentInsets: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10),
        blockable: Bool = true,
        maskColor: UIColor = .clear,
        cornerRadius: CGFloat = 10,
        arrowSize: CGSize = .init(width: 12, height: 12)
    ) {
        self.backgroundColor = backgroundColor
        self.blockable = blockable
        self.maskColor = maskColor
        self.senderRect = senderRect ?? senderView?.frame
        self.senderView = senderView
        self.arrowDirection = arrowDirection
        self.margin = margin
        self.contentInsets = contentInsets
        self.cornerRadius = cornerRadius
        self.popupSize = popupSize
        let value = max(arrowSize.width, arrowSize.height) + cornerRadius
        self.arrowSize = .init(width: value, height: value*0.6)
    }
}

extension BWPopup {
    public static func dismiss(_ popupVC: BWPopupController, completion: (()->Void)? = nil){
        popupVC.dismiss(completion: completion)
    }
    
    @discardableResult
    public static func show(
        view: UIView,
        configure: BWPopup,
        for holder: UIViewController? = UIApplication.bwPopupView_appCurrentVC
    ) -> BWPopupController? {
        guard let holder = holder else {
            fatalError("Must has a root view controller for current application!")
        }
        
        let popupVC = BWPopupController(popup: configure, contentView: view)
        popupVC.show(at: holder)
        
        weak var weakVC = popupVC
        return weakVC
    }
    
    @discardableResult
    public static func show(
        controller: UIViewController,
        configure: BWPopup,
        for holder: UIViewController? = UIApplication.bwPopupView_appCurrentVC
    ) -> BWPopupController?  {
        guard let holder = holder else {
            fatalError("Must has a root view controller for current application!")
        }
        let popupVC = BWPopupController(popup: configure, contentView: controller.view)
        popupVC.show(controller: controller, at: holder)
        
        weak var weakVC = popupVC
        return weakVC
    }
}

extension BWPopupPosition {
    var toArrowDirection: BWArrowDirection {
        switch self {
        case .any: return .any
        case .bottom: return .up
        case .right: return .left
        case .top: return .down
        case .left: return .right
        }
    }
}

extension BWArrowDirection {
    var toPopupPosition: BWPopupPosition {
        switch self {
        case .any: return .any
        case .left: return .right
        case .up: return .bottom
        case .right: return .left
        case .down: return .top
        }
    }
}
