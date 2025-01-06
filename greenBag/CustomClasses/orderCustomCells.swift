

import Foundation
import UIKit


class OrderHeaderCell: UITableViewCell {
    @IBOutlet weak var orderIDLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func configure(orderID: String, total: Double, status: String, date: Date) {
        orderIDLabel.text = "Order #\(orderID.prefix(8))"
        totalLabel.text = String(format: "Total: BHD %.2f", total)
        statusLabel.text = status.capitalized
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: date)
        
        // Style status label based on status
        statusLabel.textColor = status == "pending" ? .orange :
                              status == "completed" ? .green : .red
    }
}

class OrderItemCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configure(name: String, quantity: Int, price: Double) {
        nameLabel.text = name
        quantityLabel.text = "Qty: \(quantity)"
        priceLabel.text = String(format: "BHD %.2f", price * Double(quantity))
    }
}
