import 'package:ebus/app/theme/design_tokens.dart';
import 'package:ebus/features/route_list/data/models/route_with_stops_model.dart';
import 'package:ebus/features/route_management/presentation/controllers/create_route_controller.dart';
import 'package:flutter/material.dart';

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({super.key, this.initial});

  final RouteWithStopsModel? initial;

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage> {
  late final CreateRouteController _controller =
      CreateRouteController(initial: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final bool ok = await _controller.submit();
    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_controller.isEditMode ? 'Route updated' : 'Route created'),
        ),
      );
      navigator.pop(true);
    } else if (_controller.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(_controller.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final bool editMode = _controller.isEditMode;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(editMode ? 'Edit route' : 'New route'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  editMode ? 'Update details.' : 'Define the route.',
                  style: text.displaySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Name, description, then list each stop in order.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                _FieldLabel('Route name'),
                const SizedBox(height: 6),
                TextField(
                  controller: _controller.nameController,
                  decoration: const InputDecoration(hintText: 'Route 404'),
                  enabled: !_controller.isSubmitting,
                ),
                const SizedBox(height: AppSpacing.md),
                _FieldLabel('Description (optional)'),
                const SizedBox(height: 6),
                TextField(
                  controller: _controller.descriptionController,
                  decoration: const InputDecoration(hintText: 'Downtown — Airport'),
                  enabled: !_controller.isSubmitting,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Stops', style: text.titleLarge),
                    TextButton.icon(
                      onPressed: _controller.isSubmitting ? null : _controller.addStop,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add stop'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ..._controller.stops.asMap().entries.map((entry) {
                  final int idx = entry.key;
                  final StopDraft stop = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.parchment,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${idx + 1}',
                              style: text.labelMedium?.copyWith(
                                color: AppColors.inkMuted48,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: stop.controller,
                              decoration: InputDecoration(
                                hintText: 'Stop ${idx + 1}',
                                isDense: true,
                                fillColor: AppColors.canvas,
                              ),
                              enabled: !_controller.isSubmitting,
                            ),
                          ),
                          IconButton(
                            onPressed: _controller.isSubmitting || idx == 0
                                ? null
                                : () => _controller.moveStopUp(idx),
                            icon: const Icon(Icons.arrow_upward, size: 18),
                            tooltip: 'Move up',
                          ),
                          IconButton(
                            onPressed: _controller.isSubmitting ||
                                    idx == _controller.stops.length - 1
                                ? null
                                : () => _controller.moveStopDown(idx),
                            icon: const Icon(Icons.arrow_downward, size: 18),
                            tooltip: 'Move down',
                          ),
                          IconButton(
                            onPressed: _controller.isSubmitting ||
                                    _controller.stops.length <= 1
                                ? null
                                : () => _controller.removeStop(idx),
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFFD93025),
                            ),
                            tooltip: 'Remove',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: _controller.isSubmitting ? null : _onSubmit,
                  child: _controller.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(editMode ? 'Save changes' : 'Create route'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.inkMuted80,
          ),
    );
  }
}
