//
//  DetailViewController.swift
//  Scoops
//
//  Created by JJLZ on 4/12/17.
//  Copyright © 2017 ESoft. All rights reserved.
//

import UIKit

enum newState {
    case Neutral
    case Like
    case Dislike
}

class DetailViewController: UIViewController {
    
    // MARK: IBOutlet's
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var txtReport: UITextView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var vImage: UIView!
    
    // MARK: Constant
    let kUp           = "up"
    let kDown         = "down"
    let kUpSelected   = "upSelected"
    let kDownSelected = "downSelected"
    
    var btnUp   : UIBarButtonItem?  = nil
    var btnDown : UIBarButtonItem?  = nil
    
    // MARK: Properties
    var new: New? = nil
    
    var state: newState = .Neutral {
        
        willSet (newValue) {
            
            switch newValue
            {
            case .Like:
                self.changeImages(forUpButton: kUpSelected, andDownButton: kDown)
            
            case .Dislike:
                self.changeImages(forUpButton: kUp, andDownButton: kDownSelected)
                
            case .Neutral:
                self.changeImages(forUpButton: kUp, andDownButton: kDown)
            }
        }
        
        didSet (newValue) {
            
        }
    }
    
    // MARK: ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-- jTODO: embed in scrollview --//
        
        if let currentReport = self.new {
            
            showReport(new: currentReport)
            
            if currentReport.imageURL != "" {
                downloadImage(imageURL: URL(string: currentReport.imageURL)!)
            } else {
                spinner.isHidden = true
            }
        }
        
        //-- Up & Down Buttons --
        let imgUp = UIImage(named: kUp)!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.btnUp = UIBarButtonItem(image: imgUp, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.btnUpClicked))
        
        let imgDown = UIImage(named: kDown)!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.btnDown = UIBarButtonItem(image: imgDown, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.btnDownClicked))

        self.navigationItem.setRightBarButtonItems([self.btnUp!, self.btnDown!], animated: true)
        //--
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        saveState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods
    
    func changeImages(forUpButton imgUp: String, andDownButton imgDown: String)
    {
        btnUp?.image = UIImage(named: imgUp)!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        btnDown?.image = UIImage(named: imgDown)!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
    }
    
    func downloadImage(imageURL: URL)
    {
        //-- Default image --
        var defaultImageAsData: Data? = nil
        
        if let img = UIImage(named: "news.png") {
            if let data:Data = UIImagePNGRepresentation(img) {
                defaultImageAsData = data
            }
        }
        //--
        
        let asyncData = AsyncData(url: imageURL, defaultData: defaultImageAsData!)
        
        spinner.isHidden = false
        spinner.startAnimating()
        
        asyncData.delegate = self
        ivPhoto.image = UIImage(data: asyncData.data)
    }
    
    func btnUpClicked() {
        
        if state == .Like {
            state = .Neutral
            return
        }
        
        state = newState.Like
    }
    
    func btnDownClicked() {
        
        if state == .Dislike {
            state = .Neutral
            return
        }
        
        state = newState.Dislike
    }
    
    func showReport(new: New)
    {
        lblTitle.text? = new.title
        txtReport.text = new.text
    }
    
    func saveState() {
        
        switch state
        {
        case .Like:
            new?.refInCloud?.updateChildValues(["likes": (new!.likes + 1)])
        case .Dislike:
            new?.refInCloud?.updateChildValues(["dislikes": (new!.dislikes + 1)])
        case .Neutral:
            return
        }
    }
}

extension DetailViewController: AsyncDataDelegate {
    
    func asyncData(_ sender: AsyncData, shouldStartLoadingFrom url: URL) -> Bool {
        // nos pregunta si puede hacer la descarga.
        // por supuesto!
        return true
    }
    
    func asyncData(_ sender: AsyncData, willStartLoadingFrom url: URL) {
        // Nos avisa que va a empezar
        
    }
    
    func asyncData(_ sender: AsyncData, didEndLoadingFrom url: URL) {
        
        // la actualizo, y encima con una animación (más en el avanzado)
        UIView.transition(with: ivPhoto,
                          duration: 0.7,
                          options: [.transitionCrossDissolve],
                          animations: {
                            self.ivPhoto.image = UIImage(data: sender.data)
        }, completion: nil)
        
        spinner.stopAnimating()
        spinner.isHidden = true
    }
}


//"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

//"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"

//"But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?"

//"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

//"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"

//"But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?"
