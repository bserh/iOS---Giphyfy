//
//  SocialSharingUtilities.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/11/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation
import UIKit

func generateSocialSharingActionSheetFor(sender: UIViewController, withGif giphyImage: GiphyImage) -> UIAlertController {
    let socialSharingActionSheet = UIAlertController(title: "Share", message: "Choose an app", preferredStyle: .ActionSheet)
    
    let facebookPostAction = UIAlertAction(title: "Share on Facebook", style: .Default) {
        action in
        let facebookAPI = FacebookAPIBase()
        
        facebookAPI.postToSocialFrom(sender, withGif: giphyImage)
    }
    let tweetAction = UIAlertAction(title: "Share on Twitter", style: .Default) {
        action in
        let twitterAPI = TwitterAPIBase()
        
        twitterAPI.postToSocialFrom(sender, withGif: giphyImage)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    
    socialSharingActionSheet.addAction(facebookPostAction)
    socialSharingActionSheet.addAction(tweetAction)
    socialSharingActionSheet.addAction(cancelAction)
    
    return socialSharingActionSheet
}