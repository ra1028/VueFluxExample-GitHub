import UIKit
import SafariServices

final class UserViewController: UIViewController, StoryboardInitial {
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var searchTextField: TextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var rateLimitLabel: UILabel!
    @IBOutlet private weak var backgroundMarkLabel: UILabel!
    private let refreshControl = UIRefreshControl()
    
    private let store = Store<UserState>(state: .init(), mutations: .init())
    private var searchDisposable: Disposable? {
        didSet { oldValue?.dispose() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bindStore()
        refresh()
    }
}

private extension UserViewController {
    func bindStore() {
        store.computed.countText.bind(to: countLabel, \.text)
        store.computed.rateLimitText.bind(to: rateLimitLabel, \.text)
        store.computed.isBackgroundMarkHidden.bind(to: backgroundMarkLabel, \.isHidden)
        
        store.computed.refreshEnded.bind(to: refreshControl) { refreshControl, _ in
            refreshControl.endRefreshing()
        }
        
        store.computed.cellModels.signal.bind(to: tableView, on: .queue(.main)) { tableView, _ in
            tableView.reloadData()
        }
    }
    
    func configure() {
        view.backgroundColor = UIColor(background: .primaryWhite)
        headerView.backgroundColor = UIColor(key: .primaryBlack)
        refreshControl.tintColor = UIColor(background: .primaryGray)
        countLabel.textColor = UIColor(text: .primaryGray)
        rateLimitLabel.textColor = UIColor(text: .primaryGray)
        backgroundMarkLabel.textColor = UIColor(key: .primaryBlack)
        
        searchTextField.delegate = self
        searchTextField.layer.cornerRadius = 4
        searchTextField.backgroundColor = UIColor(background: .primaryGray)
        searchTextField.textColor = UIColor(text: .primaryWhite)
        searchTextField.attributedPlaceholder = "Search User".attributed(.foregroundColor(UIColor(text: .primaryGray)), .font(.boldSystemFont(ofSize: 14)))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshControl)
        tableView.register(UINib(nibName: UserCell.className, bundle: nil), forCellReuseIdentifier: UserCell.className)
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        let query = searchTextField.text
        searchDisposable = query.map(store.actions.search)
    }
}

extension UserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        refresh()
        return true
    }
}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.computed.cellModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.className, for: indexPath) as? UserCell else { fatalError() }
        let model = store.computed.cellModels.value[indexPath.row]
        cell.update(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = store.computed.cellModels.value[indexPath.row]
        let viewController = SFSafariViewController(url: model.url)
        present(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

private extension UserCell {
    static var className: String {
        return String(describing: self)
    }
}
