//
//  SearchGiphyImageViewController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/5/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class SearchGiphyImageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    static let fullSizeSegueIdentifier = "showFullSizeGifSegue"
    private static let defaultOffset = 5
    private var refreshControl = UIRefreshControl()
    private var giphyImages: [GiphyImage] = []
    private var offset: Int? = nil
    private var searchActiveStatus = false
    private var searchQueryState: String? = nil
    
    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "loading...")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        tableView.tableFooterView?.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - Search Bar Delegate Methods
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActiveStatus = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActiveStatus = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActiveStatus = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActiveStatus = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchGifs(searchText, completionHandler: handleGiphyData)
    }
    
    //MARK: - Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return giphyImages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GiphyImageCell") as! GiphyImageTableViewCell
        
        let giphyImage = giphyImages[indexPath.row]
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            if let urlString = giphyImage.giphyImageUrl, url = NSURL(string: urlString) {
                let temporaryImage = UIImage.animatedImageWithAnimatedGIFURL(url)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.cellImage?.image = temporaryImage
                })
            }
        })
        
        return cell
    }
    
    //MARK: - Table View Delegate Methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCellWithIdentifier("GiphyImageCell") as! GiphyImageTableViewCell
        let cellWidth = cell.frame.width
        
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
    private func handleGiphyData(data: NSData!, urlResponse: NSURLResponse!, error: NSError!) {
        guard let data = data else {
            NSLog("handleGiphyData() received no data")
            return
        }
        
        do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
            guard let jsonArray = jsonObject as? [String: AnyObject] else {
                NSLog("handleGiphyData() didn't get an array")
                return
            }
            retrieveGiphyDataFromJsonArray(jsonArray)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.tableView.tableFooterView?.hidden = true
            })
        } catch let error as NSError {
            NSLog("JSON error: \(error)")
        }
    }
    
    private func retrieveGiphyDataFromJsonArray(giphySearchResponse: [String: AnyObject]) {
        if let dataDictionary = giphySearchResponse["data"] as? [AnyObject] {
            for dataItem in dataDictionary {
                if let images = dataItem["images"] as? [String: AnyObject],
                    thumbImageData = images["fixed_width_downsampled"] as? [String: AnyObject],
                    originalImageData = images["original"] as? [String: AnyObject] {
                    var giphyImage = GiphyImage()
                    
                    giphyImage.giphyImageUrl = thumbImageData["url"] as? String
                    giphyImage.giphyImageWidth = Int((thumbImageData["width"] as? String)!)
                    giphyImage.giphyImageHeight = Int((thumbImageData["height"] as? String)!)
                    
                    giphyImage.giphyOriginalImageUrl = originalImageData["url"] as? String
                    giphyImage.giphyOriginalImageWidth = Int((originalImageData["width"] as? String)!)
                    giphyImage.giphyOriginalImageHeight = Int((originalImageData["height"] as? String)!)
                    
                    giphyImages.append(giphyImage)
                }
            }
        }
    }
    
    private func searchGifs(searchString: String,
        completionHandler: (data: NSData!, urlResponse: NSURLResponse!, error: NSError!) -> Void) {
            if searchQueryState == nil {
                searchQueryState = searchString
                offset = 0
            } else if searchQueryState == searchString {
                offset! += SearchGiphyImageViewController.defaultOffset
            } else {
                searchQueryState = searchString
                offset = 0
                giphyImages = []
            }
            
            let searchParams: [String: AnyObject] = [
                "q": searchQueryState!,
                "offset": offset!,
                "limit": SearchGiphyImageViewController.defaultOffset
            ]
            
            sendGiphyRequest(giphyAPISearchURL, queryParams: searchParams, callbackHandler: completionHandler)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            loadMore()
        }
    }
    
    private func loadMore() {
        self.tableView.tableFooterView?.hidden = false
        if let searchQueryState = searchQueryState {
            self.searchGifs(searchQueryState, completionHandler: self.handleGiphyData)
        }
    }

}
