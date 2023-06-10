//
//  SearchListViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/27.
//

import UIKit

class SearchListViewController: UIViewController {

    var searchWords = [String]()
    var result = [String]()
    
    @IBOutlet var relatedWordsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let path = Bundle.main.path(forResource: "searchWords", ofType: "csv") else { return }
        fetchSearchWords(url: URL(fileURLWithPath: path))
    }
    
    
    
    func fetchSearchWords(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoder = String(data: data, encoding: .utf8)
            
            if let words = dataEncoder?.components(separatedBy: "\n").map({$0.replacingOccurrences(of: "\r", with: "")}).dropLast() {
                searchWords = words.map({String($0)})
            }
        } catch {
            print("CSV 불러오기 실패")
        }
    }
    
    func filterdRelatedWords(text: String?) {
        guard let text = text else { return }
        result = searchWords.filter({$0.contains(text)})
        relatedWordsTableView.reloadData()
    }
}


extension SearchListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchWordCell") as? SearchWordTableViewCell else { return UITableViewCell() }
        cell.searchWordLabel.text = result[indexPath.row]
        return cell
    }
}

extension SearchListViewController: UITableViewDelegate {
    
}
