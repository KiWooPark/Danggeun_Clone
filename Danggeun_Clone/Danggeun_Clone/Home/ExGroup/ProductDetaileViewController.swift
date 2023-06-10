//
//  ProductDetaile2ViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/06/16.
//

import UIKit
import Kingfisher
import FirebaseFirestore
import FirebaseStorage
import SnapKit

class ProductDetaileViewController: UIViewController {

    @IBOutlet var productImageCollectionView: UICollectionView!
    @IBOutlet var productImageCollectionViewTop: NSLayoutConstraint!

    @IBOutlet var imagePageController: UIPageControl!
    
    @IBOutlet var descriptionCollectionView: UICollectionView!
    @IBOutlet var descriptionCollectionViewTop: NSLayoutConstraint!
    @IBOutlet var descriptionCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var startChatButton: UIButton!
    
    var statusBarStyle: UIStatusBarStyle = .lightContent

    // 상품 데이터
    var productData: ProductRegistrationModel?
    // 작성자 데이터
    var writerData: UserModel?
    
    // 페이지 컨트롤러 인덱스
    var pageIndex = 0
   
    // 네비게이션바 onoff 경계값
    var navigationBarOnOffPositionY: CGFloat = 0.0
    
    // 상태바 스타일 변경
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // 페이지 컨트롤러 초기화
        imagePageController.numberOfPages = productData?.imagesURL.count ?? 0
        imagePageController.isHidden = productData?.imagesURL.count ?? 0 == 1 ? true : false
        
        // 상품 정보 컬렉션뷰 CompositionalLayout 적용
        descriptionCollectionView.collectionViewLayout = getLayout()
            
        // 데이터 세팅
        configData()
        
        // 네비게이션바 onoff 경계 값
        let safeAreaInsetsTop = UIApplication.shared.windows.first{$0.isKeyWindow}?.safeAreaInsets.top ?? 0.0
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.height ?? 0.0)
        navigationBarOnOffPositionY = (view.bounds.height / 2) - (safeAreaInsetsTop + navigationBarHeight) - 70
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
    
    override func viewWillLayoutSubviews() {
        descriptionCollectionViewTop.constant = productImageCollectionView.frame.height / 2
        
        if descriptionCollectionView.contentSize.height != 0 {
            descriptionCollectionViewHeight.constant = descriptionCollectionView.collectionViewLayout.collectionViewContentSize.height
        }
    }
    
    func configData() {
        FirebaseManager.shared.getUserData(userPhoneNumber: productData?.phoneNumber ?? "") { userData in
            self.writerData = userData
            
            
            
            
            
            
            
            
            
//            print(userData)
//            // gs://parkkiwoo-7ed0e.appspot.com/ProductImage/01043291857/RqcifgJyy5ZE1bT0q0R3/ProductImage0
//            let fileName = userData?.products?.first?.components(separatedBy: "/").first ?? ""
//
//            let url = "gs://parkkiwoo-7ed0e.appspot.com/ProductImage/\(userData?.phoneNumber ?? "")/\(fileName)/ProductImage0"
//
//            print(url)
//
//            Storage.storage().reference(forURL: "gs://parkkiwoo-7ed0e.appspot.com/ProductImage/\(userData?.phoneNumber ?? "")/RqcifgJyy5ZE1bT0q0R3/ProductImage0").downloadURL { url, error in
//                print(url)
//            }
            
            //let address = userData?.products?.first?.components(separatedBy: "/").last?.components(separatedBy: " ") ?? []

//            Firestore.firestore().collection("게시글").document("행정구역").collection(address[0]).document(address[1]).collection("행정동").document(address[2]).collection("상품").document(userData?.products?.first?.components(separatedBy: "/").first ?? "").getDocument { snapShot , error in
//                if let error = error {
//                    print("123123")
//                }
//
//                print(snapShot?.data())
//            }
           
            
            
            DispatchQueue.main.async {
                self.descriptionCollectionView.reloadData()
            }
        }
        
        priceLabel.text = "\(productData?.price ?? "")원"
    }
    
    
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
                return self.productsItemSection()
            case 4:
                return self.productsItemSection()
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
    
    func productsItemSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        // item사이 여백
        group.interItemSpacing = .fixed(15)
    
        let section = NSCollectionLayoutSection(group: group)
        
        // group 위아래 사이 여백
        section.interGroupSpacing = 30
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 30, trailing: 15)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    func configNavigationBarButton(color: UIColor) {
        let homeButton = UIButton()
        homeButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        homeButton.setImage(UIImage(named: "home")?.withTintColor(color), for: .normal)
        
        let sharedButton = UIButton()
        sharedButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        sharedButton.setImage(UIImage(named: "shared")?.withTintColor(color), for: .normal)

        let moreButton = UIButton()
        moreButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        moreButton.setImage(UIImage(named: "more")?.withTintColor(color), for: .normal)
        
        let homeBarButton = UIBarButtonItem(customView: homeButton)
        let sharedBarButton = UIBarButtonItem(customView: sharedButton)
        let moreBarButton = UIBarButtonItem(customView: moreButton)
        
        self.navigationItem.leftBarButtonItem = homeBarButton
        self.navigationItem.rightBarButtonItems = [moreBarButton,sharedBarButton]
    }
    
    @IBAction func likeButton(_ sender: Any) {
        
    }
    
    
    @IBAction func tapStartChatButton(_ sender: Any) {
        
    }
}

