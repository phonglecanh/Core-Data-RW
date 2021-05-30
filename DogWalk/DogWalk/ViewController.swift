import UIKit
import CoreData

class ViewController: UIViewController {

  // MARK: - Properties
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()
  
  lazy var coreDataStack = CoreDataStack(modelName: "DogWalk")

  var currentDog: Dog?

  // MARK: - IBOutlets
  @IBOutlet var tableView: UITableView!


  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    let dogName = "Fido"
    let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest()
    dogFetch.predicate = NSPredicate(format: "%K == %@",
                                     #keyPath(Dog.name), dogName)
    do {
      let results = try coreDataStack.managedContext.fetch(dogFetch)
      if results.count > 0 {
        // Fido found, use Fido
        currentDog = results.first
      } else {
        // Fido not found, create Fido
        currentDog = Dog(context: coreDataStack.managedContext)
        currentDog?.name = dogName
        coreDataStack.saveContext()
      }
    } catch let error as NSError {
      print("Fetch error: \(error) description: \(error.userInfo)")
    }
  }
}

// MARK: - IBActions
extension ViewController {

  @IBAction func add(_ sender: UIBarButtonItem) {
    // Insert a new Walk entity into Core Data
    let walk = Walk(context: coreDataStack.managedContext)
    walk.date = Date()
    // Insert the new Walk into the Dog's walks set
    if let dog = currentDog,
       let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet {
      walks.add(walk)
      dog.walks = walks
    }
    // Save the managed object context
    coreDataStack.saveContext()
    // Reload table view
    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentDog?.walks?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    guard let walk = currentDog?.walks?[indexPath.row] as? Walk,
          let walkDate = walk.date as Date? else {
      return cell
    }
    cell.textLabel?.text = dateFormatter.string(from: walkDate)
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "List of Walks"
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //1
      guard let walkToRemove =
        currentDog?.walks?[indexPath.row] as? Walk,
        editingStyle == .delete else {
        return
    }
    //2
      coreDataStack.managedContext.delete(walkToRemove)
    //3
      coreDataStack.saveContext()
    //4
      tableView.deleteRows(at: [indexPath], with: .automatic)
  }
}
