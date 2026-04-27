import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../services/portfolio_service.dart';
import '../services/auth_service.dart';
import '../services/currency_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/currency_formatter.dart';

class GoalsTab extends StatelessWidget {
  const GoalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolioService = context.watch<PortfolioService>();
    final authService = context.watch<AuthService>();
    final currencyService = context.watch<CurrencyService>();
    final currencyFormatter = CurrencyFormatter(currencyService, authService.currentUser);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final portfolio = portfolioService.portfolioByType;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.02),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.02),
          ],
        ),
      ),
      child: portfolioService.goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flag_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No goals yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Set your financial goals and track your progress',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showAddGoalDialog(context),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'Create Your First Goal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: portfolioService.goals.length + 1,
              itemBuilder: (context, index) {
                if (index == portfolioService.goals.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddGoalDialog(context),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text(
                          'Add New Goal',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  );
                }

                final goal = portfolioService.goals[index];

                return _GoalCard(
                  goal: goal,
                  portfolio: portfolio,
                  currencyFormatter: currencyFormatter,
                  dateFormat: dateFormat,
                  onEdit: () => _showEditGoalDialog(context, goal),
                );
              },
            ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _GoalDialog(),
    );
  }

  void _showEditGoalDialog(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => _GoalDialog(goal: goal),
    );
  }
}

class _GoalCard extends StatefulWidget {
  final Goal goal;
  final Map<String, double> portfolio;
  final CurrencyFormatter currencyFormatter;
  final DateFormat dateFormat;
  final VoidCallback onEdit;

  const _GoalCard({
    required this.goal,
    required this.portfolio,
    required this.currencyFormatter,
    required this.dateFormat,
    required this.onEdit,
  });

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  DateTime? _selectedMilestone;

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final portfolio = widget.portfolio;
    final currencyFormatter = widget.currencyFormatter;
    final dateFormat = widget.dateFormat;

    final milestones = goal.yearlyMilestones();
    final activeTargets = _selectedMilestone != null
        ? goal.milestoneTargets(_selectedMilestone!, portfolio)
        : goal.targets;
    final activeTargetAmount = _selectedMilestone != null
        ? goal.milestoneTargetAmount(_selectedMilestone!, portfolio)
        : goal.targetAmount;

