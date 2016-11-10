//
//  ViewController.swift
//  UIT-CE
//
//  Created by Lee Hoa on 8/14/16.
//  Copyright © 2016 Lee Hoa. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import SocketIO
var socket: SocketIOClient?

class ViewController: UIViewController { //UIImagePickerControllerDelegate, UINavigationControllerDelegate
    static let identifier = String(ViewController)
   
    @IBOutlet weak var conectStatus: UIButton!
    @IBOutlet var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var listImageCollectionView: UICollectionView!

    @IBOutlet weak var vans: UILabel!
    @IBOutlet weak var port: UILabel!
    @IBOutlet weak var rDelay: UILabel!
    @IBOutlet weak var iDelay: UILabel!
    @IBOutlet weak var ip: UILabel!
    
    var left: LeftMenuViewController?
    var indicator:ProgressIndicator?
    var Image = [UIImage]()
    var ListImage = [UIImage]()
    var imagesDirectoryPath:String!
    var pixels = [DataProviding.PixelData()]
    let black = DataProviding.PixelData(a: 255, r: 0, g: 0, b: 0)
    let white = DataProviding.PixelData(a: 255, r: 255, g: 255, b: 255)
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //SD.deleteTable("SampleImageTable")
        createTable()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conditionSQLite()
        SD.deleteTable("ListImageData")
        self.view1.clipsToBounds = true
        self.view1.addGradientWithColor(UIColor.whiteColor())
        self.view2.backgroundColor = Colors.primaryBlue()
        collectionView!.registerNib(UINib(nibName: "ImportPhotoCell", bundle: nil), forCellWithReuseIdentifier: "ImportPhotoCell")
        listImageCollectionView!.registerNib(UINib(nibName: "ImportPhotoCell", bundle: nil), forCellWithReuseIdentifier: "ImportPhotoCell")
        layoutCollectiobView(self.collectionView)
        layoutCollectiobView(self.listImageCollectionView)
        
        indicator = ProgressIndicator(inview:self.view,loadingViewColor: UIColor.grayColor(), indicatorColor: UIColor.blackColor(), msg: "Loading..")
        self.view.addSubview(indicator!)
        indicator!.start()
        loaddingDataBase()
        loaddingListImageData()
        loaddingSetting()
        DataProviding.statusConnection(conectStatus)
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
    
    func layoutCollectiobView(collectionView: UICollectionView) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: (self.view.frame.size.width-1)/2, height: (self.view.frame.size.width-1)/2)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        flowLayout.scrollDirection = .Horizontal
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
    }
    
    func loaddingDataBase() {
        Image.removeAll()
        Image = []
        let (resultSet, err) = SD.executeQuery("SELECT * FROM ImageData")
        if err != nil {
            
        } else {
            for row in resultSet {
                if let image = row["Path"]?.asString() {
                    let data = NSFileManager.defaultManager().contentsAtPath(imagesDirectoryPath+image)
                    
                    let image1 = UIImage(data: data!)
                    let image2 = DataProviding.resizeImage(image1!, newWidth: 192)
                    Image.append(image2)
                }
            }
        }

        self.collectionView.reloadData()
        indicator!.stop()
    }
    
    func loaddingListImageData() {
        ListImage.removeAll()
        ListImage = []
        let (resultSet, err) = SD.executeQuery("SELECT * FROM ListImageData")
        if err != nil {
            
        } else {
            for row in resultSet {
                if let image = row["Path"]?.asString() {
                    let data = NSFileManager.defaultManager().contentsAtPath(imagesDirectoryPath+image)
                    
                    let image1 = UIImage(data: data!)
                    let image2 = DataProviding.resizeImage(image1!, newWidth: 192)
                    let result = DataProviding.intensityValuesFromImage(image2)
                    pixels = []
                    for i in 0..<Int((result.pixelValues?.count)!) {
                        if result.pixelValues![i] == 1 {
                            pixels.append(white)
                        } else {
                            pixels.append(black)
                        }
                    }
                    
                    let image3 = DataProviding.imageFromARGB32Bitmap(pixels, width: 192, height: result.height)
                    ListImage.append(image3)
                }
            }
        }
        
        self.listImageCollectionView.reloadData()
        indicator!.stop()
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
    
    func createTable() {
        /*Table image*/
        if let _ = SD.createTable("ImageData", withColumnNamesAndTypes: ["Path": .StringVal]) {
            print("Error: Do it again!")
        }
        /*Table setting*/
        if let _ = SD.createTable("Setting", withColumnNamesAndTypes: ["Van": .IntVal, "DRow": .IntVal, "DImage": .IntVal, "Value": .IntVal, "IP": .StringVal, "Port": .IntVal]) {
            print("Error: Do it again!")
        } else {
            if let _ = SD.executeChange("INSERT INTO Setting (Van, DRow, DImage, Value, IP, Port) VALUES (?, ?, ?, ?, ?, ?)", withArgs: [168,500,1000,127,"192.168.1.1",90]) {
            }
        }
        
        if let _ = SD.createTable("ListImageData", withColumnNamesAndTypes: ["Path": .StringVal]) {
            print("Error: Do it again!")
        }
    }
    
    static func loadLeftMenu() -> SlideMenuController {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainController = mainStoryboard.instantiateViewControllerWithIdentifier(ViewController.identifier)
        let letfMenu = mainStoryboard.instantiateViewControllerWithIdentifier(LeftMenuViewController.identifier)
        return SlideMenuController(mainViewController: mainController, leftMenuViewController: letfMenu)
    }

    @IBAction func leftMenuButton(sender: AnyObject) {
        self.openLeft()
    }
    
    @IBAction func connectButton(sender: AnyObject) {
        
    }
    @IBAction func gotoSetting(sender: AnyObject) {
        if let vc = UIStoryboard.loadLeftMenuSetting() {
            vc.view.layoutIfNeeded()
            self.presentViewController(vc, animated: true, completion: nil)
        }

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
        if collectionView == listImageCollectionView {
            return ListImage.count
        } else {
            return Image.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ImportPhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier("ImportPhotoCell", forIndexPath: indexPath) as! ImportPhotoCell
        if collectionView == listImageCollectionView {
            cell.image.image = ListImage[indexPath.row]
            cell.frame.size = CGSize(width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height)
        } else {
            cell.image.image = Image[indexPath.row]
            cell.frame.size = CGSize(width: self.collectionView.frame.size.width, height: self.collectionView.frame.size.height)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.collectionView == collectionView {
            do{
                let titles = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(imagesDirectoryPath)
                if let _ = SD.executeChange("INSERT INTO ListImageData (Path) VALUES (?)", withArgs: ["/\(titles[indexPath.row])"]){
                    //there was an error inserting the new row, handle it here
                }
            }catch{
                print("Error")
            }
            loaddingListImageData()
        }
        return true
    }
    
}

