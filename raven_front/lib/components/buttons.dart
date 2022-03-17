import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

class ButtonComponents {
  IconButton back(BuildContext context) => IconButton(
      icon: components.icons.back, onPressed: () => Navigator.pop(context));

  Widget actionButton(
    BuildContext context, {
    String? label,
    Widget? disabledIcon,
    String? link,
    VoidCallback? onPressed,
    VoidCallback? disabledOnPressed,
    FocusNode? focusNode,
    bool enabled = true,
    bool invert = false,
  }) =>
      Expanded(
          child: Container(
        height: 40,
        child: OutlinedButton(
          focusNode: focusNode,
          onPressed: enabled
              ? (link != null
                  ? () => Navigator.of(components.navigator.routeContext!)
                      .pushNamed(link)
                  : onPressed ?? () {})
              : disabledOnPressed ?? () {},
          style: invert
              ? components.styles.buttons.bottom(context, invert: true)
              : components.styles.buttons.bottom(context, disabled: !enabled),
          child: Text(_labelDefault(label),
              style: enabled
                  ? invert
                      ? Theme.of(context).invertButton
                      : null
                  : Theme.of(context).disabledButton),
        ),
      ));

  Widget _iconDefault(Widget? icon) => icon ?? components.icons.preview;
  Widget _iconDefaultDisabled(Widget? icon) =>
      icon ?? components.icons.disabledPreview;
  String _labelDefault(String? label) => (label ?? 'Preview').toUpperCase();
}
