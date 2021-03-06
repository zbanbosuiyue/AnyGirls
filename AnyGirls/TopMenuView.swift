//
//  TopMenuView.swift
//  AnyGirls
//
//  Created by Rong Zheng on 2/18/16.
//  Copyright © 2016 Rong Zheng. All rights reserved.
//

import UIKit


let topViewHeight: CGFloat = 30.0


protocol TopMenuDelegate {
    func topMenuDidChangedToIndex(index:Int)
}

class TopMenuView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var collection: UICollectionView!
    private var flowLayout: UICollectionViewFlowLayout?
    private var lineView: UIView?
    
    // Top View Meun Background Color
    var bgColor: UIColor?
    
    // Top View Bottom Line
    var lineColor: UIColor?
    
    // Titles for the Menu
    var titles = [NSString]()
    
    // Deletgate to TopMenuDelegate
    var delegate: TopMenuDelegate?
    
    // Current Index
    var currentIndex = 0
    var currentCell:TopMenuViewCell!
    var lastIndexPath: NSIndexPath!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupCollectionView()
        
    }
    
    func setScrollToTop(value: Bool){
        self.collection?.scrollsToTop = value
    }
    
    // Setup Collection
    func setupCollectionView(){
        // Init FlowLayout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .Horizontal
        self.flowLayout = flowLayout
        
        // Init CollectionView
        collection = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
        collection.delegate = self
        collection.dataSource = self
        collection.bounces = true
        collection.backgroundColor = UIColor.whiteColor()
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false

        self.addSubview(collection)
        
        //Init Menu Line
        let bottomView = UIView()
        bottomView.backgroundColor = self.lineColor ?? UIColor.grayColor()
        self.collection!.addSubview(bottomView)
        self.lineView = bottomView
        
        // Register Cell
        self.collection?.registerClass(TopMenuViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func layoutSubviews() {
        self.backgroundColor = bgColor ?? UIColor.whiteColor()
        self.collection?.frame = self.bounds
        var a = CGFloat(2)
        if currentCell != nil{
            a = currentCell!.frame.origin.x
        }
        
        let orient = UIApplication.sharedApplication().statusBarOrientation
        switch orient{
        default:
            if lastIndexPath != nil && collection.cellForItemAtIndexPath(lastIndexPath) != nil {
                let cell = collection.cellForItemAtIndexPath(lastIndexPath)!
                let width = CGRectGetMaxX(cell.frame)
                if width < UIScreen.mainScreen().bounds.size.width {
                    self.setCollectionFrame(cell.frame)
                }
            }
        }
        self.lineView!.frame = CGRectMake(a, topViewHeight - 2, self.titles[currentIndex].sizeByFont(UIFont.systemFontOfSize(14)).width + 20, 2);
    }

    //CollectionViewDataSource method
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.titles.count;
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TopMenuViewCell
        cell.titleName = self.titles[indexPath.item] as String
        cell.backgroundColor = UIColor.clearColor()
        cell.titleColor = UIColor.grayColor()
        
        if indexPath.item == self.titles.count-1 {
            let width = CGRectGetMaxX(cell.frame)
            lastIndexPath = indexPath
            
            if width < UIScreen.mainScreen().bounds.size.width {
                self.setCollectionFrame(cell.frame)
            }
        }
        return cell
    }
    
    // Set CollectionFrame
    func setCollectionFrame(lastItemFrame : CGRect){
        let cWidth:CGFloat = CGRectGetMaxX(lastItemFrame)
        let cHeight:CGFloat = topViewHeight
        let cX:CGFloat = (UIScreen.mainScreen().bounds.width - cWidth)/2.0
        let cY:CGFloat = self.bounds.origin.y
        self.collection!.frame = CGRectMake(cX, cY, cWidth, cHeight)
    }
    
    // UICollectionViewDelegate method
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Move")
        self.moveTopMenu(indexPath)
        currentIndex = indexPath.item
        // When Click Menu Trigger
        self.delegate!.topMenuDidChangedToIndex(indexPath.item)
        
    }
    
    // When Click Move Menu
    func moveTopMenu(indexPath: NSIndexPath){
        print("a")
        let cell = self.collection!.cellForItemAtIndexPath(indexPath) as? TopMenuViewCell
        UIView.animateWithDuration(0.25) { () -> Void in
            self.lineView!.frame = CGRectMake(cell!.frame.origin.x, cell!.frame.size.height-2, cell!.frame.size.width , 2);
        }
        currentCell = cell
        
        var nextIndexPath = NSIndexPath(forItem: indexPath.item+2, inSection: 0)
        if nextIndexPath.item > self.titles.count-1 {
            nextIndexPath = NSIndexPath(forItem: self.titles.count-1, inSection: 0)
        }
        var lastIndexPath = NSIndexPath(forItem: indexPath.item-2, inSection: 0)
        if lastIndexPath.item < 0 {
            lastIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        }
        let visibleItems = self.collection?.indexPathsForVisibleItems()
        
        if let visibleItem = visibleItems  {
            if !contains(visibleItem, value: nextIndexPath) || nextIndexPath.item == self.titles.count-1 {
                print("do")
                self.collection?.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
            }
            if !contains(visibleItem, value: lastIndexPath) || lastIndexPath.item == 0 {
                print("yy")
                self.collection?.scrollToItemAtIndexPath(lastIndexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            }
        }
    }
    
    
    // IsArrayContains
    func contains(array: [AnyObject], value: NSIndexPath)->Bool{
        for item in array{
            if item as! NSObject == value{
                return true
            }
        }
        return false
    }
    
    // UICollectionViewDelegateFlowLayout method
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        let titleSize = self.titles[indexPath.item].sizeByFont(UIFont.systemFontOfSize(14))
        return CGSizeMake(titleSize.width + 20, topViewHeight)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
