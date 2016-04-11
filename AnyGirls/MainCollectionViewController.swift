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

var navBarHeight:CGFloat! = 0

class MainCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, TopMenuDelegate, TableMenuDelegate, setToPremiumDelegate{

    var photos = NSMutableOrderedSet()
    var photosBig = NSMutableOrderedSet()
    
    //    var layout: MainCollectionViewLayout?
    var isBegin = true
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
    var isPremium:Bool!
    var isOpenedMenu = false
    var isGot = false   //Is Got Data
    var isChangedCategory = false
    
    
    var mainMenu: UIView!
    var topMenuView:TopMenuView!

    
    var collectionFrame:CGRect!
    

    var currentPage = Int(arc4random_uniform(10) + 2) //PageIndexLocater

    var lastCategory = 0
    
    var category  = CategoryType["Wallpaper"]!{
        didSet{
            if category != oldValue{
                isChangedCategory = true
            } else{
                isChangedCategory = false
            }
            lastCategory = oldValue
        }
    }
    
    var collectionLayout:UICollectionViewFlowLayout!
    
    var currentType: PageType = .animals
    var browser:PhotoBrowserView!
    
    let menuTitles = [" Wallpaper ", " Girls ", " Boys ", " About Us ", " Setting ", " Share Us ", " Rate Us "]
    
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let value = NSUserDefaults.standardUserDefaults().valueForKey("isPremium"){
            isPremium = value as! Bool
        } else{
            isPremium = false
            NSUserDefaults.standardUserDefaults().setBool(isPremium, forKey: "isPremium")
        }
        
        setupAll()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    func setupAll(){
        // Setup View
        setupCollectionView()
        
        // InitTopMenu
        initTopMenu()
        
        // setup MainMenu
        setupMainMenu()
        
        if isBegin{
            // Get the pics
            populatePhotos()
            // Add Bar Item
            addBarItem()
            
            isBegin = false
        }


    }
    
    func getPageUrl(index: Int)-> String{
        var pageBuffer:String
        switch index{
            case 0:
                pageBuffer = ImageSourceURL + currentType.rawValue + "/page" + "\(self.currentPage)"
            case 1:
                pageBuffer = girlImageURL + currentType.rawValue + "&pager_offset=" + "\(self.currentPage)"
                if currentType.rawValue == "none"{
                    pageBuffer = girlImageURL + "&pager_offset=" + "\(self.currentPage)"
                }
            default:
                pageBuffer = ImageSourceURL + currentType.rawValue + "/page" + "\(self.currentPage)"
        }
            return pageBuffer
    }

    
    func initTopMenu(){
        // Set Location of TopMenu
        if topMenuView != nil{
            topMenuView.removeFromSuperview()
        }
        topMenuView = TopMenuView(frame: CGRectMake(0, navBarHeight + topViewHeight - 10, UIScreen.mainScreen().bounds.size.width, topViewHeight))
    
        topMenuView.bgColor = UIColor.whiteColor()
        topMenuView.lineColor = UIColor.grayColor()
        topMenuView.delegate = self
        topMenuView.layer.shadowColor = UIColor.grayColor().CGColor
        topMenuView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        topMenuView.layer.shadowOpacity = 0.8
        topMenuView.layer.shadowRadius = 2.0
        //Set Menu Titles
        
        if !isPremium{
            topMenuView.titles = PhotoUtil.selectTitlesByType(category)
        }
        else{
            topMenuView.titles = PhotoUtilPremium.selectTitlesByType(category)
        }
        
        
        //Close Scrolltotop
        topMenuView.setScrollToTop(false)
        
        self.view.addSubview(topMenuView)
    }
    
    //  Click Trigger
    func topMenuDidChangedToIndex(index:Int){
        self.navigationItem.title = self.topMenuView.titles[index] as String
        if !isPremium{
            currentType = PhotoUtil.selectTypeByNumber(category, number: index)
        }else{
            currentType = PhotoUtilPremium.selectTypeByNumber(category, number: index)
        }
        
        // Clear All Pics and Return to Page X
        handleRefresh()
    }
    
