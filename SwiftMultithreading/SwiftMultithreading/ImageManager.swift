//
//  NetworkManager.swift
//  SwiftMultithreading
//
//  Created by Pavlentiy on 16.02.2023.
//

import Foundation
import UIKit

protocol ImageManagerProtocol {
    func fetchRandomImageURL(completion: @escaping(Result<String, NetworkError>) -> Void)
    func fetchImage(from stringURL: String, completion: @escaping(Result<Data, NetworkError>) -> Void)
    func filterImage(_ image: UIImage?, completion: @escaping(UIImage?) -> Void)
}

enum NetworkError: Error {
    case invalidURL
    case fetchingError
    case decodeError
}

final class ImageManager: ImageManagerProtocol {

    static let shared = ImageManager()
    private init() {}
    
    private let dataSourceURL = "https://randomfox.ca/floof/"
    
    func fetchRandomImageURL(completion: @escaping (Result<String, NetworkError>) -> Void) {
        do {
            guard let url = URL(string: dataSourceURL) else {
                completion(.failure(.invalidURL))
                return
            }
            
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data)
            
            guard let object = json as? [String: String], let imageURL = object["image"] else {
                completion(.failure(.decodeError))
                return
            }
            
            completion(.success(imageURL))
        } catch {
            completion(.failure(.fetchingError))
        }
    }
    
    func fetchImage(from stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let url = URL(string: stringURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        if let imageData = try? Data(contentsOf: url) {
            completion(.success(imageData))
        } else {
            completion(.failure(.fetchingError))
        }
    }
    
    func filterImage(_ image: UIImage?, completion: @escaping (UIImage?) -> Void) {
        completion(applySepiaFilter(image))
    }
}

// MARK: - Private methods
extension ImageManager {
    private func applySepiaFilter(_ image: UIImage?) -> UIImage? {
        
        let inputImage = CIImage(data: image?.pngData() ?? Data())
        let context = CIContext(options: nil)
        let filter = CIFilter(name:"CISepiaTone")
        
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(0.8, forKey: "inputIntensity")
        
        guard let outputImage = filter?.outputImage,
              let outImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: outImage)
    }
}
