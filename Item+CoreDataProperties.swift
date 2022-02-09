//
//  Item+CoreDataProperties.swift
//  CoreDataTodo
//
//  Created by lpiem on 09/02/2022.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var isChecked: Bool
    @NSManaged public var date: Date?
    @NSManaged public var title: String?

}

extension Item : Identifiable {

}
