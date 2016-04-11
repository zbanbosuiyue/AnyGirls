//
//  ViewController.swift
//  AnyGirls
//
//  Created by Robert on 4/8/16.
//  Copyright © 2016 Rong Zheng. All rights reserved.
//

import UIKit

protocol setToPremiumDelegate{
    func setToPremium(value: Bool)
}

class SettingViewController: UIViewController{
    
    @IBOutlet weak var UpdateSwitch: UISwitch!
    @IBOutlet weak var PremiumSwitch: UISwitch!
    
    var appVersion = "Trail & Test"
    var delegate: setToPremiumDelegate?
    var isPremium: Bool!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView(){
        
        if let value = userDefaults.valueForKey("isPremium"){
            isPremium = value as! Bool
        } else{
            userDefaults.setBool(false, forKey: "isPremium")
            isPremium = false
        }
        
        print("isPremium \(isPremium)")
        if !isPremium{
            PremiumSwitch.on = false
        } else{
            PremiumSwitch.on = true
        }
        
        PremiumSwitch.addTarget(self, action: Selector("PremiumChanged:"), forControlEvents: .TouchUpInside)
        
        
    }
    
    func PremiumChanged(sender: UISwitch){
        if PremiumSwitch.on{
            isPremium = true
            PremiumSwitch.setOn(true, animated: true)
        }
        else{
            isPremium = false
            PremiumSwitch.setOn(false, animated: true)
        }
        
        userDefaults.setBool(isPremium, forKey: "isPremium")
        self.delegate?.setToPremium(isPremium)
        
    }
    
    func goback(sender: AnyObject){
        let settingViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationVController") as! UINavigationController
        
        let window = UIApplication.sharedApplication().windows[0] as UIWindow
        
        UIView.transitionFromView(
            window.rootViewController!.view,
            toView: settingViewController.view,
            duration: 0.65,
            options: .TransitionCrossDissolve,
            completion: {
                finished in window.rootViewController = settingViewController
        })
        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
