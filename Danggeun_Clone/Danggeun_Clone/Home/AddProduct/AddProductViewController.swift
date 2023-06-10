//
//  AddProductViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/02.
//

import UIKit
import BSImagePicker

// MARK: [Protocol] ----------
protocol AddProductViewControllerDelegate: AnyObject {
    func fetchAddProduct()
    func fetchDetailProductData(productData: [String: Any], images: [UIImage])
}

// MARK: [Class or Struct] ----------
class AddProductViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var addProductTableView: UITableView!
    @IBOutlet var downKeyboardBaseViewBottom: NSLayoutConstraint!
    
    // MARK: [Let Or Var] ----------
    var titleTextViewTimer: Timer?
    var isShowKeyboard = false

    let imagePicker = ImagePickerController()
    
    var selectedImages = [UIImage]()
    
    let loginUserData = UserModel.getUserData()
    
    weak var addProductDelegate: AddProductViewControllerDelegate?
    weak var homeDelegate: AddProductViewControllerDelegate?
    
    var accessController = AccessControllerType.none
    
    var productData: ProductRegistrationModel?
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if productData?.productImages == nil {
            FirebaseManager.shared.downloadProductImages(urls: productData?.imagesURL) { result in
                switch result {
                case .success(let images):
                    self.selectedImages = images
                    
                    DispatchQueue.main.async {
                        self.addProductTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            selectedImages = productData?.productImages ?? []
        }
            
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 키보드 높이
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        print("viewWillAppear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        print("viewDidDisappear")
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews")
    }
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
    }
    
    // MARK: [@IBAction] ----------
    @IBAction func tapDoneButton(_ sender: Any) {
    
        guard let titleCell = addProductTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TitleTableViewCell else { return }
        guard let priceCell = addProductTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? PriceTableViewCell else { return }
        guard let contentCell = addProductTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? ContentTableViewCell else { return }
       
        if accessController == .productDetailVC || accessController == .moreProductsVC {
            let productData = [
                "title": titleCell.titleTextView.text ?? "",
                "contents": contentCell.contentTextView.text ?? "",
                "price": (priceCell.priceTextField.text)?.components(separatedBy: ",").joined(),
                "category": titleCell.categoryList.filter({$0.isSelected}).first?.categoryName ?? "",
            ] as [String : Any]
        
            
            FirebaseManager.shared.editProduct(id: self.productData?.productId ?? "", phoneNumber: self.productData?.phoneNumber ?? "", address: self.productData?.address ?? "", productData: productData, selectedImages: selectedImages) { result in
                switch result {
                case .success(_):
                    
                    if self.accessController == .productDetailVC {
                        self.addProductDelegate?.fetchDetailProductData(productData: productData, images: self.selectedImages)
                        self.homeDelegate?.fetchAddProduct()
                    } else {
                        NotificationCenter.default.post(name: .updateTradingProduct, object: nil)
                        NotificationCenter.default.post(name: .updateCompletedProduct, object: nil)
                        NotificationCenter.default.post(name: .updateHiddenProduct, object: nil)
                    }
                    self.dismiss(animated: true)
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            let productData = [
                "title": titleCell.titleTextView.text ?? "",
                "contents": contentCell.contentTextView.text ?? "",
                "price": (priceCell.priceTextField.text)?.components(separatedBy: ",").joined(),
                "category": titleCell.categoryList.filter({$0.isSelected}).first?.categoryName ?? "",
                "phoneNumber": loginUserData?.phoneNumber ?? "",
                "address": loginUserData?.selectedAddress ?? "",
                "hidden": false,
                "status": ProductStatusType.trading.rawValue,
                "reservation": false,
            ] as [String : Any]
            
            FirebaseManager.shared.addProduct(productData: productData, selectedImages: selectedImages) { result in
                switch result {
                case .success(_):
                    self.homeDelegate?.fetchAddProduct()
                    self.dismiss(animated: true)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func tapKeyboardDownButton(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    // MARK: [@objc Function] ----------
    @objc func keyboardWillShow(_ notification:NSNotification) {
        
        if isShowKeyboard {
            return
        }
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            isShowKeyboard = true
            
            self.downKeyboardBaseViewBottom.constant = keyboardHeight - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification:NSNotification) {
        isShowKeyboard = false
        self.downKeyboardBaseViewBottom.constant = 0
        self.view.layoutIfNeeded()
    }

    @objc func showCategoryCollectionView() {
        if let cell = addProductTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TitleTableViewCell {
            cell.categoryCollectionStackView.isHidden = false
            
            UIView.setAnimationsEnabled(false)
            addProductTableView.beginUpdates()
            addProductTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    @objc func deletePhoto(sender: UIButton) {
        selectedImages.remove(at: sender.tag)
        if let cell = addProductTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PhotosTableViewCell {
            cell.selectedImages = self.selectedImages
            
            DispatchQueue.main.async {
                cell.photoCollectionView.reloadData()
            }
        }
    }
    
    @objc func tapMoveCategoryListButton() {
        let storyboard = UIStoryboard(name: "CategoryList", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "categoryVC") as? CategoryListViewController else { return }
        guard let titleCell = addProductTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TitleTableViewCell else { return }
        vc.delegat = self
        vc.selectedCategory = titleCell.categoryList.first(where: {$0.isSelected == true})?.categoryName
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: [TableView - DataSource] ----------
extension AddProductViewController: UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "photosTableViewCell", for: indexPath) as? PhotosTableViewCell else { return UITableViewCell() }
            
            cell.selectedImages = selectedImages
            cell.photoCollectionView.delegate = self
            cell.rootVC = self
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "titleTableViewCell", for: indexPath) as? TitleTableViewCell else { return UITableViewCell() }
            
            if accessController == .productDetailVC || accessController == .moreProductsVC {
                cell.titleTextView.text = productData?.title
                cell.titlePlaceholderLabel.isHidden = true
                cell.categoryCollectionStackView.isHidden = false
                cell.configCategoryList(productCategory: productData?.category)
            }
    
            cell.delegate = self
            cell.categoryCollectionView.delegate = self
            cell.moveCategoryButton.addTarget(self, action: #selector(tapMoveCategoryListButton), for: .touchUpInside)
            cell.configCategoryList(productCategory: nil)
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "priceTableViewCell", for: indexPath) as? PriceTableViewCell else { return UITableViewCell() }
            
            cell.priceTextField.text = productData?.price.insertComma
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentTableViewCell", for: indexPath) as? ContentTableViewCell else { return UITableViewCell() }
            
            if accessController == .productDetailVC || accessController == .moreProductsVC {
                cell.contentTextView.text = productData?.content
                cell.placeholderLabel.isHidden = true
            }
            
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: [TableView - Delegate] ----------
extension AddProductViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: [CollectionView - Delegate] ----------
extension AddProductViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView.tag {
        case 100:
            if indexPath.section == 0 {
                if selectedImages.count == 10 {
                    let alert = UIAlertController(title: "알림", message: "이미지는 최대 10까지 첨부할 수 있어요", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "닫기", style: .cancel)
                    alert.addAction(cancel)
                    present(alert, animated: true)
                } else {
                    let totalCount = selectedImages.count

                    bsImagePicker(max: 10, totalCount: totalCount) { [weak self] assets in
                        self?.selectedImages += self?.convertAssetToImages(assetArr: assets) ?? []
                        
                        if let cell = self?.addProductTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PhotosTableViewCell {
                            
                            cell.selectedImages = self?.selectedImages ?? []
                        
                            DispatchQueue.main.async {
                                collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        case 101:
            // 카테고리 컬렉션뷰 셀
            if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell,
                let titleCell = addProductTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TitleTableViewCell,
                let contentCell = addProductTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? ContentTableViewCell {
                
                // 셀 태그 값 빼고 나머지 다 false
                
                for index in titleCell.categoryList.indices {
                    
                    if titleCell.categoryList[index].categoryName == titleCell.categoryList[cell.tag].categoryName {
                        titleCell.categoryList[index].isSelected = true
                    } else {
                        titleCell.categoryList[index].isSelected = false
                    }
                }
            
                DispatchQueue.main.async {
                    titleCell.categoryCollectionView.reloadData()
                    titleCell.categoryCollectionView.scrollToItem(at: IndexPath(row: cell.tag, section: 0), at: .centeredHorizontally, animated: true)
                    
                    contentCell.placeholderLabel.text = titleCell.categoryList[cell.tag].placeholeder

                    UIView.setAnimationsEnabled(false)
                    self.addProductTableView.beginUpdates()
                    self.addProductTableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                }
            }
        default:
            print("")
        }
    }
}

// MARK: [CollectionView - DelegateFlowLayout] ----------
extension AddProductViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        switch collectionView.tag {
        case 100:
            switch section {
            case 0:
                return UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 20)
            case 1:
                return UIEdgeInsets(top: 0, left: -10, bottom: 10, right: 20)
            default:
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView.tag {
        case 100:
            return CGSize(width: 110 - 30, height: 110 - 30)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
}

// MARK: [Delegate] ----------
extension AddProductViewController: CategoryListDelegate {
    func changeCategoryName(selectedCategory: CategoryModel) {
        if let titleCell = addProductTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TitleTableViewCell,
            let contentCell = addProductTableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? ContentTableViewCell {
            
            if !titleCell.categoryList.contains(where: {$0.categoryName == selectedCategory.categoryName }) {
                titleCell.categoryList.insert(selectedCategory, at: 0)                
            }
            
            for index in titleCell.categoryList.indices {
                
                if titleCell.categoryList[index].categoryName == selectedCategory.categoryName {
                    titleCell.categoryList[index].isSelected = true
                } else {
                    titleCell.categoryList[index].isSelected = false
                }
            }
            
            DispatchQueue.main.async {
                titleCell.categoryCollectionView.reloadData()
                let index = titleCell.categoryList.firstIndex(where: {$0.categoryName == selectedCategory.categoryName}) ?? 0
                titleCell.categoryCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
                
                contentCell.placeholderLabel.text = selectedCategory.placeholeder
//                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension AddProductViewController: TitleTableViewCellDelegate {
    func updateTextViewHeight(cell: TitleTableViewCell, textView: UITextView) {
        let size = textView.bounds.size
        let newSize = addProductTableView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            addProductTableView.beginUpdates()
            addProductTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        
        if cell.categoryCollectionStackView.isHidden {
            titleTextViewTimer?.invalidate()

            titleTextViewTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showCategoryCollectionView), userInfo: nil, repeats: false)
        }
        
        addProductTableView.scrollToRow(at: IndexPath(row: 1, section: 0), at: .bottom, animated: false)
    }
}

extension AddProductViewController: ContentTableViewCellDelegate {
    func updateTextViewHeight(cell: ContentTableViewCell, textView: UITextView) {
    
        let size = textView.bounds.size
        let newSize = addProductTableView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
    
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            addProductTableView.beginUpdates()
            addProductTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
        
        addProductTableView.scrollToRow(at: IndexPath(row: 3, section: 0), at: .bottom, animated: false)
    }
}

