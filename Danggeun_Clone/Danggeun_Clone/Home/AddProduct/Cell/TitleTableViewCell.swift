//
//  TitleTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/02.
//

import UIKit

// MARK: [Protocol] ----------
protocol TitleTableViewCellDelegate: AnyObject {
    func updateTextViewHeight(cell: TitleTableViewCell, textView: UITextView)
}

// MARK: [Class or Struct] ----------
class TitleTableViewCell: UITableViewCell {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var titlePlaceholderLabel: UILabel!

    @IBOutlet var categoryCollectionStackView: UIStackView!
    @IBOutlet var categoryCollectionView: UICollectionView!
    
    @IBOutlet var moveCategoryButton: UIButton!
    
    // MARK: [Let Or Var] ----------
    weak var delegate: TitleTableViewCellDelegate?
    var categoryList = CategoryModel.configureCategoryList()
 
    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configTextView()
        configCategoryCollectionView()
        
    }
    
    // MARK: [Function] ----------
    func configCategoryList(productCategory: String?) {
        if productCategory == nil {
            categoryList = categoryList.shuffled().prefix(3).map({$0})
        } else {
            var filteredCategory = categoryList.filter({$0.categoryName == productCategory ?? ""})
            filteredCategory[0].isSelected = true
            categoryList = categoryList.shuffled().prefix(2).map({$0})
            categoryList.insert(contentsOf: filteredCategory, at: 0)
        }
    }

    func configTextView() {
        titleTextView.delegate = self
        titleTextView.isScrollEnabled = false
        titleTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.sizeToFit()
        
        categoryCollectionStackView.isHidden = true
        
        titlePlaceholderLabel.textColor = .placeholderText
    }
    
    func configCategoryCollectionView() {
        categoryCollectionView.dataSource = self
        categoryCollectionView.collectionViewLayout = createLayout()
    }

    func createLayout() -> UICollectionViewCompositionalLayout {

        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1)))

        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1)), subitem: item, count: 1)

        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: nil, trailing: .fixed(5), bottom: nil)

        let section = NSCollectionLayoutSection(group: group)

        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)

        section.orthogonalScrollingBehavior = .continuous

        return UICollectionViewCompositionalLayout(section: section)
    }
}

// MARK: [TextView - Delegate] ----------
extension TitleTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {

        delegate?.updateTextViewHeight(cell: self, textView: textView)
        titlePlaceholderLabel.isHidden = textView.text == "" ? false : true
    }
}

// MARK: [CollectionView - DataSource] ----------
extension TitleTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell() }
        cell.categoryNameLabel.text = categoryList[indexPath.row].categoryName
        
        if categoryList[indexPath.row].isSelected == true {
            // 선택시 색상 변경
            cell.layer.borderColor = UIColor.orange.cgColor
            cell.layer.backgroundColor = UIColor.orange.cgColor
            cell.categoryNameLabel.textColor = .white
            cell.categoryNameLabel.font = .systemFont(ofSize: 13, weight: .bold)
        } else {
            cell.layer.borderColor = UIColor.systemGray4.cgColor
            cell.layer.backgroundColor = UIColor.white.cgColor
            cell.categoryNameLabel.textColor = .black
            cell.categoryNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        }
        
        cell.tag = indexPath.row
        return cell
    }
}

