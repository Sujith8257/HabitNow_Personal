import 'package:home_widget/home_widget.dart';
import 'package:habit_now/src/utils/models/task_model.dart';

class WidgetSyncService {
  static const String _compactWidgetProvider = 'HabitNowCompactWidgetProvider';
  static const String _listWidgetProvider = 'HabitNowListWidgetProvider';

  static Future<void> syncTasks(List<TaskModel> tasks) async {
    final sorted = [...tasks]..sort((a, b) => a.date.compareTo(b.date));
    final pendingCount = sorted.where((task) => task.isPendingTask).length;
    final completedCount = sorted.length - pendingCount;

    final lines = sorted
        .take(6)
        .map((task) => "- ${task.name}")
        .toList()
        .join('\n');

    await HomeWidget.saveWidgetData<String>('widget_title', 'HabitNow');
    await HomeWidget.saveWidgetData<String>(
      'widget_subtitle',
      '$pendingCount pending • $completedCount completed',
    );
    await HomeWidget.saveWidgetData<String>(
      'widget_tasks_lines',
      lines.isEmpty ? '- No tasks yet' : lines,
    );
    await HomeWidget.saveWidgetData<String>(
      'widget_footer',
      'Total tasks: ${sorted.length}',
    );

    await HomeWidget.updateWidget(androidName: _compactWidgetProvider);
    await HomeWidget.updateWidget(androidName: _listWidgetProvider);
  }

  static Future<void> pinListWidget() async {
    final isSupported = await HomeWidget.isRequestPinWidgetSupported();
    if (isSupported != true) return;
    await HomeWidget.requestPinWidget(androidName: _listWidgetProvider);
  }
}
