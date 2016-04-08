//
//  GiphyAPIController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/8/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation

func += <K,V> (inout left: Dictionary<K,V>, right: Dictionary<K,V>?) {
    guard let right = right else {
        return
    }
    right.forEach {
        key, value in
        
        left.updateValue(value, forKey: key)
    }
}

class GiphyAPIController {
    private static let giphyAPISearchURL = "http://api.giphy.com/v1/gifs/search"
    private static let giphyAPIRandomURL = "http://api.giphy.com/v1/gifs/random"
    private static let APIKeyQueryParam = "api_key=dc6zaTOxFJmzC"
    
    func getAsyncRandomGif(completionHandler: (giphyimage: GiphyImage) -> Void) {
        guard let requestUrl = getRequestUrl(GiphyAPIController.giphyAPIRandomURL, withParams: [:]) else {
            NSLog("Wrong Giphy URL")
            return
        }
        
        let request = NSURLRequest(URL: requestUrl)
        let session = getSessionWithDefaults()
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if let giphyImage = self.parseRandomData(data!) {
                completionHandler(giphyimage: giphyImage)
            }
        }
        
        task.resume()
    }
    
    func searchAsyncGifs(queryString string: String, withPaging paging: PagingModel, completionHandler: (giphyImages: [GiphyImage]) -> Void) {
        var queryParams: [String: AnyObject] = [
            "q": string
        ]
        
        queryParams += paging.toDictionaryRepresentation()
        
        guard let requestURL = getRequestUrl(GiphyAPIController.giphyAPISearchURL, withParams: queryParams) else {
            NSLog("Wrong Giphy URL")
            return
        }
        
        let request = NSURLRequest(URL: requestURL)
        let session = getSessionWithDefaults()
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            if let giphyImages = self.parseSearchedData(data!) {
                completionHandler(giphyImages: giphyImages)
            }
        }
        
        task.resume()
    }
    
    private func parseSearchedData(data: NSData!) -> [GiphyImage]? {
        guard let data = data else {
            NSLog("parseSearchedData() received no data")
            return nil
        }
        
        do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
            guard let jsonArray = jsonObject as? [String: AnyObject] else {
                NSLog("parseSearchedData() didn't get an array")
                return nil
            }
            
            if let dataDictionary = jsonArray["data"] as? [AnyObject] {
                var giphyImages: [GiphyImage] = []
                
                for dataItem in dataDictionary {
                    if let images = dataItem["images"] as? [String: AnyObject],
                        thumbImageData = images["fixed_width_downsampled"] as? [String: AnyObject] {
                        var giphyImage = GiphyImage()
                        
                        giphyImage.giphyImageUrl = thumbImageData["url"] as? String
                        giphyImage.giphyImageWidth = Int((thumbImageData["width"] as? String)!)
                        giphyImage.giphyImageHeight = Int((thumbImageData["height"] as? String)!)
                        
                        giphyImages.append(giphyImage)
                    }
                }
                
                return giphyImages
            }

        } catch let error as NSError {
            NSLog("JSON error: \(error)")
        }
        
        return nil
    }
    
    private func parseRandomData(data: NSData!) -> GiphyImage? {
        guard let data = data else {
            NSLog("parseRandomGiphyData() received no data")
            return nil
        }
        
        do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
            guard let jsonArray = jsonObject as? [String: AnyObject] else {
                NSLog("parseRandomGiphyData() didn't get an array")
                return nil
            }
            
            if let dataDictionary = jsonArray["data"] as? [String: AnyObject] {
                var giphyImage = GiphyImage()
                giphyImage.giphyImageUrl = dataDictionary["image_url"] as? String
                return giphyImage
            }
        } catch let error as NSError {
            NSLog("JSON error: \(error)")
        }
        
        return nil
    }
    
    private func getRequestUrl(prefix: String, withParams queryParams: [String: AnyObject]) -> NSURL? {
        let requestGiphyURL = appendRequestURL(prefix, withQueryParams: queryParams)
        let requestURL = NSURL(string: requestGiphyURL)
        
        return requestURL
    }
    
    private func getSessionWithDefaults() -> NSURLSession {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        return session
    }

    
    private func appendRequestURL(requestURLString: String, withQueryParams queryParams: [String: AnyObject]) -> String {
        var newURL = requestURLString
        
        if queryParams.isEmpty {
            newURL += "?" + GiphyAPIController.APIKeyQueryParam
        } else {
            newURL += "?"
            for (key, value) in queryParams {
                newURL += "\(key)=\(value)&"
            }
            newURL += GiphyAPIController.APIKeyQueryParam
        }
        
        return newURL
    }
}

