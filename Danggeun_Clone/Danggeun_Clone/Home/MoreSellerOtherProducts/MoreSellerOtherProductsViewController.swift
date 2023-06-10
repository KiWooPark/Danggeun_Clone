//
//  MoreOtherProductsViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/01/17.
//

import UIKit
import FirebaseFirestore

struct Page {
    var vc = UIViewController()
    
    init(vc: UIViewController) {
        self.vc = vc
    }
}

struct PageArray {
    var pages = [Page]()
    var selectedPageIndex = 0
}

// 스티키헤더뷰 높이값
var topViewInitialHeight : CGFloat = 125

// 네비게이션을 사용한다면 높이값 지정
let topViewFinalHeight : CGFloat = 0

// 범위
let topViewHeightConstraintRange = topViewFinalHeight..<topViewInitialHeight

// MARK: [Class or Struct] ----------
class MoreSellerOtherProductsViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var segmentControl: UnderlineSegmentedControl!
    @IBOutlet var stickyHederView: UIView!
    @IBOutlet var stickyHeaderViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var bottomView: UIView!
    
    private var estimateOffSetX: CGFloat = 0
    
    // MARK: [Let Or Var] ----------
    var pageViewController = UIPageViewController()
    var pageArray = PageArray()
    
    var userData: UserModel?

    var isUpdateCount = false
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configData()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.setBackIndicatorImage(UIImage(named: "backButton"), transitionMaskImage: UIImage(named: "backButton"))
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(0)]
        appearance.shadowColor = nil
        
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.standardAppearance = appearance
        
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProductsCount), name: .updateProductsCount, object: nil)
    }
    
   
    
    // MARK: [@IBAction] ----------
    @IBAction func tapSegmentControl(_ sender: Any) {
        guard let segmentContrl = sender as? UISegmentedControl else { return }
    
        let direction: UIPageViewController.NavigationDirection = pageArray.selectedPageIndex <= segmentContrl.selectedSegmentIndex ? .forward : .reverse
        
        pageArray.selectedPageIndex = segmentContrl.selectedSegmentIndex
        
        setPageView(index: segmentContrl.selectedSegmentIndex, direction: direction)
    }
    
    // MARK: [Function] ----------
    func configData() {
        
        FirebaseManager.shared.fetchOtherProductsCount(phoneNumber: self.userData?.phoneNumber ?? "") { result in
            switch result {
            case .success(let counts):
                FirebaseManager.shared.downloadThumbnailImage(url: self.userData?.profileImageUrl ?? "") { result in
                    switch result {
                    case .success(let thumbnailImage):

                        DispatchQueue.main.async {
                            if self.userData?.phoneNumber ?? "" != UserModel.getUserData()?.phoneNumber ?? "" {

                                let hiddenCount = counts?["hidden"] ?? 0

                                self.segmentControl.setTitle("전체 \((counts?["total"] ?? 0) - hiddenCount)", forSegmentAt: 0)
                                self.segmentControl.setTitle("거래중 \(counts?["trading"] ?? 0)", forSegmentAt: 1)
                                self.segmentControl.setTitle("거래완료 \(counts?["completed"] ?? 0)", forSegmentAt: 2)

                                self.navigationItem.title = "\(self.userData?.nickname ?? "")님 판매상품"
                                self.nicknameLabel.text = "\(self.userData?.nickname ?? "")님 판매상품"
                                self.profileImageView.image = thumbnailImage
                            } else {

                                self.segmentControl.setTitle("판매중 \(counts?["trading"] ?? 0)", forSegmentAt: 0)
                                self.segmentControl.setTitle("거래완료 \(counts?["completed"] ?? 0)", forSegmentAt: 1)
                                self.segmentControl.setTitle("숨김 \(counts?["hidden"] ?? 0)", forSegmentAt: 2)

                                self.navigationItem.title = "나의 판매내역"
                                self.nicknameLabel.text = "나의 판매내역"
                                self.profileImageView.image = thumbnailImage
                            }

                            if !self.isUpdateCount {
                                self.configBottomView()
                            }
                        }

                    case .failure(let error):
                        print("이미지 다운로드 실패", error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func configBottomView() {
        // 페이지 컨트롤러 옵션 설정
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        // 페이지 컨트롤러 델리게이트 연결
        pageViewController.delegate = self
        // 페이지 컨트롤러 데이터소스 연결
        pageViewController.dataSource = self
        
        // 첫번째 페이지 뷰
        if let firstVC = self.storyboard?.instantiateViewController(withIdentifier: "1") as? FirstViewController {
            
            // 여기에 델리게이트 연결해야함
            firstVC.innerTableViewDelegate = self
            firstVC.userPhoneNumber = self.userData?.phoneNumber ?? ""
            //firstVC.accessController = self.accessController
            let page1 = Page(vc: firstVC)
            pageArray.pages.append(page1)
        }
        
        // 두번째 페이지 뷰
        if let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "2") as? SecondViewController {
            
            // 여기에 델리게이트 연결해야함
            secondVC.innerTableViewDelegate = self
            secondVC.userPhoneNumber = self.userData?.phoneNumber ?? ""
            //secondVC.accessController = self.accessController
            let page2 = Page(vc: secondVC)
            pageArray.pages.append(page2)
        }
        
        // 세번째 페이지 뷰
        if let thirdVC = self.storyboard?.instantiateViewController(withIdentifier: "3") as? ThirdViewController {

            // 여기에 델리게이트 연결해야함
            thirdVC.innerTableViewDelegate = self
            thirdVC.userPhoneNumber = self.userData?.phoneNumber ?? ""
            //thirdVC.accessController = self.accessController
            let page3 = Page(vc: thirdVC)
            pageArray.pages.append(page3)
        }
    
        pageViewController.setViewControllers([pageArray.pages[0].vc], direction: .forward, animated: true)
        
        addChild(pageViewController)
        pageViewController.willMove(toParent: self)
        bottomView.addSubview(pageViewController.view)
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageViewController.view.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            pageViewController.view.topAnchor.constraint(equalTo: bottomView.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
        ])
        
        let scrollView = bottomView.subviews.first?.subviews.filter({$0 is UIScrollView}).first as! UIScrollView
        scrollView.delegate = self
    }
    
    func setPageView(index: Int, direction: UIPageViewController.NavigationDirection) {
        
        // 세그먼트 컨트롤 터치시 scrollViewDidScroll 사용 못하도록 델리게이트 끊음
        let scrollView = bottomView.subviews.first?.subviews.filter({$0 is UIScrollView}).first as! UIScrollView
        scrollView.delegate = nil
        
        pageViewController.setViewControllers([pageArray.pages[index].vc], direction: direction, animated: true)

        let underline = segmentControl.subviews.filter({$0.restorationIdentifier == "underlineView"})[0]
        
        let underlineFinalXPosition = (self.view.frame.width / CGFloat(segmentControl.numberOfSegments)) * CGFloat(segmentControl.selectedSegmentIndex)
        
        UIView.animate(withDuration: 0.3) {
            underline.frame.origin.x = underlineFinalXPosition
        } completion: { _ in
            // 애니메이션 끝난 후 다시 scrollViewDidScroll 사용하도록 델리게이트 연결
            scrollView.delegate = self
        }
    }
    
    // MARK: [@objc Function] ----------
    @objc func updateProductsCount() {
        isUpdateCount = true
        configData()
    }
}

// MARK: [PageViewController - DataSource] ----------
extension MoreSellerOtherProductsViewController: UIPageViewControllerDataSource {
 
    // 현재 페이지 뷰의 이전 뷰를 미리 로드
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // 현재 페이지의 인덱스 번호
        guard let vcIndex = pageArray.pages.firstIndex(where: {$0.vc == viewController}) else { return nil }
        
        // 이전 페이지 인덱스
        let prevIndex = vcIndex - 1
        
        // 인덱스가 0 이상이면 통과
        guard prevIndex >= 0 else { return nil }
        
        // 인덱스가 뷰컨트롤러 카운트보다 클 수 없음
        guard pageArray.pages.count > prevIndex else { return nil }
       
        // 이전 뷰 리턴
        return pageArray.pages[prevIndex].vc
        
    }
    
    // 현재 페이지 뷰의 다음 뷰를 미리 로드
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // 현재 페이지 인덱스 번호
        guard let vcIndex = pageArray.pages.firstIndex(where: {$0.vc == viewController}) else { return nil }
        
        // 다음 페이지 인덱스
        let nextIndex = vcIndex + 1
        
        // 인덱스가
        guard nextIndex < pageArray.pages.count else { return nil }
        
        // 다음 뷰 리턴
        return pageArray.pages[nextIndex].vc
    }
    
}

// MARK: [PageViewController - Delegate] ----------
extension MoreSellerOtherProductsViewController: UIPageViewControllerDelegate {
    
    // 현재 페이지 뷰 로드가 끝났을 때
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        guard completed else { return }
        
        guard let currentVC = pageViewController.viewControllers?.first else { return }

        guard let index = pageArray.pages.firstIndex(where: {$0.vc == currentVC}) else { return }

        pageArray.selectedPageIndex = index
    }
}

