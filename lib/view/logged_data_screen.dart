import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pslab/constants.dart';
import 'package:pslab/others/csv_service.dart';
import 'package:pslab/theme/colors.dart';
import 'package:pslab/view/logged_data_chart_screen.dart';

class LoggedDataScreen extends StatefulWidget {
  final String instrumentName;

  const LoggedDataScreen({super.key, required this.instrumentName});

  @override
  State<LoggedDataScreen> createState() => _LoggedDataScreenState();
}

class _LoggedDataScreenState extends State<LoggedDataScreen> {
  final CsvService _csvService = CsvService();
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });
    final files = await _csvService.getSavedFiles(widget.instrumentName);
    if (mounted) {
      setState(() {
        _files = files;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFile(String filePath, {bool askConfirm = true}) async {
    bool confirmed = true;
    if (askConfirm) {
      confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete File'),
                content:
                    const Text('Are you sure you want to delete this file?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          ) ??
          false;
    }

    if (confirmed) {
      await _csvService.deleteFile(filePath);
      _loadFiles();
    }
  }

  Future<void> _deleteAllFiles() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Data'),
          content: const Text(
              'Are you sure you want to delete all logged data for this instrument?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _csvService.deleteAllFiles(widget.instrumentName);
      _loadFiles();
    }
  }

  Future<void> _openFile(File file) async {
    final data = await _csvService.readCsvFromFile(file);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoggedDataChartScreen(
            data: data,
            fileName: file.path.split('/').last,
          ),
        ),
      );
    }
  }

  Future<void> _pickAndImportFile() async {
    final data = await _csvService.pickAndReadCsvFile();
    if (data != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoggedDataChartScreen(
            data: data,
            fileName: 'Imported Log',
          ),
        ),
      );
    }
  }

  void _showOptionsMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width,
        kToolbarHeight,
        0,
        0,
      ),
      items: [
        const PopupMenuItem(
          value: 'import_log',
          child: Text('Import Log'),
        ),
        const PopupMenuItem(
          value: 'delete_all',
          child: Text('Delete All Data'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'import_log':
            _pickAndImportFile();
            break;
          case 'delete_all':
            _deleteAllFiles();
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          luxMeterTitle,
          style: TextStyle(
            color: appBarContentColor,
            fontSize: 15,
          ),
        ),
        backgroundColor: primaryRed,
        iconTheme: IconThemeData(color: appBarContentColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? Center(
                  child: Text(
                    'No logged data found.',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFiles,
                  child: ListView.builder(
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final file = _files[index] as File;
                      final stat = file.statSync();
                      final fileName = file.path.split('/').last;
                      final formattedDate =
                          DateFormat.yMMMd().add_jm().format(stat.modified);

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        color: Colors.white,
                        margin:
                            const EdgeInsets.only(left: 8, right: 8, top: 8),
                        child: ListTile(
                          onTap: () => _openFile(file),
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Image.asset(
                              'assets/icons/tile_icon_lux_meter.png',
                              color: primaryRed,
                            ),
                          ),
                          title: Text(fileName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${(stat.size / 1024).toStringAsFixed(2)} KB\n$formattedDate'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.share, color: primaryRed),
                                onPressed: () =>
                                    _csvService.shareFile(file.path),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: primaryRed),
                                onPressed: () => _deleteFile(file.path),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
