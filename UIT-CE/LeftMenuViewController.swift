//
//  LeftMenuViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 9/10/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit

protocol PageDelegate {
    func onMovePageDelegate(pageName: String)
}

class LeftMenuViewController: UIViewController {
    static let identifier = String(LeftMenuViewController)
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    var Titile: [String]?
    var Image: [String]?
    var mainViewController: UIViewController!
    var swiftViewController: UIViewController!
    var javaViewController: UIViewController!
    var goViewController: UIViewController!
    var nonMenuViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.topView.clipsToBounds = true
        self.view.clipsToBounds = true
//        self.topView.addGradientWithColor(UIColor.grayColor())
        self.view.backgroundColor = Colors.primaryGray()//addGradientWithColor(UIColor.whiteColor())
        
        self.topView.backgroundColor = Colors.primaryTopGray()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView!.registerNib(UINib(nibName: "LeftMenuCell", bundle: nil), forCellWithReuseIdentifier: "LeftMenuCell")
        layoutCollectiobView()
        Titile = ["Home","Display Text","Clock","Import Photo","Draw Image","Setting","Test"]
        Image = ["ic_home1","ui_dislayText","ui_clock","ui_importphto","ui_paint","setting_ic","ui_test"]
    }
    
    func layoutCollectiobView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: self.view.frame.size.width, height: 50)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        collectionView!.setCollectionViewLayout(flowLayout, animated: true)
    }
}

extension LeftMenuViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (Titile?.count)!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: LeftMenuCell = collectionView.dequeueReusableCellWithReuseIdentifier("LeftMenuCell", forIndexPath: indexPath) as! LeftMenuCell
        cell.titleLebel.text = Titile![indexPath.row]
        cell.pictureImage.image = UIImage(named: Image![indexPath.row])
        //cell.frame.size = CGSize(width: self.view.frame.width, height: 50)
        cell.frame.origin.x = 8
        cell.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! LeftMenuCell
        selectedCell.delegate!.onMovePageDelegate(Titile![indexPath.row])
        return true
    }

}

extension LeftMenuViewController: PageDelegate {
    func onMovePageDelegate(pageName: String) {
        if pageName == "Draw Image" {
//            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            var vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("UITDrawViewController") as! UITDrawViewController
//            vc = UINavigationController(rootViewController: vc)
//            self.slideMenuController()?.changeMainViewController(vc, close: true)
            if let vc = UIStoryboard.loadLeftMenuDraw() {
                vc.title = pageName
                vc.view.layoutIfNeeded()
                vc.updateViewConstraints()
                vc.modalPresentationStyle = .PageSheet
                vc.modalTransitionStyle = .CrossDissolve
                self.presentViewController(vc, animated: true, completion: nil)
            }
            
        } else if pageName == "Home" {
            if let vc = UIStoryboard.slideMenuViewController() {
                vc.title = pageName
                vc.modalPresentationStyle = .PageSheet
                vc.modalTransitionStyle = .CrossDissolve
                vc.view.layoutIfNeeded()
                vc.updateViewConstraints()
                self.presentViewController(vc, animated: true, completion: nil)
            }
        } else if pageName == "Setting" {
            if let vc = UIStoryboard.loadLeftMenuSetting() {
                vc.title = pageName
                vc.modalPresentationStyle = .PageSheet
                vc.modalTransitionStyle = .CrossDissolve
                vc.view.layoutIfNeeded()
                vc.updateViewConstraints()
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
            
        else if pageName == "Clock" {
            if let vc = UIStoryboard.loadLeftMenuClock() {
                vc.title = pageName
                vc.modalPresentationStyle = .PageSheet
                vc.modalTransitionStyle = .CrossDissolve
                vc.view.layoutIfNeeded()
                vc.updateViewConstraints()
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
        
        else if pageName == "Display Text" {
            if let vc = UIStoryboard.loadLeftMenuDisplayText() {
                vc.title = pageName
                vc.modalPresentationStyle = .PageSheet
                vc.modalTransitionStyle = .CrossDissolve
                vc.view.layoutIfNeeded()
                vc.updateViewConstraints()
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
        
        else if pageName == "Import Photo" {
            if let vc = UIStoryboard.loadLeftMenuImportPhoto() {
                vc.title = pageName
                vc.modalPresentationStyle = .PageSheet
                vc.modalTransitionStyle = .CrossDissolve
                vc.view.layoutIfNeeded()
                vc.updateViewConstraints()
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
        
        else if pageName == "Test" {
            if let vc = UIStoryboard.loadLeftMenuTest() {
                vc.title = pageName
                vc.modalPresentationStyle = .PageSheet
                vc.modalTransitionStyle = .CrossDissolve
                vc.view.layoutIfNeeded()
                vc.updateViewConstraints()
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
        
    }
}


