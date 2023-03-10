import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/configs.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/blocked_accounts_model.dart';
import 'package:socialv/models/story_response_model.dart';
import 'package:socialv/models/accept_group_request_model.dart';
import 'package:socialv/models/accept_invite_response_model.dart';
import 'package:socialv/models/avatar_urls.dart';
import 'package:socialv/models/comment_model.dart';
import 'package:socialv/models/common_message_response.dart';
import 'package:socialv/models/common_story_model.dart';
import 'package:socialv/models/coverimage_response.dart';
import 'package:socialv/models/dashboard_api_response.dart';
import 'package:socialv/models/delete_avatar_response.dart';
import 'package:socialv/models/delete_cover_image_response.dart';
import 'package:socialv/models/delete_group_response.dart';
import 'package:socialv/models/delete_notification_response_model.dart';
import 'package:socialv/models/friend_list_model.dart';
import 'package:socialv/models/friend_request_model.dart';
import 'package:socialv/models/friendship_response_model.dart';
import 'package:socialv/models/get_group_member_response.dart';
import 'package:socialv/models/get_post_likes_model.dart';
import 'package:socialv/models/group_detail_model.dart';
import 'package:socialv/models/group_member_list_model.dart';
import 'package:socialv/models/group_membership_requests_model.dart';
import 'package:socialv/models/group_model.dart';
import 'package:socialv/models/group_request_model.dart';
import 'package:socialv/models/group_response.dart';
import 'package:socialv/models/invite_user_list_model.dart';
import 'package:socialv/models/login_response.dart';
import 'package:socialv/models/media_model.dart';
import 'package:socialv/models/member_detail_model.dart';
import 'package:socialv/models/member_response.dart';
import 'package:socialv/models/notification_model.dart';
import 'package:socialv/models/notification_settings_model.dart';
import 'package:socialv/models/post_in_list_model.dart';
import 'package:socialv/models/post_model.dart';
import 'package:socialv/models/profile_field_model.dart';
import 'package:socialv/models/profile_visibility_model.dart';
import 'package:socialv/models/register_user_model.dart';
import 'package:socialv/models/reject_group_invite_response.dart';
import 'package:socialv/models/reject_group_membership_request.dart';
import 'package:socialv/models/remove_existing_friend.dart';
import 'package:socialv/models/remove_group_member.dart';
import 'package:socialv/models/story_views_model.dart';
import 'package:socialv/models/woo_commerce/coupon_model.dart';
import 'package:socialv/models/woo_commerce/cart_model.dart';
import 'package:socialv/models/woo_commerce/category_model.dart';
import 'package:socialv/models/woo_commerce/common_models.dart';
import 'package:socialv/models/woo_commerce/country_model.dart';
import 'package:socialv/models/woo_commerce/customer_model.dart';
import 'package:socialv/models/woo_commerce/order_model.dart';
import 'package:socialv/models/woo_commerce/payment_model.dart';
import 'package:socialv/models/woo_commerce/product_detail_model.dart';
import 'package:socialv/models/woo_commerce/product_list_model.dart';
import 'package:socialv/models/woo_commerce/product_review_model.dart';
import 'package:socialv/models/woo_commerce/wishlist_model.dart';
import 'package:socialv/network/network_utils.dart';
import 'package:socialv/utils/constants.dart';

import '../screens/auth/screens/sign_in_screen.dart';
import 'package:http_parser/http_parser.dart';

bool get isTokenExpire => JwtDecoder.isExpired(getStringAsync(SharePreferencesKey.TOKEN));

// region Auth
Future<RegisterUserModel> createUser(Map request) async {
  return RegisterUserModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.signup, request: request, method: HttpMethod.POST, isAuth: true)));
}

Future<LoginResponse> loginUser(Map request) async {
  LoginResponse response = LoginResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.login, request: request, method: HttpMethod.POST, isAuth: true)));

  appStore.setToken(response.token.validate());
  appStore.setLoggedIn(true);

  appStore.setLoginName(response.userNicename.validate());
  appStore.setLoginFullName(response.userDisplayName.validate());
  appStore.setLoginEmail(response.userEmail.validate());
  return response;
}

Future<LoginResponse> loginUser2({required Map request, required bool isSocialLogin}) async {
  LoginResponse response;
  if (isSocialLogin.validate()) {
    response = LoginResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.socialLogin, request: request, method: HttpMethod.POST, isAuth: true)));
  } else {
    response = LoginResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.login, request: request, method: HttpMethod.POST, isAuth: true)));
  }

  appStore.setToken(response.token.validate());
  appStore.setLoggedIn(true);

  appStore.setLoginName(response.userNicename.validate());
  appStore.setLoginFullName(response.userDisplayName.validate());
  appStore.setLoginEmail(response.userEmail.validate());
  return response;
}




