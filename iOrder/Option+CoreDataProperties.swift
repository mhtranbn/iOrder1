//
//  Option+CoreDataProperties.swift
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

extension Option {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var type: String?
    @NSManaged var optionDescription: String?

}
