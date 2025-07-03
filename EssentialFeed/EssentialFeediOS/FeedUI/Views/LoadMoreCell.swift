//
//  EssentialFeed
//
//  Created by Mykola Dementiev
//

import UIKit

public class LoadMoreCell: UITableViewCell {
	private lazy var spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView(style: .medium)
		contentView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
        ])
        
		return spinner
	}()
    
    private lazy var mesageLabel: UILabel = {
        let mesageLabel = UILabel()
        mesageLabel.textColor = .tertiaryLabel
        mesageLabel.font = .preferredFont(forTextStyle: .footnote)
        mesageLabel.numberOfLines = 0
        mesageLabel.textAlignment = .center
        mesageLabel.adjustsFontForContentSizeCategory = true
        
        contentView.addSubview(mesageLabel)
        mesageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mesageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            contentView.trailingAnchor.constraint(equalTo: mesageLabel.trailingAnchor, constant: 8),
            mesageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: mesageLabel.bottomAnchor, constant: 8)
        ])
        
        return mesageLabel
    }()
    
    public var isLoading: Bool {
        get { spinner.isAnimating }
        set {
            if newValue {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }
    
    public var message: String? {
        get { mesageLabel.text }
        set { mesageLabel.text = newValue }
    }
}
