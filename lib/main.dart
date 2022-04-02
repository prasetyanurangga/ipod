import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:volume_controller/volume_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _counter = 0;
  double radius = 150;
  double degree = 0;
  double rotationalChange = 0;
  double lastOffset = 0;
  bool isPlay = false;

  bool smaller = false;

  PageController controller = PageController(viewportFraction: 1);


  void _panHandler(DragUpdateDetails d) {

    bool panUp = d.delta.dy <= 0.0;
    bool panLeft = d.delta.dx <= 0.0;
    bool panRight = !panLeft;
    bool panDown = !panUp;

    /// Pan location on the wheel
    bool onTop = d.localPosition.dy <= 150; // 150 == radius of circle
    bool onLeftSide = d.localPosition.dx <= 150;
    bool onRightSide = !onLeftSide;
    bool onBottom = !onTop;

    /// Absoulte change on axis
    double yChange = d.delta.dy.abs();
    double xChange = d.delta.dx.abs();

    /// Directional change on wheel
    double vert = (onRightSide && panUp) || (onLeftSide && panDown)
        ? yChange
        : yChange * -1;

    double horz = (onTop && panLeft) || (onBottom && panRight) 
        ? xChange 
        : xChange * -1;

    // Total computed change with velocity
    double scrollOffsetChange = (horz + vert) * (d.delta.distance * 0.4);
    print(scrollOffsetChange);
    // Move the page view scroller 
    controller.jumpTo(controller.offset + scrollOffsetChange);
    setState(() {
      degree = controller.offset + scrollOffsetChange;
    });
  }

  void _panEndHandler(DragEndDetails d) {
  }


  late AnimationController _animationController;

  double _volumeListenerValue = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState((){
        lastOffset = controller.page ?? 0.0;
      });
      // print(controller.page);
    });

    _animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 450));
     VolumeController().listener((volume) {
      setState(() => _volumeListenerValue = volume);
    });

    VolumeController().getVolume().then((volume) => _volumeListenerValue  = volume);
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF626262),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  height: 300,
                  child: PageView(
                    pageSnapping: true,
                    scrollDirection: Axis.horizontal,
                    controller: controller,
                    children: List.generate(20, (index){
                      double relativePosition = index - lastOffset;
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        width: 300,
                        child: Transform(
        transform: Matrix4.identity() // add perspective
          ..scale((1 - relativePosition.abs()).clamp(0.4, 0.6) + 0.4),
        alignment: relativePosition >= 0
            ? Alignment.centerLeft
            : Alignment.centerRight,
                          child: Container(
                            child: CachedNetworkImage(
                              progressIndicatorBuilder: (context, url, progress) => Center(
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                ),
                              ),
                              imageBuilder: (context, imageProvider) => Container(
    decoration: BoxDecoration(
      image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover
        ),
    ),
  ),
                              imageUrl: "https://cdn-images-1.listennotes.com/podcasts/weird-science-marvel-comics-marvel-comics-pWd9e1Tm7GD-4HOWs-mUV1K.300x300.jpg",
                            ),
                          )
                        )
                      );
                    }),
                    onPageChanged: (int page){
                      print(page);
                    }
                  )
                ),
                SizedBox(height: 32),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onPanUpdate: _panHandler,
                          onPanEnd: _panEndHandler,
                          child: Container(
                              height: radius * 2,
                              width: radius * 2,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF171717),
                              ),
                              child: Stack(children: [
                                Container(
                                  child: IconButton(
                                    icon: Icon(Icons.add),
                                    iconSize: 40,
                                    color: Colors.white,
                                    onPressed: () {
                                      double volumeNow = _volumeListenerValue + 0.1;
                                      VolumeController().setVolume(volumeNow > 1 ? 1 : volumeNow);
                                    },
                                  ),
                                  alignment: Alignment.topCenter,
                                  margin: EdgeInsets.only(top: 30),
                                ),
                                Container(
                                  child: IconButton(
                                    icon: Icon(Icons.fast_forward),
                                    iconSize: 40,
                                    color: Colors.white,
                                    onPressed: () {
                                      controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                      // controller.jumpTo(controller.offset + 250);
                                    },
                                  ),
                                  alignment: Alignment.centerRight,
                                  margin: EdgeInsets.only(right: 30),
                                ),
                                Container(
                                  child: IconButton(
                                    icon: Icon(Icons.fast_rewind),
                                    iconSize: 40,
                                    color: Colors.white,
                                    onPressed: () {
                                      controller.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                                    },
                                  ),
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 30),
                                ),
                                Container(
                                  child: IconButton(
                                    icon: Icon(Icons.remove),
                                    iconSize: 40,
                                    color: Colors.white,
                                    onPressed: () {
                                      double volumeNow = _volumeListenerValue - 0.1;
                                      VolumeController().setVolume(volumeNow < 0 ? 0 : volumeNow);
                                    },
                                  ),
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.only(bottom: 30),
                                )
                              ]),
                          )
                        ),
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF626262),
                          ),
                          child: IconButton(
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                                    color: Colors.white,
                              progress: _animationController,
                            ),
                            iconSize: 40,
                            onPressed: (){
                              isPlay = !isPlay;
                              isPlay
                                  ? _animationController.forward()
                                  : _animationController.reverse();

                            },
                          ),
                        ),
                      ]
                    )
                  )
                )
              ]
            )
          )
        )
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
