//
//  DetailsVC.swift
//  FoursquareClone
//
//  Created by Mehmet Tuna Arıkaya on 6.07.2024.
//

import UIKit
import Parse
import MapKit

class DetailsVC: UIViewController {

    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeTypeLabel: UILabel!
    @IBOutlet weak var placeAtmosphereLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    var selectedPlaceId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let placeId = selectedPlaceId {
            fetchPlaceDetails(placeId: placeId)
        }
    }

    func fetchPlaceDetails(placeId: String) {
        let query = PFQuery(className: "Places")
        query.getObjectInBackground(withId: placeId) { (object, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            } else if let object = object {
                if let placeName = object["name"] as? String {
                    self.placeNameLabel.text = placeName
                }
                if let placeType = object["type"] as? String {
                    self.placeTypeLabel.text = placeType
                }
                if let placeAtmosphere = object["atmosphere"] as? String {
                    self.placeAtmosphereLabel.text = placeAtmosphere
                }
                if let latitude = object["latitude"] as? Double, let longitude = object["longitude"] as? Double {
                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: location, span: span)
                    self.mapView.setRegion(region, animated: true)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location
                    annotation.title = self.placeNameLabel.text
                    annotation.subtitle = self.placeTypeLabel.text
                    self.mapView.addAnnotation(annotation)
                }
                if let imageFile = object["image"] as? PFFileObject {
                    imageFile.getDataInBackground { (data, error) in
                        if let error = error {
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(okButton)
                            self.present(alert, animated: true, completion: nil)
                        } else if let data = data {
                            self.placeImageView.image = UIImage(data: data)
                        }
                    }
                }
            }
        }
    }
}
