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
        DispatchQueue.global().async {
            do {
                guard let url = URL(string: self.dataSourceURL) else {
                    DispatchQueue.main.async {
                        completion(.failure(.invalidURL))
                    }
                    return
                }
                
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data)
                
                guard let object = json as? [String: String], let imageURL = object["image"] else {
                    DispatchQueue.main.async {
                        completion(.failure(.decodeError))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(imageURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.fetchingError))
                }
            }
        }
    }
    
    func fetchImage(from stringURL: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        DispatchQueue.global().async {
            guard let url = URL(string: stringURL) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidURL))
                }
                return
            }
            
            if let imageData = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    completion(.success(imageData))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(.fetchingError))
                }
            }
        }
    }
    
    func filterImage(_ image: UIImage?, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let filteredImage = self.applySepiaFilter(image)
            DispatchQueue.main.async {
                completion(filteredImage)
            }
        }
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
