import 'dart:html' as html;

Future<bool> openExternalUrl(Uri uri) async {
  final anchor = html.AnchorElement(href: uri.toString())
    ..target = '_blank'
    ..rel = 'noopener noreferrer';

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  return true;
}
