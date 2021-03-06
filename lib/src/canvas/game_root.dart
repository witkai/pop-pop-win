part of ppw_canvas;

class GameRoot extends GameManager {
  final Stage _stage;
  final CanvasElement _canvas;
  final GameElement _gameElement;
  final ClickManager _clickMan;
  final AffineTransform _gameElementTx;

  bool _frameRequested = false;

  factory GameRoot(int width, int height, int bombCount,
      CanvasElement canvasElement, TextureData textureData) {

    final rootElement = new GameElement(textureData);
    final stage = new Stage(canvasElement, rootElement);
    final clickMan = new ClickManager(stage);

    return new GameRoot._internal(width, height, bombCount,
        canvasElement, stage, rootElement, clickMan);
  }

  GameRoot._internal(int width, int height, int bombCount,
      this._canvas, this._stage, GameElement gameElement, this._clickMan) :
      this._gameElement = gameElement,
      _gameElementTx = gameElement.addTransform(),
      super(width, height, bombCount) {

    _gameElement.setGameManager(this);
    _stage.invalidated.add(_stageInvalidated);

    _gameElement.newGameClick.add((args) => newGame());

    ClickManager.addMouseMoveHandler(_gameElement, _mouseMoveHandler);
    ClickManager.addMouseOutHandler(_stage, _mouseOutHandler);

    window.on.resize.add((args) => _updateCanvasSize());
    _updateCanvasSize();
  }

  void newGame() {
    super.newGame();
    _gameElement.game = super.game;
    _requestFrame();
  }

  bool get canRevealTarget => _gameElement.canRevealTarget;

  bool get canFlagTarget => _gameElement.canFlagTarget;

  void revealTarget() => _gameElement.revealTarget();

  void toggleTargetFlag() => _gameElement.toggleTargetFlag();

  EventRoot get targetChanged =>
      _gameElement.targetChanged;

  void onGameStateChanged(GameState newState) {
    switch(newState) {
      case GameState.won:
        GameAudio.win();
        break;
    }
    trackAnalyticsEvent('game', newState.name, game.field.toString());
  }

  void onNewBestTime(int value) {
    trackAnalyticsEvent('game', 'record', game.field.toString(), value);
  }

  void _updateCanvasSize() {
    _canvas.width = window.innerWidth;
    _canvas.height = window.innerHeight;
    _requestFrame();
  }

  void _requestFrame() {
    if(!_frameRequested) {
      _frameRequested = true;
      window.requestAnimationFrame(_onFrame);
    }
  }

  void _onFrame(double time) {
    final boardInnerBox = _gameElement._scaledInnerBox;
    final xScale = _stage.size.width / boardInnerBox.width;
    final yScale = _stage.size.height / boardInnerBox.height;

    final prettyScale = min(1, min(xScale, yScale));

    final newDimensions = _gameElement.size * prettyScale;
    //assert(newDimensions.fitsInside(_stage.size));

    final delta = new Vector(_stage.size.width - newDimensions.width,
        min(40, _stage.size.height - newDimensions.height))
      .scale(0.5)
      .scale(1/prettyScale);

    _gameElementTx.setToScale(prettyScale, prettyScale);
    _gameElementTx.translate(delta.x, delta.y);

    var updated = _stage.draw();
    _frameRequested = false;
    if(updated) {
      _requestFrame();
    }
  }

  void updateClock() {
    _requestFrame();
    super.updateClock();
  }

  void gameUpdated(args) {
    _requestFrame();
  }

  void _stageInvalidated(args) {
    _requestFrame();
  }

  void _mouseMoveHandler(ElementMouseEventArgs args) {
    bool showPointer = false;
    if(!game.gameEnded && args.element is SquareElement) {
      final SquareElement se = args.element;
      showPointer = game.canReveal(se.x, se.y);
    } else if(args.element is NewGameElement) {
      showPointer = true;
    } else if(args.element is GameTitleElement) {
      showPointer = true;
    }
    _updateCursor(showPointer);
  }

  void _mouseOutHandler(args) {
    _updateCursor(false);
  }

  void _updateCursor(bool showFinger) {
    _canvas.style.cursor = showFinger ? 'pointer' : 'inherit';
  }
}
