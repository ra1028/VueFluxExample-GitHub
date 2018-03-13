import UIKit

final class UserCell: UITableViewCell {
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    private var setImageDisposable: Disposable? {
        didSet { oldValue?.dispose() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func update(with model: UserCellModel) {
        nameLabel.text = model.name
        
        setImageDisposable = avatarImageView.kf.reactive.setImage(with: model.avatarUrl).observe { _ in }
    }
}

private extension UserCell {
    func configure() {
        avatarImageView.layer.cornerRadius = 4
        avatarImageView.backgroundColor = UIColor(background: .primaryGray)
        
        nameLabel.textColor = UIColor(text: .primaryBlack)
    }
}
