//
//  UIStoryboardExtensions.swift
//  LotteVN
//
//  Created by Tuan Luong on 7/9/16.
//  Copyright © 2016 tma. All rights reserved.
//

import Foundation
import SlideMenuControllerSwift

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func leftMenuController() -> LeftMenuViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier(LeftMenuViewController.identifier) as? LeftMenuViewController
    }
    
    class func clockViewController() -> ClockViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier(ClockViewController.identifier) as? ClockViewController
    }
    
    class func detailViewController() -> DetailViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier(DetailViewController.identifier) as? DetailViewController
    }
    
    class func viewController() -> ViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier(ViewController.identifier) as? ViewController
    }
    
    class func uITDrawViewController() -> UITDrawViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier(UITDrawViewController.identifier) as? UITDrawViewController
    }
    
    class func socketViewController() -> SocketViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier(SocketViewController.identifier) as? SocketViewController
    }
    
    class func displayTextViewController() -> DisplayTextViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier(DisplayTextViewController.identifier) as? DisplayTextViewController
    }
    
    class func importPhotoViewController() -> ImportPhotoViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier(ImportPhotoViewController.identifier) as? ImportPhotoViewController
    }
    
    class func testViewController() -> TestViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier(TestViewController.identifier) as? TestViewController
    }
    
    class func settingViewController() -> SettingViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier(SettingViewController.identifier) as? SettingViewController
    }

    
    class func slideMenuViewController() -> SlideMenuController? {
        if let main = viewController() {
            let leftMenu = leftMenuController()
            var width = main.view.frame.size.width - 30
            if main.view.frame.size.width > 450 {
                width = 450
            }
            SlideMenuOptions.leftViewWidth =  width
            return SlideMenuController(mainViewController: main, leftMenuViewController: leftMenu!)
        }
        return nil
    }
    
    
    static func loadLeftMenuDraw() -> SlideMenuController? {
        if let main = uITDrawViewController() {
            let leftMenu = leftMenuController()
            var width = main.view.frame.size.width - 30
            if main.view.frame.size.width > 450 {
                width = 450
            }
            SlideMenuOptions.leftViewWidth =  width
            return SlideMenuController(mainViewController: main, leftMenuViewController: leftMenu!)
        }
        return nil
    }
    
    static func loadLeftMenuClock() -> SlideMenuController? {
        if let main = clockViewController() {
            let leftMenu = leftMenuController()
            var width = main.view.frame.size.width - 30
            if main.view.frame.size.width > 450 {
                width = 450
            }
            SlideMenuOptions.leftViewWidth =  width
            return SlideMenuController(mainViewController: main, leftMenuViewController: leftMenu!)
        }
        return nil
    }
    
    static func loadLeftMenuSocket() -> SlideMenuController? {
        if let main = socketViewController() {
            let leftMenu = leftMenuController()
            var width = main.view.frame.size.width - 30
            if main.view.frame.size.width > 450 {
                width = 450
            }
            SlideMenuOptions.leftViewWidth =  width
            return SlideMenuController(mainViewController: main, leftMenuViewController: leftMenu!)
        }
        return nil
    }
    
    static func loadLeftMenuDisplayText() -> SlideMenuController? {
        if let main = displayTextViewController() {
            let leftMenu = leftMenuController()
            var width = main.view.frame.size.width - 30
            if main.view.frame.size.width > 450 {
                width = 450
            }
            SlideMenuOptions.leftViewWidth =  width
            return SlideMenuController(mainViewController: main, leftMenuViewController: leftMenu!)
        }
        return nil
    }
    
    static func loadLeftMenuImportPhoto() -> SlideMenuController? {
        if let main = importPhotoViewController() {
            let leftMenu = leftMenuController()
            var width = main.view.frame.size.width - 30
            if main.view.frame.size.width > 450 {
                width = 450
            }
            SlideMenuOptions.leftViewWidth =  width
            return SlideMenuController(mainViewController: main, leftMenuViewController: leftMenu!)
        }
        return nil
    }
    
    static func loadLeftMenuSetting() -> SlideMenuController? {
        if let main = settingViewController() {
            let leftMenu = leftMenuController()
            var width = main.view.frame.size.width - 30
            if main.view.frame.size.width > 450 {
                width = 450
            }
            SlideMenuOptions.leftViewWidth =  width
            return SlideMenuController(mainViewController: main, leftMenuViewController: leftMenu!)
        }
        return nil
    }

    
    static func loadLeftMenuTest() -> SlideMenuController? {
        if let main = testViewController() {
            let leftMenu = leftMenuController()
            var width = main.view.frame.size.width - 30
            if main.view.frame.size.width > 450 {
                width = 450
            }
            SlideMenuOptions.leftViewWidth =  width
            return SlideMenuController(mainViewController: main, leftMenuViewController: leftMenu!)
        }
        return nil
    }
    
}