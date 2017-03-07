//
//  DetailCell1.swift
//  test
//
//  Created by mhtran on 5/24/16.
//  Copyright © 2016 mhtran. All rights reserved.
//

import UIKit
//import ASHorizontalScrollView
import AKPickerView_Swift

class DetailCell1: UITableViewCell ,AKPickerViewDataSource, AKPickerViewDelegate {
    
    @IBOutlet weak var kindOfOptions: UILabel!
    var selectionCallback: (() -> Void)?
    var flag: Bool = true
    
    var b:[Value] = []
    var c:String = ""
    var selectedSection : String?
    var app: AppDelegate! = nil
    var lastPrice: NSNumber = 0
    var optionTemp : Dictionary<String,String> = [:]
    
    @IBOutlet weak var pickerView: AKPickerView!
    override func awakeFromNib() {
        super.awakeFromNib()
        app = UIApplication.sharedApplication().delegate as! AppDelegate
        b = app.optionValue
        app.optionValue.removeAll()
        guard b.count > 0 else {
            return
        }
        setUpUI()
        self.pickerView.reloadData()
    }
    
    func setUpUI() {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        let t = app.optionChoose
        self.pickerView.selectItem(t, animated: false)
        app.option.options["\(b[t].option_id!)"] = b[t].id
        app.option.name[c] = b[t].name
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {        
        return self.b.count
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.b[item].name!.capitalizedString
    }
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        print("Your favorite city is \(self.b[item])")
        app.optionChoose = item
        app.priceTotalOptions -= Int(lastPrice)
        app.option.options["\(optionTemp.keys.first)"] = nil
        app.option.options["\(b[item].option_id!)"] = b[item].id
        app.option.name[c] = b[item].name!.capitalizedString
        app.priceTotalOptions += Int(b[item].price!)
        lastPrice = b[item].price!
        optionTemp.removeAll()
        optionTemp["\(b[item].option_id!)"] = "\(b[item].name)"
        if let selectionCallback = self.selectionCallback {
            selectionCallback()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // println("\(scrollView.contentOffset.x)")
    }
    
    func pickerView(pickerView: AKPickerView, marginForItem item: Int) -> CGSize {
        return CGSizeMake(10, 20)
    }

}
