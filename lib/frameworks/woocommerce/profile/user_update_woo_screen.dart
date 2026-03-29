import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inspireui/extensions/color_extension.dart';
import 'package:provider/provider.dart';

import '../../../common/tools/flash.dart';
import '../../../common/tools.dart';
import '../../../models/entities/user.dart';
import '../../../models/user_model.dart';
import '../../../modules/dynamic_layout/helper/helper.dart';
import '../../../services/index.dart';
import '../../../widgets/common/xfile_image_widget.dart';
import 'user_update_model.dart';

class UserUpdateWooScreen extends StatefulWidget {
  @override
  State<UserUpdateWooScreen> createState() => _UserUpdateScreenState();
}

class _UserUpdateScreenState extends State<UserUpdateWooScreen> {
  final formKey = GlobalKey<FormState>();

  Widget renderBackgroundAvatar(dynamic value) {
    Widget? avatar;
    if (value is String && value.isNotEmpty) {
      avatar = FluxImage(
        imageUrl: value,
        fit: BoxFit.cover,
      );
    }
    if (value is XFile) {
      avatar = XFileImageWidget(
        image: value,
        height: (MediaQuery.sizeOf(context).height * 0.20).toDouble(),
        width: MediaQuery.sizeOf(context).width.toDouble(),
        fit: BoxFit.cover,
      );
    }
    if (avatar == null) {
      return const SizedBox();
    }
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.elliptical(100, 10),
      ),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: avatar,
      ),
    );
  }

  Widget renderAvatar(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return Hero(
        tag: 'user-avatar-$value',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(150),
          child: FluxImage(
            imageUrl: value,
            fit: BoxFit.cover,
            width: 150,
            height: 150,
          ),
        ),
      );
    }
    if (value is XFile) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(150),
        child: XFileImageWidget(
          image: value,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      );
    }
    return const Icon(
      Icons.person,
      size: 120,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false);
    return ChangeNotifierProvider<UserUpdateModel>(
      create: (_) => UserUpdateModel(user.user),
      lazy: false,
      child: Consumer<UserUpdateModel>(
        builder: (context, model, child) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: GestureDetector(
            onTap: () {
              Tools.hideKeyboard(context);
            },
            child: Form(
              key: formKey,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      buildAvatar(model),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      buildInputField(S.of(context).displayName,
                                          model.userDisplayName,
                                          isEnabled: false),
                                      const SizedBox(height: 10),
                                      buildInputField(
                                          S.of(context).email, model.userEmail,
                                          isEnabled: false),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Material(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5.0),
                          child: MaterialButton(
                            height: 45,
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                model.updateProfile().then((value) {
                                  if (value != null) {
                                    final userModel = Provider.of<UserModel>(
                                        context,
                                        listen: false);
                                    userModel.updateUser(User.fromJson(value));
                                    FlashHelper.message(context,
                                        message: S.of(context).updateSuccess);
                                    Navigator.pop(context);
                                  }
                                }).catchError((e) {
                                  FlashHelper.message(context,
                                      message: e.toString(), isError: true);
                                });
                              }
                            },
                            child: Text(
                              S.of(context).update.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  buildButtonUpdate(model),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController? controller,
      {bool isEnabled = true, Function? validator}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColorLight,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            filled: !isEnabled,
            fillColor: isEnabled
                ? null
                : Theme.of(context).disabledColor.withOpacity(0.05),
          ),
          controller: controller,
          enabled: isEnabled,
          validator: (value) => validator?.call(value, label),
        ),
      ],
    );
  }

  String? validatorMoreThanThree(String? value, String label) {
    if (value == null || value.length < 3) {
      return S.of(context).cannotLessThreeLength(label);
    }
    return null;
  }

  String? validatorPhone(String? value, String label) {
    if (value == null || value.isEmpty) {
      return null;
    }

    const pattern = r'(^(?:[+0])?[0-9]{10,13}$)';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return S.of(context).invalidPhoneNumber;
    }
    return null;
  }

  Widget buildAvatar(UserUpdateModel model) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.25,
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.sizeOf(context).height * 0.20,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.elliptical(100, 10),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  )
                ]),
            child: renderBackgroundAvatar(model.avatar),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(150),
                color: Theme.of(context).primaryColorLight,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 3,
                ),
              ),
              child: renderAvatar(model.avatar),
            ),
          ),
          SafeArea(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(left: 10),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildButtonUpdate(UserUpdateModel model) {
    return model.state == UserUpdateState.loading
        ? Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: SpinKitCircle(
                color: Colors.white,
                size: 20.0,
              ),
            ),
          )
        : const SizedBox();
  }
}
