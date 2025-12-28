// note: the where and orderby clauses are privated becuase i want it to only be accesible through the clause class first

class Clauses {
  static const where = _Where('', []);
  static const orderBy = _OrderBy('');
}

class _Where {
  final String clause;
  final List<Object?> args;

  const _Where(this.clause, this.args);

  _Where eq(String column, Object? value) {
    return _Where('$column = ?', [value]);
  }

  _Where and(List<_Where> conditions) {
    return _Where(
      conditions.map((c) => c.clause).join(' AND '),
      conditions.expand((c) => c.args).toList(),
    );
  }

  _Where or(List<_Where> conditions) {
    return _Where(
      conditions.map((c) => c.clause).join(' OR '),
      conditions.expand((c) => c.args).toList(),
    );
  }

  _Where gt(String column, Object? value) {
    return _Where('$column > ?', [value]);
  }

  _Where gte(String column, Object? value) {
    return _Where('$column >= ?', [value]);
  }

  _Where lt(String column, Object? value) {
    return _Where('$column < ?', [value]);
  }

  _Where lte(String column, Object? value) {
    return _Where('$column <= ?', [value]);
  }

  _Where not(_Where condition) {
    return _Where('NOT (${condition.clause})', condition.args);
  }

  _Where isNull(String column) {
    return _Where('$column IS NULL', []);
  }

  _Where isNotNull(String column) {
    return _Where('$column IS NOT NULL', []);
  }

  _Where inVal(String column, List<Object?> values) {
    return _Where('$column IN (${values.map((v) => '?').join(',')})', values);
  }

  _Where notInVal(String column, List<Object?> values) {
    return _Where(
      '$column NOT IN (${values.map((v) => '?').join(',')})',
      values,
    );
  }

  _Where between(String column, Object? start, Object? end) {
    return _Where('$column BETWEEN ? AND ?', [start, end]);
  }

  _Where notBetween(String column, Object? start, Object? end) {
    return _Where('$column NOT BETWEEN ? AND ?', [start, end]);
  }
}

class _OrderBy {
  final String clause;

  const _OrderBy(this.clause);

  _OrderBy desc(String column) {
    return _OrderBy('$column DESC');
  }

  _OrderBy asc(String column) {
    return _OrderBy('$column ASC');
  }
}

// just experimental, not implmented using Drift (flutter ORM would be a whole lot easier (helps with the above and the schema definitions too) but wanna try to learn)

// i want to use it like: RawQuery.select().from().join().on() bt its just wrongly implemented

class RawQuery {
  RawQuery();
  static _Select select(List<String> columns) {
    return _Select(columns);
  }
}

class _Select {
  const _Select(this.columns);

  final List<String> columns;
  static _From from(String table) {
    return _From(table);
  }
}

class _From {
  final String table;

  const _From(this.table);

  static _Join join(String table) {
    return _Join(table);
  }

  static _Where where(_Where condition) {
    return _Where(condition.clause, condition.args);
  }

  static _OrderBy orderBy(_OrderBy orderBy) {
    return _OrderBy(orderBy.clause);
  }
}

class _Join {
  final String table;

  const _Join(this.table);

  static _On on(String column, String value) {
    return _On(column, value);
  }
}

class _On {
  final String column;
  final String value;

  const _On(this.column, this.value);

  static _On on(String column, String value) {
    return _On(column, value);
  }
}
