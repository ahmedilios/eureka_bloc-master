Uri uri = Uri(
  scheme: 'scheme',
  userInfo: 'userInfo',
  host: 'host',
  port: 80,
  // path: 'path',
  pathSegments: ['pathSegments'],
  // query: 'query',
  queryParameters: {"queryParameters": "queryParameters"},
  fragment: 'fragment',
);
Uri uri2 = Uri(
  scheme: 'scheme',
  userInfo: 'userInfo',
  host: 'host',
  port: 80,
  // path: 'path',
  pathSegments: ['pathSegments'],
  // query: 'query',
  queryParameters: {"queryParameters": "queryParameters"},
  fragment: 'fragment',
);

main() {
  print(uri.toString());
  print(uri2.toString());

  Type t = uri.runtimeType;
  Type t2 = uri2.runtimeType;
  print(t.hashCode);
  print(t2.hashCode);
}
