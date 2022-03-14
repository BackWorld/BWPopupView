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
    @IBAction func showPopup(_ sender: UIControl) {
        let view = UIView(frame: .init(origin: .zero, size: .init(width: 100, height: 44)))
        view.backgroundColor = .red
        
        BWPopup.show(view: view, configure: .init(senderView: sender, backgroundColor: .red))
//        BWPopup.show(view: view, configure: .init(senderRect: view.frame, backgroundColor: .red))
    }
    
    @IBAction func showCustom(_ sender: UIControl) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "CustomPopup")
        BWPopup.show(controller: vc, configure: .init(senderView: sender, popupSize: .init(width: 200, height: 300), blockable: false))
    }
}

