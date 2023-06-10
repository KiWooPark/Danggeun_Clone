//
//  PhotosTableViewCell.swift
//  Danggeun_Clone
//
//  Created by PKW on 2023/02/02.
//

import UIKit

// MARK: [Class or Struct] ----------
class PhotosTableViewCell: UITableViewCell {

    // MARK: [@IBOutlet] ----------
    @IBOutlet var photoCollectionView: UICollectionView!
    
    // MARK: [Let Or Var] ----------
    var selectedImages = [UIImage]()
    
    var accessController = AccessControllerType.none
    weak var rootVC: AddProductViewController?
   
    // MARK: [Override] ----------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configPhotoCollectionView()
    }
    
    // MARK: [Function] ----------
    func configPhotoCollectionView() {
        photoCollectionView.dataSource = self
    }
}

// MARK: [CollectionView - DataSource] ----------
extension PhotosTableViewCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return selectedImages.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addPhotoCell", for: indexPath) as? AddPhotoCollectionViewCell else { return UICollectionViewCell() }
            
            cell.countLabel.text = "\(selectedImages.count)"
            
            if selectedImages.count > 0 {
                cell.countLabel.textColor = UIColor(displayP3Red: 237/255, green: 125/255, blue: 52/255, alpha: 1)
            } else {
                cell.countLabel.textColor = .black
            }
            
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
            
        
            cell.deleteButton.addTarget(rootVC, action: #selector(rootVC?.deletePhoto(sender:)), for: .touchUpInside)
        
            cell.deleteButton.tag = indexPath.row
            cell.selectedImageView.image = selectedImages[indexPath.row].resizeThumbnailTo()
            cell.representativeLabel.isHidden = indexPath.row == 0 ? false : true
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}
