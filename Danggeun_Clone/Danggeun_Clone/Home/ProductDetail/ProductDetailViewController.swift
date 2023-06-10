//
//  ProductDetailViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/01/13.
//

import UIKit

// MARK: [Protocol] ----------
protocol ProductDetailViewControllerDelegate: AnyObject {
    func fetchProductAfterDelete()
}

// MARK: [Class or Struct] ----------
class ProductDetailViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var baseScrollView: UIScrollView!
    
    @IBOutlet var productImageCollectionView: UICollectionView!
    @IBOutlet var productImageCollectionViewTop: NSLayoutConstraint!

    @IBOutlet var productImagePageControl: UIPageControl!
    
    @IBOutlet var descriptionCollectionView: DescriptionCollectionView!
    @IBOutlet var descriptionCollectionViewTop: NSLayoutConstraint!
    @IBOutlet var descriptionCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var chattingView: UIView!
    
    // MARK: [Let Or Var] ----------
    weak var delegate: ProductDetailViewControllerDelegate?
    
    var productData: ProductRegistrationModel?
    var originalProductImages = [UIImage]()
    
    var otherProducts = [ProductRegistrationModel]()
    var categoryProducts = [ProductRegistrationModel]()
    
    var userData: UserModel?
    var userProfileImage: UIImage?

    // 페이지 컨트롤러 인덱스
    var pageIndex = 0
    
    // 네비게이션바 onoff 경계값
    var navigationBarOnOffPositionY: CGFloat = 0.0
    
    var statusBarStyle: UIStatusBarStyle = .lightContent
    
    // MARK: [Override] ----------
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
    
        descriptionCollectionViewTop.constant =  self.view.frame.height / 2
        
        descriptionCollectionView.collectionViewLayout = getLayout()
        
        // 페이지 컨트롤러 초기화
        productImagePageControl.numberOfPages = productData?.productImages?.count ?? 0
        
        configData()
        
        // 네비게이션바 onoff 경계 값
        let safeAreaInsetsTop = UIApplication.shared.windows.first{$0.isKeyWindow}?.safeAreaInsets.top ?? 0.0
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.height ?? 0.0)
        navigationBarOnOffPositionY = (view.bounds.height / 2) - (safeAreaInsetsTop + navigationBarHeight) - 70
        
        chattingView.layer.cornerRadius = 5
        
        self.productImagePageControl.currentPage = 0
        self.productImagePageControl.pageIndicatorTintColor = .lightGray
        self.productImagePageControl.currentPageIndicatorTintColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if -productImageCollectionViewTop.constant < navigationBarOnOffPositionY {
            let appearance = UINavigationBarAppearance()
            
            appearance.configureWithTransparentBackground()
            appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
            
            self.navigationItem.standardAppearance = appearance
            self.navigationItem.scrollEdgeAppearance = appearance
            self.navigationController?.navigationBar.tintColor = .white
            configNavigationBarButton(color: .white)
            
            statusBarStyle = .lightContent
            setNeedsStatusBarAppearanceUpdate()
        } else if  -productImageCollectionViewTop.constant > navigationBarOnOffPositionY {
        
            statusBarStyle = .darkContent
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let appearance = UINavigationBarAppearance()
        
        appearance.backgroundColor = nil
        appearance.shadowColor = nil
        
        appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
        
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.tintColor = .black
        
        configNavigationBarButton(color: .black)
        statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.descriptionCollectionViewHeight.constant = self.descriptionCollectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    // MARK: [@IBAction] ----------
    @IBAction func tapLikeButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        
        FirebaseManager.shared.updateLike(id: productData?.productId ?? "", address: productData?.address ?? "", isLike: button.isSelected) { isLike, count in
            
            DispatchQueue.main.async {
                button.isSelected = isLike
                button.tintColor = isLike ? UIColor.orange : UIColor.systemGray
                
                if let cell = self.descriptionCollectionView.cellForItem(at: IndexPath(row: 0, section: 1)) as? ProductInfoCollectionViewCell {
                    if count != 0 {
                        cell.likeCountLabel.isHidden = false
                        cell.dotLabel.isHidden = false
                        cell.likeCountLabel.text = "관심 \(count)"
                    } else if count == 0 {
                        cell.likeCountLabel.isHidden = true
                        cell.dotLabel.isHidden = true
                    }
                }
                
                // 메인화면 상품 업데이트
                NotificationCenter.default.post(name: .reloadMainViewProducts, object: nil)
                self.delegate?.fetchProductAfterDelete()
            }
        }
    }
    
    // MARK: [Function] ----------
    func configNavigationBarButton(color: UIColor) {

        let homeButton = UIButton()
        homeButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        homeButton.setImage(UIImage(named: "home")?.withTintColor(color), for: .normal)
        homeButton.addTarget(self, action: #selector(tapHomeButton), for: .touchUpInside)
    
        let sharedButton = UIButton()
        sharedButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        sharedButton.setImage(UIImage(named: "shared")?.withTintColor(color), for: .normal)

        let moreButton = UIButton()
        moreButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        moreButton.setImage(UIImage(named: "more")?.withTintColor(color), for: .normal)
        moreButton.addTarget(self, action: #selector(tapMoreMenuButton(_:)), for: .touchUpInside)

        let homeBarButton = UIBarButtonItem(customView: homeButton)
        let sharedBarButton = UIBarButtonItem(customView: sharedButton)
        let moreBarButton = UIBarButtonItem(customView: moreButton)

        self.navigationItem.leftBarButtonItem = homeBarButton
        self.navigationItem.rightBarButtonItems = [moreBarButton, sharedBarButton]
    }
    
    func configData() {
        
        let group = DispatchGroup()
        
        indicatorView.isHidden = false
        indicatorView.startAnimating()
       
        // 상품 이미지 다운로드
        group.enter()
        FirebaseManager.shared.downloadProductImages(urls: self.productData?.imagesURL ?? []) { result in
            switch result {
            case .success(let images):
                self.originalProductImages = images
                self.productImagesResize(images: images)
                
                self.productImagePageControl.numberOfPages = images.count
                self.productImagePageControl.isHidden = images.count > 1 ? false : true
            
                group.leave()
            case .failure(let error):
                print(error)
                group.leave()
            }
        }
        
        // 작성자 데이터 가져오기
        group.enter()
        FirebaseManager.shared.fetchUserData(phoneNumber: self.productData?.phoneNumber ?? "") { result in
            switch result {
            case .success(let userData):
                self.userData = userData
                
                group.enter()
                FirebaseManager.shared.downloadThumbnailImage(url: userData.profileImageUrl ?? "") { result in
                    switch result {
                    case .success(let image):
                        self.userProfileImage = image.resizeThumbnailTo()
                        group.leave()
                    case .failure(let error):
                        print(error)
                        group.leave()
                    }
                }
                
                // 다른 상품
                group.enter()
                FirebaseManager.shared.fetch4OtherProducts(phoneNumber: userData.phoneNumber ?? "", address: self.productData?.address ?? "") { result in
                    switch result {
                    case .success(let products):
                        
                        self.otherProducts = products
                        
                        for (index, product) in self.otherProducts.enumerated() {
                            group.enter()
                            FirebaseManager.shared.downloadThumbnailImage(url: product.imagesURL.first ?? "") { result in
                                switch result {
                                case .success(let image):
                                    self.otherProducts[index].ThumbnailImage = image
                                    group.leave()
                                case .failure(let error):
                                    print(error)
                                    group.leave()
                                }
                            }
                        }
                        group.leave()
                    case .failure(let error):
                        print(error)
                    }
                }
                
                // 같은 카테고리 상품
                group.enter()
                FirebaseManager.shared.fetchCategoryPtoducts(address: self.userData?.selectedAddress ?? "", category: self.productData?.category ?? "") { result in
                    switch result {
                    case .success(let products):
                        self.categoryProducts = products
                        
                        for (index, product) in self.categoryProducts.enumerated() {
                            group.enter()
                            FirebaseManager.shared.downloadThumbnailImage(url: product.imagesURL.first ?? "") { result in
                                switch result {
                                case .success(let image):
                                    self.categoryProducts[index].ThumbnailImage = image
                                    group.leave()
                                case .failure(let error):
                                    print(error)
                                    group.leave()
                                }
                            }
                        }
                        group.leave()
                    case .failure(let error):
                        print(error)
                        group.leave()
                    }
                }
                
                group.leave()
            case .failure(let error):
                print(error)
                group.leave()
            }
        }
        
        // 관심 상태 체크
        group.enter()
        FirebaseManager.shared.fetchIsLike(id: productData?.productId ?? "", address: productData?.address ?? "") { isLike in
            self.productData?.isLike = isLike
            group.leave()
        }
        
        // 관심 카운트
        group.enter()
        FirebaseManager.shared.fetchLikeCount(id: productData?.productId ?? "", address: productData?.address ?? "") { count in
            self.productData?.likeCount = count
            group.leave()
        }
        
        group.enter()
        FirebaseManager.shared.checkViewProduct(id: productData?.productId ?? "", address: productData?.address ?? "") { isView in

            if !isView {
                FirebaseManager.shared.updateViewCount(id: self.productData?.productId ?? "", address: self.productData?.address ?? "") {
                    FirebaseManager.shared.fetchViewCount(id: self.productData?.productId ?? "", address: self.productData?.address ?? "") { count in
                        self.productData?.viewCount = count
                        group.leave()
                    }
                }
            } else {
                FirebaseManager.shared.fetchViewCount(id: self.productData?.productId ?? "", address: self.productData?.address ?? "") { count in
                    self.productData?.viewCount = count
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if self.productData?.isLike == true {
                self.likeButton.isSelected = true
                self.likeButton.tintColor = .orange
            } else {
                self.likeButton.isSelected = false
                self.likeButton.tintColor = .systemGray
            }
            
            self.priceLabel.text = "\(self.productData?.price.insertComma ?? "")원"
            
            self.productImageCollectionView.reloadData()
            self.descriptionCollectionView.reloadData()
            
            self.indicatorView.isHidden = true
            self.indicatorView.stopAnimating()
        }
    }
    
    func productImagesResize(images: [UIImage]) {
        
        if productData?.productImages == nil {
            productData?.productImages = [UIImage]()
        }
        
        guard !images.isEmpty else { return }
        
        images.forEach { image in
            if image.size.height > view.frame.height / 2 {
                let resultImage = image.resizeImage(newHeight: floor(view.frame.height * 0.6))
                productData?.productImages?.append(resultImage)
                
            } else if image.size.height < view.frame.height / 2 {
                let resultImage = image.resizeImage(newHeight: view.frame.height / 2)
                productData?.productImages?.append(resultImage)
            }
        }
    }
  
    // MARK: [@objc Function] ----------
    @objc func tapHomeButton() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func tapCategoryButton() {
        let storyboard = UIStoryboard(name: "MoreCategory", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MoreCategoryVC") as? MoreCategoryViewController else { return }
        vc.category = productData?.category
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapSellerOtherProductButton() {
        let storyboard = UIStoryboard(name: "MoreSellerOtherProducts", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MoreSellerOtherProductsVC") as? MoreSellerOtherProductsViewController else { return }
        
        vc.userData = userData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func tapMoreMenuButton(_ sender: Any) {
        let loginUserData = UserModel.getUserData()
        
        if loginUserData?.phoneNumber ?? "" == productData?.phoneNumber {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let edit = UIAlertAction(title: "게시글 수정", style: .default) { _ in
                let storyboard = UIStoryboard(name: "AddProduct", bundle: nil)
                
                guard let vc = storyboard.instantiateViewController(withIdentifier: "addProductVC") as? AddProductViewController else { return }
                
                if let rootVC = self.navigationController?.viewControllers.first as? HomeViewController {
                    vc.addProductDelegate = self
                    vc.homeDelegate = rootVC
                    vc.accessController = .productDetailVC
                    vc.productData = self.productData
                    
                    let navigationVC = UINavigationController(rootViewController: vc)
                    navigationVC.modalPresentationStyle = .fullScreen
                    self.present(navigationVC, animated: true)
                    
                } else if let _ = self.navigationController?.viewControllers.first as? BaseProfileMenuViewController {
                    
                    vc.addProductDelegate = self
                    vc.accessController = .moreProductsVC
                    vc.productData = self.productData
                    
                    let navigationVC = UINavigationController(rootViewController: vc)
                    navigationVC.modalPresentationStyle = .fullScreen
                    self.present(navigationVC, animated: true)
                }
            }
            
            let delete = UIAlertAction(title: "삭제", style: .destructive) { _ in
                            
                FirebaseManager.shared.deleteProduct(id: self.productData?.productId ?? "", phoneNumber: self.productData?.phoneNumber ?? "", address: self.productData?.address ?? "", status: self.productData?.status ?? "") { result in
                    switch result {
                    case .success(_):
                        self.delegate?.fetchProductAfterDelete()
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            
            let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
                
            }
            
            alert.addAction(edit)
            alert.addAction(delete)
            alert.addAction(cancel)
            
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let a = UIAlertAction(title: "신고", style: .default) { _ in
                
            }
            
            let b = UIAlertAction(title: "이 사용자의 글 보지 않기", style: .default) { _ in
                
            }
            
            let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
                
            }
            
            alert.addAction(a)
            alert.addAction(b)
            alert.addAction(cancel)
            present(alert, animated: true)
        }
    }
}

// MARK: [CollectionView - DelegateFlowLayout] ----------
extension ProductDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 상품 이미지 보여줄 컬렉션뷰 셀 크기를 화면에 꽉차도록
        if collectionView.tag == 101 {
            return CGSize(width: view.frame.width, height: collectionView.frame.height)
        }
        
        return CGSize(width: 0, height: 0)
    }
}

// MARK: [CollectionView - DataSource] ----------
extension ProductDetailViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView.tag {
        case 101:
            return 1
        case 102:
            return 5
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 101:
            return productData?.productImages?.count ?? 0
        case 102:
            switch section {
            case 0:
                return 1
            case 1:
                return 1
            case 2:
                return 1
            case 3:
                return otherProducts.count
            case 4:
                return categoryProducts.count
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 101:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productsImageCell", for: indexPath) as? ProductsImageCollectionViewCell else { return UICollectionViewCell() }
            cell.productImageView.image = productData?.productImages?[indexPath.row]
            return cell
        case 102:
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sellerInfoCell", for: indexPath) as? SellerInfoCollectionViewCell else { return UICollectionViewCell() }
                
                cell.nickNameLabel.text = userData?.nickname
                cell.addressLabel.text = productData?.address?.components(separatedBy: " ").last ?? ""
                cell.profileImageView.image = userProfileImage
                return cell
            case 1:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productInfoCell", for: indexPath) as? ProductInfoCollectionViewCell else { return UICollectionViewCell() }
                cell.titleLabel.text = productData?.title
                cell.categoryButton.setTitle(productData?.category, for: .normal)
                cell.categoryButton.addTarget(self, action: #selector(tapCategoryButton), for: .touchUpInside)
                cell.timeLabel.text = "\(productData?.update.convertTimestamp() ?? "") 전"
                cell.contentLabel.text = productData?.content
                
                if productData?.likeCount == nil || productData?.likeCount == 0 {
                    cell.likeCountLabel.isHidden = true
                    cell.dotLabel.isHidden = true
                }
                
                cell.likeCountLabel.text = "관심 \(productData?.likeCount ?? 0)"
                cell.viewsCountLabel.text = "조회수 \(productData?.viewCount ?? 0)"
                
                return cell
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reportCell", for: indexPath)
                return cell
            case 3:
                if otherProducts.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherProductCell", for: indexPath)
                    cell.backgroundColor = .red
                    return cell
                } else {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherProductCell", for: indexPath) as? OtherProductCollectionViewCell else { return UICollectionViewCell() }
                    cell.titleLabel.text = otherProducts[indexPath.row].title
                    cell.priceLabel.text = "\(otherProducts[indexPath.row].price.insertComma)원"
                    
                    cell.productImageView.image = otherProducts[indexPath.row].ThumbnailImage
                    
                    return cell
                }
                
               
            case 4:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "otherProductCell", for: indexPath) as? OtherProductCollectionViewCell else { return UICollectionViewCell() }
                cell.titleLabel.text = categoryProducts[indexPath.row].title
                cell.priceLabel.text = "\(categoryProducts[indexPath.row].price.insertComma)원"
                
                cell.productImageView.image = categoryProducts[indexPath.row].ThumbnailImage
                return cell
            default:
                return UICollectionViewCell()
            }
        default:
            return UICollectionViewCell()
            
        }
    }
}

// MARK: [CollectionView - Delegate] ----------
extension ProductDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath) as? DescriptionHeaderCollectionReusableView else { return UICollectionReusableView() }
            
            switch indexPath.section {
            case 3:
                header.titleLabel.text = "\(userData?.nickname ?? "")님의 판매 상품"
                header.headerButton.isHidden = false
                header.chevronImageView.isHidden = false
                header.headerButton.addTarget(self, action: #selector(tapSellerOtherProductButton), for: .touchUpInside)
                return header
            case 4:
                header.titleLabel.text = "이 글과 함께 봤어요"
                header.headerButton.isHidden = true
                header.chevronImageView.isHidden = true
                return header
            default:
                return header
            }
            
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        switch collectionView.tag {
        case 101:
            let storyboard = UIStoryboard(name: "ZoomProductImages", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "ZoomProductImagesVC") as? ZoomProductImagesViewController else { return }
            vc.productHeights = (self.productData?.productImages ?? []).map({$0.size.height})
            vc.productImages = self.originalProductImages
            vc.imageIndex = indexPath.row
            self.present(vc, animated: false)
        case 102:
            let detailStoryboard = UIStoryboard(name: "ProductDetail", bundle: nil)
            let profileStoryboard = UIStoryboard(name: "Profile", bundle: nil)
            
            guard let detailVC = detailStoryboard.instantiateViewController(withIdentifier: "ProductDetailVC") as? ProductDetailViewController else { return }
            guard let profileVC = profileStoryboard.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController else { return }
            
            switch indexPath.section {
            case 0:
                profileVC.userData = self.userData
                profileVC.profileImage = userProfileImage
                
                self.navigationController?.pushViewController(profileVC, animated: true)
            case 3:
                detailVC.productData = otherProducts[indexPath.row]
                self.navigationController?.pushViewController(detailVC, animated: true)
            case 4:
                detailVC.productData = categoryProducts[indexPath.row]
                self.navigationController?.pushViewController(detailVC, animated: true)
            default:
                return
            }
            
            
        default:
            return
        }
    }
}

// MARK: [ScrollView - Delegate] ----------
extension ProductDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        switch scrollView.tag {
        case 100:
            if scrollView.contentOffset.y >= 0 {
                productImageCollectionViewTop.constant = -scrollView.contentOffset.y
                productImagePageControl.isHidden = scrollView.contentOffset.y == 0 && productData?.productImages?.count ?? 0 > 1 ? false : true
            } else {
                productImageCollectionViewTop.constant = 0
                productImagePageControl.isHidden = true
                
                let bottomCollectionViewPositionY = (view.frame.height / 2) + -scrollView.contentOffset.y
                
                if let cell = productImageCollectionView.cellForItem(at: IndexPath(row: pageIndex, section: 0)) as? ProductsImageCollectionViewCell {

                    let imageHeight = cell.productImageView.image?.size.height ?? 0
                    
                    if bottomCollectionViewPositionY > imageHeight {
                        // 컬렉션뷰 높이 - scrollViewContentOffsetY * 2
                        // (컬렉션뷰 높이 - scrollViewContentOffsetY * 2) / 2 하면 scale 구해짐
                        // 구한 scale에서 -1을 해야 1배율값이 나오고 부호 -이므로 +로 반전
                        let scale = -(1 - (view.frame.height - (scrollView.contentOffset.y * 2)) / imageHeight)
                        cell.productImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                        
                    } else {
                        cell.productImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }
                }
            }
            
            // 네비게이션 경계값에 따라 네비게이션바 배경 OnOff
            if scrollView.contentOffset.y > navigationBarOnOffPositionY {
                let appearance = UINavigationBarAppearance()
                
                appearance.backgroundColor = .white
                appearance.shadowColor = nil
                
                appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
                
                self.navigationItem.standardAppearance = appearance
                self.navigationController?.navigationBar.tintColor = .black
                
                configNavigationBarButton(color: .black)
                
                statusBarStyle = .darkContent
                setNeedsStatusBarAppearanceUpdate()
                
            } else if scrollView.contentOffset.y < navigationBarOnOffPositionY {
                let appearance = UINavigationBarAppearance()
                
                appearance.configureWithTransparentBackground()
                
                appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
                
                self.navigationItem.standardAppearance = appearance
                self.navigationItem.scrollEdgeAppearance = appearance
                self.navigationController?.navigationBar.tintColor = .white
                
                configNavigationBarButton(color: .white)
                
                statusBarStyle = .lightContent
                setNeedsStatusBarAppearanceUpdate()
            }
            
        case 101:
            pageIndex = Int(scrollView.contentOffset.x / view.frame.width)
            productImagePageControl.currentPage = pageIndex
        default:
            print("")
        }
    }
}

