import 'dart:io';
import 'package:flutter/material.dart';

class CleanItem {
  final String id;
  final String title;
  final String subtitle;
  final int sizeBytes;
  final IconData icon;
  final List<File> files;
  bool selected;

  CleanItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.sizeBytes,
    required this.icon,
    this.files = const [],
    this.selected = true,
  });

  int get fileCount => files.isNotEmpty ? files.length : 0;

  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} ГБ';
    }
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
    }
    if (sizeBytes >= 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(0)} КБ';
    }
    return '$sizeBytes Б';
  }
}

class DuplicateGroup {
  final String id;
  final List<String> paths;
  final List<File> files;
  final int sizeBytes;
  bool selected;

  DuplicateGroup({
    required this.id,
    required this.paths,
    this.files = const [],
    required this.sizeBytes,
    this.selected = true,
  });

  int get count => paths.length;

  int get reclaimableBytes {
    if (paths.length <= 1) return 0;
    final singleFileSize = sizeBytes ~/ paths.length;
    return singleFileSize * (paths.length - 1);
  }

  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} ГБ';
    }
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
    }
    return '${(sizeBytes / 1024).toStringAsFixed(0)} КБ';
  }

  String get reclaimableLabel {
    final r = reclaimableBytes;
    if (r >= 1024 * 1024 * 1024) {
      return '${(r / (1024 * 1024 * 1024)).toStringAsFixed(2)} ГБ';
    }
    if (r >= 1024 * 1024) {
      return '${(r / (1024 * 1024)).toStringAsFixed(1)} МБ';
    }
    return '${(r / 1024).toStringAsFixed(0)} КБ';
  }
}

class UnusedApp {
  final String name;
  final String packageName;
  final int sizeBytes;
  final DateTime lastUsed;
  final String category;
  bool selected;

  UnusedApp({
    required this.name,
    required this.packageName,
    required this.sizeBytes,
    required this.lastUsed,
    this.category = 'Утилита',
    this.selected = true,
  });

  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} ГБ';
    }
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
    }
    return '${(sizeBytes / 1024).toStringAsFixed(0)} КБ';
  }
}
