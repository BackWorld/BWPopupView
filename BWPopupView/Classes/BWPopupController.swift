//
//  BWPopupController.swift
//  BWPopupView
//
//  Created by zhuxuhong on 2022/3/10.
//

import UIKit

public class BWPopupController: UIViewController {
    private var safeInsets: UIEdgeInsets {
        let keywindow = UIApplication.shared.keyWindow ?? UIApplication.shared.delegate?.window ?? nil
        if #available(iOS 11.0, *) {
            return keywindow?.safeAreaInsets ?? .zero
        }
        return .zero
    }
    private var safeArea: CGRect {
        return UIScreen.main.bounds.inset(by: .init(top: safeInsets.top, left: popup.margin, bottom: safeInsets.bottom, right: popup.margin))
    }
    
    private lazy var popupView: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()
    private lazy var arrowView = BWArrowView(frame: .zero)
    private lazy var wrapperView: UIView = {
        let v = UIView(frame: .zero)
        v.clipsToBounds = true
        v.alpha = 0
        v.backgroundColor = .clear
        v.addSubview(popupView)
        v.addSubview(arrowView)
        return v
    }()
    
    private var originalContentFrame: CGRect!
    public var contentView: UIView?
    public lazy var popup = BWPopup()
    
    public init(popup: BWPopup, contentView: UIView){
        super.init(nibName: nil, bundle: nil)
        self.popup = popup
        self.contentView = contentView
        self.originalContentFrame = contentView.frame
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func loadView() {
        self.view = BWPopupView_FilterUserInteractionView(frame: UIScreen.main.bounds)
    }
    
    public override func viewWillLayoutSubviews() {
        view.frame = UIScreen.main.bounds
        
        super.viewWillLayoutSubviews()
    }
    
    private var filterView: BWPopupView_FilterUserInteractionView? {
        return view as? BWPopupView_FilterUserInteractionView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContentView()
        
        setupPopupView()
    }
    
    private var convertedSenderRect: CGRect? {
        let superview = popup.senderView?.superview ?? UIApplication.shared.keyWindow ?? UIApplication.shared.delegate?.window ?? nil
        guard let superview = superview,
              let rect = popup.senderRect else{
            return nil
        }
        let selfRect = superview.convert(rect, to: view)
        return selfRect
    }
    
    private func setupContentView(){
        if let view = contentView {
            popupView.addSubview(view)
        }
        if let size = contentView?.bounds.size, size != .zero, popup.popupSize == .zero {
            popup.popupSize = size
        }
    }
    
    private func setupPopupView(){
        guard popup.senderRect != nil else {
            return
        }
        view.isMultipleTouchEnabled = false
        view.backgroundColor = popup.maskColor
        
        view.addSubview(wrapperView)
        popupView.backgroundColor = popup.backgroundColor
        arrowView.color = popup.backgroundColor
        popupView.layer.cornerRadius = popup.cornerRadius
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        filterView?.outerAreaInteractionBlockable = popup.blockable
        if !popup.blockable {
            filterView?.userInteractionResponsibleViews.append(wrapperView)
        }
        
        updateLayouts()
    }
    
    private func updatePopupLayouts() {
        guard let rect = convertedSenderRect else {
            return
        }
        popup.senderRect = rect
        
        guard
            let layouts = BWPopupCalculator.calculateLayoutsBy(popup: popup, safeArea: safeArea, view: view, popupWrapper: wrapperView) else {
            return
        }
        popupView.frame = layouts.popupViewFrame
        arrowView.frame = layouts.arrowViewFrame
        contentView?.frame = layouts.popupContentViewFrame
        arrowView.direction = layouts.arrowViewDirection
    }
    
    private var isAnimating = false
    private func animatePopupView(isIn: Bool = true, completion: ((Bool)->Void)? = nil){
        guard !isAnimating else {
            return
        }
        let fromAlpha: CGFloat = isIn ? 0 : 1
        wrapperView.alpha = fromAlpha
        let origin = wrapperView.frame.origin
        wrapperView.layer.anchorPoint = popupAnimateAnchorPoint
        wrapperView.frame.origin = origin
        let fromScale: CGFloat = isIn ? 0.85 : 1
        let toScale: CGFloat = isIn ? 1 : 0.85
        let toAlpha: CGFloat = isIn ? 1 : 0
        let spring: CGFloat = isIn ? 0.5 : 1
        let duration: CGFloat = isIn ? 0.65 : 0.25
        wrapperView.layer.transform = CATransform3DMakeScale(fromScale, fromScale, 1)
        isAnimating = true
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: spring,
            initialSpringVelocity: 1,
            options: [.curveEaseInOut],
            animations: {
                self.wrapperView.layer.transform = CATransform3DMakeScale(toScale, toScale, 1)
                self.wrapperView.alpha = toAlpha
            },
            completion: { [weak self] in
                self?.isAnimating = false
                completion?($0)
            }
        )
    }
    
    private var popupAnimateAnchorPoint: CGPoint {
        let x = min(1, max(0, arrowView.frame.midX/popupView.frame.width))
        let y = min(1, max(0, arrowView.frame.midY/popupView.frame.height))
        return .init(x: x, y: y)
    }
    
    public func show(controller: UIViewController, at holder: UIViewController) {
        show(at: holder)
        
        addChild(controller)
        controller.didMove(toParent: self)
    }
    
    public func show(at holder: UIViewController) {
        modalPresentationStyle = .overCurrentContext
        holder.present(self, animated: false, completion: nil)
    }
    
    public func updateLayouts(senderRect: CGRect? = nil){
        if let rect = senderRect {
            popup.senderRect = rect
        }
        
        updatePopupLayouts()
        
        animatePopupView()
    }
    
    public func dismiss(completion: (()->Void)? = nil) {
        animatePopupView(isIn: false) { [weak self] in
            guard $0, let self = self else {
                return
            }
            self.contentView?.frame = self.originalContentFrame
            self.dismiss(animated: false, completion: completion)
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard popup.blockable else {
            return
        }
        guard let location = touches.first?.location(in: view) else {
            return
        }
        let point = view.convert(location, to: wrapperView)
        if wrapperView.point(inside: point, with: event) {
            return
        }
        dismiss()
    }
}

