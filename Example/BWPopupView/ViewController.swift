//
//  ViewController.swift
//  BWPopupView
//
//  Created by 朱旭宏 on 03/10/2022.
//  Copyright (c) 2022 朱旭宏. All rights reserved.
//

import UIKit
import BWPopupView

class ViewController: UIViewController {
    
    var popup: BWPopupController?
    var senderView: UIView?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(screenDidRotate), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    @IBAction func showPopup(_ sender: UIControl) {
        let view = UIView(frame: .init(origin: .zero, size: .init(width: 100, height: 44)))
        view.backgroundColor = .red
        
        senderView = sender
        
        popup = BWPopup.show(view: view, configure: .init(senderView: sender, backgroundColor: .red))
//        BWPopup.show(view: view, configure: .init(senderRect: sender.frame, backgroundColor: .red))
    }
    
    @IBAction func showCustom(_ sender: UIControl) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "CustomPopup")
        BWPopup.show(controller: vc, configure: .init(senderView: sender, popupSize: .init(width: 200, height: 300), blockable: false))
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    @objc private func screenDidRotate(){
        if let sender = senderView as? UIControl {
            popup?.dismiss{ [weak self] in
                self?.showPopup(sender)
            }
        }
        print(senderView?.frame)
    }
}

