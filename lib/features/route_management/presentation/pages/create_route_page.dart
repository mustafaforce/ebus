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
          content: Text(
            _controller.isEditMode
                ? 'Route updated successfully'
                : 'Route created successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop(true);
    } else if (_controller.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool editMode = _controller.isEditMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(editMode ? 'Edit Route' : 'Create Route'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Route name',
                    hintText: 'e.g. Route 404',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_controller.isSubmitting,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller.descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'e.g. Downtown - Airport',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_controller.isSubmitting,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stops',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: _controller.isSubmitting
                          ? null
                          : _controller.addStop,
                      icon: const Icon(Icons.add),
                      label: const Text('Add stop'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._controller.stops.asMap().entries.map((entry) {
                  final int idx = entry.key;
                  final StopDraft stop = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: colors.primary,
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                color: colors.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: stop.controller,
                              decoration: InputDecoration(
                                hintText: 'Stop ${idx + 1} name',
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              enabled: !_controller.isSubmitting,
                            ),
                          ),
                          IconButton(
                            onPressed: _controller.isSubmitting || idx == 0
                                ? null
                                : () => _controller.moveStopUp(idx),
                            icon: const Icon(Icons.arrow_upward),
                            tooltip: 'Move up',
                          ),
                          IconButton(
                            onPressed: _controller.isSubmitting ||
                                    idx == _controller.stops.length - 1
                                ? null
                                : () => _controller.moveStopDown(idx),
                            icon: const Icon(Icons.arrow_downward),
                            tooltip: 'Move down',
                          ),
                          IconButton(
                            onPressed: _controller.isSubmitting ||
                                    _controller.stops.length <= 1
                                ? null
                                : () => _controller.removeStop(idx),
                            icon: Icon(Icons.delete, color: colors.error),
                            tooltip: 'Remove',
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _controller.isSubmitting ? null : _onSubmit,
                    icon: _controller.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(editMode ? Icons.save : Icons.check),
                    label: Text(
                      _controller.isSubmitting
                          ? (editMode ? 'Saving...' : 'Creating...')
                          : (editMode ? 'Save Changes' : 'Create Route'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
