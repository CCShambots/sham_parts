import 'dart:io';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sham_parts/account-pages/accountPage.dart';
import 'package:sham_parts/api-util/apiSession.dart';
import 'package:sham_parts/api-util/onshapeDocument.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/home.dart';
import 'package:sham_parts/part-widgets/PartsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'api-util/project.dart';

const double _bottomPaddingForButton = 150.0;
const double _buttonHeight = 56.0;
const double _buttonWidth = 200.0;
const double _pagePadding = 16.0;
const double _pageBreakpoint = 768.0;
const double _heroImageHeight = 250.0;

void main() {
  runApp(const MyApp());

  APISession.updateKeys();
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShamParts',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Theme.of(context).colorScheme.background,
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

  @override
  void initState() {
    initVersion();
    reloadProjectList(true);

    regenWidgetOptions();

    setState(() {
      selectedIndex = pageViewController.initialPage;
    });
  }

  void regenWidgetOptions() {
    widgetOptions = [
      const Home(),
      PartsPage(project: project),
      AccountPage(user: null, project: project,)
    ];
  }

  void initVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();

    print(info.version);

    setState(() {
      version = info.version;
    });
  }

  void reloadProjectList(bool shouldLoadProject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String projectKey = prefs.getString(APIConstants().currentProject) ?? "";

    List<String> projectList = await Project.loadProjects();

    if (projectList.isEmpty) {
      projectList = ["NO PROJECT"];
    }

    setState(() {
      projectKeys = projectList;
    });

    if (projectKey == "" && projectKeys.isNotEmpty) {
      //Make the user select project
      //TODO: Select project dialog
    } else if (shouldLoadProject) {
      loadProject(projectKey);
    }
  }

  void loadProject(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(APIConstants().currentProject, key);

    Project activeProject = await Project.loadProject(key);

    print("Loaded Project");

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
        await OnshapeDocument.queryDocuments(currentQuery, () {
      reloadProjectList(false);
    });

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
        title: const Text("ShamParts"),
        actions: [
          Padding(
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
                    child: Icon(Icons.list), label: 'Parts'),
                CurvedNavigationBarItem(
                    child: Icon(Icons.account_circle), label: 'Account')
              ],
              index: selectedIndex,
              backgroundColor: Theme.of(context).colorScheme.background,
              color: Theme.of(context).colorScheme.inversePrimary,
              animationDuration: const Duration(milliseconds: 250),
              onTap: onItemTapped,
            )
          : null,
      onDrawerChanged: (isOpened) {
        reloadProjectList(true);
      },
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ShamParts v$version',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            DropdownMenu<String>(
                                label: const Text('Active Project'),
                                controller: activeProjectController,
                                initialSelection: project.name,
                                onSelected: (val) {
                                  loadProject(val ?? "");
                                },
                                menuStyle: const MenuStyle(
                                    minimumSize: MaterialStatePropertyAll(
                                        Size.fromWidth(200))),
                                dropdownMenuEntries: List.generate(
                                  projectKeys.length,
                                  (index) => DropdownMenuEntry(
                                    value: projectKeys[index],
                                    label: projectKeys[index],
                                  ),
                                ))
                          ])),
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      onItemTapped(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: const Text('Parts'),
                    onTap: () {
                      onItemTapped(1);
                    },
                  ),
                  Container(
                      child: Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: Column(
                            children: <Widget>[
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.account_circle),
                                title: const Text('Account'),
                                onTap: () {
                                  onItemTapped(2);
                                },
                              ),
                            ],
                          ))),
                ],
              ),
            )
          : null,
    );
  }
}
