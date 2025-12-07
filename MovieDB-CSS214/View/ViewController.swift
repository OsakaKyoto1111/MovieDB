//
//  ViewController.swift
//  MovieDB-CSS214
//
//  Created by Ерош Айтжанов on 06.10.2025.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var movieLabel: UILabel = {
        let label = UILabel()
        label.text = "MovieDB"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    lazy var movieTableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(MovieTableViewCell.self, forCellReuseIdentifier: "movie")
        
        table.separatorStyle = .none
        table.alpha = 0

        return table
    }()
    
    var movieData: [Result] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        animateTitle()
    }

    private func setupUI() {
        view.addSubview(movieLabel)
        view.addSubview(movieTableView)
        
        movieLabel.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
        
        movieTableView.snp.makeConstraints { make in
            make.top.equalTo(movieLabel.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
       private func animateTitle() {
        UIView.animate(withDuration: 1) {
            self.movieLabel.alpha = 1
        } completion: { _ in
            
            UIView.animate(withDuration: 0.3) {
                self.movieLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            } completion: { _ in
                
                UIView.animate(
                    withDuration: 1,
                    delay: 0.1,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 1
                ) {
                    self.movieLabel.snp.remakeConstraints { make in
                        make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                        make.centerX.equalTo(self.view.safeAreaLayoutGuide)
                    }
                    
                    self.view.layoutIfNeeded()
                    self.movieLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                } completion: { _ in
                    self.apiRequest()
                    UIView.animate(withDuration: 0.5) {
                        self.movieTableView.alpha = 1
                    }
                }
            }
        }
    }

    
    func apiRequest() {
        NetworkManager.shared.loadMovie { result in
            self.movieData = result
            self.movieTableView.reloadData()
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "movie", for: indexPath) as! MovieTableViewCell
        let movie = movieData[indexPath.row]
        cell.conf(movie: movie)

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
