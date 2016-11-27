//
//  AccountHomeViewController.swift
//  FirebaseSocialLoginSample
//
//  Created by S-SAKU on 2016/11/26.
//  Copyright © 2016年 S-SAKU. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class AccountHomeViewController: SocialLoginService {

    @IBOutlet weak var tableView: UITableView!
    let SECTION_IDX_PROFILE = 0
    let SECTION_IDX_PROVIDERS = 1
    var arySection:[(title:String,rcnt:Int)] = [("",1),("Linked Providers",0)]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Event
    @IBAction func btnDispNameEdit_Tap(_ sender: Any) {
        showAlertInput(title:"Edit AppDispName",msg: "Set App Display Name") { (userPressedOK, input) in
            guard let userInput = input else{
                return
            }
            if userInput == ""{
                self.showAlertMsgOk(msg:"App Display Name can't be empty")
            }else{
                self.showAlertWithSpin(){
                    let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                    changeRequest?.displayName = userInput

                    changeRequest?.commitChanges(){ (error) in
                        self.hideAlertWithSpin(){

                            if let err = error {
                                self.showAlertMsgOk(title: "Error",msg: err.localizedDescription)
                            }
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
    }

    @IBAction func btnLogout_Tap(_ sender: Any) {
        logout(){
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SocialLogin") {
                self.present(viewController, animated: true, completion: nil)
            }
        }

    }

}

extension AccountHomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arySection.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return arySection[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_IDX_PROFILE:
            return arySection[section].rcnt
        case SECTION_IDX_PROVIDERS:
            if let user = FIRAuth.auth()?.currentUser {
                return user.providerData.count
            }
            return 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell?

        switch (indexPath as NSIndexPath).section {
        case SECTION_IDX_PROFILE:
            cell = tableView.dequeueReusableCell(withIdentifier: "Profile")
            let user = FIRAuth.auth()?.currentUser

            let txvEmail  = cell?.viewWithTag(1) as? UITextView
            let lblDispNm = cell?.viewWithTag(2) as? UILabel
            let txvUserID = cell?.viewWithTag(3) as? UITextView
            let imvAvatar = cell?.viewWithTag(4) as? UIImageView
            txvEmail?.text = user?.email
            lblDispNm?.text = user?.displayName
            txvUserID?.text = user?.uid

            let photoURL = user?.photoURL
            let lastPhotoURL: URL? = photoURL

            if let photoURL = photoURL {
                DispatchQueue.global(qos: .default).async {
                    let data = try? Data.init(contentsOf: photoURL)
                    if let data = data {
                        let image = UIImage.init(data: data)
                        DispatchQueue.main.async(execute: {
                            if photoURL == lastPhotoURL {
                                imvAvatar?.image = image
                            }
                        })
                    }
                }
            } else {
                imvAvatar?.image = UIImage.init(named: "avatar")
            }

        case SECTION_IDX_PROVIDERS:
            cell = tableView.dequeueReusableCell(withIdentifier: "Provider")
            let userInfo = FIRAuth.auth()?.currentUser?.providerData[(indexPath as NSIndexPath).row]
            cell?.textLabel?.text = userInfo?.providerID
            cell?.detailTextLabel?.text = userInfo?.uid
        default:
            fatalError("Unknown section in UITableView")
        }
        return cell!
    }

}

extension AccountHomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == SECTION_IDX_PROFILE {
            return 270
        }
        return 45
    }
}