Future<CommonMessageResponse> forgetPassword({required String email}) async {
  Map request = {"email": email};

  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.forgetPassword}', method: HttpMethod.POST, request: request, isAuth: true)),
  );
}

Future<void> logout(BuildContext context) async {
  appStore.setLoading(true);

  Map req = {"player_id": getStringAsync(SharePreferencesKey.ONE_SIGNAL_PLAYER_ID), "add": 0};

  await setPlayerId(req).then((value) {
    appStore.setLoading(false);
  }).catchError((e) {
    appStore.setLoading(false);
    log("Player id error : ${e.toString()}");
  });
  await appStore.setToken('');
  await appStore.setNonce('');
  appStore.setLoginUserId('0');
  appStore.setLoginFullName('');
  appStore.setLoginAvatarUrl('');
  if (!appStore.doRemember) appStore.setLoginName('');
  appStore.recentMemberSearchList.clear();
  appStore.recentGroupsSearchList.clear();
  await appStore.setLoggedIn(false);
  finish(context);

  SignInScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Scale, isNewTask: true);
}

Future<CommonMessageResponse> deleteAccount() async {
  return CommonMessageResponse.fromJson(
    await handleResponse(
      await buildHttpResponse('${APIEndPoint.deleteAccount}', method: HttpMethod.DELETE),
    ),
  );
}

//endregion

//region Members

/// Members.

Future<MemberResponse> getLoginMember() async {
  return MemberResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getMembers}/me')));
}

Future<List<MemberResponse>> getAllMembers({String? type, int page = 1, String? searchText}) async {
  Iterable it = await handleResponse(
    await buildHttpResponse(
      '${APIEndPoint.getMembers}?type=${type ?? MemberType.active}&page=$page&per_page=20${searchText != null ? '&search=$searchText' : ''}&current_user=${appStore.loginUserId}',
    ),
  );

  return it.map((e) => MemberResponse.fromJson(e)).toList();
}

Future<MemberResponse> updateLoginUser({required Map request}) async {
  return MemberResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getMembers}/me', method: HttpMethod.PUT, request: request)));
}

/// Friendship Connection

Future<List<FriendshipResponseModel>> requestNewFriend(Map request) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getFriends}', request: request, method: HttpMethod.POST));

  return it.map((e) => FriendshipResponseModel.fromJson(e)).toList();
}

Future<RemoveExistingFriend> removeExistingFriendConnection({required String friendId, required bool passRequest}) async {
  Map request = {"force": true};

  return RemoveExistingFriend.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getFriends}/$friendId', method: HttpMethod.DELETE, request: passRequest ? request : null)));
}

Future<List<FriendshipResponseModel>> acceptFriendRequest({required int id}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getFriends}/$id', method: HttpMethod.PUT));

  return it.map((e) => FriendshipResponseModel.fromJson(e)).toList();
}

//endregion

// region Images

Future<DeleteCoverImageResponse> deleteGroupCoverImage({required int id}) async {
  return DeleteCoverImageResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/$id/${APIEndPoint.coverImage}', method: HttpMethod.DELETE)));
}

Future<DeleteCoverImageResponse> deleteMemberCoverImage({required int id}) async {
  return DeleteCoverImageResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getMembers}/$id/${APIEndPoint.coverImage}', method: HttpMethod.DELETE)));
}

Future<void> attachMemberImage({required String id, File? image, bool isCover = false}) async {
  appStore.setLoading(true);

  MultipartRequest multiPartRequest = await getMultiPartRequest('${APIEndPoint.getMembers}/$id/${isCover ? APIEndPoint.coverImage : APIEndPoint.avatarImage}');

  multiPartRequest.headers['authorization'] = 'Bearer ${appStore.token}';

  multiPartRequest.fields['action'] = isCover ? GroupImageKeys.coverActionKey : GroupImageKeys.avatarActionKey;
  multiPartRequest.files.add(await MultipartFile.fromPath('file', image!.path));

  await sendMultiPartRequest(
    multiPartRequest,
    onSuccess: (data) async {
      List<AvatarUrls> imageList = [];

      List jsonResponse = json.decode(data);
      jsonResponse.map((i) {
        imageList.add(AvatarUrls.fromJson(i));
      }).toList();

      if (!isCover) appStore.setLoginAvatarUrl(imageList.first.full.validate());
      appStore.setLoading(false);
      toast(language!.profilePictureUpdatedSuccessfully, print: true);
    },
    onError: (error) {
      toast(error.toString(), print: true);
    },
  );
}

