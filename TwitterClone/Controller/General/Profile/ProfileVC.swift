//
//  ProfileVC.swift
//  TwitterClone
//
//  Created by Ahmet Utlu on 10.04.2023.
//

import UIKit
import Combine
import SDWebImage

class ProfileVC: UIViewController {
    private let viewModel = ProfileVM()
    private var isStatusBarHidden = true
    private var subscriptions : Set<AnyCancellable> = []

    
    private lazy var statusbar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.opacity = 0
        
        return view
    }()
    
    private lazy var headerView = ProfileTableViewHeader(frame: CGRect(x: 0, y: 0, width: profileTableView.frame.width, height: 380))
    
    private lazy var profileTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        navigationController?.navigationBar.isHidden = true
        profileTableView.contentInsetAdjustmentBehavior = .never
        view.addSubview(profileTableView)
        view.addSubview(statusbar)
        
        profileTableView.tableHeaderView = headerView
        
        configureConstraints()
        bindViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.retreiveUser()
    }
    
    private func configureConstraints() {
        let statusbarConstraint = [
            statusbar.topAnchor.constraint(equalTo: view.topAnchor),
            statusbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusbar.heightAnchor.constraint(equalToConstant: view.bounds.height > 800 ? 40 : 20)
        ]
        
        let profileTableViewConstraint = [
            profileTableView.topAnchor.constraint(equalTo: view.topAnchor),
            profileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
                
        NSLayoutConstraint.activate(statusbarConstraint)
        NSLayoutConstraint.activate(profileTableViewConstraint)
    }
    
    private func bindViews() {
        viewModel.$user.sink { [weak self] user in
            guard let self,
                  let user else { return }
            self.headerView.displayNameLabel.text = user.displayName
            self.headerView.usernameLabel.text = user.username
            self.headerView.followersCountLabel.text = "\(user.followersCount)"
            self.headerView.followingCountLabel.text = "\(user.followingCount)"
            self.headerView.userBioLabel.text = user.bio
            self.headerView.profileAvatarImageView.sd_setImage(with: URL(string: user.avatarPath))
            self.headerView.joinedDateLabel.text = "Joined \(self.viewModel.getFormattedDate(with: user.createdOn))"
        }
        .store(in: &subscriptions)
    }
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = profileTableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as! TweetTableViewCell
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yPosition = scrollView.contentOffset.y
        
        if yPosition > 150 && isStatusBarHidden {
            UIView.animate(withDuration: 0.3, delay: 0) { [weak self] in
                guard let self else { return }
                self.isStatusBarHidden = false
                self.statusbar.layer.opacity = 1
            }
        } else if yPosition < 0 && !isStatusBarHidden {
            UIView.animate(withDuration: 0.3, delay: 0) { [weak self] in
                guard let self else { return }
                self.isStatusBarHidden = true
                self.statusbar.layer.opacity = 0
            }
        }
    }
}
