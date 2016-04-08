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
    @IBOutlet weak var shareFacebookButton: UIButton!
    @IBOutlet weak var shareTwitterButton: UIButton!
    
    private var giphyImage: GiphyImage?
    private let APIController = GiphyAPIController()

    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRandomGif()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    @IBAction func handleRandomButtonTapped(sender: UIButton) {
        loadRandomGif()
    }
    
    @IBAction func handleShareTwitterButtonTapped(sender: UIButton) {
        let twitterController = TwitterController()
        
        twitterController.postToSocialFrom(self, withGif: giphyImage!)
    }
    
    @IBAction func handleShareFacebookButtonTapped(sender: UIButton) {
        let facebookController = FacebookController()
        
        facebookController.postToSocialFrom(self, withGif: giphyImage!)
    }
    
    //MARK: - Custom Methods
    private func handleRandomGiphyData(giphyImage: GiphyImage) {
        self.giphyImage = giphyImage
        renderGifImage()
    }
    
    private func loadRandomGif() {
        APIController.getAsyncRandomGif(handleRandomGiphyData)
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
