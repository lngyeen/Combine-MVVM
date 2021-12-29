//
//  HomeViewController.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/28/21.
//

import Combine
import Reusable
import UIKit
import MBProgressHUD
import Foundation

class HomeViewController: BaseViewController {
    // Outlets
    @IBOutlet var tableView: UITableView!
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        return refreshControl
    }()
    
    // ViewModel
    let viewModel: HomeViewModelProtocol = HomeViewModel()
  
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    // MARK: - Config View

    // MARK: Setup

    override func setupData() {
        super.setupData()
    
        // fetchData
        viewModel.inputs.fetchData.send(())
    }
  
    override func setupUI() {
        super.setupUI()
    
        title = "Home"
    
        // tableview
        tableView.register(cellType: MusicCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        
        // Navigation Bar
        let clearBarButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(reset))
        navigationItem.rightBarButtonItem = clearBarButton
    }
  
    // MARK: Binding

    override func bindingToView() {
        // musics
        viewModel
            .outputs
            .musicsPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &subscriptions)
    
        // cell
        viewModel
            .outputs
            .reloadCell
            .receive(on: RunLoop.main)
            .sink { [weak self] indexPath in
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
            .store(in: &subscriptions)
        
        // isLoading
        viewModel.isLoadingPublisher.sink { isLoading in
            if isLoading {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }.store(in: &subscriptions)
        
        // error
        viewModel.outputs.error.receive(on: RunLoop.main).sink { [weak self] message in
            _ = self?.alert(title: "HOME", text: message)
        }.store(in: &subscriptions)
    }
  
    override func bindingToViewModel() {}
  
    // MARK: Router

    override func router() {
        
    }
  
    // MARK: - Private functions

    @objc func reset() {
        viewModel.inputs.reset.send(())
    }
}

// MARK: - UITableView Delegate

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows(in: section)
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MusicCell = tableView.dequeueReusableCell(for: indexPath)
        let musicViewModel = viewModel.music(at: indexPath)
        cell.musicViewModel = musicViewModel
        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
