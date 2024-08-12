import 'dart:async';
import 'dart:io';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sham_parts/account-pages/settings_page.dart';
import 'package:sham_parts/api-util/api_session.dart';
import 'package:sham_parts/api-util/onshape_document.dart';
import 'package:sham_parts/api-util/user.dart';
import 'package:sham_parts/compound-widgets/compounds_page.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/home.dart';
import 'package:sham_parts/part-widgets/parts_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'api-util/project.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

const double _bottomPaddingForButton = 150.0;
const double _buttonHeight = 56.0;
const double _pagePadding = 16.0;

class ConnectionStatus {
  static bool connected = false;

  static const connectionInterval = Duration(seconds: 5);

  static checkConnection() async {
    try {
      Response response = await APISession.get("/");

      if (response.statusCode == 200) {
        ConnectionStatus.connected = true;
      } else {
        ConnectionStatus.connected = false;
      }
    } catch (e) {
      ConnectionStatus.connected = false;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      stderr.writeln('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      stderr.writeln('User granted provisional permission');
    } else {
      stderr.writeln('User declined or has not accepted permission');
    }
  } catch (e) {
    stderr.writeln("Failed to do firebase stuff");
  }

  APISession.updateKeys();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String version = "";

  @override
  void initState() {
    super.initState();
    initVersion();
  }

  void initVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();

    setState(() {
      version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShamParts v$version',
      navigatorKey: MyApp.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Theme.of(context).colorScheme.surface,
      ),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue, brightness: Brightness.dark),
          brightness: Brightness.dark),
      home: const BottomNavigation(),
    );
  }
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => BottomNavigationBarState();
}

class BottomNavigationBarState extends State<BottomNavigation> {
  bool connected = false;

  final pageViewController = PageController(initialPage: 0);
  final int currentPage = 0;

  final isMobile = Platform.isAndroid || Platform.isIOS;

  String version = "";

  int selectedIndex = 0;

  TextEditingController documentSearchController = TextEditingController();

  bool searching = false;
  List<OnshapeDocument> docs = [];

  Project project = Project.blank();
  List<String> projectKeys = [];
  final TextEditingController activeProjectController = TextEditingController();

  static List<Widget> widgetOptions = <Widget>[];

  late User user = User.blank();

  @override
  void initState() {
    super.initState();

    initVersion();

    regenWidgetOptions();

    loadUser().then((value) {
      regenWidgetOptions();
    });

    loadProjectWithoutSavingNewKey();

    setState(() {
      selectedIndex = pageViewController.initialPage;
    });

    Timer.periodic(ConnectionStatus.connectionInterval, (timer) {
      runConnectionCheck();
    });

    runConnectionCheck();
  }

  void runConnectionCheck() async {
    await ConnectionStatus.checkConnection();

    //This means we should load everything again
    if (ConnectionStatus.connected && !connected) {
      loadUser().then((value) {
        regenWidgetOptions();
      });

      loadProjectWithoutSavingNewKey();
    }

    setState(() {
      connected = ConnectionStatus.connected;
    });
  }

