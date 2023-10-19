# Updating Templates

### Updating one object template

```swift
func updateProperty(newValue: ValueType) {
        
        let backgroundContainerViewContext = AppCoordinator.shared.backgroundContainerViewContext()
        
        backgroundContainerViewContext.performAndWait {
            
            guard let coreDataObject = loadCoreDataObject(with: newValue, withBackgroundContext: backgroundContainerViewContext) else {
                return
            }
            
            coreDataObject.propertyToUpdate = newValue
            AppCoordinator.shared.saveBackgroundContext(with: backgroundContainerViewContext)
        }
    }
```