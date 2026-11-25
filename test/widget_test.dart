import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aplikasi_lapas/helpers/database_helper.dart';
import 'package:aplikasi_lapas/main.dart';
import 'package:aplikasi_lapas/controllers/narapidana_controller.dart';
import 'package:aplikasi_lapas/model/narapidana.dart';
import 'package:aplikasi_lapas/ui/screen/block_sel_screen.dart';
import 'package:aplikasi_lapas/ui/screen/detail_narapidana_screen.dart';
import 'package:aplikasi_lapas/ui/screen/narapidana_screen.dart';
import 'package:aplikasi_lapas/ui/screen/operasional_sipir_screen.dart';
import 'package:aplikasi_lapas/ui/screen/petugas_screen.dart';

late Directory _testDatabaseDirectory;

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final originalDirectory = Directory.current;
    _testDatabaseDirectory = await Directory.systemTemp.createTemp(
      'simlapas_widget_test_',
    );
    try {
      Directory.current = _testDatabaseDirectory;
      final legacyDatabase = await openDatabase(
        path.join(await getDatabasesPath(), 'simlapas.db'),
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nama TEXT NOT NULL,
              nip TEXT NOT NULL UNIQUE,
              password TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE narapidana (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              no_reg TEXT UNIQUE NOT NULL,
              nama TEXT NOT NULL,
              blok TEXT NOT NULL,
              sel TEXT NOT NULL,
              tanggal_masuk TEXT NOT NULL,
              estimasi_bebas TEXT NOT NULL,
              status TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE insiden (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              no_reg TEXT NOT NULL,
              nama_napi TEXT NOT NULL,
              nip_petugas TEXT NOT NULL,
              keterangan TEXT NOT NULL,
              tanggal TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE blok (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nama_blok TEXT UNIQUE NOT NULL,
              kapasitas_sel INTEGER NOT NULL,
              maks_penghuni INTEGER NOT NULL,
              tingkat_keamanan TEXT NOT NULL
            )
          ''');
        },
      );
      await legacyDatabase.close();
      await DatabaseHelper.instance.registerUser(
        nama: 'Dina Pratama',
        nip: '12345',
        password: 'password',
        role: 'Kepala Lapas',
      );
      expect(
        (await DatabaseHelper.instance.loginUser(
          'Dina Pratama',
          'password',
        ))?['nama'],
        'Dina Pratama',
      );
    } finally {
      Directory.current = originalDirectory;
    }
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
    await _testDatabaseDirectory.delete(recursive: true);
  });

  testWidgets('login form is shown on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(find.text('NIP / Nama pengguna'), findsOneWidget);
    expect(find.text('Kata sandi'), findsOneWidget);
  });

  testWidgets('new account can be registered from the login screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('Buat akun baru'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat akun baru'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(2), 'Ayu Prameswari');
    await tester.enterText(find.byType(TextField).at(3), 'NIP-REG-001');
    await tester.enterText(find.byType(TextField).at(4), 'sandi-uji');
    await tester.tap(find.text('Daftar Akun'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    expect(find.text('✅ Akun berhasil dibuat! Silakan login.'), findsOneWidget);
    final user = await tester.runAsync(
      () => DatabaseHelper.instance.loginUser('NIP-REG-001', 'sandi-uji'),
    );
    expect(user?['nama'], 'Ayu Prameswari');
  });

  test('duplicate account NIP is rejected', () async {
    await expectLater(
      DatabaseHelper.instance.registerUser(
        nama: 'Nama Lain',
        nip: '12345',
        password: 'password-lain',
        role: 'Sipir',
      ),
      throwsA(isA<StateError>()),
    );
  });

  testWidgets('empty credentials are rejected', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(
      find.text('NIP/nama pengguna dan kata sandi wajib diisi.'),
      findsOneWidget,
    );
    expect(find.text('Selamat datang kembali'), findsOneWidget);
  });

  testWidgets('password visibility can be toggled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
      isTrue,
    );
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
      isFalse,
    );
  });

  testWidgets('login form fits a mobile viewport', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    expect(find.text('Selamat datang kembali'), findsOneWidget);
    final exception = tester.takeException();
    if (exception != null) debugPrint(exception.toString());
    if (exception != null) debugPrint(exception.toString());
    expect(exception, isNull, reason: '$exception');
  });

  testWidgets('valid login navigates to the main layout', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.enterText(find.byType(TextField).at(0), 'Dina Pratama');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Masuk'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan'), findsOneWidget);
    expect(find.text('Dina Pratama'), findsOneWidget);
  });

  testWidgets('dashboard fits a mobile viewport after login', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.enterText(find.byType(TextField).at(0), 'Dina Pratama');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Masuk'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan operasional'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('database supports prisoner, block, and incident records', () async {
    final db = await DatabaseHelper.instance.database;
    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    final noReg = 'TEST-$suffix';
    final namaBlok = 'Blok TEST-$suffix';

    try {
      await DatabaseHelper.instance.insertNarapidanaWithInsiden(
        {
          'no_reg': noReg,
          'nama': 'Napi Uji',
          'blok': namaBlok,
          'sel': 'T-01',
          'tanggal_masuk': '2026-01-01',
          'estimasi_bebas': '2027-01-01',
          'status': 'Aktif',
        },
        insiden: {
          'no_reg': noReg,
          'nama_napi': 'Napi Uji',
          'nip_petugas': 'SIPIR-UJI',
          'keterangan': 'Catatan uji',
          'tanggal': '2026-01-02',
        },
      );
      final napi = (await DatabaseHelper.instance.getNarapidanaByBlok(
        namaBlok,
      )).single;
      expect(napi['no_reg'], noReg);

      await DatabaseHelper.instance.insertBlok({
        'nama_blok': namaBlok,
        'kapasitas_sel': 8,
        'maks_penghuni': 48,
        'tingkat_keamanan': 'Menengah',
      });
      expect(await DatabaseHelper.instance.getJumlahNapiByBlok(namaBlok), 1);
      expect(
        (await DatabaseHelper.instance.getInsidenByNapi(
          noReg,
        )).single['keterangan'],
        'Catatan uji',
      );
    } finally {
      await db.delete('insiden', where: 'no_reg = ?', whereArgs: [noReg]);
      await db.delete('narapidana', where: 'no_reg = ?', whereArgs: [noReg]);
      await db.delete('blok', where: 'nama_blok = ?', whereArgs: [namaBlok]);
    }
  });

  test(
    'prisoner controller registers through service and repository',
    () async {
      final db = await DatabaseHelper.instance.database;
      final suffix = DateTime.now().microsecondsSinceEpoch.toString();
      final noReg = 'LAYER-$suffix';
      final namaBlok = 'Blok LAYER-$suffix';
      final estimasiBebas = DateTime(2027, 1, 1);

      try {
        await DatabaseHelper.instance.insertBlok({
          'nama_blok': namaBlok,
          'kapasitas_sel': 2,
          'maks_penghuni': 12,
          'tingkat_keamanan': 'Menengah',
        });

        final controller = NarapidanaController();
        expect(
          await controller.daftarkanNarapidana(
            nama: 'Narapidana Layer',
            noReg: noReg,
            blokNama: namaBlok,
            selNomor: '$namaBlok-01',
            estimasiBebas: estimasiBebas,
          ),
          isTrue,
        );

        final napi = (await controller.muatNarapidanaByBlok(namaBlok)).single;
        expect(napi.noRegistrasi, noReg);
        expect(napi.estimasiBebas, estimasiBebas);
      } finally {
        await db.delete('narapidana', where: 'no_reg = ?', whereArgs: [noReg]);
        await db.delete('blok', where: 'nama_blok = ?', whereArgs: [namaBlok]);
      }
    },
  );

  testWidgets('editing prisoner keeps its block and cell selected', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final suffix = DateTime.now().microsecondsSinceEpoch.toString();
    final namaBlok = 'Blok Edit-$suffix';
    final noReg = 'EDIT-$suffix';
    final sel = '$namaBlok-02';

    try {
      await tester.runAsync(() async {
        await DatabaseHelper.instance.insertBlok({
          'nama_blok': namaBlok,
          'kapasitas_sel': 3,
          'maks_penghuni': 12,
          'tingkat_keamanan': 'Menengah',
        });
        await DatabaseHelper.instance.insertNarapidana({
          'no_reg': noReg,
          'nama': 'Nama Sebelum Edit',
          'blok': namaBlok,
          'sel': sel,
          'tanggal_masuk': '2026-01-01',
          'estimasi_bebas': '2028-01-01',
          'status': 'Aktif',
        });
        await DatabaseHelper.instance.insertInsiden({
          'no_reg': noReg,
          'nama_napi': 'Nama Sebelum Edit',
          'nip_petugas': 'SIPIR-LAMA',
          'keterangan': 'Insiden sebelum edit',
          'tanggal': '2026-01-02',
        });
      });

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NarapidanaScreen())),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Edit').first);
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();

      final dropdowns = tester.widgetList<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(dropdowns.first.initialValue, namaBlok);
      expect(dropdowns.last.initialValue, sel);
      expect(find.text('Insiden sebelum edit'), findsOneWidget);
      await tester.tap(find.text('Edit catatan ini'));
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'Nama Setelah Edit');
      await tester.enterText(
        find.byType(TextField).last,
        'Insiden diperbarui saat edit',
      );
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();

      final updated = await tester.runAsync(
        () => DatabaseHelper.instance.getNarapidanaByBlok(namaBlok),
      );
      expect(updated?.single['nama'], 'Nama Setelah Edit');
      expect(updated?.single['sel'], sel);
      final incidents = await tester.runAsync(
        () => DatabaseHelper.instance.getInsidenByNapi(noReg),
      );
      expect(incidents?.length, 1);
      expect(incidents?.single['keterangan'], 'Insiden diperbarui saat edit');
      expect(incidents?.single['nip_petugas'], 'SIPIR-LAMA');
      expect(incidents?.single['tanggal'], '2026-01-02');
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() async {
        final db = await DatabaseHelper.instance.database;
        await db.delete('insiden', where: 'no_reg = ?', whereArgs: [noReg]);
        await db.delete('narapidana', where: 'no_reg = ?', whereArgs: [noReg]);
        await db.delete('blok', where: 'nama_blok = ?', whereArgs: [namaBlok]);
      });
    }
  });

  testWidgets('management screens render without mobile layout errors', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> pumpScreen(Widget screen) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: screen)));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
      final exception = tester.takeException();
      if (exception != null) debugPrint(exception.toString());
      if (exception != null) debugPrint(exception.toString());
      expect(exception, isNull, reason: '${screen.runtimeType}: $exception');
    }

    await pumpScreen(
      const OperasionalSipirScreen(
        loggedInUser: {
          'nama': 'Sipir Uji',
          'nip': 'SIPIR-UJI',
          'blok': 'Blok A',
        },
      ),
    );
    await pumpScreen(const NarapidanaScreen());
    await pumpScreen(const BlokSelScreen());
    await pumpScreen(
      DetailNarapidanaScreen(
        narapidana: Narapidana(
          nik: 'TEST-DETAIL',
          nama: 'Nama Narapidana Uji',
          noRegistrasi: 'TEST-DETAIL',
          status: 'Aktif',
          blok: 'Blok A',
          selNomor: 'A-01',
          tanggalMasuk: DateTime(2026, 1, 1),
          estimasiBebas: DateTime(2027, 1, 1),
        ),
      ),
    );
  });

  testWidgets('petugas screen loads typed petugas data', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: PetugasScreen())),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    expect(find.text('Dina Pratama'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
