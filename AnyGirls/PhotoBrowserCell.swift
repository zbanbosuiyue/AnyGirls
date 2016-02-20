//
//  PhotoBrowserCell.swift
//  AnyGirls
//
//  Created by Rong Zheng on 2/18/16.
//  Copyright © 2016 Rong Zheng. All rights reserved.
//


import UIKit

class PhotoBrowserCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var scrollView: UIScrollView = UIScrollView()
    var imageView = UIImageView()
    var delegate: BrowserCellDelagate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        addSubview(scrollView)
        scrollView.frame = bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.addSubview(imageView)
        imageView.frame = bounds
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        scrollView.contentSize = imageView.frame.size
        
        //Double Click
        let doubleTapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleDoubleTapGesture:"))
        doubleTapGesture.numberOfTouchesRequired = 1
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(doubleTapGesture)
        
        let singleTapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTapGesture:"))
        singleTapGesture.numberOfTouchesRequired = 1
        singleTapGesture.numberOfTapsRequired = 1
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(singleTapGesture)
        
        singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
    }
    
    func handleSingleTapGesture(sender: UITapGestureRecognizer) {
        delegate?.singleTap()
    }
    
    func handleDoubleTapGesture(sender: UITapGestureRecognizer) {
        let factor:CGFloat = sender.view!.transform.a
        if factor == 1 { //Zoom In
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(NSTimeInterval(0.3))
            scrollView.zoomScale = 2
            UIView.commitAnimations()
        }else{// Zoom Out
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(NSTimeInterval(0.3))
            scrollView.zoomScale = 1
            UIView.commitAnimations()
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()//Put Small Pic into Middle
    }
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        if imageView.frame.size.width < frame.width {
            scrollView.zoomScale = 1
        }
    }
    func centerScrollViewContents() {
        let boundsSize: CGSize = scrollView.bounds.size
        var contentsFrame: CGRect = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        scrollView.contentSize = contentsFrame.size
        imageView.frame = contentsFrame
    }
}
