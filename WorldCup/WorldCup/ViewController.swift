import UIKit
import CoreData

class ViewController: UIViewController {

  // MARK: - Properties
  var dataSource: UITableViewDiffableDataSource<String, Team>?
  fileprivate let teamCellIdentifier = "teamCellReuseIdentifier"
  lazy var  coreDataStack = CoreDataStack(modelName: "WorldCup")
  lazy var fetchedResultsController:
    NSFetchedResultsController<Team> = {
      //1
      let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
      let zoneSort = NSSortDescriptor(
        key: #keyPath(Team.qualifyingZone), ascending: true)
      let scoreSort = NSSortDescriptor(
        key: #keyPath(Team.wins), ascending: false)
      let nameSort = NSSortDescriptor(
        key: #keyPath(Team.teamName), ascending: true)
      fetchRequest.sortDescriptors = [zoneSort, scoreSort, nameSort]
      //2
      let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: #keyPath(Team.qualifyingZone), cacheName: "worldCup")
      fetchedResultsController.delegate = self
      return fetchedResultsController
    }()
  
  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var addButton: UIBarButtonItem!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    importJSONSeedDataIfNeeded()
    dataSource = setupDataSource()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIView.performWithoutAnimation {
      do {
        try fetchedResultsController.performFetch()
      } catch let error as NSError {
        print("Fetching error: \(error), \(error.userInfo)")
      }
    }
  }
  
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      addButton.isEnabled = true
    }
  }
}

// MARK: - IBActions
extension ViewController {
  @IBAction func addTeam(_ sender: Any) {
    let alertController = UIAlertController(
      title: "Secret Team",
      message: "Add a new team",
      preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.placeholder = "Team Name"
    }
    alertController.addTextField { textField in
      textField.placeholder = "Qualifying Zone"
    }
    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) {
  [unowned self] action in
    guard
      let nameTextField = alertController.textFields?.first,
      let zoneTextField = alertController.textFields?.last
      else {
  return
    }
    let team = Team(
      context: self.coreDataStack.managedContext)
    team.teamName = nameTextField.text
    team.qualifyingZone = zoneTextField.text
    team.imageName = "wenderland-flag"
    self.coreDataStack.saveContext()
  }
  alertController.addAction(saveAction)
  alertController.addAction(UIAlertAction(title: "Cancel",
                                          style: .cancel))
      present(alertController, animated: true)
     
    }
  }


// MARK: - Internal
extension ViewController {

  func configure(cell: UITableViewCell, for indexPath: IndexPath) {

    guard let cell = cell as? TeamCell else {
      return
    }

    let team = fetchedResultsController.object(at: indexPath)
    cell.teamLabel.text = team.teamName
    cell.scoreLabel.text = "Wins: \(team.wins)"
    
    if let imageName = team.imageName {
      cell.flagImageView.image = UIImage(named: imageName)
    } else {
      cell.flagImageView.image = nil
    }
  }
  
  func setupDataSource()
    -> UITableViewDiffableDataSource<String, Team> {
      return UITableViewDiffableDataSource(tableView: tableView) {
        [unowned self] (tableView, indexPath, team)
        -> UITableViewCell? in
        let cell = tableView.dequeueReusableCell(
          withIdentifier: self.teamCellIdentifier,
          for: indexPath)
        self.configure(cell: cell, for: indexPath)
  return cell
        
      }
  }
}

// MARK: - UITableViewDataSource


// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let team = fetchedResultsController.object(at: indexPath)
    team.wins = team.wins + 1
    coreDataStack.saveContext()
    let cell = tableView.cellForRow(at: indexPath) as! TeamCell
    configure(cell: cell, for: indexPath)
  }
  
  func tableView(_ tableView: UITableView,
                 viewForHeaderInSection section: Int) -> UIView? {
    let sectionInfo = fetchedResultsController.sections?[section]
    let titleLabel = UILabel()
    titleLabel.backgroundColor = .white
    titleLabel.text = sectionInfo?.name
    return titleLabel
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int)
  -> CGFloat {
    return 20
    
  }
}


// MARK: - Helper methods
extension ViewController {

  func importJSONSeedDataIfNeeded() {

    let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
    let count = try? coreDataStack.managedContext.count(for: fetchRequest)

    guard let teamCount = count,
      teamCount == 0 else {
        return
    }

    importJSONSeedData()
  }

  func importJSONSeedData() {

    let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
    let jsonData = try! Data(contentsOf: jsonURL)

    do {
      let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [[String: Any]]

      for jsonDictionary in jsonArray {
        let teamName = jsonDictionary["teamName"] as! String
        let zone = jsonDictionary["qualifyingZone"] as! String
        let imageName = jsonDictionary["imageName"] as! String
        let wins = jsonDictionary["wins"] as! NSNumber

        let team = Team(context: coreDataStack.managedContext)
        team.teamName = teamName
        team.imageName = imageName
        team.qualifyingZone = zone
        team.wins = wins.int32Value
      }

      coreDataStack.saveContext()
      print("Imported \(jsonArray.count) teams")

    } catch let error as NSError {
      print("Error importing teams: \(error)")
    }
  }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
  func controller(
    _ controller:
    NSFetchedResultsController<NSFetchRequestResult>,
    didChangeContentWith
    snapshot: NSDiffableDataSourceSnapshotReference) {
  //1
    var diff = NSDiffableDataSourceSnapshot<String, Team>()
    snapshot.sectionIdentifiers.forEach { section in
      //2
          diff.appendSections([section as! String])
      //3
          let items =
            snapshot.itemIdentifiersInSection(withIdentifier: section)
            .map { (objectId: Any) -> Team in
              let oid =  objectId as! NSManagedObjectID
              return controller
                .managedObjectContext
                .object(with: oid) as! Team
          }
          diff.appendItems(items, toSection: section as? String)
        }
      //4
        dataSource?.apply(diff)
      }
}
