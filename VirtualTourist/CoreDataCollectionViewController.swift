//
//  CoreDataCollectionViewController.swift
//  VirtualTourist
//
//  Created by Tony Chen on 7/18/17.
//  Copyright © 2017 Tony Chen. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class CoreDataCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var insertIndexPath = [IndexPath]()
    var deleteIndexPath = [IndexPath]()
    var updateIndexPath = [IndexPath]()
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

// Collection Data Source

extension CoreDataCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("started 3")
        
        let photoImageView = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let photo = self.fetchedResultsController?.object(at: indexPath) as? Photo
        
        if photo?.url == nil {
            print("empty")
        }
        
        
        return photoImageView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("started 2")
        
        if let fc = fetchedResultsController {
            fc.managedObjectContext.delete(fc.object(at: indexPath) as! NSManagedObject)
            delegate.stack.save()
        }
    }

}

// Fetches

extension CoreDataCollectionViewController {
    func executeSearch(){
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}

extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertIndexPath.removeAll()
        deleteIndexPath.removeAll()
        updateIndexPath.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .insert:
            insertIndexPath.append(newIndexPath!)
            break
        case .delete:
            deleteIndexPath.append(indexPath!)
            break
        case .update:
            updateIndexPath.append(indexPath!)
            break
        default:
            break
        }

    }
}
