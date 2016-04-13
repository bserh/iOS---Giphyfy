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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var imageConstraintBottom: NSLayoutConstraint!
    
    var gifModel: GiphyImage? {
        didSet {
            let thumbURL = gifModel!.giphyImageUrl
            let originalURL = thumbURL?.stringByReplacingOccurrencesOfString("200w_d", withString: "giphy")
            gifModel!.giphyImageUrl = originalURL
        }
    }
    private var lastZoomScale: CGFloat = -1
    
    //MARK: - Overrided Methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let urlString = self.gifModel!.giphyImageUrl
        let url = NSURL(string: urlString!)
        let image = UIImage.animatedImageWithAnimatedGIFURL(url)
        imageView.image = image
        activityIndicator.stopAnimating()
        
        scrollView.delegate = self
        updateZoom()
        updateConstraints()
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({
            [weak self] _ in
            self?.updateZoom()
            }, completion: nil)
    }
    
    //MARK: - Scroll View Delegate Methods
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraints()
    }
    
    //MARK: - Actions
    @IBAction func shareButtonTapped(sender: UIBarButtonItem) {
        let socialSharingActionSheet = generateSocialSharingActionSheetFor(self, withGif: gifModel!)
        
        self.presentViewController(socialSharingActionSheet, animated: true, completion: nil)
    }
    
    //MARK: - Custom Methods
    private func updateConstraints() {
        if let image = imageView.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            
            let viewWidth = scrollView.bounds.size.width
            let viewHeight = scrollView.bounds.size.height
            
            // center image if it is smaller than the scroll view
            var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
            if hPadding < 0 {
                hPadding = 0
            }
            
            var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
            if vPadding < 0 {
                vPadding = 0
            }
            
            imageConstraintLeft.constant = hPadding
            imageConstraintRight.constant = hPadding
            
            imageConstraintTop.constant = vPadding
            imageConstraintBottom.constant = vPadding
            
            view.layoutIfNeeded()
        }
    }
    
    private func updateZoom() {
        if let image = imageView.image {
            var minZoom = min(scrollView.bounds.size.width / image.size.width, scrollView.bounds.size.height / image.size.height)
            if minZoom > 1 {
                minZoom = 1
            }
            
            scrollView.minimumZoomScale = minZoom
            scrollView.maximumZoomScale = 2
            
            scrollView.zoomScale = minZoom
            lastZoomScale = minZoom
        }
    }

}
