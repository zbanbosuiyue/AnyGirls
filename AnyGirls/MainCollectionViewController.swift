//
//  CollectionViewController.swift
//  AnyGirls
//
//  Created by Rong Zheng on 2/18/16.
//  Copyright © 2016 Rong Zheng. All rights reserved.
//

import UIKit
import Foundation
import UIKit
import Alamofire
import Kanna
import JGProgressHUD
import SDWebImage
import MJRefresh

private let reuseIdentifier = "Cell"
private let imageBaseUrl = "http://www.dbmeinv.com/dbgroup/rank.htm?pager_offset="
private let pageBaseUrl = "http://www.dbmeinv.com/dbgroup/show.htm?cid="
class MainCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, TopMenuDelegate{
    
    var photos = NSMutableOrderedSet()
    var photosBig = NSMutableOrderedSet()
    //    var layout: MainCollectionViewLayout?
    var populatingPhotos = false //isPopulating
    var currentPage = 2 //PageIndexLocater
    var isGot = false   //Is Got Data
    var menuView:TopMenuView!
    var currentType: PageType = .boobs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // LanuchScreen Show 1s
        configureRefresh()
        
        // InitTopMenu
        initTopMenu()
        
        // InitPageBaseUrl()
        getPageUrl()
        
        // Setup View
        setupView()
        
        // Add Bar Item
        addBarItem()
        
