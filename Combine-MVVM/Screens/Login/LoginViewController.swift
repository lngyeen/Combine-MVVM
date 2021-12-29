//
//  LoginViewController.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/28/21.
//

import UIKit
import Combine

class LoginViewController: BaseViewController {
    // Outlet
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    // MARK: - Properies

    let viewModel = LoginViewModel(username: "", password: "")
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Configuration

    override func setupData() {}
    
    override func setupUI() {}
    
    override func bindingToView() {
        viewModel
            .$username
            .assign(to: \.text, on: usernameTextField)
            .store(in: &subscriptions)
        
        viewModel
            .$password
            .assign(to: \.text, on: passwordTextField)
            .store(in: &subscriptions)
        
        viewModel
            .loginEnabled
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &subscriptions)
   
        viewModel.$isLoading
            .sink(receiveValue: { [indicatorView] isLoading in
                if isLoading {
                    indicatorView?.startAnimating()
                } else {
                    indicatorView?.stopAnimating()
                }
            })
            .store(in: &subscriptions)
    }
    
    override func bindingToViewModel() {
        usernameTextField
            .publisher
            .assign(to: \.username, on: viewModel)
            .store(in: &subscriptions)
        
        passwordTextField
            .publisher
            .assign(to: \.password, on: viewModel)
            .store(in: &subscriptions)
    }
    
    // MARK: - Navigation

    override func router() {
        // viewmodel State
        viewModel.state
            .sink { [weak self] state in
                switch state {
                case .loggedIn(let user):
                     let homeVC = HomeViewController()
                     self?.navigationController?.pushViewController(homeVC, animated: true)
                    
                case .error(let message):
                     _ = self?.alert(title: App.Text.appName, text: message)
                    
                     default: break
                }
                
            }.store(in: &subscriptions)
    }
    
    // MARK: - Actions

    @IBAction func loginButtonTouchUpInside(_ sender: Any) {
        viewModel.action.send(.login)
    }
    
    @IBAction func clearButtonTouchUpInside(_ sender: Any) {
        viewModel.action.send(.clear)
    }
}
