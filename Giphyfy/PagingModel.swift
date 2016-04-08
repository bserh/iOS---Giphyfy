//
//  PagingModel.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/8/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import Foundation

struct PagingModel {
    var limit: Int = 5
    var offset: Int = 0
    
    func toDictionaryRepresentation() -> [String: AnyObject] {
        return [
            "limit": limit,
            "offset": offset
        ]
    }
}