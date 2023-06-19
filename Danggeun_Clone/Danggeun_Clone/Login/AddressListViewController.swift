//
//  RegionListViewController.swift
//  Danggeun_Clone
//
//  Created by PKW on 2022/10/08.
//

import UIKit
import CoreLocation
import SnapKit
import NMapsMap
import FirebaseFirestore
import Kingfisher

// MARK: [Protocol] ----------
protocol AddressListViewControllerDelegate: AnyObject {
    func sendSelectedAddress(address: String, isFirstButton: Bool)
}

// MARK: [Class or Struct] ----------
class AddressListViewController: UIViewController {
    
    // MARK: [@IBOutlet] ----------
    @IBOutlet var findindCurrentLocationButton: UIButton!
    @IBOutlet var addressListTableView: UITableView!
    
    // MARK: [Let Or Var] ----------
    let db = Firestore.firestore()
    weak var delegate: AddressListViewControllerDelegate?
    
    // 뷰컨트롤러 타입 체크
    var vcType = VCType.addressVC
    
    var isSetting = false
    var isFirstButton = false
    
    var isFiltering = false
    
    // 인증VC에서 받아온 데이터
    var phoneNumber: String?
    
    var allAddressList = [[AddressModel]]()
    var addressList = [[AddressModel]]()
    
    var headerString = "근처 동네"
    
    // MARK: [Override] ----------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        addressListTableView.keyboardDismissMode = .onDrag
        
        if #available(iOS 15.0, *) {
            addressListTableView.sectionHeaderTopPadding = 0
        }
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        // 1. 모든 지역 정보 불러오기(CSV)
        guard let path = Bundle.main.path(forResource: "address", ofType: "csv") else { return }
        fetchAllAddress(url: URL(fileURLWithPath: path))
        
        LocationManager.shared.getNaverCurrentLocation { area1, area2, area3, area4 in
            self.fetchMyCurrentLocationAddress(area1: area1, area2: area2, area3: area3, area4: area4)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.titleView?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.titleView?.translatesAutoresizingMaskIntoConstraints = true
    }
    
    // MARK: [@IBAction] ----------
    @IBAction func tapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapFindCurrentLocationButton(_ sender: Any) {
        
        if let searchBar = self.navigationItem.titleView?.subviews.first as? UISearchBar {
            searchBar.text = ""
            headerString = "근처 동네"
        }
        
        LocationManager.shared.getNaverCurrentLocation { area1, area2, area3, area4 in
            self.fetchMyCurrentLocationAddress(area1: area1, area2: area2, area3: area3, area4: area4)
        }
    }
    
    // MARK: [Function] ----------
    func configureNavigationBar() {
        
        let container = SearchAddressContainerView()
        container.backgroundColor = .white
        
        container.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        
        let searchBar = UISearchBar()
        searchBar.delegate = self
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear
            textField.placeholder = "동명(읍, 면)으로 검색 (ex. 서초동)"
        }
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        self.navigationItem.titleView = container
    }
    
    private func fetchAllAddress(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoder = String(data: data, encoding: .utf8)
            
            if let dataArr = dataEncoder?.components(separatedBy: "\n").map({$0.split(separator: ",", maxSplits: 1)}).dropLast() {
                let addressList = dataArr.map({$0.map({String($0)})})
                
                for address in addressList {
                    allAddressList.append([AddressModel(address: address[0], address2: address[1].replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\"", with: ""))])
                }
            }
        } catch {
            print("CSV 불러오기 실패")
        }
    }
    
    // 검색(필터링)
    func filteredAddress(text: String) {
        addressList.removeAll()
        addressList = allAddressList.filter({$0[0].address.contains(text)})
        
        addressListTableView.reloadData()
    }
    
    // 현재위치로 찾기
    // 여기도 카운트로 분기 필요 2개,3개,4개
    func fetchMyCurrentLocationAddress(area1: String, area2: String, area3: String, area4: String) {
        
        var area1 = area1
        var area2 = area2
        var area3 = area3
        var area4 = area4
        
        if area1 == "" || area2 == "" || area3 == "" || area4 == "" {
            area1 = "경기도"
            area2 = "평택시"
            area3 = "장당동"
            area4 = ""
        }
        
        addressList.removeAll()
                
        var index = 0
        var filteredArea1 = allAddressList.filter({$0[0].address.contains(area1)})
        
        if area3 == "" && area4 == "" {
            let currentArea = filteredArea1.filter({$0[0].address.contains(area2)})
            index = filteredArea1.firstIndex(where: {$0[0].address == currentArea[0][0].address}) ?? 0
            filteredArea1.remove(at: index)
            
            addressList.append(contentsOf: currentArea)
            addressList.append(contentsOf: filteredArea1)
        } else if area4 == "" {
            var filteredArea2 = filteredArea1.filter({$0[0].address.contains(area2)})
            let currentArea = filteredArea2.filter({$0[0].address.contains(area3)})
            index = filteredArea2.firstIndex(where: {$0[0].address == currentArea[0][0].address}) ?? 0
            
            filteredArea2.remove(at: index)
            addressList.append(contentsOf: currentArea)
            addressList.append(contentsOf: filteredArea2)
        } else {
            let filteredArea2 = filteredArea1.filter({$0[0].address.contains(area2)})
            var filteredArea3 = filteredArea2.filter({$0[0].address.contains(area3)})
            let currentArea = filteredArea3.filter({$0[0].address.contains(area4)})
            
            index = filteredArea3.firstIndex(where: {$0[0].address == currentArea[0][0].address}) ?? 0
            
            filteredArea3.remove(at: index)
            
            addressList.append(contentsOf: currentArea)
            addressList.append(contentsOf: filteredArea3)
        }
        
        DispatchQueue.main.async {
            self.addressListTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.addressListTableView.reloadData()
        }
    }
}


