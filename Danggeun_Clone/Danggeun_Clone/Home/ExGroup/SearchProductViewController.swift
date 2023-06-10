//
//  SearchProductViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/13.
//

import UIKit

class SearchProductViewController: UIViewController {
    
    let tags = ["아이폰", "아이패드", "맥북", "에어팟", "프로", "애플워치", "애플펜슬", "1세대", "2세대", "3세대"]
    
    var searchWords = [String]()
    var addressName: String = ""
    
    @IBOutlet var searchProductCollectionView: UICollectionView!
    @IBOutlet var searchWordsResultView: UIView!
    @IBOutlet var searchResultView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.array(forKey: "searchWords") == nil {
            UserDefaults.standard.set(searchWords, forKey: "searchWords")
        } else {
            searchWords = UserDefaults.standard.array(forKey: "searchWords") as? [String] ?? []
        }
        
        configureNavigationBar()
    
        searchProductCollectionView.collectionViewLayout = getLayout()
        searchWordsResultView.isHidden = true
        searchResultView.isHidden = true
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { (section , env) -> NSCollectionLayoutSection in
            switch section {
            case 0:
                return self.firstSection()
            case 1:
                return self.secondeSection()
            default:
                return self.secondeSection()
            }
        }
    }
    
    func firstSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(8), top: .fixed(0), trailing: .fixed(8), bottom: .fixed(0))
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        section.orthogonalScrollingBehavior = .continuous
        
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        section.boundarySupplementaryItems = [header]
      
        return section
    }
    
    func secondeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        //section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.titleView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.titleView?.translatesAutoresizingMaskIntoConstraints = true
        
        UserDefaults.standard.set(searchWords, forKey: "searchWords")
    }
    
    func configureNavigationBar() {
        let container = SearchAddressContainerView()
        container.backgroundColor = .white
        
        container.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        
        searchBar.becomeFirstResponder()
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.placeholder = "\(addressName.components(separatedBy: " ").last ?? "") 근처에서 검색"
        }
    
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(searchBar)
    
        searchBar.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        self.navigationItem.titleView = container
    }
}

extension SearchProductViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if searchWords.isEmpty {
            return 1
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return tags.count
        } else {
            return searchWords.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as? TagCollectionViewCell else { return UICollectionViewCell() }
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.systemGray4.cgColor
            cell.layer.cornerRadius = cell.frame.height * 0.5
            cell.nameLabel.text = tags[indexPath.row]
            cell.tag = indexPath.row
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productNameCell", for: indexPath) as? SearchProductCollectionViewCell else { return UICollectionViewCell() }
            cell.searchWordLabel.text = searchWords[indexPath.row]
            cell.deleteButton.tag = indexPath.row
            cell.tag = indexPath.row
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath) as? SearchProductHeaderCollectionReusableView else { return UICollectionReusableView() }
        
        if indexPath.section == 0 {
            header.headerLabel.text = "이웃들이 많이 찾고 있어요!"
            header.deleteAllWordsButton.isHidden = true
            return header
        } else {
            header.headerLabel.text = "최근 검색어"
            header.delegate = self
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let searchBar = self.navigationItem.titleView?.subviews[0] as? UISearchBar else { return }
        
        if indexPath.section == 0 {
            searchResultView.isHidden = false
            if let index = collectionView.cellForItem(at: indexPath)?.tag {
                if let cVC = self.children[1] as? SearchResulteViewController {
                    cVC.fetchProducts(text: tags[index])
                    searchBar.text = tags[index]
                    searchBar.resignFirstResponder()
                }
            }
        } else {
            searchResultView.isHidden = false
            if let index = collectionView.cellForItem(at: indexPath)?.tag {
                if let cVC = self.children[1] as? SearchResulteViewController {
                    cVC.fetchProducts(text: searchWords[index])
                    searchBar.text = searchWords[index]
                    searchBar.resignFirstResponder()
                }
            }
        }
    }
}

extension SearchProductViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 44)
    }
}

extension SearchProductViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            searchWordsResultView.isHidden = false
            if let cVC = self.children[0] as? SearchListViewController {
                cVC.filterdRelatedWords(text: searchText)
            }
        } else if searchText == "" {
            searchWordsResultView.isHidden = true
            searchResultView.isHidden = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            searchWords.append(text)
            UserDefaults.standard.set(searchWords, forKey: "searchWords")
            
            searchWordsResultView.isHidden = true
            searchResultView.isHidden = false
            
            if let cVC = self.children[1] as? SearchResulteViewController {
                cVC.fetchProducts(text: text)
            }
        }
    }
}

extension SearchProductViewController: SearchProductHeaderCollectionReusableViewDelegate {
    func deleteAllWords() {
        self.searchWords.removeAll()
        
        DispatchQueue.main.async {
            if self.searchWords.isEmpty {
                self.searchProductCollectionView.reloadData()
            } else {
                self.searchProductCollectionView.reloadSections(IndexSet(integer: 1))
            }
        }
    }
}

extension SearchProductViewController: SearchProductCollectionViewCellDelegate {
    func deleteSearchWord(index: Int) {
        searchWords.remove(at: index)
        
        DispatchQueue.main.async {
            if self.searchWords.isEmpty {
                self.searchProductCollectionView.reloadData()
            } else {
                self.searchProductCollectionView.reloadSections(IndexSet(integer: 1))
            }
        }
    }
}
