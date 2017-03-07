//
//  NewBill+CoreDataProperties.swift
//  iOrder
//
//  Created by mhtran on 5/30/16.
//  Copyright © 2016 mhtran. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension NewBill {

    @NSManaged var kindOf: String?
    @NSManaged var orders: NSObject?
    @NSManaged var restaurant: NSObject?
    @NSManaged var sub_total: NSNumber?
    @NSManaged var tax: NSNumber?
    @NSManaged var total: NSNumber?

}