Future<void> groupAttachImage({required int id, File? image, bool isCoverImage = false}) async {
  appStore.setLoading(true);
  MultipartRequest multiPartRequest = await getMultiPartRequest('${APIEndPoint.getGroups}/$id/${isCoverImage ? APIEndPoint.coverImage : APIEndPoint.avatarImage}');

  multiPartRequest.headers['authorization'] = 'Bearer ${appStore.token}';

  multiPartRequest.fields['action'] = isCoverImage ? GroupImageKeys.coverActionKey : GroupImageKeys.avatarActionKey;
  multiPartRequest.files.add(await MultipartFile.fromPath('file', image!.path));

  await sendMultiPartRequest(
    multiPartRequest,
    onSuccess: (data) async {
      appStore.setLoading(false);

      List<CoverImageResponse> imageList = [];

      List jsonResponse = json.decode(data);
      jsonResponse.map((i) {
        imageList.add(CoverImageResponse.fromJson(i));
      }).toList();
    },
    onError: (error) {
      appStore.setLoading(false);

      toast(error.toString(), print: true);
    },
  );
}

Future<void> deleteMemberAvatarImage({required String id}) async {
  appStore.setLoading(true);
  await deleteAvatarImage(id: id).then((value) async {
    await getMemberAvatarUrls(id: id).then((value) {
      appStore.setLoginAvatarUrl(value.first.full.validate());
      appStore.setLoading(false);
      toast(language!.profilePictureRemovedSuccessfully);
    });
  }).catchError((e) {
    appStore.setLoading(false);

    toast(e.toString(), print: true);
  });
}

Future<List<AvatarUrls>> getMemberAvatarUrls({required String id}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getMembers}/$id/${APIEndPoint.avatarImage}'));

  return it.map((e) => AvatarUrls.fromJson(e)).toList();
}

Future<DeleteAvatarResponse> deleteAvatarImage({required String id, bool isGroup = false}) async {
  return DeleteAvatarResponse.fromJson(await handleResponse(await buildHttpResponse('${isGroup ? APIEndPoint.getGroups : APIEndPoint.getMembers}/$id/${APIEndPoint.avatarImage}', method: HttpMethod.DELETE)));
}

Future<List<CoverImageResponse>> getMemberCoverImage({required String id}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getMembers}/$id/${APIEndPoint.coverImage}'));

  return it.map((e) => CoverImageResponse.fromJson(e)).toList();
}

//endregion

// region Groups

Future<List<GroupResponse>> getUserGroups({int page = 1, String? searchText, bool searchScreen = true}) async {
  Iterable it = Iterable.empty();

  it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}?page=$page&per_page=20${searchScreen ? '&search=$searchText' : ''}'));

  return it.map((e) => GroupResponse.fromJson(e)).toList();
}

Future<DeleteGroupResponse> deleteGroup({String? id}) async {
  return DeleteGroupResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/$id', method: HttpMethod.DELETE)));
}

Future<List<GroupResponse>> createGroup(Map request) async {
  Iterable it = await handleResponse(await buildHttpResponse(APIEndPoint.getGroups, request: request, method: HttpMethod.POST));

  return it.map((e) => GroupResponse.fromJson(e)).toList();
}

Future<List<GroupResponse>> updateGroup({required Map request, required int groupId}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/$groupId', request: request, method: HttpMethod.PUT));

  return it.map((e) => GroupResponse.fromJson(e)).toList();
}

/// Group Invites

Future<RejectGroupInviteResponse> rejectGroupInvite({required int id}) async {
  return RejectGroupInviteResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/${APIEndPoint.groupInvites}/$id', method: HttpMethod.DELETE)));
}

Future<List<AcceptInviteResponseModel>> acceptGroupInvite({required String id}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/${APIEndPoint.groupInvites}/$id', method: HttpMethod.PUT));

  return it.map((e) => AcceptInviteResponseModel.fromJson(e)).toList();
}

/// Group Membership Requests

Future<List<AcceptGroupRequestModel>> joinPublicGroup({required int groupId}) async {
  Map request = {"user_id": appStore.loginUserId.toInt()};

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/$groupId/${APIEndPoint.groupMembers}', method: HttpMethod.POST, request: request));
  return it.map((e) => AcceptGroupRequestModel.fromJson(e)).toList();
}

