

import Foundation
import RealmSwift

class ProductModelRealm: Object {
    @Persisted(primaryKey: true) var id: ObjectId = ObjectId.generate()
    @Persisted var name: String = ""
    @Persisted var category: String = ""
    @Persisted var price: String = ""
    @Persisted var quantity: String = ""
    
    
}
