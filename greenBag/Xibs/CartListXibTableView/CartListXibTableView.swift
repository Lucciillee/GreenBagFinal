

import UIKit
protocol CartListXibTableViewDelegate: AnyObject {
    func removeCartItem(cell: CartListXibTableView)
}


class CartListXibTableView: UITableViewCell {
    
    weak var delegate: CartListXibTableViewDelegate?
    
    
    @IBOutlet weak var removeButton: CustomRoundedButton!
    @IBOutlet weak var cartItemImage: UIImageView!
    
    @IBOutlet weak var cartItemCategory: UILabel!
    
    @IBOutlet weak var cartItemName: UILabel!
    
    @IBOutlet weak var cartItemTotalItems: UILabel!
    
    @IBOutlet weak var cartItemTotalPrice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        assignRandomImage()
        
    }
    
    @IBAction func removeButtonPressed(_ sender: Any) {
        delegate?.removeCartItem(cell: self)
    }
    
    func addDataToCartCell(cartModel: CartItemRealm) {
        cartItemName.text = cartModel.productName
        cartItemCategory.text = cartModel.productCategory
        cartItemTotalItems.text = String(cartModel.quantity)
        cartItemTotalPrice.text = cartModel.totalPrice
    }
    
    private func assignRandomImage() {
        // List of image names in your asset catalog
        let imageNames = [ "firstProductImage"] // Replace these with your actual image names
        
        // Select a random image
        if let randomImageName = imageNames.randomElement() {
            cartItemImage.image = UIImage(named: randomImageName)
        }
    }

}
