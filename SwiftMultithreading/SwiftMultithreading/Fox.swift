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
    var image = UIImage(named: "photo")
    
    init(imageURL: String, name: String) {
        self.imageURL = imageURL
        self.name = name
      }
}
