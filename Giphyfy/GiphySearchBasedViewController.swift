//
//  GiphySearchBasedViewController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/12/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class GiphySearchBasedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    static let fullSizeSegueIdentifier = "showFullSizeGifSegue"
    weak var searchDelegate: Searchable? = nil
    
    let giphyLoader = GiphyLoader()
    var giphyImages: [GiphyImage] = []
    var searchQueryState = ""
    
    let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        pagingSpinner.hidesWhenStopped = true
    }
    
    //MARK: - Search Bar Delegate Methods
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchedString = searchBar.text!
        
        if searchedString != searchQueryState {
            giphyImages = []
            searchQueryState = searchedString
        }
        
        searchDelegate?.search(searchedString)
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if giphyImages.isEmpty {
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
        return giphyImages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GiphyImageCell", forIndexPath: indexPath) as! GiphyImageTableViewCell
        let giphyImage = giphyImages[indexPath.row]
        cell.cellImage.image = nil
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            if let urlString = giphyImage.giphyImageUrl, url = NSURL(string: urlString) {
                let image = UIImage.animatedImageWithAnimatedGIFURL(url)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.cellImage.image = image
                })
            }
            
        })
        
        return cell
    }

    //MARK: - Table View Delegate Methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellWidth = UIScreen.mainScreen().bounds.width
        
        let currentGif = giphyImages[indexPath.row]
        let currentGifImageWidth = currentGif.giphyImageWidth!
        let currentGifImageHeight = currentGif.giphyImageHeight!
        
        let scale = Double(currentGifImageWidth) / Double(currentGifImageHeight)
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
            self.searchDelegate?.search(searchQueryState)
        }
    }
    
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tableViewCell = sender as! GiphyImageTableViewCell
        let indexPath = tableView.indexPathForCell(tableViewCell)!
        
        let giphyImage = giphyImages[indexPath.row]
        
        if let presentFullSizeImageVC = segue.destinationViewController as? PresentFullSizeGifViewController
            where segue.identifier == SearchGiphyImageViewController.fullSizeSegueIdentifier {
                presentFullSizeImageVC.giphyImage = giphyImage
        }
    }
    
    //MARK: - Custom Methods
    func handleGiphyData(giphyImages: [GiphyImage]) {
        self.giphyImages += giphyImages
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.pagingSpinner.stopAnimating()
        })
    }
}