extension ProductDetaileViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 101 {
            if let cell = collectionView.cellForItem(at: indexPath) as? ProductDetailCollectionViewCell {
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "zoomVC") as? ZoomImageViewController else { return }
                vc.photoUrls = self.productData?.imagesURL ?? []
                vc.photoIndex = pageIndex
                self.present(vc, animated: false)
            }
        } else if collectionView.tag == 102 {
            switch indexPath.section {
            case 0:
                let storyBoard = UIStoryboard(name: "MyInfo", bundle: nil)
                guard let vc = storyBoard.instantiateViewController(withIdentifier: "MyInfo") as? MyInfoTableViewController else { return }
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                print("게시글 정보")
            case 2:
                print("신고하기")
            case 3,4:
                if let cell = collectionView.cellForItem(at: indexPath) as? OtherProductsCollectionViewCell {
                    print(cell.tag)
                }
            default:
                print("default")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath) as? DetailHeaderCollectionReusableView else { return UICollectionReusableView() }
            
            if indexPath.section == 3 {
                header.headerTitleLabel.text = "가나다라님의 판매 상품"
                header.underLineView.isHidden = true
                return header
            } else if indexPath.section == 4 {
                header.headerTitleLabel.text = "로그인유저님, 이건 어때요?"
                header.headerButton.isHidden = true
                header.underLineView.isHidden = false
                return header
            }
            
            return header
        default :
            return UICollectionReusableView()
        }
    }
}