    func tableMenuDidChangedToIndex(index:Int){
        category = index
        if category < 3{
            removeBlurEffect()
            currentType = PhotoUtil.selectTypeByNumber(category, number: 0)
            setupCollectionView()
            initTopMenu()
            setupMainMenu()
            
            handleRefresh()
            isOpenedMenu = false
        }
        else{
            switch category{
            case CategoryType["Setting"]!:
                performSegueWithIdentifier("SettingViewController", sender: self)
            case CategoryType["ShareUs"]!:
                performSegueWithIdentifier("ShareUsViewController", sender: self)
            case CategoryType["AboutUs"]!:
                performSegueWithIdentifier("AboutUsViewController", sender: self)
            case CategoryType["RateUs"]!:
                performSegueWithIdentifier("RateUsViewController", sender: self)
            default:
                performSegueWithIdentifier("SettingViewController", sender: self)
            }
            //closingMenu()
            category = lastCategory
        }
    }
    
    func setToPremium(value: Bool) {
        isPremium = value
        closingMenu()
        initTopMenu()
        handleRefresh()
    }
    
    func configureRefresh(){
        self.collectionView!.mj_header = MJRefreshNormalHeader(refreshingBlock:
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
        
        self.collectionView!.mj_footer = MJRefreshAutoFooter(refreshingBlock:
            { () in
                if self.isFinished{
                    print("footer")
                    self.collectionView?.mj_footer.endRefreshing()
                    self.showMessage("Loading", animate: 0.5)
                    self.populatePhotos()
                } else{
                    self.collectionView?.mj_footer.endRefreshing()
                    self.showMessage("Wait For Loading", animate: 0.5)
                }
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.toolbarHidden = true
    }
    
    func setupCollectionView() {
        if isBegin{
            collectionFrame = CGRectMake(10, 0, self.view.frame.width - 20, self.view.frame.height)
    
            navBarHeight = self.navigationController?.navigationBar.frame.height
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.barTintColor = UIColor(rgb: 0xFF420E)
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
            self.navigationController?.navigationBar.layer.shadowColor = UIColor(rgb: 0x601905).CGColor
            self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            self.navigationController?.navigationBar.layer.shadowOpacity = 0.8
            self.navigationController?.navigationBar.layer.shadowRadius = 2.0
            self.view.backgroundColor = UIColor.whiteColor()
        
        } else{
            collectionFrame = CGRectMake(10, statusHeight + topViewHeight + 15, self.view.frame.width - 20, self.view.frame.height)
        }
        
        setupCollectionLayout()
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionLayout)
        self.collectionView?.frame = collectionFrame
        
        configureRefresh()
        
        // Set Title
        
        if category < 3{
            self.navigationItem.title = navigationTitles[category]
        }
        else{
            self.navigationItem.title = "Any Images"
        }
        

        
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.collectionView?.scrollsToTop = true
        self.collectionView!.registerClass(MainCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func setupCollectionLayout(){
        if collectionLayout == nil{
            collectionLayout = UICollectionViewFlowLayout()
        }
        
        if(view.bounds.size.width > view.bounds.size.height){
            if category == CategoryType["Wallpaper"]{
                collectionLayout.itemSize = CGSize(width: (view.bounds.size.width - 50)/3, height: ((view.bounds.size.width - 50)/3)/1080.0*760.0)
            } else{
                collectionLayout.itemSize = CGSize(width: (view.bounds.size.width - 50)/4, height: ((view.bounds.size.width - 50)/4)/225.0*300.0)
            }
            
        } else{
            if category == CategoryType["Wallpaper"]{
                collectionLayout.itemSize = CGSize(width: (view.bounds.size.width - 50)/2, height: ((view.bounds.size.width - 50)/2)/1080.0*760.0)
            } else{
                collectionLayout.itemSize = CGSize(width: (view.bounds.size.width - 50)/3, height: ((view.bounds.size.width - 50)/3)/225.0*300.0)
            }
        }
        
        collectionLayout.minimumInteritemSpacing = 10
        collectionLayout.minimumLineSpacing = 10
    }
    
    func doClick(sender:UITapGestureRecognizer){
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
        if mainMenu != nil{
            mainMenu.removeFromSuperview()
        }
        
        mainMenu = UIView()
        if self.view.frame.width < self.view.frame.height{
            mainMenu.frame = CGRectMake(-self.view.bounds.size.width * 0.6, topViewHeight + 30, self.view.bounds.size.width * 0.6, self.view.bounds.size.height + 200)
        } else{
            mainMenu.frame = CGRectMake(-self.view.bounds.size.width * 0.6, topViewHeight + 20, self.view.bounds.size.width * 0.6, self.view.bounds.size.height + 200)
        }
       
        mainMenu.backgroundColor = UIColor(rgb: 0xF98866)
        
        mainMenu.layer.shadowColor = UIColor.grayColor().CGColor
        mainMenu.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        mainMenu.layer.shadowOpacity = 0.8
        mainMenu.layer.shadowRadius = 2.0
        mainMenu.tag = -1

        // Logo Image
        let logoImage = UIImage(named: "Logo.png")
        let logoImageView = UIImageView(image: logoImage)
        let tap = UITapGestureRecognizer(target: self, action: Selector("doClick:"))
        logoImageView.frame = CGRectMake(10, 10, logoImage!.size.width, logoImage!.size.height)
        logoImageView.userInteractionEnabled = true
        logoImageView.addGestureRecognizer(tap)
        

        self.mainMenu.addSubview(logoImageView)
        let tableMenu:TableMenuView!
        if self.view.frame.width > self.view.frame.height{
            tableMenu = TableMenuView(frame:CGRectMake(0, 20 + logoImage!.size.height, self.mainMenu.frame.size.width - 20, 150))
        }else{
            tableMenu = TableMenuView(frame:CGRectMake(0, 20 + logoImage!.size.height, self.mainMenu.frame.size.width - 20, self.view.frame.height))
        }
        
        tableMenu.titles = menuTitles

        tableMenu.delegate = self
        self.mainMenu.addSubview(tableMenu)
        
    }
    

    func openingMenu(){
        print("openMenu")
        
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
        blurEffectView.frame = self.view.bounds
        blurEffectView.alpha = 0.2
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(blurEffectView)
        
        self.view.addSubview(mainMenu)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mainMenu.frame = self.mainMenu.frame.offsetBy(dx: self.mainMenu.frame.width, dy: 0)
            self.topMenuView.frame = self.topMenuView.frame.offsetBy(dx: self.mainMenu.frame.width, dy: 0)
            self.collectionView?.frame = (self.collectionView?.frame.offsetBy(dx: self.mainMenu.frame.width, dy: 0))!
            
            }, completion: { (Bool) -> Void in
                let tap = UITapGestureRecognizer(target: self, action: Selector("doClick:"))
                blurEffectView.addGestureRecognizer(tap)
        })
        isOpenedMenu = true
        
    }
    
    func closingMenu(){
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mainMenu.frame = self.mainMenu.frame.offsetBy(dx: -self.mainMenu.frame.size.width, dy: 0)
            self.topMenuView.frame = self.topMenuView.frame.offsetBy(dx: -self.mainMenu.frame.size.width, dy: 0)
            self.collectionView?.frame = (self.collectionView?.frame.offsetBy(dx: -self.mainMenu.frame.size.width, dy: 0))!
            }, completion: { (Bool) -> Void in
        })
        
        removeBlurEffect()
        isOpenedMenu = false
        //self.topMenuView.removeFromSuperview()
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
        SDImageCache.sharedImageCache().clearDisk()
        photos.removeAllObjects()
        photosBig.removeAllObjects()
        
        self.currentPage = Int(arc4random_uniform(40) + 2)
        self.collectionView?.reloadData()
        
        populatePhotos()
    }
    
