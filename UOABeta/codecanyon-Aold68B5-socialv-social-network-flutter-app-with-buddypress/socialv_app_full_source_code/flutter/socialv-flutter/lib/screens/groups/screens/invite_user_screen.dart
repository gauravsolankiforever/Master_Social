import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/screens/groups/components/invite_user_component.dart';

import '../../../../main2.dart';

class InviteUserScreen extends StatefulWidget {
  final int? groupId;

  InviteUserScreen({this.groupId});

  @override
  State<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: context.iconColor),
        title: Text(language!.groupInvites, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
      ),
      body: InviteUserComponent(groupId: widget.groupId.validate()),
    );
  }
}
