import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/widgets.dart';

class RemovePassword extends StatefulWidget {
  @override
  _RemovePasswordState createState() => _RemovePasswordState();
}

class _RemovePasswordState extends State<RemovePassword> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      streams.app.verify.value ? body() : VerifyPassword(parentState: this);

  Widget body() {
    return Padding(
        padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 16),
            Text('Are you sure?', style: Theme.of(context).textTheme.headline2),
            Row(children: [submitButton])
          ],
        ));
  }

  Widget get submitButton => components.buttons.actionButton(context,
      label: 'Yes, Remove Password', onPressed: () async => await submit());

  Future submit() async {
    FocusScope.of(context).unfocus();
    streams.password.update.add('');
    components.loading.screen(message: 'Removing Password');
  }
}
