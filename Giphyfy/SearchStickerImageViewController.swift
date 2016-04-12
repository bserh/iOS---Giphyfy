//
//  SearchStickerImageViewController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/12/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class SearchStickerImageViewController: GiphySearchBasedViewController, Searchable {
    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchDelegate = self
    }
    
    //MARK: - Searchable Protocol Methods
    func search(searchString: String) {
        pagingSpinner.startAnimating()
        
        giphyLoader.searchAsyncStickers(queryString: searchString, completionHandler: handleGiphyData)
    }
}
