//
//  Tools.swift
//  BWPopupView
//
//  Created by zhuxuhong on 2022/3/10.
//

import Foundation

extension UIApplication {
    public static var bwPopupView_appCurrentVC: UIViewController? {
        let window = shared.keyWindow ?? shared.delegate?.window ?? nil
        guard let vc = window?.rootViewController else {
            return nil
        }
        return bwPopupView_topVC(of: vc)
    }
    public static func bwPopupView_topVC(of rootVC: UIViewController) -> UIViewController {
        if let tab = rootVC as? UITabBarController,
           let vc = tab.selectedViewController  {
            return bwPopupView_topVC(of: vc)
        }
        else if let nav = rootVC as? UINavigationController,
                let vc = nav.visibleViewController {
            return bwPopupView_topVC(of: vc)
        }
        if let vc = rootVC.presentedViewController {
            return bwPopupView_topVC(of: vc)
        }
        return rootVC
    }
}

public final class BWPopupView_FilterUserInteractionView: UIView {
    public var userInteractionResponsibleViews: [UIView] = []
    public var outerAreaInteractionBlockable = true
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !userInteractionResponsibleViews.isEmpty else {
            return super.hitTest(point, with: event)
        }
        for responsibleView in userInteractionResponsibleViews {
            let newPoint = convert(point, to: responsibleView)
            if responsibleView.point(inside: newPoint, with: event) {
                return super.hitTest(point, with: event)
            }
        }
        if let vc = bwPopupView_viewController,
           let presentingVC = vc.presentingViewController {
            return presentingVC.view.hitTest(point, with: event)
        }
        return outerAreaInteractionBlockable ? super.hitTest(point, with: event) : nil
    }
}

extension UIView {
    public var bwPopupView_viewController: UIViewController? {
        var vc: UIViewController?
        var nextResponder: UIResponder? = next
        while nextResponder != nil {
            if nextResponder is UIViewController {
                vc = nextResponder as? UIViewController
                break
            }
            nextResponder = next
        }
        return vc
    }
}
