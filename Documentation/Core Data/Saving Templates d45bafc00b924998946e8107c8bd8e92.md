# Saving Templates

### Saving one object template

```swift
func saveCoreDataObject(json: JSON) {
        
        let backgroundContainerViewContext = AppCoordinator.shared.backgroundContainerViewContext()
        
        backgroundContainerViewContext.perform {
            
            guard let objectId = json[CoreDataObject.JsonKey.id.rawValue] as? String else {
                return
            }
            
            let coreDataObject: CoreDataObject
            
            if let localCoreDataObject = loadCoreDataObject(with: id, withBackgroundContext: backgroundContainerViewContext) {
                coreDataObject = localCoreDataObject
            } else {
                coreDataObject = CoreDataObject(context: backgroundContainerViewContext)
            }
            
            let didSetupSuccessfully = coreDataObject.setup(usingJson: json)
            
            if !didSetupSuccessfully {
                backgroundContainerViewContext.delete(coreDataObject)
            }
            
            AppCoordinator.shared.saveBackgroundContext(with: backgroundContainerViewContext)
            return
        }
    }
```

### Saving many objects template

```swift
func saveCoreDataObjects(json: [JSON]) {

        let backgroundContainerViewContext = AppCoordinator.shared.backgroundContainerViewContext()

        let newObjectsIds = json.compactMap { $0[CoreDataObject.JsonKey.id.rawValue] as? String }

        backgroundContainerViewContext.perform {

            let localObjectsInNewObjects = getLocalCoreDataObjects(withIds: newObjectsIds, withBackgroundContext: backgroundContainerViewContext)

            for coreDataObjectJson in json {

                guard let objectId = coreDataObjectJson[CoreDataObject.JsonKey.id.rawValue] as? String else {
                    continue
                }

                let coreDataObject: CoreDataObject

                if let localCoreDataObject = localObjectsInNewObjectIds.first(where: { $0.id == objectId }) {
                    coreDataObject = localCoreDataObject
                } else {
                    coreDataObject = CoreDataObject(context: backgroundContainerViewContext)
                }

                let didSetupSuccessfully = coreDataObject.setup(usingJson: coreDataObjectJson)

                if !didSetupSuccessfully {
                    backgroundContainerViewContext.delete(coreDataObject)
                    continue
                }
            }

            AppCoordinator.shared.saveBackgroundContext(with: backgroundContainerViewContext)

            deleteStaleCoreDataObjects(from: newObjectsIds, withBackgroundContext: backgroundContainerViewContext)
        }
    }
```

### Fetching stale objects for saving

```swift
private func loadStaleCoreDataObjects(from ids: [String], withBackgroundContext backgroundContext: NSManagedObjectContext) -> [CoreDataObjects] {

        let request = CoreDataObjects.createFetchRequest()
        
        let isStaleObject = NSPredicate(format: "NOT (\(CoreDataObject.JsonKey.id.rawValue) IN %@)", ids)
        request.predicate = isStaleObject

        do {
            return try backgroundContext.fetch(request)
        } catch {
            return []
        }
    }
```

### Deleting stale objects for saving

```swift
private func deleteStaleCoreDataObjects(from ids: [String], withBackgroundContext backgroundContext: NSManagedObjectContext) {

        let staleCoreDataObjects = loadStaleCoreDataObjects(from: ids, withBackgroundContext: backgroundContext)

        for coreDataObjects in staleCoreDataObjects {
            backgroundContext.delete(coreDataObjects)
        }

        AppCoordinator.shared.saveBackgroundContext(with: backgroundContext)
    }
```