// MARK: [Delegate] ----------
extension MoreSellerOtherProductsViewController: InnerTableViewScrollDelegate {
    
    var headerHeight: CGFloat {
        return stickyHeaderViewHeightConstraint.constant
    }

    func didScroll(distance: CGFloat) {
        stickyHeaderViewHeightConstraint.constant -= distance

        if stickyHeaderViewHeightConstraint.constant > topViewInitialHeight {

            stickyHeaderViewHeightConstraint.constant = topViewInitialHeight
        }

        if stickyHeaderViewHeightConstraint.constant < topViewFinalHeight {

            stickyHeaderViewHeightConstraint.constant = topViewFinalHeight
        }
        
        let percentage = 1 - stickyHeaderViewHeightConstraint.constant / 125
        
     
        self.navigationItem.standardAppearance?.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(percentage)]
        self.navigationItem.scrollEdgeAppearance?.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(percentage)]
    }
}

// MARK: [ScrollView - Delegate] ----------
extension MoreSellerOtherProductsViewController: UIScrollViewDelegate {
    
    // 참고
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let pageWidth = view.frame.width
//        currentPage = Int(round(estimateOffSetX/pageWidth))
//        if currentPage < 0 {
//            currentPage = (readyViewControllers?.count)! - 1
//        }
//        estimateOffSetX = CGFloat(currentPage)*pageWidth
//        //        print("矫正后：\(estimateOffSetX)")
//        scrollDidScroll!(estimateOffSetX)
//    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let underline = segmentControl.subviews.filter({$0.restorationIdentifier == "underlineView"})[0]

        segmentControl.selectedSegmentIndex = pageArray.selectedPageIndex

        let width = self.view.frame.width

        // 스크롤 끝난 후 오차때문에 강제 지정
        switch self.pageArray.selectedPageIndex {
        case 0:
            underline.frame.origin.x = 0
        case 1:
            underline.frame.origin.x = width / 3
        case 2:
            underline.frame.origin.x = (width * 2) / 3
        default:
            print("")
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let underline = segmentControl.subviews.filter({$0.restorationIdentifier == "underlineView"})[0]
        
        let pageWidth = self.view.frame.width
        
        for vc in pageArray.pages {
            let pagePoint = vc.vc.view.convert(CGPoint(), to: view)
            
            if (pagePoint.x) > CGFloat(0.0) && (pagePoint.x) < pageWidth {
                let estimatePage = pageArray.pages.firstIndex(where: {$0.vc == vc.vc})
                estimateOffSetX = ((CGFloat(estimatePage ?? 0) * pageWidth) - (pagePoint.x))
            }
        }
    
        if (0 ... view.bounds.width * 2).contains(estimateOffSetX) {
            underline.frame.origin.x = abs(estimateOffSetX / 3)
        }
    }
}

