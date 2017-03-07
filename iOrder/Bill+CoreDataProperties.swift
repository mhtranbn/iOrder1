//
//  Bill+CoreDataProperties.swift
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

extension Bill {

    @NSManaged var date: NSDate?
    @NSManaged var id: String?
    @NSManaged var item: NSObject?
    @NSManaged var item_id: String?
    @NSManaged var price: NSNumber?
    @NSManaged var quantity: NSNumber?
    @NSManaged var status: String?
    @NSManaged var table: NSObject?
    @NSManaged var table_id: String?
    @NSManaged var user: NSObject?
    @NSManaged var user_id: String?

}
