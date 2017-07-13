//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Tony Chen on 7/10/17.
//  Copyright © 2017 Tony Chen. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