  Future<void> loadUser() async {
    User? newUser = await User.getUserFromPrefs();

    if (newUser != null) {
      setState(() {
        user = newUser;
      });
    } else {
      //Route user to settings page
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => SettingsPage(
                  user: user,
                  loadUser: () {
                    loadUser().then((value) {
                      regenWidgetOptions();
                    });
                  },
                  project: project,
                  appbar: true,
                  loadProject: loadProject,
                )),
      );
    }
  }

  void regenWidgetOptions() {
    widgetOptions = [
      Home(
        user: user,
        project: project,
      ),
      CompoundsPage(project: project),
      PartsPage(project: project),
      SettingsPage(
        user: user,
        loadUser: () {
          loadUser().then((value) {
            regenWidgetOptions();
          });
        },
        project: project,
        loadProject: loadProject,
      )
    ];
  }

  void initVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();

    setState(() {
      version = info.version;
    });
  }

  void loadProjectWithoutSavingNewKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String projectKey = prefs.getString(APIConstants().currentProject) ?? "";

    // ignore: use_build_context_synchronously
    Project activeProject = await Project.loadProject(projectKey, context);

    stderr.writeln("Loaded Project");

    setState(() {
      project = activeProject;
    });

    regenWidgetOptions();
  }

  void loadProject(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(APIConstants().currentProject, key);

    // ignore: use_build_context_synchronously
    Project activeProject = await Project.loadProject(key, context);

    stderr.writeln("Loaded Project");

    setState(() {
      project = activeProject;
    });

    regenWidgetOptions();
  }

  void onItemTapped(int index) {
    pageViewController.animateToPage(index,
        duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }

  void queryDocuments(BuildContext context, page) async {
    setState(() {
      searching = true;
      docs = [];
    });

    String currentQuery = documentSearchController.value.text;

    List<OnshapeDocument> newDocs =
        await OnshapeDocument.queryDocuments(currentQuery, () {});

    setState(() {
      docs = newDocs;
      searching = false;
    });

    showWoltModal(ValueNotifier(0), page);
  }

  void showWoltModal(ValueNotifier<int> pageIndexNotifier, page) {
    WoltModalSheet.show(
      context: context,
      pageIndexNotifier: pageIndexNotifier,
      pageListBuilder: (modalSheetContext) {
        final textTheme = Theme.of(context).textTheme;
        return [
          page(modalSheetContext, textTheme),
        ];
      },
      onModalDismissedWithBarrierTap: () {
        debugPrint('Closed modal sheet with barrier tap');
        Navigator.of(context).pop();
        pageIndexNotifier.value = 0;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageIndexNotifier = ValueNotifier(0);

    SliverWoltModalSheetPage page2(
        BuildContext modalSheetContext, TextTheme textTheme) {
      return WoltModalSheetPage(
          hasSabGradient: false,
          stickyActionBar: Padding(
            padding: const EdgeInsets.all(_pagePadding),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(modalSheetContext).pop(),
                  child: const SizedBox(
                    height: _buttonHeight,
                    width: double.infinity,
                    child: Center(child: Text('Back')),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () =>
                      pageIndexNotifier.value = pageIndexNotifier.value + 1,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                  ),
                  child: SizedBox(
                    height: _buttonHeight,
                    width: double.infinity,
                    child: Center(
                        child: Text(
                      'Create',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface),
                    )),
                  ),
                ),
              ],
            ),
          ),
          topBarTitle: Text('Select Document', style: textTheme.titleSmall),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            padding: const EdgeInsets.all(_pagePadding),
            icon: const Icon(Icons.close),
            onPressed: Navigator.of(modalSheetContext).pop,
          ),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(
                _pagePadding,
                _pagePadding,
                _pagePadding,
                _bottomPaddingForButton,
              ),
              child: Column(
                  children: docs.map((e) {
                return e.searchWidget;
              }).toList())));
    }

    SliverWoltModalSheetPage page1(
        BuildContext modalSheetContext, TextTheme textTheme) {
      return WoltModalSheetPage(
        hasSabGradient: false,
        stickyActionBar: Padding(
          padding: const EdgeInsets.all(_pagePadding),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(modalSheetContext).pop(),
                child: const SizedBox(
                  height: _buttonHeight,
                  width: double.infinity,
                  child: Center(child: Text('Cancel')),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                  onPressed: () {
                    queryDocuments(context, page2);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                  ),
                  child: SizedBox(
                    height: _buttonHeight,
                    width: double.infinity,
                    child: Center(
                        child: Text(
                      'Search',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inverseSurface),
                    )),
                  )),
            ],
          ),
        ),
        topBarTitle: Text('Search Documents', style: textTheme.titleSmall),
        isTopBarLayerAlwaysVisible: true,
        trailingNavBarWidget: IconButton(
          padding: const EdgeInsets.all(_pagePadding),
          icon: const Icon(Icons.close),
          onPressed: Navigator.of(modalSheetContext).pop,
        ),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(
              _pagePadding,
              _pagePadding,
              _pagePadding,
              _bottomPaddingForButton,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: documentSearchController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Search"),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (val) {
                        queryDocuments(context, page2);
                      },
                    ))
                  ],
                ),
              ],
            )),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("ShamParts v$version"),
        actions: [
          IconButton(
            icon: Icon(
              connected ? Icons.cloud_done : Icons.cloud_off,
              color: connected ? Colors.green : Colors.red,
            ),
            tooltip: connected ? "Server Connected" : "Server  Disconnected",
            onPressed: () async {
              runConnectionCheck();

              try {
                loadProjectWithoutSavingNewKey();

                APIConstants.showSuccessToast("Reloaded project info", context);
              } catch (e) {
                APIConstants.showErrorToast(
                    "Failed to relaod project", context);

                stderr.writeln("Failed to load project from reload click");
              }
            },
          ),
          user.roles.contains("admin") && !isMobile
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: const Icon(
                      Icons.add,
                    ),
                    tooltip: "Create New Project",
                    onPressed: () {
                      showWoltModal(pageIndexNotifier, page1);
                    },
                  ))
              : Container()
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: PageView(
        controller: pageViewController,
        physics: isMobile ? null : const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        children: widgetOptions,
      ),
      bottomNavigationBar: isMobile
          ? CurvedNavigationBar(
              items: const <CurvedNavigationBarItem>[
                CurvedNavigationBarItem(
                  child: Icon(Icons.home),
                  label: 'Home',
                ),
                CurvedNavigationBarItem(
                  child: Icon(Icons.grid_on),
                  label: 'Compounds',
                ),
                CurvedNavigationBarItem(
                    child: Icon(Icons.list), label: 'Parts'),
                CurvedNavigationBarItem(
                    child: Icon(Icons.settings), label: 'Settings')
              ],
              index: selectedIndex,
              backgroundColor: Theme.of(context).colorScheme.surface,
              color: Theme.of(context).colorScheme.inversePrimary,
              animationDuration: const Duration(milliseconds: 250),
              onTap: onItemTapped,
            )
          : null,
      onDrawerChanged: (isOpened) {},
      drawer: !isMobile
          ? Drawer(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inversePrimary),
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ShamParts v$version',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            )
                          ])),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      onItemTapped(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.grid_on),
                    title: const Text('Compounds'),
                    onTap: () {
                      onItemTapped(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: const Text('Parts'),
                    onTap: () {
                      onItemTapped(2);
                    },
                  ),
                  Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: Column(
                        children: <Widget>[
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text('Settings'),
                            onTap: () {
                              onItemTapped(3);
                            },
                          ),
                        ],
                      )),
                ],
              ),
            )
          : null,
    );
  }
}
