//
//  ScanQRCodeVC.swift
//  iOrder
//
//  Created by mhtran on 4/22/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import CoreData
import AlamofireImage
import SwiftString
import Kingfisher
//import UIColor_Hex_Swift

class ScanQRCodeVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var flashButton: UIButton!
    var beepAudio: AVAudioPlayer!
    @IBOutlet weak var canCel: UIButton!
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrcodeframeView: UIView?
    var result : String!
    var k: Bool = true
    var app : AppDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        app?.viewDict["ScanQRCodeVC"] = self
    }
    
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
            self.k = true
            self.ScanPicture()
            self.view.addSubview(self.flashButton)
            self.view.addSubview(self.canCel)
        })
        alertView.addAction(actionOK)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func saveImage (image: UIImage, path: String ) -> Bool{
        let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
        let result = jpgImageData!.writeToFile(path, atomically: true)
        return result
        
    }
    
    func getDocumentsURL() -> NSURL {
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        return documentsURL
    }
    
    func fileInDocumentsDirectory(filename: String) -> String {
        let fileURL = getDocumentsURL().URLByAppendingPathComponent(filename)
        return fileURL.path!
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        k = true
        ScanPicture()
        flashButton.setImage(UIImage(named:"flash.png" ),inFrame:CGRectMake(35, self.view.bounds.size.height - 40, 30, 30), forState: UIControlState.Normal)
        canCel.setImage(UIImage(named: "Layer 2.png"), inFrame: CGRectMake(self.view.bounds.size.width - 65, self.view.bounds.size.height - 40, 30, 30), forState: UIControlState.Normal)
        self.view.addSubview(flashButton)
        self.view.addSubview(canCel)
        app = UIApplication.sharedApplication().delegate as? AppDelegate
        if app?.viewDict["KYDrawerController"] != nil {
            app?.navitabbar.hideNaviBarTabbar()
        }
    }
    
    func ScanPicture() {
        audio()
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError?
        let input: AnyObject!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch let err1 as NSError {
            error = err1
            input = nil
        }
        if error != nil {
            print("\(error?.localizedDescription)")
            return
        }
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as! AVCaptureInput)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()
        qrcodeframeView = UIView()
        qrcodeframeView?.layer.borderColor = UIColor.greenColor().CGColor
        qrcodeframeView?.layer.borderWidth = 2
        view.addSubview(qrcodeframeView!)
        view.bringSubviewToFront(qrcodeframeView!)
    }
    
    func audio() {
        do {
            try beepAudio = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beepAudio", ofType: "mp3")!))
            beepAudio.prepareToPlay()
        } catch let err as NSError {
            print("\(err.debugDescription)")
        }
    }
    
    func afterSave() {
        self.navigationController?.pushViewController(({
            //                self.navigationController?.setNavigationBarHidden(true, animated: false)
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier(SEGUE_CONTAINER) as! KYDrawerController
            vc.navigationController?.setNavigationBarHidden(true, animated: false)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            //                self.beepAudio.play()
            return vc
        })(), animated: true)
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0{
            qrcodeframeView?.frame = CGRectZero
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObject.type == AVMetadataObjectTypeQRCode {
            let BarcodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrcodeframeView?.frame = BarcodeObject.bounds
            if metadataObject.stringValue != nil && k == true {
                k = false
                result = metadataObject.stringValue
                Defaults[.scan] = false
                if result.rangeOfString("table:") != nil && result.rangeOfString(";") != nil {
                    result = result.chompLeft("table:")
                    result = result.chompRight(";")
                    APIManager.getDataFromTableID(result, callback: { (intCheck : Int,json: JSON) -> Void in
                        if intCheck == 1 {
                            self.saveData(json)
                        } else if intCheck == 0 {
                            var error: String = ""
                            if json["errors"] == nil || json["message"] == nil {
                            } else if json["errors"] != nil{
                                for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                                    error = subJson[0].string!
                                }
                                self.showAlert("error".localized(), message: error)
                            } else if json["message"] != nil{
                                self.showAlert("error".localized(), message: json["message"].rawString()!)
                            }
                            self.showAlert("error".localized(), message: "QRCode problem")
                        } else {
                            self.showAlert("No Network".localized(), message: "Please check again net work".localized())
                        }
                        })
                    app?.genererValue._table_id = result
                } else if app?.flagsScanWifi == true {
                    self.navigationController?.pushViewController({
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_SCAN_WIFI) as! ScanWifi
                        vc.setData(result)
                        return vc
                        }(), animated: false)
                    
                } else {
                    // table id error
                    showAlert("Wrong QRCode".localized(), message: "Please scan QRCode Table of Restaurant..".localized())
                }
                captureSession?.stopRunning()
            }
        }
    }
    
    func showAlertViewError(json:JSON){
        var error: String = ""
        if json["errors"] == nil || json["message"] == nil {
        } else if json["errors"] != nil{
            for (_,subJson):(String,JSON) in (json["errors"].dictionary)! {
                error = subJson[0].string!
            }
            showAlert("error".localized(), message: error)
        } else if json["message"] != nil{
            showAlert("error".localized(), message: json["message"].rawString()!)
        }
        print("Error")
    }

    @IBAction func turnOnFlash(sender: AnyObject) {
        let avDevice  = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if avDevice.hasTorch {
            do {
                try avDevice.lockForConfiguration()
                avDevice.torchMode = avDevice.torchActive ? AVCaptureTorchMode.Off : AVCaptureTorchMode.On
                try avDevice.setTorchModeOnWithLevel(1.0)
                avDevice.unlockForConfiguration()
                if avDevice.torchActive == true {
                    turnOffFlash()
                }
            } catch let error as NSError{
                print("Flash error \(error)")
            }
            
        }

    }
    
    func turnOffFlash() {
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if ((device?.hasTorch) != nil) {
            do {
                try device.lockForConfiguration()
                device.torchMode =  AVCaptureTorchMode.Off
                device.unlockForConfiguration()
            } catch let err as NSError {
                print("Turn Off flash error \(err)")
            }
        }
    }
    
    @IBAction func canCelScan(sender: AnyObject) {
        self.view.willRemoveSubview(flashButton)
        self.view.willRemoveSubview(canCel)
        Defaults[.scan] = true
        if Defaults["login"].boolValue == true {
            app?.flagsBill = true
            self.navigationController?.pushViewController(({
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier(SEGUE_CONTAINER) as! KYDrawerController
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                return vc
            })(), animated: false)
        } else {
            self.navigationController?.pushViewController({
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_LOGGED_IN) as! LoginVC
                return vc
                }(), animated: false)
        }
    }

    func saveData(json: JSON){
        let coreData = CoreData()
        let restaurantDict = json["restaurant"].dictionary!
        let itemsJson: JSON = json["items"]
        let categoriesJson: JSON = json["categories"]
        //Do something you want
        // RESTAURANT
//        self.deleteAllCoreData()
        let restaurant = NSEntityDescription.insertNewObjectForEntityForName("Restaurants", inManagedObjectContext: coreData.managedObjectContext) as! Restaurants
        if (restaurantDict["description"]?.rawString() != "null") {
            self.deleteAllCoreData()
            restaurant.descriptions = restaurantDict["description"]!.string!
        } else {
            restaurant.descriptions = ""
            self.deleteAllCoreData()
        }
        
        if (restaurantDict["address"]?.rawString()! != "null") {
            restaurant.address = restaurantDict["address"]!.string!
        }
        
        if (restaurantDict["id"]?.rawString()! != "null") {
            restaurant.id = restaurantDict["id"]!.string!
        }
        
        if (restaurantDict["color"]?.rawString()! != "null") {
            restaurant.color = restaurantDict["color"]!.string!
            //                self.app?.genererValue._color = UIColor(rgba:"\(String("#" + restaurant.color!))")
            
        }
        
        if (restaurantDict["name"]?.rawString()! != "null") {
            restaurant.name = restaurantDict["name"]!.string!
            
        }
        
        if (restaurantDict["phone"]?.rawString()! != "null") {
            restaurant.phone = restaurantDict["phone"]!.string!
        }
        
        if (restaurantDict["website"]?.rawString()! != "null") {
            restaurant.website = restaurantDict["website"]!.string!
            
        }
        
        
        if (restaurantDict["description"]?.rawString()! != "null") {
            restaurant.descriptions = restaurantDict["description"]!.string!
        }
        
        
        if (restaurantDict["images"]?.rawString()! != "null"){
            do {
                try restaurant.images = (restaurantDict["images"]!.rawData())
            } catch {
                fatalError("error get thumbImage")
            }
        }
        
        if (restaurantDict["thumbs"]?.rawString()! != "null"){
            do {
                try restaurant.thumbs = (restaurantDict["thumbs"]!.rawData())
            } catch {
                fatalError("error get thumbImage")
            }
        }
        if (restaurantDict["location"]?.rawString()! != "null"){
            do {
                try restaurant.location = (restaurantDict["location"]!.rawData())
            } catch {
                fatalError("error get thumbImage")
            }
        }
        // ITEMS
        for i in 0...(itemsJson.count - 1) {
            let items = NSEntityDescription.insertNewObjectForEntityForName("Items", inManagedObjectContext: coreData.managedObjectContext) as! Items
            print(itemsJson)
            let a = itemsJson[i].dictionary
            if a!["id"]!.string! != "null" {
                items.id = a!["id"]!.string!
            }
            if a!["name"]!.string! != "null" {
                items.name = a!["name"]!.string!
            }
            if a!["description"]!.string! != "null" {
                items.descriptions = a!["description"]!.string!
            }
            
            if a!["category_id"]!.string! != "null" {
                items.category_id = a!["category_id"]!.string!
            }
            
            if a!["discount"]!.rawString()! != "null" {
                items.discount = a!["discount"]!.number
            }
            
            if a!["price"]!.rawString()! != "null" {
                items.price = a!["price"]!.number!
            }
            
            if a!["rate"]!.rawString()! != "null" {
                NSLog("-------log here \(NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: NSDate()).minute) please see it----= \(a!["rate"]!.rawString()!)")
                items.rate = NSNumber(double: a!["rate"]!.doubleValue)
                NSLog("-------log here \(NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: NSDate()).minute) please see it----= \(items.rate!)")
            }
            
            if a!["images"]!.rawString()! != "null" {
                do {
                    try items.image = a!["images"]!.rawData()
                } catch {
                    fatalError("Error get image")
                }
            }
            
            if a!["thumbs"]!.rawString()! != "null" {
                do {
                    try items.thumbs = a!["thumbs"]!.rawData()
                } catch {
                    fatalError("Error get thumbs")
                }
            }
            
            if ((a?["options"]) != nil){
                do {
                    try items.option = a!["options"]!.rawData()
                } catch {
                    fatalError("Error get thumbs")
                }
            }
        }
        
        // CATEGORY
        for i in 0...(categoriesJson.count - 1) {
            let category = NSEntityDescription.insertNewObjectForEntityForName("Categorys", inManagedObjectContext: coreData.managedObjectContext) as! Categorys
            let b = categoriesJson[i].dictionary
            if b!["id"]!.string! != "null" {
                category.id = b!["id"]!.string
            }
            if b!["name"]!.string! != "null" {
                category.name = b!["name"]!.string
            }
        }
        coreData.saveContext()
        self.afterSave()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        turnOffFlash()
        captureSession = nil
        videoPreviewLayer = nil
        beepAudio = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        let statusBar: UIView = UIApplication.sharedApplication().valueForKey("statusBar") as! UIView
        if statusBar.respondsToSelector(Selector("setBackgroundColor:")) {
            statusBar.backgroundColor = UIColor.clearColor()
        }
    }
    
    func deleteAllCoreData() {
        do {
            let coreData = CoreData()
            let coord = coreData.persistentStoreCoordinator
            let fetchRequest = NSFetchRequest(entityName: "Items")
            let fetchRequest2 = NSFetchRequest(entityName: "Categorys")
            let fetchReques3 = NSFetchRequest(entityName: "Restaurants")
            let fetchRequest5 = NSFetchRequest(entityName: "Option")
            let fetchRequest6 = NSFetchRequest(entityName: "Value")
            if #available(iOS 9.0, *) {
                let deteleResquest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                let deteleResquest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
                let deteleResquest3 = NSBatchDeleteRequest(fetchRequest: fetchReques3)
                let deteleResquest5 = NSBatchDeleteRequest(fetchRequest: fetchRequest5)
                let deteleResquest6 = NSBatchDeleteRequest(fetchRequest: fetchRequest6)
                do {
                    try coord.executeRequest(deteleResquest, withContext: coreData.managedObjectContext)
                    try coord.executeRequest(deteleResquest2, withContext: coreData.managedObjectContext)
                    try coord.executeRequest(deteleResquest3, withContext: coreData.managedObjectContext)
                    try coord.executeRequest(deteleResquest5, withContext: coreData.managedObjectContext)
                    try coord.executeRequest(deteleResquest6, withContext: coreData.managedObjectContext)
                } catch let errors as NSError{
                    print("cant delete because \(errors.debugDescription)")
                }
            } else {
                // Fallback on earlier versions
                do {
                    let coreData = CoreData()
                    for request in [fetchRequest,fetchRequest2,fetchReques3,fetchRequest5,fetchRequest6] {
                        coreData.deleteCoreData(request)
                    }
                }
            }
            
            if app!.viewDict["ContainerVC"] != nil {
                (self.app!.viewDict["ContainerVC"] as! ContainerVC).removeAllData()
            }
        }
    }
    
}
