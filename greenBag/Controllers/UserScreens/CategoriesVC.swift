

import UIKit
import RealmSwift
class CategoriesVC: UIViewController {
    
    
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    @IBOutlet weak var recentlyViewCollectionView: UICollectionView!
    @IBOutlet weak var recommendedCollectionView: UICollectionView!
    
    private let realm = try! Realm()
    private var productsList: [ProductModelRealm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the XIB for collection views
        let nib = UINib(nibName: "ProductXibCollectionView", bundle: nil)
        categoriesCollectionView.register(nib, forCellWithReuseIdentifier: "ProductXibCollectionView")
        recentlyViewCollectionView.register(nib, forCellWithReuseIdentifier: "ProductXibCollectionView")
        recommendedCollectionView.register(nib, forCellWithReuseIdentifier: "ProductXibCollectionView")
        
        // Set delegates and data sources
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        
        recentlyViewCollectionView.delegate = self
        recentlyViewCollectionView.dataSource = self
        
        recommendedCollectionView.delegate = self
        recommendedCollectionView.dataSource = self
        
        // Fetch products from Realm
        fetchProductsFromRealm()
    }
    
    private func fetchProductsFromRealm() {
        let products = realm.objects(ProductModelRealm.self)
        productsList = Array(products)
        
        // Reload all collection views
        categoriesCollectionView.reloadData()
        recentlyViewCollectionView.reloadData()
        recommendedCollectionView.reloadData()
    }
    
}

extension CategoriesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductXibCollectionView", for: indexPath) as! ProductXibCollectionView
        cell.configureWithStoreData(productModelRealm: productsList[indexPath.row])
        return cell
    }
}

extension CategoriesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 30) / 2 // Adjust based on desired layout
        return CGSize(width: width, height: 120)
    }
}
