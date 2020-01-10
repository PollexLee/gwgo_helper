import 'package:flutter/material.dart';
import 'package:gwgo_helper/config.dart';
import 'package:gwgo_helper/config/strings.dart';
import 'package:gwgo_helper/provider/provider_widget.dart';
import 'package:gwgo_helper/ui/home/home_view_model.dart';
import 'package:gwgo_helper/ui/promise/promise.dart';
import 'package:gwgo_helper/utils/common_utils.dart';
import 'package:provider/provider.dart';

class NewHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NewHomeState();
  }
}

class NewHomeState extends State<NewHomePage> {
  @override
  void initState() {
    /// 第一次启动，自动跳转到使用说明
    Config.init(context);
    // 初始化授权相关
    PromiseInstance(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<HomeViewModel>(
      viewModel: HomeViewModel(context),
      onReady: (model) async {
        await model.init();
      },
      builder: (context, viewmodel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Consumer(
              builder: (context, UserInfoProvider provider, _) {
                return RichText(
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                      text: Strings.appName,
                      style: Theme.of(context)
                          .textTheme
                          .title
                          .copyWith(color: Colors.white),
                    ),
                    TextSpan(
                        text: '  ' + provider.invalidTime,
                        style: provider.invalidTime.contains('到期时间')
                            ? null
                            : TextStyle(color: Colors.red)),
                  ]),
                );
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.help),
                onPressed: viewmodel.onIndicator,
                tooltip: '使用说明',
              )
            ],
          ),
          body: _buildBody(viewmodel),
        );
      },
    );
  }

  Widget _buildBody(HomeViewModel model) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 5.0, mainAxisSpacing: 5.0),
        children: <Widget>[
          HomeCardWidget(
            title: '御剑飞行',
            subTitle: '可使持剑人进入“御剑飞行”状态，可上九天揽月，可下五洋捉鳖。',
            ontap: () {
              model.fly();
            },
          ),
          HomeCardWidget(
            title: '妖灵探测',
            subTitle: '释放剑气，探测附近妖灵，在“御剑飞行”状态下，可立即飞过去抓取此妖灵。',
            ontap: () {
              model.scanningYaoling();
            },
          ),
          HomeCardWidget(
            title: '神剑授权',
            subTitle: '此剑为上古神剑，无法祭练，但可使用特殊令牌操控一二。',
            ontap: () {
              model.openPromisePage();
            },
          ),
          HomeCardWidget(
            title: '飞剑传书',
            subTitle: '可通过飞剑传书，联系炼器师，询问令牌购买、飞剑使用等相关事宜。',
            ontap: () {
              openQQ('3234991420');
            },
          ),
        ],
      ),
    );
  }
}

class HomeCardWidget extends StatelessWidget {
  final String title;
  final Function() ontap;
  final String subTitle;

  HomeCardWidget({this.title, this.ontap, this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        onTap: ontap,
        child: Container(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.title,
              ),
              SizedBox(height: 10),
              Text(
                subTitle,
                style: Theme.of(context).textTheme.subtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
