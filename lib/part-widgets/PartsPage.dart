import 'package:flutter/material.dart';
import 'package:sham_parts/api-util/part.dart';
import 'package:sham_parts/api-util/project.dart';
import 'package:sham_parts/api-util/user.dart';
import 'package:sham_parts/constants.dart';
import 'package:sham_parts/expandable-fab/ExpandableFab.dart';
import 'package:sham_parts/part-widgets/MergeDisplay.dart';

class PartsPage extends StatefulWidget {
  final Project project;

  const PartsPage({super.key, required this.project});

  @override
  State<PartsPage> createState() => PartsPageState();
}

typedef PartPredicate = bool Function(Part part);

class PartsPageState extends State<PartsPage> {
  List<Part> currentParts = [];

  late List<User> users = [];
  List<String> partTypes = [];
  List<String> availableMaterials = [];

  bool loadingImages = false;
  int partsWithLoadedImages = 0;

  bool showImages = false;

  //Filters
  List<PartPredicate> partFilters = [];

  bool userFilterEnabled = false;
  int userIdToFilter = 0;

  bool partTypeFilterEnabled = false;
  String partTypeToFilter = "";

  bool materialFilterEnabled = false;
  String materialToFilter = "";

  bool nameFilterEnabled = false;
  String nameToFilter = "";

  bool combineFilterEnabled = false;

  bool filterForFinished = false;

  bool filterForMissing = false;

  bool filterForRequested = false;

  @override
  void initState() {
    super.initState();

    loadUsers();
    loadPartTypes();

    setState(() {
      currentParts = widget.project.parts;
      availableMaterials = widget.project.getMaterials();
      partsWithLoadedImages = currentParts
          .where((element) => element.thumbnail != "unloaded")
          .length;
    });
  }

  void loadPartTypes() async {
    List<String> types = await Part.getPartTypes();
    if (mounted) {
      setState(() {
        partTypes = types;
      });
    }
  }

  void loadUsers() async {
    List<User> result = await User.getAllUsers();

    if (mounted) {
      setState(() {
        users = result;
      });
    }
  }

  void loadPhotos(BuildContext context) async {
    if (mounted) {
      setState(() {
        loadingImages = true;
        partsWithLoadedImages = currentParts
            .where((element) => element.thumbnail != "unloaded")
            .length;
      });
    }

    for (var part in widget.project.parts) {
      if (part.thumbnail == "unloaded") {
        part.loadThumbnail().then((value) => {
              if (value)
                {
                  APIConstants.showSuccessToast(
                      "Loaded Image for ${part.number}", context)
                }
              else
                {
                  APIConstants.showErrorToast(
                      "Failed to Load Image for ${part.number}", context)
                }
            });
      }
    }
  }

  void reload() {
    setState(() {});
  }

  void openFilterPageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            
            insetPadding: const EdgeInsets.all(24),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  reload();
                },
                child: const Text("Close"),
              ),
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Filter Parts",
                  style: StyleConstants.subtitleStyle,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: userFilterEnabled,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            userFilterEnabled = value;
                          });
                        }
                      },
                    ),
                    const Text('User'),
                    DropdownButton<User>(
                      value: users.firstWhere((e) => e.id == userIdToFilter,
                          orElse: () => users[
                              0]), // Replace null with the selected user value
                      onChanged: (User? newValue) {
                        if (newValue != null) {
                          setState(() {
                            userFilterEnabled = true;
                            userIdToFilter = newValue.id;
                          });
                        }
                      },
                      items: users.map<DropdownMenuItem<User>>((User user) {
                        return DropdownMenuItem<User>(
                          value: user,
                          child: Text(user.name),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: partTypeFilterEnabled,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            partTypeFilterEnabled = value;
                          });
                        }
                      },
                    ),
                    const Text('Part Type'),
                    DropdownButton<String>(
                      value:
                          partTypeToFilter.isNotEmpty ? partTypeToFilter : null,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            partTypeFilterEnabled = true;
                            partTypeToFilter = newValue;
                          });
                        }
                      },
                      items: partTypes
                          .map<DropdownMenuItem<String>>((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: materialFilterEnabled,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            materialFilterEnabled = value;
                          });
                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Material'),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value:
                            materialToFilter.isNotEmpty ? materialToFilter : null,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              materialFilterEnabled = true;
                              materialToFilter = newValue;
                            });
                          }
                        },
                        items: availableMaterials
                            .map<DropdownMenuItem<String>>((String material) {
                          return DropdownMenuItem<String>(
                            value: material,
                            child: FittedBox(fit: BoxFit.contain, child: Text(material)),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: nameFilterEnabled,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            nameFilterEnabled = value;
                          });
                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Name'),
                    ),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            nameFilterEnabled = true;
                            nameToFilter = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: combineFilterEnabled,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            combineFilterEnabled = value;
                          });
                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Merged Parts"),
                    ),
                    Container()
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: filterForFinished,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            filterForFinished = value;

                            if(value) {
                              filterForMissing = false;
                            }
                          });


                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Have All Required"),
                    ),
                    Container()
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: filterForMissing,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            filterForMissing = value;

                            if(value) {
                              filterForFinished = false;
                            }
                          });

                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Missing Some"),
                    ),
                    Container()
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: filterForRequested,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            filterForRequested = value;   
                          });

                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Some Requested"),
                    ),
                    Container()
                  ],
                ),
              ],
            ),
          );
        });
      },
    ).then((e) {
      setState(() {
        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return const SizedBox.shrink();

    List<Part> filteredParts = widget.project.parts.where((part) {
      bool passUserFilter =
          !userFilterEnabled || part.asigneeId == userIdToFilter;
      bool passPartTypeFilter =
          !partTypeFilterEnabled || part.partType == partTypeToFilter;
      bool passMaterialFilter =
          !materialFilterEnabled || part.material.contains(materialToFilter);
      bool passNameFilter = !nameFilterEnabled ||
          part.number
              .replaceAll(' ', '')
              .toLowerCase()
              .contains(nameToFilter.replaceAll(' ', '').toLowerCase());

      bool combineFilter = !combineFilterEnabled || part.numCombines > 0;

      bool finishedFilter = !filterForFinished || part.quantityInStock >= part.quantityNeeded;
      bool missingFilter = !filterForMissing || part.quantityInStock < part.quantityNeeded;
      bool requestedFilter = !filterForRequested || part.quantityRequested > 0;

      return passUserFilter &&
          passPartTypeFilter &&
          passMaterialFilter &&
          passNameFilter &&
          combineFilter &&
          finishedFilter &&
          missingFilter &&
          requestedFilter
          ;
    }).toList();

    return Scaffold(
      body: ListView(
        children: filteredParts.map((e) => e.partListDisplay).toList(),
      ),
      floatingActionButton: ExpandableFab(
        distance: 112,
        children: [
          ActionButton(
            onPressed: () => {
              loadPhotos(context),
            },
            icon: const Icon(Icons.photo),
            message: "Load Photos",
          ),
          ActionButton(
            onPressed: () => {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MergePage(project: widget.project))),
            },
            icon: const Icon(Icons.merge),
            message: "Merge Duplicates",
          ),
          ActionButton(
            onPressed: () => {openFilterPageDialog(context)},
            icon: const Icon(Icons.filter_alt),
            message: "Filter",
          ),
        ],
      ),
    );
  }
}
