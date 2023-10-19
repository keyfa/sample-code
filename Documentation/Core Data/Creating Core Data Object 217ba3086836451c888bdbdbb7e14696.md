# Creating Core Data Object

1. Create a class using the template below

```swift
import CoreData

@objc(CoreDataObject)
final class CoreDataObject: NSManagedObject {
    
    enum JsonKey: String {
        case id
        case propertyToUpdate
        case optionalProperty
    }
    
    @NSManaged public var id: String
    @NSManaged public var propertyToUpdate: String
    @NSManaged public var optionalProperty: String?
    
    @nonobjc public class func createFetchRequest() -> NSFetchRequest<CoreDataObject> {
        return NSFetchRequest<CoreDataObject>(entityName: String(describing: self))
    }
    
    @discardableResult func setup(usingJson json: JSON) -> Bool {
        
        guard let id = json[JsonKey.id.rawValue] as? String,
              let propertyToUpdate = json[JsonKey.propertyToUpdate.rawValue] as? String,
        else {
            print("Error: Failed to create NSManagedObject")
            return false
        }
        
        self.id = id
        self.propertyToUpdate = propertyToUpdate
        
        optionalProperty = json[JsonKey.optionalProperty.rawValue] as? String
        
        return true
    }
}
```

1. Navigate to the data database and create a new model version. The model name should PineappleDatabasex with x being the next increment.
    
    ![Untitled](Creating%20Core%20Data%20Object%20217ba3086836451c888bdbdbb7e14696/Untitled.png)
    
2. Add an entity by pressing pressing the button labeled **1** in the image below. ❗********************************This should have the same name as class you just created.********************************
3. Add the attributes but clicking the + icon in the box labeled **2**. ❗**These should have the same name and type at the properties created in the class.**
4. Make sure to set the codegen to be Manual/None on the right panel labeled by **3.** 

![Untitled](Creating%20Core%20Data%20Object%20217ba3086836451c888bdbdbb7e14696/Untitled%201.png)

1. ⚠️ **If your object has a unique id, add it as a constraint shown below ⚠️** This will stop duplicate data occurring.

![Untitled](Creating%20Core%20Data%20Object%20217ba3086836451c888bdbdbb7e14696/Untitled%202.png)

1. Make sure to set the current model version to the new model version

![Untitled](Creating%20Core%20Data%20Object%20217ba3086836451c888bdbdbb7e14696/Untitled%203.png)