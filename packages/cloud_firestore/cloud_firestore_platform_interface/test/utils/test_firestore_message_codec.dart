// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_firestore.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_query.dart';
import 'package:cloud_firestore_platform_interface/src/method_channel/utils/firestore_message_codec.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// This codec is able to decode FieldValues.
/// This ability is only required in tests, hence why
/// those values are only decoded in tests.
class TestFirestoreMessageCodec extends FirestoreMessageCodec {
  /// Constructor.
  const TestFirestoreMessageCodec();

  static const int _kDocumentReference = 130;
  static const int _kArrayUnion = 132;
  static const int _kArrayRemove = 133;
  static const int _kDelete = 134;
  static const int _kServerTimestamp = 135;
  static const int _kFirestoreInstance = 144;
  static const int _kFieldPath = 140;
  static const int _kFirestoreQuery = 145;
  static const int _kFirestoreSettings = 146;

  static const int _kIncrementDouble = 137;
  static const int _kIncrementInteger = 138;

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      // The following cases are only used by unit tests, and not by actual application
      // code paths.
      case _kArrayUnion:
        final List<dynamic> value = readValue(buffer)! as List<dynamic>;
        return FieldValuePlatform(
            FieldValueFactoryPlatform.instance.arrayUnion(value));
      case _kArrayRemove:
        final List<dynamic> value = readValue(buffer)! as List<dynamic>;
        return FieldValuePlatform(
            FieldValueFactoryPlatform.instance.arrayRemove(value));
      case _kDelete:
        return FieldValuePlatform(FieldValueFactoryPlatform.instance.delete());
      case _kServerTimestamp:
        return FieldValuePlatform(
            FieldValueFactoryPlatform.instance.serverTimestamp());
      case _kIncrementDouble:
        final double value = readValue(buffer)! as double;
        return FieldValuePlatform(
            FieldValueFactoryPlatform.instance.increment(value));
      case _kIncrementInteger:
        final int value = readValue(buffer)! as int;
        return FieldValuePlatform(
            FieldValueFactoryPlatform.instance.increment(value));
      case _kFirestoreInstance:
        String appName = readValue(buffer)! as String;
        String databaseURL = readValue(buffer)! as String;
        readValue(buffer);
        final FirebaseApp app = Firebase.app(appName);
        return MethodChannelFirebaseFirestore(
            app: app, databaseId: databaseURL);
      case _kFirestoreQuery:
        Map<dynamic, dynamic> values =
            readValue(buffer)! as Map<dynamic, dynamic>;
        //ignore:
        return MethodChannelQuery(
          //ignore: avoid_redundant_argument_values
          MethodChannelFirebaseFirestore(app: null),
          values['path'],
          FirestorePigeonFirebaseApp(
            appName: 'test',
            settings: PigeonFirebaseSettings(
              ignoreUndefinedProperties: false,
            ),
            databaseURL: '',
          ),
        );
      case _kFirestoreSettings:
        readValue(buffer);
        return const Settings();
      case _kDocumentReference:
        MethodChannelFirebaseFirestore firestore =
            readValue(buffer)! as MethodChannelFirebaseFirestore;
        String path = readValue(buffer)! as String;
        return firestore.doc(path, null, null, null);
      case _kFieldPath:
        final int size = readSize(buffer);
        final List<String> segments = <String>[];
        for (int i = 0; i < size; i++) {
          segments.add(readValue(buffer)! as String);
        }
        return FieldPath(segments);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}