Future<RemoveGroupMember> leaveGroup({required int groupId}) async {
  return RemoveGroupMember.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/$groupId/${APIEndPoint.groupMembers}/${appStore.loginUserId}', method: HttpMethod.DELETE)));
}

Future<RemoveGroupMember> removeGroupMember({required int groupId, required int memberId}) async {
  return RemoveGroupMember.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/$groupId/${APIEndPoint.groupMembers}/$memberId', method: HttpMethod.DELETE)));
}

Future<List<GetGroupMemberResponse>> makeMemberAdmin({required int groupId, required int memberId}) async {
  Map request = {"role": Roles.admin};

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/$groupId/${APIEndPoint.groupMembers}/$memberId', method: HttpMethod.POST, request: request));

  return it.map((e) => GetGroupMemberResponse.fromJson(e)).toList();
}

Future<List<GetGroupMemberResponse>> dismissMemberAsAdmin({required int groupId, required int memberId}) async {
  Map request = {"role": Roles.member, "action": GroupActions.demote};

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/$groupId/${APIEndPoint.groupMembers}/$memberId', method: HttpMethod.POST, request: request));

  return it.map((e) => GetGroupMemberResponse.fromJson(e)).toList();
}

Future<List<GroupMembershipRequestsModel>> sendGroupMembershipRequest(Map request) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/${APIEndPoint.groupMembershipRequests}', method: HttpMethod.POST, request: request));
  return it.map((e) => GroupMembershipRequestsModel.fromJson(e)).toList();
}

Future<List<AcceptGroupRequestModel>> acceptGroupMembershipRequest({required int requestId}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/${APIEndPoint.groupMembershipRequests}/$requestId', method: HttpMethod.PUT));
  return it.map((e) => AcceptGroupRequestModel.fromJson(e)).toList();
}

Future<RejectGroupMembershipRequest> rejectGroupMembershipRequest({required int requestId}) async {
  return RejectGroupMembershipRequest.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getGroups}/${APIEndPoint.groupMembershipRequests}/$requestId', method: HttpMethod.DELETE)));
}

//endregion

// region notification

Future<DeleteNotificationResponseModel> deleteNotification({required String notificationId}) async {
  return DeleteNotificationResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.getNotifications}/$notificationId', method: HttpMethod.DELETE)));
}

Future<List<NotificationModel>> notificationsList({int page = 1}) async {
  Map request = {"page": page, "per_page": 20};

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.notifications}', method: HttpMethod.POST, request: request));
  return it.map((e) => NotificationModel.fromJson(e)).toList();
}

//endregion

/// Custom apis

// region Post
Future<List<PostModel>> getPost({int page = 1, int? userId, int? groupId, required String type}) async {
  Map request = {"user_id": userId ?? appStore.loginUserId.toInt(), "per_page": PER_PAGE, "page": page, "type": type, "group_id": groupId};

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.posts}', method: HttpMethod.POST, request: request));
  return it.map((e) => PostModel.fromJson(e)).toList();
}

Future<PostModel> getSinglePost({required int postId}) async {
  Map request = {
    "type": PostRequestType.singleActivity,
    "activity_id": postId.toString(),
  };

  return PostModel.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.singlePosts}', method: HttpMethod.POST, request: request)),
  );
}

Future<List<MediaModel>> getMediaTypes({String? type}) async {
  Map request = {"component": type ?? Component.members};

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.supportedMediaList}', method: HttpMethod.POST, request: request));

  return it.map((e) => MediaModel.fromJson(e)).toList();
}

Future<List<PostInListModel>> getPostInList() async {
  Map request = {"current_user_id": appStore.loginUserId};

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getPostInList}', method: HttpMethod.POST, request: request));

  return it.map((e) => PostInListModel.fromJson(e)).toList();
}

