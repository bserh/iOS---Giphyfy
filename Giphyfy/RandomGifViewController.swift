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
    private var giphyImage = GiphyImage()

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
        
        var message = SocialMessage()
        message.initialText = "Here is the shared gif from #Giphyfy iOS app"
        message.image = randomGifImageView.image
        message.url = giphyImage.giphyImageUrl
        
        twitterController.postToSocialFrom(self, withMessage: message)
    }
    
    @IBAction func handleShareFacebookButtonTapped(sender: UIButton) {
        let facebookController = FacebookController()
        
        var message = SocialMessage()
        message.initialText = "Here is the shared gif from #Giphyfy iOS app"
        message.image = randomGifImageView.image
        message.url = giphyImage.giphyImageUrl
        
        facebookController.postToSocialFrom(self, withMessage: message)
    }
    
    //MARK: - Custom Methods
    private func handleRandomGiphyData(data: NSData!, urlResponse: NSURLResponse!, error: NSError!) {
        guard let data = data else {
            NSLog("handleRandomGiphyData() received no data")
            return
        }
        
        do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
            guard let jsonArray = jsonObject as? [String: AnyObject] else {
                NSLog("handleRandomGiphyData() didn't get an array")
                return
            }
            
            if let dataDictionary = jsonArray["data"] as? [String: AnyObject] {
                self.giphyImage.giphyImageUrl = dataDictionary["image_url"] as? String
            }
            
            self.renderGifImage()
        } catch let error as NSError {
            NSLog("JSON error: \(error)")
        }
    }
    
    private func loadRandomGif() {
        sendGiphyRequest(giphyAPIRandomURL, queryParams: [:], callbackHandler: handleRandomGiphyData)
    }
    
    private func renderGifImage() {
        if let urlString = giphyImage.giphyImageUrl, url = NSURL(string: urlString) {
            let temporaryImage = UIImage.animatedImageWithAnimatedGIFURL(url)
            dispatch_async(dispatch_get_main_queue()) {
                self.randomGifImageView.image = temporaryImage
            }
        }
    }

}
