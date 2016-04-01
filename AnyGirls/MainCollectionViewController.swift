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
class MainCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, TopMenuDelegate {
    
    var photos = NSMutableOrderedSet()
    var photosBig = NSMutableOrderedSet()
    
    //    var layout: MainCollectionViewLayout?
    let mainManu = UIView()
    var isFinished = false
    var populatingPhotos = false{
        didSet{
            if !populatingPhotos{
                print("changed")
                isFinished = true
            }
            else{
                print("changing")
                isFinished = false
            }
        }
    }
    
    var isOpenedMenu = false
    var currentPage = Int(arc4random_uniform(60) + 2) //PageIndexLocater
    var isGot = false   //Is Got Data
    var topMenuView:TopMenuView!
    var currentType: PageType = PageType.face
    var browser:PhotoBrowserView!
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // setup MainMenu
        setupMainMenu()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func getPageUrl()-> String{
        return pageBaseUrl + currentType.rawValue + "&pager_offset=" + "\(self.currentPage)"
    }

    
    func initTopMenu(){
        let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
        
        // Set Location of TopMenu
        topMenuView = TopMenuView(frame: CGRectMake(0, navBarHeight + topViewHeight - 10, screenSize.width, topViewHeight))
        
        topMenuView.bgColor = UIColor.whiteColor()
        topMenuView.lineColor = UIColor.grayColor()
        topMenuView.delegate = self
        //Set Menu Titles
        topMenuView.titles = [" Face ", " Stocking ", " Legs ", " Random "]
        
        //Close Scrolltotop
        topMenuView.setScrollToTop(false)
        self.view.addSubview(topMenuView)
    }
    
    //  Click Trigger
    func topMenuDidChangedToIndex(index:Int){
        print("Press \(index)")
        self.navigationItem.title = self.topMenuView.titles[index] as String
        
        currentType = PhotoUtil.selectTypeByNumber(index)
        
        photos.removeAllObjects()
        photosBig.removeAllObjects()
        // Clear All Pics and Return to Page X
        self.currentPage = Int(arc4random_uniform(60) + 2)
        
        self.collectionView?.reloadData()
        
        populatePhotos()// Get Photos.
    }
    
