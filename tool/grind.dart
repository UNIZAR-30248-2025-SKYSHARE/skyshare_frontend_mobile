import 'dart:io';
import 'package:grinder/grinder.dart';

void main(List<String> args) => grind(args);

bool _isCommandAvailable(String cmd) {
  try {
    if (Platform.isWindows) {
      final r = Process.runSync('where', [cmd]);
      return r.exitCode == 0;
    } else {
      final r = Process.runSync('which', [cmd]);
      return r.exitCode == 0;
    }
  } catch (_) {
    return false;
  }
}

Future<void> _openPath(String path) async {
  try {
    if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', '""', path]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [path]);
    } else {
      await Process.run('xdg-open', [path]);
    }
  } catch (_) {
  }
}

@DefaultTask('Run tests with coverage and generate html')
@Task('Run tests with coverage and generate html')
Future<void> checkCoverage() async {
  final flutterResult = await Process.run('flutter', ['test', '--coverage']);
  if (flutterResult.exitCode != 0) fail('flutter test failed (${flutterResult.exitCode})');

  if (!File('coverage/lcov.info').existsSync()) fail('coverage/lcov.info no generado');

  final hasGenhtml = _isCommandAvailable('genhtml');
  if (!hasGenhtml) {
    log('genhtml no encontrado. Se ha generado coverage/lcov.info pero no se podrá generar HTML automáticamente.');
    log('Instala lcov (genhtml) para generar el informe HTML o usa una herramienta alternativa.');
    log('Puedes ver el archivo lcov con un servicio online o instalar lcov y ejecutar: genhtml coverage/lcov.info -o coverage/html');
    return;
  }

  final genhtmlResult = await Process.run('genhtml', ['coverage/lcov.info', '-o', 'coverage/html']);
  if (genhtmlResult.exitCode != 0) fail('genhtml failed (${genhtmlResult.exitCode})');

  final htmlIndex = 'coverage/html/index.html';
  if (File(htmlIndex).existsSync()) {
    bool opened = false;
    if (Platform.isWindows) {
      opened = _isCommandAvailable('cmd');
    } else if (Platform.isMacOS) {
      opened = _isCommandAvailable('open');
    } else {
      opened = _isCommandAvailable('xdg-open');
    }

    if (opened) {
      try {
        await _openPath(htmlIndex);
      } catch (_) {
        log('No se pudo abrir el navegador automáticamente, informe generado en $htmlIndex');
      }
    } else {
      log('No se encontró comando para abrir el navegador automáticamente. Informe generado en $htmlIndex');
    }
  } else {
    log('Se generó coverage/html pero no se encontró index.html. Revisa coverage/html.');
  }

  log('Coverage HTML: coverage/html/index.html');
}