// MARK: [TableView - DataSource] ----------
extension AddressListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as? AddressInfoTableViewCell else { return UITableViewCell()}
        
        cell.addressLabel.text = addressList[indexPath.row][0].address
        if addressList[indexPath.row][0].address2 != "" {
            cell.address2Label.text = "관련주소 : \(addressList[indexPath.row][0].address2)"
            cell.address2Label.isHidden = false
        } else {
            cell.address2Label.isHidden = true
        }
        return cell
    }
}

// MARK: [TableView - Delegate] ----------
extension AddressListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let target = addressList[indexPath.row][0]
        
        // 로그인에서인지, 동네변경인지 분기
        if isSetting {
            delegate?.sendSelectedAddress(address: target.address, isFirstButton: isFirstButton)
            self.navigationController?.popViewController(animated: true)
        } else {
            if vcType == .loginVC {
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "authVC") as? AuthPhoneNumberViewController else { return }
                vc.userData = UserModel(address: target.address, phoneNumber: nil)
                vc.vcType = VCType.addressVC
                self.navigationController?.pushViewController(vc, animated: true)
            } else if vcType == .authVC {
                guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "nickname") as? NicknameConfigureViewController else { return }
                vc.userData = UserModel(address: target.address, phoneNumber: phoneNumber)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        let label = UILabel()
        label.text = headerString
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 14)

        let view = UIView()
        view.backgroundColor = .white

        view.addSubview(label)

        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(18)
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        return view
    }
}

// MARK: [SearchBar - Delegate] ----------
extension AddressListViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        addressList.removeAll()
        addressListTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if searchText == "" {
            LocationManager.shared.getNaverCurrentLocation { area1, area2, area3, area4  in
                self.fetchMyCurrentLocationAddress(area1: area1, area2: area2, area3: area3, area4: area4)
                self.headerString = "근처 동네"
            }
        } else {
            filteredAddress(text: searchText)
            self.headerString = "'\(searchText)' 검색 결과"
        }
    }
}
