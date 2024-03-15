import 'dart:io';

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_icon_button.dart';
import 'package:getwidget/components/search_bar/gf_search_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:redacted/redacted.dart';
import 'package:sham_parts/api_util/onshapeDocument.dart';
import 'package:sham_parts/colorTile.dart';
import 'package:sham_parts/home.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

const double _bottomPaddingForButton = 150.0;
const double _buttonHeight = 56.0;
const double _buttonWidth = 200.0;
const double _pagePadding = 16.0;
const double _pageBreakpoint = 768.0;
const double _heroImageHeight = 250.0;
final materialColorsInGrid = allMaterialColors.take(20).toList();
final materialColorsInSliverList = allMaterialColors.sublist(20, 25);
final materialColorsInSpinner = allMaterialColors.sublist(30, 50);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShamParts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Theme.of(context).colorScheme.background,
      ),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
          brightness: Brightness.dark
      ),
      home: const BottomNavigation(),
    );
  }
}

class BottomNavigation extends StatefulWidget {

  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() =>
      BottomNavigationBarState();
}

class BottomNavigationBarState extends State<BottomNavigation> {

  final pageViewController = PageController(initialPage: 0);

  final isMobile = Platform.isAndroid || Platform.isIOS;

  String version = "";

  int selectedIndex = 0;

  TextEditingController documentSearchController = TextEditingController();

  bool searching = false;
  List<OnshapeDocument> docs = [];

  @override
  void initState() {

    initVersion();

    setState(() {
      selectedIndex = pageViewController.initialPage;
    });

  }

  void initVersion() async {
    PackageInfo info = await PackageInfo.fromPlatform();

    print(info.version);

    setState(() {
      version = info.version;
    });
  }

  void onItemTapped(int index) {
    pageViewController.animateToPage(index, duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }

  static List<Widget> widgetOptions = <Widget>[
    Home(),
  ];

  void queryDocuments(BuildContext context, page) async {

    setState(() {
      searching = true;
      docs = [];
    });

    String currentQuery = documentSearchController.value.text;

    List<OnshapeDocument> newDocs = await OnshapeDocument.queryDocuments(currentQuery);

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
                    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  child: SizedBox(
                    height: _buttonHeight,
                    width: double.infinity,
                    child: Center(child: Text('Create', style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),)),
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
              child: Column(children: docs.map((e) {
                return e.searchWidget;
              }).toList())
          )

      );
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
                onPressed: ()
                {
                  queryDocuments(context, page2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: SizedBox(
                  height: _buttonHeight,
                  width: double.infinity,
                  child: Center(child: Text('Search', style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),)),
                )
              ),
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
                            border: OutlineInputBorder(),
                            labelText: "Search"
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (val) {queryDocuments(context, page2);},
                      )
                    )
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
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
                icon: const Icon(Icons.add,),
                tooltip: "Create New Project",
                onPressed: () {
                  showWoltModal(pageIndexNotifier, page1);
                },
              )
          )
        ],
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
      ),
      body: PageView(
        controller: pageViewController,
        children: widgetOptions,
        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: isMobile ? CurvedNavigationBar(
        items: const <CurvedNavigationBarItem>[
          CurvedNavigationBarItem(
            child: Icon(Icons.home),
            label: 'Home',
          ),
          CurvedNavigationBarItem(
              child: Icon(Icons.list),
              label: 'Parts'
          )
        ],
        index: selectedIndex,
        backgroundColor: Theme.of(context).colorScheme.background,
        color: Theme.of(context).colorScheme.inversePrimary,
        animationDuration: const Duration(milliseconds: 250),
        onTap: onItemTapped,
      ) : null,
      drawer: !isMobile ? Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary
              ),
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ShamParts v$version', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Switch Project'),
                    ),
                  ]

                )

            ),
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
          ],
        ),
      ) : null,
    );
  }


}