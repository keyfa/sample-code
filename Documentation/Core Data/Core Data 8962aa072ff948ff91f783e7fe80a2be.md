# Core Data

Core data is how the Pineapple project saves and caches data locally.

### ❗ Important ❗

- Make sure to delete data when fetching new data by either calling a deleteAll function or updating the old data and deleting stale data while saving. ⚠️ ************************************************The second is preferred when UI is already displaying data that was previously saved since if a user clicks on an update item between the time the item is deleted and resaved the UI may look incorrect ⚠️************************************************
- If fetching data immediately after an update, use **performAndWait** so that the data is saved before loading the data into UI
- ⚠️ **If your object has a unique id, add it as a constraint shown below ⚠️** This will stop duplicate data occurring. [see this step in object creation](https://github.com/keyfa/sample-code/blob/main/Documentation/Core%20Data/Creating%20Core%20Data%20Object%20217ba3086836451c888bdbdbb7e14696.md)

### Main Components

- `AppCoordinator.shared.containerViewContext()` : This is the main context, do all fetching of data for UI on this context
- `AppCoordinator.shared.backgroundContainerViewContext()` : This is a **new** background context, do saving/deleting of data on this context. N.B. if additional fetches/changes to data happens when using a background context, the same background context needs to be used
- `saveContext()` : Saves the main context to storage, **do this after any updates, additions or deletions**
- `saveBackgroundContext(with backgroundContext:)` : Saves the background context to storage, **do this after any updates, additions or deletions** (This automatically merges with parent)
- `backgroundContext.perform` : perform the changes to the database within the block. Runs on a private queue. ⚠️ **Use this if not waiting on the data change for UI purposes** ⚠️
- `backgroundContext.performAndWait` : perform the changes to the database within the block. Runs on the main queue. ⚠️  **Use this if waiting on the data change for UI purposes, avoid using for large changes/additions/updates** ⚠️

[Creating Core Data Object](https://github.com/keyfa/sample-code/blob/main/Documentation/Core%20Data/Creating%20Core%20Data%20Object%20217ba3086836451c888bdbdbb7e14696.md)

[Saving Templates](https://github.com/keyfa/sample-code/blob/main/Documentation/Core%20Data/Saving%20Templates%20d45bafc00b924998946e8107c8bd8e92.md)

[Fetching Templates](https://github.com/keyfa/sample-code/blob/main/Documentation/Core%20Data/Fetching%20Templates%2040b91e091b444510a6aa4ae0a5c19273.md)

[Deleting Templates](https://github.com/keyfa/sample-code/blob/main/Documentation/Core%20Data/Deleting%20Templates%20fb139675d95047139e06ceeca4e5ba14.md)

[Updating Templates](https://github.com/keyfa/sample-code/blob/main/Documentation/Core%20Data/Updating%20Templates%20e888226f569443ffbddfe6f1ee1157c2.md)
