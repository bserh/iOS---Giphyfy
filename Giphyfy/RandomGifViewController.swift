//
//  RandomGifViewController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/5/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class RandomGifViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var randomGifImageView: UIImageView!
    
    private var giphyImage: GiphyImage?
    private let APIController = GiphyAPIController()

    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIController.getAsyncRandomGif(handleRandomGiphyData)
    }
    
    //MARK: - Actions
    @IBAction func handleRandomButtonTapped(sender: UIButton) {
        APIController.getAsyncRandomGif(handleRandomGiphyData)
    }
    
    @IBAction func shareButtonTapped(sender: UIBarButtonItem) {
        let socialSharingActionSheet = generateSocialSharingActionSheetFor(self, withGif: giphyImage!)
        
        self.presentViewController(socialSharingActionSheet, animated: true, completion: nil)
    }
    
    //MARK: - Custom Methods
    private func handleRandomGiphyData(giphyImage: GiphyImage) {
        self.giphyImage = giphyImage
        renderGifImage()
    }
    
    private func renderGifImage() {
        if let urlString = giphyImage!.giphyImageUrl, url = NSURL(string: urlString) {
            let temporaryImage = UIImage.animatedImageWithAnimatedGIFURL(url)
            dispatch_async(dispatch_get_main_queue()) {
                self.randomGifImageView.image = temporaryImage
            }
        }
    }

}
