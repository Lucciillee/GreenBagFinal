

import UIKit
class ProductXibTableView: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productCategory: UILabel!
    
    
    @IBOutlet weak var productName: UILabel!
    
    
    @IBOutlet weak var productPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        assignRandomImage()
    }
    
    func addCellDatawithProductData(productsListModel: ProductModelRealm) {
        productCategory.text = productsListModel.category
        productName.text = productsListModel.name
        productPrice.text = "\(productsListModel.price) BHD"
    }
    
    private func assignRandomImage() {
        // List of image names in your asset catalog
        let imageNames = [ "firstProductImage"] // Replace these with your actual image names
        
        // Select a random image
        if let randomImageName = imageNames.randomElement() {
            productImage.image = UIImage(named: randomImageName)
        }
    }
    
}
