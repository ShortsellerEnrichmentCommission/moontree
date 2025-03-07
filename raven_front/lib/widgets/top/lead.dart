//import 'package:backdrop/backdrop.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';

class PageLead extends StatefulWidget {
  final BuildContext mainContext;

  PageLead({Key? key, required this.mainContext}) : super(key: key);

  @override
  _PageLead createState() => _PageLead();
}

class _PageLead extends State<PageLead> {
  late String pageTitle = 'Wallet';
  late String? settingTitle = null;
  late bool xlead = false;
  late List listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.page.listen((value) {
      if (value != pageTitle) {
        setState(() {
          pageTitle = value;
        });
      }
    }));
    listeners.add(streams.app.setting.listen((value) {
      if (value != settingTitle) {
        setState(() {
          settingTitle = value;
        });
      }
    }));
    listeners.add(streams.app.xlead.listen((value) {
      if (value != xlead) {
        setState(() {
          xlead = value;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() {
    var ret = null;
    if (settingTitle == '/settings/import_export') {
      return IconButton(
          splashRadius: 24,
          icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () => streams.app.setting.add('/settings'));
    }
    if (settingTitle == '/settings/settings') {
      return IconButton(
          splashRadius: 24,
          icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () => streams.app.setting.add('/settings'));
    }

    if (pageTitle == 'Wallet') {
      return IconButton(
          splashRadius: 24,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            flingBackdrop(context);
          },
          padding: EdgeInsets.only(left: 16),
          icon: SvgPicture.asset('assets/icons/menu/menu.svg'));
    }
    if (pageTitle == '') {
      return Container();
    }
    if (pageTitle == 'Login') {
      return Container(
        height: 24,
        padding: EdgeInsets.only(left: 16),
        child: SvgPicture.asset(
          'assets/icons/menu/menu.svg',
          color: AppColors.black38,
        ),
      );
    }
    if (xlead || ['Send', 'Scan', 'Receive'].contains(pageTitle)) {
      return IconButton(
          splashRadius: 24,
          icon: Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            if (pageTitle == 'Send') streams.spend.form.add(null);
            if (xlead) streams.app.xlead.add(false);
            Navigator.pop(components.navigator.routeContext ?? context);
          });
    }
    return IconButton(
        splashRadius: 24,
        icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
        onPressed: () {
          if (pageTitle == 'Transaction') streams.spend.form.add(null);
          Navigator.pop(components.navigator.routeContext ?? context);
        });
  }
}
