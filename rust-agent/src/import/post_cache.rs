// This is an experimental feature to generate Rust binding from Candid.
// You may want to manually adjust some of the types.
#![allow(dead_code, unused_imports)]
use candid::{self, CandidType, Deserialize, Principal, Encode, Decode};
type Result<T> = std::result::Result<T, ic_agent::AgentError>;

#[derive(CandidType, Deserialize)]
pub enum KnownPrincipalType {
  CanisterIdUserIndex,
  CanisterIdPlatformOrchestrator,
  CanisterIdConfiguration,
  CanisterIdProjectMemberIndex,
  CanisterIdTopicCacheIndex,
  CanisterIdRootCanister,
  CanisterIdDataBackup,
  CanisterIdPostCache,
  #[serde(rename="CanisterIdSNSController")]
  CanisterIdSnsController,
  CanisterIdSnsGovernance,
  UserIdGlobalSuperAdmin,
}
#[derive(CandidType, Deserialize)]
pub struct PostCacheInitArgs {
  pub known_principal_ids: Option<Vec<(KnownPrincipalType,Principal,)>>,
  pub version: String,
  pub upgrade_version_number: Option<u64>,
}
#[derive(CandidType, Deserialize)]
pub enum PostStatus {
  BannedForExplicitness,
  BannedDueToUserReporting,
  Uploaded,
  CheckingExplicitness,
  ReadyToView,
  Transcoding,
  Deleted,
}
#[derive(CandidType, Deserialize)]
pub enum NsfwFilter { IncludeNsfw, OnlyNsfw, ExcludeNsfw }
#[derive(CandidType, Deserialize)]
pub struct SystemTime { pub nanos_since_epoch: u32, pub secs_since_epoch: u64 }
#[derive(CandidType, Deserialize)]
pub struct PostScoreIndexItemV1 {
  pub is_nsfw: bool,
  pub status: PostStatus,
  pub post_id: u64,
  pub created_at: Option<SystemTime>,
  pub score: u64,
  pub publisher_canister_id: Principal,
}
#[derive(CandidType, Deserialize)]
pub enum TopPostsFetchError {
  ReachedEndOfItemsList,
  InvalidBoundsPassed,
  ExceededMaxNumberOfItemsAllowedInOneRequest,
}
#[derive(CandidType, Deserialize)]
pub enum Result_ { Ok(Vec<PostScoreIndexItemV1>), Err(TopPostsFetchError) }
#[derive(CandidType, Deserialize)]
pub struct HttpRequest {
  pub url: String,
  pub method: String,
  pub body: serde_bytes::ByteBuf,
  pub headers: Vec<(String,String,)>,
}
#[derive(CandidType, Deserialize)]
pub struct HttpResponse {
  pub body: serde_bytes::ByteBuf,
  pub headers: Vec<(String,String,)>,
  pub status_code: u16,
}

pub struct Service<'a>(pub Principal, pub &'a ic_agent::Agent);
impl<'a> Service<'a> {
  pub async fn get_cycle_balance(&self) -> Result<candid::Nat> {
    let args = Encode!()?;
    let bytes = self.1.query(&self.0, "get_cycle_balance").with_arg(args).call().await?;
    Ok(Decode!(&bytes, candid::Nat)?)
  }
  pub async fn get_top_posts_aggregated_from_canisters_on_this_network_for_home_feed_cursor(&self, arg0: u64, arg1: u64, arg2: Option<bool>, arg3: Option<PostStatus>, arg4: Option<NsfwFilter>) -> Result<Result_> {
    let args = Encode!(&arg0,&arg1,&arg2,&arg3,&arg4)?;
    let bytes = self.1.query(&self.0, "get_top_posts_aggregated_from_canisters_on_this_network_for_home_feed_cursor").with_arg(args).call().await?;
    Ok(Decode!(&bytes, Result_)?)
  }
  pub async fn get_top_posts_aggregated_from_canisters_on_this_network_for_hot_or_not_feed_cursor(&self, arg0: u64, arg1: u64, arg2: Option<bool>, arg3: Option<PostStatus>, arg4: Option<NsfwFilter>) -> Result<Result_> {
    let args = Encode!(&arg0,&arg1,&arg2,&arg3,&arg4)?;
    let bytes = self.1.query(&self.0, "get_top_posts_aggregated_from_canisters_on_this_network_for_hot_or_not_feed_cursor").with_arg(args).call().await?;
    Ok(Decode!(&bytes, Result_)?)
  }
  pub async fn get_well_known_principal_value(&self, arg0: KnownPrincipalType) -> Result<Option<Principal>> {
    let args = Encode!(&arg0)?;
    let bytes = self.1.query(&self.0, "get_well_known_principal_value").with_arg(args).call().await?;
    Ok(Decode!(&bytes, Option<Principal>)?)
  }
  pub async fn http_request(&self, arg0: HttpRequest) -> Result<HttpResponse> {
    let args = Encode!(&arg0)?;
    let bytes = self.1.query(&self.0, "http_request").with_arg(args).call().await?;
    Ok(Decode!(&bytes, HttpResponse)?)
  }
  pub async fn receive_top_home_feed_posts_from_publishing_canister(&self, arg0: Vec<PostScoreIndexItemV1>) -> Result<()> {
    let args = Encode!(&arg0)?;
    let bytes = self.1.update(&self.0, "receive_top_home_feed_posts_from_publishing_canister").with_arg(args).call_and_wait().await?;
    Ok(Decode!(&bytes)?)
  }
  pub async fn receive_top_hot_or_not_feed_posts_from_publishing_canister(&self, arg0: Vec<PostScoreIndexItemV1>) -> Result<()> {
    let args = Encode!(&arg0)?;
    let bytes = self.1.update(&self.0, "receive_top_hot_or_not_feed_posts_from_publishing_canister").with_arg(args).call_and_wait().await?;
    Ok(Decode!(&bytes)?)
  }
  pub async fn remove_all_feed_entries(&self) -> Result<()> {
    let args = Encode!()?;
    let bytes = self.1.update(&self.0, "remove_all_feed_entries").with_arg(args).call_and_wait().await?;
    Ok(Decode!(&bytes)?)
  }
  pub async fn update_post_home_feed(&self, arg0: PostScoreIndexItemV1) -> Result<()> {
    let args = Encode!(&arg0)?;
    let bytes = self.1.update(&self.0, "update_post_home_feed").with_arg(args).call_and_wait().await?;
    Ok(Decode!(&bytes)?)
  }
  pub async fn update_post_hot_or_not_feed(&self, arg0: PostScoreIndexItemV1) -> Result<()> {
    let args = Encode!(&arg0)?;
    let bytes = self.1.update(&self.0, "update_post_hot_or_not_feed").with_arg(args).call_and_wait().await?;
    Ok(Decode!(&bytes)?)
  }
}
