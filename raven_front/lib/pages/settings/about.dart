import 'package:flutter/material.dart';

import 'package:raven_mobile/components/components.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: components.headers.back(context, 'About'),
        body: Center(
          child: Column(
            children: <Widget>[
              Image(image: AssetImage('assets/rvn.png')),
              Text('Github.com/moontreeapp'),
              Text('MoonTree LLC, 2021'),
            ],
          ),
        ));
  }
}
