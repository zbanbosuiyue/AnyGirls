//
//  File.swift
//  AnyGirls
//
//  Created by Rong Zheng on 2/18/16.
//  Copyright © 2016 Rong Zheng. All rights reserved.
//

import UIKit
import JGProgressHUD
import SDWebImage

let statusHeight =  UIApplication.sharedApplication().statusBarFrame.size.height

let girlImageURL: String = "http://www.dbmeinv.com/dbgroup/show.htm?cid="
let ImageSourceURL: String = "https://wallpaperscraft.com/catalog/"
let imageBaseUrl = "http://www.dbmeinv.com/dbgroup/rank.htm?pager_offset="
let reuseIdentifier = "Cell"

let wallpaperTitles = [" Animals ", " Anime ", " Cars ", " City ", " Flowers ", " Games ", " Girls ", " Men "]
let girlsTitles = [" Face ", " Stocking ", " Legs ", " Random "]
let boysTitles = [" Face ", " Stocking ", " Legs ", " Random "]


let wallpaperTitlesPremium = [" All ", " 3D ", "  Abstract ", " Animals ", " Anime ", " Brands ", " Cars ", " City ",
    " Fantasy ", " Flowers ", " Food ", " Games ", " Girls ", " Hi-Tech ", " Holidays ",
    " Macro ", " Men ", " Movies ", " Music ", " Nature ", " Space ", " Sport ", " Texture ",
    " TV Series ", " Vector " ," Other "]

let girlsTitlesPremium = [" Face ", " Stocking ", " Legs ", " Random ", " Boobs " , " Booty ", " All "]


let navigationTitles = [" Wallpapper ", " Girls ", " Boys "]


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


// Creates a UIColor from a Hex string.
extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}



// Pics Classify
enum PageType: String {
    case stocking = "7"
    case legs  = "3"
    case face = "4"
    case random  = "5"
    case boobs = "2"
    case booty = "6"
    case allGirl = "none"
    
    //Wallpaper
    case all = ""
    case threeD = "3d"
    case abstract = "abstract"
    case animals = "animals"
    case anime = "anime"
    case brands = "brands"
    case cars = "cars"
    case city = "city"
    case fantasy = "fantasy"
    case flowers = "flowers"
    case food = "food"
    case games = "games"
    case girls = "girls"
    case hitech = "hi-tech"
    case holidays = "holidays"
    case macro = "macro"
    case men = "men"
    case movies = "movies"
    case music = "music"
    case nature = "nature"
    case other = "other"
    case space = "space"
    case sport = "sport"
    case textures = "textures"
    case tvseries = "tv-series"
    case vector = "vector"
    
}

let CategoryType:[String: Int] =
[
    "Wallpaper" : 0,
    "Girls" : 1,
    "Boys" : 2,
    "AboutUs" : 3,
    "Setting" : 4,
    "ShareUs" : 5,
    "RateUs" : 6
]




// PhotoUtil
class PhotoUtil {
    // Use Int to get PageType
    static func selectTypeByNumber(type: Int, number: Int)->PageType{
        switch type{
            
            case 0:
                switch number{
                case 0:
                    return .animals
                case 1:
                    return .anime
                case 2:
                    return .cars
                case 3:
                    return .city
                case 4:
                    return .flowers
                case 5:
                    return .games
                case 6:
                    return .girls
                case 7:
                    return .men
                default:
                    return .animals
            }
            
            case 1:
                switch number{
                case 0:
                    return .face
                case 1:
                    return .stocking
                case 2:
                    return .legs
                case 3:
                    return .random
                case 4:
                    return .boobs
                case 5:
                    return .booty

                default:
                    return .face
            }
            default:
                return .animals
            
        }
    }
    
    static func selectTitlesByType(type: Int) ->[String]{
        switch type{
            case 0:
                return wallpaperTitles
            case 1:
                return girlsTitles
            case 2:
                return boysTitles
            default:
                return wallpaperTitles
        }
    }
}



class PhotoUtilPremium {
    static func selectTypeByNumber(type: Int, number: Int)->PageType{
        switch type{
            
        case 0:
            switch number{
            case 0:
                return .all
            case 1:
                return .threeD
            case 2:
                return .abstract
            case 3:
                return .animals
            case 4:
                return .anime
            case 5:
                return .brands
            case 6:
                return .cars
            case 7:
                return .city
            case 8:
                return .fantasy
            case 9:
                return .flowers
            case 10:
                return .food
            case 11:
                return .games
            case 12:
                return .girls
            case 13:
                return .hitech
            case 14:
                return .holidays
            case 15:
                return .macro
            case 16:
                return .men
            case 17:
                return .movies
            case 18:
                return .music
            case 19:
                return .nature
            case 20:
                return .space
            case 21:
                return .sport
            case 22:
                return .textures
            case 23:
                return .tvseries
            case 24:
                return .vector
            case 25:
                return .other
            default: return .all
            }
            
        case 1:
            switch number{
            case 0:
                return .face
            case 1:
                return .stocking
            case 2:
                return .legs
            case 3:
                return .random
            case 4:
                return .boobs
            case 5:
                return .booty
            case 6:
                return .allGirl
            default:
                return .face
            }
        default:
            return .animals
            
        }
    }
    
    static func selectTitlesByType(type: Int) ->[String]{
        switch type{
        case 0:
            return wallpaperTitlesPremium
        case 1:
            return girlsTitlesPremium
        case 2:
            return boysTitles
        default:
            return wallpaperTitlesPremium
        }
    }
}






