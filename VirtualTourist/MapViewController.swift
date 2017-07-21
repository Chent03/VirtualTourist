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
    var fr: NSFetchRequest<NSFetchRequestResult>!
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
        fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false)]
        
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Hello")
        
        self.selectedPin(coordinates: (view.annotation?.coordinate)!) { (error, pin) in
            
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let selectedPin = pin else {
                print("no pin found")
                return
            }
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            request.sortDescriptors = [NSSortDescriptor(key: "pin", ascending: true)]
            let pred = NSPredicate(format: "pin = %@", argumentArray: [pin])
            
            let fc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
            
            let albumView = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            
            albumView.fetchedResultsController = fc
            albumView.pin = pin
            
            self.navigationController?.pushViewController(albumView, animated: true)
            
        }
    
        
    }
    
    func selectedPin(coordinates: CLLocationCoordinate2D, completionHandlerForSelected: @escaping (_ error: String?, _ pin: Pin?) -> Void) {
        
        let latitudePred = NSPredicate(format: "latitude = %@", argumentArray: [coordinates.latitude])
        let longitudePred = NSPredicate(format: "longitude = %@", argumentArray: [coordinates.longitude])
        
        let pred =  NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [latitudePred, longitudePred])
        fr.predicate = pred
        
        do{
            try fetchedResultsController.performFetch()
        }catch{
            print("Error in fetching")
        }
        
        guard let pin = fetchedResultsController.fetchedObjects?[0] as? Pin else {
            completionHandlerForSelected("No pin found in core data", nil)
            return
        }
        print(pin.latitude)
        
        completionHandlerForSelected(nil, pin)
    
    }
    
   
    
    func loadPins(){
        do{
            try self.fetchedResultsController.performFetch()
        }catch{
            print("Fetching Error")
        }
        print(fetchedResultsController.fetchedObjects!.count)
        self.Pins = (fetchedResultsController.fetchedObjects as? [Pin])!
        
        if !self.Pins.isEmpty {
            for pin in self.Pins {
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
        
        if gesture.state == UIGestureRecognizerState.ended {
            let point = gesture.location(in: self.mapView)
            
            let coord = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            
            print(coord.latitude)
            print(coord.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            self.mapView.addAnnotation(annotation)
            
            
            let pin = Pin(latitude: coord.latitude, longitude: coord.longitude, context: self.fetchedResultsController.managedObjectContext)
            print("Just created a pin: \(pin)")
            
            
            self.delegate.stack.save()
            print("saved")
            
            FlickrClient.sharedInstance().searchFlickr(latitude: coord.latitude, longitude: coord.longitude)
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

