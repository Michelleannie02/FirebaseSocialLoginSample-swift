//
//  SocialLoginService.swift
//
//  Created by S-SAKU on 2016/11/26.
//  Copyright © 2016年 S-SAKU. All rights reserved.
//


import UIKit
import Firebase
import GoogleSignIn

public protocol SocialLoginProtocol {
    func login(authType:AuthProvider,email:String?,password:String?,loginCallBack:@escaping FirebaseAuth.FIRAuthResultCallback)
    func register(successfulCompletion:@escaping ()->Void)
    func resetPassword()
}


@objc protocol SocialLoginServiceDelegate{
    @objc optional func signinCredentialFinished(user:FIRUser?, error:Error?)
}


public enum AuthProvider {
    case authEmail
    case authGoogle
}


public class SocialLoginService:UIViewController, SocialLoginProtocol,GIDSignInDelegate, GIDSignInUIDelegate{

    var delegate: SocialLoginServiceDelegate! = nil

    public func login(authType:AuthProvider,email:String? = nil,password:String? = nil,loginCallBack:@escaping FirebaseAuth.FIRAuthResultCallback) {
        switch authType {
        case .authEmail:
            showAlertWithSpin(){
                FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
                    loginCallBack(user,error)
                }
            }
        case .authGoogle:
            GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().signIn()
        //default:break
        }
    }

    public func register(successfulCompletion:@escaping ()->Void) {
        showAlertInput(msg: "Enter email for registration") { (userPressedOK, _email) in
            guard userPressedOK else{
                return
            }
            if let email = _email , _email != "" {
                self.showAlertInput(msg: "Enter passward for registration",secureTextEntry: true) { (userPressedOK, _password) in
                    if let password = _password ,_password != ""{
                        self.showAlertWithSpin(){
                            FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                                self.hideAlertWithSpin(){
                                    if let error = error {
                                        self.showAlertMsgOk(title: "Error",msg:error.localizedDescription)
                                        return
                                    }
                                    print("\(user!.email!) created")
                                    successfulCompletion()
                                }
                            }

                        }
                    }else{
                        self.showAlertMsgOk(title: "Error",msg:"Passward can't be empty")
                    }
                }
            }else{
                self.showAlertMsgOk(title: "Error",msg:"Email can't be empty")
            }
        }
    }

    public func resetPassword(){
        showAlertInput(msg: "Enter email to reset password") { (userPressedOK, _email) in
            guard userPressedOK else{
                return
            }
            if let email = _email , _email != "" {
                self.showAlertWithSpin(){
                    FIRAuth.auth()?.sendPasswordReset(withEmail: email) { (error) in
                        self.hideAlertWithSpin(){
                            if let error = error {
                                self.showAlertMsgOk(title: "Error",msg:error.localizedDescription)
                                return
                            }
                            self.showAlertMsgOk(msg:"Please confirm email about password reset")
                        }
                    }
                }
            }else{
                self.showAlertMsgOk(title: "Error",msg:"Email can't be empty")
            }
        }
    }

    public func logout(successfulCompletion:@escaping ()->Void) {
        showAlertMsgOkCancel(msg: "Are you sure you want to log out?") { (userOK) in
            if userOK == true {
                self.showAlertWithSpin(){
                    let firebaseAuth = FIRAuth.auth()
                    do {
                        try
                            firebaseAuth?.signOut()
                        GIDSignIn.sharedInstance().signOut()

                    } catch let error as NSError {
                        self.hideAlertWithSpin(){
                            self.showAlertMsgOk(title: "Error",msg:error.localizedDescription)
                        }
                    }
                    return
                }

                self.hideAlertWithSpin(){
                    successfulCompletion()
                }
            }
        }
    }

    //MARK: - Delegate GIDSignIn
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            self.showAlertMsgOk(msg: error.localizedDescription)
            return
        }

        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        firebaseLogin(credential)
    }

    //MARK: - Function
    func firebaseLogin(_ credential: FIRAuthCredential) {
        showAlertWithSpin(){

            if let user = FIRAuth.auth()?.currentUser {

                user.link(with: credential) { (user, error) in
                    self.delegate.signinCredentialFinished!(user: user, error: error)
                }

            } else {
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    self.delegate.signinCredentialFinished!(user: user, error: error)
                }
            }
        }
    }
}

