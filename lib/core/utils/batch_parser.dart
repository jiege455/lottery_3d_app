import 'dart:async';
import '../constants/play_types.dart';
import '../../models/bet_record.dart';
import 'package:flutter/material.dart';

class ParsedItem {
  final String number;
  final String playType;
  final String playTypeName;
  double multiplier;
  Color color;
  double baseAmount;

  ParsedItem({
    required this.number,
    required this.playType,
    required this.playTypeName,
    this.multiplier = 1.0,
    required this.color,
    this.baseAmount = 2.0,
  });
}

class BatchParser {
  static const int previewMax = 50;
  static const Set<String> separators = {',', '、', '\t'};
  static final RegExp _multiplierRegex = RegExp(r'[*×x](\d+\.?\d*)$');

  static final Map<String, String> _prefixLookup = () {
    final map = <String, String>{};
    for (final pt in PlayTypes.all) {
      map['${pt.name}:'] = pt.code;
      map['${pt.name}：'] = pt.code;
    }
    for (var i = 0; i <= 9; i++) {
      map['${i}跨:'] = 'span$i';
      map['${i}跨：'] = 'span$i';
    }
    return map;
  }();

  static List<ParsedItem> parse(String input, {String? forcePlayType, double defaultMultiplier = 1.0}) {
    if (input.trim().isEmpty) return [];
    final results = <ParsedItem>[];
    final lines = input.split('\n').where((l) => l.trim().isNotEmpty).toList();
    for (final line in lines) {
      final items = _parseLine(line.trim(), forcePlayType: forcePlayType, defaultMultiplier: defaultMultiplier);
      results.addAll(items);
    }
    return results;
  }

  static List<ParsedItem> _parseLine(String line, {String? forcePlayType, double defaultMultiplier = 1.0}) {
    final config = forcePlayType != null ? PlayTypes.getByCode(forcePlayType) : null;
    if (config != null && config.isWholeLine) return [_createItem(line, config, defaultMultiplier)];
    final prefixMatch = _detectPrefix(line);
    if (prefixMatch != null) return _parseWithPrefix(line, prefixMatch, defaultMultiplier);
    if (forcePlayType != null) return _splitAndCreate(line, PlayTypes.getByCode(forcePlayType)!, defaultMultiplier);
    final detected = _autoDetectPlayType(line);
    if (detected != null) {
      final pc = PlayTypes.getByCode(detected);
      if (pc == null) return _splitAndCreate(line, PlayTypes.getByCode('single')!, defaultMultiplier);
      if (pc.isWholeLine) return [_createItem(line, pc, defaultMultiplier)];
      return _splitAndCreate(line, pc, defaultMultiplier);
    }
    return _splitAndCreate(line, PlayTypes.getByCode('single')!, defaultMultiplier);
  }

  static String? _detectPrefix(String line) {
    for (final entry in _prefixLookup.entries) {
      if (line.startsWith(entry.key)) return entry.value;
    }
    return null;
  }

  static List<ParsedItem> _parseWithPrefix(String line, String playTypeCode, double defaultMultiplier) {
    final colonIndex = line.indexOf(RegExp('[：:]'));
    final content = line.substring(colonIndex + 1).trim();
    final config = PlayTypes.getByCode(playTypeCode);
    if (config == null) return _splitAndCreate(content, PlayTypes.getByCode('single')!, defaultMultiplier);
    if (config.isWholeLine) return [_createItem(content, config, defaultMultiplier)];
    return _splitAndCreate(content, config, defaultMultiplier);
  }

  static String? _autoDetectPlayType(String line) {
    final clean = line.replaceAll(RegExp(r'[ *×x]\d+\.?\d*$'), '').trim();
    if (clean == '大' || clean == '小') return 'bigsmall';
    if (clean == '单' || clean == '双') return 'oddeven';
    if (RegExp(r'^[0-9]$').hasMatch(clean)) return 'dan';
    if (RegExp(r'^(百|十|个)位,\d$').hasMatch(clean)) return 'pos1';
    if (RegExp(r'^(前两位|后两位|首尾),\d{2}$').hasMatch(clean)) return 'pos2';
    if (RegExp(r'^\d{3},\d{3}$').hasMatch(clean)) {
      final parts = clean.split(',');
      final hasPair = _hasDuplicateDigit(parts[0]) || _hasDuplicateDigit(parts[1]);
      return hasPair ? 'shuangfei_g3' : 'shuangfei_g6';
    }
    if (RegExp(r'^\d{3}$').hasMatch(clean)) return _hasDuplicateDigit(clean) ? 'group3' : 'group6';
    final digitsOnly = clean.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length >= 2 && digitsOnly.length <= 9) {
      final uniqueDigits = digitsOnly.split('').toSet().length;
      if (uniqueDigits >= 2 && uniqueDigits <= 9 && uniqueDigits == digitsOnly.length) {
        if (uniqueDigits <= 3) return 'g3_$uniqueDigits';
        return 'g6_$uniqueDigits';
      }
    }
    final numVal = int.tryParse(clean);
    if (numVal != null && numVal >= 0 && numVal <= 27) return 'sum_$numVal';
    return null;
  }

  static bool _hasDuplicateDigit(String s) => s.split('').toSet().length < s.length;

  static List<ParsedItem> _splitAndCreate(String content, PlayTypeConfig config, double defaultMultiplier) {
    final parts = _splitContent(content);
    final items = <ParsedItem>[];
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final mult = _extractMultiplier(trimmed);
      final numStr = trimmed.replaceAll(_multiplierRegex, '').trim();
      if (numStr.isEmpty) continue;
      items.add(ParsedItem(number: numStr, playType: config.code, playTypeName: config.name, multiplier: mult ?? defaultMultiplier, color: config.color, baseAmount: config.baseAmount));
    }
    return items;
  }

  static List<String> _splitContent(String content) {
    var result = content;
    for (final sep in separators) result = result.replaceAll(sep, ',');
    result = result.replaceAll(RegExp(r'\s+'), ',');
    result = result.replaceAll(RegExp(r'(?<=\d)-(?=\d)'), ',');
    result = result.replaceAll(RegExp(r'(?<=\d)/'), ',');
    result = result.replaceAll(RegExp(r'(?<=\d{3})\.(?=\d{3})'), ',');
    return result.split(',').where((s) => s.trim().isNotEmpty).toList();
  }

  static double? _extractMultiplier(String text) {
    final match = _multiplierRegex.firstMatch(text);
    return match != null ? double.parse(match.group(1)!) : null;
  }

  static ParsedItem _createItem(String number, PlayTypeConfig config, double multiplier) {
    final mult = _extractMultiplier(number) ?? multiplier;
    final cleanNum = number.replaceAll(_multiplierRegex, '').trim();
    return ParsedItem(number: cleanNum.isEmpty ? number : cleanNum, playType: config.code, playTypeName: config.name, multiplier: mult, color: config.color, baseAmount: config.baseAmount);
  }
}
