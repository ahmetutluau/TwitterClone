//
//  ProfileDataFormVM.swift
//  TwitterClone
//
//  Created by Ahmet Utlu on 17.04.2023.
//

import UIKit
import Combine
import FirebaseStorage
import Firebase

final class ProfileDataFormVM: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    @Published var displayName: String?
    @Published var username: String?
    @Published var bio: String?
    @Published var avatarPath: String?
    @Published var imageData: UIImage?
    @Published var isFormValid: Bool = false
    @Published var error: String = ""
    @Published var isOnboardingFinished = false
    
    func validateUserProfileForm() {
        guard let displayName = displayName,
              displayName.count > 2,
              let username = username,
              username.count > 2,
              let bio = bio,
              bio.count > 2,
              imageData != nil else {
            isFormValid = false
            return
        }
        isFormValid = true
    }
    
    func uploadAvatar() {
            let randomID = UUID().uuidString
            guard let imageData = imageData?.jpegData(compressionQuality: 0.5) else { return }
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            StorageManager.shared.uploadProfilePhoto(with: randomID, image: imageData, metaData: metaData)
                .flatMap({ metaData in
                    StorageManager.shared.getDownloadURL(for: metaData.path)
                })
                .sink { [weak self] completion in
                    guard let self else { return }
                    switch completion {
                    case .failure(let error):
                        self.error = error.localizedDescription
                    case .finished:
                        self.updateUserData()
                    }
                } receiveValue: { [weak self] url in
                    guard let self else { return }
                    self.avatarPath = url.absoluteString
                }
                .store(in: &subscriptions)
        }
        
    func updateUserData() {
        guard let displayName,
              let username,
              let bio,
              let avatarPath,
              let id = Auth.auth().currentUser?.uid else { return }
        
        let userFields: [String: Any] = [
            "displayName": displayName,
            "username": username,
            "bio": bio,
            "avatarPath": avatarPath,
            "isUserOnboarded": true
        ]
        
        DatabaseManager.shared.collectionUsers(updateFields: userFields, for: id).sink { [weak self] completion in
            guard let self else { return }
            if case .failure(let error) = completion {
                print(error.localizedDescription)
                self.error = error.localizedDescription
            }
        } receiveValue: { [weak self] onboardingState in
            guard let self else { return }
            self.isOnboardingFinished = onboardingState
        }
        .store(in: &subscriptions)

    }
}
