//
//  Restaurants+CoreDataProperties.swift
//  iOrder
//
//  Created by mhtran on 6/13/16.
//  Copyright © 2016 mhtran. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Restaurants {

    @NSManaged var address: String?
    @NSManaged var color: String?
    @NSManaged var descriptions: String?
    @NSManaged var email: String?
    @NSManaged var id: String?
    @NSManaged var images: NSData?
    @NSManaged var location: NSData?
    @NSManaged var name: String?
    @NSManaged var phone: String?
    @NSManaged var thumbs: NSData?
    @NSManaged var website: String?
    @NSManaged var category: NSSet?
    @NSManaged var items: NSSet?

}
