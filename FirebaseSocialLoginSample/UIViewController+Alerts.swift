//
//  UIViewController+Alerts.swift
//  FirebaseSocialLoginSample
//
//  Created by S-SAKU on 2016/11/26.
//  Copyright © 2016年 S-SAKU. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

extension UIViewController {
    static let kWaitAssociatedObjectKey = "UIViewControllerAlert_WaitScreenAssociatedObject"

    func showAlertWithSpin(_titile:String="",_msg:String="Please Wait...\n\n\n\n",completion: (()->Void)?){

        var waitAlert:UIAlertController? = objc_getAssociatedObject(self, UIViewController.kWaitAssociatedObjectKey) as? UIAlertController

        if waitAlert != nil {
            if ((completion) != nil) {
                completion!();
            }
            return
        }

        waitAlert = UIAlertController(title: _titile, message: _msg, preferredStyle: .alert)

        let spinView: UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle:.whiteLarge)

        spinView.color = UIColor.black
        spinView.center = CGPoint.init(x: (waitAlert?.view.bounds.size.width)!/2, y:(waitAlert?.view.bounds.size.height)!/2)

        spinView.autoresizingMask = [.flexibleBottomMargin , .flexibleTopMargin , .flexibleLeftMargin , .flexibleRightMargin]

        spinView.startAnimating()
        waitAlert?.view.addSubview(spinView)


        objc_setAssociatedObject(self, UIViewController.kWaitAssociatedObjectKey, waitAlert, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        self.present(waitAlert!, animated: true, completion: completion)

    }

    func hideAlertWithSpin(completion: (()->Void)?){
        let waitAlert:UIAlertController? = objc_getAssociatedObject(self, UIViewController.kWaitAssociatedObjectKey) as? UIAlertController

        waitAlert?.dismiss(animated: true, completion:completion)

        objc_setAssociatedObject(self, UIViewController.kWaitAssociatedObjectKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        self.dismiss(animated: true, completion: completion)

    }

    func showAlertMsgOk(title:String="",msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        let okAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
        
    }

    func showAlertMsgOkCancel(title:String="",msg:String,completion: ((Bool)->Void)?){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        let okAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            completion!(true)

        })
        alert.addAction(okAction)
        let cancelAction: UIAlertAction = UIAlertAction.init(title: "CANCEL", style: .cancel,
                                                             handler: { (action: UIAlertAction) in
                                                                completion!(false)
                                                                
        })
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)

    }

    func showAlertInput(title:String="",msg:String,secureTextEntry:Bool=false,completion: ((Bool,String?)->Void)?){
        let alert: UIAlertController = UIAlertController(title: title, message: msg, preferredStyle:.alert)


        weak var weakAlertCon: UIAlertController? = alert

        let cancelAction: UIAlertAction = UIAlertAction.init(title: "CANCEL", style: .cancel,
                                                                        handler: { (action: UIAlertAction) in
            completion!(false, nil)

        })
        let okAction: UIAlertAction = UIAlertAction.init(title: "OK", style: .default, handler: { (action: UIAlertAction) in
            let strongAlertCon: UIAlertController = weakAlertCon!
            completion!(true, strongAlertCon.textFields?[0].text)

        })
        alert.addTextField(configurationHandler: nil)
        alert.textFields?[0].isSecureTextEntry = secureTextEntry
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)

    }

    func isStillWaitProcessing()->Bool{
        guard let preVC = self.presentedViewController else {
            return false
        }

        guard let preVC2:UIViewController = preVC as UIViewController? else{
            return false
        }

        if let _: UIAlertController = preVC2 as? UIAlertController {
            return true
        }

        if let preNav = preVC2 as? UINavigationController{
            if (preNav.visibleViewController?.isKind(of: UIAlertController.self))! {
                return true
            }
        }
        return false

    }

}

