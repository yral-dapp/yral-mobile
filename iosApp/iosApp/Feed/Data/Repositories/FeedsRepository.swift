//
//  FeedsRepository.swift
//  iosApp
//
//  Created by Sarvesh Sharma on 15/12/24.
//  Copyright © 2024 orgName. All rights reserved.
//
import Foundation

class FeedsRepository: FeedRepositoryProtocol {
  private let httpService: HTTPService
  private let mlClient: MlFeed_MLFeedNIOClient
  private let authClient: AuthClient

  init(httpService: HTTPService, mlClient: MlFeed_MLFeedNIOClient, authClient: AuthClient) {
    self.httpService = httpService
    self.mlClient = mlClient
    self.authClient = authClient
  }

  func fetchFeed(request: FeedRequest) async -> Result<[FeedResult], Error> {
    var mlRequest = MlFeed_FeedRequest()
    mlRequest.canisterID = authClient.principalString ?? ""
    mlRequest.filterPosts = request.filteredPosts
    mlRequest.numResults = UInt32(request.numResults)
    do {
      let response = try await mlClient.get_feed_clean(
        mlRequest
      ).response.get()
      let feeds = try await response.feed.asyncMap { feed in
        let principal = try get_principal(feed.canisterID)
        do {
          let identity = try self.authClient.generateNewDelegatedIdentity()
          let service = try Service(principal, identity)
          let result = try await service.get_individual_post_details_by_id(UInt64(feed.postID))
          let videoURL = URL(
            string: "\(Constants.cloudfarePrefix)\(result.video_uid().toString())\(Constants.cloudflareSuffix)"
          ) ?? URL(fileURLWithPath: "")
          let thumbnailURL = URL(
            string: "\(Constants.cloudfarePrefix)\(result.video_uid().toString())\(Constants.thumbnailSuffix)"
          ) ?? URL(fileURLWithPath: "")
          let urlString = result.created_by_profile_photo_url()?.toString()
          return FeedResult(
            postID: String(feed.postID),
            videoID: result.video_uid().toString(),
            canisterID: feed.canisterID,
            url: videoURL,
            thumbnail: thumbnailURL,
            postDescription: result.description().toString(),
            profileImageURL: urlString != nil ? URL(string: urlString!) : nil,
            likeCount: Int(result.like_count()),
            isLiked: result.liked_by_me()
          )
        }
      }
      return .success(feeds)
    } catch {
      return .failure(error)
    }
  }

  func toggleLikeStatus(for postId: Int) async -> Result<Bool, Error> {
    do {
      let identity = try self.authClient.generateNewDelegatedIdentity()
      guard let principal = authClient.principal else {
        return .failure(AuthError.authenticationFailed("Authentication failed"))
      }
      let service = try Service(principal, identity)
      let result = try await service.update_post_toggle_like_status_by_caller(1)
      return .success(result)
    } catch {
      return .failure(error)
    }
  }
}

extension FeedsRepository {
  enum Constants {
    static let cloudfarePrefix = "https://customer-2p3jflss4r4hmpnz.cloudflarestream.com/"
    static let cloudflareSuffix = "/manifest/video.m3u8"
    static let thumbnailSuffix = "/thumbnails/thumbnail.jpg"

  }
}
