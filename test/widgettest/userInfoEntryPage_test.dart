import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchup/Pages/userInfoEntryPage.dart';
import 'package:matchup/bizlogic/User.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import './assetBundle.dart';

import 'package:matchup/bizlogic/authentication.dart';

// pages that use scaffolds must be a descendant of some type of material app
Future<Widget> makeTestableWidget(WidgetTester tester, Widget child, BaseAuth auth) async{
  final AssetBundle assetBundle = TestAssetBundle(<String, List<String>>{
    'assets/images/logo.png': <String>['assets/images/regionsMap.png'],
  });

  return DefaultAssetBundle(
    bundle: assetBundle,
    child: MultiProvider(
      providers: [
        Provider<BaseAuth>(
          create: (context) => Auth()
        ),
        Provider<User>(
          create: (context) => User()
        ),
      ],
        child: MaterialApp(
          home: child,
        ),
      )
  ,);
}

// mock for firebase auth functionality
class MockAuth extends Mock implements BaseAuth{}

class Keys{
  static const Key userName = Key('Username'); 
  static const Key friendCode = Key('FriendCode'); 
  static const Key main = Key('Main'); 
  static const Key secondary = Key('Secondary'); 
  static const Key region = Key('Region'); 
  static const Key saveProfile = Key('SaveProfile'); // the error message text found on login/signup
  static const Key deleteAccount = Key('DeleteAccount'); 
}

void main(){
  testWidgets('Filling out user information', (WidgetTester tester) async {
    // ARRANGE
    // check if login call back is used
    String expectedEmail = 'foo@gmail.com';
    String expectedPassword = 'Test123!';

    MockAuth mockAuth = new MockAuth();
    when(mockAuth.signIn(expectedEmail, expectedPassword)).thenAnswer((value){return Future.value("test id");});

    bool didSignIn = false;
    bool didLogOut = false;
    UserInfoEntryPage page = UserInfoEntryPage(
      (){ // loginCallBack
        didSignIn = true;
        return;
      },
      (bool deleteAccount){ // logoutCallBack
        didLogOut = true;
        return;
      },
    );

    // ACT 
    // pump the login page
    await tester.pumpWidget(await makeTestableWidget(tester, page, mockAuth));

    // userInfoEntry Page
    // username
    Finder usernameField = find.byKey(Keys.userName);
    expect(usernameField, findsOneWidget);
    await tester.tap(usernameField);
    await tester.enterText(usernameField, 'test');

    // friend code
    Finder friendCodeField = find.byKey(Keys.friendCode);
    expect(friendCodeField, findsOneWidget);
    await tester.tap(friendCodeField);
    await tester.enterText(friendCodeField, 'SW-1234-1234-1234');

    // main
    Finder mainDropdown = find.byKey(Keys.main);
    expect(mainDropdown, findsOneWidget);
    await tester.tap(mainDropdown);
    await tester.pumpAndSettle();

    Finder mainText = find.byKey(Key("MainBowser"));
    expect(mainText.first, findsOneWidget);
    await tester.tap(mainText.first);
    await tester.pumpAndSettle();
    
    // secondary
    Finder secondaryDropdown = find.byKey(Keys.secondary);
    expect(secondaryDropdown, findsOneWidget);
    await tester.tap(secondaryDropdown);
    await tester.pumpAndSettle();

    Finder secondaryText = find.byKey(Key("SecondaryBowser"));
    expect(secondaryText.first, findsOneWidget);
    await tester.tap(secondaryText.first);
    await tester.pumpAndSettle();

    // region 
    Finder regionDropdown = find.byKey(Keys.region);
    expect(regionDropdown, findsOneWidget);
    await tester.tap(regionDropdown);
    await tester.pumpAndSettle();

    Finder regionText = find.byKey(Key("RegionWest Coast (WC)"));
    expect(regionText.first, findsOneWidget);
    await tester.tap(regionText.first);
    await tester.pumpAndSettle();

    //save
    Finder saveButton = find.byKey(Keys.saveProfile);
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
  });
}