    func configureRefresh(){
        self.collectionView?.mj_header = MJRefreshNormalHeader(refreshingBlock:
            { () in
                if self.isFinished{
                    print("header")
                    self.handleRefresh()
                    self.collectionView?.mj_header.endRefreshing()
                } else{
                        self.collectionView?.mj_header.endRefreshing()
                    self.showMessage("Wait For Loading", animate: 0.5)
                }
        })
        
        self.collectionView?.mj_footer = MJRefreshAutoFooter(refreshingBlock:
            { () in
                if self.isFinished{
                    print("footer")
                    self.populatePhotos()
                    self.collectionView?.mj_footer.endRefreshing()
                } else{
                    self.collectionView?.mj_footer.endRefreshing()
                    self.showMessage("Wait For Loading", animate: 0.5)
                }
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.toolbarHidden = true
    }
    
    func setupView() {
        // Set Title
        self.navigationItem.title = "Any Girls"
        self.view.backgroundColor = UIColor.whiteColor()
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.collectionView?.scrollsToTop = true
        self.collectionView?.frame = CGRectMake(10, 0, self.view.frame.width - 20, self.view.frame.height)


        let layout = UICollectionViewFlowLayout()
        if(view.bounds.size.width > view.bounds.size.height){
            layout.itemSize = CGSize(width: (view.bounds.size.width - 50)/4, height: ((view.bounds.size.width - 50)/4)/225.0*300.0)
        } else{
            layout.itemSize = CGSize(width: (view.bounds.size.width - 50)/3, height: ((view.bounds.size.width - 50)/3)/225.0*300.0)
        }

        
        //print(layout.itemSize)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        collectionView!.collectionViewLayout = layout
        self.collectionView!.registerClass(MainCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }
    
    
    func doClick(sender:UIPanGestureRecognizer){
       closingMenu()
    }
    
    //Add Navigationitem
    func addBarItem(){
        let item = UIBarButtonItem(image: UIImage(named: "Del"), style: UIBarButtonItemStyle.Plain, target: self, action: "deletePics:")
        item.tintColor = UIColor.whiteColor()
        
        let item2 = UIBarButtonItem(image: UIImage(named: "Menu"), style: UIBarButtonItemStyle.Plain, target: self, action: "openMenu:")
        item2.tintColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = item2
        self.navigationItem.rightBarButtonItem = item
    }
    
    @IBAction func openMenu(sender: AnyObject){
        if !isOpenedMenu{
            openingMenu()
        } else{
            closingMenu()
        }
    }
    
    
    func setupMainMenu(){
        mainManu.frame = CGRectMake(-500, topViewHeight * 2, self.view.bounds.size.width * 0.35, self.view.bounds.size.height)
        mainManu.backgroundColor = UIColor.whiteColor()
        mainManu.alpha = 0.98
        mainManu.tag = -1

        // Logo Image
        let logoImage = UIImage(named: "Logo.png")
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.frame = CGRectMake(10, 10, logoImage!.size.width, logoImage!.size.height)
/*
        //
        let animalsButton = UIButton()
        animalsButton.frame = CGRectMake(10, 10 + logoImage!.size.height, 100, 50)
        animalsButton.setTitle("Animals", forState: .Normal)
        animalsButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        animalsButton.addTarget(self, action: "clickAnimals:", forControlEvents: .TouchUpInside)
        
        //
        let landscapeButton = UIButton()
        landscapeButton.frame = CGRectMake(10, 10 + logoImage!.size.height, 100, 50)
        landscapeButton.setTitle("Landscape", forState: .Normal)
        landscapeButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        landscapeButton.addTarget(self, action: "clickLandscape:", forControlEvents: .TouchUpInside)
        
        //
        let girlsButton = UIButton()
        girlsButton.frame = CGRectMake(10, 10 + logoImage!.size.height, 100, 50)
        girlsButton.setTitle("Girls", forState: .Normal)
        girlsButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        girlsButton.addTarget(self, action: "clickGirls:", forControlEvents: .TouchUpInside)
        
        //
        let boysButton = UIButton()
        boysButton.frame = CGRectMake(10, 10 + logoImage!.size.height, 100, 50)
        boysButton.setTitle("Boys", forState: .Normal)
        boysButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        boysButton.addTarget(self, action: "clickBoys:", forControlEvents: .TouchUpInside)
        
        
        //
        let settingButton = UIButton()
        settingButton.frame = CGRectMake(10, 10 + logoImage!.size.height, 100, 50)
        settingButton.setTitle("Setting", forState: .Normal)
        settingButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        settingButton.addTarget(self, action: "clickSetting:", forControlEvents: .TouchUpInside)
        
        //
        let rateButton = UIButton()
        rateButton.frame = CGRectMake(10, 10 + logoImage!.size.height, 100, 50)
        rateButton.setTitle("Rate This App", forState: .Normal)
        rateButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        rateButton.addTarget(self, action: "clickRate:", forControlEvents: .TouchUpInside)
    
   
        
        
        self.mainManu.addSubview(animalsButton)
        self.mainManu.addSubview(landscapeButton)
        self.mainManu.addSubview(girlsButton)
        self.mainManu.addSubview(boysButton)
        self.mainManu.addSubview(settingButton)
        self.mainManu.addSubview(rateButton)
        
*/
        self.mainManu.addSubview(logoImageView)
        
    }
    
    //
    func clickAnimals(sender: UIButton!){
        print("Animals")
    }
    
    //
    func clickLandscape(sender: UIButton!){
        print("Animals")
    }
    
    
    //
    func clickGirls(sender: UIButton!){
        print("Animals")
    }
    
    
    //
    func clickBoys(sender: UIButton!){
        print("Animals")
    }
    
    
    //
    func clickSetting(sender: UIButton!){
        print("Animals")
    }
    
    //
    func clickRate(sender: UIButton!){
        print("About")
    }
    
    //
    func clickAbout(sender: UIButton!){
        print("About")
    }
    
    
    
    
    
    
    
    func openingMenu(){
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blurEffectView.frame = self.view.bounds
        blurEffectView.alpha = 0.2
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        isOpenedMenu = true
        print("openMenu")
        
        self.view.addSubview(blurEffectView)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mainManu.frame = CGRectMake(0, topViewHeight * 2, self.mainManu.frame.size.width, self.mainManu.frame.size.height)
            self.topMenuView.frame = CGRectMake(self.mainManu.frame.size.width, self.navigationController!.navigationBar.frame.size.height + 20, UIScreen.mainScreen().bounds.size.width, topViewHeight)
            self.collectionView?.frame = CGRectMake(10 + self.mainManu.frame.size.width, 0, self.view.frame.width - 20, self.view.frame.height)
            self.view.addSubview(self.mainManu)
            }, completion: { (Bool) -> Void in
                let tap = UITapGestureRecognizer(target: self, action: ("doClick:"))
                blurEffectView.addGestureRecognizer(tap)
        })
        
    }
    
    func closingMenu(){
        isOpenedMenu = false
        print("closeMenu")
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mainManu.frame = CGRectMake(-500, topViewHeight * 2, self.mainManu.frame.size.width, self.mainManu.frame.size.height)
            self.topMenuView.frame = CGRectMake(0, self.navigationController!.navigationBar.frame.size.height + 20, UIScreen.mainScreen().bounds.size.width, topViewHeight)
            self.collectionView?.frame = CGRectMake(10, 0, self.view.frame.width - 20, self.view.frame.height)
            
            }, completion: { (Bool) -> Void in
                self.mainManu.removeFromSuperview()
        })
        
