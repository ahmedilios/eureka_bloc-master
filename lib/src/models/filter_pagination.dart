import '../models/filter.dart';

/// Filtro padrão na estrutura de offset(ou skip) e limit, usado para paginação
class FilterPagination extends Filter {
  final int offset;
  final int limit;

  FilterPagination({
    this.offset,
    this.limit,
  });

  factory FilterPagination.start(int limit) =>
      FilterPagination(offset: 0, limit: limit);

  factory FilterPagination.next(FilterPagination filter) => FilterPagination(
        offset: filter.offset + filter.limit,
        limit: filter.limit,
      );

  @override
  String get encoded => '\$skip=$offset&\$limit=$limit';
}
