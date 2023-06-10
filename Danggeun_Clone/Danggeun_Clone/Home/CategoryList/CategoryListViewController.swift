//
//  CategoryListViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/04.
//

import UIKit

// MARK: [Protocol] ----------
protocol CategoryListDelegate: AnyObject {
    func changeCategoryName(selectedCategory: CategoryModel)
}

// MARK: [Class or Struct] ----------
class CategoryListViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var categoryTableView: UITableView!
    
    // MARK: [Let Or Var] ----------
    var categoryList = CategoryModel.configureCategoryList()
    weak var delegat: CategoryListDelegate?
    var selectedCategory: String?
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()

        if let index = categoryList.firstIndex(where: {$0.categoryName == selectedCategory}) {
            categoryList[index].isSelected = true
            categoryTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .none, animated: true)
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.standardAppearance = appearance
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let index = categoryList.firstIndex(where: {$0.categoryName == selectedCategory}) {
            categoryTableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .none, animated: true)
        }
    }
}

// MARK: [TableView - DataSource] ----------
extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") else { return UITableViewCell() }
        cell.textLabel?.text = categoryList[indexPath.row].categoryName
        cell.textLabel?.textColor = categoryList[indexPath.row].isSelected ? UIColor(displayP3Red: 237/255, green: 125/255, blue: 52/255, alpha: 1) : .black
        cell.tintColor = UIColor(displayP3Red: 237/255, green: 125/255, blue: 52/255, alpha: 1)
        cell.accessoryType = categoryList[indexPath.row].isSelected ? .checkmark : .none
        return cell
    }
}

// MARK: [TableView - Delegate] ----------
extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            if row == indexPath.row {
                categoryList[row].isSelected = true
                delegat?.changeCategoryName(selectedCategory: categoryList[row])
            } else {
                categoryList[row].isSelected = false
            }
        }
        
        categoryTableView.reloadData()
        self.navigationController?.popViewController(animated: true)
    }
}
