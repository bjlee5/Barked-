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

class NewUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    let breeds = ["Affenpinscher",
                  "Afghan Hound",
                  "Airedale Terrier",
                  "Akita",
                  "Alaskan Malamute",
                  "American English Coonhound",
                  "American Eskimo Dog",
                  "American Foxhound",
                  "American Hairless Terrier",
                  "American Leopard Hound",
                  "American Staffordshire Terrier",
                  "American Water Spaniel",
                  "Anatolian Shepherd Dog",
                  "Appenzeller Sennenhunde",
                  "Australian Cattle Dog",
                  "Austrailian Shepherd",
                  "Austrailian Terrier",
                  "Azawakh",
                  "Barbet",
                  "Basenji",
                  "Basset Fauve De Bretagne",
                  "Basset Hound",
                  "Beagle",
                  "Bearded Collie",
                  "Beauceron",
                  "Bedlington Terrier",
                  "Belgian Laeknois",
                  "Belgian Malinois",
                  "Belgian Sheepdog",
                  "Belgian Tervuren",
                  "Bergamasco",
                  "Berger Picard",
                  "Bernese Mountain Dog",
                  "Bichon Frise",
                  "Biewer Terrier",
                  "Black and Tan Coonhound",
                  "Black Russian Terrier",
                  "Bloodhound",
                  "Bluetick Coonhound",
                  "Boerboel",
                  "Bolognese",
                  "Border Collie",
                  "Border Terrier",
                  "Borzoi",
                  "Boston Terrier",
                  "Bouvier Des Flandres",
                  "Boxer",
                  "Boykin Spaniel",
                  "Bracco Italiano",
                  "Braque Du Bourbonnais",
                  "Braque Francais Pyrenean",
                  "Briard",
                  "Brittany",
                  "Broholmer",
                  "Brussels Griffon",
                  "Bull Terrier",
                  "Bulldog",
                  "Bullmastiff",
                  "Cairn Terrier",
                  "Canaan Dog",
                  "Cane Corso",
                  "Cardigan Welsh Corgi",
                  "Catahoula Leopard Dog",
                  "Caucasian Shepherd Dog",
                  "Cavalier King Charles Spaniel",
                  "Central Asian Shepherd Dog",
                  "Cesky Terrier",
                  "Chesapeake Bay Retriever",
                  "Chihuahua",
                  "Chinese Crested",
                  "Chinese Shar-Pei",
                  "Chinook",
                  "Chow Chow",
                  "Cirneco Dell'Enta",
                  "Clumber Spaniel",
                  "Cocker Spaniel",
                  "Collie",
                  "Coton De Tulear",
                  "Curly-Coated Retriever",
                  "Czechoslovakian Vlcak",
                  "Dachshund",
                  "Dalmatian",
                  "Dandie Dinmont Terrier",
                  "Danish-Swedish Farmdog",
                  "Deutscher Wachtelhund",
                  "Doberman Pinscher",
                  "Dogo Argentino",
                  "Dogue De Bordeaux",
                  "Drentsche Patrijshond",
                  "Drever",
                  "Dutch Shepherd",
                  "English Cocker Spaniel",
                  "English Foxhound",
                  "English Setter",
                  "English Springer Spaniel",
                  "English Toy Spaniel",
                  "Entlebucher Mountain Dog",
                  "Estrela Mountain Dog",
                  "Eurasier",
                  "Field Spaniel",
                  "Finnish Lapphund",
                  "Finnish Spitz",
                  "Flat-Coated Retriever",
                  "French Bulldog",
                  "French Spaniel",
                  "German Longhaired Pointer",
                  "German Pinscher",
                  "German Shepherd",
                  "German Shorthaired Pointer",
                  "German Spitz",
                  "German Wirehaired Pointer",
                  "Giant Schnauzer",
                  "Glen of Imaal Terrier",
                  "Golden Retriever",
                  "Golden Doodle",
                  "Gordon Setter",
                  "Grand Basset Griffon Vendeen",
                  "Great Dane",
                  "Great Pyrenees",
                  "Greater Swiss Mountain Dog",
                  "Greyhound",
                  "Hamiltonstovare",
                  "Harrier",
                  "Havanese",
                  "Hokkaido",
                  "Hovawart",
                  "Ibizan Hound",
                  "Icelandic Sheepdog",
                  "Irish Red and White Setter",
                  "Irish Setter",
                  "Irish Terrier",
                  "Irish Water Spaniel",
                  "Irish Wolfhound",
                  "Italian Greyhound",
                  "Jagdterrier",
                  "Japanese Chin",
                  "Jindo",
                  "Kai Ken",
                  "Karelian Bear Dog",
                  "Keeshond",
                  "Kerry Blue Terrier",
                  "Kishu Ken",
                  "Komondor",
                  "Kromfohrlander",
                  "Kuvasz",
                  "Labrador (Yellow)",
                  "Labrador (Chocolate)",
                  "Labrador (Black)",
                  "Lagotto Romagnolo",
                  "Lakeland Terrier",
                  "Lancashire Heeler",
                  "Leonberger",
                  "Lhasa Apso",
                  "Lowchen",
                  "Maltese",
                  "Manchester Terrier",
                  "Mastiff",
                  "Miniature American Shepherd",
                  "Miniature Bull Terrier",
                  "Miniature Pinscher",
                  "Miniature Schnauzer",
                  "Mudi",
                  "Neapolitan Mastiff",
                  "Nederlandse Kooikerhondje",
                  "Newfoundland",
                  "Norfolk Terrier",
                  "Norrbottenspets",
                  "Norwegian Buhund",
                  "Norwegian Elkhound",
                  "Norwegian Lundehund",
                  "Norwich Terrier",
                  "Nova Scotia Duck Tolling Retriever",
                  "Old English Sheepdog",
                  "Otterhound",
                  "Papillon",
                  "Parson Russell Terrier",
                  "Pekingese",
                  "Pembroke Welsh Corgi",
                  "Perro De Presa Canario",
                  "Peruvian Inca Orchid",
                  "Petit Basset Griffon Vendeen",
                  "Pharaoh Hound",
                  "Pit Bull",
                  "Plott",
                  "Pointer",
                  "Polish Lowland Sheepdog",
                  "Pomeranian",
                  "Poodle",
                  "Portuguese Podengo",
                  "Portuguese Podengo Pequeno",
                  "Portuguese Pointer",
                  "Portuguese Sheepdog",
                  "Portuguese Water Dog",
                  "Pudelpointer",
                  "Pug",
                  "Puli",
                  "Pumi",
                  "Pyrenean Mastiff",
                  "Pyrenean Shepherd",
                  "Rafeiro Do Alentejo",
                  "Rat Terrier",
                  "Redbone Coonhound",
                  "Rhodesian Ridgeback",
                  "Rottweiler",
                  "Russell Terrier",
                  "Russian Toy",
                  "Russian Tsvetnaya Bolonka",
                  "Saluki",
                  "Samoyed",
                  "Schapendoes",
                  "Schipperke",
                  "Scottish Deerhound",
                  "Scottish Terrier",
                  "Sealyham Terrier",
                  "Shetland Sheepdog",
                  "Shiba Inu",
                  "Shih Tzu",
                  "Siberian Husky",
                  "Silky Terrier",
                  "Skye Terrier",
                  "Sloughi",
                  "Slovensky Cuvac",
                  "Slovensky Kopov",
                  "Small Munsterlander Pointer",
                  "Smooth Fox Terrier",
                  "Soft Coated Wheaten Terrier",
                  "Spanish Mastiff",
                  "Spanish Water Dog",
                  "Spinone Italiano",
                  "St. Bernard",
                  "Stabyhoun",
                  "Staffordshire Bull Terrier",
                  "Standard Schnauzer",
                  "Sussex Spaniel",
                  "Swedish Lapphund",
                  "Swedish Vallhund",
                  "Teddy Roosevelt Terrier",
                  "Thai Ridgeback",
                  "Tibetan Mastiff",
                  "Tibetan Spaniel",
                  "Tibetan Terrier",
                  "Tornjak",
                  "Tosa",
                  "Toy Fox Terrier",
                  "Transylvanian Hound",
                  "Treeding Tennessee Brindle",
                  "Treeing Walker Coonhound",
                  "Vizsla",
                  "Weimaraner",
                  "Welsh Springer Spaniel",
                  "Welsh Terrier",
                  "West Highland White Terrier",
                  "Whippet",
                  "Wire Fox Terrier",
                  "Wirehaired Pointing Griffon",
                  "Wirehaired Vizsla",
                  "Working Kelpie",
                  "Xoloitzuintli",
                  "Yorkshire Terrier"]
    
