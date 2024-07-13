//
//  mapVC.swift
//  FoursquareClone
//
//  Created by Mehmet Tuna Arıkaya on 6.07.2024.
//

import UIKit
import MapKit
import Parse

class mapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var chosenLatitude: Double?
    var chosenLongitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonClicked))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backButtonClicked))
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = placeModel.sharedInstance.placeName
            annotation.subtitle = placeModel.sharedInstance.placeType
            self.mapView.addAnnotation(annotation)
        }
    }

    @objc func saveButtonClicked() {
        if let chosenLatitude = chosenLatitude, let chosenLongitude = chosenLongitude {
            let placeModel = PlaceModel.sharedInstance
            
            let object = PFObject(className: "Places")
            object["name"] = placeModel.placeName
            object["type"] = placeModel.placeType
            object["atmosphere"] = placeModel.placeAtmosphere
            object["latitude"] = chosenLatitude
            object["longitude"] = chosenLongitude
            
            if let imageData = placeModel.placeImage?.jpegData(compressionQuality: 0.5) {
                let imageFile = PFFileObject(name: "image.jpg", data: imageData)
                object["image"] = imageFile
            }
            
            object.saveInBackground { (success, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "toPlacesVC", sender: nil)
                }
            }
        }
    }
    
    @objc func backButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
}
