import 'package:flutter/material.dart';
import 'package:stock_count_app/api/api.dart';
import 'package:stock_count_app/components/Layout.dart';
import 'package:stock_count_app/components/SKUName.dart';
import 'package:stock_count_app/models/User.dart';
import 'package:stock_count_app/screens/Dashboard.dart';
import 'package:stock_count_app/util/constant.dart' as constant;
import 'package:stock_count_app/util/dialog.dart';
import 'package:stock_count_app/util/shared_preference_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  static const routeName = "/HistoryPage";

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List history = [];
  int limit = 5;
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  // Date filter variables
  DateTime? fromDate;
  DateTime? toDate;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  User user = User();
  @override
  void initState() {
    super.initState();
    loadUser();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        _loadNextPage();
      }
    });
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferencesHelper.getInstance();
    var userMap = prefs.getMap(constant.userKey);

    if (userMap == null) {
      Navigator.of(context).pushNamed(Dashboard.routeName);
    }
    setState(() {
      user = User.fromJson(userMap!);
    });

    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);

    try {
      // Calculate offset based on the current page
      int offset = (currentPage - 1) * limit;

      var response = await Api.instance.getHistory(
        user.id,
        limit,
        offset,
        fromDate: fromDate != null ? dateFormat.format(fromDate!) : null,
        toDate: toDate != null ? dateFormat.format(toDate!) : null,
      );
      var preHistory = history;

      if (response != null) {
        preHistory.addAll(response['data']['data']);

        setState(() {
          history = preHistory;
          hasMore = response['data']['data'].length == limit;
        });
      }
    } catch (e, stackTrace) {
      print("ERROR: -- ${e}");
      print("STACK TRACE: -- $stackTrace");
    }

    setState(() => isLoading = false);
  }

  Future<void> _loadNextPage() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      currentPage++; // Increment the page instead of offset
    });

    _loadHistory();
  }

  void _refreshHistory() {
    setState(() {
      history = [];
      currentPage = 1;
      hasMore = true;
    });
    _loadHistory();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (fromDate ?? DateTime.now())
          : (toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          fromDate = pickedDate;
          fromDateController.text = dateFormat.format(pickedDate);
        } else {
          toDate = pickedDate;
          toDateController.text = dateFormat.format(pickedDate);
        }
      });
    }
  }

  void _applyFilters() {
    setState(() {
      history = [];
      currentPage = 1;
      hasMore = true;
    });
    _loadHistory();
  }

  void _clearFilters() {
    setState(() {
      fromDate = null;
      toDate = null;
      fromDateController.clear();
      toDateController.clear();
      history = [];
      currentPage = 1;
      hasMore = true;
    });
    _loadHistory();
  }

  void onDelete(dynamic d, int index) {
    showAlert(context, AlertState.warning,
        "Are you sure you want to delete this history?",
        okText: "Yes", cancelText: "No", okCallback: () async {
      print("${d['id']} ${user.id}");
      showFullPageLoader(context);
      var response = await Api.instance.removeCount(d['id'], user.id);
      Navigator.pop(context);
      print(response);
      if (response != null) {
        if (response['status'] == true) {
          history.removeAt(index);
          // history[index]['delete_requested'] = true;
          showAlert(
              context, AlertState.success, "Count removal request successful");
          setState(() {});
        } else {
          showAlert(context, AlertState.error, response['message']);
        }
      } else {
        showAlert(context, AlertState.error,
            "Unable to remove this count, kindly contact admin");
      }
    }, cancelCallback: () {}, showCancel: true);
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
        backgroundColor: constant.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter dialog
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshHistory,
          ),
        ],
      ),
      child: Column(
        children: [
          // Date filter indicator
          if (fromDate != null || toDate != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtered: ${fromDate != null ? dateFormat.format(fromDate!) : 'Any'} to ${toDate != null ? dateFormat.format(toDate!) : 'Any'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _clearFilters,
                    child:
                        const Icon(Icons.close, size: 18, color: Colors.blue),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshHistory();
              },
              child: history.isEmpty && isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : history.isEmpty
                      ? const Center(child: Text('No History found'))
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: history.length + 1,
                          itemBuilder: (context, index) {
                            if (index == history.length) {
                              return hasMore
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
                                  : const SizedBox.shrink();
                            }

                            final d = history[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(31, 156, 156, 156),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Slidable(
                                  key: ValueKey(d['id']), // use a unique key
                                  endActionPane: d['delete_requested'] == null
                                      ? ActionPane(
                                          motion: const DrawerMotion(),
                                          children: [
                                            SlidableAction(
                                              onPressed: (context) =>
                                                  onDelete(d, index),
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              icon: Icons.delete,
                                              label: 'Delete',
                                            ),
                                          ],
                                        )
                                      : null,
                                  child: Container(
                                    child: Stack(
                                      children: [
                                        ListTile(
                                          title: SKUName(
                                              name: d['sku_name'],
                                              countType: d['count_type']),
                                          subtitle: Table(
                                            columnWidths: const {
                                              0: FlexColumnWidth(1),
                                              1: FlexColumnWidth(1),
                                            },
                                            children: [
                                              _buildTableRow(
                                                  "Team:", d['team_name']),
                                              _buildTableRow(
                                                  "Bin:", d['bin_name']),
                                              if (d['created_at'] != null)
                                                _buildTableRow(
                                                    "Date:", d['created_at']),
                                              _buildTableRow(
                                                  "Full Pallet Counted:",
                                                  d['pallet_count']),
                                              _buildTableRow(
                                                  "${d['sku_type'] == 'NFG' ? 'Non Full Pallet count' : 'Quantity'}:",
                                                  d['extras']),
                                              _buildTableRow(
                                                  "Date:", d['timestamp']),
                                            ],
                                          ),
                                        ),
                                        if (d['delete_requested'] != null)
                                          Positioned(
                                            bottom: 0,
                                            child: Container(
                                              color: constant.primaryColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 20),
                                              child: const Text(
                                                  "Delete Requested",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        if (d['other_requested_confirmed'] !=
                                            null)
                                          Positioned(
                                            bottom: 0,
                                            child: Container(
                                              color: constant.primaryColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 20),
                                              child: Text(
                                                  "Deleted by ${d['other_team_name'] ?? ""} team",
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        if (d['other_requested_removal'] !=
                                            null)
                                          Positioned(
                                            bottom: 0,
                                            child: Container(
                                              color: constant.primaryColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 20),
                                              child: Text(
                                                  "Delete requested by ${d['other_team_name'] ?? ""} team",
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )),
                            );
                          },
                        ),
            ),
          ),
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Page $currentPage${hasMore ? ' (Scroll for more)' : ' (End of list)'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, dynamic value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(value.toString()),
      ),
    ]);
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Date Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('From: '),
                  Expanded(
                    child: TextFormField(
                      controller: fromDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: 'Start date',
                        suffixIcon: Icon(Icons.calendar_today),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('To: '),
                  Expanded(
                    child: TextFormField(
                      controller: toDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: 'End date',
                        suffixIcon: Icon(Icons.calendar_today),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _applyFilters();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }
}
