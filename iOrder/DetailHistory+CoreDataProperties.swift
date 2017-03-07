//
//  DetailHistory+CoreDataProperties.swift
//  iOrder
//
//  Created by mhtran on 6/8/16.
//  Copyright © 2016 mhtran. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DetailHistory {

    @NSManaged var date: String?
    @NSManaged var id: String?
    @NSManaged var orders: NSObject?
    @NSManaged var restaurant: NSObject?
    @NSManaged var status: String?
    @NSManaged var subTotalDetal: NSNumber?
    @NSManaged var tax: NSNumber?
    @NSManaged var total: NSNumber?
    @NSManaged var user: NSObject?
    @NSManaged var bill_id: String?

}
