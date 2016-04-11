//
//  TableViewController.swift
//  AnyGirls
//
//  Created by Rong Zheng on 3/31/16.
//  Copyright © 2016 Rong Zheng. All rights reserved.
//

import UIKit

protocol TableMenuDelegate{
    func tableMenuDidChangedToIndex(index:Int)
}

class TableMenuView: UIView, UITableViewDataSource, UITableViewDelegate {
    var titles = [NSString]()
    var category = 0
    var delegate : TableMenuDelegate?
    var tableView : UITableView?
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.setupTableMenu(frame)
    }
    
    func setupTableMenu(frame: CGRect){
        
        let tableView = UITableView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height + navBarHeight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.whiteColor()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.backgroundColor = UIColor.clearColor()

        //tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        self.addSubview(tableView)

        self.tableView = tableView
        self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    
    //MARK: - Tableview Delegate & Datasource
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        
        return titles.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.text = titles[indexPath.item] as String
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 18)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        
        cell.layer.shadowColor = UIColor.grayColor().CGColor
        cell.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowRadius = 0.5
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        category = indexPath.item
        self.delegate!.tableMenuDidChangedToIndex(indexPath.item)
        print("category \(category)")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
