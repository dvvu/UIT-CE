//
//  ViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 8/14/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift


class ViewController: UIViewController { //UIImagePickerControllerDelegate, UINavigationControllerDelegate
    static let identifier = String(ViewController)
    @IBOutlet weak var randomImage: UIImageView!
    @IBOutlet var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var vans: UILabel!
    @IBOutlet weak var port: UILabel!
    @IBOutlet weak var rDelay: UILabel!
    @IBOutlet weak var iDelay: UILabel!
    @IBOutlet weak var ip: UILabel!
    
    
//    var actionButton: ActionButton!
//    var imagePicker = UIImagePickerController()
    var left: LeftMenuViewController?
    var indicator:ProgressIndicator?
    var Image = [UIImage]()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)        
        //SD.deleteTable("SampleImageTable")
        //SD.deleteTable("Setting")
        //SD.deleteTable("ImageData")
        createTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view2.clipsToBounds = true
        self.viewMain.clipsToBounds = true
        self.view2.addGradientWithColor(UIColor.grayColor())
        self.viewMain.addGradientWithColor(UIColor.darkGrayColor())
        collectionView!.registerNib(UINib(nibName: "ImportPhotoCell", bundle: nil), forCellWithReuseIdentifier: "ImportPhotoCell")
        layoutCollectiobView()
        
        indicator = ProgressIndicator(inview:self.view,loadingViewColor: UIColor.grayColor(), indicatorColor: UIColor.blackColor(), msg: "Loading..")
        self.view.addSubview(indicator!)
        indicator!.start()
        loaddingData()
        loaddingSetting()
    }
    
    func loaddingSetting() {
        let (resultSet, err) = SD.executeQuery("SELECT * FROM Setting")
        if err != nil {
            print(" Error in loading Data")
        } else {
            print(resultSet.count)
            vans.text = resultSet[0]["Van"]?.asInt()?.description
            rDelay.text = resultSet[0]["DRow"]?.asInt()?.description
            iDelay.text = resultSet[0]["DImage"]?.asInt()?.description
            //textField3.text = resultSet[0]["Value"]?.asInt()?.description
            ip.text = resultSet[0]["IP"]?.asString()
            port.text = resultSet[0]["Port"]?.asInt()?.description
        }
    }
    
    func layoutCollectiobView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: (self.view.frame.size.width-1)/2, height: (self.view.frame.size.width-1)/2)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        flowLayout.scrollDirection = .Horizontal
        collectionView!.setCollectionViewLayout(flowLayout, animated: true)
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
        indicator!.stop()
    }
    
    func createTable() {
        
        /*Table image*/
        if let err = SD.createTable("ImageData", withColumnNamesAndTypes: ["Path": .StringVal]) {
            print("Error: Do it again!")
        } else {
            
        }
        
        /*Table image*/
        if let err = SD.createTable("SampleImageTable", withColumnNamesAndTypes: ["Name": .StringVal, "Image": .UIImageVal]) {
            print("Error: Do it again!")
        } else {
            let image = UIImage(named:"ic1")
            if let imageID = SD.saveUIImage(image!) {
                if let err = SD.executeChange("INSERT INTO SampleImageTable (Name, Image) VALUES (?, ?)", withArgs: ["ic1", imageID]) {
                    //there was an error inserting the new row, handle it here
                }
            }
        }
        
        /*Table setting*/
        if let err = SD.createTable("Setting", withColumnNamesAndTypes: ["Van": .IntVal, "DRow": .IntVal, "DImage": .IntVal, "Value": .IntVal, "IP": .StringVal, "Port": .IntVal]) {
            print("Error: Do it again!")
        } else {
            if let err = SD.executeChange("INSERT INTO Setting (Van, DRow, DImage, Value, IP, Port) VALUES (?, ?, ?, ?, ?, ?)", withArgs: [168,500,1000,127,"192.168.1.1",90]) {
            }
        }
    }
//    func floatingMenu() {
//        /*add brower for SQLite*/
//        let twitterImage = UIImage(named: "clock_ic")!
//        let twitter = ActionButtonItem(title: "Brower", image: twitterImage)
//        twitter.action = { item in print("Path into forder")
//            
//            self.imagePicker.allowsEditing = false
//            self.imagePicker.sourceType = .SavedPhotosAlbum
//            self.presentViewController(self.imagePicker, animated: true, completion: nil)
//            self.imagePicker.delegate = self
//        }
//        
//        /*add show picture*/
//        let plusImage1 = UIImage(named: "clock_ic")!
//        let drawNew = ActionButtonItem(title: "Draw picture", image: plusImage1)
//        drawNew.action = { item in
//            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("UITDrawViewController") as! UITDrawViewController
//            self.presentViewController(vc, animated: true, completion: nil)
//        }
//        
//        actionButton = ActionButton(attachedToView: self.view, items: [twitter,drawNew])
//        actionButton.action = { button in button.toggleMenu() }
//        actionButton.setTitle("+", forState: .Normal)
//        actionButton.backgroundColor = UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 34.0/255.0, alpha:1.0)
//    }
//    
//    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
//        let selectedImage : UIImage = image
//        print(selectedImage)
//    }
    
    static func loadLeftMenu() -> SlideMenuController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainController = mainStoryboard.instantiateViewControllerWithIdentifier(ViewController.identifier)
        let letfMenu = mainStoryboard.instantiateViewControllerWithIdentifier(LeftMenuViewController.identifier)
        return SlideMenuController(mainViewController: mainController, leftMenuViewController: letfMenu)
    }

    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    @IBAction func RamdomButton(sender: AnyObject) {
        
    }
    
    @IBAction func sendButton(sender: AnyObject) {
    let refreshAlert = UIAlertController(title: "Sending...", message: "Please, Connect and check with wifi?", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Image.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ImportPhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("ImportPhotoCell", forIndexPath: indexPath) as! ImportPhotoCell
        cell.image.image = Image[indexPath.row]
        cell.frame.size = CGSize(width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        randomImage.image = Image[indexPath.row]
        return true
    }
    
}