    func transformUrl(urls: [String]){
        switch category{
        case CategoryType["Girls"]!:
            for url in urls{
                let urlBig = url.stringByReplacingOccurrencesOfString("bmiddle", withString: "large")
                photosBig.addObject(urlBig)
            }
            
        case CategoryType["Wallpaper"]!:
            for url in urls{
                let urlBig = url.stringByReplacingOccurrencesOfString("300x188", withString: "1920x1080")
                photosBig.addObject(urlBig)
            }
            
        default:
            for url in urls{
                let urlBig = url.stringByReplacingOccurrencesOfString("bmiddle", withString: "large")
                photosBig.addObject(urlBig)
            }
        }

    }

    
    // Get Photos From Web
    func populatePhotos(){
        for subview in (self.collectionView?.subviews)! as [UIView]{
            if subview.tag == -1 {
                subview.removeFromSuperview()
            }
        }
        
        let pageUrl = getPageUrl(category)
        let HUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
        HUD.textLabel.text = "Loading"
        HUD.tag = -1
        HUD.showInRect(self.view.frame.offsetBy(dx: 0, dy: -100), inView: self.collectionView, animated: true)
        
        self.populatingPhotos = true
        print(pageUrl)
        // Asychronize Request
        Alamofire.request(.GET, pageUrl).responseString{
            (response) in
            self.populatingPhotos = false
            let isSuccess = response.result.isSuccess
            let html = response.result.value
            if isSuccess == true{
                // Waiting Sign
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    // Temp
                    var urls = [String]()
                    // Kanna parse html
                    if let doc = Kanna.HTML(html: html!, encoding: NSUTF8StringEncoding){
                        CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingASCII)
                        let lastItem = self.photos.count
                        // Parse Images
                        for node in doc.css("img"){
                            if self.category == CategoryType["Wallpaper"]{
                                if node["src"]!.containsString(".jpg"){
                                    urls.append("http:" + node["src"]!)
                                }
                            }
                            else{
                                if node["src"]!.containsString(".jpg"){
                                    urls.append(node["src"]!)
                                }
                            }
                            self.isGot = true
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
        
        //timer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "delayAction:", userInfo: HUD, repeats: false)
        
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
        if isOpenedMenu{
            isOpenedMenu = false
            self.mainMenu.removeFromSuperview()
            self.removeBlurEffect()
        }
        let orient = UIApplication.sharedApplication().statusBarOrientation
        
        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            switch orient.rawValue {
            default:
                self.orientationHandler()
            }
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                self.setupCollectionView()
                self.view.addSubview(self.topMenuView)
                self.setupMainMenu()
        })
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    }
    
    func orientationHandler(){
        //NavBar Height Changed
        navBarHeight = self.navigationController?.navigationBar.frame.height
        topMenuView.frame = CGRectMake(0, navBarHeight + topViewHeight - 10, self.view.frame.width, topViewHeight)
        
        if((self.browser) != nil && !self.browser.exit){
            let pageBuffer = self.browser.pageBuffer
            self.browser.removeFromSuperview()
            self.browser = PhotoBrowserView.initWithPhotos(withUrlArray: self.photosBig.array)
            // Remote Type
            self.browser.sourceType = SourceType.REMOTE
            self.browser.index = pageBuffer
            self.browser.show()
        }
    }
    
    func removeBlurEffect(){
        for subview in self.view.subviews as [UIView]{
            if let v = subview as? UIVisualEffectView{
                v.removeFromSuperview()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        switch segue.identifier!{
        case "SettingViewController":
            let next = segue.destinationViewController as! SettingViewController
            next.delegate = self
        case "ShareUsViewController":
            let next = segue.destinationViewController as! ShareUsViewController
        case "AboutUsViewController":
            let next = segue.destinationViewController as! AboutUsViewController
        case "RateUsViewController":
            let next = segue.destinationViewController as! RateUsViewController
        default:
            let next = segue.destinationViewController
        }
    }
    
    @objc(SEPushNoAnimationSegue)
    class SEPushNoAnimationSegue: UIStoryboardSegue{
        override func perform() {
            let src = self.sourceViewController as UIViewController
            let dst = self.destinationViewController as UIViewController
            src.navigationController!.pushViewController(dst, animated:false)
        }
    }
    
    
    
}