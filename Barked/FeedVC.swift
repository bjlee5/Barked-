//
//  FeedVC.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import Foundation

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // TO DO: Try using nil coelessing operator for if let statements concerning current username and e-mail address, profilePic & default picture
    
    
    // Issues with the ProfilePic - only loads properly sometimes, when going back from Profile screen DOES NOT load. When logging in initially, everything DOES load properly.
    
    // Refactor this storage ref using DataService //
    
    var posts = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var storageRef: FIRStorage { return FIRStorage.storage() }
    var profilePicLoaded = false 
    var following = [String]()
    /// Referencing the Storage DB then, current User
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    
    

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var currentUser: UILabel!

    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePic.isHidden = true
        currentUser.isHidden = true
        
        self.posts.sort(by: self.sortLikesFor)
        followingFriends()
        loadUserInfo()
        fetchPosts()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Dismiss Keyboard //
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
    } // End ViewDidLoad
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.posts.sort(by: self.sortLikesFor)
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func loadUserInfo(){
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let imageURL = user.photoURL!
            self.currentUser.text = user.username
            
            /// We are downloading the current user's ImageURL then converting it using "data" to the UIImage which takes a property of data
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.profilePic.image = UIImage(data: data)
                            self.profilePicLoaded = true
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
    
    /// Sort Feed of Posts by Amount of Likes
    func sortLikesFor(this: Post, that: Post) -> Bool {
        return this.likes > that.likes
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
                            print("BRIAN: You are following these users \(self.following)")
                            
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
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        print("POST: \(postDict)")
                        if let postUser = postDict["uid"] as? String {
                            if self.following.contains(postUser) {
                                
                                let key = snap.key
                                let post = Post(postKey: key, postData: postDict)
                                self.posts.append(post)
                                
                                
                            }
                        }
                    }
                }
                
                self.tableView.reloadData()
                self.posts.sort(by: self.sortLikesFor)
            }
        })
        
    }
    
    // User Feed //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString!), let proImg = FeedVC.imageCache.object(forKey: post.profilePicURL as NSString!) {
                cell.configureCell(post: post, img: img, proImg: proImg)
            } else {
                cell.configureCell(post: post)
            }
            return cell
        } else {
            
            return PostCell()
            
        }
    }

    // Logging Out //
    

    @IBAction func signOutPress(_ sender: Any) {
    
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            
            // This code causes view stacking (potentially memory leaks), but cannot figure out a better way to get to LogInVC and clear the log in text //
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
            self.present(vc, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }

} 
