//
//  SocialLoginViewController.swift
//
//  Created by S-SAKU on 2016/11/26.
//  Copyright © 2016年 S-SAKU. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SocialLoginViewController:SocialLoginService{
    var handle: FIRAuthStateDidChangeListenerHandle?
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var txtSetFocusField:UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        txtEmail.delegate = self
        txtPassword.delegate = self
        super.delegate = self

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(SocialLoginViewController.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(SocialLoginViewController.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            guard user != nil else{
                return
            }
            if self.isStillWaitProcessing() == false{
                self.performSegue(withIdentifier: "toAccountHome",sender: nil)

            }

        }	
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    //MARK: - Event
    @IBAction func btnLogin_Tap(_ sender: Any) {
        guard let email = self.txtEmail.text, let password = self.txtPassword.text else {
            self.showAlertMsgOk(msg: "Email/Password can't be empty")
            return
        }
        if email.characters.count == 0 || password.characters.count == 0 {
            self.showAlertMsgOk(msg: "Email/Password can't be empty")
            return
        }
        login(authType: .authEmail, email: email, password: password){
            (user,error) in
            self.hideAlertWithSpin(){
                if let error = error {
                    self.showAlertMsgOk(title: "Error",msg: error.localizedDescription)
                    return
                }else{
                    self.performSegue(withIdentifier: "toAccountHome",sender: nil)
                }
            }
        }
    }

    @IBAction func btnRegister_Tap(_ sender: Any) {
        register(){
            self.showAlertMsgOk(msg:"Successfully registered")
            self.performSegue(withIdentifier: "toAccountHome",sender: nil)

        }
    }

    @IBAction func btnForgotPassword_Tap(_ sender: Any) {
        resetPassword()
    }

    @IBAction func btnLoginWithGoogle_Tap(_ sender: Any) {
        login(authType: .authGoogle){_,_ in }
    }

    //MARK: - Notification
    func keyboardWillShowNotification(_ notification: Notification) {

        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let screenSize: CGSize = UIScreen.main.bounds.size

        let txtHeight = txtSetFocusField.frame.origin.y + txtSetFocusField.frame.height + 50.0
        let keyBoardHeight = screenSize.height - keyboardScreenEndFrame.size.height


        if txtHeight >= keyBoardHeight {
            self.scrollView.contentOffset.y = txtHeight - keyBoardHeight
        }
    }

    func keyboardWillHideNotification(_ notification: Notification) {
        self.scrollView.contentOffset.y = 0
    }

    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toLogin") {
            //let loginVC = segue.destination as! LoginViewController
        }
    }

}


//MARK: - extension Delegate UITextField
extension SocialLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        txtSetFocusField = textField
        return true
    }

}

//MARK: - extension Delegate SocialLoginService
extension SocialLoginViewController: SocialLoginServiceDelegate {
    func signinCredentialFinished(user: FIRUser?, error: Error?) {
        self.hideAlertWithSpin(){
            if let error = error {
                self.showAlertMsgOk(msg: error.localizedDescription)
                return
            }else{
                self.performSegue(withIdentifier: "toAccountHome",sender: nil)
            }
        }
    }
}

