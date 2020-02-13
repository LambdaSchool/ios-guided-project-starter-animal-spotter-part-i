//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Joseph Rogers on 4/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case badImageEncoding
    case badURL
    case noToken
    case badToken
    case unknownNetworkError
    case dataError
    case decodeError
}

//created the network errors that are possible.

class APIController {
    
    private let baseUrl = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    var bearer: Bearer?
    
    // create function for sign up
    func signUp(with user: User, completion: @escaping (Error?) -> ()) {
        
        let signUpURL = baseUrl.appendingPathComponent("users/signup")
        //creates request
        var request = URLRequest(url: signUpURL)
        request.httpMethod = HTTPMethod.post.rawValue
        //payload below
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //json encoder. converts the user into json.
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        }catch {
            print("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            completion(nil)
        }.resume()
    }
    
    // create function for sign in
    
    func signIn(with user: User, completion: @escaping (Error?) -> ()) {
        
        let loginUrl = baseUrl.appendingPathComponent("users/login")
        //creates request
        var request = URLRequest(url: loginUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        //payload below
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //json encoder. converts the user into json.
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        }catch {
            print("Error encoding user object: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                self.bearer = try decoder.decode(Bearer.self, from: data)
            } catch {
                print("Error decoding bearer object: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    // create function for fetching all animal names
    
    func fetchAllAnimalNames(completion: @escaping (Result<[String], NetworkError>) -> Void) {
        //this is saying we dont have a token at all.
        guard let bearer = bearer else {
            completion(.failure(.noToken))
            return
        }
        
        let allAnimalsURL = baseUrl.appendingPathComponent("animals/all")
        var request = URLRequest(url: allAnimalsURL)
        //adding the request as a full URL, getting the method for it, getting the header and token.
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        //handles the response. putting the request we made in the shared data task
        URLSession.shared.dataTask(with: request) { data, response, error in
            //check for bad tokens. this is saying that the token is bad or expired. not that it doesn't exist.
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badToken))
                return
            }
            //check for errors
            if let error = error {
                NSLog("Error reeiving animal name data: \(error)")
                completion(.failure(.unknownNetworkError))
                return
            }
            
            //see if we have data
            guard let data = data else {
                completion(.failure(.dataError))
                return
            }
            //convert the data from json into an array of strings in swift
            let decoder = JSONDecoder() // can throw an error so throw it in a do block
            do {
                let animalNames = try decoder.decode([String].self, from: data)
                completion(.success(animalNames))
            } catch {
                print("Error decoding animal objects: \(error)")
                completion(.failure(.decodeError))
                return
            }
        }.resume()
    }
    
    //create function for fetching a specific animal
    
    func fetchDetails(for animalName: String, completion: @escaping (Result<Animal, NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noToken))
            return
        }
        
        let AnimalURL = baseUrl.appendingPathComponent("animals/\(animalName)")
        var request = URLRequest(url: AnimalURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            //check for bad tokens
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badToken))
                return
            }
            //check for errors
            if let error = error {
                print("Error receiving (\(animalName)) animal detail data: \(error)")
                completion(.failure(.unknownNetworkError))
                return
            }
            
            //see if we have data
            guard let data = data else {
                completion(.failure(.dataError))
                return
            }
            //convert the data from json into an array of strings in swift
            let decoder = JSONDecoder() // can throw an error so throw it in a do block
            decoder.dateDecodingStrategy = .secondsSince1970
            do {
                let animal = try decoder.decode(Animal.self, from: data)
                completion(.success(animal))
            } catch {
                NSLog("Error decoding animal object: \(error)")
                completion(.failure(.decodeError))
                return
            }
        }.resume()
    }
    
    // create function to fetch image
    
    func fetchImage(at urlString: String, completion: @escaping (Result<UIImage, NetworkError>) -> ()) {
       
        //unwrapped the image URL instead of force unwrapping it.
        guard let imageURL = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }
        var request = URLRequest(url: imageURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let _ = error {
                completion(.failure(.unknownNetworkError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.dataError))
                return
            }
            guard let image = UIImage(data: data) else {
                completion(.failure(.badImageEncoding))
                return
            }
            completion(.success(image))
        }.resume()
    }
}
