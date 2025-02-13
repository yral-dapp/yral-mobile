//
//  FeedDIContainer.swift
//  iosApp
//
//  Created by Sarvesh Sharma on 15/12/24.
//  Copyright © 2024 orgName. All rights reserved.
//
import Foundation

final class FeedDIContainer {
  struct Dependencies {
    let mlfeedService: MlFeed_MLFeedNIOClient
    let httpService: HTTPService
    let authClient: AuthClient
  }

  private let dependencies: Dependencies

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }

  func makeFeedsViewControllerWrapper() -> FeedsViewControllerWrapper {
    FeedsViewControllerWrapper(feedsViewController: FeedsViewController(viewModel: makeFeedsViewModel()))
  }

  func makeFeedsViewModel() -> FeedsViewModel {
    let feedRepository = makeFeedsRepository()
    return FeedsViewModel(
      fetchFeedsUseCase: FetchInitialFeedsUseCase(feedRepository: feedRepository),
      moreFeedsUseCase: FetchMoreFeedsUseCase(feedRepository: feedRepository),
      likeUseCase: ToggleLikeUseCase(feedRepository: feedRepository)
    )
  }

  func makeFeedsRepository() -> FeedsRepository {
    FeedsRepository(
      httpService: dependencies.httpService,
      mlClient: dependencies.mlfeedService,
      authClient: dependencies.authClient
    )
  }
}