extension ProductDetaileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == 101 {
            return 1
        } else if collectionView.tag == 102 {
            return 5
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 101{
            return productData?.imagesURL.count ?? 0
        } else if collectionView.tag == 102 {
            if section == 0 {
                return 1
            } else if section == 1 {
                return 1
            } else if section == 2 {
                return 1
            } else if section == 3 {
                return 3
            } else if section == 4 {
                return 4
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 101 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ProductDetailCollectionViewCell else { return UICollectionViewCell() }
            
            cell.tag = indexPath.row
    
            FirebaseManager.shared.downloadImage(url: productData?.imagesURL[indexPath.row] ?? "") { result in
                DispatchQueue.main.async {
                    if let updateCell = collectionView.cellForItem(at: indexPath) as? ProductDetailCollectionViewCell {
                        var image = result

                        if image?.size.height ?? 0 > collectionView.frame.height / 2 {
                            image = image?.resizeImage(newHeight: floor(collectionView.frame.height * 0.6))
                        } else if image?.size.height ?? 0 < collectionView.frame.height / 2 {
                            image = image?.resizeImage(newHeight: collectionView.frame.height / 2)
                        }

                        updateCell.ProductImageView.image = image
                    }
                }
            }
            return cell
            
        } else if collectionView.tag == 102 {
            if indexPath.section == 0 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as? WriterInfoCollectionViewCell else { return UICollectionViewCell() }
                
                cell.nicknameLabel.text = writerData?.nickname
                cell.addressLabel.text = productData?.address?.components(separatedBy: " ").last ?? ""
                // 매너온도 데이터 추가
                
                FirebaseManager.shared.downloadImage(url: writerData?.profileImageUrl ?? "") { result in
                    DispatchQueue.main.async {

                        cell.profileImageView.image = result?.resizeImage(newHeight: 50)
                        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.height / 2
                    }
                }
                return cell
            } else if indexPath.section == 1 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as? DescriptionCollectionViewCell else { return UICollectionViewCell() }
                
                cell.titleLabel.text = productData?.title
                cell.categoryButton.setTitle(productData?.category, for: .normal)
                cell.timeLabel.text = " • \(productData?.update.convertTimestamp() ?? "") 전"
                cell.descriptionLabel.text = productData?.content
                
                // 업데이트 필요
                cell.countLabel.text = "채팅 1 • 관심 12 • 조회 123"
                
                return cell
            } else if indexPath.section == 2 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell3", for: indexPath) as? ReportCollectionViewCell else { return UICollectionViewCell() }
                
                
                return cell
            } else if indexPath.section == 3 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell4", for: indexPath) as? OtherProductsCollectionViewCell else { return UICollectionViewCell() }
                cell.tag = indexPath.row
                cell.productImageView.image = UIImage(named: "아이패드에어1-6")
                //cell.titleLabel.text = "아이패드"
                //cell.priceLabel.text = "90,000원"
                cell.backgroundColor = .white
                
                return cell
            } else if indexPath.section == 4 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell4", for: indexPath) as? OtherProductsCollectionViewCell else { return UICollectionViewCell() }
                cell.tag = indexPath.row
                cell.productImageView.image = UIImage(named: "아이패드에어1-6")
                //cell.titleLabel.text = "아이패드123"
                //cell.priceLabel.text = "100,000원"
                cell.backgroundColor = .white
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
}

extension ProductDetaileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 101 {
            return CGSize(width: view.frame.width, height: collectionView.frame.height)
        }
        return CGSize(width: 0, height: 0)
    }
}
 
