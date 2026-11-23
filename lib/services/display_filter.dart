/// Paquet d'une capture SIMULÉE (aucune capture réseau réelle).
class Packet {
  final int no;
  final double time;
  final String src;
  final String dst;
  final String protocol;
  final int length;
  final String info;

  /// Couches présentes (`eth`, `arp`, `ip`, `tcp`, `udp`, `dns`, `http`,
  /// `tls`, `icmp`).
  final Set<String> layers;

  /// Champs Wireshark (`ip.src`, `tcp.dstport`, `dns.qry.name`…).
  final Map<String, Object> fields;

  const Packet({
    required this.no,
    required this.time,
    required this.src,
    required this.dst,
    required this.protocol,
    required this.length,
    required this.info,
    required this.layers,
    required this.fields,
  });

  /// Valeurs d'un champ, champs « virtuels » compris : `ip.addr`
  /// (source OU destination), `tcp.port`, `udp.port`, `frame.number`…
  List<Object> values(String field) {
    switch (field) {
      case 'frame.number':
        return [no];
      case 'frame.len':
        return [length];
      case 'ip.addr':
        return [?fields['ip.src'], ?fields['ip.dst']];
      case 'tcp.port':
        return [?fields['tcp.srcport'], ?fields['tcp.dstport']];
      case 'udp.port':
        return [?fields['udp.srcport'], ?fields['udp.dstport']];
      case 'arp.addr':
        return [?fields['arp.src.proto_ipv4'], ?fields['arp.dst.proto_ipv4']];
    }
    final v = fields[field];
    return v == null ? const [] : [v];
  }

  /// Présence d'un protocole ou d'un champ (filtre « nu » : `dns`,
  /// `http.request`…).
  bool has(String name) {
    if (layers.contains(name)) return true;
    switch (name) {
      case 'http.request':
        return fields.containsKey('http.request.method');
      case 'http.response':
        return fields.containsKey('http.response.code');
    }
    return values(name).isNotEmpty;
  }
}

/// Erreur de syntaxe ou de champ (la barre de filtre passe au rouge).
class FilterError implements Exception {
  final String message;
  const FilterError(this.message);
  @override
  String toString() => message;
}

/// Filtres d'affichage façon Wireshark (sous-ensemble pédagogique) :
/// - protocoles ou champs seuls : `dns`, `tcp`, `http.request` ;
/// - comparaisons : `==`, `!=`, `>`, `<`, `>=`, `<=` (ou `eq`, `ne`, `gt`,
///   `lt`, `ge`, `le`) et `contains` ;
/// - combinaisons : `&&` / `and`, `||` / `or`, `!` / `not`, parenthèses ;
/// - valeurs : nombres, adresses, mots, chaînes "entre guillemets".
///
/// Comme dans Wireshark récent, `ip.addr != X` signifie « ni la source ni
/// la destination ne vaut X ».
class DisplayFilter {
  DisplayFilter._(this._root, this.source);

  final _Node _root;
  final String source;

  /// Champs et protocoles reconnus.
  static const knownNames = {
    'eth', 'arp', 'ip', 'tcp', 'udp', 'dns', 'http', 'tls', 'icmp', //
    'frame.number', 'frame.len',
    'ip.src', 'ip.dst', 'ip.addr',
    'tcp.srcport', 'tcp.dstport', 'tcp.port',
    'tcp.flags.syn', 'tcp.flags.ack', 'tcp.flags.reset', 'tcp.flags.fin',
    'udp.srcport', 'udp.dstport', 'udp.port',
    'dns.qry.name', 'dns.flags.response', 'dns.a', 'dns.qry.type',
    'http.request', 'http.response', 'http.request.method',
    'http.request.uri', 'http.host', 'http.response.code', 'http.file_data',
    'tls.handshake.extensions_server_name',
    'arp.opcode', 'arp.src.proto_ipv4', 'arp.dst.proto_ipv4', 'arp.addr',
    'icmp.type',
  };

  /// Analyse [text]. Lève [FilterError] si le filtre est invalide. Un
  /// filtre vide est accepté et montre tout.
  static DisplayFilter parse(String text) {
    final tokens = _lex(text);
    if (tokens.isEmpty) return DisplayFilter._(const _All(), text);
    final p = _Parser(tokens);
    final node = p.expr();
    if (!p.atEnd) {
      throw FilterError('Élément inattendu : « ${p.peek} »');
    }
    return DisplayFilter._(node, text);
  }

  bool matches(Packet p) => _root.eval(p);

  List<Packet> apply(List<Packet> packets) => packets.where(matches).toList();

