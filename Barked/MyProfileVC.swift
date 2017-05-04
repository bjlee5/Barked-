//
//  ProfileVC.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import SCLAlertView

class MyProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Refactor storage reference //
    
    var posts = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var profilePicLoaded = false
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    var following = [String]()
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    
    // For Layout
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    

    @IBOutlet weak var proPic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        followingFriends()
        fetchPosts()
        loadUserInfo()
        collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        /////////////// Layout /////////////////
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        layout.itemSize = CGSize(width: screenWidth/5, height: screenWidth/5)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        
        
    }
    
    // Load Current User Info
    
    func loadUserInfo(){
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            self.usernameLabel.text = user.username
            let imageURL = user.photoURL!
            
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                
                if error == nil {
                    
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.proPic.image = UIImage(data: data)
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
    
    /// Sort Feed of Posts by Current Date
    func sortDatesFor(this: Post, that: Post) -> Bool {
        return this.currentDate > that.currentDate
    }
    
    // Show Current User Feed //
    
    func followingFriends() {
        
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String: AnyObject]
            
            for (_, value) in users {
                if let uName = value["username"] as? String {
                    self.userRef.observe(.value, with: { (snapshot) in
                        
                        let myUser = Users(snapshot: snapshot)
                        
                        if uName == myUser.username {
                            if let followingUsers = value["following"] as? [String: String] {
                                for (_, user) in followingUsers {
                                    self.following.append(user)
                                    
                                }
                            }
                            
                            self.following.append((FIRAuth.auth()?.currentUser?.uid)!)
                            print("FEEDBRIAN: You are following these users \(self.following)")
                            
                        }
                    })
                }
            }
            
            self.fetchPosts()
        })
    }
    
    func fetchPosts() {
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                print("LEE: \(snapshot)")
                for snap in snapshot {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        if let postUser = postDict["uid"] as? String {
                            if postUser == FIRAuth.auth()?.currentUser?.uid {
                                
                                let key = snap.key
                                let post = Post(postKey: key, postData: postDict)
                                self.posts.append(post)
                                
                                
                            }
                        }
                    }
                }
                
                self.collectionView.reloadData()
                self.posts.sort(by: self.sortDatesFor)
            }
        })
        
    }
    
    // Collection View
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProCell", for: indexPath) as? ProfileCell {

            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
            cell.frame.size.width = screenWidth / 5
            cell.frame.size.height = screenWidth / 5
            
            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString!) {
                cell.configureCell(post: post, img: img)
            } else {
                cell.configureCell(post: post)
            }
            return cell
        } else {
            
            return ProfileCell()
            
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func editProfile(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileVC")
        self.present(vc, animated: true, completion: nil)
    }

    
    
    
}

