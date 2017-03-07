//
//  HomeVC.swift
//  iOrder
//
//  Created by mhtran on 5/23/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation
import MessageUI
import AVFoundation
import AudioToolbox
import SwiftyJSON
import Kingfisher
import SwiftString
import Alamofire
import BRYXBanner

class HomeVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,MFMailComposeViewControllerDelegate,NSFetchedResultsControllerDelegate, NVActivityIndicatorViewable{
    
    @IBOutlet weak var nameRes: UILabel!
    
    @IBOutlet weak var website: UILabel!
    
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var descriptions: UILabel!
    
    @IBOutlet weak var imageRes: UIImageView!
    
    @IBOutlet weak var addressRes: UILabel!
    
    @IBOutlet weak var timeOpen: UILabel!
    
    @IBOutlet weak var faceBookRes: UIButton!
    
    @IBOutlet weak var twitterRes: UIButton!
    
    @IBOutlet weak var googleRes: UIButton!
    
    @IBOutlet weak var makit: MKMapView!
    let locationMgr = CLLocationManager()
    var index : NSInteger = 2
    @IBOutlet weak var logo2: UIImageView!
    var app: AppDelegate? = nil
    var managedObjectcontext : NSManagedObjectContext!
    var result: NSFetchedResultsController!
    var restaurant: [Restaurants] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        app = UIApplication.sharedApplication().delegate as?
        AppDelegate
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Layer 1.png")!)
        app?.viewDict["HomeVC"] = self
        locationMgr.delegate = self
        locationMgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        timeOpen.text = "Open 8:00 to 21:00".localized()
        self.automaticallyAdjustsScrollViewInsets = false
        var frame = self.view.frame
        frame.origin.y = 64 //The height of status bar + navigation bar
        self.view.frame = frame
        loadData()
        result.delegate = self
        restaurant = result.fetchedObjects as! [Restaurants]
        guard restaurant.count > 0 else {
            return
        }
        self.nameRes.text = restaurant[0].name?.uppercaseString
        self.addressRes.text = restaurant[0].address!
        self.addressRes.setLineHeight(1.2)
        self.website.text = restaurant[0].website!.chompLeft("https://")
        self.phone.text = restaurant[0].phone!
        self.descriptions.text = restaurant[0].descriptions!
        let _ = JSON(data: restaurant[0].images! as NSData)[0].string
        self.imageRes.kf_showIndicatorWhenLoading = true
        self.imageRes.kf_setImageWithURL(NSURL(string: "")!, placeholderImage: UIImage(named: "download.jpg"),
                                        optionsInfo: [.Transition(ImageTransition.Fade(1))],
                                        progressBlock: { receivedSize, totalSize in
                                            print("\(0 + 1): \(receivedSize)/\(totalSize)")
            },
                                        completionHandler: { image, error, cacheType, imageURL in
                                            print("\(0 + 1): Finished")
        })
//        nameRes.hidden = true
        guard (result.fetchedObjects as! [Restaurants])[0].descriptions! == "null" else {
            self.descriptions.text = (result.fetchedObjects as! [Restaurants])[0].descriptions!
            self.descriptions.textColor = UIColor.whiteColor()
            self.descriptions.font = UIFont.systemFontOfSize(16)
            return
        }
    }
    
    func localNotifiaction() {
        let banner = Banner(title: "iOrder", subtitle: "Please order now.", image: UIImage(named: "IconBanner-Small.png"), backgroundColor: UIColor.blackColor())
        banner.springiness = .None
        banner.dismissesOnTap = true
        banner.show(duration: 4.0)
        AudioServicesPlaySystemSound(1312)
    }

    func loadData() {
        let coreData = CoreData()
        managedObjectcontext = coreData.managedObjectContext
        let request = NSFetchRequest(entityName: "Restaurants")
        let sort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sort]
        result = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectcontext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try result.performFetch()
        } catch {            
            fatalError("Error in fetching records")
        }
    }
    
    func setupMap() {
        locationMgr.delegate = self
        locationMgr.requestWhenInUseAuthorization()
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        locationMgr.startUpdatingLocation()
        makit.showsUserLocation = true
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let a = JSON(data:restaurant[0].location! as NSData).dictionary
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:Double(round(100*a!["lat"]!.doubleValue)/100), longitude:Double(round(100*a!["lng"]!.doubleValue)/100))
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        guard restaurant.count > 0 else{
            return
        }
        annotation.title = restaurant[0].name!
        annotation.subtitle = restaurant[0].name!
        makit.addAnnotation(annotation)
        makit.setRegion(region, animated: true)
        locationMgr.stopUpdatingLocation()
    }

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(["tranmanhhoang@gmail.com"])
        mailComposerVC.setSubject("Feedback about service of \(self.nameRes.text!)")
        mailComposerVC.setMessageBody("Sending e-mail by custommer!", isHTML: false)        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.".localized(), preferredStyle: .Alert)
        self.presentViewController(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: {
            self.thanksForFeedback()
        })
    }
    
    func thanksForFeedback() {
        let thank = UIAlertController(title: "We look forward to hearing from you!", message: "We at The \(self.nameRes.text!) care about what you think of our restaurant and the services that we provide. Your feedback is valuable and we greatly appreciate you filling out the comment form below.".localized(), preferredStyle: UIAlertControllerStyle.Alert)
        let actionOK = UIAlertAction(title: "Dissmiss".localized(), style: UIAlertActionStyle.Default, handler: { (Void) in
            let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainPage : KYDrawerController = mainStoryBoard.instantiateViewControllerWithIdentifier(SEGUE_CONTAINER) as! KYDrawerController
            let mainPageNav = UINavigationController(rootViewController: mainPage)
            self.app?.window?.rootViewController = mainPageNav
        })
        thank.addAction(actionOK)
        self.presentViewController(thank, animated: true, completion: {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        })
    }
    
    // Feedback by mail. facebook ,twetter
    
    @IBAction func goFacebookRes(sender: AnyObject) {
        self.navigationController?.pushViewController({
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_SOCIAL_VC) as! FaceBookTwitterVC
            vc.URL = "https://www.facebook.com/AmericanUniversity"
            return vc
            }(), animated: false)
    }
    
    @IBAction func goTwitterRestaurants(sender: AnyObject) {
        self.navigationController?.pushViewController({
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_SOCIAL_VC) as! FaceBookTwitterVC
            vc.URL = "https://twitter.com/mhtranbn"
            return vc
            }(), animated: false)
        
    }

    @IBAction func feedbackbyEmail(sender: AnyObject) {
        let mailComposeViewController = self.configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupMap()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        app?.navitabbar.showNaviTabBar()
        guard app?.flagJumpToMyOrderVC != true else {
            app?.flagJumpToMyOrderVC = nil
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_TABBAR_CUSTOM) as! RAMAnimatedTabBarController
            self.navigationController?.pushViewController({
                vc.setSelectIndex(from: 2, to: 2)
                (app?.viewDict["ContainerMyOrderVC"] as! ContainerMyOrderVC).swipeableView.jumpToCurrentOrderView()
                app?.navitabbar.setTitleBar("My Order".localized())
                app?.navitabbar.hideSearchBar()
                return vc
                }(), animated: false)
            return
        }
        guard app?.flagJumpToMenuVC != true else {
            app?.flagJumpToMenuVC = nil
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_TABBAR_CUSTOM) as! RAMAnimatedTabBarController
            self.navigationController?.pushViewController({
                vc.setSelectIndex(from: 1, to: 1)
                app?.navitabbar.setTitleBar("Menu".localized())
                app?.navitabbar.hideSearchBar()
                return vc
                }(), animated: false)
            return
        }
        guard app?.flagsBill != true else {
            app?.flagsBill = nil
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier(SEGUE_TABBAR_CUSTOM) as! RAMAnimatedTabBarController
            self.navigationController?.pushViewController({
                vc.setSelectIndex(from: 3, to: 3)
                app?.navitabbar.setTitleBar("Bill".localized())
                app?.navitabbar.hideSearchBar()
                return vc
                }(), animated: false)
            return
        }
        checkBagde()
    }

    func checkBagde(){
        if app?.countBagde > 0 {
            let tabItem = self.tabBarController?.tabBar.items![2]
            tabItem!.badgeValue = nil
            let animationItem : RAMAnimatedTabBarItem = self.tabBarController!.tabBar.items![2] as! RAMAnimatedTabBarItem
            delay(1, closure: {
                tabItem!.badgeValue = "\(self.app!.countBagde)"
                animationItem.playAnimation()
            })
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationMgr.stopMonitoringVisits()
        locationMgr.stopMonitoringSignificantLocationChanges()
        for region in locationMgr.monitoredRegions {
            locationMgr.stopMonitoringForRegion(region)
        }
    }
    
}
