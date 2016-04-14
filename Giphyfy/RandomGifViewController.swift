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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var gifModel: GiphyImageModel?
    private let giphyLoader = GiphyLoader()

    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        loadNextImage()
    }
    
    //MARK: - Actions
    @IBAction func handleRandomButtonTapped(sender: UIButton) {
        loadNextImage()
    }
    
    @IBAction func shareButtonTapped(sender: UIBarButtonItem) {
        let socialSharingActionSheet = generateSocialSharingActionSheetFor(self, withGif: gifModel!)
        
        self.presentViewController(socialSharingActionSheet, animated: true, completion: nil)
    }
    
    //MARK: - Custom Methods
    private func handleRandomGiphyData(giphyImage: GiphyImageModel) {
        self.gifModel = giphyImage
        renderGifImage()
    }
    
    private func loadNextImage() {
        activityIndicator.startAnimating()
        giphyLoader.getAsyncRandomGif(handleRandomGiphyData)
    }
    
    private func renderGifImage() {
        if let urlString = gifModel!.originalImageUrl, url = NSURL(string: urlString) {
            let temporaryImage = UIImage.animatedImageWithAnimatedGIFURL(url)
            dispatch_async(dispatch_get_main_queue()) {
                self.randomGifImageView.image = temporaryImage
                self.activityIndicator.stopAnimating()
            }
        }
    }

}
