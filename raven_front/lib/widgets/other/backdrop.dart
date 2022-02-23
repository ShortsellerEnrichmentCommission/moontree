import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';

class ScaffoldBackdrop extends StatefulWidget {
  final Widget front;
  final Widget? title;
  final Widget? back;
  //final Widget navbar;

  const ScaffoldBackdrop({
    required this.front,
    this.title,
    this.back,
    //required this.navbar,
  }) : super();

  @override
  _ScaffoldBackdropState createState() => _ScaffoldBackdropState();
}

class _ScaffoldBackdropState extends State<ScaffoldBackdrop>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() => BackdropScaffold(
        //scaffoldKey: components.scaffoldKey, // thought this could help scrim issue, but it didn't
        //maintainBackLayerState: false,
        //resizeToAvoidBottomInset: false,
        //extendBody: true,
        // for potentially modifying the persistent bottom sheet options:
        stickyFrontLayer: true,
        backgroundColor: Theme.of(context).backgroundColor,
        backLayerBackgroundColor: Theme.of(context).backgroundColor,
        frontLayerElevation: 1,
        frontLayerBackgroundColor: Colors.transparent,
        frontLayerBorderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        frontLayerBoxShadow: [
          BoxShadow(
              color: const Color(0x33000000),
              offset: Offset(0, 1),
              blurRadius: 5),
          BoxShadow(
              color: const Color(0x1F000000),
              offset: Offset(0, 3),
              blurRadius: 1),
          BoxShadow(
              color: const Color(0x24000000),
              offset: Offset(0, 2),
              blurRadius: 2),
        ],
        appBar: BackdropAppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
          leading: PageLead(mainContext: context),
          //title: /*FittedBox(fit: BoxFit.fitWidth, child: */ PageTitle() /*)*/,
          title: widget.title ?? PageTitle(),
          actions: <Widget>[
            components.status,
            ConnectionLight(),
            QRCodeContainer(),
            SnackBarViewer(),
            SizedBox(width: 6),
          ],
        ),
        backLayer: widget.back ?? BackLayer(),
        frontLayer: Container(
          color: Colors.white,
          child: widget.front,
        ),
      );
}
