

import UIKit

protocol StoreProductListXibTableViewDelegate: AnyObject {
    func deleteProduct(cell: StoreProductListXibTableView)
    func showProductDetails(cell: StoreProductListXibTableView)
}

class StoreProductListXibTableView: UITableViewCell {
    
    weak var delegate: StoreProductListXibTableViewDelegate?
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productName: UILabel!
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func productDetailsButtonPressed(_ sender: Any) {
        delegate?.showProductDetails(cell: self)
    }
    
    @IBAction func deleteProductButtonPressed(_ sender: Any) {
        delegate?.deleteProduct(cell: self)
    }
    
    
    func configureWithStoreData(productModelRealm: ProductModelRealm) {
        assignRandomImage()
        productName.text = productModelRealm.name
    }
    
    private func assignRandomImage() {
        // List of image names in your asset catalog
        let imageNames = [ "thirdProductImage"] // Replace these with your actual image names
        
        // Select a random image
        if let randomImageName = imageNames.randomElement() {
            productImage.image = UIImage(named: randomImageName)
        }
    }
    
    
}

