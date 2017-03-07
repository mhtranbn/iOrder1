//
//  ScanWifi.swift
//  iOrder
//
//  Created by mhtran on 6/14/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
import AVFoundation
class ScanWifi: UIViewController{

    @IBOutlet weak var naviCustom: UIView!
    @IBOutlet weak var wifiTitle: UILabel!
    @IBOutlet weak var ssidLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var nameWifiLabel: UILabel!
    @IBOutlet weak var passwordWifiLabel: UILabel!
    @IBOutlet weak var resultQrcode: UILabel!
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var result: UILabel!
    
    
    var dataQRcodeScan: String = ""
    var ssid:String = ""
    var pass:String = ""
    var encrypt:String = ""
    var temp:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let app = UIApplication.sharedApplication().delegate as? AppDelegate
        app?.viewDict["ScanWifi"] = self
        back.setImage(
            UIImage(named: "arrow.png"),
            inFrame: CGRectMake(10, 20, 26, 18),
            forState: UIControlState.Normal
        )
        naviCustom.backgroundColor = app?.genererValue.color
        setText()
        solveResultQR()
//        showInfoQRcode()
    }

    func setText() {
        wifiTitle.text = "Wifi QR code".localized()
        ssidLabel.text = "SSID:".localized()
        passwordLabel.text = "Password:".localized()
        resultQrcode.text = "Please go to setting/wifi connect to that wifi with that password.".localized()
        result.text = "Result".localized()
    }
    
    func setData(data: String) -> () {
        dataQRcodeScan = data
    }
    
    func solveResultQR() {
        if (dataQRcodeScan.rangeOfString("WIFI:S:") != nil) {
            showInfoQRcode()
        } else {
            hideSsidPass()
            resultQrcode.text = ("That QR code is not wifi:" + dataQRcodeScan).localized()
        }
    }
    
    func hideSsidPass() {
        self.ssidLabel.hidden = true
        self.passwordLabel.hidden = true
    }
    
    func showSsidPass() {
        self.ssidLabel.hidden = false
        self.passwordLabel.hidden = false
    }
    
    func showInfoQRcode() {
        dataQRcodeScan = dataQRcodeScan.chompLeft("WIFI:S:")
        ssid = getStringFromStringByCharacter(dataQRcodeScan, character: ";")
        dataQRcodeScan = dataQRcodeScan.chompLeft(ssid + ";T:")
        dataQRcodeScan = dataQRcodeScan.chompLeft(encrypt + ";P:")
        pass = dataQRcodeScan.chompRight(";;")
        nameWifiLabel.text = ssid
        passwordWifiLabel.text = pass
    }
    
    func getStringFromStringByCharacter(totalString: String, character: String) -> String {
        var result:String = ""
        var k:Bool = false
        
        for i in 0...totalString.characters.count {
            _ = totalString.substringWithRange(0, location: i)
            if String(totalString[i]) == character && k == false {
                k = true
                result = totalString.substringWithRange(0, location: i)
                break
            }
        }
        return result
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        let app = UIApplication.sharedApplication().delegate as? AppDelegate
        app!.navitabbar.hideNaviBarTabbar()
    }

}