Future<void> uploadPost({List<File>? files, String? content, bool isMedia = false, String postIn = "0", String? mediaType}) async {
  MultipartRequest multiPartRequest = await getMultiPartRequest('${APIEndPoint.createPosts}');

  multiPartRequest.headers['authorization'] = 'Bearer ${appStore.token}';

  multiPartRequest.fields['user_id'] = appStore.loginUserId;
  multiPartRequest.fields['content'] = content.validate();
  multiPartRequest.fields['activity_type'] = isMedia ? PostActivityType.mppMediaUpload : PostActivityType.activityUpdate;
  multiPartRequest.fields['post_in'] = postIn.validate();
  if (files.validate().isNotEmpty) multiPartRequest.fields['media_count'] = files.validate().length.toString();
  multiPartRequest.fields['media_type'] = isMedia ? mediaType.validate() : "0";

  List<MultipartFile> _files = [];

  await Future.forEach(files.validate(), (File element) async {
    _files.add(await MultipartFile.fromPath("media_${files.validate().indexOf(element)}", element.path));
  });

  multiPartRequest.files.addAll(_files);

  log('url : $BASE_URL${APIEndPoint.createPosts}');
  log('files ${multiPartRequest.files.map((e) => e.filename).toList()}');
  log('fields ${multiPartRequest.fields}');

  await sendMultiPartRequest(
    multiPartRequest,
    onSuccess: (data) async {
      CommonMessageResponse message = CommonMessageResponse.fromJson(jsonDecode(data));
      toast(message.message);
    },
    onError: (error) {
      toast(error.toString(), print: true);
    },
  );
}

Future<List<GetPostLikesModel>> getPostLikes({required int id, int page = 1}) async {
  Map request = {"activity_id": id, "per_page": PER_PAGE, "page": page};
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getAllPostLike}', method: HttpMethod.POST, request: request));

  return it.map((e) => GetPostLikesModel.fromJson(e)).toList();
}

Future<CommonMessageResponse> likePost({required int postId}) async {
  Map request = {
    "activity_id": postId.toString(),
    "current_user_id": appStore.loginUserId,
  };
  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.likePost}', method: HttpMethod.POST, request: request)),
  );
}

Future<CommonMessageResponse> deletePost({required int postId}) async {
  Map request = {
    "activity_id": postId,
    "user_id": appStore.loginUserId,
  };
  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.deletePost}', method: HttpMethod.DELETE, request: request)),
  );
}

Future<CommonMessageResponse> savePostComment({required int postId, String? content, int? parentId}) async {
  Map request = {
    "activity_id": postId,
    "current_user_id": appStore.loginUserId,
    "content": content,
    "parent_comment_id": parentId,
  };
  return CommonMessageResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.savePostComment}', method: HttpMethod.DELETE, request: request)));
}

Future<CommonMessageResponse> deletePostComment({required int commentId, required int postId}) async {
  Map request = {
    "post_id": postId,
    "comment_id": commentId,
    "user_id": appStore.loginUserId,
  };
  return CommonMessageResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.deletePostComment}', method: HttpMethod.DELETE, request: request)));
}

Future<List<CommentModel>> getComments({required int id, int? page}) async {
  Map request = {"activity_id": id, "per_page": PER_PAGE, "page": page};

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getPostComment}', method: HttpMethod.POST, request: request));
  return it.map((e) => CommentModel.fromJson(e)).toList();
}

//endregion

// region group
Future<List<GroupListModel>> getGroupList({String? groupType, int? page, int? userId}) async {
  Map request = {
    "group_type": groupType,
    "user_id": userId ?? appStore.loginUserId,
    "per_page": PER_PAGE,
    "page": page,
  };

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroupList}', method: HttpMethod.POST, request: request));
  return it.map((e) => GroupListModel.fromJson(e)).toList();
}

Future<List<GroupDetailModel>> getGroupDetail({int? groupId, String? userId}) async {
  Map request = {
    "group_id": groupId,
    "current_user_id": userId ?? appStore.loginUserId,
  };

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroupDetail}', method: HttpMethod.POST, request: request));
  return it.map((e) => GroupDetailModel.fromJson(e)).toList();
}

Future<List<GroupMemberListModel>> getGroupMembersList({int? groupId, int page = 1}) async {
  Map request = {"group_id": groupId, "per_page": 20, "page": page};

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroupMembersList}', method: HttpMethod.POST, request: request));
  return it.map((e) => GroupMemberListModel.fromJson(e)).toList();
}

Future<List<GroupRequestModel>> getGroupMembershipRequest({int? groupId, int page = 1}) async {
  Map request = {"group_id": groupId, "per_page": 20, "page": page};

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroupRequests}', method: HttpMethod.POST, request: request));
  return it.map((e) => GroupRequestModel.fromJson(e)).toList();
}

Future<List<InviteUserListModel>> getGroupInviteList({int? groupId, int page = 1}) async {
  Map request = {"group_id": groupId, "per_page": 10, "page": page};
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getGroupInvites}', method: HttpMethod.POST, request: request));
  return it.map((e) => InviteUserListModel.fromJson(e)).toList();
}

