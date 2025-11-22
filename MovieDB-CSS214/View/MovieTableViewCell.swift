//
//  MovieTableViewCell.swift
//  MovieDB-CSS214
//
//  Created by Ерош Айтжанов on 06.10.2025.
//

import UIKit
import CoreData

class MovieTableViewCell: UITableViewCell {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext
    lazy var movieImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 30
        image.clipsToBounds = true
        return image
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    lazy var movieTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()

    private lazy var favoriteImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "heart")
        return image
    }()

    private var isFavorite: Bool = false {
        didSet {
            favoriteImage.image = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        }
    }

    private var movie: Result?
    var method: (()->Void)? = nil

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImage.image = nil
        movieTitle.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func conf(movie: Result) {
        self.movie = movie

        self.movieImage.image = nil
        activityIndicator.startAnimating()

        NetworkManager.shared.loadImage(posterPath: movie.posterPath!) { data in
            self.movieImage.image = UIImage(data: data)
            self.activityIndicator.stopAnimating()
        }
        movieTitle.text = movie.title

        loadFavorite(movie: movie)
    }

    func setupUI() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(movieImage)
        movieImage.addSubview(favoriteImage)
        movieImage.addSubview(activityIndicator)
        stackView.addArrangedSubview(movieTitle)

        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }

        movieImage.snp.makeConstraints { make in
            make.height.equalTo(484)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide.snp.trailing).offset(-15)
            make.leading.equalToSuperview().offset(15)
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(movieImage)
        }

        favoriteImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(50)
            make.width.equalTo(60)
        }

        favoriteImage.isUserInteractionEnabled = true
        movieImage.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        favoriteImage.addGestureRecognizer(tap)
    }

    @objc func tap() {
        guard let movie else { return }
        if isFavorite {
            deleteFavorite(movie: movie)
        } else {
            saveFavorite(movie: movie)
        }

        isFavorite.toggle()
        if let method {
            method()
        }
    }

 func saveFavorite(movie: Result) {
    let favorite = Favorite(context: context)
    favorite.movieID = Int64(movie.id ?? 0)
    favorite.posterPath = movie.posterPath
    favorite.title = movie.title
    favorite.voteAverage = movie.voteAverage ?? 0.0

    (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
}

func deleteFavorite(movie: Result) {
    let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
    request.predicate = NSPredicate(format: "movieID == %d", movie.id ?? 0)

    do {
        let favorites = try context.fetch(request)
        if let objectToDelete = favorites.first {
            context.delete(objectToDelete)
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        }
    } catch {
        print("Error deleting favorite: \(error)")
    }
}

    func loadFavorite(movie: Result) {
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.predicate = NSPredicate(format: "movieID == %d", movie.id ?? 0)

        do {
            let favorites = try context.fetch(request)
            isFavorite = !favorites.isEmpty
        } catch {
            print("Error loading favorite: \(error)")
            isFavorite = false
        }
    }





}
