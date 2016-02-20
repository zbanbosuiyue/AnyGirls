//
//  TopMenuViewController.swift
//  AnyGirls
//
//  Created by Rong Zheng on 2/18/16.
//  Copyright © 2016 Rong Zheng. All rights reserved.
//

import UIKit
private let reuseIdentifier = "mainCell"
class TopMenuViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,TopMenuDelegate{
    var menuView:TopMenuView!
    var collectionView:UICollectionView?
    var con:UITableViewController?
    
    //用来存放menu 对应的控制器
    var vcList = [UITableViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
        let menuView = TopMenuView(frame: CGRectMake(0, statusHeight + navBarHeight , screenSize.width, 40))
        menuView.bgColor = UIColor.grayColor()
        menuView.delegate = self
        menuView.titles = ["首页", "最新","美图","轻松一刻","最新资讯","娱乐明星","芜湖乐呵"]
        self.menuView = menuView
        self.view.addSubview(menuView)
        
        
        self.setupCollectionView()
        //设置menu对应的控制器
        self.setupVCList()
        
    }
    //给vcList赋值
    func setupVCList(){
        if vcList.count == 0 {
            for _ in 1...self.menuView.titles.count {
                let vc = TopMenuTableViewController()
                self.vcList.append(vc)
            }
        }
    }
    
    //MARK: - TopMenuDelegate 代理方法
    func topMenuDidChangedToIndex(index:Int){
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        self.collectionView!.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
    }
    
    func setupCollectionView(){
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .Horizontal
        let cY = CGRectGetMaxY(self.menuView.frame)
        flowLayout.itemSize = CGSizeMake(screenSize.width, screenSize.height - cY)
        
        let collectionView = UICollectionView(frame: CGRectMake(0, cY, screenSize.width, screenSize.height - cY), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        self.collectionView = collectionView
        self.view.addSubview(collectionView)
        collectionView.pagingEnabled = true
        collectionView.bounces = false
        
        //注册cell
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.tag = 0
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Collection view data source
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuView.titles.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        
        let vc = self.vcList[indexPath.row] as UITableViewController
        //此处必须定义成属性不然会出问题
        vc.view.frame = cell.bounds
        cell.contentView.addSubview(vc.view!)
        
        
        return cell
    }
    //MARK: - CollectionViewDelegate method
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let nowIndexPath: NSIndexPath? = self.collectionView!.indexPathsForVisibleItems().last
        //切换顶部红色滚动条
        if let nowIndex = nowIndexPath{
            self.menuView.moveTopMenu(nowIndex)
        }
        
    }
}
