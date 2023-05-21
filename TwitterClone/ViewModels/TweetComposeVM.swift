//
//  TweetComposeVM.swift
//  TwitterClone
//
//  Created by Ahmet Utlu on 26.04.2023.
//

import Foundation
import Combine
import FirebaseAuth

final class TweetComposeVM: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    
    @Published var isValidToTweet = false
    @Published var error = ""
    @Published var shouldDismissComposer = false
    var tweetContent = ""
    private var user: TwitterUser?
    
    func getUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retreive: userId)
            .sink { [weak self] completion in
            guard let self else { return }
            if case .failure(let error) = completion {
                self.error = error.localizedDescription
            }
        } receiveValue: { [weak self] twitterUser in
            guard let self else { return }
            self.user = twitterUser
        }
        .store(in: &subscriptions)
    }
    
    func validateToTweet() {
        isValidToTweet = !tweetContent.isEmpty
    }
    
    func dispatchTweet() {
        guard let user else { return }
        let tweet = Tweet(author: user, authorId: user.id, tweetContent: tweetContent, likesCount: 0, likers: [], isReply: false, parentReference: nil)
        DatabaseManager.shared.collectiontweets(dipatch: tweet)
            .sink { [weak self] completion in
            guard let self else { return }
            if case .failure(let error) = completion {
                self.error = error.localizedDescription
            }
        } receiveValue: { [weak self] state in
            self?.shouldDismissComposer = state
        }
        .store(in: &subscriptions)

    }
}
