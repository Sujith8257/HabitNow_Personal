import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_now/src/cubit/tasks_cubits/tasks_database_cubit.dart.dart';
import 'package:habit_now/src/presentation/shared/components/BottomNavbar.dart';
import 'package:habit_now/src/presentation/tasks/tasks_page.dart';
import 'package:habit_now/src/utils/const.dart';
import 'package:habit_now/src/utils/extentions.dart';
import 'package:habit_now/src/utils/models/task_model.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const CustomFloatingActionButton(),
      bottomNavigationBar: const CustomBottomNavBar(),
      appBar: AppBar(
        title: const Text('Habits'),
      ),
      body: BlocBuilder<TasksDatabaseCubit, List<TaskModel>>(
        builder: (context, tasks) {
          if (tasks.isEmpty) {
            return const _HabitsEmptyState();
          }

          final now = DateTime.now();
          final todayTasks = tasks.where((task) => _isSameDay(task.date, now)).toList();
          final completedToday = todayTasks.where((task) => !task.isPendingTask).length;
          final completionRate = todayTasks.isEmpty ? 0.0 : completedToday / todayTasks.length;
          final completionLabel = "${(completionRate * 100).round()}%";
          final activeHabits = tasks.where((task) => task.isPendingTask).length;

          final upcoming = tasks
              .where((task) => task.reminder.type != ReminderTime.dontRemind)
              .toList()
            ..sort((a, b) => a.reminder.time.compareTo(b.reminder.time));

          final categoryCounts = <String, int>{};
          for (final task in tasks) {
            categoryCounts.update(task.category.name, (value) => value + 1, ifAbsent: () => 1);
          }
          final sortedCategories = categoryCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView(
            padding: EdgeInsets.all(context.width * 0.04),
            children: [
              _OverviewCard(
                title: "Today's progress",
                subtitle: "$completedToday of ${todayTasks.length} done",
                value: completionLabel,
                progress: completionRate,
              ),
              SizedBox(height: context.height * 0.018),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: "Active",
                      value: activeHabits.toString(),
                      icon: Icons.local_fire_department_outlined,
                    ),
                  ),
                  SizedBox(width: context.width * 0.03),
                  Expanded(
                    child: _StatCard(
                      title: "Completed",
                      value: completedToday.toString(),
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.height * 0.025),
              const _SectionTitle("Top categories"),
              SizedBox(height: context.height * 0.01),
              ...sortedCategories.take(4).map(
                (entry) => _CategoryRow(
                  name: entry.key,
                  count: entry.value,
                  total: tasks.length,
                ),
              ),
              SizedBox(height: context.height * 0.025),
              const _SectionTitle("Upcoming reminders"),
              SizedBox(height: context.height * 0.01),
              if (upcoming.isEmpty)
                const _MutedText("No reminders enabled yet.")
              else
                ...upcoming.take(5).map((task) => _ReminderTile(task: task)),
            ],
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.width * 0.045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color.fromARGB(255, 33, 33, 33),
      ),
      child: Row(
        children: [
          SizedBox(
            height: context.width * 0.22,
            width: context.width * 0.22,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 9,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(AppColors.kpurpleOn),
                ),
                Center(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: context.height * 0.006),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                SizedBox(height: context.height * 0.012),
                const _MutedText("Keep the streak alive by completing one more habit."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.width * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(255, 33, 33, 33),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.kpurpleOn),
          SizedBox(height: context.height * 0.008),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.75))),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.name,
    required this.count,
    required this.total,
  });

  final String name;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : count / total;
    return Container(
      margin: EdgeInsets.only(bottom: context.height * 0.012),
      padding: EdgeInsets.all(context.width * 0.035),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color.fromARGB(255, 29, 29, 29),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text("$count"),
            ],
          ),
          SizedBox(height: context.height * 0.008),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(20),
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(AppColors.kpurpleOn),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(task.reminder.time).format(context);
    return Container(
      margin: EdgeInsets.only(bottom: context.height * 0.012),
      padding: EdgeInsets.all(context.width * 0.035),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color.fromARGB(255, 29, 29, 29),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: task.category.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: context.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: context.height * 0.004),
                _MutedText("${task.category.name} • $time"),
              ],
            ),
          ),
          Icon(
            task.isPendingTask ? Icons.radio_button_unchecked : Icons.check_circle,
            color: task.isPendingTask ? Colors.white60 : Colors.greenAccent,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Colors.white.withValues(alpha: 0.68)),
    );
  }
}

class _HabitsEmptyState extends StatelessWidget {
  const _HabitsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.width * 0.08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insights_outlined, size: 64, color: Colors.grey),
            SizedBox(height: context.height * 0.015),
            const Text(
              "No habits yet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: context.height * 0.01),
            const _MutedText(
              "Create a task or recurring habit to unlock progress insights, reminders, and category analytics.",
            ),
          ],
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
