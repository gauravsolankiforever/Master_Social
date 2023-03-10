import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/profile_field_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/components/profile_field_component.dart';
import 'package:socialv/utils/app_constants.dart';

ProfileFieldModel group = ProfileFieldModel();

// ignore: must_be_immutable
class ExpansionBody extends StatefulWidget {
  ProfileFieldModel group = ProfileFieldModel();

  ExpansionBody({required this.group});

  @override
  State<ExpansionBody> createState() => _ExpansionBodyState();
}

class _ExpansionBodyState extends State<ExpansionBody> {
  final profileFieldFormKey = GlobalKey<FormState>();
  List<ProfileFieldModel> fieldList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Form(
          key: profileFieldFormKey,
          child: ListView.builder(
            itemCount: widget.group.fields.validate().length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, i) {
              Field element = widget.group.fields![i];
              return ProfileFieldComponent(field: element).paddingSymmetric(horizontal: 16, vertical: 8);
            },
          ),
        ),
        16.height,
        AppButton(
          elevation: 0,
          onTap: () {
            if (!appStore.isLoading)
              ifNotTester(() async {
                if (profileFieldFormKey.currentState!.validate() && isValid) {
                  profileFieldFormKey.currentState!.save();
                  hideKeyboard(context);

                  appStore.setLoading(true);
                  await updateProfileFields(request: group.toJson()).then((value) {
                    appStore.setLoading(false);
                    toast('${group.groupName} ${language!.updatedSuccessfully}');
                    appStore.setLoginFullName(name);
                  }).catchError((e) {
                    appStore.setLoading(false);
                    toast(e.toString());
                  });
                } else {
                  toast(language!.enterValidDetails);
                }
              });
          },
          padding: EdgeInsets.symmetric(horizontal: 16),
          text: language!.saveChanges,
          textColor: Colors.white,
          color: context.primaryColor,
        ),
        16.height,
      ],
    );
  }
}

