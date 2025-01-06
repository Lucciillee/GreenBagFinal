

import UIKit

protocol StoreXibTableViewDelegate: AnyObject {
    func deleteStore(cell: StoresListXibTableView)
    func showStoreDetails(cell: StoresListXibTableView)
}

class StoresListXibTableView: UITableViewCell {
    
    weak var delegate: StoreXibTableViewDelegate?
    
    @IBOutlet weak var storeImage: UIImageView!
    
    @IBOutlet weak var storeName: UILabel!
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func storeDetailsButtonPressed(_ sender: Any) {
        delegate?.showStoreDetails(cell: self)
    }
    
    @IBAction func deleteStoreButtonPressed(_ sender: Any) {
        delegate?.deleteStore(cell: self)
    }
    
    
    func configureWithStoreData(userModel: UserModel) {
        assignRandomImage()
        storeName.text = userModel.name
    }
    
    private func assignRandomImage() {
        // List of image names in joyour asset catalog
        let imageNames = ["dummyStoreImage"] // Replace these with your actual image names
        
        // Select a random image
        if let randomImageName = imageNames.randomElement() {
            storeImage.image = UIImage(named: randomImageName)
        }
    }
    
}
