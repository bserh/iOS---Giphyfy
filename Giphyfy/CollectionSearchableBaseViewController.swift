//
//  CollectionRepresentableBaseViewController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/13/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class CollectionSearchableBaseViewController: UIViewController, UISearchBarDelegate {
    //MARK: - Properties
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchController = SearchController()
    
    //MARK: - Overrided Methods
    override func viewDidLoad() {
        searchBar.delegate = self
    }
}