Future<CommonMessageResponse> invite({required int isInviting, required int userId, required int groupId}) async {
  Map request = {"group_id": groupId, "user_id": userId, "is_inviting": isInviting, "current_user_id": appStore.loginUserId.toInt()};
  return CommonMessageResponse.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.manageInvitation}', method: HttpMethod.DELETE, request: request)));
}

//endregion

// region member
Future<List<MemberDetailModel>> getMemberDetail({required int userId}) async {
  Map request = {"user_id": userId};
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getMemberDetail}', method: HttpMethod.POST, request: request));

  return it.map((e) => MemberDetailModel.fromJson(e)).toList();
}

Future<List<FriendListModel>> getFriendList({required int userId, int page = 1}) async {
  Map request = {"user_id": userId, "per_page": 20, "page": page};
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getFriendList}', method: HttpMethod.POST, request: request));

  return it.map((e) => FriendListModel.fromJson(e)).toList();
}

Future<List<FriendRequestModel>> getFriendRequestList({int page = 1}) async {
  Map request = {"current_user_id": appStore.loginUserId.toInt(), "per_page": PER_PAGE, "page": page};
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getFriendRequestList}', method: HttpMethod.POST, request: request));

  return it.map((e) => FriendRequestModel.fromJson(e)).toList();
}
Future<CommonMessageResponse> updateActiveStatus() async {
  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.updateActiveStatus}')),
  );
}
Future<List<FriendRequestModel>> getFriendRequestSent({int page = 1}) async {
  Map request = {"current_user_id": appStore.loginUserId.toInt(), "per_page": 20, "page": page};
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getFriendRequestSent}', method: HttpMethod.POST, request: request));

  return it.map((e) => FriendRequestModel.fromJson(e)).toList();
}

//endregion

// region settings and dashboard
Future<DashboardAPIResponse> getDashboardDetails() async {
  return DashboardAPIResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.getDashboard}', method: HttpMethod.GET)),
  );
}

Future<List<ProfileFieldModel>> getProfileFields() async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getProfileFields}', method: HttpMethod.GET));

  return it.map((e) => ProfileFieldModel.fromJson(e)).toList();
}

Future<CommonMessageResponse> updateProfileFields({required Map request}) async {
  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.saveProfileFields}', method: HttpMethod.POST, request: request)),
  );
}

Future<List<ProfileVisibilityModel>> getProfileVisibility() async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getProfileVisibility}', method: HttpMethod.GET));

  return it.map((e) => ProfileVisibilityModel.fromJson(e)).toList();
}

Future<CommonMessageResponse> saveProfileVisibility({required Map request}) async {
  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.saveProfileVisibility}', method: HttpMethod.POST, request: request)),
  );
}

Future<CommonMessageResponse> changePassword({required Map request}) async {
  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.changePassword}', method: HttpMethod.POST, request: request)),
  );
}

Future<void> setPlayerId(Map req) async {
  await handleResponse(await buildHttpResponse('${APIEndPoint.setPlayerId}', method: HttpMethod.POST, request: req));
}

Future<List<NotificationSettingsModel>> notificationsSettings() async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getNotificationSettings}'));

  return it.map((e) => NotificationSettingsModel.fromJson(e)).toList();
}

Future<CommonMessageResponse> saveNotificationsSettings({List? requestList}) async {
  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.saveNotificationSettings}', requestList: requestList, method: HttpMethod.POST)),
  );
}

//endregion

// region block report

Future<CommonMessageResponse> blockUser({required String key, required int userId}) async {
  Map request = {"user_id": userId, "key": key};
  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.blockMemberAccount}', method: HttpMethod.POST, request: request)),
  );
}

Future<List<BlockedAccountsModel>> getBlockedAccounts() async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getBlockedMembers}'));

  return it.map((e) => BlockedAccountsModel.fromJson(e)).toList();
}

Future<CommonMessageResponse> reportPost({required String report, required String reportType, required int postId, required int userId}) async {
  Map request = {"user_id": userId, "item_id": postId, "report_type": reportType, "details": report};
  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.reportPost}', method: HttpMethod.POST, request: request)),
  );
}

Future<CommonMessageResponse> reportUser({required String report, required int userId, required String reportType}) async {
  Map request = {"user_id": userId, "report_type": reportType, "details": report};
  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.reportUserAccount}', method: HttpMethod.POST, request: request)),
  );
}

