//
//  File.swift
//  AnyGirls
//
//  Created by Rong Zheng on 2/18/16.
//  Copyright © 2016 Rong Zheng. All rights reserved.
//

import UIKit

var statusHeight =  UIApplication.sharedApplication().statusBarFrame.size.height
var screenSize = UIScreen.mainScreen().bounds.size




extension NSString {
    func sizeByFont(font:UIFont) -> CGSize {
        let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
        return self.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: .UsesFontLeading, attributes: attributes as? [String : AnyObject], context: nil).size
    }
    
}

extension UIColor {
    //Set RandomColor
    class func randomColor() ->UIColor {
        let randomRed = CGFloat(arc4random_uniform(256))
        let randomGreen = CGFloat(arc4random_uniform(256))
        let randomBlue = CGFloat(arc4random_uniform(256))
        return UIColor(red: randomRed/255.0, green: randomGreen/255.0, blue: randomBlue/255.0, alpha: 1.0)
    }
    

    class func mainColor() ->UIColor{
        //        return UIColor(red: 231/255, green: 45/255, blue: 48/255, alpha: 1)
        return UIColor.whiteColor()
    }
    
}




// Pics Classify
enum PageType: String {
    case boobs = "2" //1
    case booty  = "6"  //2
    case stocking = "7"    //3
    case legs  = "3"    //4
    case face = "4" //5
    case random  = "5" //6
}




// PhotoUtil
class PhotoUtil {
    static let imageSource: String = "5442.com"
    
    // Use Int to get PageType
    static func selectTypeByNumber(number: Int)->PageType{
        switch number{
        case 0:
            return .boobs
        case 1:
            return .booty
        case 2:
            return .stocking
        case 3:
            return .legs
        case 4:
            return .face
        case 5:
            return .random
        default:
            return .boobs
        }
    }
}
