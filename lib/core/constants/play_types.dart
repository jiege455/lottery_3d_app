import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlayTypeConfig {
  final String code;
  final String name;
  final String category;
  final String ruleText;
  final String example;
  final bool isWholeLine;
  final Color color;
  final double baseAmount;

  const PlayTypeConfig({
    required this.code,
    required this.name,
    required this.category,
    required this.ruleText,
    required this.example,
    this.isWholeLine = false,
    required this.color,
    this.baseAmount = 2.0,
  });
}

class PlayTypes {
  static const List<PlayTypeConfig> all = [
    PlayTypeConfig(code: 'single', name: '直选', category: '基础三码',
      ruleText: '输入3位数字，顺序需一致', example: '358', color: Color(0xFF4F46E5)),
    PlayTypeConfig(code: 'group3', name: '组三', category: '基础三码',
      ruleText: '输入3位数字，含对子即可', example: '112,336', color: Color(0xFF4F46E5)),
    PlayTypeConfig(code: 'group6', name: '组六', category: '基础三码',
      ruleText: '输入3位数字，各不相同', example: '258,369', color: Color(0xFF4F46E5)),

    PlayTypeConfig(code: 'dan', name: '独胆', category: '定位',
      ruleText: '输入1个数字，任一位开出即中', example: '5', color: Color(0xFF7C3AED), baseAmount: 10.0),
    PlayTypeConfig(code: 'pos1', name: '一码定位', category: '定位',
      ruleText: '输入位置+数字，如"百位,5"', example: '百位,5', color: Color(0xFF7C3AED), baseAmount: 10.0),
    PlayTypeConfig(code: 'pos2', name: '二码定位', category: '定位',
      ruleText: '输入两位置+数字，如"前两位,35"', example: '前两位,35', color: Color(0xFF7C3AED), baseAmount: 10.0),

    PlayTypeConfig(code: 'shuangfei_g3', name: '双飞对子', category: '双飞',
      ruleText: '开出对子形态(组三)，整行=1条', example: '112,223', isWholeLine: true, color: Color(0xFFDC2626), baseAmount: 10.0),
    PlayTypeConfig(code: 'shuangfei_g6', name: '双飞组六', category: '双飞',
      ruleText: '开出非对子形态(组六)，整行=1条', example: '123,456', isWholeLine: true, color: Color(0xFFDC2626), baseAmount: 10.0),

    PlayTypeConfig(code: 'g3_2', name: '组三2码', category: '组三复式',
      ruleText: '输入2个不同数字，自动排列成组三', example: '15', color: Color(0xFFF59E0B), baseAmount: 10.0),
    PlayTypeConfig(code: 'g3_3', name: '组三3码', category: '组三复式',
      ruleText: '输入3个不同数字，生成所有组三组合', example: '158', color: Color(0xFFF59E0B), baseAmount: 10.0),
    PlayTypeConfig(code: 'g3_4', name: '组三4码', category: '组三复式',
      ruleText: '输入4个不同数字，生成所有组三组合', example: '1358', color: Color(0xFFF59E0B), baseAmount: 10.0),
    PlayTypeConfig(code: 'g3_5', name: '组三5码', category: '组三复式',
      ruleText: '输入5个不同数字，生成所有组三组合', example: '13578', color: Color(0xFFF59E0B), baseAmount: 10.0),
    PlayTypeConfig(code: 'g3_6', name: '组三6码', category: '组三复式',
      ruleText: '输入6个不同数字，生成所有组三组合', example: '123578', color: Color(0xFFF59E0B), baseAmount: 10.0),
    PlayTypeConfig(code: 'g3_7', name: '组三7码', category: '组三复式',
      ruleText: '输入7个不同数字，生成所有组三组合', example: '1235678', color: Color(0xFFF59E0B), baseAmount: 10.0),
    PlayTypeConfig(code: 'g3_8', name: '组三8码', category: '组三复式',
      ruleText: '输入8个不同数字，生成所有组三组合', example: '12345678', color: Color(0xFFF59E0B), baseAmount: 10.0),
    PlayTypeConfig(code: 'g3_9', name: '组三9码', category: '组三复式',
      ruleText: '输入9个不同数字，生成所有组三组合', example: '123456789', color: Color(0xFFF59E0B), baseAmount: 10.0),
    PlayTypeConfig(code: 'g3_all', name: '组三全包', category: '组三复式',
      ruleText: '全包所有组三组合（270注）', example: '-', color: Color(0xFFF59E0B), baseAmount: 10.0),

    PlayTypeConfig(code: 'g6_4', name: '组六4码', category: '组六复式',
      ruleText: '输入4个不同数字，生成所有组六组合', example: '1358', color: Color(0xFF059669), baseAmount: 10.0),
    PlayTypeConfig(code: 'g6_5', name: '组六5码', category: '组六复式',
      ruleText: '输入5个不同数字，生成所有组六组合', example: '13578', color: Color(0xFF059669), baseAmount: 10.0),
    PlayTypeConfig(code: 'g6_6', name: '组六6码', category: '组六复式',
      ruleText: '输入6个不同数字，生成所有组六组合', example: '123578', color: Color(0xFF059669), baseAmount: 10.0),
    PlayTypeConfig(code: 'g6_7', name: '组六7码', category: '组六复式',
      ruleText: '输入7个不同数字，生成所有组六组合', example: '1235678', color: Color(0xFF059669), baseAmount: 10.0),
    PlayTypeConfig(code: 'g6_8', name: '组六8码', category: '组六复式',
      ruleText: '输入8个不同数字，生成所有组六组合', example: '12345678', color: Color(0xFF059669), baseAmount: 10.0),
    PlayTypeConfig(code: 'g6_9', name: '组六9码', category: '组六复式',
      ruleText: '输入9个不同数字，生成所有组六组合', example: '123456789', color: Color(0xFF059669), baseAmount: 10.0),
    PlayTypeConfig(code: 'g6_all', name: '组六全包', category: '组六复式',
      ruleText: '全包所有组六组合（120注）', example: '-', color: Color(0xFF059669), baseAmount: 10.0),

    PlayTypeConfig(code: 'fs_3', name: '复式3码', category: '通用复式',
      ruleText: '输入3个数字，包含直选和组选', example: '158', color: Color(0xFF0D9488), baseAmount: 10.0),
    PlayTypeConfig(code: 'fs_4', name: '复式4码', category: '通用复式',
      ruleText: '输入4个数字，包含直选和组选', example: '1358', color: Color(0xFF0D9488), baseAmount: 10.0),
    PlayTypeConfig(code: 'fs_5', name: '复式5码', category: '通用复式',
      ruleText: '输入5个数字，包含直选和组选', example: '13578', color: Color(0xFF0D9488), baseAmount: 10.0),
    PlayTypeConfig(code: 'fs_6', name: '复式6码', category: '通用复式',
      ruleText: '输入6个数字，包含直选和组选', example: '123578', color: Color(0xFF0D9488), baseAmount: 10.0),
    PlayTypeConfig(code: 'fs_7', name: '复式7码', category: '通用复式',
      ruleText: '输入7个数字，包含直选和组选', example: '1235678', color: Color(0xFF0D9488), baseAmount: 10.0),
    PlayTypeConfig(code: 'fs_8', name: '复式8码', category: '通用复式',
      ruleText: '输入8个数字，包含直选和组选', example: '12345678', color: Color(0xFF0D9488), baseAmount: 10.0),
    PlayTypeConfig(code: 'fs_9', name: '复式9码', category: '通用复式',
      ruleText: '输入9个数字，包含直选和组选', example: '123456789', color: Color(0xFF0D9488), baseAmount: 10.0),
    PlayTypeConfig(code: 'fs_all', name: '复式全包', category: '通用复式',
      ruleText: '全包所有组合（1000注）', example: '-', color: Color(0xFF0D9488), baseAmount: 10.0),

    PlayTypeConfig(code: 'span0', name: '0跨', category: '跨度',
      ruleText: '最大值-最小值=0（豹子号）', example: '111,222', isWholeLine: true, color: Color(0xFFEC4899), baseAmount: 10.0),
    PlayTypeConfig(code: 'span1', name: '1跨', category: '跨度',
      ruleText: '最大值-最小值=1', example: '110,121', isWholeLine: true, color: Color(0xFFEC4899), baseAmount: 10.0),
    PlayTypeConfig(code: 'span2', name: '2跨', category: '跨度',
      ruleText: '最大值-最小值=2', example: '200,311', isWholeLine: true, color: Color(0xFFEC4899), baseAmount: 10.0),
    PlayTypeConfig(code: 'span3', name: '3跨', category: '跨度',
      ruleText: '最大值-最小值=3', example: '300,413', isWholeLine: true, color: Color(0xFFEC4899), baseAmount: 10.0),
    PlayTypeConfig(code: 'span4', name: '4跨', category: '跨度',
      ruleText: '最大值-最小值=4', example: '400,514', isWholeLine: true, color: Color(0xFFEC4899), baseAmount: 10.0),
    PlayTypeConfig(code: 'span5', name: '5跨', category: '跨度',
      ruleText: '最大值-最小值=5', example: '500,617', isWholeLine: true, color: Color(0xFFEC4899), baseAmount: 10.0),
    PlayTypeConfig(code: 'span6', name: '6跨', category: '跨度',
      ruleText: '最大值-最小值=6', example: '600,728', isWholeLine: true, color: Color(0xFFEC4899), baseAmount: 10.0),
    PlayTypeConfig(code: 'span7', name: '7跨', category: '跨度',
      ruleText: '最大值-最小值=7', example: '700,809', isWholeLine: true, color: Color(0xFFEC4899), baseAmount: 10.0),
    PlayTypeConfig(code: 'span8', name: '8跨', category: '跨度',
      ruleText: '最大值-最小值=8', example: '800,909', isWholeLine: true, color: Color(0xFFEC4899), baseAmount: 10.0),
    PlayTypeConfig(code: 'span9', name: '9跨', category: '跨度',
      ruleText: '最大值-最小值=9', example: '099,190', isWholeLine: true, color: Color(0xFFEC4899), baseAmount: 10.0),

    PlayTypeConfig(code: 'sum_val', name: '和值', category: '其他',
      ruleText: '输入0-27之间的数字', example: '10,15,20', color: Color(0xFF6366F1), baseAmount: 10.0),
    PlayTypeConfig(code: 'bigsmall', name: '大小', category: '其他',
      ruleText: '输入"大"(和值>=14)或"小"(和值<=13)', example: '大,小', isWholeLine: true, color: Color(0xFF6366F1), baseAmount: 10.0),
    PlayTypeConfig(code: 'oddeven', name: '单双', category: '其他',
      ruleText: '输入"单"(奇数)或"双"(偶数)', example: '单,双', isWholeLine: true, color: Color(0xFF6366F1), baseAmount: 10.0),
  ];

  static PlayTypeConfig? getByCode(String code) {
    try {
      return all.firstWhere((p) => p.code == code);
    } catch (_) {
      return null;
    }
  }

  static List<PlayTypeConfig> getByCategory(String category) {
    return all.where((p) => p.category == category).toList();
  }

  static const List<String> categories = ['基础三码', '定位', '双飞', '组三复式', '组六复式', '通用复式', '跨度', '其他'];

  static Set<String> get wholeLineCodes =>
      all.where((p) => p.isWholeLine).map((p) => p.code).toSet();
}