//    @IBOutlet weak var usernameField: UITextField!
//    @IBOutlet weak var passwordField: UITextField!
//    @IBOutlet weak var emailField: UITextField!
//    @IBOutlet weak var profilePic: UIImageView!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var selectedPic: CircleView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var breedLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.nameField.backgroundColor = UIColor.clear
        self.usernameField.backgroundColor = UIColor.clear
        self.passwordField.backgroundColor = UIColor.clear
        self.emailField.backgroundColor = UIColor.clear
        
        selectedPic.isHidden = true
        
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
    
    // PickerView //
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return breeds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return breeds[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        breedLabel.text = breeds[row]
    }
    
    // ImagePicker //
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            selectedPic.isHidden = false
            profilePic.isHidden = true 
            selectedPic.image = image
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
        
        guard let breed = breedLabel.text, breed != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid breed!")
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
                self.setUserInfo(user: user, email: email, password: password, username: username, breed: breed, proPic: pictureData as NSData!)
                
            }
        })
        
    }
    
    func setUserInfo(user: FIRUser!, email: String, password: String, username: String, breed: String, proPic: NSData!) {
        
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
                    
                    
                    self.saveUserInfo(user: user, username: username, password: password, breed: breed, image: url)
                    
                }
            }
        }
    }
    
    
    // This is func completeSignInID.createFIRDBuser from SocialApp1. Instead of only providing "provider": user.providerID - there is additional information provided - for the username, profile pic, etc. We need to provide a place for this information to be input. //
    
    private func saveUserInfo(user: FIRUser!, username: String, password: String, breed: String, image: String) {
        
        
        let userInfo = ["email": user.email!, "username": username , "uid": user.uid , "breed": breed, "photoURL": image, "provider": user.providerID]
        
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


