library ppw_canvas;

import 'dart:html';
import 'dart:math';
import 'package:bot/bot.dart';
import 'package:bot/html.dart';
import 'package:bot/retained.dart';
import 'package:bot/texture.dart';
import 'analytics.dart';
import 'html.dart';
import 'poppopwin.dart';

part 'src/canvas/board_element.dart';
part 'src/canvas/game_background_element.dart';
part 'src/canvas/game_element.dart';
part 'src/canvas/game_root.dart';
part 'src/canvas/new_game_element.dart';
part 'src/canvas/score_element.dart';
part 'src/canvas/square_element.dart';
part 'src/canvas/title_element.dart';
part 'src/canvas/game_audio.dart';

EventHandle _titleClickedEventHandle = new EventHandle<EventArgs>();

EventRoot titleClickedEvent = _titleClickedEventHandle;

