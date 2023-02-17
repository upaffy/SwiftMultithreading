//
//  Fox.swift
//  SwiftMultithreading
//
//  Created by Pavlentiy on 16.02.2023.
//

import UIKit

enum ImageState {
    case new, downloaded, filtered, failed
}

class Fox {
    let imageURL: String
    let name: String
    var state = ImageState.new
    var image = UIImage(systemName: "photo")
    
    init(name: String, imageURL: String) {
        self.name = name
        self.imageURL = imageURL
    }
}
