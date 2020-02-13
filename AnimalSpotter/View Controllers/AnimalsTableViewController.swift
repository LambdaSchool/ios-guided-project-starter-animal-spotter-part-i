//
//  AnimalsTableViewController.swift
//  AnimalSpotter
//
//  Created by Joseph Rogers on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AnimalsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var animalNames: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    //creating the api controller instance. we will pass this to the login view whenever needed.
    let apiController = APIController()

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // transition to login view if conditions require
        if apiController.bearer == nil {
            performSegue(withIdentifier: "LoginViewModalSegue", sender: self)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animalNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimalCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = animalNames[indexPath.row]

        return cell
    }

    // MARK: - Actions
    
    @IBAction func getAnimals(_ sender: UIBarButtonItem) {
//        // fetch all animals from API without looking for an error
//        apiController.fetchAllAnimalNames { result in
//            if let arrayOfAnimalsNames = try? result.get() {
//                DispatchQueue.main.async {
//                    self.animalNames = arrayOfAnimalsNames.sorted()
//                    //added the reload data to update the UI within the array of animals
//
//                }
//            }
//        }
        //allows us to process the success with error handling in a switch statement. 
        apiController.fetchAllAnimalNames { result in
            do {
                let names = try result.get()
                DispatchQueue.main.async {
                    self.animalNames = names
                    self.tableView.reloadData()
                }
            } catch {
                if let error = error as? NetworkError {
                    switch error {
                    case .noToken:
                        NSLog("No bearer token please login")
                    case .badToken:
                        NSLog("old or bad token.")
                    case .unknownNetworkError:
                        NSLog("Unknown network error")
                    case .decodeError:
                        NSLog("Bad decoding of data")
                    case .dataError:
                        NSLog("bad data")
                    case .badImageEncoding:
                        NSLog("bad image encoding")
                    case .badURL:
                        NSLog("Bad URL data")
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginViewModalSegue" {
            // inject dependencies
            if let loginVC = segue.destination as? LoginViewController {
                loginVC.apiController = apiController
            }
        } else if segue.identifier == "ShowAnimalDetailSegue" {
            //inject dependencies to the detail view. so they have the data needed.
            if let detailVC = segue.destination as? AnimalDetailViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    detailVC.animalName = animalNames[indexPath.row]
                }
                //deleted the fix me that was here idk why it was ever here. lol
                detailVC.apiController = apiController
            }
        }
    }
}
