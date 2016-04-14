//
//  SearchGiphyImageViewController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/5/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class SearchGiphyImageViewController: CollectionSearchableBaseViewController, UITableViewDataSource, UITableViewDelegate {
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    private let fullSizeSegueIdentifier = "showFullSizeGifSegue"
    
    let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    private let cellIdentifier = "GiphyImageCell"
    
    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        pagingSpinner.hidesWhenStopped = true
    }
    
    //MARK: - Search Bar Delegate Methods
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchedString = searchBar.text!
        
        pagingSpinner.startAnimating()
        searchController.getGifsAsyncByKeyWord(searchedString, completionHandler: handleGiphyData)
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchController.data.isEmpty {
            let emptyLabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            emptyLabel.text = "No data is available"
            emptyLabel.textAlignment = .Center
            emptyLabel.sizeToFit()
            
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = .None
            
            return 0
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GiphyImageTableViewCell
        let cellGifModel = searchController.data[indexPath.row]
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            if let urlString = cellGifModel.giphyThumbImageUrl, url = NSURL(string: urlString) {
                let image = UIImage.animatedImageWithAnimatedGIFURL(url)
                dispatch_async(dispatch_get_main_queue(), {
                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? GiphyImageTableViewCell {
                        cellToUpdate.cellImage.image = image
                    }
                })
            }
        })
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellWidth = UIScreen.mainScreen().bounds.width
        
        let gifModel = searchController.data[indexPath.row]
        let gifWidth = gifModel.giphyThumbImageWidth!
        let gifHeight = gifModel.giphyThumbImageHeight!
        
        let scale = Double(gifWidth) / Double(gifHeight)
        let cellHeight = CGFloat(Double(cellWidth) / scale)
        
        return cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return pagingSpinner
    }
    
    //MARK: - Scroll View Delegate Methods
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= -20 {
            searchController.getGifsAsyncByKeyWord(searchController.searchQueryState, completionHandler: handleGiphyData)
        }
    }
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tableViewCell = sender as! GiphyImageTableViewCell
        let indexPath = tableView.indexPathForCell(tableViewCell)!
        
        let gifModel = searchController.data[indexPath.row]
        
        if let presentFullSizeImageVC = segue.destinationViewController as? PresentFullSizeGifViewController
            where segue.identifier == fullSizeSegueIdentifier {
                presentFullSizeImageVC.gifModel = gifModel
        }
    }
    
    //MARK: - Custom Methods
    private func handleGiphyData(giphyModels: [GiphyImage]) {
        searchController.data += giphyModels
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
            self.pagingSpinner.stopAnimating()
        }
    }

}
