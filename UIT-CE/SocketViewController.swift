//
//  SocketViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 9/15/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit

class SocketViewController: UIViewController {
    static let identifier = String(SocketViewController)
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewRearrangeableLayout: KDRearrangeableCollectionViewFlowLayout!
    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    var position: NSIndexPath?
    var data : [String]?
    var imagePicker = UIImagePickerController()
    var Image = [UIImage]()
    var imagesDirectoryPath:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewRearrangeableLayout.draggable = true
        self.collectionViewRearrangeableLayout.axis = .Free
        self.imagePicker.delegate = self
        SD.deleteTable("SD1")
        createTable()
    }
    
    func createTable() {
        if let err = SD.createTable("SD1", withColumnNamesAndTypes: ["Name": .StringVal]) {
            print("Error: Do it again!")
        } else {
            loadData()
        }
    }
    
    func loadData() {
        
        let task: ()->Void = {
            
            if let err = SD.executeChange("INSERT INTO SD1 (Name) VALUES (?)", withArgs: ["ic1"]) {
                
            }
            if let err = SD.createIndex("ic1", onColumns: ["Name"], inTable: "SD1", isUnique: true) {
                print("Index creation failed")
            }
        }
        
        if let err = SD.executeWithConnection(.ReadWrite, closure: task) {
            //there was an error opening or closing the custom connection
        } else {
            print("save sucess")
        }
        
        if let err = SD.executeChange("INSERT INTO SD1 (Name) VALUES (?)", withArgs: ["ic2"]) {
             print("error")
        } else {
             print("save sucess")
        }

    }
    
    /*layout collectionView*/
    func layoutCollectiobView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: (self.view.frame.size.width-1)/2, height: (self.view.frame.size.width-1)/2)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        collectionView!.setCollectionViewLayout(flowLayout, animated: true)
    }

}

extension SocketViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        data = []
        let (resultSet, err) = SD.executeQuery("SELECT * FROM SD1")
        if err != nil {
        } else {
            for row in resultSet {
                if let name = row["Name"]?.asString() {
                    data?.append(name)
                }
            }
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("AlbumCollectionViewCell", forIndexPath: indexPath) as! AlbumCollectionViewCell
        cell.backgroundImage.image = UIImage(named: data![indexPath.row])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
       
        let (resultSet, err) = SD.executeQuery("SELECT * FROM SD1")
        if err != nil {
        } else {
            print((resultSet[indexPath.row]["Name"]!.asString()))
            if let name = resultSet[indexPath.row]["Name"]!.asString() {
                SD.executeQuery("DELETE FROM SD1 WHERE Name='\(name)'")
            }
        }

        self.collectionView.reloadData()
    }
    
    func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) {
        let name = self.Image[fromIndexPath.item]
        self.Image.removeAtIndex(fromIndexPath.item)
        self.Image.insert(name, atIndex: toIndexPath.item)
        position = fromIndexPath
    }
}

extension SocketViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func addButton(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