        //获取第一页图片
        populatePhotos()
        //        self.collectionView?.header.beginRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func getPageUrl()-> String{
        return pageBaseUrl + currentType.rawValue + "&pager_offset=" + "\(currentPage)"
    }

    
    func initTopMenu(){
        let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
        
        // Set Location of TopMenu
        let menuView = TopMenuView(frame: CGRectMake(0, navBarHeight + topViewHeight - 10, screenSize.width, topViewHeight))
        
        menuView.bgColor = UIColor.whiteColor()
        menuView.lineColor = UIColor.grayColor()
        menuView.delegate = self
        //Set Menu Titles
        menuView.titles = [" Boobs ", " Booty ", " Stocking ", " Legs ", " Face ", " Random "]
        
        //Close Scrolltotop
        menuView.setScrollToTop(false)
        self.menuView = menuView
        self.view.addSubview(menuView)
    }
    
    //  Clicke Trigger
    func topMenuDidChangedToIndex(index:Int){
        self.navigationItem.title = self.menuView.titles[index] as String
        
        currentType = PhotoUtil.selectTypeByNumber(index)
        
        photos.removeAllObjects()
        photosBig.removeAllObjects()
        // Clear All Pics and Return to Page 2
        self.currentPage = 2
        
        self.collectionView?.reloadData()
        
        populatePhotos()// Get Photos.
    }
    
    func configureRefresh(){
        self.collectionView?.mj_header = MJRefreshNormalHeader(refreshingBlock: { () in
            //print("header")
            self.handleRefresh()
            self.collectionView?.mj_header.endRefreshing()
        })
        
        self.collectionView?.mj_footer = MJRefreshAutoFooter(refreshingBlock:
            { () in
                //print("footer")
                self.populatePhotos()
                self.collectionView?.mj_footer.endRefreshing()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.toolbarHidden = true
    }
    
    func setupView() {
        // Set Title
        self.navigationItem.title = "GIRL FINDER"
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 0)
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.collectionView?.scrollsToTop = true
        self.collectionView?.frame = CGRectMake(10, 0, self.view.frame.width - 20, self.view.frame.height)


        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.bounds.size.width - 30)/2, height: ((view.bounds.size.width - 30)/2)/225.0*300.0)
        
        //print(layout.itemSize)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView!.collectionViewLayout = layout
        self.collectionView!.registerClass(MainCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }
    
    //Add Navigationitem
    func addBarItem(){
        let item = UIBarButtonItem(image: UIImage(named: "Del"), style: UIBarButtonItemStyle.Plain, target: self, action: "setting:")
        item.tintColor = UIColor.whiteColor()
        
        self.navigationItem.rightBarButtonItem = item
    }
    
    @IBAction func setting(sender: AnyObject){
        let alert = UIAlertController(title: "ALERT", message: "Do You Really Want To Clear Cache?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.Cancel, handler: nil)
        let okAction = UIAlertAction(title: "CONFIRM", style: UIAlertActionStyle.Default, handler: clearCache)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Clear Cache
    func clearCache(alert: UIAlertAction!){
        
        let size = SDImageCache.sharedImageCache().getSize() / 1000 //KB
        var string: String
        if size/1000 >= 1{
            string = "Clear Cache \(size/1000)M"
        }else{
            string = "Clear Cache \(size)K"
        }
        let hud = JGProgressHUD(style: JGProgressHUDStyle.Light)
        hud.textLabel.text = string
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.showInView(self.view, animated: true)
        SDImageCache.sharedImageCache().clearDisk()
        hud.dismissAfterDelay(1.0, animated: true)
    }
    
    override func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return true
    }
    
    //Bottom Pull Refresh
    func handleRefresh() {
        photos.removeAllObjects()
        // Clear All Pics
        self.currentPage = 2
        self.collectionView?.reloadData()
        
        populatePhotos()
    }
    
    //Check Image URL
    func checkImageUrl(imageUrl: String?)->Bool{
        //        if imageUrl == nil{
        //            return false
        //        }
        //
        //        if !imageUrl!.componentsSeparatedByString(imageBaseUrl).isEmpty{
        //            let array = imageUrl!.componentsSeparatedByString(imageBaseUrl)
        //            if array.count > 1 && !array[1].isEmpty{
        //                return true
        //            }
        //        }
        //
        //        return false
        return true
    }
    
    func transformUrl(urls: [String]){
        for url in urls{
            let urlBig = url.stringByReplacingOccurrencesOfString("bmiddle", withString: "large")
            photosBig.addObject(urlBig)
        }
    }
    
    //Set HUD
    //    func loadTextHUD(text: String, time: Float){
    //        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    //        loadingNotification.mode = MBProgressHUDMode.Text
    //        loadingNotification.minShowTime = time
    //        loadingNotification.labelText = text
    //    }
    
    // Get Photos From Web
    func populatePhotos(){
        if populatingPhotos{//If is populating, then skip
            return
        }
        
        // If isnot populating, then do
        populatingPhotos = true
        let pageUrl = getPageUrl()
        Alamofire.request(.GET, pageUrl).validate().responseString{
            (response) in
            
            //
            let isSuccess = response.result.isSuccess
            let html = response.result.value
            let HUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
            
            if isSuccess == true{
                // Waiting Sign

                HUD.textLabel.text = "Loading"
                HUD.showInView(self.view, animated: true)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    // Temp
                    var urls = [String]()
                    // Kanna parse html
                    if let doc = Kanna.HTML(html: html!, encoding: NSUTF8StringEncoding){
                        CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII)
                        let lastItem = self.photos.count
                        // Parse Images
                        for node in doc.css("img"){
                            if self.checkImageUrl(node["src"]){
                                urls.append(node["src"]!)
                                self.isGot = true
                            }
                        }
                        
                        // Only transfer pics when isGot
                        if self.isGot{
                            self.photos.addObjectsFromArray(urls)
                            self.transformUrl(urls)
                        }
                        
                        //Only refresh the pics adding

                        let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                        }
                        if self.isGot{
                            self.currentPage++
                            self.isGot = false
                        }
                    }
                }
            }else{
                
                // let hud = JGProgressHUD(style: JGProgressHUDStyle.Light)
                HUD.textLabel.text = "Network Error"
                HUD.indicatorView = JGProgressHUDErrorIndicatorView()
                HUD.showInView(self.view, animated: true)
                HUD.dismissAfterDelay(1.0, animated: true)
            }
            
            //Clear HUB
            //            MBProgressHUD.hideHUDForView(self.view, animated: true)
            HUD.dismiss()
            self.populatingPhotos = false
        }
    }
    
    // Show big pics
    //    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    //        performSegueWithIdentifier("BrowserPhoto", sender: (self.photos.objectAtIndex(indexPath.item) as! PhotoInfo))
    //    }
    
    // Set Brower Data
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "BrowserPhoto"{
    //            let temp = segue.destinationViewController as! PhotoBrowserCollectionViewController
    //            temp.photoInfo = sender as! PhotoInfo
    //            temp.currentType = self.currentType
    //        }
    //    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: topViewHeight + 10)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collectionView?.mj_footer.hidden = self.photos.count == 0
        return self.photos.count
    }
    
    // See Big Pics
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var browser:PhotoBrowserView
        
        // Photo Loading
        browser = PhotoBrowserView.initWithPhotos(withUrlArray: self.photosBig.array)
        
        // Remote Type
        browser.sourceType = SourceType.REMOTE
        
        // Show Which Pics
        browser.index = indexPath.row
        
        //Show
        browser.show()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MainCollectionViewCell
        
        //        let imageURL = (photos.objectAtIndex(indexPath.row) as! PhotoInfo).imageUrl
        
        cell.layer.borderWidth = 1.2
        cell.layer.borderColor = UIColor(red: 229/255, green: 230/255, blue: 234/255, alpha: 1).CGColor
        cell.layer.cornerRadius = 15.0
        cell.layer.masksToBounds = true
        //        cell.layer.shadowColor = UIColor.grayColor().CGColor
        //
        //        cell.layer.shadowOffset = CGSizeMake(2, 2)
        //        cell.layer.shadowOpacity = 1
        //        cell.layer.shadowRadius = 6.0
        
        let imageURL = NSURL(string: (photos.objectAtIndex(indexPath.row) as! String))
        cell.imageView.image = nil
        cell.imageView.sd_setImageWithURL(imageURL)
        
        return cell
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orient = UIApplication.sharedApplication().statusBarOrientation
            
            switch orient {
            default:
                //print("Anything But Portrait")
                //print(UIScreen.mainScreen().bounds.size)
                self.menuView.frame = CGRectMake(0.0, self.navigationController!.navigationBar.frame.size.height + 20, UIScreen.mainScreen().bounds.size.width, topViewHeight)
                // Do something else
            }
            
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                //print("rotation completed")
        })
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    
}