//
//  Items+CoreDataProperties.swift
//  
//
//  Created by mhtran on 7/30/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Items {

    @NSManaged var category_id: String?
    @NSManaged var descriptions: String?
    @NSManaged var discount: NSNumber?
    @NSManaged var id: String?
    @NSManaged var image: NSData?
    @NSManaged var menu_id: String?
    @NSManaged var name: String?
    @NSManaged var option: NSData?
    @NSManaged var price: NSNumber?
    @NSManaged var quantity: NSNumber?
    @NSManaged var thumbs: NSData?
    @NSManaged var rate: NSNumber?
    @NSManaged var restaurant: Restaurants?

}
