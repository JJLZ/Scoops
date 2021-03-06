//
//  NewsViewController.swift
//  Scoops
//
//  Created by JJLZ on 4/5/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit
import GoogleSignIn

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: IBOutlet's
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Constants
    let cellIdentifier = "newsCell"
    let cellHeight: CGFloat = 129.0
    
    // MARK: Properties
    var user: FIRUser? = nil
    var author: String = ""
    var news: [New] = []
    
    var userId: String {
        return  getUserId(fromUser: user)
    }
    
    // store a reference to the list of news in the database
    var newsRef = FIRDatabase.database().reference().child("news")
    
    private var newsRefHandle: FIRDatabaseHandle?
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //-- Custom Cell --
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        //--
        
        self.author = getAuthor(fromUser: self.user)
        title = "My Reports"
        
        observeNews()
    }
    
    deinit {
        
        // Stop observing database changes when the view controller dies
        if let refHandle = newsRefHandle {
            
            newsRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Firebase related methods
    
    private func observeNews() {
        
        newsRef.queryOrdered(byChild: "authorID").queryEqual(toValue: self.userId).observe(.childAdded, with: { snapshot in
            
            if snapshot.childrenCount > 0 {
                
                self.news.append(New(snapshot: snapshot))
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        
        newsRef.queryOrdered(byChild: "authorID").queryEqual(toValue: self.userId).observe(.childChanged, with: { snapshot in
            
            if snapshot.childrenCount > 0 {
                
                let newChanged = New(snapshot: snapshot)
                let id: String = (newChanged.refInCloud?.description())!
                
                for i in 0..<(self.news.count) {
                    
                    if (self.news[i].refInCloud?.description())! == id {
                        
                        self.news[i] = newChanged
                        
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(item: i, section: 0)
                            self.tableView.reloadRows(at: [indexPath], with: .fade)
                        }
                        
                        return
                    }
                }
            }
        })
        
    }
    
    // MARK: IBAction's
    
    @IBAction func btnLogoutClicked(_ sender: Any) {
        
        makeLogout()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addNewClicked(_ sender: Any) {
        
        performSegue(withIdentifier: "showCreateNew", sender: self)
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NewsTableViewCell
        
        let new: New = news[indexPath.row]
        
        cell.lblTitle?.text = new.title
        cell.lblText?.text = new.text
        cell.lblPublished?.text = (new.isPublished == true) ? "Published" : "Unpublished: tap to publish"
        cell.lblPublished?.textColor = (new.isPublished == true) ? UIColor.black : UIColor.red
        cell.lblLikes?.text = "\(new.likes)"
        cell.lblDislikes?.text = "\(new.dislikes)"
        
        // Image for the new
        if new.imageURL != "" {
            cell.downloadImage(imageURL: URL(string: new.imageURL)!)
        } else {
            cell.ivPhoto.image = UIImage(named: "news.png")
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = news[indexPath.row]
        
        if selectedItem.isPublished == false {
            
            let alertController = UIAlertController(title          : "Publish Now!",
                                                    message        : "Do you want publish this new?",
                                                    preferredStyle : .alert)
            
            let saveAction = UIAlertAction(title: "Publish", style: .default, handler: { (alertAction) in
                
                selectedItem.refInCloud?.updateChildValues(["isPublished": true])
                
                let cell = tableView.cellForRow(at: indexPath) as! NewsTableViewCell
                cell.lblPublished?.text = "Published"
                cell.lblPublished?.textColor = UIColor.black
            })
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(saveAction)
            alertController.addAction(actionCancel)
            
            self.present(alertController, animated: true, completion: {})
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showCreateNew" {
            
            let createNewVC = segue.destination as! CreateNewViewController
            createNewVC.user = self.user
        }
    }
}

//"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

//"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"

//"But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?"

//"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

//"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"

//"But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?"