// MARK: [extension - CollectionViewLayout] ----------
extension ProductDetailViewController {
    func getLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, env -> NSCollectionLayoutSection? in
            
            switch section {
            case 0:
                return self.singleItemSection()
            case 1:
                return self.singleItemSection()
            case 2:
                return self.singleItemSection()
            case 3:
                return self.otherProducts.isEmpty ? nil : self.productItemsSection()
            case 4:
                return self.categoryProducts.isEmpty ? nil : self.productItemsSection()
            default:
                return nil
            }
        }
    }
    
    func singleItemSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    func productItemsSection() -> NSCollectionLayoutSection {

        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitem: item, count: 2)
        
        // item사이 여백
        group.interItemSpacing = .fixed(15)
    
        let section = NSCollectionLayoutSection(group: group)
        
        // group 위아래 사이 여백
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15)
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        return section
    }
}

// MARK: [Extention Delegate] ----------
extension ProductDetailViewController: AddProductViewControllerDelegate {
    func fetchDetailProductData(productData: [String: Any], images: [UIImage]) {
        
        self.productData?.title = productData["title"] as! String
        self.productData?.content = productData["contents"] as! String
        self.productData?.price = productData["price"] as! String
        
        self.priceLabel.text = "\(self.productData?.price.insertComma ?? "")원"
        
        self.productData?.category = productData["category"] as! String
        self.productData?.productImages?.removeAll()
        productImagesResize(images: images)
        self.productImagePageControl.numberOfPages = images.count
        
        DispatchQueue.main.async {
            self.productImageCollectionView.reloadData()
            self.descriptionCollectionView.reloadData()
        }
    }

    func fetchAddProduct() { }
}
