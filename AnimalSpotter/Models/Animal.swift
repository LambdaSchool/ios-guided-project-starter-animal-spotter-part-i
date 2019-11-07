//
//  Animal.swift
//  AnimalSpotter
//
//  Created by Joseph Rogers on 11/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
//conforms to the api.
struct Animal: Codable{
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let timeSeen: Date
    let description: String
    let imageURL: String
}
