//
//  NewUserVC.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit

import UIKit
import Firebase
import SwiftKeychainWrapper

class NewUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
//    @IBOutlet weak var usernameField: UITextField!
//    @IBOutlet weak var passwordField: UITextField!
//    @IBOutlet weak var emailField: UITextField!
//    @IBOutlet weak var profilePic: UIImageView!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // Dismiss Keyboard //
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // ImagePicker //
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            profilePic.image = image
            imageSelected = true
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func selectImgPress(_ sender: Any) {
    
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Creating a New User //

        
    @IBAction func createUserPress(_ sender: Any) {
    
        guard let username = usernameField.text, username != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a username!")
            return
        }
        guard let password = passwordField.text, password != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid password!")
            return
        }
        guard let email = emailField.text, email != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid e-mail!")
            return
        }
        
        guard imageSelected == true else {
            showWarningMessage("Error", subTitle: "You have not selected an image!")
            return
        }
        
        let pictureData = UIImageJPEGRepresentation(self.profilePic.image!, 0.70)
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                
                print("BRIAN: Could not create user")
                
            } else {
                
                print("BRIAN: The user has been created.")
                self.setUserInfo(user: user, email: email, password: password, username: username, proPic: pictureData as NSData!)
                
            }
        })
        
    }
    
    func setUserInfo(user: FIRUser!, email: String, password: String, username: String, proPic: NSData!) {
        
        let imgUid = NSUUID().uuidString
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        DataService.ds.REF_PRO_IMAGES.child(imgUid).put(proPic as Data, metadata: metadata) { (newMetaData, error) in
            
            if error != nil {
                
                print("BRIAN: Error uploading profile Pic to Firebase")
                
            } else {
                print("BRIAN: New metadata stuff's workin.")
                
                
                
                let photoURL = newMetaData?.downloadURL()?.absoluteString
                if let url = photoURL {
                    
                    
                    self.saveUserInfo(user: user, username: username, password: password, image: url)
                    
                }
            }
        }
    }
    
    
    // This is func completeSignInID.createFIRDBuser from SocialApp1. Instead of only providing "provider": user.providerID - there is additional information provided - for the username, profile pic, etc. We need to provide a place for this information to be input. //
    
    private func saveUserInfo(user: FIRUser!, username: String, password: String, image: String) {
        
        
        let userInfo = ["email": user.email!, "username": username , "uid": user.uid , "photoURL": image, "provider": user.providerID]
        
        self.completeSignIn(id: user.uid, userData: userInfo)
        print("BRIAN: User info has been saved to the database")
        
    }
    
    
    

    @IBAction func backBtnPress(_ sender: Any) {
    
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
        self.present(vc, animated: true, completion: nil)
    }
    
    // Duplicative function - can I refactor this to DataService?
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("BRIAN: Segway completed \(keychainResult)")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Tab")
        self.present(vc, animated: true, completion: nil)
    }
    
}


