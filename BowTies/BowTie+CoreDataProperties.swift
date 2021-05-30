//
//  BowTie+CoreDataProperties.swift
//  BowTies
//
//  Created by Lê Cảnh Phong on 30/05/2021.
//  Copyright © 2021 Razeware. All rights reserved.
//
//

import Foundation
import CoreData


extension BowTie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BowTie> {
        return NSFetchRequest<BowTie>(entityName: "BowTie")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var lastWorn: Date?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var rating: Double
    @NSManaged public var searchKey: String?
    @NSManaged public var timesWorn: Int32
    @NSManaged public var url: URL?
    @NSManaged public var name: String?
    @NSManaged public var photoData: Data?
    @NSManaged public var tintColor: NSObject?

}

extension BowTie : Identifiable {

}
