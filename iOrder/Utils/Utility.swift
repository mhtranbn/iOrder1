//
//  UtilityClass.swift
//  UtilityClassApplication
//
//  Created by Anandharajan SRJ on 3/17/16.
//  Copyright © 2016 KaryaTechnologies. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import SystemConfiguration



public class Utility: UIResponder, CLLocationManagerDelegate {
    
    private var documentPath = (NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)).last! as NSURL
    private var locationStatus: Bool = false
    private var locationManager: CLLocationManager!
    private var location: CLLocation!
    public var locationInfo: NSMutableDictionary = [:]
    public var searchLocationInfo: MKMapItem = MKMapItem()
    
    public enum property: Int {
        case Day
        case Month
        case Year
        case Hour
        case Minute
        case Second
    }
    
    public override init() {
        super.init()
    }
    
    /*
     * Network Reachability operations
     * Private Methods
     */
    
    //MARK: setup and initiate reachability
    private func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
            //SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags = SCNetworkReachabilityFlags()
        
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
    
    /*
     * Network Reachability operations
     * Public Methods
     */
    
    //MARK: Connection Exist Checker
    public func checkNetworkConnectivity() -> Bool {
        if self.isConnectedToNetwork() == true {
            return true
        }
        return false
    }
    
    /*
    * File Operations
    * Public Methods
    */
    //MARK: Getting file lists
    public func getFileLists()->NSArray? {
        do {
            let directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(self.documentPath, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            print(directoryContents)
            return self.getFileNames(directoryContents)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    //MARK: File Existence checker
    public func isFileExists(fileName: String) -> Bool {
        let filePath = self.documentPath.URLByAppendingPathComponent(fileName as String);
        let checker = NSFileManager.defaultManager();
        if (checker.fileExistsAtPath(filePath.path!)) {
            return true;
        }
        return false;
    }
    
    //MARK: Write Files to the document directory with NSData type
    public func writeFileWithNSData(fileData: NSData?, documentFileName: String) -> Bool {
        if (fileData != nil && documentFileName != "") {
            let filePath = self.documentPath.URLByAppendingPathComponent(documentFileName)
            do {
                try fileData!.writeToURL(filePath, options: NSDataWritingOptions.DataWritingFileProtectionNone);
                return true
            } catch let error as NSError {
                print(error.localizedDescription)
                return false
            }
        }
        return false
    }
    
    //MARK: Write Files to the document directory with string type
    public func writeFileWithStringContent(fileData: String?, documentName: String) -> Bool {
        if (fileData != nil && documentName != "") {
            let filePath = self.documentPath.URLByAppendingPathComponent(documentName).path
            do {
                try fileData?.writeToFile(filePath!, atomically: true, encoding: NSUTF8StringEncoding)
                return true
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return false
    }
    
    //MARK: Write Files to the document directory with dictionary type
    public func writeFileWithDictionaryContent(fileData: NSMutableDictionary?, documentName: String) {
        if (fileData != nil && documentName != "") {
            let filePath = self.documentPath.URLByAppendingPathComponent(documentName).path;
            fileData?.writeToFile(filePath!, atomically: true)
        } else {
            print("fileName or file data is missing");
        }
    }
    
    //MARK: Getting document directory path
    public func getDocumentPath() -> NSURL {
        return self.documentPath;
    }
    
    //MARK: Read the file by file name
    public func readFileWithName(documentName: String) ->NSData? {
        if (documentName != "") {
            if (isFileExists(documentName)) {
                let filePath = self.documentPath.URLByAppendingPathComponent(documentName).path
                do {
                    let documentData: NSData = try NSData(contentsOfFile: filePath!, options: NSDataReadingOptions())
                    return documentData
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else {
                print("File doesn't exist in your directory")
            }
        }
        return nil
    }
    
    //MARK: Deleting file by file name
    public func deleteFileByName(documentName: String) -> Bool {
        do {
            let filePath: String = self.documentPath.URLByAppendingPathComponent(documentName).path!
            let fileManager = NSFileManager.defaultManager()
            try fileManager.removeItemAtPath(filePath)
            return true
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return false
    }
    
    private func getFileNames(fileArray: NSArray) -> NSArray {
        let fileNames: NSMutableArray = []
        for i in 0 ..< fileArray.count {
            fileNames.addObject(fileArray[i].lastPathComponent)
        }
        return fileNames
    }
    
    /*
     * Date Format conversion
     * Public Method
     */
    
    //MARK: Get Date by specifying Format
    public func setDateFormat(date: NSDate, format: String) -> String {
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(date)
    }
    
    //MARK: Convertion of NSDate type to String
    public func convertDateToString(date: NSDate) -> String {
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss zzz"
        return formatter.stringFromDate(date)
    }
    
    //MARK: Convertion of String type to NSDate
    public func convertStringToDate(date: String, format: String) -> NSDate {
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.dateFromString(date)!
    }
    
    //MARK: Compare two dates gives text formation
    public func compareDates(date1: NSDate, date2: NSDate) -> String? {
        let laterResult = "First Date is later than Second Date"
        let earlierResult = "First Date is Eariler than Second Date"
        let sameResult = "First Date and Second Date are same"
        if date1.compare(date2) == NSComparisonResult.OrderedAscending {
            return laterResult
        } else if date1.compare(date2) == NSComparisonResult.OrderedDescending {
            return earlierResult
        } else if date1.compare(date2) == NSComparisonResult.OrderedSame {
            return sameResult
        }
        return nil
    }
    
    //MARK: Getting two dates differents of Days, Months, Years, Hours
    public func findDateDifference(startDate: NSDate, currentDate:NSDate, dateProperty: property) -> Int? {
        let calendar = NSCalendar.currentCalendar()
        let option = dateProperty.rawValue
        switch option {
        case property.Day.rawValue:
            let unit: NSCalendarUnit = .Day
            return calendar.components(unit, fromDate: startDate, toDate: currentDate, options:[]).day
        case property.Month.rawValue:
            let unit: NSCalendarUnit = .Month
            return calendar.components(unit, fromDate: startDate, toDate: currentDate, options:[]).month
        case property.Year.rawValue:
            let unit: NSCalendarUnit = .Year
            return calendar.components(unit, fromDate: startDate, toDate: currentDate, options:[]).year
        case property.Hour.rawValue:
            let unit: NSCalendarUnit = .Hour
            return calendar.components(unit, fromDate: startDate, toDate: currentDate, options:[]).hour
        case property.Minute.rawValue:
            let unit: NSCalendarUnit = .Minute
            return calendar.components(unit, fromDate: startDate, toDate: currentDate, options:[]).minute
        case property.Second.rawValue:
            let unit: NSCalendarUnit = .Second
            return calendar.components(unit, fromDate: startDate, toDate: currentDate, options:[]).second
        default:
            return nil;
        }
    }
    
    //MARK: Getting Future Date by adding value of Days, Months, Years, Hours
    public func getFutureDate(numberOfUnit: Int, currentDate:NSDate, dateProperty: property) -> NSDate? {
        let components: NSDateComponents = NSDateComponents()
        let option = dateProperty.rawValue
        switch option {
            case property.Day.rawValue:
                components.setValue(numberOfUnit, forComponent: NSCalendarUnit.Day)
                return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
            case property.Month.rawValue:
                components.setValue(numberOfUnit, forComponent: NSCalendarUnit.Month)
                return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
            case property.Year.rawValue:
                components.setValue(numberOfUnit, forComponent: NSCalendarUnit.Year)
                return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
            case property.Hour.rawValue:
                components.setValue(numberOfUnit, forComponent: NSCalendarUnit.Hour)
                return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: currentDate, options: NSCalendarOptions(rawValue: 0))!
            default:
                return nil
        }
    }
    
    public func getDate(date: NSDate) -> NSDate {
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: date)
        return calendar.dateBySettingHour(components.hour, minute: components.minute, second: 0, ofDate: date, options: NSCalendarOptions())!
    }
    
    public func getTime(date: NSDate) -> NSDate {
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: date)
        return calendar.dateBySettingHour(components.hour, minute: components.minute, second: 0, ofDate: date, options: NSCalendarOptions())!
    }
    
    /*
    * Location Service
    * Public Method
    */
    //MARK: Initiate Location service
    public func initiateLocation(locationManager: CLLocationManager, location: CLLocation?) {
        self.locationManager = locationManager;
        self.location = location
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.location = nil
        } else {
            print("Location service is disabled")
        }
    }
    
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            case .NotDetermined:
                print("Not Determined")
            break
            case .Denied:
                print("Deneid")
            break
            case .AuthorizedWhenInUse, .AuthorizedAlways:
                print("Authorized")
                self.locationManager.startUpdatingLocation()
                setLocationInformation(getCurrentLocation())
            break
            default:
                print("Unable to Authorize the Status")
            break
        }
    }
    //MARK: Search Location
    public func searchLocation(searchText: String, mapKit: MKMapView) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler({ response, _ in
            guard let response = response else {
                return
            }
            self.searchLocationInfo = response.mapItems.last!
            let title = self.searchLocationInfo.placemark.title != nil ? self.searchLocationInfo.placemark.title: ""
            let subTitle = ""
            self.setRegion(mapKit, location: self.searchLocationInfo.placemark.location!, distance: 0.1, title: title!, subTitle: subTitle)
        })
    }
    
    //MARK: Gettin Current Location
    public func getCurrentLocation() -> CLLocation? {
        if self.locationManager.location != nil {
            let currentLocation: CLLocation = self.locationManager.location!
            return currentLocation
        }
        return nil
    }
    
    //MARK: Setting Location Information
    public func setLocationInformation(locations:CLLocation?) {
        if locations != nil {
            CLGeocoder().reverseGeocodeLocation(locations!, completionHandler: { (placeMarks, error) -> Void in
                if (error != nil) {
                    print(error)
                    return
                }
                if placeMarks?.count > 0 {
                    let pm = placeMarks![0] as CLPlacemark
                    self.locationInfo["locality"] = pm.locality
                    self.locationInfo["postalCode"] = pm.postalCode
                    self.locationInfo["country"] = pm.country
                    self.locationInfo["administrativeArea"] = pm.administrativeArea
                    self.locationInfo["location"] = pm.location
                    self.locationInfo["subLocality"] = pm.subLocality
                    self.locationInfo["name"] = pm.name
                    self.locationInfo["ISOcountryCode"] = pm.ISOcountryCode
                    if #available(iOS 9.0, *) {
                        self.locationInfo["timeZone"] = pm.timeZone
                    }
                    self.locationManager.stopUpdatingLocation()
                } else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    //MARK: Setting Location Region
    public func setRegion(mapKit: MKMapView, location: CLLocation, distance: CLLocationDegrees, title: String, subTitle: String) {
        if CLAuthorizationStatus.AuthorizedWhenInUse == .AuthorizedWhenInUse || CLAuthorizationStatus.AuthorizedAlways == .AuthorizedAlways  {
            let span = MKCoordinateSpanMake(distance, distance)
            let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: span)
            mapKit.setRegion(region, animated: true)
            mapKit.addAnnotation(self.getAnnotation(center, title: title, subTitle: subTitle));
        }
    }
    
    //MARK: Reemoving All Annotations
    public func removeAllAnnotations(mapKit: MKMapView) {
        let annotations = mapKit.annotations
        mapKit.removeAnnotations(annotations)
    }
    
    private func getAnnotation(locations:CLLocationCoordinate2D, title: String, subTitle: String) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locations
        annotation.title = title
        annotation.subtitle = subTitle
        return annotation
    }
    
}
