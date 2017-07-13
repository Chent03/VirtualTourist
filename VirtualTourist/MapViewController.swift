//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Tony Chen on 7/9/17.
//  Copyright © 2017 Tony Chen. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation



class MapViewController: UIViewController, MKMapViewDelegate {
    
    let regionCoord = "regionCoord"
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var Pins = [Pin]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.setGesture()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stack = self.delegate.stack
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore"){
            let regionLat = UserDefaults.standard.float(forKey: "regionLat")
            let regionLng = UserDefaults.standard.float(forKey: "regionLng")
            let spanLat = UserDefaults.standard.float(forKey: "spanLat")
            let spanLng = UserDefaults.standard.float(forKey: "spanLng")
            
            let CLLocation = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(regionLat), longitude: CLLocationDegrees(regionLng))
            let MKCoord = MKCoordinateSpan.init(latitudeDelta: CLLocationDegrees(spanLat), longitudeDelta: CLLocationDegrees(spanLng))
            
            let MKCoordregion = MKCoordinateRegion.init(center: CLLocation, span: MKCoord)
            
            mapView.setRegion(MKCoordregion, animated: true)
            
            self.loadPins()
            
        }else {
            
            print("HERE")
            UserDefaults.standard.set(mapView.region.center.latitude, forKey: "regionLat")
            UserDefaults.standard.set(mapView.region.center.longitude, forKey: "regionLng")
            UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "spanLat")
            UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "spanLng")
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            
        }
        
    }
    
    func loadPins(){
        do{
            try self.fetchedResultsController.performFetch()
        }catch{
            print("Fetching Error")
        }
        self.Pins = (fetchedResultsController.fetchedObjects as? [Pin])!
        print(self.Pins.count)
        
        if !self.Pins.isEmpty {
            for pin in self.Pins {
                print("pasting")
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(pin.latitude), CLLocationDegrees(pin.longitude))
                self.mapView.addAnnotation(annotation)
            }
        }else {
            print("empty pin array")
        }
    }
    
    func setGesture(){
        let gesture = UILongPressGestureRecognizer()
        gesture.minimumPressDuration = 1.0
        
        gesture.addTarget(self, action: #selector(MapViewController.addPin(gesture:)))
        
        self.mapView.addGestureRecognizer(gesture)
    }
    
    @objc func addPin(gesture: UIGestureRecognizer){
        let point = gesture.location(in: self.mapView)
        
        let coord = self.mapView.convert(point, toCoordinateFrom: self.mapView)

        print(coord.latitude)
        print(coord.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        self.mapView.addAnnotation(annotation)
        
        self.delegate.stack.backgroundContext.perform {
            
            let pin = Pin(latitude: coord.latitude, longitude: coord.longitude, context: self.fetchedResultsController.managedObjectContext)
            print("Just created a pin: \(pin)")

            
            do{
                try self.delegate.stack.backgroundContext.save()
                print("saved")
                try self.fetchedResultsController.performFetch()
                self.Pins = (self.fetchedResultsController.fetchedObjects as? [Pin])!
                print(self.Pins.count)
            }catch{
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
        
        
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "regionLat")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "regionLng")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "spanLat")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "spanLng")
    }
    
    
    
    
    @IBAction func editPins(_ sender: UIBarButtonItem){
        
        
    }
    
    


}

