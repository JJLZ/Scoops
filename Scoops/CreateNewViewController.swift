//
//  CreateNewViewController.swift
//  Scoops
//
//  Created by JJLZ on 4/6/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class CreateNewViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtTexto: UITextView!
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var txtLongitude: UITextField!
    @IBOutlet weak var txtLatitude: UITextField!
    
    // MARK: Properties
    var user: FIRUser? = nil
    
    // store a reference to the list of news in the database
    var newsRef = FIRDatabase.database().reference().child("news")
    
    // Firebase storage reference and is conceptually similar to the Firebase database references you’ve seen already, but for a storage object
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://scoops-4fda2.appspot.com")
    
    var userId: String {
        return  getUserId(fromUser: user)
    }

    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Report"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: Methods
    
    func saveRecord(completion: () -> ()) {
        
        //-- jTODO: Alertas para las campos requeridos --//
        guard let title = txtTitle.text else {
            return
        }
        
        guard let text = txtTexto.text else {
            return
        }
        
        let myAuthor = getAuthor(fromUser: self.user)
        if myAuthor.characters.count == 0 {
            return
        }
        
        let testRef = newsRef.childByAutoId()
        let newItem = ["title": title,
                       "text": text,
                       "author": myAuthor,
                        "authorID": self.userId,
                       "isPublished": false,
                       "longitude": 0.5252,
                       "latitude": 0.5353,
                       "imageURL": "imageURLTest"] as [String : Any]
        
        testRef.setValue(newItem)
        
        completion()
    }
    
    // MARK: Firebase storage
    
    func uploadImageToFirebaseStorage(data: Data)
    {
        let localStorageRef = FIRStorage.storage().reference(withPath: "images/demo.jpg")
        let uploadMetadata = FIRStorageMetadata()
        uploadMetadata.contentType = "image/jpeg"
        
        let uploadTask = localStorageRef.put(data as Data, metadata: uploadMetadata) { (metadata, error) in
            
            if (error != nil)
            {
                print(error?.localizedDescription ?? "Unknown error")
            }
            else
            {
                print("Upload complete! Here's some metadata! \(String(describing: metadata))")
            }
        }
        
        // Update the progress bar
        uploadTask.observe(.progress) { (taskSnapshot) in
            
            guard let progress = taskSnapshot.progress else { return }
            
        }
    }
    
    func uploadMovieToFirebaseStorage(url: NSURL)
    {
        
    }
    
    // MARK: IBAction's
    
    @IBAction func saveNewClicked(_ sender: Any) {
        
        saveRecord { 
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func bntTakePhotoClicked(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: Image Picker Delegate

extension CreateNewViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let mediaType: String = info[UIImagePickerControllerMediaType] as? String else {
            
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        if mediaType == (kUTTypeImage as String)    // The user has selected an image
        {
            if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(originalImage, 0.8)
            {
                uploadImageToFirebaseStorage(data: imageData)
            }
        }
        else if mediaType == (kUTTypeMovie as String)   // the user has selected a movie
        {
            if let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL
            {
                uploadMovieToFirebaseStorage(url: movieURL)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
        
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}

//"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

//"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"

//"But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?"

//"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

//"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"

//"But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?"
