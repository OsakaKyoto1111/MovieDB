//
//  FavoriteViewController.swift
//  MovieDB-CSS214
//
//  Created by Ерош Айтжанов on 10.11.2025.
//

import UIKit
import CoreData

class FavoriteViewController: UIViewController {
let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext
    lazy var startLabel: UILabel = {
        let label = UILabel()
        label.text = "Add favorite movies"
        label.textAlignment = .center
        label.alpha = 0.5
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var movieTableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MovieTableViewCell.self, forCellReuseIdentifier: "favorite")
        return table
    }()

    var movieData: [Result] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Favorites"
        navigationItem.largeTitleDisplayMode = .automatic

        setupUI()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFromCoreData()
        movieTableView.reloadData()
    }

    func setupUI() {
        view.addSubview(movieTableView)
        view.addSubview(startLabel)
        movieTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        startLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

func loadFromCoreData() {
    do {
        let favorites = try context.fetch(Favorite.fetchRequest()) as! [Favorite]

        movieData = favorites.map {
            Result(
                id: Int($0.movieID),
                posterPath: $0.posterPath,
                title: $0.title,
                voteAverage: $0.voteAverage
            )
        }

        if movieData.isEmpty {
            movieTableView.alpha = 0
            startLabel.alpha = 0.5
        } else {
            startLabel.alpha = 0
            movieTableView.alpha = 1
        }

        movieTableView.reloadData()
    } catch {
        print("error loadFromCoreData: \(error)")
    }
}




}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "favorite", for: indexPath) as! MovieTableViewCell
        let movie = movieData[indexPath.row]
        cell.conf(movie: movie)
        cell.method = { [weak self] in
            self!.loadFromCoreData()
            self!.movieTableView.reloadData()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movieDetailVC = MovieDetailViewController()
        let movieID = movieData[indexPath.row].id!
        movieDetailVC.movieID = movieID
        NetworkManager.shared.loadVideo(movieID: movieID) { result in
            let trailer = result.first(where: { $0.type == "Trailer" }) ?? result.first!
            movieDetailVC.trailerKey = trailer.key!
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(movieDetailVC, animated: true)
            }
        }
    }
}
