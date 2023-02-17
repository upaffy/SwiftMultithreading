//
//  ViewController.swift
//  SwiftMultithreading
//
//  Created by Pavlentiy on 16.02.2023.
//

import UIKit
import CoreImage

let pageSize = 20
let imageManager = OperationQueueImageManager.shared

class FoxListViewController: UITableViewController {
    
    var foxes: [Fox] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavBar()
        fetchFoxes()
    }
}

// MARK: - Table view data source
extension FoxListViewController {
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return foxes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FoxListCell.reuseId,
            for: indexPath
        ) as? FoxListCell else {
            return UITableViewCell()
        }
        
        let fox = foxes[indexPath.row]
        
        cell.foxTitle.text = fox.name
        cell.foxImage.image = fox.image
        
        switch (fox.state) {
        case .filtered:
            break
        case .failed:
            cell.foxTitle.text = "Failed to load"
        case .new:
            imageManager.startDownload(for: fox, at: indexPath) {
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .downloaded:
            imageManager.startFiltration(for: fox, at: indexPath) {
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        
        return cell
    }
}

// MARK: - private methods
extension FoxListViewController {
    private func fetchFoxes() {
        for _ in 0..<pageSize {
            imageManager.fetchRandomImageURL { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let imageURL):
                    let fox = Fox(name: "Лиса №\(self.foxes.count + 1)", imageURL: imageURL)
                    self.foxes.append(fox)
                    self.tableView.reloadData()
                case .failure(_):
                    break
                }
            }
        }
    }
    
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
