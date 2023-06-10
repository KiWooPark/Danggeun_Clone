//
//  SearchResulteViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/27.
//

import UIKit

class SearchResulteViewController: UIViewController {
    
    @IBOutlet var productListTableView: UITableView!
    
    let list = ["1","1","1","1","1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // nib파일 연결
        let nibName = UINib(nibName: "ProductTableViewCell", bundle: nil)
        productListTableView.register(nibName, forCellReuseIdentifier: "productCell")
    }
    
    func fetchProducts(text: String) {
        productListTableView.reloadData()
    }
}

extension SearchResulteViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
            return cell
        }
    }
}

extension SearchResulteViewController: UITableViewDelegate {
    
}
