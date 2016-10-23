//
//  ImportPhotoViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 9/17/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit

class ImportPhotoViewController: UIViewController {
    static let identifier = String(ImportPhotoViewController)
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var imagePicker = UIImagePickerController()
    var Image = [UIImage]()
    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
   // var ImageArray = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()
        loaddingData()
        self.topView.clipsToBounds = true
        self.view.clipsToBounds = true
        self.topView.addGradientWithColor(UIColor.grayColor())
        self.view.addGradientWithColor(UIColor.darkGrayColor())
        
        //self.imagePicker.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.imagePicker.delegate = self
        collectionView!.registerNib(UINib(nibName: "ImportPhotoCell", bundle: nil), forCellWithReuseIdentifier: "ImportPhotoCell")
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutCollectiobView()
    }
    
    func loaddingData() {
        Image = []
        let (resultSet, err) = SD.executeQuery("SELECT * FROM SampleImageTable")
        if err != nil {
            //there was an error with the query, handle it here
        } else {
            for row in resultSet {
                if let image = row["Image"]?.asUIImage() {
                    Image += [image]
                }
            }
        }
    }
    
    func layoutCollectiobView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: (self.view.frame.size.width-1)/2, height: (self.view.frame.size.width-1)/2)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        collectionView!.setCollectionViewLayout(flowLayout, animated: true)
    }
    
}

extension ImportPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
   
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Image.count
    }
   
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ImportPhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("ImportPhotoCell", forIndexPath: indexPath) as! ImportPhotoCell
        cell.image.image = Image[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       
        let (resultSet, err) = SD.executeQuery("SELECT * FROM SampleImageTable")
        if err != nil {
        } else {
            if let vc = UIStoryboard.detailViewController() {
                vc.imageID = resultSet[indexPath.row]["Image"]?.asUIImage()
                self.presentViewController(vc, animated: true, completion: nil)
            }
            
        }
        //Delete image
//        let (resultSet, err) = SD.executeQuery("SELECT * FROM SampleImageTable")
//        if err != nil {
//        } else {
//            if let name = resultSet[indexPath.row]["Name"]!.asString() {
//                print(name)
//                SD.executeQuery("DELETE FROM SampleImageTable WHERE Name='\(name)'")
//            }
//        }
//        self.collectionView.reloadData()
    }
    

}

extension ImportPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func addButton(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let imageID = SD.saveUIImage(pickedImage) {
            if let err = SD.executeChange("INSERT INTO SampleImageTable (Name, Image) VALUES (?, ?)", withArgs: [imageID+" ", imageID]) {
                //there was an error inserting the new row, handle it here
            }
        }
            self.loaddingData()
            self.collectionView.reloadData()
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
