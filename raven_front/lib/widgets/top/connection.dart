import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';

class ConnectionLight extends StatefulWidget {
  ConnectionLight({Key? key}) : super(key: key);

  @override
  _ConnectionLightState createState() => _ConnectionLightState();
}

class _ConnectionLightState extends State<ConnectionLight>
    with TickerProviderStateMixin, AnimationEagerListenerMixin {
  AnimationController? _animationControllerActive;
  AnimationController? _animationControllerUp;
  AnimationController? _animationControllerDown;
  String activity = 'idle';
  List<StreamSubscription> listeners = [];
  String? lastestClientValue;
  String? lastestProcessValue;
  bool connected = false;
  bool working = false;

  @override
  void initState() {
    super.initState();
    _animationControllerActive = _animationControllerActive ??
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationControllerUp = _animationControllerUp ??
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationControllerDown = _animationControllerDown ??
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    /// to make this animate correctly and have correct colors I think we nned
    /// a combine lastest or something on these listeners.
    /// basically there are 3 states:
    /// 1. disconnected, busy trying to connect
    /// 2. connected, busy working
    /// 3. connected, idle
    /// and 6 transitions:
    /// 1. connected idle -> disconnected busy : green still -> red moving, turn red, start moving, loop.
    /// 2. connected busy -> disconnected busy : green moving -> red moving, turn red, keep looping
    /// 3. connected idle -> connected busy : green still -> green moving, start moving, loop
    /// 4. connected busy -> connected idle : green moving -> green still, stop moving
    /// 5. disconnected busy -> connected idle : red moving -> green still, turn green, stop moving
    /// 6. disconnected busy -> connected busy : red moving -> green moving, turn green, loop
    listeners
        .add(streams.client.connected.listen((bool value) => value != connected
            ? setState(() {
                connected = value;
              })
            : () {/*do nothing*/}));
    listeners.add(services.busy.client.listen((String? value) {
      if (value == null) {
        setState(() {
          lastestClientValue = value;
          //connected = false;
        });
      } else {
        setState(() {
          lastestClientValue = value;
          //connected = true;
        });
      }
    }));

    listeners.add(services.busy.process.listen((String? value) async {
      if (value == null) {
        await Future.delayed(Duration(seconds: 2));
        if (mounted) {
          setState(() {
            lastestProcessValue = value;
            working = false;
            activity = activity == 'working' ? 'down' : 'idle';
          });
        }
      } else {
        setState(() {
          lastestProcessValue = value;
          working = true;
          activity = activity == 'idle' ? 'up' : 'working';
        });
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    // _ConnectionLightState.dispose failed to call super.dispose.
    // ignore: invalid_use_of_protected_member
    _animationControllerActive?.clearStatusListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerActive?.clearListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerUp?.clearStatusListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerUp?.clearListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerDown?.clearStatusListeners();
    // ignore: invalid_use_of_protected_member
    _animationControllerDown?.clearListeners();
    _animationControllerActive?.dispose();
    _animationControllerUp?.dispose();
    _animationControllerDown?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (activity == 'down') {
      _animationControllerDown!.forward(from: 0.50);
      _animationControllerDown!.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() => activity = 'idle');
        }
      });
    } else if (activity == 'up') {
      TickerFuture tickerFuture = _animationControllerUp!.forward(from: 0.0);
      tickerFuture.timeout(Duration(milliseconds: 1000), onTimeout: () {
        //_animationControllerUp!.forward(from: 0);
        //_animationControllerUp!.stop(canceled: true);
        _animationControllerActive?.value = 0.0;
        _animationControllerActive?.repeat();
        setState(() => activity = 'working');
      }); //rgba(244, 67, 54, 1)
    }
    var status;
    var connectionMessage;
    var processMessage;
    if (connected) {
      status = 'Connected';
      connectionMessage = lastestClientValue ?? 'Connection established.';
    } else {
      status = 'Disconnected';
      connectionMessage =
          'Unable to communicate with the Ravencoin Electrum Server. Please check your internet connection.';
    }
    if (working) {
      processMessage = lastestProcessValue;
    } else {
      processMessage = 'Currently idle.';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// for manual testing
        //TextButton(
        //    onPressed: () {
        //      print(_animationControllerUp!.value);
        //      setState(() => activity = 'up');
        //    },
        //    child: Text('$activity')),
        //TextButton(
        //    onPressed: () {
        //      print(_animationControllerActive!.value);
        //      setState(() => activity = 'down');
        //    },
        //    child: Text('stop')),
        IconButton(
          splashRadius: 24,
          onPressed: () => showDialog(
              //context: context,
              context: components.navigator.routeContext!,
              builder: (BuildContext context) => AlertDialog(
                  title: Text(status),
                  content: Text('Connection Status: $connectionMessage \n\n'
                      'Background Tasks: $processMessage'))),
          icon: Stack(
            children: [
              Visibility(
                  visible: activity == 'idle',
                  child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          connected ? Color(0xFF4CAF50) : Color(0xFFF44336),
                          BlendMode.srcATop),
                      //child: Image(image: AssetImage('assets/icons/status/status_green_24px.png')))),
                      child: Image(
                          image: AssetImage("assets/status/center.png")))),
              Visibility(
                  visible: activity == 'working',
                  child: RotationTransition(
                      child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              connected ? Color(0xFF4CAF50) : Color(0xFFF44336),
                              BlendMode.srcATop),
                          child: Image(
                              image: AssetImage("assets/status/left.png"))),
                      alignment: Alignment.center,
                      turns: _animationControllerActive!)),
              Visibility(
                  visible: activity == 'up',
                  child: RotationTransition(
                      child: RotationTransition(
                          child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  connected
                                      ? Color(0xFF4CAF50)
                                      : Color(0xFFF44336),
                                  BlendMode.srcATop),
                              child: Image(
                                  image:
                                      AssetImage("assets/status/center.png"))),
                          alignment: Alignment(.3, 0),
                          turns: _animationControllerUp!),
                      alignment: Alignment.center,
                      turns: _animationControllerUp!)),
              Visibility(
                visible: activity == 'down',
                child: Transform.rotate(
                  angle: 6.283184 * _animationControllerActive!.value,
                  child: RotationTransition(
                      child: RotationTransition(
                          child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  connected
                                      ? Color(0xFF4CAF50)
                                      : Color(0xFFF44336),
                                  BlendMode.srcATop),
                              child: Image(
                                  image:
                                      AssetImage("assets/status/center.png"))),
                          alignment: Alignment(.3, 0),
                          turns: _animationControllerDown!),
                      alignment: Alignment.center,
                      turns: _animationControllerDown!),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
