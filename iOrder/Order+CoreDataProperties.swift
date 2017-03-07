//
//  Order+CoreDataProperties.swift
//  iOrder
//
//  Created by mhtran on 6/10/16.
//  Copyright © 2016 mhtran. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Order {

    @NSManaged var date: String?
    @NSManaged var id: String?
    @NSManaged var image: NSData?
    @NSManaged var item: NSData?
    @NSManaged var item_id: String?
    @NSManaged var options: NSData?
    @NSManaged var price: NSNumber?
    @NSManaged var quantity: NSNumber?
    @NSManaged var status: String?
    @NSManaged var table: NSObject?
    @NSManaged var table_id: String?
    @NSManaged var user: NSData?
    @NSManaged var user_id: String?

}
