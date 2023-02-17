//
//  OperatoinQueueImageManager.swift
//  SwiftMultithreading
//
//  Created by Pavlentiy on 17.02.2023.
//

import UIKit

protocol OperationQueueImageManagerProtocol {
    func fetchRandomImageURL(completion: @escaping(Result<String, NetworkError>) -> Void)
    func startDownload(for fox: Fox, at indexPath: IndexPath, completion: @escaping() -> Void)
    func startFiltration(for fox: Fox, at indexPath: IndexPath, completion: @escaping() -> Void)
}

final class OperationQueueImageManager: OperationQueueImageManagerProtocol {
    
    static let shared = OperationQueueImageManager()
    private init() {}
    
    private let dataSourceURL = "https://randomfox.ca/floof/"
    private let pendingOperations = PendingOperations()
    
    func startDownload(for fox: Fox, at indexPath: IndexPath, completion: @escaping() -> Void) {
        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        
        let downloader = ImageDownloader(fox)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                completion()
            }
        }
        
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func startFiltration(for fox: Fox, at indexPath: IndexPath, completion: @escaping() -> Void) {
        guard pendingOperations.filtrationsInProgress[indexPath] == nil else {
            return
        }
        
        let filterer = ImageFiltration(fox)
        filterer.completionBlock = {
            if filterer.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
                completion()
            }
        }
        
        pendingOperations.filtrationsInProgress[indexPath] = filterer
        pendingOperations.filtrationQueue.addOperation(filterer)
    }

    func fetchRandomImageURL(completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let url = URL(string: dataSourceURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession(configuration: .default).dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: String]

                    guard let imageURL = json?["image"] else {
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

            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(.fetchingError))
                }
            }
        }

        task.resume()
    }
}

class PendingOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        return queue
    }()
    
    lazy var filtrationsInProgress: [IndexPath: Operation] = [:]
    lazy var filtrationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Filtration queue"
        return queue
    }()
}

class ImageDownloader: Operation {
    let fox: Fox
    
    init(_ fox: Fox) {
        self.fox = fox
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        guard let url = URL(string: fox.imageURL),
                let imageData = try? Data(contentsOf: url) else { return }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            fox.image = UIImage(data:imageData)
            fox.state = .downloaded
        } else {
            fox.state = .failed
        }
    }
}

class ImageFiltration: Operation {
    let fox: Fox
    
    init(_ fox: Fox) {
        self.fox = fox
    }
    
    override func main () {
        if isCancelled {
            return
        }
        
        guard self.fox.state == .downloaded else {
            return
        }
        
        if let image = fox.image,
           let filteredImage = applySepiaFilter(image) {
            fox.image = filteredImage
            fox.state = .filtered
        }
    }
    
    private func applySepiaFilter(_ image: UIImage) -> UIImage? {
        guard let data = image.pngData() else { return nil }
        let inputImage = CIImage(data: data)
        
        if isCancelled {
            return nil
        }
        
        let context = CIContext(options: nil)
        
        guard let filter = CIFilter(name: "CISepiaTone") else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(0.8, forKey: "inputIntensity")
        
        if isCancelled {
            return nil
        }
        
        guard
            let outputImage = filter.outputImage,
            let outImage = context.createCGImage(outputImage, from: outputImage.extent)
        else {
            return nil
        }
        
        return UIImage(cgImage: outImage)
    }
    
}

