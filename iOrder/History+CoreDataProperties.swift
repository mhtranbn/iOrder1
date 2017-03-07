//
//  History+CoreDataProperties.swift
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

extension History {

    @NSManaged var date: String?
    @NSManaged var id: String?
    @NSManaged var restaurant: NSObject?
    @NSManaged var total: NSNumber?

}
