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
    @IBOutlet weak var connectStatus: UIButton!

    var imagePicker = UIImagePickerController()
    var images: [UIImage]?
    var indicator:ProgressIndicator?
    var imagesDirectoryPath:String!
    var number: Int = 0
    var isLoadMore: Bool = false
    var pageNumber: Int = 1
    var isDelete: Bool = false
    
    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    @IBAction func connectButton(sender: AnyObject) {
   
    }
    
    @IBAction func deleteButton(sender: AnyObject) {
        if isDelete == true {
            isDelete = false
            self.collectionView.backgroundColor = UIColor.whiteColor()
        } else {
            isDelete = true
            self.collectionView.backgroundColor = UIColor.redColor()
        }
    }
    
    @IBAction func addButton(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = ProgressIndicator(inview:self.view,loadingViewColor: UIColor.grayColor(), indicatorColor: UIColor.blackColor(), msg: "Loading..")
        indicator!.start()
        self.view.addSubview(indicator!)
        self.topView.clipsToBounds = true
        self.view.clipsToBounds = true
        self.topView.addGradientWithColor(Colors.primaryBlue())
        self.view.addGradientWithColor(UIColor.whiteColor())
        collectionView!.registerNib(UINib(nibName: "ImportPhotoCell", bundle: nil), forCellWithReuseIdentifier: "ImportPhotoCell")
        
        /* loading data with activity*/
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
            self.conditionSQLite()
            self.RepareData()

            dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                self.layoutCollectiobView()
                self.collectionView.dataSource = self
                self.collectionView.delegate = self
                self.imagePicker.delegate = self
                self.indicator!.stop()
            })
        })
    }
    
    func conditionSQLite() {
        /*Condition to have path*/
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        imagesDirectoryPath = documentDirectorPath.stringByAppendingString("/ImagePicker")
        var objcBool:ObjCBool = true
        let isExist = NSFileManager.defaultManager().fileExistsAtPath(imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false {
            do{
                try NSFileManager.defaultManager().createDirectoryAtPath(imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }
    }
    
    func RepareData() {
        images?.removeAll()
        images = []
        let (resultSet, err) = SD.executeQuery("SELECT * FROM ImageData")
        if err != nil {
            
        } else {
            for row in resultSet {
                if let image = row["Path"]?.asString() {
                    let data = NSFileManager.defaultManager().contentsAtPath(imagesDirectoryPath+image)
                    
                    let image1 = UIImage(data: data!)
                    let image2 = DataProviding.resizeImage(image1!, newWidth: 192)
                    images?.append(image2)
                }
            }
        }
        if let number = images?.count {
            self.number = number
        }
        self.collectionView.reloadData()

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("not enough")
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
        return number
    }
   
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ImportPhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("ImportPhotoCell", forIndexPath: indexPath) as! ImportPhotoCell
        self.indicator = ProgressIndicator(inview:cell,loadingViewColor: UIColor.grayColor(), indicatorColor: UIColor.blackColor(), msg: "Loading..")
        cell.addSubview(self.indicator!)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
            
                dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                    cell.image.image = self.images![indexPath.row]
                })
        })
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if isDelete == true {
            let refreshAlert = UIAlertController(title: "Delete", message: "Do you want to delete this immage?", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                self.deleteImage(indexPath.row)
                self.isDelete = false
                self.collectionView.backgroundColor = UIColor.whiteColor()
               
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "No", style: .Default, handler: { (action: UIAlertAction!) in
            }))
            
            presentViewController(refreshAlert, animated: true, completion: nil)
        } else {
            let (resultSet, err) = SD.executeQuery("SELECT * FROM ImageData")
            if err != nil {
            } else {
                if let image = resultSet[indexPath.row]["Path"]?.asString() {
                    print(image)
                    if let vc = UIStoryboard.detailViewController() {
                        vc.imageURL = image
                        self.presentViewController(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func deleteImage(index: Int) {
        //Delete image
        let (resultSet, err) = SD.executeQuery("SELECT * FROM ImageData")
        if err != nil {
        } else {
            if let name = resultSet[index]["Path"]!.asString() {
                SD.executeQuery("DELETE FROM ImageData WHERE Path='\(name)'")
                do {
                    print(name)
                    try NSFileManager.defaultManager().removeItemAtPath(imagesDirectoryPath + name)
                    print("old image has been removed")
                } catch {
                    print("an error during a removing")
                }
                
            }
        }
        self.RepareData()
        self.collectionView.reloadData()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if collectionView.contentOffset.y > (self.view.frame.size.width-1)*2*CGFloat(pageNumber) {
            pageNumber += 1
            print("load  more")
//            indicator = ProgressIndicator(inview:self.view,loadingViewColor: UIColor.grayColor(), indicatorColor: UIColor.blackColor(), msg: "Loading..")
//            self.view.addSubview(indicator!)
//            indicator!.start()
//            collectionView.userInteractionEnabled = false
        }
        print(collectionView.contentOffset.y)
        print((self.view.frame.size.width-1)*2*CGFloat(pageNumber))
    }
}

extension ImportPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        var imagePath = NSDate().description
        imagePath = imagePath.stringByReplacingOccurrencesOfString(" ", withString: "")
        imagePath = imagesDirectoryPath.stringByAppendingString("/\(imagePath).png")
        let data = UIImagePNGRepresentation(image)
        let success = NSFileManager.defaultManager().createFileAtPath(imagePath, contents: data, attributes: nil)
        dismissViewControllerAnimated(true) { () -> Void in
            self.insertData()
            self.RepareData()
        }
    }
    
    func insertData() {
        do{
            let titles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(imagesDirectoryPath)
            if let err = SD.executeChange("INSERT INTO ImageData (Path) VALUES (?)", withArgs: ["/\(titles[titles.count-1])"]){
                //there was an error inserting the new row, handle it here
            }
        }catch{
            print("Error")
        }
    }
}

