library painter;

import 'package:flutter/widgets.dart' hide Image;
import 'dart:ui';
import 'dart:async';
import 'dart:typed_data';

class Painter extends StatefulWidget {
  final PainterController painterController;

  Painter(PainterController painterController):
        this.painterController = painterController,
        super(key: ValueKey<PainterController>(painterController));

  @override
  _PainterState createState() => _PainterState();
}

class _PainterState extends State<Painter> {
  bool _finished;

  @override
  void initState() {
    super.initState();
    _finished = false;
    widget.painterController._widgetFinish = _finish;
  }

  Size _finish(){
    setState((){
      _finished = true;
    });
    return context.size;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = CustomPaint(
      willChange: true,
      painter: _PainterPainter(
          widget.painterController._pathHistory,
          repaint: widget.painterController
      ),
    );
    child = ClipRect(child: child);
    if(!_finished){
      child = GestureDetector(
        child: child,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
      );
    }
    return Container(
      child: child,
      width: double.infinity,
      height: double.infinity,
    );
  }

  void _onPanStart(DragStartDetails start){
    Offset pos = (context.findRenderObject() as RenderBox)
        .globalToLocal(start.globalPosition);
    widget.painterController._pathHistory.add(pos);
    widget.painterController._notifyListeners();
  }

  void _onPanUpdate(DragUpdateDetails update){
    Offset pos = (context.findRenderObject() as RenderBox)
        .globalToLocal(update.globalPosition);
    widget.painterController._pathHistory.updateCurrent(pos);
    widget.painterController._notifyListeners();
  }

  void _onPanEnd(DragEndDetails end){
    widget.painterController._pathHistory.endCurrent();
    widget.painterController._notifyListeners();
  }

}

class _PainterPainter extends CustomPainter{
  final _PathHistory _path;

  _PainterPainter(
      this._path,
      {Listenable repaint}
  ) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    _path.draw(canvas, size);
  }

  @override
  bool shouldRepaint(_PainterPainter oldDelegate) => true;

}

class _PathHistory {
  List<MapEntry<Path, Paint>> _paths;
  List<MapEntry<Path, Paint>> _undone;
  Paint currentPaint;
  Paint _backgroundPaint;
  bool _inDrag;

  _PathHistory(){
    _paths = List<MapEntry<Path, Paint>>();
    _undone = List<MapEntry<Path, Paint>>();
    _inDrag = false;
    _backgroundPaint = Paint();
  }

  void setBackgroundColor(Color backgroundColor){
    _backgroundPaint.color = backgroundColor;
  }

  bool canUndo() => _paths.length > 0;

  void undo() {
    if (!_inDrag && canUndo()) {
      _undone.add(_paths.removeLast());
    }
  }

  bool canRedo() => _undone.length > 0;

  void redo() {
    if(!_inDrag && canRedo()) {
      _paths.add(_undone.removeLast());
    }
  }

  void clear(){
    if(!_inDrag) {
      _paths.clear();
      _undone.clear();
    }
  }

  void add(Offset startPoint){
    if(!_inDrag) {
      _inDrag = true;
      Path path = Path();
      path.moveTo(startPoint.dx, startPoint.dy);
      _paths.add(MapEntry<Path, Paint>(path, currentPaint));
    }
  }

  void updateCurrent(Offset nextPoint) {
    if (_inDrag) {
      Path path = _paths.last.key;
      path.lineTo(nextPoint.dx, nextPoint.dy);
    }
  }

  void endCurrent() {
    _inDrag = false;
  }

  void draw(Canvas canvas,Size size){
    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), _backgroundPaint);
    for(MapEntry<Path, Paint> path in _paths){
      canvas.drawPath(path.key,path.value);
    }
  }
}

typedef PictureDetails PictureCallback();

class PictureDetails{
  final Picture picture;
  final int width;
  final int height;

  const PictureDetails(this.picture, this.width, this.height);

  Future<Image> toImage() async {
    return await picture.toImage(width, height);
  }

  Future<Uint8List> toPNG() async{
    return (await (await toImage()).toByteData(format: ImageByteFormat.png)).buffer.asUint8List();
  }
}

class PainterController extends ChangeNotifier{
  Color _drawColor = Color.fromARGB(255, 0, 0, 0);
  Color _backgroundColor = Color.fromARGB(255, 255, 255, 255);

  double _thickness = 1.0;
  PictureDetails _cached;
  _PathHistory _pathHistory;
  ValueGetter<Size> _widgetFinish;

  PainterController() {
    _pathHistory = _PathHistory();
  }

  Color get drawColor => _drawColor;
  set drawColor(Color color){
    _drawColor = color;
    _updatePaint();
  }

  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color color){
    _backgroundColor=color;
    _updatePaint();
  }

  double get thickness => _thickness;
  set thickness(double t){
    _thickness=t;
    _updatePaint();
  }

  void _updatePaint(){
    Paint paint = Paint();
    paint.color = drawColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = thickness;
    _pathHistory.currentPaint = paint;
    _pathHistory.setBackgroundColor(backgroundColor);
    notifyListeners();
  }

  void undo(){
    if(!isFinished) {
      _pathHistory.undo();
      notifyListeners();
    }
  }

  void redo(){
    if(!isFinished) {
      _pathHistory.redo();
      notifyListeners();
    }
  }

  bool get canUndo => _pathHistory.canUndo();
  bool get canRedo => _pathHistory.canRedo();

  void _notifyListeners(){
    notifyListeners();
  }

  void clear(){
    if(!isFinished) {
      _pathHistory.clear();
      notifyListeners();
    }
  }

  PictureDetails finish(){
    if(!isFinished){
      _cached = _render(_widgetFinish());
    }
    return _cached;
  }

  PictureDetails _render(Size size){
    PictureRecorder recorder = PictureRecorder();
    Canvas canvas = Canvas(recorder);
    _pathHistory.draw(canvas, size);
    return PictureDetails(recorder.endRecording(),size.width.floor(),size.height.floor());
  }

  bool get isFinished => _cached != null;
}