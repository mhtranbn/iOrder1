//
//  Value+CoreDataProperties.swift
//  
//
//  Created by mhtran on 7/15/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Value {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var option_id: String?
    @NSManaged var price: NSNumber?
    @NSManaged var valueDescription: String?

}
