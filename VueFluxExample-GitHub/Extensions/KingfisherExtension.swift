import UIKit
import Kingfisher

extension Kingfisher: ReactiveCompatible {}

extension Reactive where Base: Kingfisher<UIImageView> {
    func setImage(
        with url: URL?,
        placeholder: UIImage? = nil,
        options: KingfisherOptionsInfo? = [.transition(.fade(0.2))]
        ) -> Signal<Result<(), AnyError>> {
        return .init { [base = self.base] send in
            let task = base.setImage(
                with: url,
                placeholder: placeholder,
                options: options,
                completionHandler: { _, error, _, _ in
                    if let error = error {
                        return send(.failure(AnyError(error)))
                    }
                    
                    send(.success(()))
            })
            
            return AnyDisposable(task.cancel)
        }
    }
}
