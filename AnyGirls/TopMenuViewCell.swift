//
//  TopMenuViewCell.swift
//  AnyGirls
//
//  Created by Rong Zheng on 2/18/16.
//  Copyright © 2016 Rong Zheng. All rights reserved.
//

import UIKit

class TopMenuViewCell: UICollectionViewCell {
    var titleColor:UIColor = UIColor.blackColor() {
        willSet{
            self.titleLabel?.textColor = newValue as UIColor
        }
    }
    var titleName:NSString {
        get{
            return self.titleName
        }
        set{
            self.titleLabel?.text = newValue as String
        }
        
    }
    var titleLabel:UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLable()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupLable()
    }
    
    func setupLable(){
        self.backgroundColor = UIColor.groupTableViewBackgroundColor()
        let titleLabel = UILabel()
        titleLabel.textAlignment = NSTextAlignment.Center
        
        titleLabel.font = UIFont.systemFontOfSize(14)
        self.addSubview(titleLabel)
        self.titleLabel = titleLabel
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel?.frame = self.bounds
        self.titleLabel?.textColor = self.titleColor
    }
    

}
