//
//  AnimalDetailViewController.swift
//  AnimalSpotter
//
//  Created by Joseph Rogers on 10/31/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var timeSeenLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var animalImageView: UIImageView!
    
    
    //created a dependant. we will inject it with data.
    var animalName: String?
    var apiController: APIController?
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        getDetails()
    }
    
    private func getDetails() {
        guard let apiController = apiController,
            let animalName = animalName else {return}
        
        apiController.fetchDetails(for: animalName) { (result) in
            do{
                let animal = try result.get()
                DispatchQueue.main.async {
                    self.updateViews(with: animal)
                }
                apiController.fetchImage(at: animal.imageURL) { (result) in
                    if let image = try? result.get() {
                        DispatchQueue.main.async {
                            self.animalImageView.image = image
                        }
                    }
                }
            } catch {
                if let error = error as? NetworkError {
                    switch error {
                    case .noToken:
                        print("No error token exists")
                        //testing an error case
                        let alertController = UIAlertController(title: "Not Logged in", message: "please log in before you try to use the app!", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true)
                    case .badToken:
                        print("Bearing token invalid")
                    case .dataError:
                        print("Other error occured, see log")
                    case .unknownNetworkError:
                        print("no data received, or data corrupted")
                    case .decodeError:
                        print("JSON could not be decoded")
                    }
                }
            }
        }
    }
    
    private func updateViews(with animal: Animal) {
        title = animal.name
        descriptionLabel.text = animal.description
        coordinatesLabel.text = "lat: \(animal.latitude), long: \(animal.longitude)"
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        timeSeenLabel.text = df.string(from: animal.timeSeen)
    }
}
