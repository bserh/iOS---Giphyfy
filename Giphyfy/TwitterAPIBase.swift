//
//  TwitterController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/7/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation
import Social

class TwitterAPIBase: SocialNetworkAPIBase {
    
    init() {
        let serviceType = SLServiceTypeTwitter
        
        super.init(serviceType: serviceType)
    }
}