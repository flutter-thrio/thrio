import 'package:flutter/material.dart';
import 'package:thrio/thrio.dart';

class Page2 extends StatefulWidget {
  const Page2({
    Key key,
    this.url,
    this.index,
    this.params,
  }) : super(key: key);

  final String url;

  final int index;

  final dynamic params;

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) => NavigatorPageNotify(
      name: 'page2Notify',
      onPageNotify: (params) =>
          ThrioLogger.v('flutter2 receive notify:$params'),
      child: Scaffold(
          appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
            title: const Text('thrio_example',
                style: TextStyle(color: Colors.black)),
            leading: const IconButton(
              color: Colors.black,
              tooltip: 'back',
              icon: Icon(Icons.arrow_back_ios),
              onPressed: ThrioNavigator.pop,
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      alignment: AlignmentDirectional.center,
                      child: Text(
                        'flutter2: index is ${widget.index}',
                        style:
                            const TextStyle(fontSize: 28, color: Colors.blue),
                      ),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.push(
                        url: '/biz1/flutter3',
                        params: {
                          '1': {'2': '3'}
                        },
                      ),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: const Text(
                            'push flutter3',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.remove(url: '/biz2/flutter2'),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: const Text(
                            'remove flutter2',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.pop(
                          params: 'popResult /biz2/flutter2'),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.yellow,
                          child: const Text(
                            'pop',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.push(
                          url: '/biz1/native2',
                          params: {
                            '1': {'2': '3'}
                          },
                          poppedResult: (params) =>
                              ThrioLogger.v('/biz1/native1 popped:$params')),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey,
                          child: const Text(
                            'push native2',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () => ThrioNavigator.remove(url: '/biz1/native1'),
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey,
                          child: const Text(
                            'pop native1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        ThrioNavigator.notify(
                            url: '/biz1/flutter1',
                            name: 'page1Notify',
                            params: 2);
                      },
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey,
                          child: const Text(
                            'notify flutter1',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        ThrioNavigator.notify(
                            url: '/biz2/flutter2', name: 'page2Notify');
                      },
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(8),
                          color: Colors.grey,
                          child: const Text(
                            'notify flutter2',
                            style: TextStyle(fontSize: 22, color: Colors.black),
                          )),
                    ),
                  ]),
            ),
          )));
}
