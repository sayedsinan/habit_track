import 'package:flutter/material.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/core/data/in_memory_store.dart';
import 'package:habit_builder/core/models/habit_model.dart';

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────

enum HabitFrequency { daily, weekly, custom }

class BlueprintItem {
  final String title;
  final List<String> tags;
  final int timesPerDay;
  final List<String> defaultBlocks;

  const BlueprintItem({
    required this.title,
    required this.tags,
    this.timesPerDay = 1,
    this.defaultBlocks = const ['Morning'],
  });
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: PageAppBar
// ─────────────────────────────────────────────

class HabitPageAppBar extends StatelessWidget {
  final VoidCallback? onSettingsTap;

  const HabitPageAppBar({super.key, this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.cardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_outline,
                  color: color.primaryTextColor, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'The Silent Architect',
              style: TextStyle(
                color: color.primaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Icon(Icons.settings_outlined,
            color: color.primaryTextColor, size: 22),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: PageTitleBlock
// ─────────────────────────────────────────────

class PageTitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;

  const PageTitleBlock({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color.primaryTextColor,
            fontSize: 38,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: color.subtitleColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: LabeledSection
// ─────────────────────────────────────────────

class LabeledSection extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledSection({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.subtitleColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: HabitNameField
// ─────────────────────────────────────────────

class HabitNameField extends StatelessWidget {
  final TextEditingController? controller;

  const HabitNameField({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      decoration: BoxDecoration(
        color: color.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.borderColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: color.primaryTextColor, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'e.g., Deep Work Protocol',
          hintStyle: TextStyle(color: color.subtitleColor, fontSize: 15),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: FrequencySelector
// ─────────────────────────────────────────────

class FrequencySelector extends StatelessWidget {
  final HabitFrequency selected;
  final ValueChanged<HabitFrequency> onChanged;

  const FrequencySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: HabitFrequency.values.map((freq) {
          final isSelected = selected == freq;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(freq),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.primaryTextColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  freq.name[0].toUpperCase() + freq.name.substring(1),
                  style: TextStyle(
                    color: isSelected
                        ? color.backgroundColor
                        : color.subtitleColor,
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: StarterBlueprintSectionHeader
// ─────────────────────────────────────────────

class BlueprintSectionHeader extends StatelessWidget {
  const BlueprintSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Row(
      children: [
        Icon(Icons.auto_awesome, color: color.subtitleColor, size: 16),
        const SizedBox(width: 8),
        Text(
          'STARTER BLUEPRINTS',
          style: TextStyle(
            color: color.subtitleColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: BlueprintTile
// ─────────────────────────────────────────────

class BlueprintTile extends StatelessWidget {
  final BlueprintItem blueprint;
  final VoidCallback? onAdd;
  final bool isSelected;

  const BlueprintTile({
    super.key,
    required this.blueprint,
    this.onAdd,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return GestureDetector(
      onTap: onAdd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.primaryTextColor.withOpacity(0.05) : color.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blueprint.title,
                    style: TextStyle(
                      color: isSelected ? color.accentColor : color.primaryTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    blueprint.tags.join(' • '),
                    style: TextStyle(
                      color: color.subtitleColor,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              color: isSelected ? color.accentColor : color.subtitleColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: CreateHabitButton
// ─────────────────────────────────────────────

class CreateHabitButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CreateHabitButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: color.primaryTextColor,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          'Create Habit',
          style: TextStyle(
            color: color.backgroundColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN PAGE: NewHabitPage
// ─────────────────────────────────────────────

class NewHabitPage extends StatefulWidget {
  const NewHabitPage({super.key});

  @override
  State<NewHabitPage> createState() => _NewHabitPageState();
}

class _NewHabitPageState extends State<NewHabitPage> {
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  final TextEditingController _nameController = TextEditingController();
  
  // Track selected blueprint
  String? _selectedBlueprintTitle;
  
  // New State variables for times per day, reminders, and time of day pref
  int _timesPerDay = 1;
  bool _reminderEnabled = false;
  List<TimeOfDay> _reminderTimes = [const TimeOfDay(hour: 8, minute: 0)];

  List<String> _selectedTimeBlocks = [];
  final List<String> _timeOfDayOptions = ['Morning', 'Noon', 'Evening', 'Night', 'Anytime'];

  TimeOfDay _getDefaultTimeForBlock(String block) {
    switch (block) {
      case 'Morning': return const TimeOfDay(hour: 8, minute: 0);
      case 'Noon': return const TimeOfDay(hour: 12, minute: 0);
      case 'Evening': return const TimeOfDay(hour: 17, minute: 0);
      case 'Night': return const TimeOfDay(hour: 21, minute: 0);
      default: return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  void _syncReminders() {
    for (int i = 0; i < _timesPerDay; i++) {
      if (i < _selectedTimeBlocks.length) {
        final newTime = _getDefaultTimeForBlock(_selectedTimeBlocks[i]);
        if (i < _reminderTimes.length) {
          _reminderTimes[i] = newTime;
        } else {
          _reminderTimes.add(newTime);
        }
      } else if (i >= _reminderTimes.length) {
        _reminderTimes.add(const TimeOfDay(hour: 8, minute: 0));
      }
    }
    if (_reminderTimes.length > _timesPerDay) {
      _reminderTimes.removeRange(_timesPerDay, _reminderTimes.length);
    }
  }

  final List<BlueprintItem> _blueprints = const [
    BlueprintItem(
      title: 'Morning Meditation',
      tags: ['10 MINS', 'FOCUS', 'DAILY'],
      timesPerDay: 1,
      defaultBlocks: ['Morning'],
    ),
    BlueprintItem(
      title: 'Read 10 pages',
      tags: ['EDUCATION', 'WISDOM', 'DAILY'],
      timesPerDay: 2,
      defaultBlocks: ['Morning', 'Night'],
    ),
    BlueprintItem(
      title: 'Gratitude Journal',
      tags: ['MINDSET', 'REFLECTION', 'DAILY'],
      timesPerDay: 1,
      defaultBlocks: ['Night'],
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    const SizedBox(height: 16),

                    // ── App Bar ──
                    const HabitPageAppBar(),

                    const SizedBox(height: 28),

                    // ── Page Title ──
                    const PageTitleBlock(
                      title: 'New Habit',
                      subtitle: 'DESIGN YOUR DISCIPLINE',
                    ),

                    const SizedBox(height: 30),

                    // ── Habit Name ──
                    LabeledSection(
                      label: 'HABIT NAME',
                      child: HabitNameField(controller: _nameController),
                    ),

                    const SizedBox(height: 26),

                    // ── Frequency ──
                    LabeledSection(
                      label: 'FREQUENCY',
                      child: FrequencySelector(
                        selected: _selectedFrequency,
                        onChanged: (val) =>
                            setState(() => _selectedFrequency = val),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ── Times Per Day ──
                    LabeledSection(
                      label: 'TIMES PER DAY',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_timesPerDay time${_timesPerDay > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: color.primaryTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline, color: color.subtitleColor),
                                  onPressed: () {
                                    if (_timesPerDay > 1) {
                                      setState(() {
                                        _timesPerDay--;
                                        if (_selectedTimeBlocks.length > _timesPerDay) {
                                          _selectedTimeBlocks.removeLast();
                                        }
                                        _syncReminders();
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline, color: color.primaryTextColor),
                                  onPressed: () {
                                    setState(() {
                                      _timesPerDay++;
                                      _syncReminders();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ── Time Of Day Preferance ──
                    LabeledSection(
                      label: 'PREFERRED TIME BLOCK',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _timeOfDayOptions.map((option) {
                          final isSelected = _selectedTimeBlocks.contains(option);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedTimeBlocks.remove(option);
                                } else {
                                  if (_selectedTimeBlocks.length < _timesPerDay) {
                                    _selectedTimeBlocks.add(option);
                                  } else {
                                    // Replace the last one if we're full
                                    if (_selectedTimeBlocks.isNotEmpty) {
                                      _selectedTimeBlocks.removeLast();
                                      _selectedTimeBlocks.add(option);
                                    }
                                  }
                                }
                                _syncReminders();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? color.primaryTextColor : color.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? color.primaryTextColor : color.borderColor,
                                ),
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: isSelected ? color.backgroundColor : color.primaryTextColor,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // ── Remember Toggle ──
                    LabeledSection(
                      label: 'NOTIFICATIONS',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: color.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Send Reminder',
                                  style: TextStyle(
                                    color: color.primaryTextColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Switch(
                                  value: _reminderEnabled,
                                  activeColor: color.accentColor,
                                  onChanged: (val) {
                                    setState(() => _reminderEnabled = val);
                                  },
                                ),
                              ],
                            ),
                            if (_reminderEnabled) ...[
                              const SizedBox(height: 12),
                              ...List.generate(_timesPerDay, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Reminder ${index + 1}',
                                        style: TextStyle(
                                          color: color.subtitleColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final t = await showTimePicker(
                                            context: context,
                                            initialTime: _reminderTimes[index],
                                          );
                                          if (t != null) {
                                            setState(() => _reminderTimes[index] = t);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: color.backgroundColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _reminderTimes[index].format(context),
                                            style: TextStyle(
                                              color: color.primaryTextColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ]
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Starter Blueprints Header ──
                    const BlueprintSectionHeader(),

                    const SizedBox(height: 12),

                    // ── Blueprint Tiles ──
                    ..._blueprints.map(
                      (bp) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BlueprintTile(
                          blueprint: bp,
                          isSelected: _selectedBlueprintTitle == bp.title,
                          onAdd: () {
                            setState(() {
                              if (_selectedBlueprintTitle == bp.title) {
                                // Deselect
                                _selectedBlueprintTitle = null;
                                _nameController.text = '';
                                _timesPerDay = 1;
                                _selectedTimeBlocks = [];
                                _reminderEnabled = false;
                                _syncReminders();
                              } else {
                                // Select
                                _selectedBlueprintTitle = bp.title;
                                _nameController.text = bp.title;
                                _timesPerDay = bp.timesPerDay;
                                _selectedTimeBlocks = List.from(bp.defaultBlocks);
                                _reminderEnabled = true;
                                _syncReminders();
                              }
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Sticky Bottom Button ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: CreateHabitButton(
                onTap: () {
                  final name = _nameController.text.trim();
                  if (name.isNotEmpty) {
                    final newHabit = Habit(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: name,
                      description: 'Custom added habit',
                      timeOfDay: _selectedTimeBlocks.isEmpty ? 'Anytime' : _selectedTimeBlocks.join(', '),
                      totalTimes: _timesPerDay,
                      completedTimes: 0,
                    );
                    InMemoryStore().addHabit(newHabit);
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}