  static List<String> _lex(String s) {
    final out = <String>[];
    var i = 0;
    while (i < s.length) {
      final c = s[i];
      if (c == ' ' || c == '\t') {
        i++;
        continue;
      }
      if (c == '"') {
        final end = s.indexOf('"', i + 1);
        if (end < 0) throw const FilterError('Guillemet non fermé');
        out.add(s.substring(i, end + 1));
        i = end + 1;
        continue;
      }
      final two = i + 1 < s.length ? s.substring(i, i + 2) : '';
      if (const {'==', '!=', '>=', '<=', '&&', '||'}.contains(two)) {
        out.add(two);
        i += 2;
        continue;
      }
      if ('()!<>'.contains(c)) {
        out.add(c);
        i++;
        continue;
      }
      if (c == '=' || c == '&' || c == '|') {
        throw FilterError(
          '« $c » seul n\'existe pas : utilisez '
          '${c == '='
              ? '=='
              : c == '&'
              ? '&&'
              : '||'}',
        );
      }
      final start = i;
      while (i < s.length && RegExp(r'[A-Za-z0-9_.:\-/]').hasMatch(s[i])) {
        i++;
      }
      if (i == start) throw FilterError('Caractère inattendu : « $c »');
      out.add(s.substring(start, i));
    }
    return out;
  }
}

class _Parser {
  _Parser(this.t);
  final List<String> t;
  int i = 0;

  bool get atEnd => i >= t.length;
  String? get peek => atEnd ? null : t[i];

  static const _ops = {
    '==': '==', 'eq': '==', '!=': '!=', 'ne': '!=', '>': '>', 'gt': '>', //
    '<': '<', 'lt': '<', '>=': '>=', 'ge': '>=', '<=': '<=', 'le': '<=',
    'contains': 'contains',
  };

  _Node expr() {
    var left = and();
    while (peek == '||' || peek == 'or') {
      i++;
      left = _Or(left, and());
    }
    return left;
  }

  _Node and() {
    var left = not();
    while (peek == '&&' || peek == 'and') {
      i++;
      left = _And(left, not());
    }
    return left;
  }

  _Node not() {
    if (peek == '!' || peek == 'not') {
      i++;
      return _Not(not());
    }
    return primary();
  }

  _Node primary() {
    final tok = peek;
    if (tok == null) throw const FilterError('Filtre incomplet');
    if (tok == '(') {
      i++;
      final e = expr();
      if (peek != ')') throw const FilterError('Parenthèse « ) » manquante');
      i++;
      return e;
    }
    i++;
    final name = tok.toLowerCase();
    if (!DisplayFilter.knownNames.contains(name)) {
      throw FilterError(
        '« $tok » n\'est ni un champ ni un protocole connu de cette capture',
      );
    }
    final op = peek == null ? null : _ops[peek!.toLowerCase()];
    if (op == null) return _Has(name);
    i++;
    final value = peek;
    if (value == null || const {'&&', '||', ')', 'and', 'or'}.contains(value)) {
      throw FilterError('Valeur manquante après « ${t[i - 1]} »');
    }
    i++;
    final v = value.startsWith('"')
        ? value.substring(1, value.length - 1)
        : value;
    return _Cmp(name, op, v);
  }
}

abstract class _Node {
  const _Node();
  bool eval(Packet p);
}

class _All extends _Node {
  const _All();
  @override
  bool eval(Packet p) => true;
}

class _Has extends _Node {
  const _Has(this.name);
  final String name;
  @override
  bool eval(Packet p) => p.has(name);
}

class _Not extends _Node {
  const _Not(this.a);
  final _Node a;
  @override
  bool eval(Packet p) => !a.eval(p);
}

class _And extends _Node {
  const _And(this.a, this.b);
  final _Node a, b;
  @override
  bool eval(Packet p) => a.eval(p) && b.eval(p);
}

class _Or extends _Node {
  const _Or(this.a, this.b);
  final _Node a, b;
  @override
  bool eval(Packet p) => a.eval(p) || b.eval(p);
}

class _Cmp extends _Node {
  const _Cmp(this.field, this.op, this.value);
  final String field;
  final String op;
  final String value;

  bool _one(Object actual) {
    if (op == 'contains') return '$actual'.contains(value);
    final a = num.tryParse('$actual');
    final b = num.tryParse(value);
    if (a != null && b != null) {
      return switch (op) {
        '==' => a == b,
        '!=' => a != b,
        '>' => a > b,
        '<' => a < b,
        '>=' => a >= b,
        _ => a <= b,
      };
    }
    final x = '$actual'.toLowerCase(), y = value.toLowerCase();
    return switch (op) {
      '==' => x == y,
      '!=' => x != y,
      '>' => x.compareTo(y) > 0,
      '<' => x.compareTo(y) < 0,
      '>=' => x.compareTo(y) >= 0,
      _ => x.compareTo(y) <= 0,
    };
  }

  @override
  bool eval(Packet p) {
    final vals = p.values(field);
    if (vals.isEmpty) return false;
    // != : aucune valeur égale (ip.addr != X exclut X en source ET en
    // destination) ; autres opérateurs : au moins une valeur correspond.
    if (op == '!=') return vals.every(_one);
    return vals.any(_one);
  }
}
