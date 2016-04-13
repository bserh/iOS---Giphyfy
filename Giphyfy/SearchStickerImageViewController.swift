//
//  SearchStickerImageViewController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/12/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class SearchStickerImageViewController: CollectionSearchableBaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK: - Properties
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let fullSizeSegueIdentifier = "showFullSizeStickerSegue"
    private let cellIdentifier = "StickerImageCell"
    
    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchController = SearchController(pagingModel: PagingModel(limit: 14, offset: 0))
        
        searchBar.delegate = self
        collectionView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
    }
    
    //MARK: - Collection View Data Source Methods
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if searchController.data.isEmpty {
            let emptyLabel = UILabel(frame: CGRectMake(0, 0, collectionView.bounds.size.width, collectionView.bounds.size.height))
            emptyLabel.text = "No data is available"
            emptyLabel.textAlignment = .Center
            emptyLabel.sizeToFit()
            
            collectionView.backgroundView = emptyLabel
            
            return 0
        }
        
        collectionView.backgroundView = nil
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchController.data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)
            as! StickerImageCollectionViewCell
        
        let cellGifModel = searchController.data[indexPath.row]
        cell.stickerImageView.image = nil
        cell.loadingIndicator.hidesWhenStopped = true
        cell.loadingIndicator.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            if let urlString = cellGifModel.giphyImageUrl, url = NSURL(string: urlString) {
                let image = UIImage.animatedImageWithAnimatedGIFURL(url)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.stickerImageView.image = image
                    cell.loadingIndicator.stopAnimating()
                })
            }
        })
        
        return cell
    }
 
    //MARK: - Collection View Flow Layout Delegate Methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = (UIScreen.mainScreen().bounds.width / 2) - 5
        
        let gifModel = searchController.data[indexPath.row]
        let gifWidth = gifModel.giphyImageWidth!
        let gifHeight = gifModel.giphyImageHeight!
        
        let scale = Double(gifWidth) / Double(gifHeight)
        let cellHeight = CGFloat(Double(cellWidth) / scale)
        
        return CGSizeMake(cellWidth, cellHeight)
    }
    
    //MARK: - Scroll View Delegate Methods
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            searchController.getStickersAsyncByKeyWord(searchController.searchQueryState, completionHandler: handleGiphyData)
        }
    }
    
    //MARK: - Search Bar Delegate Methods
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchedString = searchBar.text!
        
        searchController.getStickersAsyncByKeyWord(searchedString, completionHandler: handleGiphyData)
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let collectionViewCell = sender as! StickerImageCollectionViewCell
        let indexPath = collectionView.indexPathForCell(collectionViewCell)!
        
        let gifModel = searchController.data[indexPath.row]
        
        if let presentFullSizeImageVC = segue.destinationViewController as? PresentFullSizeGifViewController
            where segue.identifier == fullSizeSegueIdentifier {
                presentFullSizeImageVC.gifModel = gifModel
        }
    }
    
    //Custom Methods
    private func handleGiphyData(giphyModels: [GiphyImage]) {
        searchController.data += giphyModels
        
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView.reloadData()
        }
    }
}
