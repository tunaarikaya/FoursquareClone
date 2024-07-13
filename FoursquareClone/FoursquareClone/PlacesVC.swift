//
//  PlacesVC.swift
//  FoursquareClone
//
//  Created by Mehmet Tuna Arıkaya on 6.07.2024.
//

import UIKit
import Parse

class PlacesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var placeNames = [String]()
    var placeIds = [String]()
    var selectedPlaceId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: UIBarButtonItem.Style.plain, target: self, action: #selector(logoutButtonClicked))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchPlaces()
    }
    
    @objc func addButtonClicked() {
        self.performSegue(withIdentifier: "toAddPlaceVC", sender: nil)
    }
    
    @objc func logoutButtonClicked() {
        PFUser.logOutInBackground { (error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.performSegue(withIdentifier: "toSignUpVC", sender: nil)
            }
        }
    }
    
    func fetchPlaces() {
        let query = PFQuery(className: "Places")
        query.findObjectsInBackground { (objects, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            } else if let objects = objects {
                self.placeNames.removeAll()
                self.placeIds.removeAll()
                
                for object in objects {
                    if let placeName = object["name"] as? String, let placeId = object.objectId {
                        self.placeNames.append(placeName)
                        self.placeIds.append(placeId)
                    }
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = placeNames[indexPath.row]
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlaceId = placeIds[indexPath.row]
        self.performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.selectedPlaceId = selectedPlaceId
        }
    }
}
