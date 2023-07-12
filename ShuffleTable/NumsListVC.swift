import UIKit

class NumsListVC: UIViewController {
    
    private lazy var data = (0...30).map { String($0) }
    
    private lazy var tableView = UITableView()
    
    private lazy var dataSource = UITableViewDiffableDataSource<Int, String>(tableView: tableView) {
        (tableView, indexPath, item) in
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell",
                                                       for: indexPath)
        cell.textLabel?.text = item
        cell.accessoryType = self.selectedCells.contains(item) ? .checkmark : .none
        
        return cell
    }
    
    private lazy var snapshot: NSDiffableDataSourceSnapshot<Int, String> = {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(data) 
        return snapshot
    }()

    private var selectedCells = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        navigationController?.navigationBar.backgroundColor = .secondarySystemBackground
        navigationItem.title = "Task 4"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleCells))
        setupView()
    }
        
    private func setupView() {
        
        view.addSubview(tableView)
        tableView.layer.cornerRadius = 8
        tableView.rowHeight = 40
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 130),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @objc func shuffleCells() {
        data.shuffle()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension NumsListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else { return }

        if selectedCells.contains(selectedItem) {
            selectedCells = selectedCells.filter { $0 != selectedItem }
            cell.accessoryType = .none
        } else {
            selectedCells.append(selectedItem)
            cell.accessoryType = .checkmark
            cell.isSelected = false
            snapshot.deleteItems([selectedItem])
            snapshot.insertItems([selectedItem], beforeItem: snapshot.itemIdentifiers.first ?? "")
            dataSource.apply(snapshot, animatingDifferences: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
