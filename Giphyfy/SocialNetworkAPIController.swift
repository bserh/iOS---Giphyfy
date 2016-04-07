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

class SocialNetworkAPIController {
    private var serviceType: String
    
    init(serviceType: String) {
        self.serviceType = serviceType
    }
    
    func postToSocialFrom(sender: UIViewController, withMessage message: SocialMessage) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) {
            if SLComposeViewController.isAvailableForServiceType(self.serviceType) {
                let socialVC = SLComposeViewController(forServiceType: self.serviceType)
                
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
                dispatch_async(dispatch_get_main_queue()) {
                    sender.presentViewController(alertVC, animated: true, completion: nil)
                }
            }
        }
    }
}