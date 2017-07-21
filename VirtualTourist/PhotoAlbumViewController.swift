//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Tony Chen on 7/18/17.
//  Copyright © 2017 Tony Chen. All rights reserved.
//

import MapKit
import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var pin: Pin?

    var insertIndexPath = [IndexPath]()
    var deleteIndexPath = [IndexPath]()
    var updateIndexPath = [IndexPath]()
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
            collectionView.reloadData()
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>) {
        fetchedResultsController = fc
        super.init(coder: )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadMap()
        // Do any additional setup after loading the view.
        
    }


    func loadMap(){
        mapView.delegate = self
        
        if let selectedPin = pin {
            let coord = CLLocationCoordinate2DMake(selectedPin.latitude, selectedPin.longitude)
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: coord, span: span)
            mapView.setRegion(region, animated: true)
            
            let pinDrop = MKPointAnnotation()
            pinDrop.coordinate = coord
            mapView.addAnnotation(pinDrop)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
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

