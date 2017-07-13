//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Tony Chen on 7/10/17.
//  Copyright © 2017 Tony Chen. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    convenience init (mediaUrl: String, context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context){
            self.init(entity: ent, insertInto: context)
            self.url = mediaUrl
        } else {
            fatalError("Unable to find Entity name!")
        }
    }

}
