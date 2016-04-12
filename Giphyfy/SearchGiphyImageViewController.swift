//
//  SearchGiphyImageViewController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/5/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class SearchGiphyImageViewController: GiphySearchBasedViewController, Searchable {
    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchDelegate = self
    }
    
    //MARK: - Searchable Protocol Methods
    func search(searchString: String) {
        pagingSpinner.startAnimating()
        
        giphyLoader.searchAsyncGifs(queryString: searchString, completionHandler: handleGiphyData)
    }
}
