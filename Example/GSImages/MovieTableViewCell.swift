import Foundation
import UIKit
import GSImages

public class MovieTableViewCell: UITableViewCell {

    private var title: UILabel!
    private var subtitle: UILabel!
    private var poster: UIImageView!
    private var animator: UIViewPropertyAnimator?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        poster.image = nil
        poster.alpha = 0.0
        animator?.stopAnimation(true)
    }

    public func configure(with movie: Movie) {
        title.text = movie.title
        subtitle.text = movie.overview
        
        loadImageWithUIImageExtension(for: movie)
    }

    private func showImage(image: UIImage?) {
        poster.alpha = 0.0
        animator?.stopAnimation(false)
        poster.image = image
        animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.poster.alpha = 1.0
        })
    }
    
    private func loadImageWithRepository(for movie: Movie) {
        guard
            let url = URL(string: movie.poster)
        else {
            return
        }
        
        GSImagesRepository
            .shared
            .loadImage(
                from: url
            ).done { image in
                self.showImage(image: image)
            }.catch { error in
                print(error)
            }
    }
    
    private func loadImageWithUIImageExtension(for movie: Movie) {
        guard
            let url = URL(string: movie.poster)
        else {
            return
        }
        
        poster.alpha = 0.0
        animator?.stopAnimation(false)
        poster.setImage(
            from: url
        ) { [weak self] image in
            self?.animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                self?.poster.alpha = 1.0
            })
        }
    }

    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        poster = UIImageView()
        stackView.addArrangedSubview(poster)
        NSLayoutConstraint.activate([
            poster.widthAnchor.constraint(equalToConstant: 60),
            poster.heightAnchor.constraint(equalToConstant: 100)
        ])

        title = UILabel()
        title.font = .boldSystemFont(ofSize: 14)
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping

        subtitle = UILabel()
        subtitle.font = .systemFont(ofSize: 14)
        subtitle.numberOfLines = 3
        subtitle.lineBreakMode = .byTruncatingTail

        let textStackView = UIStackView()
        textStackView.axis = .vertical
        textStackView.distribution = .equalSpacing
        textStackView.alignment = .leading
        textStackView.spacing = 4
        textStackView.addArrangedSubview(title)
        textStackView.addArrangedSubview(subtitle)
        stackView.addArrangedSubview(textStackView)
    }
}
