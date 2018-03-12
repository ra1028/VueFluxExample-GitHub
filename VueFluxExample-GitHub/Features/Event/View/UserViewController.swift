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
    private let loadDebouncer = Debouncer(on: .global())
    private var loadDisposable: Disposable? {
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
        
        store.computed.cellModelChanges
            .observe(on: .mainThread)
            .observe(duringScopeOf: self) { [unowned self] changes in
                self.tableView.reloadWithoutAnimation(changes: changes) { [weak self] _ in
                    self?.store.actions.reloadCompleted()
                }
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
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: .searchUser,
            attributes: .foregroundColor(UIColor(text: .primaryGray)), .font(.boldSystemFont(ofSize: 14))
        )
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshControl)
        tableView.register(cellType: UserCell.self)
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        searchTextField.addTarget(self, action: #selector(refresh), for: .allEditingEvents)
    }
    
    @objc func refresh() {
        let query = searchTextField.text
        loadDebouncer.debounce(interval: 0.2) { [weak self] in
            guard let `self` = self else { return }
            self.loadDisposable = query.map(self.store.actions.search)
        }
    }
}

extension UserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UserViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.computed.cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: UserCell.self)
        let model = store.computed.cellModels[indexPath.row]
        cell.update(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = store.computed.cellModels[indexPath.row]
        let viewController = SFSafariViewController(url: model.url)
        present(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGFloat = 40
        let height = scrollView.frame.height
        let contentHeight = scrollView.contentSize.height
        let y = scrollView.contentOffset.y
        let threshold = max(0, contentHeight - height - offset)
        let isOverThreshold = contentHeight >= height && contentHeight > offset && y >= threshold
        
        if isOverThreshold && store.computed.isLoadMoreEnabled {
            let query = searchTextField.text
            let nextPage = store.computed.currentPage + 1
            loadDisposable = query.map { store.actions.loadMore(query: $0, nextPage: nextPage) }
        }
    }
}
