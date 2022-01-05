import 'package:flutter/material.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class Support extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //SizedBox(height: 40),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'RAVENCOIN',
                    style: Theme.of(context).supportHeading,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join the Ravencoin Discord for general Ravencoin discussions.',
                    style: Theme.of(context).supportText,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'MOONTREE',
                    style: Theme.of(context).supportHeading,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join the Moontree Discord, where you can see frequently asked questions, find solutions and request help.',
                    style: Theme.of(context).supportText,
                  ),
                ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  actionButton(
                    context,
                    name: 'RAVENCOIN',
                    color: 'green',
                  ),
                  actionButton(
                    context,
                    name: 'MOONTREE',
                    color: 'orange',
                    link: 'Jh9aqeuB3Q',
                  ),
                ]),
          ],
        ));
  }

  Widget actionButton(
    BuildContext context, {
    required String name,
    required String color,
    String? link,
  }) =>
      OutlinedButton(
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                    title: Text('Open in External App'),
                    content: Text('Open discord app or browser?'),
                    actions: [
                      TextButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop()),
                      TextButton(
                          child: Text('Continue'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            launch(
                                'https://discord.gg/${link ?? name.toLowerCase()}');
                          })
                    ])),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            'assets/icons/discord/discord_$color.png',
            height: 23,
            width: 20,
          ),
          SizedBox(width: 8),
          Text(name.toUpperCase())
        ]),
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(Size(156, 40)),
          textStyle: MaterialStateProperty.all(Theme.of(context).navBarButton),
          foregroundColor: MaterialStateProperty.all(Color(0xDE000000)),
          side: MaterialStateProperty.all(BorderSide(
              color: Color(0xFF5C6BC0), width: 2, style: BorderStyle.solid)),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0))),
        ),
      );
}
