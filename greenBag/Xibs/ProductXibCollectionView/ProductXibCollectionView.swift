

import UIKit
class ProductXibCollectionView: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        assignRandomImage()
    }
    
    func configureWithStoreData(productModelRealm: ProductModelRealm) {
        assignRandomImage()
        productName.text = productModelRealm.name
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
