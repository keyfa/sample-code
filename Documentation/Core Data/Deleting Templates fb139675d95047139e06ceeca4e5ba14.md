# Deleting Templates

### Deleting one object template

```swift
func deleteCoreDataObject(id: String) {

        let backgroundContainerViewContext = AppCoordinator.shared.backgroundContainerViewContext()

        backgroundContainerViewContext.performAndWait {

            guard let coreDataObject = loadCoreDataObject(with: id, withBackgroundContext: backgroundContainerViewContext) else {
                return
            }

            backgroundContainerViewContext.delete(coreDataObject)
            AppCoordinator.shared.saveBackgroundContext(with: backgroundContainerViewContext)
        }
    }
```