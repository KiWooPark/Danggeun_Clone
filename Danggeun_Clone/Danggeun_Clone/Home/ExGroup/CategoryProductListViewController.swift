////
////  CategoryProductListViewController.swift
////  Danggeun_Clone
////
////  Created by PKW on 2022/06/17.
////
//
//import UIKit
//import Kingfisher
//import FirebaseFirestore
//
//class CategoryProductListViewController: UIViewController {
//
//    @IBOutlet var productListTableView: UITableView!
//    
//    var category: String?
//    
//    let db = Firestore.firestore()
//    
//    var categoryProductList = [ProductRegistrationModel]()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.title = category ?? ""
//        
//        fetchCategoryProductDB() {
//            self.productListTableView.reloadData()
//        }
//    }
//    
//    func fetchCategoryProductDB(completion: @escaping () -> ()) {
//        db.collection("게시글").whereField("category", isEqualTo: category).getDocuments { snapShot, error in
//            if let error = error {
//                print("카테고리와 같은 게시물 가져오기 실패 = \(error)")
//            }
//            guard let documents = snapShot?.documents else { return }
//            
//            for productData in documents {
//                let product = ProductRegistrationModel(data: productData)
//                self.categoryProductList.append(product)
//            }
//            
//            self.categoryProductList.sort(by: {$0.update.seconds > $1.update.seconds})
//            completion()
//        }
//    }
//}
//
//extension CategoryProductListViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as? ProductDetaileViewController else { return }
//        //vc.product = categoryProductList[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//}
//
//extension CategoryProductListViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return categoryProductList.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductListTableViewCell else { return UITableViewCell() }
//        cell.productImageView.kf.setImage(with: URL(string: categoryProductList[indexPath.row].photos.first ?? ""))
//        cell.titleLabel.text = categoryProductList[indexPath.row].title
//        cell.priceLabel.text = categoryProductList[indexPath.row].price
//        cell.addressLabel.text = categoryProductList[indexPath.row].address
//        cell.timeLabel.text = "\(categoryProductList[indexPath.row].update.convertTimestamp()) 전"
//        return cell
//    }
//}