        for subview in self.view.subviews as [UIView]{
            if let v = subview as? UIVisualEffectView{
                v.removeFromSuperview()
            }
        }
    }
    
    // Delete Pics
    @IBAction func deletePics(sender: AnyObject){
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
        // Clear All Pics
        photos.removeAllObjects()
        photosBig.removeAllObjects()
        
        self.currentPage = Int(arc4random_uniform(60) + 2)
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
        let pageUrl = getPageUrl()
        
        let HUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
        HUD.textLabel.text = "Loading"
        HUD.showInView(self.view, animated: true)
        
        self.populatingPhotos = true
        
        // Asychronize Request
        Alamofire.request(.GET, pageUrl).responseString{
            (response) in
            self.populatingPhotos = false
            let isSuccess = response.result.isSuccess
            let html = response.result.value
            //print(html)
            if isSuccess == true{
                // Waiting Sign
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    // Temp
                    var urls = [String]()
                    // Kanna parse html
                    if let doc = Kanna.HTML(html: html!, encoding: NSUTF8StringEncoding){
                        CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII)
                        let lastItem = self.photos.count
                        //print("lastItem \(lastItem)")
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
            }
            HUD.dismiss()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "delayAction:", userInfo: HUD, repeats: false)
    }
    
    func delayAction(timer: NSTimer){
        let HUD = timer.userInfo as! JGProgressHUD
        HUD.dismiss()
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
    
    func showMessage(message: String, animate: Double){
        let HUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
        HUD.textLabel.text = message
        HUD.showInView(self.view, animated: true)
        HUD.dismissAfterDelay(animate);
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
    
            // Do something else
            
            switch orient {
            default:
                print(UIScreen.mainScreen().bounds.size)
                if((self.browser) != nil && !self.browser.exit){
                    let pageBuffer = self.browser.pageBuffer
                    self.browser.removeFromSuperview()
                    self.browser = PhotoBrowserView.initWithPhotos(withUrlArray: self.photosBig.array)
                    // Remote Type
                    self.browser.sourceType = SourceType.REMOTE
                    self.browser.index = pageBuffer
                    self.browser.show()
                }

                
                self.collectionView?.frame = CGRectMake(10, 0, self.view.frame.width - 20, self.view.frame.height)
                
                
                self.topMenuView.frame = CGRectMake(0.0, self.navigationController!.navigationBar.frame.size.height + 20, UIScreen.mainScreen().bounds.size.width, topViewHeight)
            }
            
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
        })
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    
    
}