//
//  PresentFullSizeGifViewController.swift
//  Giphyfy
//
//  Created by Sergey Bavykin on 4/6/16.
//  Copyright © 2016 Sergey Bavykin. All rights reserved.
//

import UIKit

class PresentFullSizeGifViewController: UIViewController, UIScrollViewDelegate {
    //MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    
    var originalImage = UIImageView()
    var giphyImage: GiphyImage? {
        didSet {
            let thumbURL = giphyImage!.giphyImageUrl
            let originalURL = thumbURL?.stringByReplacingOccurrencesOfString("200w_d", withString: "giphy")
            giphyImage!.giphyImageUrl = originalURL
        }
    }
    
    //MARK: - Overrided Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlString = self.giphyImage?.giphyImageUrl, url = NSURL(string: urlString) {
            let temporaryImage = UIImage.animatedImageWithAnimatedGIFURL(url)
            originalImage.image = temporaryImage
            originalImage.frame = CGRectMake(0, 0, originalImage.image!.size.width, originalImage.image!.size.height)
            originalImage.contentMode = UIViewContentMode.Center
            
            scrollView.delegate = self
            scrollView.addSubview(self.originalImage)
            
            scrollView.contentSize = (originalImage.image?.size)!
            setZoomScale()
        }
    }
    
    //MARK: - Scroll View Delegate Methods
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return originalImage
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = originalImage.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2
        } else {
            contentsFrame.origin.x = 0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2
        } else {
            contentsFrame.origin.y = 0
        }
        
        originalImage.frame = contentsFrame
    }
    
    //MARK: - Actions
    
    @IBAction func shareButtonTapped(sender: UIBarButtonItem) {
        let socialSharingActionSheet = generateSocialSharingActionSheetFor(self, withGif: giphyImage!)
        
        self.presentViewController(socialSharingActionSheet, animated: true, completion: nil)
    }
    
    //MARK: - Custom Methods
    private func setZoomScale() {
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        
        scrollView.minimumZoomScale = minScale / 2
        scrollView.maximumZoomScale = 2.0
        scrollView.zoomScale = 1.0
    }

}
