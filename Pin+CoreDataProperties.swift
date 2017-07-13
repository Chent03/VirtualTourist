//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Tony Chen on 7/10/17.
//  Copyright © 2017 Tony Chen. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photos: Photo?

}
