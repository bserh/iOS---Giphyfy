//
//  SocialNetworkAPI.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/7/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation
import Social
import UIKit

class SocialNetworkAPIBase {
    private var serviceType: String
    
    init(serviceType: String) {
        self.serviceType = serviceType
    }
    
    func postToSocialFrom(sender: UIViewController, withGif gif: GiphyImageModel) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            if SLComposeViewController.isAvailableForServiceType(self.serviceType) {
                let socialVC = SLComposeViewController(forServiceType: self.serviceType)
                let message = self.convertGiphyImageToSocialMessagePost(gif)
                
                if let image = message.image {
                    socialVC.addImage(image)
                }
                if let initialText = message.initialText {
                    socialVC.setInitialText(initialText)
                }
                if let urlString = message.url, url = NSURL(string: urlString) {
                    socialVC.addURL(url)
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    sender.presentViewController(socialVC, animated: true, completion: nil)
                }
            } else {
                let alertVC = UIAlertController(title: "Accounts Error",
                    message: "You don't have an account for this social. Please get one!",
                    preferredStyle: .Alert)
                let completeAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alertVC.addAction(completeAction)
                
                dispatch_async(dispatch_get_main_queue()) {
                    sender.presentViewController(alertVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func convertGiphyImageToSocialMessagePost(giphyImage: GiphyImageModel) -> SocialMessage {
        var message = SocialMessage()
        
        message.initialText = "Here is the shared gif from #Giphyfy iOS app"
        if let GIFURLString = giphyImage.originalImageUrl, GIFURL = NSURL(string: GIFURLString),
            image = UIImage.animatedImageWithAnimatedGIFURL(GIFURL) {
            message.image = image
            message.url = GIFURLString
        }
        
        return message
    }
}