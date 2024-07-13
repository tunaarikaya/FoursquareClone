//
//  addPlaceVC.swift
//  FoursquareClone
//
//  Created by Mehmet Tuna Arıkaya on 6.07.2024.
//

import UIKit
import Parse

class addPlaceVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var placeNameText: UITextField!
    @IBOutlet weak var placeTypeText: UITextField!
    @IBOutlet weak var placeAtmosphereText: UITextField!
    @IBOutlet weak var placeImageView: UIImageView! // İsmi placeImageText yerine placeImageView olarak değiştirdim.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        placeImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        placeImageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if placeNameText.text != "" && placeTypeText.text != "" && placeAtmosphereText.text != "" {
            if let chosenImage = placeImageView.image {
                let placeModel = PlaceModel.sharedInstance
                placeModel.placeName = placeNameText.text!
                placeModel.placeType = placeTypeText.text!
  
                placeModel.placeImage = chosenImage // chooseImage değil chosenImage olacak
                
                performSegue(withIdentifier: "toMapVC", sender: nil)
            }
        } else {
            // Boş alan varsa kullanıcıya uyarı ver
            let alert = UIAlertController(title: "Hata", message: "Tüm alanları doldurmalısınız.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alert.addAction(okButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func chooseImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
}

// Assuming you have a PlaceModel singleton to store the place details
class PlaceModel {
    static let sharedInstance = PlaceModel()
    
    var placeName: String?
    var placeType: String?
    var placeAtmosphere: String?
    var placeImage: UIImage?
    
    private init() { }
}