    final totalCurrent = goal.currentAmount(portfolio);
    final totalProgress = activeTargetAmount > 0
        ? (totalCurrent / activeTargetAmount) * 100
        : 0.0;
    final completed = totalCurrent >= activeTargetAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (goal.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          goal.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(36, 36),
                  ),
                ),
              ],
            ),
            if (milestones.length > 1) ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: milestones.map((milestone) {
                    final isSelected = _selectedMilestone == milestone;
                    final isFinal = milestone == goal.targetDate;
                    final label = DateFormat('MMM yyyy').format(milestone);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedMilestone = isSelected ? null : milestone;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        side: BorderSide(
                          color: isFinal
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...(activeTargets.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).map((entry) {
              final type = entry.key;
              final target = entry.value;
              final current = portfolio[type] ?? 0;
              final pct = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
              final color = AppTheme.getPortfolioTypeColor(type);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${currencyFormatter.format(current)} / ${currencyFormatter.format(target)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: color.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMilestone != null ? 'Milestone Target' : 'Total Progress',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${currencyFormatter.format(totalCurrent)} / ${currencyFormatter.format(activeTargetAmount)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target Date',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      dateFormat.format(_selectedMilestone ?? goal.targetDate),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (totalProgress / 100).clamp(0.0, 1.0),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  completed ? AppTheme.successColor : AppTheme.primaryColor,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${totalProgress.toStringAsFixed(1)}% complete',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${goal.daysRemaining} days left',
                  style: TextStyle(
                    color: goal.daysRemaining < 0
                        ? AppTheme.errorColor
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetEntry {
  String? type;
  final TextEditingController amountController;

  _TargetEntry({this.type, String? amount})
      : amountController = TextEditingController(text: amount ?? '');
}

class _GoalDialog extends StatefulWidget {
  final Goal? goal;

  const _GoalDialog({this.goal});

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _totalTargetController;
  late DateTime _targetDate;
  late List<_TargetEntry> _targetEntries;
  late bool _isPercentageMode;

  @override
  void initState() {
    super.initState();
    _isPercentageMode = false;
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController = TextEditingController(text: widget.goal?.description ?? '');
    _targetDate = widget.goal?.targetDate ?? DateTime.now().add(const Duration(days: 365));

    if (widget.goal != null) {
      _isPercentageMode = widget.goal!.isPercentageMode;
      if (_isPercentageMode && widget.goal!.percentages != null) {
        _targetEntries = widget.goal!.percentages!.entries
            .map((e) => _TargetEntry(type: e.key, amount: e.value.toString()))
            .toList();
      } else {
        _targetEntries = widget.goal!.targets.entries
            .map((e) => _TargetEntry(type: e.key, amount: e.value.toString()))
            .toList();
      }
      _totalTargetController = TextEditingController(
        text: widget.goal!.targetAmount.toString(),
      );
    } else {
      _targetEntries = [_TargetEntry()];
      _totalTargetController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalTargetController.dispose();
    for (final entry in _targetEntries) {
      entry.amountController.dispose();
    }
    super.dispose();
  }

  List<String> _availableTypes(_TargetEntry current) {
    final used = _targetEntries
        .where((e) => e != current && e.type != null)
        .map((e) => e.type!)
        .toSet();
    return AppConstants.portfolioTypes.where((t) => !used.contains(t)).toList();
  }

  double get _userTotal =>
      double.tryParse(_totalTargetController.text) ?? 0;

  double _resolveEntryAmount(_TargetEntry entry) {
    final value = double.tryParse(entry.amountController.text) ?? 0;
    if (_isPercentageMode) {
      return _userTotal * value / 100;
    }
    return value;
  }


  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final targets = <String, double>{};
    Map<String, double>? percentages;
    if (_isPercentageMode) {
      percentages = <String, double>{};
    }
    for (final entry in _targetEntries) {
      if (entry.type != null) {
        final rawValue = double.tryParse(entry.amountController.text) ?? 0;
        final amount = _resolveEntryAmount(entry);
        if (amount > 0) targets[entry.type!] = amount;
        if (_isPercentageMode && rawValue > 0) {
          percentages![entry.type!] = rawValue;
        }
      }
    }

    if (targets.isEmpty) return;

    final portfolioService = context.read<PortfolioService>();
    final goal = Goal(
      id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      targets: targets,
      targetDate: _targetDate,
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
      isPercentageMode: _isPercentageMode,
      percentages: percentages,
    );

    if (widget.goal == null) {
      portfolioService.addGoal(goal);
    } else {
      portfolioService.updateGoal(goal);
    }

    Navigator.of(context).pop();
  }

  void _delete() {
    if (widget.goal != null) {
      context.read<PortfolioService>().deleteGoal(widget.goal!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.02),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.goal == null ? Icons.flag_outlined : Icons.edit_outlined,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.goal == null ? 'Add New Goal' : 'Edit Goal',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.goal == null
                        ? 'Set a target across your asset types'
                        : 'Update your goal details',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Title
                  _buildLabel('Title'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration(
                      context,
                      hintText: 'e.g., Millionaire Portfolio',
                      icon: Icons.flag_outlined,
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildLabel('Description'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration(
                      context,
                      hintText: 'Describe your goal',
                      icon: Icons.notes,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),

                  // Target Date
                  _buildLabel('Target Date'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _targetDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) {
                        setState(() => _targetDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_targetDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Total Target Amount
                  _buildLabel('Total Target Amount'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _totalTargetController,
                    decoration: _inputDecoration(
                      context,
                      hintText: 'e.g., 1000000',
                      icon: Icons.attach_money,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      final val = double.tryParse(v ?? '') ?? 0;
                      return val <= 0 ? 'Enter a target amount' : null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Amount / Percentage toggle
                  _buildLabel('Target Mode'),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Amount'),
                          icon: Icon(Icons.attach_money, size: 18),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Percentage'),
                          icon: Icon(Icons.percent, size: 18),
                        ),
                      ],
                      selected: <bool>{_isPercentageMode},
                      onSelectionChanged: (Set<bool> v) {
                        setState(() => _isPercentageMode = v.first);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Asset Targets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Asset Targets'),
                      if (_targetEntries.length < AppConstants.portfolioTypes.length)
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _targetEntries.add(_TargetEntry()));
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._targetEntries.asMap().entries.map((mapEntry) {
                    final i = mapEntry.key;
                    final entry = mapEntry.value;
                    final available = _availableTypes(entry);
                    if (entry.type != null && !available.contains(entry.type)) {
                      available.insert(0, entry.type!);
                    }
                    final entryValue = double.tryParse(entry.amountController.text) ?? 0;
                    final resolvedAmount = _resolveEntryAmount(entry);

                    String? tip;
                    if (entryValue > 0 && _userTotal > 0) {
                      if (_isPercentageMode) {
                        tip = '= \$${resolvedAmount.toStringAsFixed(0)}';
                      } else {
                        final pct = (entryValue / _userTotal * 100);
                        tip = '${pct.toStringAsFixed(1)}% of total';
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  initialValue: entry.type,
                                  decoration: _inputDecoration(
                                    context,
                                    hintText: 'Asset type',
                                    icon: Icons.category_outlined,
                                  ),
                                  items: available
                                      .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14))))
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() => entry.type = v);
                                  },
                                  validator: (v) => v == null ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: entry.amountController,
                                  decoration: _inputDecoration(
                                    context,
                                    hintText: _isPercentageMode ? '%' : 'Amount',
                                    icon: _isPercentageMode ? Icons.percent : Icons.attach_money,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                                ),
                              ),
                              if (_targetEntries.length > 1)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _targetEntries[i].amountController.dispose();
                                      _targetEntries.removeAt(i);
                                    });
                                  },
                                  icon: Icon(Icons.remove_circle_outline, color: Colors.red[400], size: 22),
                                  padding: const EdgeInsets.only(top: 12),
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                          if (tip != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, left: 4),
                              child: Text(
                                tip,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  if (_isPercentageMode) ...[
                    () {
                      double totalPct = 0;
                      for (final e in _targetEntries) {
                        totalPct += double.tryParse(e.amountController.text) ?? 0;
                      }
                      final remaining = 100 - totalPct;
                      final color = remaining.abs() < 0.01
                          ? AppTheme.successColor
                          : remaining < 0
                              ? AppTheme.errorColor
                              : Colors.orange;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              remaining.abs() < 0.01
                                  ? Icons.check_circle
                                  : Icons.info_outline,
                              size: 16,
                              color: color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              remaining.abs() < 0.01
                                  ? 'Allocation complete (100%)'
                                  : remaining > 0
                                      ? '${remaining.toStringAsFixed(1)}% remaining to reach 100%'
                                      : '${remaining.abs().toStringAsFixed(1)}% over 100%',
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }(),
                  ],
                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                      if (widget.goal != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'ACTIONS',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Theme.of(context).dividerColor)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (widget.goal != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _delete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: Icon(
                            widget.goal == null ? Icons.add_circle_outline : Icons.save_rounded,
                            size: 20,
                          ),
                          label: Text(
                            widget.goal == null ? 'Create Goal' : 'Save',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }
}