Future<CommonMessageResponse> reportGroup({required String report, required int groupId, required String reportType}) async {
  Map request = {"group_id": groupId, "report_type": reportType, "details": report};
  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.reportGroup}', method: HttpMethod.POST, request: request)),
  );
}

//endregion

// region story
Future<void> uploadStory(BuildContext context, {required List<MediaSourceModel> fileList, required List<CreateStoryModel> contentList}) async {
  Future.forEach<MediaSourceModel>(fileList, (element) async {
    int index = fileList.indexOf(element);

    MultipartRequest multiPartRequest = await getMultiPartRequest('${APIEndPoint.addStory}');

    multiPartRequest.headers['authorization'] = 'Bearer ${appStore.token}';

    multiPartRequest.fields['story_text'] = contentList[index].storyText.validate();
    multiPartRequest.fields['story_link'] = contentList[index].storyLink.validate();
    if (element.mediaType != MediaTypes.video) multiPartRequest.fields['duration'] = contentList[index].storyDuration.validate();
    multiPartRequest.files.add(await MultipartFile.fromPath(
      'media',
      element.mediaFile.path,
      contentType: element.mediaType == MediaTypes.video ? MediaType(element.mediaType, element.extension) : null,
    ));

    log('Media extension: ${element.extension}');

    log('url : $BASE_URL${APIEndPoint.addStory}');
    log('fields ${multiPartRequest.fields}');
    log('files ${multiPartRequest.files[0].filename}');
    log('contentType ${multiPartRequest.files[0].contentType}');
    log('files ${element.mediaFile.path}');

    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        CommonMessageResponse message = CommonMessageResponse.fromJson(jsonDecode(data));
        toast(message.message);
      },
      onError: (error) {
        appStore.setLoading(false);
        toast(error.toString(), print: true);
      },
    );
  }).then((value) {
    appStore.setLoading(false);
    finish(context, true);
  });
}

Future<List<StoryResponseModel>> getUserStories({int? userId}) async {
  Iterable it;

  if (userId != null) {
    Map request = {"user_id": appStore.loginUserId.toInt()};
    it = await handleResponse(await buildHttpResponse('${APIEndPoint.getUserStories}', method: HttpMethod.POST, request: request));
  } else {
    it = await handleResponse(await buildHttpResponse('${APIEndPoint.getUserStories}'));
  }

  return it.map((e) => StoryResponseModel.fromJson(e)).toList();
}

Future<CommonMessageResponse> viewStory({required int storyId, required String uniqueStoryId}) async {
  Map request = {"story_id": storyId, "uniq_id": uniqueStoryId};

  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.viewStory}', method: HttpMethod.POST, request: request)),
  );
}

Future<List<StoryViewsModel>> getStoryViews({required int storyId, required String uniqueStoryId}) async {
  Map request = {"story_id": storyId, "uniq_id": uniqueStoryId};
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getStoryViews}', method: HttpMethod.POST, request: request));

  return it.map((e) => StoryViewsModel.fromJson(e)).toList();
}

Future<CommonMessageResponse> deleteStory({required int storyId, required int storyIndex}) async {
  Map request = {"story_id": storyId, "index": storyIndex};

  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.deleteStory}', method: HttpMethod.DELETE, request: request)),
  );
}

//endregion

// region woo commerce

/// products
Future<List<ProductListModel>> getProductsList({int page = 1, int? categoryId, String? orderBy}) async {
  Iterable it;

  it = await handleResponse(await buildHttpResponse('${APIEndPoint.productsList}?orderby=$orderBy&page=$page&per_page=$PER_PAGE', passParameters: true));

  if (categoryId != null) {
    it = await handleResponse(await buildHttpResponse('${APIEndPoint.productsList}?category=$categoryId&page=$page&per_page=$PER_PAGE', passParameters: true));
  } else {
    it = await handleResponse(await buildHttpResponse('${APIEndPoint.productsList}?orderby=$orderBy&page=$page&per_page=$PER_PAGE', passParameters: true));
  }

  return it.map((e) => ProductListModel.fromJson(e)).toList();
}

/// product reviews

Future<List<ProductReviewModel>> getProductReviews({required int productId}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.productReviews}?product=$productId', passParameters: true));

  return it.map((e) => ProductReviewModel.fromJson(e)).toList();
}

Future<ProductReviewModel> addProductReview({required Map request}) async {
  return ProductReviewModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.productReviews}', request: request, method: HttpMethod.POST, passParameters: true)));
}

Future<ProductReviewModel> updateProductReview({required Map request, required int reviewId}) async {
  return ProductReviewModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.productReviews}/$reviewId', request: request, method: HttpMethod.POST, passParameters: true)));
}

