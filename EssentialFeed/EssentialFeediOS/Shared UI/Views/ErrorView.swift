//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import UIKit

public final class ErrorView: UIControl {
    public var onHide: (() -> Void)?
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 17)
        label.isUserInteractionEnabled = false
        
        return label
    }()
    
    private lazy var bottomConstraint: NSLayoutConstraint = {
        bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: .zero)
    }()
    
    private lazy var topConstraint: NSLayoutConstraint = {
        label.topAnchor.constraint(equalTo: topAnchor, constant: .zero)
    }()

    public var message: String? {
        get { isVisible ? label.text : nil }
        set { setMessageAnimated(newValue) }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        hideMessage()
    }
    
    private var isVisible: Bool {
        alpha > 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }

    private func showAnimated(_ message: String) {
        label.text = message
        topConstraint.constant = 8
        bottomConstraint.constant = 8
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @objc
    func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.hideMessage() }
            })
    }
    
    private func hideMessage() {
        label.text = nil
        topConstraint.constant = .zero
        bottomConstraint.constant = .zero
        alpha = .zero
        onHide?()
    }
    
    private func configure() {
        backgroundColor = .errorBackgroundColor
        configureLabel()
        hideMessage()
        
        self.addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
    }
    
    private func configureLabel() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
         NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            topConstraint,
            bottomConstraint
        ])
        
    }
}

extension UIColor {
    static var errorBackgroundColor = UIColor(
        red: 0.99951404330000004,
        green: 0.41759261489999999,
        blue: 0.4154433012,
        alpha: 1
    )
}
