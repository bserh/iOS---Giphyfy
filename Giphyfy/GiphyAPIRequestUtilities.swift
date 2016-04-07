//
//  GiphyAPIRequestUtilities.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/5/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation

public let giphyAPISearchURL = "http://api.giphy.com/v1/gifs/search"
public let giphyAPIRandomURL = "http://api.giphy.com/v1/gifs/random"

private let APIKeyQueryParam = "api_key=dc6zaTOxFJmzC"

public func sendGiphyRequest(requestURLString: String, queryParams: [String: AnyObject],
    callbackHandler: (data: NSData!, urlResponse: NSURLResponse!, error: NSError!) -> Void) {
        let requestGiphyURL = appendRequestURL(requestURLString, withQueryParams: queryParams)
        
        guard let requestURL = NSURL(string: requestGiphyURL) else {
            NSLog("Wrong Giphy URL")
            return
        }
        
        let request = NSURLRequest(URL: requestURL)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error in
            
            callbackHandler(data: data!, urlResponse: response!, error: error)
        });

        task.resume()
}

private func appendRequestURL(requestURLString: String, withQueryParams queryParams: [String: AnyObject]) -> String {
    var newURL = requestURLString
    
    if queryParams.isEmpty {
        newURL += "?" + APIKeyQueryParam
    } else {
        newURL += "?"
        for (key, value) in queryParams {
            newURL += "\(key)=\(value)&"
        }
        newURL += APIKeyQueryParam
    }
    
    return newURL
}
