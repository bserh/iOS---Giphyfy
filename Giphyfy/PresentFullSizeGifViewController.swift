//
//  PresentFullSizeGifViewController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/6/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class PresentFullSizeGifViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var originalImage: UIImageView!
    
    var originalImageUrlString: String?
    
    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        renderGifImage()
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    @IBAction func handleShareToFacebookButtonTapped(sender: UIButton) {
    }
    
    @IBAction func handleShareToTwitterButtonTapped(sender: UIButton) {
    }
    
    //MARK: - Custom Methods
    private func renderGifImage() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            if let urlString = self.originalImageUrlString, url = NSURL(string: urlString) {
                let temporaryImage = UIImage.animatedImageWithAnimatedGIFURL(url)
                dispatch_async(dispatch_get_main_queue(), {
                    self.originalImage.image = temporaryImage
                })
            }
        })
    }

}