extension ProductDetaileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        if scrollView.tag == 100 {
            if scrollView.contentOffset.y >= 0 {
                productImageCollectionViewTop.constant = -scrollView.contentOffset.y
                imagePageController.isHidden = scrollView.contentOffset.y == 0 && productData?.imagesURL.count ?? 0 > 1 ? false : true
            } else {
                productImageCollectionViewTop.constant = 0
                imagePageController.isHidden = true
                
                // 이미지 Bottom 경계 위치
                let boundaryPositionY = (productImageCollectionView.frame.height / 2) + -scrollView.contentOffset.y
                
                if let cell = productImageCollectionView.cellForItem(at: IndexPath(row: pageIndex, section: 0)) as? ProductDetailCollectionViewCell {

                    let imageHeight = cell.ProductImageView.image?.size.height ?? 0
                    
                    if boundaryPositionY > imageHeight {
                        // 컬렉션뷰 높이 - scrollViewContentOffsetY * 2
                        // (컬렉션뷰 높이 - scrollViewContentOffsetY * 2) / 2 하면 scale 구해짐
                        // 구한 scale에서 -1을 해야 1배율값이 나오고 부호 -이므로 +로 반전
                        let scale = -(1 - (productImageCollectionView.frame.height - (scrollView.contentOffset.y * 2)) / imageHeight)
                        cell.ProductImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                    } else {
                        cell.ProductImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
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

        } else if scrollView.tag == 101 {
            // 페이지 컨트롤러
            pageIndex = Int(scrollView.contentOffset.x / view.frame.width)
            imagePageController.currentPage = pageIndex
        }
    }
}





















//class ProductDetaileViewController: UIViewController {
//
//    let productDetailView: ProductDetailView = {
//        let view = ProductDetailView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    var viewState = ViewState.notFinish
//
//    let db = Firestore.firestore()
//
//    // 게시물 정보
//    var product: ProductRegistrationModel?
//    var imageHeights = [CGFloat]()
//    var images = [UIImage]()
//
//    var isLike = false
//
//    // 게시물 유저 정보
//    var productUserInfo: UserModel?
//
//    // 로그인 유저 정보
//    let loginUser = UserModel.getUserData()
//
//    var otherProducts = [ProductRegistrationModel]()
//    var categoryProducts = [ProductRegistrationModel]()
//
//    var height: CGFloat = 0.0
//    var statusBarHeight: CGFloat = 0.0
//    var navigationBarHeight: CGFloat = 0.0
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if product?.phoneNumber == loginUser?.phoneNumber ?? "" {
//            productDetailView.startChatButton.isEnabled = false
//            productDetailView.startChatButton.backgroundColor = .systemGray4
//        }
//
//        height = UIScreen.main.bounds.height * 0.5
//        statusBarHeight = UIApplication.shared.statusBarFrame.height
//        navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
//
//
//        self.navigationController?.hidesBarsOnSwipe = false
//
//        self.view.addSubview(productDetailView)
//        productDetailView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//        productDetailView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
//        productDetailView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        productDetailView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//
//
//        productDetailView.mainScrollView.delegate = self
//        productDetailView.productImagesScrollView.delegate = self
//
//        productDetailView.otherProductsCollectionView.register(OtherProductCollectionViewCell.self, forCellWithReuseIdentifier: OtherProductCollectionViewCell.identifier)
//        productDetailView.recommendationCollectionView.register(OtherProductCollectionViewCell.self, forCellWithReuseIdentifier: OtherProductCollectionViewCell.identifier)
//
//        productDetailView.otherProductsCollectionView.delegate = self
//        productDetailView.otherProductsCollectionView.dataSource = self
//
//        productDetailView.recommendationCollectionView.delegate = self
//        productDetailView.recommendationCollectionView.dataSource = self
//
//
//        productDetailView.profileButton.addTarget(self, action: #selector(tapProfileViewButton), for: .touchUpInside)
//        productDetailView.categoryButton.addTarget(self, action: #selector(tapCategoryButton), for: .touchUpInside)
//        productDetailView.reportButton.addTarget(self, action: #selector(tapReportButton), for: .touchUpInside)
//        productDetailView.viewMoreButton.addTarget(self, action: #selector(tapViewMoreButton), for: .touchUpInside)
//        productDetailView.startChatButton.addTarget(self, action: #selector(tapStartChatButton), for: .touchUpInside)
//        productDetailView.heartButton.addTarget(self, action: #selector(tapHeartButton), for: .touchUpInside)
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToZoom))
//        tap.numberOfTapsRequired = 1
//        productDetailView.productImagesScrollView.addGestureRecognizer(tap)
//
//        configureProductUserData()
//
//        if let photos = product?.photos {
//            if photos.isEmpty {
//                self.productDetailView.productImagesScrollView.isHidden = true
//                self.productDetailView.stackViewInMainScrollView.snp.updateConstraints { make in
//                    make.leading.trailing.top.bottom.equalToSuperview()
//                }
//            } else {
//                var count = 0
//                for photo in photos {
//                    FirebaseManager.shared.downloadImagesTest(url: photo) { image in
//                        self.images.append(image ?? UIImage())
//                        count += 1
//
//                        if count == photos.count {
//                            self.productDetailView.productImagesScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(self.images.count), height: 0)
//                            self.configureProductImages(images: self.images)
//                            self.viewState = .finish
//                            self.productDetailView.pageControl.numberOfPages = self.images.count
//
//                            self.productDetailView.stackViewInMainScrollView.snp.updateConstraints { make in
//                                make.top.equalTo(self.height - self.statusBarHeight - self.navigationBarHeight)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//        downloadOtherProductImages {
//            if self.otherProducts.isEmpty {
//                self.productDetailView.otherProductsView.isHidden = true
//            } else {
//                self.productDetailView.otherProductsCollectionView.reloadData()
//            }
//        }
//
//        downloadCategoryImages {
//            self.productDetailView.recommendationCollectionView.reloadData()
//        }
//
//        // 좋아요 체크 및 카운트
//
//
////        // 좋아요 체크, 카운트
////        // 경로 수정 필요
////        db.collection("게시글").document(product?.productId ?? "").collection("관심").getDocuments { snapShot, error in
////            if let error = error {
////                print("관심상품 등록 유저 정보 가져오기 실패", error)
////            }
////
////            guard let documents = snapShot?.documents else { return }
////
////            self.db.collection("게시글").document(self.product?.productId ?? "").getDocument { snapShot, error in
////                if let error = error {
////                    print("좋아요 카운트 가져오기 실패", error)
////                }
////
////                guard let likesCount = snapShot?.data()?["likesCount"] as? Int else { return }
////
////                if documents.filter({$0.documentID == UserModel.getUserData()?.phoneNumber ?? ""}) != [] {
////                    DispatchQueue.main.async {
////                        self.productDetailView.heartButton.setImage(UIImage(named: "like_selected"), for: .normal)
////                        self.isLike = true
////                        self.productDetailView.interestCountLabel.text = "관심 \(likesCount)"
////                    }
////                }
////            }
////        }
////
////        // 채팅 카운트
////        // 경로 수정 필요
////        db.collection("게시글").document(product?.productId ?? "").getDocument { snapShot, error in
////            if let error = error {
////                print("채팅 카운트 가져오기 실패", error)
////            }
////
////            guard let chattingCount = snapShot?.data()?["chattingCount"] as? Int else { return }
////
////            DispatchQueue.main.async {
////                self.productDetailView.chattingCountLabel.text = "채팅 \(chattingCount)"
////            }
////        }
////
////        // 조회수 카운트
////        // 경로 수정 필요
////        db.collection("게시글").document(product?.productId ?? "").collection("조회").document(UserModel.getUserData()?.phoneNumber ?? "").setData([:]) { error in
////            if let error = error {
////                print("조회수 업데이트 실패", error)
////            }
////
////            self.db.collection("게시글").document(self.product?.productId ?? "").collection("조회").getDocuments { snapShot, error in
////                if let error = error {
////                    print("조회수 정보 불러오기 실패", error)
////                }
////                guard let documents = snapShot?.documents else { return }
////
////                DispatchQueue.main.async {
////                    self.productDetailView.countLabel.text = "조회수 \(documents.count)"
////                }
////            }
////        }
//    }
//
//    override func viewWillLayoutSubviews() {
//
//        productDetailView.otherProductsCollectionView.snp.updateConstraints { make in
//            make.height.equalTo(productDetailView.otherProductsCollectionView.contentSize.height)
//        }
//
//        productDetailView.recommendationCollectionView.snp.updateConstraints { make in
//            make.height.equalTo(productDetailView.recommendationCollectionView.contentSize.height)
//        }
//
//        productDetailView.profileImageView.layer.cornerRadius = productDetailView.profileImageView.frame.width * 0.5
//    }
//
//    // 리팩토링
//    func configureProductUserData() {
//        // 게시물 등록 유저 정보 가져오기
//
//        db.collection("유저정보").whereField("phoneNumber", isEqualTo: product?.phoneNumber ?? "").getDocuments { snapShot, error in
//            if let error = error {
//                print("유저정보 가져오기 실패 = \(error)")
//            }
//
//            guard let userData = snapShot?.documents.first?.data() else { return }
//
//            let target = UserModel(data: userData)
//
//            FirebaseManager.shared.downloadImagesTest(url: target.profileImageUrl ?? "") { image in
//                DispatchQueue.main.async {
//                    self.productDetailView.profileImageView.image = image?.resizeThumbnailTo()
//                }
//            }
//
//            self.productDetailView.nickNameLabel.text = target.nickName ?? ""
//            self.productDetailView.regionLabel.text = target.selectedAddress
//            self.productDetailView.otherProductsTitleLabel.text = "\(target.nickName ?? "")님의 판매 상품"
//
//            self.productUserInfo = target
//        }
//
//        // 게시글 정보
//        productDetailView.productTitleLabel.text = product?.title
//        productDetailView.categoryButton.setTitle(product?.category, for: .normal)
//        productDetailView.timeLabel.text = "\(product?.update.convertTimestamp() ?? "") 전"
//        productDetailView.contentTextLabel.text = product?.content
//
//        // 로그인 유저에게 상품 추천 정보
//        productDetailView.recommendationTitle.text = "\(loginUser?.nickName ?? "")님 이건 어때요?"
//    }
//
//    // 리팩토링
//    func downloadOtherProductImages(completion: @escaping () -> ()) {
//        db.collection("게시글").whereField("phoneNumber", isEqualTo: product?.phoneNumber).getDocuments { snapShot, error in
//            if let error = error {
//                print("판매자 다른 상품 검색 실패 = \(error)")
//            }
//
//            guard let documents = snapShot?.documents else { return }
//
//            self.otherProducts.removeAll()
//
//            for productData in documents {
//                // 현재 상품 외에 다른 상품 검색
//                let productTitle = productData.data()["title"] as? String ?? ""
//                if self.product?.title != productTitle {
//                    let product = ProductRegistrationModel(data: productData)
//                    self.otherProducts.append(product)
//                }
//            }
//            completion()
//        }
//    }
//
//    // 리팩토링
//    func downloadCategoryImages(completion: @escaping () -> ()) {
//        db.collection("게시글").whereField("category", isEqualTo: product?.category).getDocuments { snapShot, error in
//
//            if let error = error {
//                print("카테고리 게시물 가져오기 실패 = \(error)")
//            }
//
//            guard let documents = snapShot?.documents else { return }
//            self.categoryProducts.removeAll()
//
//            for productData in documents {
//                // 현재 상품 외에 같은 카테고리의 다른 상품들 검색
//                let productTitle = productData.data()["title"] as? String ?? ""
//                if self.product?.title != productTitle {
//                    let product = ProductRegistrationModel(data: productData)
//                    self.categoryProducts.append(product)
//                }
//            }
//            completion()
//        }
//    }
//
//    // 리팩토링
//    // 메소드 이름 리사이즈 들어가게 바꾸기
//    func configureProductImages(images: [UIImage]) {
//        for (index, image) in images.enumerated() {
//            let imageView = UIImageView()
//            let xPos = UIScreen.main.bounds.width * CGFloat(index)
//            imageView.image = image
//
//            let ratio = image.size.width / image.size.height
//            var newHeight = UIScreen.main.bounds.width / ratio
//
//            if newHeight > 700 {
//                newHeight = UIScreen.main.bounds.height * 0.8
//            } else if newHeight < UIScreen.main.bounds.height / 2 {
//                newHeight = UIScreen.main.bounds.height / 2
//            }
//
//            imageHeights.append(floor(newHeight))
//            imageView.frame = CGRect(x: xPos, y: 0, width: UIScreen.main.bounds.width, height: floor(newHeight))
//            productDetailView.productImagesScrollView.addSubview(imageView)
//        }
//    }
//
//
//    @objc func tapProfileViewButton() {
//        let storyboard = UIStoryboard(name: "MyInfo", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "profileVC") as? ProfileTableViewController else { return }
//        vc.userData = productUserInfo
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    @objc func tapCategoryButton() {
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "categoryProductListVC") as? CategoryProductListViewController else { return }
//        vc.category = productDetailView.categoryButton.titleLabel?.text
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    @objc func tapReportButton() {
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "reportVC") else { return }
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    @objc func tapViewMoreButton() {
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "otherProductListVC") as? OtherProductsListViewController else { return }
//        vc.phoneNumber = product?.phoneNumber
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    @objc func tapToZoom() {
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "zoom") as? ZoomImageViewController else { return }
//        vc.images = images
//        vc.imageIndex = productDetailView.pageControl.currentPage
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: false)
//    }
//
//    @objc func tapStartChatButton() {
//        let storyboard = UIStoryboard(name: "Chatting", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(withIdentifier: "chatRoom") as? ChatRoomViewController else { return }
//
//        vc.viewType = "detail"
//        vc.productId = product?.productId
//        vc.productUserData = productUserInfo
//
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    var isButtonTouch = false
//    @objc func tapHeartButton() {
//
//        // 버튼 중복 터치 체크
//        if isButtonTouch == true {
//            return
//        }
//
//        isButtonTouch = true
//
//        if isLike {
//            db.collection("게시글").document(product?.productId ?? "").collection("관심").document(UserModel.getUserData()?.phoneNumber ?? "").delete { error in
//                if let error = error {
//                    print("관심 유저 삭제 실패", error)
//                }
//
//                self.db.collection("게시글").document(self.product?.productId ?? "").getDocument { snapShot, error in
//                    if let error = error {
//                        print("게시물 데이터 가져오기 실패", error)
//                    }
//
//                    guard let likesCount = snapShot?.data()?["likesCount"] as? Int else { return }
//
//                    self.db.collection("게시글").document(self.product?.productId ?? "").updateData(["likesCount": likesCount - 1]) { error in
//                        if let error = error {
//                            print("관심 카운트 업데이트 실패", error)
//                        }
//                        self.isLike = false
//
//                        DispatchQueue.main.async {
//                            self.productDetailView.heartButton.setImage(UIImage(named: "like_unselected"), for: .normal)
//                        }
//
//                        self.db.collection("유저정보").document(UserModel.getUserData()?.phoneNumber ?? "").collection("관심").document(self.product?.productId ?? "").delete() { error in
//                            if let error = error {
//                                print("유저정보에 관심상품 삭제 실패", error)
//                            }
//                            self.isButtonTouch = false
//                        }
//                    }
//                }
//            }
//        } else {
//            db.collection("게시글").document(product?.productId ?? "").collection("관심").document(UserModel.getUserData()?.phoneNumber ?? "").setData([:]) { error in
//                if let error = error {
//                    print("관심 유저 등록 실패", error)
//                }
//
//                self.db.collection("게시글").document(self.product?.productId ?? "").getDocument { snapShot, error in
//                    if let error = error {
//                        print("게시물 데이터 가져오기 실패", error)
//                    }
//
//                    if let likesCount = snapShot?.data()?["likesCount"] as? Int {
//                        self.db.collection("게시글").document(self.product?.productId ?? "").updateData(["likesCount": likesCount + 1]) { error in
//                            if let error = error {
//                                print("관심 카운트 업데이트 실패", error)
//                            }
//                            self.isLike = true
//
//                            DispatchQueue.main.async {
//                                self.productDetailView.heartButton.setImage(UIImage(named: "like_selected"), for: .normal)
//                            }
//
//                            self.db.collection("유저정보").document(UserModel.getUserData()?.phoneNumber ?? "").collection("관심").document(self.product?.productId ?? "").setData([:]) { error in
//                                if let error = error {
//                                    print("유저정보에 관심상품 등록 실패", error)
//                                }
//                                self.isButtonTouch = false
//                            }
//                        }
//                    } else {
//                        self.db.collection("게시글").document(self.product?.productId ?? "").updateData(["likesCount": 1]) { error in
//                            if let error = error {
//                                print("관심 카운트 업데이트 실패", error)
//                            }
//
//                            self.isLike = true
//
//                            DispatchQueue.main.async {
//                                self.productDetailView.heartButton.setImage(UIImage(named: "like_selected"), for: .normal)
//                            }
//
//                            self.db.collection("유저정보").document(UserModel.getUserData()?.phoneNumber ?? "").collection("관심").document(self.product?.productId ?? "").setData([:]) { error in
//                                if let error = error {
//                                    print("유저정보에 관심상품 등록 실패", error)
//                                }
//                                self.isButtonTouch = false
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//extension ProductDetaileViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if viewState == .finish && !images.isEmpty {
//            if scrollView.restorationIdentifier == "mainScrollView" {
//                productDetailView.productImagesScrollView.contentOffset.y = scrollView.contentOffset.y > 0 ? scrollView.contentOffset.y : 0
//
//                let imageHeight = imageHeights[productDetailView.pageControl.currentPage]
//                let imageViews = productDetailView.productImagesScrollView.subviews.filter({$0 is UIImageView})
//                let imageView = imageViews[productDetailView.pageControl.currentPage]
//
//                let coverHeight = imageHeight - productDetailView.stackViewInMainScrollView.frame.origin.y
//                let scale = 1 + -(coverHeight + scrollView.contentOffset.y) * 2 / imageHeight
//
//                if productDetailView.stackViewInMainScrollView.frame.origin.y + -scrollView.contentOffset.y > 121 {
//                    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//                    self.navigationController?.navigationBar.shadowImage = UIImage()
//                } else {
//                    self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
//                    self.navigationController?.navigationBar.shadowImage = nil
//                }
//
//                if productDetailView.stackViewInMainScrollView.frame.origin.y + -scrollView.contentOffset.y > imageHeights[productDetailView.pageControl.currentPage] {
//                    imageView.transform = .identity
//                    imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
//                } else {
//                    imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
//                }
//            } else if scrollView.restorationIdentifier == "productImagesScrollView" {
//                productDetailView.pageControl.currentPage = Int(floor(scrollView.contentOffset.x / UIScreen.main.bounds.width))
//            }
//        }
//    }
//}
//
//extension ProductDetaileViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView.restorationIdentifier == "otherProductsCollectionView" {
//            if otherProducts.count > 5 {
//                return 4
//            } else {
//                return otherProducts.count
//            }
//        } else if collectionView.restorationIdentifier == "recommendationCollectionView" {
//            return categoryProducts.count
//        } else {
//            return 0
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherProductCollectionViewCell.identifier, for: indexPath) as? OtherProductCollectionViewCell else { return UICollectionViewCell() }
//
//        if collectionView.restorationIdentifier == "otherProductsCollectionView" {
//            cell.imageView.kf.setImage(with: URL(string: otherProducts[indexPath.row].photos.first ?? ""),placeholder: UIImage(named: "swift"))
//            cell.productTitleLabel.text = otherProducts[indexPath.row].title
//            cell.priceLabel.text = otherProducts[indexPath.row].price
//            cell.tag = indexPath.row
//            return cell
//        } else if collectionView.restorationIdentifier == "recommendationCollectionView" {
//            cell.imageView.kf.setImage(with: URL(string: categoryProducts[indexPath.row].photos.first ?? ""),placeholder: UIImage(named: "swift"))
//            cell.productTitleLabel.text = categoryProducts[indexPath.row].title
//            cell.priceLabel.text = categoryProducts[indexPath.row].price
//            cell.tag = indexPath.row
//            return cell
//        } else {
//            return UICollectionViewCell()
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as? ProductDetaileViewController else { return }
//
//        if collectionView.restorationIdentifier == "otherProductsCollectionView" {
//            vc.product = otherProducts[indexPath.row]
//            self.navigationController?.pushViewController(vc, animated: true)
//        } else if collectionView.restorationIdentifier == "recommendationCollectionView" {
//            vc.product = categoryProducts[indexPath.row]
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//}
//
//extension ProductDetaileViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let size = UIScreen.main.bounds.width / 2 * 0.90
//        return CGSize(width: size, height: size)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 30, left: 15, bottom: 30, right: 15)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 30
//    }
//}
