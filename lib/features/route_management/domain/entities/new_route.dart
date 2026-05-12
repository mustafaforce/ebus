class NewStop {
  const NewStop({
    required this.name,
    required this.sequenceOrder,
  });

  final String name;
  final int sequenceOrder;
}

class NewRoute {
  const NewRoute({
    required this.name,
    this.description,
    required this.stops,
  });

  final String name;
  final String? description;
  final List<NewStop> stops;
}
