//
//  ViewController.swift
//  SwiftMultithreading
//
//  Created by Pavlentiy on 16.02.2023.
//

import UIKit
import CoreImage

let pageSize = 20
let imageManager = ImageManager.shared

class FoxListViewController: UITableViewController {

    lazy var imagesURL: [String] = {
        var images: [String] = []
        
        for _ in 0..<pageSize {
            imageManager.fetchRandomImageURL { result in
                switch result {
                case .success(let imageURL):
                    images.append(imageURL)
                case .failure(_):
                    break
                }
            }
        }
        
        return images
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavBar()
    }
}

// MARK: - Table view data source
extension FoxListViewController {
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return imagesURL.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FoxListCell.reuseId,
            for: indexPath
        ) as? FoxListCell else {
            return UITableViewCell()
        }
        
        let fox = Fox(
            imageURL: imagesURL[indexPath.row],
            name: "Лиса №\(indexPath.row + 1)"
        )
        cell.configure(with: fox)
        
        return cell
    }
}

// MARK: - private methods
extension FoxListViewController {
    private func setupTableView() {
        tableView.register(
            UINib(nibName: FoxListCell.reuseId, bundle: nil),
            forCellReuseIdentifier: FoxListCell.reuseId
        )
        
        tableView.backgroundColor = UIColor(red: 232/255, green: 237/255, blue: 237/255, alpha: 1)
    }
    
    private func setupNavBar() {
        self.title = "Foxes"
    }
}
