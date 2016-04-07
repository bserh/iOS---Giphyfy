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
                self.giphyImage.giphyImageWidth = dataDictionary["image_width"] as? Int
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