Future<ProductReviewModel> deleteProductReview({required int reviewId}) async {
  Map request = {"force": true};

  return ProductReviewModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.productReviews}/$reviewId', request: request, method: HttpMethod.DELETE, passParameters: true)));
}

/// Cart

Future<CartModel> getCartDetails() async {
  return CartModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.cart}', requiredNonce: true)));
}

Future<CartModel> applyCoupon({required String code}) async {
  return CartModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.applyCoupon}?code=$code', method: HttpMethod.POST, requiredNonce: true)));
}

Future<CartModel> removeCoupon({required String code}) async {
  return CartModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.removeCoupon}?code=$code', method: HttpMethod.POST, requiredNonce: true)));
}

Future<List<CouponModel>> getCouponsList() async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.coupons}', passHeaders: false, passParameters: true));

  return it.map((e) => CouponModel.fromJson(e)).toList();
}

Future<CartModel> addItemToCart({required int productId, required int quantity}) async {
  Map request = {"id": productId, "quantity": quantity};
  return CartModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.addCartItems}', method: HttpMethod.POST, request: request, requiredNonce: true)));
}

Future<CartModel> updateCartItem({required String productKey, required int quantity}) async {
  Map request = {"key": productKey, "quantity": quantity};

  return CartModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.updateCartItems}', method: HttpMethod.POST, request: request, requiredNonce: true)));
}

Future<CartModel> removeCartItem({required String productKey}) async {
  Map request = {"key": productKey};

  return CartModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.removeCartItems}', method: HttpMethod.POST, request: request, requiredNonce: true)));
}

Future<List<PaymentModel>> getPaymentMethods() async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.getPaymentMethods}', passHeaders: false, passParameters: true));

  return it.map((e) => PaymentModel.fromJson(e)).toList();
}

Future<List<CategoryModel>> getCategoryList() async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.categories}', passParameters: true));

  return it.map((e) => CategoryModel.fromJson(e)).toList();
}

Future<List<OrderModel>> getOrderList({String? status}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.orders}?customer=${appStore.loginUserId}&status=$status', passParameters: true));

  return it.map((e) => OrderModel.fromJson(e)).toList();
}

Future<OrderModel> createOrder({required Map request}) async {
  return OrderModel.fromJson(await handleResponse(
    await buildHttpResponse('${APIEndPoint.orders}', method: HttpMethod.POST, request: request, requiredNonce: true, passParameters: true),
  ));
}

Future<OrderModel> deleteOrder({required int orderId}) async {
  return OrderModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.orders}/$orderId', method: HttpMethod.DELETE, requiredNonce: true, passParameters: true)));
}

Future<CustomerModel> getCustomer() async {
  return CustomerModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.customers}/${appStore.loginUserId}', passParameters: true)));
}

Future<CustomerModel> updateCustomer({required Map request}) async {
  return CustomerModel.fromJson(await handleResponse(
    await buildHttpResponse('${APIEndPoint.customers}/${appStore.loginUserId}', method: HttpMethod.POST, request: request, requiredNonce: true, passParameters: true),
  ));
}

Future<List<CountryModel>> getCountries({String? status}) async {
  Iterable it = await handleResponse(await buildHttpResponse(APIEndPoint.countries, passParameters: true));

  return it.map((e) => CountryModel.fromJson(e)).toList();
}

/// custom apis
Future<NonceModel> getNonce() async {
  return NonceModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.storeNonce}', passParameters: true)));
}

Future<List<WishlistModel>> getWishList({int page = 1}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.wishlist}?page=$page&per_page=20'));

  return it.map((e) => WishlistModel.fromJson(e)).toList();
}

Future<CommonMessageResponse> removeFromWishlist({required int productId}) async {
  Map request = {"product_id": productId};

  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.removeFromWishlist}', method: HttpMethod.DELETE, request: request)),
  );
}

Future<CommonMessageResponse> addToWishlist({required int productId}) async {
  Map request = {"product_id": productId};

  return CommonMessageResponse.fromJson(
    await handleResponse(await buildHttpResponse('${APIEndPoint.addToWishlist}', method: HttpMethod.POST, request: request)),
  );
}

Future<List<ProductDetailModel>> getProductDetail({required int productId}) async {
  Map request = {"product_id": productId};

  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.productDetails}', method: HttpMethod.POST, request: request));

  return it.map((e) => ProductDetailModel.fromJson(e)).toList();
}

//endregion
