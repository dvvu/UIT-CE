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
    var images: [UIImage]?
    var indicator:ProgressIndicator?
    var imagesDirectoryPath:String!
    var numberItems: Int = 0
    
    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    @IBAction func sendButton(sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Sending...", message: "Please, Connect and check with wifi?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
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
        self.topView.addGradientWithColor(UIColor.grayColor())
        self.view.addGradientWithColor(UIColor.darkGrayColor())
        collectionView!.registerNib(UINib(nibName: "ImportPhotoCell", bundle: nil), forCellWithReuseIdentifier: "ImportPhotoCell")
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
        if isExist == false{
            do{
                try NSFileManager.defaultManager().createDirectoryAtPath(imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }
    }
    
    func loadData() {
        let (resultSet, err) = SD.executeQuery("SELECT * FROM ImageData")
        if err != nil {
            //there was an error with the query, handle it here
        } else {
            numberItems = resultSet.count
        }
         self.collectionView.reloadData()
    }
    
    func repareData() {
        images = []
        let (resultSet, err) = SD.executeQuery("SELECT * FROM ImageData")
        if err != nil {
            //there was an error with the query, handle it here
        } else {
            for row in resultSet {
                if let image = row["Path"]?.asString() {
                    print(imagesDirectoryPath)
                    let data = NSFileManager.defaultManager().contentsAtPath(imagesDirectoryPath+image)
                    let image1 = UIImage(data: data!)
                    images?.append(image1!)
                }
            }
        }
        self.collectionView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /* loading data with activity*/
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
            self.conditionSQLite()
            //self.repareData()
            self.loadData()
            dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                self.layoutCollectiobView()
                self.collectionView.dataSource = self
                self.collectionView.delegate = self
                self.imagePicker.delegate = self
                self.indicator!.stop()
            })
        })

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
        return numberItems
    }
   
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ImportPhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("ImportPhotoCell", forIndexPath: indexPath) as! ImportPhotoCell
        self.indicator = ProgressIndicator(inview:cell,loadingViewColor: UIColor.grayColor(), indicatorColor: UIColor.blackColor(), msg: "Loading..")
        cell.addSubview(self.indicator!)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() -> Void in
            
            let (resultSet, err) = SD.executeQuery("SELECT * FROM ImageData")
            if err != nil {
                //there was an error with the query, handle it here
            } else {
                if let image = resultSet[indexPath.row]["Path"]?.asString() {
                    print(self.imagesDirectoryPath)
                    let data = NSFileManager.defaultManager().contentsAtPath(self.imagesDirectoryPath+image)
                    let image1 = UIImage(data: data!)
                  
                    dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                        cell.image.image = image1
                        self.indicator!.stop()
                    })
                }
            }
        })
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       
//        let (resultSet, err) = SD.executeQuery("SELECT * FROM SampleImageTable")
//        if err != nil {
//        } else {
////            if let vc = UIStoryboard.detailViewController() {
////                vc.imageID = resultSet[indexPath.row]["Image"]?.asUIImage()
////                self.presentViewController(vc, animated: true, completion: nil)
////            }
//            
//        }
//        //Delete image
////        let (resultSet, err) = SD.executeQuery("SELECT * FROM SampleImageTable")
////        if err != nil {
////        } else {
////            if let name = resultSet[indexPath.row]["Name"]!.asString() {
////                print(name)
////                SD.executeQuery("DELETE FROM SampleImageTable WHERE Name='\(name)'")
////            }
////        }
////        self.collectionView.reloadData()
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
            self.loadData()
        }
    }
    
    func insertData() {
        do{
            let titles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(imagesDirectoryPath)
            print(titles.description)
            if let err = SD.executeChange("INSERT INTO ImageData (Path) VALUES (?)", withArgs: ["/\(titles[titles.count-1])"]){
                //there was an error inserting the new row, handle it here
            }
            
        }catch{
            print("Error")
        }
    }
    
}
