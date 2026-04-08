import '../services/check_service.dart';
import '../models/bet_record.dart';
import '../models/draw_record.dart';

void main() {
  print('=' * 70);
  print('福彩 3D/排列三 玩法校验测试');
  print('=' * 70);
  print('');

  int totalTests = 0;
  int passedTests = 0;

  void test(String playType, String playTypeName, String betNumber, String drawNumber, bool shouldWin, String expectedWinType) {
    totalTests++;
    final bet = BetRecord(
      number: betNumber,
      playType: playType,
      playTypeName: playTypeName,
      multiplier: 1.0,
      baseAmount: 2.0,
    );
    final draw = DrawRecord(
      issue: '测试',
      numbers: drawNumber,
      sumValue: DrawRecord.getSumValue(drawNumber),
      span: DrawRecord.getSpan(drawNumber),
      formType: DrawRecord.getFormType(drawNumber),
      drawDate: DateTime.now(),
    );
    final result = CheckService.checkSingle(bet, draw);
    
    bool passed = result.isWin == shouldWin;
    if (shouldWin && result.isWin) {
      passed = result.winType == expectedWinType;
    }
    
    if (passed) passedTests++;
    
    String status = passed ? '✅' : '❌';
    String winLose = result.isWin ? '中' : '未中';
    print('$status ${playTypeName.padRight(12)} | 投注：${betNumber.padRight(10)} | 开奖：$drawNumber | 结果：$winLose ${result.isWin ? "| 中奖类型：${result.winType}" : ""}');
    
    if (!passed) {
      print('   ⚠️  期望：${shouldWin ? "中奖" : "未中"}，实际：${result.isWin ? "中奖" : "未中"}');
      if (shouldWin && result.isWin) {
        print('   ⚠️  期望中奖类型：$expectedWinType，实际：${result.winType}');
      }
    }
  }

  // 基础玩法
  print('【基础玩法】');
  test('single', '直选', '358', '358', true, '直选');
  test('single', '直选', '358', '385', false, '');
  test('group3', '组三', '338', '383', true, '组三');
  test('group3', '组三', '338', '358', false, '');
  test('group6', '组六', '358', '853', true, '组六');
  test('group6', '组六', '358', '338', false, '');
  print('');

  // 胆码玩法
  print('【胆码玩法】');
  test('dan', '独胆', '5', '358', true, '胆码');
  test('dan', '独胆', '2', '358', false, '');
  print('');

  // 定位玩法
  print('【定位玩法】');
  test('pos1', '一码定位', '百位，3', '358', true, '定位胆');
  test('pos1', '一码定位', '十位，5', '358', true, '定位胆');
  test('pos1', '一码定位', '个位，8', '358', true, '定位胆');
  test('pos1', '一码定位', '百位，5', '358', false, '');
  test('pos2', '二码定位', '前两位，35', '358', true, '前两位');
  test('pos2', '二码定位', '后两位，58', '358', true, '后两位');
  test('pos2', '二码定位', '首尾，38', '358', true, '首尾');
  test('pos2', '二码定位', '前两位，38', '358', false, '');
  print('');

  // 双飞玩法
  print('【双飞玩法】');
  test('shuangfei_g3', '双飞组三', '38', '383', true, '双飞组三');
  test('shuangfei_g3', '双飞组三', '38', '358', false, '');
  test('shuangfei_g6', '双飞组六', '358', '853', true, '双飞组六');
  test('shuangfei_g6', '双飞组六', '358', '383', false, '');
  print('');

  // 组三复式
  print('【组三复式】');
  test('g3_2', '组三 2 码', '38', '383', true, '组三 2 码');
  test('g3_3', '组三 3 码', '358', '383', true, '组三 3 码');
  test('g3_4', '组三 4 码', '3589', '383', true, '组三 4 码');
  test('g3_2', '组三 2 码', '38', '358', false, '');
  print('');

  // 组六复式
  print('【组六复式】');
  test('g6_4', '组六 4 码', '3589', '358', true, '组六 4 码');
  test('g6_5', '组六 5 码', '35891', '358', true, '组六 5 码');
  test('g6_4', '组六 4 码', '3589', '383', false, '');
  print('');

  // 通用复式
  print('【通用复式】');
  test('fs_3', '复式 3 码', '358', '358', true, '复式 3 码');
  test('fs_4', '复式 4 码', '3589', '358', true, '复式 4 码');
  test('fs_5', '复式 5 码', '35891', '358', true, '复式 5 码');
  print('');

  // 跨度玩法
  print('【跨度玩法】');
  test('span5', '5 跨', '358', '358', true, '跨度 5');
  test('span0', '0 跨', '555', '555', true, '跨度 0');
  test('span2', '2 跨', '355', '355', true, '跨度 2');
  test('span5', '5 跨', '358', '388', false, '');
  print('');

  // 和值玩法
  print('【和值玩法】');
  test('sum_16', '和值 16', '358', '358', true, '和值 16');
  test('sum_0', '和值 0', '000', '000', true, '和值 0');
  test('sum_27', '和值 27', '999', '999', true, '和值 27');
  test('sum_10', '和值 10', '127', '127', true, '和值 10');
  test('sum_16', '和值 16', '358', '359', false, '');
  print('');

  // 大小单双
  print('【大小单双】');
  test('bigsmall', '大小', '大', '358', true, '大');
  test('bigsmall', '大小', '小', '358', false, '');
  test('bigsmall', '大小', '大', '123', false, '');
  test('bigsmall', '大小', '小', '123', true, '小');
  test('oddeven', '单双', '单', '358', false, '');
  test('oddeven', '单双', '双', '358', true, '双');
  test('oddeven', '单双', '单', '357', true, '单');
  print('');

  // 豹子玩法
  print('【豹子玩法】');
  test('baozi_single', '豹子直选', '555', '555', true, '豹子直选');
  test('baozi_all', '豹子组选', '555', '555', true, '豹子组选');
  test('baozi_all', '豹子组选', '555', '358', false, '');
  print('');

  // 中趣玩法
  print('【中趣玩法】');
  test('zq6_3', '中趣组六 3 码', '358', '358', true, '中趣组六');
  test('zq3_3', '中趣组三 3 码', '358', '383', true, '中趣组三');
  print('');

  // 追伯乐玩法
  print('【追伯乐玩法】');
  test('zbl_g6_3', '追伯乐组六 3 码', '358', '358', true, '追伯乐组六');
  test('zbl_g3_3', '追伯乐组三 3 码', '358', '383', true, '追伯乐组三');
  test('zbl_g6_3', '追伯乐组六 3 码', '358', '383', false, '');
  print('');

  // 胆拖玩法
  print('【胆拖玩法】');
  test('g6_dt3', '组六胆拖 3 码', '3:58', '358', true, '组六胆拖');
  test('g3_dt3', '组三胆拖 3 码', '3:58', '383', true, '组三胆拖');
  test('g6_dt3', '组六胆拖 3 码', '3:58', '383', false, '');
  print('');

  // 总结
  print('');
  print('=' * 70);
  print('测试总结');
  print('=' * 70);
  print('总测试数：$totalTests');
  print('通过测试：$passedTests');
  print('失败测试：${totalTests - passedTests}');
  print('通过率：${(passedTests / totalTests * 100).toStringAsFixed(1)}%');
  print('');
  
  if (passedTests == totalTests) {
    print('🎉 所有测试通过！');
  } else {
    print('⚠️  有 ${totalTests - passedTests} 个测试未通过，请检查！');
  }
  print('=' * 70);
}
