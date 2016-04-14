//
//  SearchController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/13/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation

class SearchController {
    private let giphyLoader: GiphyLoader
    
    var data: [GiphyImageModel] = []
    var searchQueryState = ""
    
    init() {
        giphyLoader = GiphyLoader()
    }
    
    init(pagingModel: PagingModel) {
        self.giphyLoader = GiphyLoader(pagingModel: pagingModel)
    }
    
    func getStickersAsyncByKeyWord(keyWord: String, completionHandler: ([GiphyImageModel]) -> Void) {
        prepareDataForSpecifiedQueryState(keyWord)
        giphyLoader.searchAsyncStickers(queryString: keyWord, completionHandler: completionHandler)
    }
    
    func getGifsAsyncByKeyWord(keyWord: String, completionHandler: ([GiphyImageModel]) -> Void) {
        prepareDataForSpecifiedQueryState(keyWord)
        giphyLoader.searchAsyncGifs(queryString: keyWord, completionHandler: completionHandler)
    }
    
    private func prepareDataForSpecifiedQueryState(queryState: String) {
        if isQueryStateChanged(queryState) {
            data = []
            searchQueryState = queryState
        }
    }
    
    private func isQueryStateChanged(newQueryStringValue: String) -> Bool {
        return newQueryStringValue != searchQueryState
    }
}