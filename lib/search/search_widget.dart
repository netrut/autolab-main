import '/backend/backend.dart';
import '/components/main_bottom_nav_bar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'search_model.dart';
export 'search_model.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  static String routeName = 'search';
  static String routePath = '/search';

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late SearchModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _seedSearchTestData(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Seed test data?'),
          content: Text(
            'This will add demo vehicles and service entries for filter testing.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('Add Data'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10, 0, 0);
      final yesterday = today.subtract(Duration(days: 1));
      final last7 = today.subtract(Duration(days: 5));
      final last30 = today.subtract(Duration(days: 22));
      final next7 = today.add(Duration(days: 3));
      final next30 = today.add(Duration(days: 18));

      final batch = FirebaseFirestore.instance.batch();

      final carOneRef =
          VechileDetailsRecord.collection.doc('search_test_car_1001');
      final carTwoRef =
          VechileDetailsRecord.collection.doc('search_test_car_1002');
      final bikeOneRef =
          VechileDetailsRecord.collection.doc('search_test_bike_2001');
      final bikeTwoRef =
          VechileDetailsRecord.collection.doc('search_test_bike_2002');

      batch.set(
        carOneRef,
        createVechileDetailsRecordData(
          name: 'Demo Car One',
          mobile: '9000000001',
          company: 'Honda',
          model: 'City',
          vechileNo: 'GJ01AA1001',
          makeYear: '2021',
          chasisNo: 'TESTCHASISCAR001',
          fuelType: 'Petrol',
          transmission: 'Manual',
          carBike: 'Car',
        ),
        SetOptions(merge: true),
      );
      batch.set(
        carTwoRef,
        createVechileDetailsRecordData(
          name: 'Demo Car Two',
          mobile: '9000000002',
          company: 'Hyundai',
          model: 'i20',
          vechileNo: 'GJ01AA1002',
          makeYear: '2022',
          chasisNo: 'TESTCHASISCAR002',
          fuelType: 'Petrol',
          transmission: 'Automatic',
          carBike: 'Car',
        ),
        SetOptions(merge: true),
      );
      batch.set(
        bikeOneRef,
        createVechileDetailsRecordData(
          name: 'Demo Bike One',
          mobile: '9000000003',
          company: 'Honda',
          model: 'Activa',
          vechileNo: 'GJ01BK2001',
          makeYear: '2023',
          chasisNo: 'TESTCHASISBIKE001',
          fuelType: 'Petrol',
          transmission: 'Auto',
          carBike: 'Bike',
        ),
        SetOptions(merge: true),
      );
      batch.set(
        bikeTwoRef,
        createVechileDetailsRecordData(
          name: 'Demo Bike Two',
          mobile: '9000000004',
          company: 'TVS',
          model: 'Jupiter',
          vechileNo: 'GJ01BK2002',
          makeYear: '2020',
          chasisNo: 'TESTCHASISBIKE002',
          fuelType: 'Petrol',
          transmission: 'Auto',
          carBike: 'Bike',
        ),
        SetOptions(merge: true),
      );

      batch.set(
        CarServiceRecord.collection.doc('search_test_car_today'),
        createCarServiceRecordData(
          vechileNo: 'GJ01AA1001',
          date: today,
          notifications: 'Yes',
        ),
        SetOptions(merge: true),
      );
      batch.set(
        CarServiceRecord.collection.doc('search_test_car_yesterday'),
        createCarServiceRecordData(
          vechileNo: 'GJ01AA1002',
          date: yesterday,
          notifications: 'Yes',
        ),
        SetOptions(merge: true),
      );
      batch.set(
        CarServiceRecord.collection.doc('search_test_car_next_7'),
        createCarServiceRecordData(
          vechileNo: 'GJ01AA1001',
          date: next7,
          notifications: 'Yes',
        ),
        SetOptions(merge: true),
      );
      batch.set(
        CarServiceRecord.collection.doc('search_test_car_next_30'),
        createCarServiceRecordData(
          vechileNo: 'GJ01AA1002',
          date: next30,
          notifications: 'Yes',
        ),
        SetOptions(merge: true),
      );

      batch.set(
        BikeServiceRecord.collection.doc('search_test_bike_last_7'),
        createBikeServiceRecordData(
          vechileNo: 'GJ01BK2001',
          date: last7,
          notifications: 'Yes',
        ),
        SetOptions(merge: true),
      );
      batch.set(
        BikeServiceRecord.collection.doc('search_test_bike_last_30'),
        createBikeServiceRecordData(
          vechileNo: 'GJ01BK2002',
          date: last30,
          notifications: 'Yes',
        ),
        SetOptions(merge: true),
      );

      await batch.commit();

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Test data added. You can now verify all filter options.'),
        ),
      );
      _model.listViewPagingController?.refresh();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add test data: $e'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchModel());

    _model.searchFieldTextController ??= TextEditingController();
    _model.searchFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery =
        _model.searchFieldTextController.text.toLowerCase().trim();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF3F3F3),
        appBar: AppBar(
          backgroundColor: Color(0xFFF3F3F3),
          iconTheme: IconThemeData(color: Color(0xFF2A2A2A)),
          automaticallyImplyLeading: true,
          title: Text(
            'SEARCH',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleMedium.fontStyle,
                  ),
                  color: Color(0xFF1F1F1F),
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 10.0, 8.0),
              child: FFButtonWidget(
                onPressed: () async {
                  await _seedSearchTestData(context);
                },
                text: 'Seed Data',
                options: FFButtonOptions(
                  height: 34.0,
                  padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: Color(0xFF1F1F1F),
                  textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodySmall.fontStyle,
                        ),
                        color: Colors.white,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
          centerTitle: true,
          elevation: 0.0,
        ),
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: 2,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(10.0, 6.0, 10.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(2.0, 2.0, 2.0, 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search Vehicles',
                        style:
                            FlutterFlowTheme.of(context).headlineSmall.override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .fontStyle,
                                  ),
                                  color: Color(0xFF1E1E1E),
                                  fontSize: 30.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      Text(
                        'Find your vehicle and open service or history in one tap',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              color: Color(0xFF7A7A7A),
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.0),
                Container(
                  height: 46.0,
                  decoration: BoxDecoration(
                    color: Color(0xFFEFEFEF),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Color(0xFFDCDCDC),
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 8.0, 0.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: Color(0xFF8B8B8B),
                          size: 22.0,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _model.searchFieldTextController,
                            focusNode: _model.searchFieldFocusNode,
                            onChanged: (_) => EasyDebounce.debounce(
                              '_model.searchFieldTextController',
                              Duration(milliseconds: 350),
                              () {
                                _model.searchText =
                                    _model.searchFieldTextController.text;
                                safeSetState(() {});
                              },
                            ),
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Search vehicle number or mobile',
                              hintStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF8A8A8A),
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  10.0, 0.0, 10.0, 0.0),
                              suffixIcon: _model.searchFieldTextController!.text
                                      .isNotEmpty
                                  ? InkWell(
                                      onTap: () async {
                                        _model.searchFieldTextController
                                            ?.clear();
                                        _model.searchText = _model
                                            .searchFieldTextController.text;
                                        safeSetState(() {});
                                      },
                                      child: Icon(
                                        Icons.clear,
                                        color: Color(0xFF7A7A7A),
                                        size: 20.0,
                                      ),
                                    )
                                  : null,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: Color(0xFF2B2B2B),
                                  letterSpacing: 0.0,
                                ),
                            textAlign: TextAlign.start,
                            validator: _model.searchFieldTextControllerValidator
                                .asValidator(context),
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(FilterWidget.routeName);
                          },
                          child: Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: BoxDecoration(
                              color: Color(0xFFE3E3E3),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: Color(0xFF2A2A2A),
                              size: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.0),
                Expanded(
                  child: PagedListView<DocumentSnapshot<Object?>?,
                      VechileDetailsRecord>(
                    pagingController: _model.setListViewController(
                      VechileDetailsRecord.collection,
                    ),
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
                    primary: false,
                    shrinkWrap: false,
                    reverse: false,
                    scrollDirection: Axis.vertical,
                    builderDelegate:
                        PagedChildBuilderDelegate<VechileDetailsRecord>(
                      firstPageProgressIndicatorBuilder: (_) => Center(
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      ),
                      newPageProgressIndicatorBuilder: (_) => Center(
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                      ),
                      noItemsFoundIndicatorBuilder: (_) => Center(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 40.0, 0.0, 0.0),
                          child: Text(
                            'No vehicles found',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: Color(0xFF7A7A7A),
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ),
                      ),
                      itemBuilder: (context, _, listViewIndex) {
                        final record = _model
                            .listViewPagingController!.itemList![listViewIndex];
                        final matchesQuery = searchQuery.isEmpty ||
                            record.vechileNo
                                .toLowerCase()
                                .contains(searchQuery) ||
                            record.carBike
                                .toLowerCase()
                                .contains(searchQuery) ||
                            record.mobile.toLowerCase().contains(searchQuery);

                        if (!matchesQuery) {
                          return SizedBox.shrink();
                        }

                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 10.0),
                          child: Container(
                            width: double.infinity,
                            height: 144.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: Color(0xFFE4E4E4),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10.0,
                                  color: Color(0x14000000),
                                  offset: Offset(0.0, 4.0),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      12.0, 12.0, 10.0, 12.0),
                                  child: Container(
                                    width: 112.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF3F3F3),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Image.asset(
                                        record.carBike == 'Car'
                                            ? 'assets/images/four-wheeler.png'
                                            : 'assets/images/two-wheeler.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 12.0, 12.0, 12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record.vechileNo,
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .titleMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF232323),
                                                fontSize: 17.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          '${record.carBike} • ${record.mobile}',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF7A7A7A),
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        Spacer(),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: FFButtonWidget(
                                                onPressed: () async {
                                                  if (record.carBike == 'Car') {
                                                    context.pushNamed(
                                                      ServiceForm2Widget
                                                          .routeName,
                                                      queryParameters: {
                                                        'vechileNo':
                                                            serializeParam(
                                                          record.vechileNo,
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  } else {
                                                    context.pushNamed(
                                                      ServiceForm1Widget
                                                          .routeName,
                                                      queryParameters: {
                                                        'vechileNo':
                                                            serializeParam(
                                                          record.vechileNo,
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  }
                                                },
                                                text: 'Service',
                                                options: FFButtonOptions(
                                                  height: 34.0,
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          16.0, 0.0, 16.0, 0.0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0.0, 0.0,
                                                              0.0, 0.0),
                                                  color: Color(0xFF1F1F1F),
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .bodySmall
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color: Colors.white,
                                                        fontSize: 12.5,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                  elevation: 0.0,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8.0),
                                            Expanded(
                                              child: FFButtonWidget(
                                                onPressed: () async {
                                                  if (record.carBike == 'Car') {
                                                    context.pushNamed(
                                                      HistoryCarWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'vechileNo':
                                                            serializeParam(
                                                          record.vechileNo,
                                                          ParamType.String,
                                                        ),
                                                        'carBike':
                                                            serializeParam(
                                                          record.carBike,
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  } else {
                                                    context.pushNamed(
                                                      HistoryBikeWidget
                                                          .routeName,
                                                      queryParameters: {
                                                        'vechileNo':
                                                            serializeParam(
                                                          record.vechileNo,
                                                          ParamType.String,
                                                        ),
                                                        'carBike':
                                                            serializeParam(
                                                          record.carBike,
                                                          ParamType.String,
                                                        ),
                                                      }.withoutNulls,
                                                    );
                                                  }
                                                },
                                                text: 'History',
                                                options: FFButtonOptions(
                                                  height: 34.0,
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          16.0, 0.0, 16.0, 0.0),
                                                  iconPadding:
                                                      EdgeInsetsDirectional
                                                          .fromSTEB(0.0, 0.0,
                                                              0.0, 0.0),
                                                  color: Colors.white,
                                                  textStyle: FlutterFlowTheme
                                                          .of(context)
                                                      .bodySmall
                                                      .override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodySmall
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            Color(0xFF1F1F1F),
                                                        fontSize: 12.5,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                  elevation: 0.0,
                                                  borderSide: BorderSide(
                                                    color: Color(0xFF1F1F1F),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
