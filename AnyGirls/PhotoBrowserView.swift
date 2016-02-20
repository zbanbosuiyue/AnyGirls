//
//  PhotoBrowserView.swift
//  AnyGirls
//
//  Created by Rong Zheng on 2/18/16.
//  Copyright © 2016 Rong Zheng. All rights reserved.
//

import UIKit
import JGProgressHUD
import SDWebImage

enum SourceType{
    case LOCAL
    case REMOTE
}


class PhotoBrowserView: UIView, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDataSource, BrowserCellDelagate {

    var collectionView: UICollectionView?
    let cellIdentifier = "Cell"
    var photos = NSMutableOrderedSet()
    
    //Show Page Number
    var title: UILabel?
    //Close Button
    var close: UIButton?
    //Download Button
    var downloadButton: UIButton?

    //SourceType
    var sourceType: SourceType?
    
    let count = CGFloat(14)
    var heightUnit: CGFloat?
    var layout: UICollectionViewFlowLayout?
    
    // Indexing
    var index: Int?{
        didSet{
            title?.text = "\(index! + 1)/\(photos.count)"
            let indexPath = NSIndexPath(forRow: index!, inSection: 0)
            collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView(frame)
    }
    
    //Init
    class func initWithPhotos(withUrlArray array: [AnyObject])-> PhotoBrowserView{
        let view = PhotoBrowserView(frame: (UIApplication.sharedApplication().keyWindow?.frame)!)
        view.photos.addObjectsFromArray(array)
        return view
    }
    
    //Show
    func show(){
        let window = UIApplication.sharedApplication().keyWindow
        window?.addSubview(self)
    }
    
    //Setup PageView
    func setupView(frame: CGRect){
        heightUnit = frame.height/self.count
        self.backgroundColor = UIColor.whiteColor()
        
        layout = UICollectionViewFlowLayout()
        layout!.itemSize = CGSize(width: frame.width, height: heightUnit!*(self.count - 2))
        layout!.scrollDirection = UICollectionViewScrollDirection.Horizontal
    
        collectionView = UICollectionView(frame: CGRect(x: 0, y: heightUnit!, width: frame.width, height: heightUnit!*(self.count - 2)), collectionViewLayout: layout!)
        collectionView!.pagingEnabled = true
        collectionView!.directionalLockEnabled = true
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.showsHorizontalScrollIndicator = true
        collectionView!.indicatorStyle = UIScrollViewIndicatorStyle.White
        self.collectionView!.registerClass(PhotoBrowserCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.addSubview(collectionView!)
        
        addTitleLabel(frame)
//        addCloseBtn(frame)
        addDownloadButton(frame)
    }
    
    //Add TitleLabel
    func addTitleLabel(frame: CGRect){
        title = UILabel(frame: CGRect(x: 0, y: 15.0, width: frame.width, height: heightUnit!))
        title?.textColor = UIColor.grayColor()
        title?.textAlignment = NSTextAlignment.Center
        
        addSubview(title!)
    }
    // Add Close Button
    func addCloseBtn(frame: CGRect) {
        close = UIButton(frame: CGRect(x: 8, y: 5.0, width: 30, height: heightUnit!))
        let image = UIImage(named: "close")
        close?.setImage(image, forState: UIControlState.Normal)
        close?.addTarget(self, action: Selector("close:"), forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(close!)
    }

    // Add Download Button
    func addDownloadButton(frame: CGRect){
        downloadButton = UIButton(frame: CGRect(x: frame.width/2 - 20, y: heightUnit!*(count - 1), width: 40, height: 35))
        let downloadImage = UIImage(named: "Download")
        let stretchableButtonImage = downloadImage?.stretchableImageWithLeftCapWidth(0, topCapHeight: 0)
        downloadButton!.setBackgroundImage(stretchableButtonImage, forState: UIControlState.Normal)
        downloadButton!.addTarget(self, action: "saveImage:", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(downloadButton!)
    }
    
    // SaveImage
    func saveImage(sender: UIButton){
        let indexPath = collectionView!.indexPathsForVisibleItems().last!
        let cell = collectionView?.cellForItemAtIndexPath(indexPath) as! PhotoBrowserCell
        if cell.imageView.image == nil{
            print("image nil")
        }else{
            UIImageWriteToSavedPhotosAlbum(cell.imageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        }
    }
    
    func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject?) {
        if error == nil{
            showSuccessMsg("Saved Image", interval: 0.5)
        }else{
            showErrorMsg("Failed to Save", interval: 0.5)
        }
    }
    
    // Identify Page No.
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int((floor(scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1) + 1
        title?.text = "\(page)/\(photos.count)"
        
    }
    // Close it self
    func close(sender: UIButton) {
        self.removeFromSuperview()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    // Set Space Between Item Horizontal
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    // Set Space Between Item Vertical
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    // Show Message
    func showSuccessMsg(text: String, interval: Double){
        let hud = JGProgressHUD(style: JGProgressHUDStyle.Light)
        hud.textLabel.text = text
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.showInView(self, animated: true)
        hud.dismissAfterDelay(interval, animated: true)
    }
    
    func showErrorMsg(text: String, interval: Double){
        let hud = JGProgressHUD(style: JGProgressHUDStyle.Light)
        hud.textLabel.text = text
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.showInView(self, animated: true)
        hud.dismissAfterDelay(interval, animated: true)
    }
    
    func singleTap() {
        self.removeFromSuperview()
    }
    
    // Setup Cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! PhotoBrowserCell
        cell.delegate = self
        let url = NSURL(string: photos.objectAtIndex(indexPath.row) as! String)!
        let frame = cell.imageView.frame
        let percent: CGFloat = 0.8
        cell.imageView.frame = CGRect(x: frame.width*(1 - percent)/2, y: frame.height*(1 - percent)/2, width: frame.width*percent, height: frame.height*percent)
        if sourceType == SourceType.REMOTE{
            //progress bar
            let mixedIndicator: RMDownloadIndicator = RMDownloadIndicator(rectframe: CGRectMake(CGRectGetWidth(self.bounds)/2 - 30, CGRectGetMaxY(self.bounds)/2 - 30, 60, 60), type: RMIndicatorType.kRMMixedIndictor)
            mixedIndicator.backgroundColor = UIColor.clearColor()
            mixedIndicator.fillColor = UIColor.mainColor()
            mixedIndicator.strokeColor = UIColor.mainColor()
            mixedIndicator.closedIndicatorBackgroundStrokeColor = UIColor.mainColor()
            mixedIndicator.radiusPercent = 0.45
            mixedIndicator.loadIndicator()
            
            cell.imageView.sd_setImageWithURL(url, placeholderImage: nil, options: SDWebImageOptions.TransformAnimatedImage, progress: { (received, total) -> Void in
                //没有缓存过，加入progress bar
                if received != 0{
                    if !self.subviews.contains(mixedIndicator){
                        self.addSubview(mixedIndicator)
                    }
                }
                
                mixedIndicator.updateWithTotalBytes(CGFloat(total), downloadedBytes: CGFloat(received))
                }, completed: { (image, error, cacheType, url) -> Void in
                    if image == nil{
                        return
                    }
                })
        }
        
        else{
            let image = UIImage(named: (url.absoluteString))
            cell.imageView.image = image
        }
        
        UIView.animateWithDuration(NSTimeInterval(0.5), animations: {
            () in
            cell.imageView.frame = frame
        })
        cell.scrollView.zoomScale = 1
        
        return cell
    }
}
