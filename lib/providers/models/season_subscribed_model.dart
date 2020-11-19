import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/http.dart';
import 'package:mikan_flutter/internal/repo.dart';
import 'package:mikan_flutter/model/season.dart';
import 'package:mikan_flutter/model/season_gallery.dart';
import 'package:mikan_flutter/model/year_season.dart';
import 'package:mikan_flutter/providers/models/base_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SeasonSubscribedModel extends CancelableBaseModel {
  bool _hasScrolled = false;

  bool get hasScrolled => _hasScrolled;

  set hasScrolled(bool value) {
    if (this._hasScrolled != value) {
      this._hasScrolled = value;
      notifyListeners();
    }
  }

  int _tapBangumiItemIndex = -1;

  set tapBangumiItemIndex(int value) {
    _tapBangumiItemIndex = value;
    notifyListeners();
  }

  int get tapBangumiItemIndex => _tapBangumiItemIndex;
  bool _loading = false;

  bool get loading => _loading;

  List<Season> _seasons;

  List<Season> get seasons => _seasons;

  int _loadIndex = 1;

  SeasonSubscribedModel(this._years, this._galleries) {
    this._seasons =
        this._years.map((e) => e.seasons).expand((element) => element).toList();
    Future.delayed(Duration(milliseconds: 250), () {
      this._refreshController.requestLoading(needMove: false);
    });
  }

  final List<YearSeason> _years;

  final List<SeasonGallery> _galleries;

  List<SeasonGallery> get galleries => _galleries;

  final RefreshController _refreshController = RefreshController();

  RefreshController get refreshController => _refreshController;

  _loadSeasonBangumis() async {
    if (this._loadIndex >= this._seasons.length) {
      return _refreshController.loadNoData();
    }
    this._loading = true;
    final Season season = this._seasons[this._loadIndex];
    final Resp resp = await (this +
        Repo.mySubscribedSeasonBangumi(season.year, season.season));
    this._loading = false;
    if (resp.success) {
      if (this._loadIndex == 0) {
        this._galleries.clear();
      }
      this._galleries.add(SeasonGallery(
            season: season.title,
            bangumis: resp.data ?? [],
          ));
      this._loadIndex++;
      this._refreshController.completed();
      notifyListeners();
    } else {
      this._refreshController.failed();
      "获取${season.title}订阅失败：${resp.msg}".toast();
    }
  }

  refresh() async {
    if (this._loading) return "加载中，请等待加载完成...";
    this._loadIndex = 0;
    await _loadSeasonBangumis();
  }

  loadMore() async {
    if (this._loading) return "加载中，请等待加载完成...";
    await _loadSeasonBangumis();
  }
}