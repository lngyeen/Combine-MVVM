//
//  LoginViewModel.swift
//  Combine-MVVM
//
//  Created by Nguyen Truong Luu on 12/28/21.
//

import Combine
import Foundation
import UIKit

final class LoginViewModel {
    enum State {
        case loggedIn(user: User)
        case initial
        case error(message: String)
    }
    
    enum Action {
        case clear
        case login
    }
    
    let state = CurrentValueSubject<State, Never>(.initial)
    
    let action = PassthroughSubject<Action, Never>()
    
    // MARK: - Properties

    // Subscriptions
    var subscriptions = [AnyCancellable]()
    
    private var user: User?
    
    // Publisher & store
    @Published var username: String?
    @Published var password: String?
    @Published var isLoading: Bool = false
    
    var validateInputs: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($username, $password)
            .map { !($0!.isEmpty || $1!.isEmpty) }
            .eraseToAnyPublisher()
    }
    
    var loginEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(validateInputs, $isLoading)
            .map { $0 && !$1 }
            .eraseToAnyPublisher()
    }
    
    init(username: String?, password: String?) {
        self.username = username
        self.password = password
        
        // action binding
        action.sink { [weak self] action in
            self?.processAction(action)
        }.store(in: &subscriptions)
        
        // state binding
        state.sink { [weak self] state in
            self?.processState(state)
        }.store(in: &subscriptions)
    }
    
    private func clear() {
        self.username = ""
        self.password = ""
    }
    
    // MARK: - Private functions

    // process Action
    private func processAction(_ action: Action) {
        switch action {
        case .login:
            login()
                .sink { [weak self] user in
                    if let user = user {
                        self?.state.value = .loggedIn(user: user)
                    } else {
                        self?.state.value = .error(message: "Login failed.")
                    }
                }
                .store(in: &subscriptions)
            
        case .clear:
            clear()
        }
    }
    
    private func processState(_ state: State) {
        switch state {
        case .loggedIn(let user):
            isLoading = false
            
        case .initial:
            isLoading = false
            
        case .error(let message):
            isLoading = false
        }
    }
    
    private func login() -> AnyPublisher<User?, Never> {
        isLoading = true
        
        // test
        var user: User?
        if let username = username,
           let password = password,
           username == "admin", password == "123456"
        {
            user = User(username: username, password: password)
        }
        
        let subject = CurrentValueSubject<User?, Never>(user)
        return subject
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
