# Fetching Templates

### Fetching one object template

```swift
func loadCoreDataObject() -> CoreDataObject? {

        let containerViewContext = AppCoordinator.shared.containerViewContext()

        let request = CoreDataObject.createFetchRequest()

				//Add predicates if needed to fetch data who's property matches a certian value 
        request.predicate = NSPredicate.searchForObject(usingProperty: CoreDataObject.JsonKey.id.rawValue, withStringValue: id)
				//Add sortDescriptors if needed to sort data
        request.sortDescriptors = [NSSortDescriptor(key: CoreDataObject.JsonKey.timestamp.rawValue, ascending: false)]

        do {
            let results = try containerViewContext.fetch(request)
            return results.first
        } catch {
            return nil
        }
	}
```