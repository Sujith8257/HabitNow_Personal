import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_now/src/cubit/tasks_cubits/tasks_database_cubit.dart.dart';
import 'package:habit_now/src/cubit/today/todayListView_cubit.dart';
import 'package:habit_now/src/presentation/shared/components/BottomNavbar.dart';
import 'package:habit_now/src/presentation/shared/components/drawer.dart';
import 'package:habit_now/src/presentation/tasks/tasks_page.dart';
import 'package:habit_now/src/presentation/today/components/today_widgets.dart';
import 'package:habit_now/src/utils/const.dart';
import 'package:habit_now/src/utils/extentions.dart';
import 'package:habit_now/src/utils/models/task_model.dart';
import 'package:intl/intl.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodayListViewCubit, TodayListViewState>(
      builder: (context, listViewState) {
        return Scaffold(
            drawer: const DrawerWidget(),
            bottomNavigationBar: const CustomBottomNavBar(),
            floatingActionButton: const CustomFloatingActionButton(),
            appBar: TodayAppBar(
              context: context,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: context.height * 0.087,
                  child: ListView.builder(
                    controller: ScrollController(
                        initialScrollOffset: 100 * context.height * 0.067 +
                            100 * 5 -
                            context.height * 0.067 * 3),
                    scrollDirection: Axis.horizontal,
                    itemCount: 201,
                    itemBuilder: (context, index) => TodayListViewElement(
                      isSelected: listViewState.currentIndex == index,
                      index: index,
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<TasksDatabaseCubit, List<TaskModel>>(
                    builder: (context, tasks) {
                      final selectedDate = DateTime.now().add(
                        Duration(days: listViewState.currentIndex - 100),
                      );

                      final selectedDateTasks = tasks
                          .where((task) => _isSameDay(task.date, selectedDate))
                          .toList()
                        ..sort((a, b) => a.date.compareTo(b.date));

                      if (selectedDateTasks.isEmpty) {
                        return const _TodayEmptyState();
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: context.width * 0.03),
                        itemCount: selectedDateTasks.length,
                        itemBuilder: (context, index) {
                          final task = selectedDateTasks[index];
                          return _TodayTaskTile(task: task);
                        },
                      );
                    },
                  ),
                ),
              ],
            ));
      },
    );
  }
}

class _TodayTaskTile extends StatelessWidget {
  const _TodayTaskTile({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.kBackgroundColor,
      child: InkWell(
        onTap: () {
          context.pushNamed("/edit_task", arguments: task);
        },
        child: Container(
          height: context.height * 0.08,
          width: double.infinity,
          decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Color.fromARGB(255, 66, 66, 66), width: 0.3),
                  bottom: BorderSide(
                      color: Color.fromARGB(255, 66, 66, 66), width: 0.3))),
          child: Row(
            children: [
              Container(
                height: context.height * 0.05,
                width: context.height * 0.05,
                decoration: BoxDecoration(
                    color: task.category.color,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(task.category.icon),
              ),
              SizedBox(width: context.width * 0.04),
              Expanded(
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontSize: context.fontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                task.isPendingTask
                    ? Icons.radio_button_unchecked
                    : Icons.check_circle,
                color: task.isPendingTask ? Colors.white54 : Colors.greenAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_note_outlined, color: Colors.grey, size: 64),
          SizedBox(height: context.height * 0.01),
          const Text(
            "No tasks for this day",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class TodayListViewElement extends StatelessWidget {
  const TodayListViewElement({
    Key? key,
    required this.isSelected,
    required this.index,
  }) : super(key: key);

  final bool isSelected; //100 default value + the drawer logic
  final int index;

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    DateTime targetDate = currentDate.add(Duration(days: index - 100));

    return GestureDetector(
      onTap: () {
        context.read<TodayListViewCubit>().updateSelection(index);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 5),
        height: context.height * 0.086,
        width: context.height * 0.067,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? const Color.fromARGB(255, 162, 19, 67)
              : const Color.fromARGB(255, 30, 30, 30),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 3,
            ),
            Expanded(
              flex: 8,
              child: Center(
                child: Text(
                  DateFormat('EEE').format(targetDate),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: context.height * 0.017,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 14,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  color: isSelected
                      ? const Color.fromARGB(255, 121, 14, 50)
                      : AppColors.kGray,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: context.height * 0.007,
                    ),
                    Text(
                      targetDate.day.toString(), // Display day number
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 15,
                      height: 2,
                      decoration: BoxDecoration(
                          color:
                              index == 100 ? Colors.grey : Colors.transparent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
