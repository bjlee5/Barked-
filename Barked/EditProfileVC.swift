//
//  EditProfile.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var changeProBtn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.backgroundColor = UIColor.clear
        emailField.backgroundColor = UIColor.clear
        
        fetchCurrentUser()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
    }
    
    
    func fetchCurrentUser() {
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            self.usernameField.text = user.username
            self.emailField.text = user.email
            let imageURL = user.photoURL!
            
            // Clean up profilePic is storage - model after the post-pic, which is creating a folder in storage. This is too messy right now.
            
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                
                if error == nil {
                    
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.profilePic.image = UIImage(data: data)
                        }
                    }
                    
                    
                } else {
                    print(error!.localizedDescription)
                    
                }
                
            })
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
        
         profilePic.image = image
         imageSelected = true
        
        }
            imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    

    @IBAction func changePic(_ sender: Any) {
    
        present(imagePicker, animated: true, completion: nil)
    }
    

    @IBAction func updateProfile(_ sender: Any) {
    
        let user = FIRAuth.auth()?.currentUser
        
        guard let username = usernameField.text, username != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid username!")
            return
        }
        
        guard let email = emailField.text, email != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid e-mail!")
            return
        }
        
        
        let pictureData = UIImageJPEGRepresentation(self.profilePic.image!, 0.70)
        
        let imgUid = NSUUID().uuidString
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        DataService.ds.REF_PRO_IMAGES.child(imgUid).put(pictureData! as Data, metadata: metadata) { (newMetaData, error) in
            
            if error != nil {
                
                print("BRIAN: Error uploading profile Pic to Firebase")
                
            } else {
                print("BRIAN: New metadata stuff's workin.")
                
                let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                changeRequest?.didChangeValue(forKey: "email")
                changeRequest?.displayName = username
                
                user?.updateEmail(email, completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
                
                let photoString = newMetaData!.downloadURL()?.absoluteString
                let photoURL = newMetaData!.downloadURL()
                changeRequest?.photoURL = photoURL
                
                changeRequest?.commitChanges(completion: { (error) in
                    
                    if error == nil {
                        
                        let user = FIRAuth.auth()?.currentUser
                        let userInfo = ["email": user!.email!, "username": username as Any , "uid": user!.uid, "photoURL": photoString!] as [String : Any]
                        
                        let userRef = DataService.ds.REF_USERS.child((user?.uid)!)
                        userRef.updateChildValues(userInfo)
                        print("BRIAN: New values saved properly!")
                        
                    }
                })
                
            }
        }
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    

    @IBAction func cancelPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePassword(_ sender: Any) {
        
        let alert = SCLAlertView()
        let txt = alert.addTextField("Enter email")
        alert.addButton("OK") {
            let emailInput = txt.text
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: emailInput!, completion: { (error) in
                if let error = error {
                    if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .errorCodeUserNotFound:
                            DispatchQueue.main.async {
                                showWarningMessage("The e-mail address you have entered is not valid")
                            }
                        default:
                            DispatchQueue.main.async {
                                showWarningMessage("An error has occurred")
                            }
                        }
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        showNotice("You'll receive an e-mail shortly to reset your password")
                    }
                }
            })
        }
        alert.showEdit("Change Password", subTitle: "Please enter the e-mail address associated with your account")
    }
    
    

    @IBAction func deleteAccount(_ sender: Any) {
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Delete") {
            self.delete()
        }
        alertView.addButton("Cancel") {
            
        }
        alertView.showError("WARNING", subTitle: "Are you sure you want to delete your account?")
        
        
    }
    
    func delete() {
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            
            FIRAuth.auth()?.currentUser?.delete(completion: { (error) in
                
                if error == nil {
                    
                    print("BRIAN: Account successfully deleted!")
                    DispatchQueue.main.async {
                        
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
                        self.present(vc, animated: true, completion: nil)
                        
                        
                    }
                    
                } else {
                    
                    print(error?.localizedDescription)
                }
            })
        })
        
    }
    
}

