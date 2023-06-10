//
//  CategoryViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/05/11.
//

import UIKit

protocol CategoryViewDelegate {
    func changeCategoryName(categoryName: String)
}

class CategoryViewController: UIViewController {
    
    @IBOutlet var categoryListTableView: UITableView!

    var categoryList = CategoryModel.configureCategoryList()
    var delegate: CategoryViewDelegate?
    var selectedCategory: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        guard let selectedCategory = selectedCategory else { return }
        guard let index = categoryList.firstIndex(where: {$0.categoryName == selectedCategory}) else { return }
        categoryList[index].isSelected = true
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let target = categoryList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        cell.textLabel?.text = target.categoryName
        cell.textLabel?.textColor = target.isSelected ? UIColor(displayP3Red: 237/255, green: 125/255, blue: 52/255, alpha: 1) : .black
        cell.tintColor = UIColor(displayP3Red: 237/255, green: 125/255, blue: 52/255, alpha: 1)
        cell.accessoryType = target.isSelected ? .checkmark : .none
        
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            if row == indexPath.row {
                categoryList[row].isSelected = true
                delegate?.changeCategoryName(categoryName: categoryList[row].categoryName)
            } else {
                categoryList[row].isSelected = false
            }
        }
        categoryListTableView.reloadData()
        self.navigationController?.popViewController(animated: true)
    }
}
